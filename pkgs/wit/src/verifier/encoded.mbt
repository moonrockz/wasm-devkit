///|
/// An original encoded package and private lowering. Construction validates the
/// whole component and consumes every WIT export; unsupported forms fail closed.
/// The private lowering never appears in Resolution::sources or source origins.
pub struct EncodedPackage {
  source_id : String
  bytes : Bytes
  lowered : SourcePackage
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
    let component = @component.parse_component(bytes) catch {
      _ => raise Invalid("validated component could not be read")
    }
    let text = lower_encoded(component)
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
    Ok({ source_id, bytes, lowered, })
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
  for input in [root].iter().concat(dependencies.iter()) {
    if input is Encoded(encoded) {
      binaries[encoded.source_id] = true
      encoded_inputs.push(encoded)
    }
  }
  let result = match
    prepare(root.lowered(), dependencies.map(PackageInput::lowered)) {
    Err(errors) => Err(errors)
    Ok(prepared) =>
      verify_prepared(prepared, semantic_features, binary_sources=binaries)
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
// Guard the maintained WAT parser before its recursive s-expression reader.
// Comments and strings have their own framing; input nesting uses explicit state.
fn encoded_wat_preflight(text : String) -> Unit raise EncodedFailure {
  let mut index = 0
  let mut depth = 0
  let mut comments = 0
  let mut quoted = false
  let mut line = false
  while index < text.length() {
    let unit = text.code_unit_at(index).to_int()
    let next = if index + 1 < text.length() {
      text.code_unit_at(index + 1).to_int()
    } else {
      -1
    }
    if line {
      if unit == 10 || unit == 13 {
        line = false
      }
    } else if quoted {
      if unit == 92 {
        index += 1
      } else if unit == 34 {
        quoted = false
      }
    } else if comments > 0 {
      if unit == 40 && next == 59 {
        comments += 1
        index += 1
      } else if unit == 59 && next == 41 {
        comments -= 1
        index += 1
      }
    } else if unit == 59 && next == 59 {
      line = true
      index += 1
    } else if unit == 40 && next == 59 {
      comments = 1
      index += 1
    } else if unit == 34 {
      quoted = true
    } else if unit == 40 {
      depth += 1
    } else if unit == 41 {
      depth -= 1
      guard depth >= 0 else {
        raise Invalid("unmatched WAT closing parenthesis")
      }
    }
    guard depth <= 256 && comments <= 256 else {
      raise Unsupported("WAT nesting exceeds 256")
    }
    index += 1
  }
  guard depth == 0 && comments == 0 && !quoted else {
    raise Invalid("unclosed WAT expression, comment or string")
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
    encoded_wat_preflight(text)
    let bytes = @component_text.parse_component_wat(text) catch {
      @component_text.Unsupported(message) => raise Unsupported(message)
      @component_text.ParseError(message) => raise Invalid(message)
    }
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
