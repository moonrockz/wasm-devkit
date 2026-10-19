///|
priv struct SemanticArena {
  types : Map[Int32, ResolvedType]
  functions : Map[Int32, ResolvedFunction]
  interfaces : Map[Int32, ResolvedInterface]
  owners : Map[Int32, Int32]
  origins : Array[Origin]
  type_order : Array[Int32]
  function_order : Array[Int32]
  interface_order : Array[Int32]
}

///|
fn lexical_owners(tree : @ast.Tree) -> ReadOnlyArray[Int32] {
  let parents = Array::make(tree.nodes.length(), -1)
  for id, node in tree.nodes {
    for child in node.data.children() {
      parents[child] = id
    }
  }
  let owners = Array::make(tree.nodes.length(), -1)
  for id = tree.nodes.length() - 1; id >= 0; id = id - 1 {
    match tree.nodes[id].data {
      Interface(..) | World(..) => owners[id] = id
      _ => if parents[id] >= 0 { owners[id] = owners[parents[id]] }
    }
  }
  ReadOnlyArray::from_array(owners)
}

///|
fn SemanticArena::new(
  prepared : Prepared,
  references : Map[Int32, Int32],
  resources : ReadOnlyArray[Int32],
  stabilities : ReadOnlyArray[StabilityInfo],
) -> SemanticArena {
  let scopes = lexical_owners(prepared.tree)
  let origins = prepared.origins.iter().to_array()
  let types = resolved_types(
      prepared.tree,
      prepared.origins.map(o => o.location),
      references,
      scopes,
      resources,
      type_stabilities(prepared.tree, references, resources, stabilities),
    )
    .iter()
    .to_array()
  let functions = model_functions(prepared, scopes, types, origins, stabilities)
  let interfaces = model_interfaces(prepared, functions, stabilities)
  let arena : SemanticArena = {
    types: Map([]),
    functions: Map([]),
    interfaces: Map([]),
    owners: Map([]),
    origins,
    type_order: [],
    function_order: [],
    interface_order: [],
  }
  for ty in types {
    arena.types[ty.id] = ty
    arena.owners[ty.id] = ty.scope
    arena.type_order.push(ty.id)
  }
  for function in functions {
    arena.functions[function.id] = function
    arena.owners[function.id] = scopes[function.id]
    arena.function_order.push(function.id)
  }
  for interface_ in interfaces {
    arena.interfaces[interface_.id] = interface_
    arena.interface_order.push(interface_.id)
  }
  arena
}

///|
fn SemanticArena::allocate(self : SemanticArena, source : Int32) -> Int32 {
  let id = self.origins.length()
  self.origins.push(self.origins[source])
  id
}

///|
fn kind_children(kind : TypeKind) -> ReadOnlyArray[Int32] {
  match kind {
    Scalar(_) | Resource | Flags(_) | Enum(_) => []
    Alias(id) | Own(id) | Borrow(id) | List(id, _) | Option(id) => [id]
    Tuple(ids) => ids
    Result(ok, error) => {
      let ids = []
      if ok is Some(id) {
        ids.push(id)
      }
      if error is Some(id) {
        ids.push(id)
      }
      ReadOnlyArray::from_array(ids)
    }
    Future(id) | Stream(id) =>
      match id {
        Some(id) => [id]
        None => []
      }
    Map(key, value) => [key, value]
    Record(fields) => fields.map(field => field.ty)
    Variant(cases) =>
      ReadOnlyArray::from_array(
        cases.iter().filter_map(case_ => case_.payload).to_array(),
      )
  }
}

///|
fn remap_kind(kind : TypeKind, replace : (Int32) -> Int32) -> TypeKind {
  match kind {
    Scalar(_) | Resource | Flags(_) | Enum(_) => kind
    Alias(id) => Alias(replace(id))
    Own(id) => Own(replace(id))
    Borrow(id) => Borrow(replace(id))
    List(id, size) => List(replace(id), size)
    Option(id) => Option(replace(id))
    Tuple(ids) => Tuple(ids.map(replace))
    Result(ok, error) => Result(ok.map(replace), error.map(replace))
    Future(id) => Future(id.map(replace))
    Stream(id) => Stream(id.map(replace))
    Map(key, value) => Map(replace(key), replace(value))
    Record(fields) =>
      Record(fields.map(field => { ..field, ty: replace(field.ty), }))
    Variant(cases) =>
      Variant(
        cases.map(case_ => { ..case_, payload: case_.payload.map(replace), }),
      )
  }
}

