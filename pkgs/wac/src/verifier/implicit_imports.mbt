///|
priv struct ImplicitImport {
  node : Int32
  value : Int32
  name : String
  kind : ItemKind
}

///|
priv struct InstantiationCheck {
  node : Int32
  imports : ReadOnlyArray[Extern]
  arguments : ReadOnlyArray[InstantiationArgument]
  resources : ReadOnlyArray[ResourceBinding]
}

///|
// Aggregate only after ordered declarations are checked, so later explicit
// imports participate in exact-name conflict detection as well.
fn Check::finalize_implicit_imports(self : Check) -> Unit raise SemanticFailure {
  if self.implicit_imports.is_empty() {
    return
  }
  let requests = self.implicit_imports.copy()
  let provisional : Map[Int32, Bool] = Map([])
  for request in requests {
    provisional[request.value] = true
    if self.scopes[0].import_nodes.get(request.name) is Some(explicit) {
      raise Problem(
        self.problem(
          request.node,
          "WAC-C008",
          "implicit import `" +
          request.name +
          "` conflicts with an explicit import",
          first=Some(explicit),
        ),
      )
    }
  }
  for item in self.composition_nodes {
    if item.operation is Import(name) && !provisional.contains(item.id) {
      requests.push({
        node: self.scopes[0].import_nodes.get(name).unwrap_or(requests[0].node),
        value: item.id,
        name,
        kind: item.kind,
      })
    }
  }
  let state = ImportTypes::new()
  let requests = self.import_owner_requests(state, requests)
  for request in requests {
    self.copy_import_type(state, request.node, binary_kind_id(request.kind))
    |> ignore
  }
  let groups : Array[ImportGroup] = []
  let order : Array[Int32] = []
  for request in requests {
    let kind = binary_kind_with_id(
      request.kind,
      state.copies[binary_kind_id(request.kind)],
    )
    let mut existing : Int32? = None
    for index in order {
      self.import_step(state, request.node)
      if compatible_external_version(groups[index].name, request.name) {
        existing = Some(index)
        break
      }
    }
    if existing is Some(index) {
      let group = groups[index]
      self.merge_import_type(state, request.node, group.kind, kind)
      group.requests.push(request)
      if group.name != request.name &&
        import_version_compare(request.name, group.name) > 0 {
        group.name = request.name
        let before = order.copy()
        order.clear()
        for old in before {
          if old != index {
            order.push(old)
          }
        }
        order.push(index)
      }
    } else {
      order.push(groups.length())
      groups.push({
        name: request.name,
        kind,
        requests: [request],
        resources: [],
      })
    }
  }
  self.finish_import_types(state, requests[0].node)
  let parents = Array::makei(self.next_resource_identity, i => i)
  self.merge_import_contexts(state, groups, parents)
  self.bind_import_resource_types(state, groups)
  self.finish_import_graph(state, groups, order, parents)
}

///|
priv struct ImportGroup {
  mut name : String
  mut kind : ItemKind
  requests : Array[ImplicitImport]
  mut resources : ReadOnlyArray[ResourceBinding]
}

///|
fn import_identity(parents : Array[Int32], initial : Int32) -> Int32 {
  let mut current = initial
  while parents[current] != current {
    current = parents[current]
  }
  let mut previous = initial
  while parents[previous] != previous {
    let next = parents[previous]
    parents[previous] = current
    previous = next
  }
  current
}

///|
fn import_decimal_compare(a : String, b : String) -> Int32 {
  if a.length() != b.length() {
    return a.length().compare(b.length())
  }
  a.compare(b)
}

///|
// Compatible tracks exclude prereleases and 0.0.x, so only the numeric core
// and semver crate's ordered build metadata participate in name promotion.
fn import_version_compare(a : String, b : String) -> Int32 {
  let av = a.split("@").to_array()[1].split("+").to_array()
  let bv = b.split("@").to_array()[1].split("+").to_array()
  let ac = av[0].split(".").to_array()
  let bc = bv[0].split(".").to_array()
  for i in 0..<3 {
    let compared = import_decimal_compare(ac[i].to_owned(), bc[i].to_owned())
    if compared != 0 {
      return compared
    }
  }
  if av.length() != bv.length() {
    return av.length().compare(bv.length())
  }
  if av.length() == 1 {
    return 0
  }
  let ab = av[1].split(".").to_array()
  let bb = bv[1].split(".").to_array()
  for i in 0..<ab.length() {
    if i >= bb.length() {
      return 1
    }
    let a = ab[i].to_owned()
    let b = bb[i].to_owned()
    let an = a.iter().all(c => c >= '0' && c <= '9')
    let bn = b.iter().all(c => c >= '0' && c <= '9')
    if an != bn {
      return if an { -1 } else { 1 }
    }
    let compared = if an {
      let mut ai = 0
      let mut bi = 0
      while ai < a.length() && a.code_unit_at(ai).to_int() == 48 {
        ai += 1
      }
      while bi < b.length() && b.code_unit_at(bi).to_int() == 48 {
        bi += 1
      }
      let compared = import_decimal_compare(
        a[ai:].to_owned(),
        b[bi:].to_owned(),
      )
      if compared == 0 {
        a.length().compare(b.length())
      } else {
        compared
      }
    } else {
      a.compare(b)
    }
    if compared != 0 {
      return compared
    }
  }
  ab.length().compare(bb.length())
}

