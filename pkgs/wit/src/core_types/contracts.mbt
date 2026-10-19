///|
/// A module contract or a link to an enclosing decoder's flat scope table.
/// Other bindings carry no core contract. These values are metadata, not proof
/// that caller-constructed component declarations have been validated.
pub(all) enum ContractBinding {
  Scope(Int32)
  Module(Module)
  Other
} derive(Eq, Debug)

///|
/// Immutable core contracts associated with one component or instance scope.
/// Binding sort codes follow the component binary format; core sorts add 0x100.
pub struct ContractScope {
  priv definitions : ReadOnlyArray[Definition]
  priv bindings : Map[Int32, ReadOnlyArray[ContractBinding]]
  priv exports : Map[String, ContractBinding]
}

///|
pub fn ContractScope::new(
  definitions : ReadOnlyArray[Definition],
  bindings : ReadOnlyArray[(Int32, ReadOnlyArray[ContractBinding])],
  exports : ReadOnlyArray[(String, ContractBinding)],
) -> ContractScope {
  let binding_map = Map([])
  for (sort, values) in bindings {
    binding_map[sort] = values
  }
  let export_map = Map([])
  for (name, value) in exports {
    export_map[name] = value
  }
  { definitions, bindings: binding_map, exports: export_map, }
}

///|
pub fn ContractScope::definition(
  self : ContractScope,
  index : Int32,
) -> Definition? {
  self.definitions.get(index)
}

///|
pub fn ContractScope::binding(
  self : ContractScope,
  sort : Int32,
  index : Int32,
) -> ContractBinding? {
  match self.bindings.get(sort) {
    Some(values) => values.get(index)
    None => None
  }
}

///|
pub fn ContractScope::exported(
  self : ContractScope,
  name : String,
) -> ContractBinding? {
  self.exports.get(name)
}

///|
/// Flat scope table produced by an ordered component metadata pass. Scope zero
/// is the root; Scope bindings refer to indices in this table. The table never
/// traverses or follows caller-provided links implicitly.
pub struct ContractGraph {
  priv scopes : ReadOnlyArray[ContractScope]
}

///|
pub fn ContractGraph::new(
  scopes : ReadOnlyArray[ContractScope],
) -> ContractGraph {
  { scopes, }
}

///|
pub fn ContractGraph::scope(
  self : ContractGraph,
  index : Int32,
) -> ContractScope? {
  self.scopes.get(index)
}

///|
pub fn ContractGraph::length(self : ContractGraph) -> Int32 {
  self.scopes.length()
}

///|
pub extend ContractBinding with Eq::{equal, not_equal}

///|
pub extend ContractBinding with @debug.Debug::{to_repr}
