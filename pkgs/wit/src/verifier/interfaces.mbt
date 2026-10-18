///|
pub(all) struct ResolvedFunction {
  id : Int32
  name : String
  params : ReadOnlyArray[TypeMember]
  result : Int32?
  asynchronous : Bool
  location : Location
} derive(Eq, Debug)

///|
pub(all) struct ResolvedInterface {
  id : Int32
  name : String?
  package_identity : PackageIdentity
  types : ReadOnlyArray[TypeMember]
  functions : ReadOnlyArray[ResolvedFunction]
  location : Location
} derive(Eq, Debug)

///|
pub fn Verified::worlds(self : Verified) -> ReadOnlyArray[ResolvedWorld] {
  self.resolved_worlds
}

///|
pub fn Verified::interfaces(
  self : Verified,
) -> ReadOnlyArray[ResolvedInterface] {
  self.resolved_interfaces
}

///|
pub fn Verified::functions(self : Verified) -> ReadOnlyArray[ResolvedFunction] {
  self.resolved_functions
}

///|
pub fn Resolution::interfaces(
  self : Resolution,
) -> ReadOnlyArray[ResolvedInterface] {
  self.model.interfaces()
}

///|
pub fn Resolution::functions(
  self : Resolution,
) -> ReadOnlyArray[ResolvedFunction] {
  self.model.functions()
}

///|
fn model_functions(prepared : Prepared) -> ReadOnlyArray[ResolvedFunction] {
  let result : Array[ResolvedFunction] = []
  for id, node in prepared.tree.nodes {
    let signature = match node.data {
      Function(name~, signature~, ..) => Some((name, signature))
      Import(name=Some(name), target~, ..)
      | Export(name=Some(name), target~, ..) => Some((name, target))
      _ => None
    }
    if signature is Some((name, signature)) &&
      prepared.tree.nodes[signature].data
      is Signature(result=output, asynchronous~, ..) {
      let members : Array[TypeMember] = []
      if prepared.tree.nodes[signature].data is Signature(params=parameters, ..) {
        for parameter in parameters {
          if prepared.tree.nodes[parameter].data is Parameter(name~, ty~) {
            members.push({
              name,
              ty,
              location: prepared.origins[parameter].location,
            })
          }
        }
      }
      result.push({
        id: signature,
        name,
        params: ReadOnlyArray::from_array(members),
        result: output,
        asynchronous,
        location: prepared.origins[id].location,
      })
    }
  }
  ReadOnlyArray::from_array(result)
}

///|
fn model_interfaces(
  prepared : Prepared,
  functions : ReadOnlyArray[ResolvedFunction],
) -> ReadOnlyArray[ResolvedInterface] {
  let by_id : Map[Int32, ResolvedFunction] = Map([])
  for function in functions {
    by_id[function.id] = function
  }
  let result = []
  for id, node in prepared.tree.nodes {
    if node.data is Interface(name~, items~, ..) {
      let types : Array[TypeMember] = []
      let signatures : Array[ResolvedFunction] = []
      for item in items {
        let node = prepared.tree.nodes[item]
        if type_declaration(node.data) && declaration(node.data) is Some(name) {
          types.push({
            name,
            ty: item,
            location: prepared.origins[item].location,
          })
        }
        if node.data is Use(names~, ..) {
          for selector in names {
            if prepared.tree.nodes[selector].data is Rename(name~, renamed~) {
              types.push({
                name: renamed.unwrap_or(name),
                ty: selector,
                location: prepared.origins[selector].location,
              })
            }
          }
        }
        if node.data is Function(signature~, ..) &&
          by_id.get(signature) is Some(function) {
          signatures.push(function)
        }
      }
      result.push({
        id,
        name: if name.is_empty() {
          None
        } else {
          Some(name)
        },
        package_identity: prepared.identities[prepared.node_packages[id]],
        types: ReadOnlyArray::from_array(types),
        functions: ReadOnlyArray::from_array(signatures),
        location: prepared.origins[id].location,
      })
    }
  }
  ReadOnlyArray::from_array(result)
}

///|
pub extend ResolvedFunction with Eq::{equal, not_equal}

///|
pub extend ResolvedFunction with @debug.Debug::{to_repr}

///|
pub extend ResolvedInterface with Eq::{equal, not_equal}

///|
pub extend ResolvedInterface with @debug.Debug::{to_repr}