///|
fn Check::import_resource_id(
  self : Check,
  state : ImportTypes,
  node : Int32,
  original : Int32,
) -> Int32 raise SemanticFailure {
  guard state.copies.get(original) is Some(copy) else {
    raise Problem(
      self.problem(
        node, "WAC-C009", "implicit resource is outside the imported type graph",
      ),
    )
  }
  let id = self.import_type_id(state, node, copy)
  guard self.resource_root(id) is Some(resource) else {
    raise Problem(
      self.problem(
        node, "WAC-C009", "implicit resource no longer refers to a resource",
      ),
    )
  }
  resource
}

///|
fn Check::merge_import_contexts(
  self : Check,
  state : ImportTypes,
  groups : Array[ImportGroup],
  parents : Array[Int32],
) -> Unit raise SemanticFailure {
  // First unify declared binders, across all groups. A later resource import
  // can justify identities used by an earlier imported function.
  for group in groups {
    let declarations : Map[Int32, Int32] = Map([])
    for request in group.requests {
      let (parameters, owned) = self.resource_parameters(
        request.node,
        request.kind,
        budget=Some(state.budget),
      )
      for ty in parameters {
        if !owned.contains(ty) {
          continue
        }
        let target = self.import_resource_id(state, request.node, ty)
        guard resource_binding(
            self.composition_nodes[request.value].resources,
            ty,
          )
          is Some(identity) else {
          raise Problem(
            self.problem(
              request.node,
              "WAC-C009",
              "implicit resource declaration has no runtime identity",
            ),
          )
        }
        if declarations.get(target) is Some(previous) {
          let a = import_identity(parents, previous)
          let b = import_identity(parents, identity)
          if a != b {
            parents[b] = a
          }
        } else {
          declarations[target] = identity
        }
      }
    }
  }
  let owner_bindings : Map[(String, Int32), Int32] = Map([])
  for group in groups {
    for request in group.requests {
      let (parameters, owned) = self.resource_parameters(
        request.node,
        request.kind,
        budget=Some(state.budget),
      )
      for ty in parameters {
        if owned.contains(ty) &&
          resource_binding(self.composition_nodes[request.value].resources, ty)
          is Some(identity) {
          let target = self.import_resource_id(state, request.node, ty)
          owner_bindings[(group.name, target)] = import_identity(
            parents, identity,
          )
        }
      }
    }
  }
  let available : Map[Int32, Int32] = Map([])
  let ambiguous : Map[Int32, Bool] = Map([])
  let missing : Array[(Int32, Int32)] = []
  for index, group in groups {
    let context : Map[Int32, Int32] = Map([])
    for request in group.requests {
      let (parameters, _) = self.resource_parameters(
        request.node,
        request.kind,
        budget=Some(state.budget),
      )
      for ty in parameters {
        self.import_step(state, request.node)
        let target = self.import_resource_id(state, request.node, ty)
        guard resource_binding(
            self.composition_nodes[request.value].resources,
            ty,
          )
          is Some(identity) else {
          raise Problem(
            self.problem(
              request.node,
              "WAC-C009",
              "implicit resource capture has no runtime identity",
            ),
          )
        }
        let mut identity = import_identity(parents, identity)
        if state.owners.get((request.value, ty)) is Some(owner) {
          for candidate in groups {
            self.import_step(state, request.node)
            if compatible_external_version(candidate.name, owner) &&
              owner_bindings.get((candidate.name, target)) is Some(bound) {
              identity = bound
              break
            }
          }
        }
        if context.get(target) is Some(previous) && previous != identity {
          raise Problem(
            self.problem(
              request.node,
              "WAC-C005",
              "shared implicit import captures distinct resource identities",
            ),
          )
        }
        context[target] = identity
      }
    }
    let node = group.requests[0].node
    let kind = binary_kind_with_id(
      group.kind,
      self.import_type_id(state, node, binary_kind_id(group.kind)),
    )
    let (parameters, owned) = self.resource_parameters(
      node,
      kind,
      budget=Some(state.budget),
    )
    for ty in parameters {
      if context.contains(ty) {
        continue
      }
      if owned.contains(ty) {
        let identity = self.new_resource_identity()
        parents.push(identity)
        context[ty] = identity
      } else {
        missing.push((index, ty))
      }
    }
    let keys = context.keys().to_array()
    keys.sort()
    group.resources = ReadOnlyArray::from_array(
      keys.map(ty => ResourceBinding::{ ty, identity: context[ty], }),
    )
    for ty in keys {
      if available.get(ty) is Some(previous) && previous != context[ty] {
        ambiguous[ty] = true
      } else {
        available[ty] = context[ty]
      }
    }
  }
  for (index, ty) in missing {
    let group = groups[index]
    guard !ambiguous.contains(ty) && available.get(ty) is Some(identity) else {
      raise Problem(
        self.problem(
          group.requests[0].node,
          "WAC-C005",
          "implicit import captures an unbound or ambiguous resource",
        ),
      )
    }
    let context = group.resources.iter().to_array()
    context.push({ ty, identity, })
    context.sort_by((a, b) => a.ty.compare(b.ty))
    group.resources = ReadOnlyArray::from_array(context)
  }
}

