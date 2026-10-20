///|
/// An original encoded package and private lowering. Construction validates the
/// whole component and consumes every WIT export; unsupported forms fail closed.
/// The private lowering never appears in Resolution::sources or source origins.
pub struct EncodedPackage {
  priv source_id : String
  priv bytes : Bytes
  priv lowered : SourcePackage
  priv metadata : Map[Int32, Stability]
  priv references : Map[Int32, EncodedReference]
}

///|
pub(all) enum PackageInput {
  Source(SourcePackage)
  Encoded(EncodedPackage)
}

///|
pub fn EncodedPackage::source(self : EncodedPackage) -> String {
  self.source_id
}

///|
pub fn EncodedPackage::bytes(self : EncodedPackage) -> Bytes {
  self.bytes
}

///|
pub fn EncodedPackage::identity(self : EncodedPackage) -> PackageIdentity {
  // The constructor has already checked this private lowering's identity.
  self.lowered.identity().unwrap()
}

///|
pub fn decode_package(
  bytes : Bytes,
  source_id~ : String = "<binary>",
) -> Result[EncodedPackage, ReadOnlyArray[Diagnostic]] {
  match @binary.validate_type_component(bytes, source_id~) {
    Err(diagnostics) => return Err(diagnostics.map(Diagnostic::from_binary))
    Ok(_) => ()
  }
  try {
    let component = @type_parser.parse_component(bytes) catch {
      _ => raise Invalid("validated component could not be read")
    }
    let (text, metadata_bytes, markers) = lower_encoded(component)
    let parsed = @parser.parse(text, features=@parser.Features::reference())
    guard parsed.is_valid() else {
      raise Invalid("decoded package cannot be represented by the WIT grammar")
    }
    let lowered : SourcePackage = {
      documents: [Document::from_parse(source_id, text, parsed)],
    }
    guard lowered.identity() is Ok(_) else {
      raise Invalid("invalid decoded package identity")
    }
    let metadata : Map[Int32, Stability] = match metadata_bytes {
      None => Map([])
      Some(bytes) => metadata_read(bytes, lowered)
    }
    let references : Map[Int32, EncodedReference] = Map([])
    for id, node in lowered.documents[0].ast.nodes {
      if node.data is NamedType(name~) &&
        markers.get(name) is Some((path, type_name)) {
        let (package_identity, interface_name) = if path.contains("/") {
          let (identity, interface_name) = encoded_qualified(path)
          (Some(identity), interface_name)
        } else {
          (None, path)
        }
        references[id] = { package_identity, interface_name, type_name, }
      }
    }
    Ok({ source_id, bytes, lowered, metadata, references, })
  } catch {
    Unsupported(message) =>
      Err([error_at(Location::binary(source_id), "WIT-B002", message)])
    Invalid(message) =>
      Err([error_at(Location::binary(source_id), "WIT-B004", message)])
  }
}

///|
fn PackageInput::lowered(self : PackageInput) -> SourcePackage {
  match self {
    Source(source) => source
    Encoded(package_input) => package_input.lowered
  }
}

///|
pub fn PackageInput::identity(
  self : PackageInput,
) -> Result[PackageIdentity, ReadOnlyArray[Diagnostic]] {
  match self {
    Source(source) => source.identity()
    Encoded(package_input) => Ok(package_input.identity())
  }
}

///|
fn encoded_location(
  location : Location,
  binaries : Map[String, Bool],
) -> Location {
  if binaries.contains(location.source) {
    Location::binary(location.source)
  } else {
    location
  }
}

///|
fn encoded_diagnostic(
  diagnostic : Diagnostic,
  binaries : Map[String, Bool],
) -> Diagnostic {
  let label = fn(label : Label) {
    { ..label, location: encoded_location(label.location, binaries), }
  }
  {
    ..diagnostic,
    primary: label(diagnostic.primary),
    related: diagnostic.related.map(label),
  }
}

///|
fn encoded_resolution(
  resolution : Resolution,
  binaries : Map[String, Bool],
  inputs : ReadOnlyArray[EncodedPackage],
) -> Resolution {
  let location = fn(location) { encoded_location(location, binaries) }
  let member_location = fn(member_info : TypeMember) {
    { ..member_info, location: location(member_info.location), }
  }
  let function_location = fn(function : ResolvedFunction) {
    {
      ..function,
      params: function.params.map(member_location),
      location: location(function.location),
    }
  }
  let item_location = fn(item : WorldItem) {
    { ..item, location: location(item.location), }
  }
  let model = resolution.model
  {
    ..resolution,
    encoded_packages: inputs,
    root_location: location(resolution.root_location),
    documents: ReadOnlyArray::from_array(
      resolution.documents
      .iter()
      .filter(document => !binaries.contains(document.id))
      .to_array(),
    ),
    origins: resolution.origins.map(origin => {
      if binaries.contains(origin.location.source) {
        { location: location(origin.location), node: None, }
      } else {
        origin
      }
    }),
    model: {
      ..model,
      resolved_types: model.resolved_types.map(ty => {
        let kind : TypeKind = match ty.kind {
          Record(members) => Record(members.map(member_location))
          Variant(cases) =>
            Variant(
              cases.map(case => { ..case, location: location(case.location), }),
            )
          kind => kind
        }
        { ..ty, kind, location: location(ty.location), }
      }),
      resolved_functions: model.resolved_functions.map(function_location),
      resolved_interfaces: model.resolved_interfaces.map(interface_info => {
        ..interface_info,
        location: location(interface_info.location),
        types: interface_info.types.map(member_location),
        functions: interface_info.functions.map(function_location),
      }),
      resolved_worlds: model.resolved_worlds.map(world => {
        ..world,
        location: location(world.location),
        imports: world.imports.map(item_location),
        exports: world.exports.map(item_location),
      }),
    },
  }
}

