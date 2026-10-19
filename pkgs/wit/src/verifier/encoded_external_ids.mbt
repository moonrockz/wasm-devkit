///|
// Merge keys use declaration identity, never private lowering node positions.
fn encoded_external_id_members(
  prepared : Prepared,
) -> Array[((String, String, String), Int32, Int32)] {
  let members = []
  let tree = prepared.tree
  for root in prepared.roots {
    let package_key = identity_key(
      prepared.identities[prepared.node_packages[root]],
    )
    for owner in section_items(tree.nodes[root].data) {
      guard tree.nodes[owner].data is Interface(name=interface_name, items~, ..) else {
        continue
      }
      for id in items {
        let data = tree.nodes[id].data
        if type_declaration(data) && declaration(data) is Some(name) {
          members.push(
            ((package_key, interface_name, "type:" + name), id, owner),
          )
        }
        if data is Use(names~, ..) {
          for selector in names {
            if tree.nodes[selector].data is Rename(name~, renamed~) {
              members.push(
                (
                  (
                    package_key,
                    interface_name,
                    "type:" + renamed.unwrap_or(name),
                  ),
                  selector,
                  owner,
                ),
              )
            }
          }
        }
        if data is Function(name~, signature~, ..) {
          members.push(
            (
              (
                package_key,
                interface_name,
                "function:" + signature_name(tree, signature, name),
              ),
              id,
              owner,
            ),
          )
        }
        if data is Resource(methods~, ..) {
          for method_id in methods {
            if resource_function_name(tree, id, method_id) is Some(name) {
              members.push(
                (
                  (package_key, interface_name, "function:" + name),
                  method_id,
                  owner,
                ),
              )
            }
          }
        }
      }
    }
  }
  members
}

///|
// Resolve::merge retains the first input's external ID, including None. Source
// declarations still supply the merged type definition and original provenance.
fn encoded_merge_external_ids(
  prepared : Prepared,
  selected : Map[(String, Int32), Bool],
  input_ranks : Map[String, Int32],
  output : Map[(String, String, String), String?],
  budget : EncodedMergeBudget,
) -> Unit raise EncodedFailure {
  encoded_merge_charge(budget, prepared.tree.nodes.length())
  let errors = []
  let values = parse_external_ids(prepared, errors)
  guard errors.is_empty() else {
    raise Invalid("invalid external ID in merge input")
  }
  let ranks : Map[(String, String, String), Int32] = Map([])
  let retained = fn(id : Int32) {
    let origin = prepared.origins[id]
    match origin.node {
      Some(node) => selected.get((origin.location.source, node)) != Some(false)
      None => true
    }
  }
  for (key, id, owner) in encoded_external_id_members(prepared) {
    encoded_merge_charge(budget, 1)
    if !retained(owner) || !retained(id) {
      continue
    }
    let rank = input_ranks[prepared.origins[id].location.source]
    if ranks.get(key) is Some(previous) && previous <= rank {
      continue
    }
    ranks[key] = rank
    output[key] = values[id]
  }
}