///|
// Runtime sharing must also appear in the published static aggregate graph.
// Captured handles point at the imported declaration that owns their identity.
fn Check::bind_import_resource_types(
  self : Check,
  state : ImportTypes,
  groups : Array[ImportGroup],
) -> Unit raise SemanticFailure {
  let declarations : Map[Int32, Int32] = Map([])
  for group in groups {
    let node = group.requests[0].node
    let kind = binary_kind_with_id(
      group.kind,
      self.import_type_id(state, node, binary_kind_id(group.kind)),
    )
    let (_, owned) = self.resource_parameters(
      node,
      kind,
      budget=Some(state.budget),
    )
    for binding in group.resources {
      if owned.contains(binding.ty) && !declarations.contains(binding.identity) {
        declarations[binding.identity] = binding.ty
      }
    }
  }
  for group in groups {
    let node = group.requests[0].node
    let mapping : Map[Int32, Int32] = Map([])
    for binding in group.resources {
      guard declarations.get(binding.identity) is Some(target) else {
        raise Problem(
          self.problem(
            node, "WAC-C009", "implicit resource has no imported declaration",
          ),
        )
      }
      let source = self.import_type_id(state, node, binding.ty)
      let target = self.import_type_id(state, node, target)
      mapping[source] = target
    }
    let root = self.import_type_id(state, node, binary_kind_id(group.kind))
    let seen : Map[Int32, Bool] = Map([])
    let pending = [(root, false)]
    while pending.pop() is Some((id, finish)) {
      self.import_step(state, node)
      if mapping.contains(id) {
        continue
      }
      let children = binary_children(self.types[id].kind)
      let uses = match self.types[id].kind {
        Interface(_, uses, _) | World(_, uses, _, _) => uses
        _ => []
      }
      for used in uses {
        children.push(used.interface)
        children.push(used.ty)
      }
      if !finish {
        if seen.contains(id) {
          continue
        }
        seen[id] = true
        pending.push((id, true))
        for i = children.length() - 1; i >= 0; i = i - 1 {
          pending.push((children[i], false))
        }
        continue
      }
      let mut changed = false
      for child in children {
        self.import_step(state, node)
        if mapping.get(child).unwrap_or(child) != child {
          changed = true
        }
      }
      if changed {
        let copy = self.types.length()
        self.types.push({
          ..self.types[id],
          id: copy,
          kind: binary_remap(self.types[id].kind, mapping),
        })
        self.borrowed.push(self.borrowed[id])
        mapping[id] = copy
      } else {
        mapping[id] = id
      }
    }
    group.kind = binary_kind_with_id(
      group.kind,
      mapping.get(root).unwrap_or(root),
    )
    let by_type : Map[Int32, Int32] = Map([])
    for binding in group.resources {
      let original = self.import_type_id(state, node, binding.ty)
      let ty = mapping.get(original).unwrap_or(original)
      if by_type.get(ty) is Some(previous) && previous != binding.identity {
        raise Problem(
          self.problem(
            node, "WAC-C005", "implicit aggregate conflates distinct resources",
          ),
        )
      }
      by_type[ty] = binding.identity
    }
    let keys = by_type.keys().to_array()
    keys.sort()
    group.resources = ReadOnlyArray::from_array(
      keys.map(ty => ResourceBinding::{ ty, identity: by_type[ty], }),
    )
  }
}
