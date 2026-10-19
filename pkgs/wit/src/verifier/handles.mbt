///|
/// Called only after structural, name and cycle checks. A handle alias is not
/// a resource alias: only plain typedef/reference edges may reach a resource.
fn resource_roots(
  tree : @ast.Tree,
  references : Map[Int32, Int32],
  excluded : Map[Int32, Bool],
) -> ReadOnlyArray[Int32] {
  let roots = Array::make(tree.nodes.length(), -2)
  for seed in 0..<tree.nodes.length() {
    let path = []
    let mut id = seed
    let mut root = -1
    while true {
      if roots[id] != -2 {
        root = roots[id]
        break
      }
      path.push(id)
      // A foreign resource constraint is deferred while its selector is gated.
      // Selection removes this identity, and rejects every active reference.
      if excluded.contains(id) {
        root = id
        break
      }
      match tree.nodes[id].data {
        Resource(..) => {
          root = id
          break
        }
        Alias(ty~, ..) => id = ty
        NamedType(..) | Rename(..) =>
          match references.get(id) {
            Some(target) => id = target
            None => break
          }
        _ => break
      }
    }
    for id in path {
      roots[id] = root
    }
  }
  ReadOnlyArray::from_array(roots)
}

///|
fn verify_handle_targets(
  prepared : Prepared,
  resources : ReadOnlyArray[Int32],
  errors : Array[Diagnostic],
) -> Unit {
  let tree = prepared.tree
  for id, node in tree.nodes {
    match node.data {
      OwnType(resource~) | BorrowType(resource~) =>
        if resources[resource] < 0 {
          errors.push(
            prepared_error(
              prepared, id, "WIT-S007", "a handle target must resolve to a resource",
            ),
          )
        }
      _ => ()
    }
  }
}

///|
fn verify_handles(
  prepared : Prepared,
  references : Map[Int32, Int32],
  active_functions : ReadOnlyArray[Bool],
  errors : Array[Diagnostic],
) -> Unit {
  let tree = prepared.tree
  // Cache the first borrowed handle reachable from every type. This also
  // bounds the cost of shared DAGs and long chains reused by many functions.
  let borrowed = Array::make(tree.nodes.length(), -2)
  for seed in 0..<tree.nodes.length() {
    let pending = [(seed, false)]
    while pending.pop() is Some((id, leaving)) {
      if borrowed[id] != -2 {
        continue
      }
      match tree.nodes[id].data {
        BorrowType(..) => {
          borrowed[id] = id
          continue
        }
        OwnType(..) | Resource(..) => {
          borrowed[id] = -1
          continue
        }
        _ => ()
      }
      let children = type_edges(tree.nodes[id].data)
      if leaving {
        let mut witness = -1
        if references.get(id) is Some(target) {
          witness = borrowed[target]
        }
        for child in children {
          if borrowed[child] >= 0 && witness < 0 {
            witness = borrowed[child]
          }
        }
        borrowed[id] = witness
      } else {
        pending.push((id, true))
        for i = children.length() - 1; i >= 0; i = i - 1 {
          pending.push((children[i], false))
        }
        if references.get(id) is Some(target) {
          pending.push((target, false))
        }
      }
    }
  }
  for id, node in tree.nodes {
    let result = match node.data {
      Signature(result~, ..) | Constructor(result~, ..) => result
      _ => None
    }
    if active_functions[id] && result is Some(result) && borrowed[result] >= 0 {
      let d = prepared_error(
        prepared, id, "WIT-S007", "a function result cannot contain a borrowed handle",
      )
      errors.push({
        ..d,
        related: [
          {
            location: prepared.origins[borrowed[result]].location,
            message: "borrowed handle occurs here",
          },
        ],
      })
    }
  }
}
