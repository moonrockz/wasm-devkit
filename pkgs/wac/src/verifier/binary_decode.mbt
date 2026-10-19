///|
fn BinaryGraph::type_alias(
  self : BinaryGraph,
  referenced : Int32,
  name : String,
) -> Int32 raise BinaryFailure {
  let target = self.follow(referenced)
  self.add(
    if self.types[target].kind is Resource(_) {
      Resource(Some(target))
    } else {
      Alias(referenced)
    },
    name=Some(name),
  )
}

///|
fn BinaryGraph::describe(
  self : BinaryGraph,
  scope : BinaryScope,
  importing : Bool,
  name : String,
  attributes : Array[@component.NameAttribute],
  desc : @component.ExternDesc,
) -> ItemKind raise BinaryFailure {
  let kind : ItemKind = match desc {
    Type(SubResource) => {
      let id = self.add(Resource(None), name=Some(name))
      scope.resources.push(id)
      Type(id)
    }
    Type(Eq(index)) => {
      let referenced = binary_index(scope.types, index)
      let id = self.type_alias(referenced, name)
      if scope.parent is Some(_) && (scope.interface_scope || importing) {
        self.own_or_use(scope, name, referenced, id)
      }
      Type(id)
    }
    FuncType(index) => Function(self.follow(binary_index(scope.types, index)))
    InstanceType(index) => {
      for attr in attributes {
        if attr is Implements(bytes) {
          let names = match self.implements_names.get(scope.owner) {
            Some(names) => names
            None => {
              let names : Map[String, String] = Map([])
              self.implements_names[scope.owner] = names
              names
            }
          }
          names[name] = binary_text(bytes)
        }
      }
      Instance(self.instantiate_type(scope, binary_index(scope.types, index)))
    }
    ComponentType(index) =>
      Component(self.instantiate_type(scope, binary_index(scope.types, index)))
    Value(_) =>
      raise Unsupported(
        "component values are outside the binary package profile",
      )
    CoreModuleType(index) => {
      guard scope.core_ids.get(index) is Some(Some(id)) else {
        raise Invalid("core module type index is invalid")
      }
      Module(id)
    }
  }
  if desc is Type(SubResource) &&
    scope.parent is Some(_) &&
    (scope.interface_scope || importing) {
    self.owners[binary_kind_id(kind)] = (scope.owner, name)
  }
  scope.bind(kind)
  kind
}

///|
fn BinaryGraph::alias_entry(
  self : BinaryGraph,
  scope_id : Int32,
  alias_entry : @component.Alias,
) -> Unit raise BinaryFailure {
  let scope = self.scopes[scope_id]
  let item = match alias_entry.target {
    Outer(count, index) => {
      let mut outer = scope_id
      for _ in 0..<count {
        guard self.scopes[outer].parent is Some(parent) else {
          raise Invalid("outer alias exceeds lexical scopes")
        }
        outer = parent
      }
      if alias_entry.sort is Core(0x10) {
        let source = self.scopes[outer]
        guard source.core_types.get(index) is Some(definition) else {
          raise Invalid("outer core type alias index is invalid")
        }
        let id = source.core_ids[index]
        scope.core_types.push(definition)
        scope.core_ids.push(id)
        return
      }
      self.scopes[outer].lookup(alias_entry.sort, index)
    }
    Export(index, name) => {
      let id = self.follow(binary_index(scope.instances, index))
      guard self.types[id].kind is Interface(_, _, exports) else {
        raise Invalid("instance alias target is not an interface")
      }
      let mut found : ItemKind? = None
      for item in exports {
        if item.name == name {
          found = Some(item.kind)
        }
      }
      guard found is Some(kind) else {
        raise Invalid("instance alias export is missing")
      }
      kind
    }
    CoreExport(_, _) =>
      raise Unsupported(
        "core export aliases are outside the declarative package profile",
      )
  }
  scope.bind(item)
}

///|
fn BinaryGraph::export_entry(
  self : BinaryGraph,
  scope : BinaryScope,
  export_entry : @component.Export,
) -> Unit raise BinaryFailure {
  let name = binary_export_name(export_entry.name)
  let original = scope.lookup(
    export_entry.sortidx.sort,
    export_entry.sortidx.idx,
  )
  let kind = match (original, export_entry.desc) {
    (Type(id), None) => Type(self.type_alias(id, name))
    (_, None) => original
    (Function(_), Some(FuncType(index))) =>
      Function(self.follow(binary_index(scope.types, index)))
    _ =>
      raise Unsupported(
        "root export ascriptions are outside the binary package profile",
      )
  }
  scope.bind(kind)
  scope.exports.push({ name, kind, location: self.location, })
}

