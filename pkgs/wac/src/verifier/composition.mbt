///|
/// Operations in a verified composition. Type identities refer to types();
/// alias sources refer to composition() and always precede their aliases.
pub(all) enum CompositionOperation {
  Definition
  Import(String)
  Access(Int32, String)
  Instantiate(String, String?, ReadOnlyArray[InstantiationArgument])
} derive(Eq, Debug)

///|
pub(all) struct CompositionNode {
  id : Int32
  operation : CompositionOperation
  kind : ItemKind
  resources : ReadOnlyArray[ResourceBinding]
  location : Location
} derive(Eq, Debug)

///|
pub(all) struct CompositionExport {
  name : String
  value : Int32
  location : Location
} derive(Eq, Debug)

///|
pub fn Verified::composition(self : Verified) -> ReadOnlyArray[CompositionNode] {
  self.composition_nodes
}

///|
pub fn Verified::composition_exports(
  self : Verified,
) -> ReadOnlyArray[CompositionExport] {
  self.composition_outputs
}

///|
fn Check::composition_node(
  self : Check,
  node : Int32,
  operation : CompositionOperation,
  kind : ItemKind,
  resources~ : ReadOnlyArray[ResourceBinding]? = None,
) -> Int32 raise SemanticFailure {
  let id = self.composition_nodes.length()
  let resources : ReadOnlyArray[ResourceBinding] = match resources {
    Some(resources) => resources
    None =>
      match operation {
        Definition => []
        Import(_) => self.import_resource_context(node, kind)
        Access(instance, _) => self.composition_nodes[instance].resources
        Instantiate(_, _, _) =>
          raise Problem(
            self.problem(
              node, "WAC-S001", "missing instantiation resource context",
            ),
          )
      }
  }
  self.composition_nodes.push({
    id,
    operation,
    kind,
    resources,
    location: self.location(node),
  })
  id
}

///|
pub extend CompositionOperation with Eq::{equal, not_equal}

///|
pub extend CompositionOperation with @debug.Debug::{to_repr}

///|
pub extend CompositionNode with Eq::{equal, not_equal}

///|
pub extend CompositionNode with @debug.Debug::{to_repr}

///|
pub extend CompositionExport with Eq::{equal, not_equal}

///|
pub extend CompositionExport with @debug.Debug::{to_repr}
