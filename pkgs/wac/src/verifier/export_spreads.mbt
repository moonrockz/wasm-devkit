///|
fn Check::export_value(
  self : Check,
  node : Int32,
  name : String,
  item : LocalItem,
) -> Unit raise SemanticFailure {
  if self.scopes[0].names.get(name) is Some(bound) &&
    bound.value is Some(value) &&
    self.composition_nodes[value].operation is Definition {
    raise Problem(
      self.problem(
        node,
        "WAC-S004",
        "export `" + name + "` conflicts with a type definition",
        first=Some(bound.node),
      ),
    )
  }
  self.extern_item(0, node, name, item.kind, false, value=item.value)
}

///|
// Earlier exports win by exact name. Alias caching preserves the identity of
// members already accessed through another expression or export.
fn Check::export_spread(
  self : Check,
  node : Int32,
  expression : Int32,
  item : LocalItem,
) -> Unit raise SemanticFailure {
  guard item.kind is Instance(ty) &&
    self.types[ty].kind is Interface(_, _, exports) else {
    raise Problem(
      self.problem(expression, "WAC-C007", "export spread requires an instance"),
    )
  }
  let mut contributed = false
  for exported in exports {
    if self.scopes[0].export_nodes.contains(exported.name) {
      continue
    }
    let selected = self.alias_export(
      item,
      expression,
      expression,
      ty,
      exported.name,
      exports,
    )
    self.export_value(node, exported.name, selected)
    contributed = true
  }
  if !contributed {
    raise Problem(
      self.problem(
        expression, "WAC-C007", "spread instance has no unexported members",
      ),
    )
  }
}
