///|
fn WitAdapter::dependencies(
  self : WitAdapter,
  id : Int32,
) -> Array[Int32] raise SemanticFailure {
  let result = []
  let seen : Map[Int32, Bool] = Map([])
  for entry in self.interfaces[id].types {
    let mut target = entry.ty
    for _ in 0..<self.types.length() {
      guard self.types[target].kind is Alias(next) else { break }
      self.step(wit_location(self.types[target].location))
      target = next
      if self.owners.get(target) is Some(owner) && owner != id {
        if !seen.contains(owner) {
          seen[owner] = true
          result.push(owner)
        }
        break
      }
    }
  }
  result
}

///|
fn WitAdapter::used(
  self : WitAdapter,
  entry : @wit_verifier.TypeMember,
  context : WitContext,
) -> UsedType? raise SemanticFailure {
  let mut current = entry.ty
  let mut root = entry.ty
  for _ in 0..<self.types.length() {
    guard self.types[current].kind is Alias(next) else { break }
    self.step(wit_location(entry.location))
    current = next
    if self.owners.contains(current) {
      root = current
    }
  }
  guard root != entry.ty &&
    self.owners.get(root) is Some(owner) &&
    context.interfaces.get(owner) is Some(interface) else {
    return None
  }
  let original_name = self.types[root].name.unwrap_or(entry.name)
  Some({
    name: entry.name,
    original_name,
    interface,
    ty: context.types[entry.ty],
    location: wit_location(entry.location),
  })
}

///|
fn WitAdapter::copy_interface(
  self : WitAdapter,
  original : Int32,
  parent : WitContext,
) -> (Int32, WitContext) raise SemanticFailure {
  let source = self.interfaces[original]
  let context : WitContext = {
    types: parent.types.copy(),
    interfaces: parent.interfaces.copy(),
  }
  for entry in source.types {
    context.types.remove(entry.ty) |> ignore
  }
  let exports = []
  let uses = []
  for entry in source.types {
    let ty = self.copy_type(entry.ty, context)
    exports.push({
      name: entry.name,
      kind: Type(ty),
      location: wit_location(entry.location),
    })
    if self.used(entry, context) is Some(used) {
      uses.push(used)
    }
  }
  for function in source.functions {
    let ty = self.copy_function(function, context)
    exports.push({
      name: function.name,
      kind: Function(ty),
      location: wit_location(function.location),
    })
  }
  let identity = source.name.map(name => {
    wit_identity(source.package_identity, name)
  })
  let id = self.add(
    source.name,
    Interface(
      identity,
      ReadOnlyArray::from_array(uses),
      ReadOnlyArray::from_array(exports),
    ),
    wit_location(source.location),
  )
  context.interfaces[original] = id
  (id, context)
}

///|
// The dependency closure is ordered with an explicit DFS stack. Each wrapper
// gets a separate context, so resource declarations never leak between wrappers.
fn WitAdapter::interface_environment(
  self : WitAdapter,
  original : Int32,
  context : WitContext,
) -> ReadOnlyArray[Extern] raise SemanticFailure {
  let pending = []
  for dependency in self.dependencies(original).rev() {
    pending.push((dependency, false))
  }
  let active : Map[Int32, Bool] = Map([])
  let imports = []
  while pending.pop() is Some((id, finish)) {
    if context.interfaces.contains(id) {
      continue
    }
    let source = self.interfaces[id]
    let location = wit_location(source.location)
    self.step(location)
    if !finish {
      if active.contains(id) {
        raise Problem(wit_problem(location, "cyclic WIT interface dependency"))
      }
      active[id] = true
      pending.push((id, true))
      for dependency in self.dependencies(id).rev() {
        pending.push((dependency, false))
      }
      continue
    }
    let (copy, copied) = self.copy_interface(id, context)
    context.interfaces[id] = copy
    for entry in source.types {
      context.types[entry.ty] = copied.types[entry.ty]
    }
    active.remove(id) |> ignore
    guard source.name is Some(name) else {
      raise Problem(
        wit_problem(location, "anonymous WIT interface used as a dependency"),
      )
    }
    imports.push({
      name: wit_identity(source.package_identity, name),
      kind: Instance(copy),
      location,
    })
  }
  ReadOnlyArray::from_array(imports)
}