///|
fn SemanticArena::copy_types(
  self : SemanticArena,
  roots : Array[Int32],
  old_owner : Int32,
  owner : Int32,
  names : Map[Int32, String],
  mapping : Map[Int32, Int32],
) -> Unit {
  let pending = roots.copy()
  let copied = []
  while pending.pop() is Some(id) {
    if mapping.contains(id) || self.owners.get(id) != Some(old_owner) {
      continue
    }
    let fresh = self.allocate(id)
    mapping[id] = fresh
    copied.push(id)
    for child in kind_children(self.types[id].kind) {
      pending.push(child)
    }
  }
  let replace = fn(id : Int32) { mapping.get(id).unwrap_or(id) }
  for id in copied {
    let original = self.types[id]
    let fresh = mapping[id]
    let name = match names.get(id) {
      Some(name) => Some(name)
      None => original.name
    }
    self.types[fresh] = {
      ..original,
      id: fresh,
      name,
      scope: owner,
      kind: remap_kind(original.kind, replace),
    }
    self.owners[fresh] = owner
    self.type_order.push(fresh)
  }
}

///|
fn SemanticArena::copy_function(
  self : SemanticArena,
  id : Int32,
  owner : Int32,
  name : String,
  mapping : Map[Int32, Int32],
) -> ResolvedFunction {
  let original = self.functions[id]
  let fresh = self.allocate(id)
  let replace = fn(id : Int32) { mapping.get(id).unwrap_or(id) }
  let kind = remap_function_kind(original.kind, replace)
  let name = match function_resource(kind) {
    Some(resource) =>
      match self.types[resource].name {
        Some(resource_name) =>
          remap_function_name(name, kind, original.flavor, resource_name)
        None => name
      }
    None => name
  }
  let copied = {
    ..original,
    id: fresh,
    name,
    kind,
    params: original.params.map(param => { ..param, ty: replace(param.ty), }),
    result: original.result.map(replace),
  }
  self.functions[fresh] = copied
  self.owners[fresh] = owner
  self.function_order.push(fresh)
  copied
}

///|
fn SemanticArena::copy_world(
  self : SemanticArena,
  prepared : Prepared,
  old_owner : Int32,
  owner : Int32,
  imports : Array[WorldItem],
  exports : Array[WorldItem],
  replacements : Map[String, (String, Int32)],
  dependencies : Map[Int32, Array[(Int32, Int32)]],
) -> (Array[WorldItem], Array[WorldItem]) {
  let roots : Array[Int32] = []
  let names : Map[Int32, String] = Map([])
  let mapping : Map[Int32, Int32] = Map([])
  for item in imports {
    if item.kind is Type(id) {
      roots.push(id)
      names[id] = match replacements.get(item.name) {
        Some((name, _)) => name
        None => item.name
      }
    }
  }
  for item in imports.iter().concat(exports.iter()) {
    if item.kind is Function(id) {
      for param in self.functions[id].params {
        roots.push(param.ty)
      }
      if self.functions[id].result is Some(id) {
        roots.push(id)
      }
    }
  }
  self.copy_types(roots, old_owner, owner, names, mapping)
  let copied_sides = []
  let copied_interfaces : Map[Int32, Int32] = Map([])
  for side in [imports, exports] {
    let copied = []
    for item in side {
      let mut name = if !item.by_id {
        include_item_name(item.name, replacements)
      } else {
        item.name
      }
      let kind : WorldItemKind = match item.kind {
        Type(id) => Type(mapping.get(id).unwrap_or(id))
        Function(id) => {
          let function = self.copy_function(id, owner, name, mapping)
          name = function.name
          Function(function.id)
        }
        Interface(id) => {
          let original = self.interfaces[id]
          if original.name is Some(_) {
            item.kind
          } else {
            let interface_id = match copied_interfaces.get(id) {
              Some(id) => id
              None => {
                let fresh = self.allocate(id)
                copied_interfaces[id] = fresh
                let local_roots = original.types
                  .map(ty => ty.ty)
                  .iter()
                  .to_array()
                for function in original.functions {
                  for param in function.params {
                    local_roots.push(param.ty)
                  }
                  if function.result is Some(id) {
                    local_roots.push(id)
                  }
                }
                let local_mapping : Map[Int32, Int32] = Map([])
                self.copy_types(local_roots, id, fresh, Map([]), local_mapping)
                let functions = original.functions.map(function => {
                  self.copy_function(
                    function.id,
                    fresh,
                    function.name,
                    local_mapping,
                  )
                })
                let types = original.types.map(ty => {
                  ..ty,
                  ty: local_mapping.get(ty.ty).unwrap_or(ty.ty),
                })
                self.interfaces[fresh] = {
                  ..original,
                  id: fresh,
                  package_identity: prepared.identities[prepared.node_packages[owner]],
                  functions,
                  types,
                }
                self.interface_order.push(fresh)
                dependencies[fresh] = dependencies[id].copy()
                fresh
              }
            }
            Interface(interface_id)
          }
        }
      }
      copied.push({ ..item, name, kind, })
    }
    copied_sides.push(copied)
  }
  (copied_sides[0], copied_sides[1])
}
