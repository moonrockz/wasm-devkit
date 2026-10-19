///|
// Resource aliases retain their named owner through the enclosing use entry.
// Aggregation imports that owner before the item containing the alias.
fn Check::import_owner_requests(
  self : Check,
  state : ImportTypes,
  requests : Array[ImplicitImport],
) -> Array[ImplicitImport] raise SemanticFailure {
  let known : Map[String, ImplicitImport] = Map([])
  for request in self.implicit_imports {
    if !known.contains(request.name) {
      known[request.name] = request
    }
  }
  let result : Array[ImplicitImport] = []
  let emitted : Map[Int32, Bool] = Map([])
  let pending : Array[(ImplicitImport, Bool)] = []
  for i = requests.length() - 1; i >= 0; i = i - 1 {
    pending.push((requests[i], false))
  }
  while pending.pop() is Some((request, finish)) {
    self.import_step(state, request.node)
    if finish {
      result.push(request)
      continue
    }
    if emitted.contains(request.value) {
      continue
    }
    emitted[request.value] = true
    pending.push((request, true))
    let owners : Array[ImplicitImport] = []
    let work = [binary_kind_id(request.kind)]
    let seen : Map[Int32, Bool] = Map([])
    while work.pop() is Some(id) {
      self.import_step(state, request.node)
      if seen.contains(id) {
        continue
      }
      seen[id] = true
      let uses = match self.types[id].kind {
        Interface(_, uses, _) | World(_, uses, _, _) => uses
        _ => []
      }
      for used in uses {
        self.import_step(state, request.node)
        if self.resource_root(used.ty) is Some(resource) {
          guard self.types[used.interface].kind is Interface(Some(name), _, _) else {
            raise Problem(
              self.problem(
                request.node,
                "WAC-C009",
                "implicit resource alias has no named owner",
              ),
            )
          }
          state.owners[(request.value, resource)] = name
          let owner = match known.get(name) {
            Some(owner) => owner
            None => {
              let kind = Instance(used.interface)
              let resources = self.import_resource_context(request.node, kind)
              let value = self.composition_node(
                request.node,
                Import(name),
                kind,
                resources=Some(resources),
              )
              let owner = ImplicitImport::{
                node: request.node,
                value,
                name,
                kind,
              }
              known[name] = owner
              owner
            }
          }
          owners.push(owner)
        }
      }
      let children = binary_children(self.types[id].kind)
      for i = children.length() - 1; i >= 0; i = i - 1 {
        work.push(children[i])
      }
    }
    for i = owners.length() - 1; i >= 0; i = i - 1 {
      pending.push((owners[i], false))
    }
  }
  result
}
