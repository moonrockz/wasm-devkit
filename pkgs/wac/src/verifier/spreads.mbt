///|
// Compatible tracks are symmetric: a provider may be older or newer. Prerelease
// versions and 0.0.x versions only match their exact external name.
fn version_track(name : String) -> String? {
  guard name.find("@") is Some(at) else { return None }
  let version = name[at + 1:].to_owned()
  guard semantic_version(version) else { return None }
  let core = version.split("+").to_array()[0].to_owned()
  if core.contains("-") {
    return None
  }
  let numbers = core.split(".").to_array()
  let prefix = name[:at + 1].to_owned()
  if numbers[0] != "0" {
    return Some(prefix + numbers[0].to_owned())
  }
  if numbers[1] != "0" {
    return Some(prefix + "0." + numbers[1].to_owned())
  }
  None
}

///|
fn compatible_external_version(actual : String, expected : String) -> Bool {
  if actual == expected {
    return true
  }
  match (version_track(actual), version_track(expected)) {
    (Some(a), Some(b)) => a == b
    _ => false
  }
}

///|
fn Check::spread_argument(
  self : Check,
  node : Int32,
  name : String,
  imports : ReadOnlyArray[Extern],
  seen : Map[String, Int32],
  arguments : Array[(String, Int32, LocalItem)],
) -> Unit raise SemanticFailure {
  let item = self.lookup(0, node, name)
  guard item.kind is Instance(ty) &&
    self.types[ty].kind is Interface(_, _, exports) else {
    raise Problem(
      self.problem(node, "WAC-C007", "spread argument requires an instance"),
    )
  }
  let mut contributed = false
  for imported in imports {
    if seen.contains(imported.name) {
      continue
    }
    let mut selected : String? = None
    if exports.any(exported => exported.name == imported.name) {
      selected = Some(imported.name)
    } else {
      for exported in exports {
        if compatible_external_version(exported.name, imported.name) {
          selected = Some(exported.name)
          break
        }
      }
    }
    if selected is Some(selected) {
      let value = self.alias_export(item, node, node, ty, selected, exports)
      seen[imported.name] = node
      arguments.push((imported.name, node, value))
      contributed = true
    }
  }
  if !contributed {
    raise Problem(
      self.problem(
        node, "WAC-C007", "spread instance has no matching exports for unsatisfied arguments",
      ),
    )
  }
}