///|
fn WitAdapter::copy_world(
  self : WitAdapter,
  world : @wit_verifier.ResolvedWorld,
) -> Int32 raise SemanticFailure {
  let context : WitContext = { types: Map([]), interfaces: Map([]), }
  let imports = []
  let exports = []
  let uses = []
  for (items, importing) in [(world.imports, true), (world.exports, false)] {
    for item in items {
      let location = wit_location(item.location)
      self.step(location)
      let kind : ItemKind = match item.kind {
        Interface(original) => {
          let needed = self.interface_environment(original, context)
          for dependency in needed {
            imports.push(dependency)
          }
          let (copy, copied) = self.copy_interface(original, context)
          if importing && item.by_id {
            context.interfaces[original] = copy
            for entry in self.interfaces[original].types {
              context.types[entry.ty] = copied.types[entry.ty]
            }
          }
          Instance(copy)
        }
        Type(original) => {
          let copy = self.copy_type(original, context)
          let entry : @wit_verifier.TypeMember = {
            name: item.name,
            ty: original,
            location: item.location,
          }
          if self.used(entry, context) is Some(used) {
            uses.push(used)
          }
          Type(copy)
        }
        Function(original) =>
          Function(self.copy_function(self.functions[original], context))
      }
      let external : Extern = { name: item.name, kind, location, }
      if importing {
        imports.push(external)
      } else {
        exports.push(external)
      }
    }
  }
  self.add(
    Some(world.name),
    World(
      Some(wit_identity(world.package_identity, world.name)),
      ReadOnlyArray::from_array(uses),
      ReadOnlyArray::from_array(imports),
      ReadOnlyArray::from_array(exports),
    ),
    wit_location(world.location),
  )
}

///|
/// Translate an immutable WIT resolution into WAC package types without encoding
/// bytes, host tools or I/O. Fresh contexts preserve component resource binders.
pub fn adapt_wit_package(
  resolution : @wit_verifier.Resolution,
) -> Result[WitPackage, ReadOnlyArray[Diagnostic]] {
  for document in resolution.sources() {
    for node in document.ast.nodes {
      if node.data is Attribute(name="id", ..) ||
        node.data is Signature(flavor=Get | Set, ..) {
        return Err([
          wit_problem(
            Location::text(document.id, {
              start: node.span.start,
              end: node.span.end,
            }),
            "WIT source construct is outside WAC's pinned WIT profile",
          ),
        ])
      }
    }
  }
  let adapter : WitAdapter = {
    types: Map([]),
    interfaces: Map([]),
    functions: Map([]),
    owners: Map([]),
    roots: Map([]),
    arena: [],
    remaining: 1000000,
  }
  for ty in resolution.types() {
    adapter.types[ty.id] = ty
  }
  for interface in resolution.interfaces() {
    adapter.interfaces[interface.id] = interface
    for entry in interface.types {
      adapter.owners[entry.ty] = interface.id
    }
  }
  for function in resolution.functions() {
    adapter.functions[function.id] = function
  }
  try {
    let definitions = []
    let exports = []
    let root = resolution.root()
    let ordered = []
    let seen : Map[Int32, Bool] = Map([])
    for interface in resolution.interfaces() {
      if interface.package_identity != root || interface.name is None {
        continue
      }
      let pending = [(interface.id, false)]
      while pending.pop() is Some((id, finish)) {
        if seen.contains(id) {
          continue
        }
        adapter.step(wit_location(adapter.interfaces[id].location))
        if finish {
          seen[id] = true
          ordered.push(id)
          continue
        }
        pending.push((id, true))
        for dependency in adapter.dependencies(id).rev() {
          if adapter.interfaces[dependency].package_identity == root {
            pending.push((dependency, false))
          }
        }
      }
    }
    for id in ordered {
      let interface = adapter.interfaces[id]
      guard interface.name is Some(name) else { continue }
      let context : WitContext = { types: Map([]), interfaces: Map([]), }
      let imports = adapter.interface_environment(interface.id, context)
      let (copy, _) = adapter.copy_interface(interface.id, context)
      let location = wit_location(interface.location)
      let wrapper = adapter.add(
        None,
        World(None, [], imports, [
          { name: wit_identity(root, name), kind: Instance(copy), location, },
        ]),
        location,
      )
      definitions.push({ name, kind: Type(copy), location, })
      exports.push({ name, kind: Type(wrapper), location, })
    }
    for world in resolution.worlds_in_dependency_order() {
      if world.package_identity != root {
        continue
      }
      let copy = adapter.copy_world(world)
      let location = wit_location(world.location)
      let wrapper = adapter.add(
        None,
        World(None, [], [], [
          {
            name: wit_identity(root, world.name),
            kind: Component(copy),
            location,
          },
        ]),
        location,
      )
      definitions.push({ name: world.name, kind: Type(copy), location, })
      exports.push({ name: world.name, kind: Type(wrapper), location, })
    }
    let location = wit_location(resolution.root_location())
    let exports = ReadOnlyArray::from_array(exports)
    let world_type = adapter.add(None, World(None, [], [], exports), location)
    let instance_type = adapter.add(
      None,
      Interface(None, [], exports),
      location,
    )
    Ok({
      arena: ReadOnlyArray::from_array(adapter.arena),
      world_type,
      instance_type,
      defined_items: ReadOnlyArray::from_array(definitions),
    })
  } catch {
    Problem(problem) => Err([problem])
  }
}
