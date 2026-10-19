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
  for exported in exports {
    if exported.name == name {
      return { kind: exported.kind, node, external_name: Some(name), }
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
