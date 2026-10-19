///|
fn encoded_overlapping_packages(
  prepared : Prepared,
  binaries : Map[String, Bool],
) -> Bool {
  let seen : Map[Int32, Bool] = Map([])
  for root in prepared.roots {
    let owner = prepared.node_packages[root]
    let partial = binaries.contains(prepared.origins[root].location.source) &&
      prepared.tree.nodes[root].data is Package(nested=true, ..)
    match seen.get(owner) {
      Some(previous) => if partial || previous { return true }
      None => seen[owner] = partial
    }
  }
  false
}

///|
// Selection maps use caller document/node identities, so compaction cannot
// change which independently validated declaration was selected.
fn encoded_selection_metadata(
  prepared : Prepared,
  metadata : Map[String, Map[Int32, Stability]],
) -> Map[Int32, Stability] {
  let values : Map[Int32, Stability] = Map([])
  for id, origin in prepared.origins {
    if origin.node is Some(original) &&
      metadata.get(origin.location.source) is Some(input) &&
      input.get(original) is Some(value) {
      values[id] = value
    }
  }
  values
}

///|
fn encoded_selected_prepared(
  prepared : Prepared,
  selected : Map[(String, Int32), Bool],
  binaries : Map[String, Bool],
) -> Result[Prepared, ReadOnlyArray[Diagnostic]] {
  let nodes = prepared.tree.nodes.iter().to_array()
  let origins = prepared.origins.iter().to_array()
  let roots = prepared.roots.iter().to_array()
  let packages = prepared.node_packages.iter().to_array()
  let keep = fn(id : Int32) {
    let origin = origins[id]
    match origin.node {
      Some(original) =>
        selected.get((origin.location.source, original)) != Some(false)
      None => true
    }
  }
  for id, node in nodes {
    let data = match node.data {
      File(items~) => @ast.Data::File(items=items.filter(keep))
      Package(attributes~, path~, nested~, items~) =>
        Package(attributes~, path~, nested~, items=items.filter(keep))
      Interface(attributes~, name~, items~) =>
        Interface(attributes~, name~, items=items.filter(keep))
      World(attributes~, name~, items~) =>
        World(attributes~, name~, items=items.filter(keep))
      Resource(attributes~, name~, methods~, has_body~) =>
        Resource(attributes~, name~, methods=methods.filter(keep), has_body~)
      Use(attributes~, path~, names~, renamed~) =>
        Use(attributes~, path~, names=names.filter(keep), renamed~)
      data => data
    }
    nodes[id] = { ..node, data, }
  }
  let owners : Map[Int32, Int32] = Map([])
  let partial : Map[Int32, Bool] = Map([])
  for root in roots {
    owners[root] = packages[root]
    if binaries.contains(origins[root].location.source) &&
      nodes[root].data is Package(nested=true, ..) {
      partial[root] = true
    }
  }
  let errors : Array[Diagnostic] = []
  encoded_merge_sections(nodes, origins, roots, owners, partial, errors) catch {
    Unsupported(message) | Invalid(message) =>
      errors.push(error_at(origins[roots[0]].location, "WIT-B002", message))
  }
  if !errors.is_empty() {
    return Err(ordered_diagnostics(errors))
  }
  encoded_compact_closure(nodes, origins, roots, packages)
  Ok({
    ..prepared,
    tree: { nodes: ReadOnlyArray::from_array(nodes), },
    origins: ReadOnlyArray::from_array(origins),
    roots: ReadOnlyArray::from_array(roots),
    node_packages: ReadOnlyArray::from_array(packages),
  })
}