///|
fn binary_root_declarations(
  component : @component.Component,
) -> Array[BinaryDeclaration] raise BinaryFailure {
  try {
    let declarations = []
    for section in component.binary.sections {
      match section.id {
        0 => ()
        1 => declarations.push(CoreModule(section.payload))
        3 => declarations.push(CoreDefine(section.payload, true))
        7 =>
          for definition in @component.parse_type_section(section.payload) {
            declarations.push(BinaryDeclaration::Define(definition))
          }
        6 =>
          for alias_entry in @component.parse_alias_section(section.payload) {
            declarations.push(Alias(alias_entry))
          }
        10 =>
          for imported in @component.parse_import_section(section.payload) {
            declarations.push(
              Describe(
                true,
                binary_import_name(imported.name),
                imported.attributes,
                imported.desc,
              ),
            )
          }
        11 =>
          for exported in @component.parse_export_section(section.payload) {
            declarations.push(Export(exported))
          }
        _ =>
          raise Unsupported(
            "runtime sections are outside the declarative package profile",
          )
      }
    }
    declarations
  } catch {
    Unsupported(message) => raise Unsupported(message)
    Invalid(message) => raise Invalid(message)
    error => raise Invalid(error.to_string())
  }
}

///|
fn binary_decode(
  component : @component.Component,
  bytes : Bytes,
  source_id : String,
) -> Result[BinaryPackage, ReadOnlyArray[Diagnostic]] raise BinaryFailure {
  let graph : BinaryGraph = {
    location: Location::binary(source_id),
    remaining: 1000000,
    types: [],
    scopes: [],
    primitives: Map([]),
    bound_resources: Map([]),
    owners: Map([]),
    implements_names: Map([]),
  }
  let root = graph.scope(None, binary_root_declarations(component), false)
  let work : Array[(Int32, Int32)] = [(root, 0)]
  while work.pop() is Some((scope_id, position)) {
    graph.step()
    let scope = graph.scopes[scope_id]
    if position == scope.declarations.length() {
      let uses = ReadOnlyArray::from_array(scope.uses)
      let exports = ReadOnlyArray::from_array(scope.exports)
      let kind : TypeKind = if scope.interface_scope {
        Interface(None, uses, exports)
      } else {
        World(None, uses, ReadOnlyArray::from_array(scope.imports), exports)
      }
      graph.types[scope.owner] = { ..graph.types[scope.owner], kind, }
      graph.bound_resources[scope.owner] = scope.resources.copy()
      if scope.parent is Some(parent) {
        graph.scopes[parent].types.push(scope.owner)
      }
      continue
    }
    work.push((scope_id, position + 1))
    match scope.declarations[position] {
      Define(definition) =>
        match definition {
          ComponentType(_) | InstanceType(_) | InstanceTypeEmpty => {
            let child = graph.scope(
              Some(scope_id),
              binary_declarations(definition),
              !(definition is ComponentType(_)),
            )
            work.push((child, 0))
          }
          _ => scope.types.push(graph.definition(scope, definition))
        }
      CoreModule(bytes) => {
        graph.step()
        match @core_types.decode_module(bytes) {
          Ok(contract) => scope.modules.push(graph.add(Module(contract)))
          Err(error) => raise Invalid(error.message)
        }
      }
      CoreDefine(bytes, section) =>
        graph.core_definition(scope_id, bytes, section)
      Alias(alias_entry) => graph.alias_entry(scope_id, alias_entry)
      Describe(importing, name, attributes, desc) => {
        let kind = graph.describe(scope, importing, name, attributes, desc)
        let item : Extern = { name, kind, location: graph.location, }
        if importing {
          scope.imports.push(item)
        } else {
          scope.exports.push(item)
        }
      }
      Export(export_entry) => graph.export_entry(scope, export_entry)
    }
  }
  let root_scope = graph.scopes[root]
  graph.assign_identities(root_scope.owner)
  let instance_type = graph.add(
    Interface(None, [], ReadOnlyArray::from_array(root_scope.exports)),
  )
  let definitions = []
  for item in root_scope.exports {
    guard item.kind is Type(ty) else { continue }
    let ty = graph.follow(ty)
    guard graph.types[ty].kind is World(_, _, _, exports) &&
      exports.length() == 1 else {
      continue
    }
    let exported = exports[0]
    // Validated qualified component names identify WIT interface/world exports.
    guard exported.name.contains(":") && exported.name.contains("/") else {
      continue
    }
    match exported.kind {
      Instance(id) | Component(id) =>
        definitions.push({ ..item, kind: Type(id), })
      _ => ()
    }
  }
  Ok({
    source_id,
    snapshot: bytes,
    arena: ReadOnlyArray::from_array(graph.types),
    world_type: root_scope.owner,
    instance_type,
    defined_items: ReadOnlyArray::from_array(definitions),
  })
}
