///|
// Exact external names win. Only unquoted access may infer a unique interface
// suffix, ignoring the optional version. Ambiguous suffixes remain unresolved.
fn matching_external_name(
  name : String,
  exports : ReadOnlyArray[Extern],
) -> String {
  if exports.any(item => item.name == name) {
    return name
  }
  let mut found : String? = None
  for item in exports {
    let segments = item.name.split("/").to_array()
    if segments.length() < 2 {
      continue
    }
    let suffix = segments[segments.length() - 1].split("@").to_array()[0].to_owned()
    if suffix != name {
      continue
    }
    if found is Some(_) {
      return name
    }
    found = Some(item.name)
  }
  found.unwrap_or(name)
}

///|
fn Check::access(
  self : Check,
  item : LocalItem,
  node : Int32,
  parent : Int32,
) -> LocalItem raise SemanticFailure {
  guard self.tree.nodes[node].data is Access(name~, quoted~) else {
    raise Problem(
      self.problem(node, "WAC-S001", "invalid instance access role"),
    )
  }
  if !quoted {
    self.name(node, name)
  }
  guard item.kind is Instance(ty) else {
    raise Problem(
      self.problem(parent, "WAC-C001", "member access requires an instance"),
    )
  }
  guard self.types[ty].kind is Interface(_, _, exports) else {
    raise Problem(
      self.problem(parent, "WAC-S001", "invalid resolved instance type"),
    )
  }
  let name = if quoted { name } else { matching_external_name(name, exports) }
  self.alias_export(item, node, parent, ty, name, exports)
}

///|
fn Check::alias_export(
  self : Check,
  item : LocalItem,
  node : Int32,
  parent : Int32,
  ty : Int32,
  name : String,
  exports : ReadOnlyArray[Extern],
) -> LocalItem raise SemanticFailure {
  for exported in exports {
    if exported.name == name {
      guard item.value is Some(instance) else {
        raise Problem(
          self.problem(parent, "WAC-S001", "instance has no composition value"),
        )
      }
      let key = (instance, name)
      let value = match self.composition_aliases.get(key) {
        Some(value) => value
        None => {
          let value = self.composition_node(
            node,
            Access(instance, name),
            exported.kind,
          )
          self.composition_aliases[key] = value
          value
        }
      }
      return {
        kind: exported.kind,
        node,
        external_name: Some(name),
        value: Some(value),
      }
    }
  }
  let diagnostic = self.problem(
    node,
    "WAC-C002",
    "instance has no export `" + name + "`",
  )
  raise Problem({
    ..diagnostic,
    related: [
      {
        location: self.types[ty].location,
        message: "instance type defined here",
      },
    ],
  })
}