///|
// Source validation sees authoritative packages before inferred additions.
// Only packages reachable from source inputs participate; an unrelated binary
// is validated independently with its own inferred dependency definitions.
fn encoded_source_view(
  prepared : Prepared,
  binaries : Map[String, Bool],
  references : Map[Int32, EncodedReference],
  budget : EncodedMergeBudget,
) -> Prepared raise EncodedFailure {
  let authoritative : Map[Int32, Bool] = Map([])
  let needed : Map[Int32, Bool] = Map([])
  let work : Array[Int32] = []
  for root in prepared.roots {
    encoded_merge_charge(budget, 1)
    let binary = binaries.contains(prepared.origins[root].location.source)
    let owner = prepared.node_packages[root]
    if !binary {
      authoritative[owner] = true
    }
    if !binary && !needed.contains(owner) {
      needed[owner] = true
      work.push(owner)
    }
  }
  let roots_by_package : Map[Int32, Array[Int32]] = Map([])
  let retained : Map[Int32, Bool] = Map([])
  for root in prepared.roots {
    encoded_merge_charge(budget, 1)
    let owner = prepared.node_packages[root]
    if authoritative.contains(owner) &&
      binaries.contains(prepared.origins[root].location.source) &&
      prepared.tree.nodes[root].data is Package(nested=true, ..) {
      continue
    }
    let group = match roots_by_package.get(owner) {
      Some(group) => group
      None => {
        let group : Array[Int32] = []
        roots_by_package[owner] = group
        group
      }
    }
    group.push(root)
    retained[root] = true
  }
  while work.pop() is Some(owner) {
    if roots_by_package.get(owner) is Some(group) {
      let pending = group.copy()
      while pending.pop() is Some(id) {
        encoded_merge_charge(budget, 1)
        let data = prepared.tree.nodes[id].data
        let dependency = if references.get(id) is Some(reference) &&
          reference.package_identity is Some(identity) {
          prepared.by_identity.get(identity_key(identity))
        } else if data is Path(..) {
          prepared.foreign_package(id)
        } else {
          None
        }
        if dependency is Some(dependency) && !needed.contains(dependency) {
          needed[dependency] = true
          work.push(dependency)
        }
        for child in data.children() {
          // Each nested package has its own package root and dependency edges.
          if !(prepared.tree.nodes[child].data is Package(nested=true, ..)) {
            pending.push(child)
          }
        }
      }
    }
  }
  let roots : Array[Int32] = []
  for root in prepared.roots {
    let owner = prepared.node_packages[root]
    if needed.contains(owner) && retained.contains(root) {
      roots.push(root)
    }
  }
  let nodes = prepared.tree.nodes.iter().to_array()
  for root in roots {
    if nodes[root].data is File(items~) {
      nodes[root] = {
        ..nodes[root],
        data: File(
          items=items.filter(id => !(nodes[id].data is Package(nested=true, ..))),
        ),
      }
    }
  }
  let origins = prepared.origins.iter().to_array()
  let packages = prepared.node_packages.iter().to_array()
  encoded_compact_closure(nodes, origins, roots, packages)
  let by_identity : Map[String, Int32] = Map([])
  for key, owner in prepared.by_identity {
    if needed.contains(owner) {
      by_identity[key] = owner
    }
  }
  {
    ..prepared,
    tree: { nodes: ReadOnlyArray::from_array(nodes), },
    roots: ReadOnlyArray::from_array(roots),
    origins: ReadOnlyArray::from_array(origins),
    node_packages: ReadOnlyArray::from_array(packages),
    by_identity,
  }
}

///|
fn encoded_select_closure(
  prepared : Prepared,
  inputs : Array[EncodedPackage],
  binaries : Map[String, Bool],
  features : SemanticFeatures,
  metadata : Map[String, Map[Int32, Stability]],
  references : Map[String, Map[Int32, EncodedReference]],
  input_ranks : Map[String, Int32],
  external_id_overrides : Map[(String, String, String), String?],
) -> Result[Prepared, ReadOnlyArray[Diagnostic]] {
  let selected : Map[(String, Int32), Bool] = Map([])
  let budget : EncodedMergeBudget = { remaining: 1000000, }
  try {
    encoded_merge_charge(budget, prepared.tree.nodes.length())
    for input in inputs {
      let own = match prepare(input.lowered, [], binary_sources=binaries) {
        Ok(own) => own
        Err(errors) => return Err(errors)
      }
      encoded_merge_charge(budget, own.tree.nodes.length())
      match
        verify_prepared(
          own,
          features,
          binary_sources=binaries,
          binary_metadata=encoded_selection_metadata(own, metadata),
          binary_references=encoded_reference_nodes(own, references),
          selection_output=selected,
        ) {
        Ok(_) => ()
        Err(errors) => return Err(errors)
      }
    }
    let view = encoded_source_view(
      prepared,
      binaries,
      encoded_reference_nodes(prepared, references),
      budget,
    )
    if !view.roots.is_empty() {
      let view = match encoded_selected_prepared(view, selected, binaries) {
        Ok(view) => view
        Err(errors) => return Err(errors)
      }
      encoded_merge_charge(budget, view.tree.nodes.length())
      let source_selected : Map[(String, Int32), Bool] = Map([])
      match
        verify_prepared(
          view,
          features,
          binary_sources=binaries,
          binary_metadata=encoded_selection_metadata(view, metadata),
          binary_references=encoded_reference_nodes(view, references),
          selection_output=source_selected,
        ) {
        Ok(_) => ()
        Err(errors) => return Err(errors)
      }
      for key, value in source_selected {
        if !binaries.contains(key.0) {
          selected[key] = value
        }
      }
    }
    encoded_merge_external_ids(
      prepared, selected, input_ranks, external_id_overrides, budget,
    )
    encoded_selected_prepared(prepared, selected, binaries)
  } catch {
    Unsupported(message) | Invalid(message) =>
      Err([
        error_at(
          prepared.origins[prepared.roots[0]].location,
          "WIT-B002",
          message,
        ),
      ])
  }
}
