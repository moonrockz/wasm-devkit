///|
// Generated names exist only in private compiler input. These descriptors bind
// expression nodes directly, without inventing source use declarations or world
// type imports that were absent from the encoded package.
priv struct EncodedReference {
  package_identity : PackageIdentity?
  interface_name : String
  type_name : String
}

///|
fn encoded_reference_nodes(
  prepared : Prepared,
  inputs : Map[String, Map[Int32, EncodedReference]],
) -> Map[Int32, EncodedReference] {
  let references : Map[Int32, EncodedReference] = Map([])
  for id, origin in prepared.origins {
    if origin.node is Some(original) &&
      inputs.get(origin.location.source) is Some(input) &&
      input.get(original) is Some(reference) {
      references[id] = reference
    }
  }
  references
}

///|
fn encoded_reference_target(
  prepared : Prepared,
  scopes : Array[Map[String, Int32]],
  owner_scopes : Map[Int32, Int32],
  id : Int32,
  reference : EncodedReference,
) -> Result[(Int32, Int32), Diagnostic] {
  let package_index = match reference.package_identity {
    None => Some(prepared.node_packages[id])
    Some(identity) => prepared.by_identity.get(identity_key(identity))
  }
  if package_index is Some(package_index) &&
    scopes[package_index].get(reference.interface_name) is Some(interface_id) &&
    prepared.tree.nodes[interface_id].data is Interface(..) &&
    owner_scopes.get(interface_id) is Some(scope) &&
    scopes[scope].get(reference.type_name) is Some(target) &&
    (
      type_declaration(prepared.tree.nodes[target].data) ||
      prepared.tree.nodes[target].data is Rename(..)
    ) {
    Ok((interface_id, target))
  } else {
    Err(
      prepared_error(
        prepared,
        id,
        "WIT-S005",
        "unresolved encoded type `" +
        reference.interface_name +
        "." +
        reference.type_name +
        "`",
      ),
    )
  }
}