///|
/// Resolve caller-supplied source and encoded packages without I/O. Encoded
/// packages retain binary provenance and never publish their private lowering.
pub fn resolve_packages(
  root : PackageInput,
  dependencies~ : ReadOnlyArray[PackageInput] = [],
  semantic_features~ : SemanticFeatures = SemanticFeatures::default(),
) -> Result[Resolution, ReadOnlyArray[Diagnostic]] {
  let binaries : Map[String, Bool] = Map([])
  let encoded_inputs = []
  let input_ranks : Map[String, Int32] = Map([])
  let external_id_overrides : Map[(String, String, String), String?] = Map([])
  let selected_models : Array[Resolution] = []
  let mut input_rank = 0
  let input_metadata : Map[String, Map[Int32, Stability]] = Map([])
  let input_references : Map[String, Map[Int32, EncodedReference]] = Map([])
  for input in [root].iter().concat(dependencies.iter()) {
    for document in input.lowered().documents {
      input_ranks[document.id] = input_rank
    }
    input_rank += 1
    if input is Encoded(encoded) {
      binaries[encoded.source_id] = true
      encoded_inputs.push(encoded)
      input_metadata[encoded.source_id] = encoded.metadata
      input_references[encoded.source_id] = encoded.references
    }
  }
  let inferred_closure = encoded_inputs.any(input => {
    input.lowered.documents.any(document => {
      document.ast.nodes.any(node => node.data is Package(nested=true, ..))
    })
  })
  let prepared = prepare(
    root.lowered(),
    dependencies.map(PackageInput::lowered),
    binary_sources=binaries,
    merge_encoded=!inferred_closure,
  )
  let prepared = match prepared {
    Ok(prepared) if inferred_closure =>
      if encoded_overlapping_packages(prepared, binaries) {
        encoded_select_closure(
          prepared, encoded_inputs, binaries, semantic_features, input_metadata,
          input_references, input_ranks, external_id_overrides, selected_models,
        )
      } else {
        encoded_selected_prepared(prepared, Map([]), binaries)
      }
    other => other
  }
  let result = match prepared {
    Err(errors) => Err(errors)
    Ok(prepared) => {
      let metadata : Map[Int32, Stability] = Map([])
      let inputs : Map[String, EncodedPackage] = Map([])
      for input in encoded_inputs {
        inputs[input.source_id] = input
      }
      for id, origin in prepared.origins {
        if inputs.get(origin.location.source) is Some(input) &&
          origin.node is Some(node) &&
          input.metadata.get(node) is Some(value) {
          metadata[id] = value
        }
      }
      verify_prepared(
        prepared,
        semantic_features,
        binary_sources=binaries,
        binary_metadata=metadata,
        binary_references=encoded_reference_nodes(prepared, input_references),
        external_id_overrides~,
        selected_models~,
        input_ranks~,
      )
    }
  }
  match result {
    Err(errors) =>
      Err(errors.map(diagnostic => encoded_diagnostic(diagnostic, binaries)))
    Ok(resolution) =>
      Ok(
        encoded_resolution(
          resolution,
          binaries,
          ReadOnlyArray::from_array(encoded_inputs),
        ),
      )
  }
}

///|
/// Compile type-only component WAT using the pinned portable frontend, then run
/// the binary decoder. Diagnostics have no byte offset: compiled byte positions
/// cannot identify positions in the original WAT. bytes() returns compiled bytes.
pub fn decode_wat_package(
  text : String,
  source_id~ : String = "<wat>",
) -> Result[EncodedPackage, ReadOnlyArray[Diagnostic]] {
  try {
    let bytes = compile_encoded_wat(text)
    let binaries : Map[String, Bool] = Map([(source_id, true)])
    decode_package(bytes, source_id~).map_err(diagnostics => {
      diagnostics.map(diagnostic => encoded_diagnostic(diagnostic, binaries))
    })
  } catch {
    Unsupported(message) =>
      Err([error_at(Location::binary(source_id), "WIT-B002", message)])
    Invalid(message) =>
      Err([error_at(Location::binary(source_id), "WIT-B004", message)])
  }
}
