///|
pub(all) enum FunctionKind {
  Freestanding
  Method(Int32)
  Static(Int32)
  Constructor(Int32)
} derive(Eq, Debug)

///|
pub(all) enum FunctionFlavor {
  Plain
  Getter
  Setter
} derive(Eq, Debug)

///|
pub(all) struct ResolvedFunction {
  id : Int32
  name : String
  kind : FunctionKind
  flavor : FunctionFlavor
  params : ReadOnlyArray[TypeMember]
  result : Int32?
  asynchronous : Bool
  location : Location
  stability : Stability
} derive(Eq, Debug)

///|
pub(all) struct ResolvedInterface {
  id : Int32
  name : String?
  package_identity : PackageIdentity
  types : ReadOnlyArray[TypeMember]
  functions : ReadOnlyArray[ResolvedFunction]
  location : Location
  stability : Stability
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
fn model_functions(
  prepared : Prepared,
  scopes : ReadOnlyArray[Int32],
  types : Array[ResolvedType],
  origins : Array[Origin],
  stabilities : ReadOnlyArray[StabilityInfo],
  type_stabilities : ReadOnlyArray[Stability],
) -> ReadOnlyArray[ResolvedFunction] {
  let result : Array[ResolvedFunction] = []
  let resource_members = resource_members(prepared.tree)
  let handle = fn(kind : TypeKind, at : Int32, stability : Stability) {
    let id = origins.length()
    origins.push(prepared.origins[at])
    types.push({
      id,
      scope: scopes[at],
      name: None,
      stability,
      kind,
      location: prepared.origins[at].location,
    })
    id
  }
  for id, node in prepared.tree.nodes {
    let signature = match node.data {
      Function(name~, signature~, ..) => Some((name, signature))
      Import(name=Some(name), target~, ..)
      | Export(name=Some(name), target~, ..) => Some((name, target))
      _ => None
    }
    if signature is Some((name, signature)) &&
      prepared.tree.nodes[signature].data
      is Signature(result=output, asynchronous~, flavor=syntax_flavor, ..) {
      let members : Array[TypeMember] = []
      let kind : FunctionKind = match resource_members.get(id) {
        Some(resource) =>
          if node.data is Function(is_static=true, ..) {
            Static(resource)
          } else {
            let ty = handle(
              Borrow(resource),
              signature,
              type_stabilities[signature],
            )
            members.push({
              name: "self",
              ty,
              location: prepared.origins[signature].location,
            })
            Method(resource)
          }
        None => Freestanding
      }
      let name = match resource_members.get(id) {
        Some(resource) =>
          resource_function_name(prepared.tree, resource, id).unwrap_or(name)
        None => signature_name(prepared.tree, signature, name)
      }
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
        stability: stabilities[signature].value,
        id: signature,
        name,
        kind,
        flavor: match syntax_flavor {
          Func => Plain
          Get => Getter
          Set => Setter
        },
        params: ReadOnlyArray::from_array(members),
        result: output,
        asynchronous,
        location: prepared.origins[id].location,
      })
    }
    if node.data is Constructor(params~, result=output, ..) &&
      resource_members.get(id) is Some(resource) {
      let parameters : Array[TypeMember] = []
      for parameter in params {
        if prepared.tree.nodes[parameter].data is Parameter(name~, ty~) {
          parameters.push({
            name,
            ty,
            location: prepared.origins[parameter].location,
          })
        }
      }
      result.push({
        id,
        name: resource_function_name(prepared.tree, resource, id).unwrap(),
        stability: stabilities[id].value,
        kind: Constructor(resource),
        flavor: Plain,
        params: ReadOnlyArray::from_array(parameters),
        result: match output {
          Some(id) => Some(id)
          None => Some(handle(Own(resource), id, Unknown))
        },
        asynchronous: false,
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
  stabilities : ReadOnlyArray[StabilityInfo],
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
        if node.data is Resource(methods~, ..) {
          for func_id in methods {
            let function_id = match prepared.tree.nodes[func_id].data {
              Function(signature~, ..) => signature
              _ => func_id
            }
            if by_id.get(function_id) is Some(function) {
              signatures.push(function)
            }
          }
        }
      }
      result.push({
        id,
        name: if name.is_empty() {
          None
        } else {
          Some(name)
        },
        stability: stabilities[id].value,
        package_identity: prepared.identities[prepared.node_packages[id]],
        types: ReadOnlyArray::from_array(types),
        functions: ordered_functions(ReadOnlyArray::from_array(signatures)),
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

///|
pub extend FunctionKind with Eq::{equal, not_equal}

///|
pub extend FunctionKind with @debug.Debug::{to_repr}

///|
pub extend FunctionFlavor with Eq::{equal, not_equal}

///|
pub extend FunctionFlavor with @debug.Debug::{to_repr}
