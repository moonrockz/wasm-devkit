///|
priv struct ForeignGates {
  paths : Map[Int32, Bool]
  excluded : Map[Int32, Int32]
  versions : ReadOnlyArray[Bool]
}

///|
fn Prepared::foreign_key(self : Prepared, path : Int32) -> String? {
  guard self.foreign_package(path) is Some(package_index) &&
    self.tree.nodes[path].data is Path(segments~, ..) else {
    return None
  }
  let identity = self.identities[package_index]
  Some(
    self.node_packages[path].to_string() +
    ":" +
    identity.namespace_name +
    ":" +
    identity.name +
    "/" +
    segments[1] +
    identity.version.map(v => "@" + v).unwrap_or(""),
  )
}

///|
fn foreign_kinds(
  prepared : Prepared,
  errors : Array[Diagnostic],
) -> Map[String, (String, Int32)] {
  let kinds : Map[String, (String, Int32)] = Map([])
  let visited = Array::make(prepared.tree.nodes.length(), false)
  let work = []
  for i = prepared.roots.length() - 1; i >= 0; i = i - 1 {
    work.push(prepared.roots[i])
  }
  while work.pop() is Some(id) {
    if visited[id] {
      continue
    }
    visited[id] = true
    let data = prepared.tree.nodes[id].data
    let children = data.children()
    for i = children.length() - 1; i >= 0; i = i - 1 {
      work.push(children[i])
    }
    let (path, kind) = match data {
      Use(path~, names~, ..) =>
        (path, if names.is_empty() { "item" } else { "interface" })
      Include(path~, ..) => (path, "world")
      Import(target~, ..) | Export(target~, ..) => (target, "interface")
      _ => continue
    }
    guard prepared.foreign_key(path) is Some(key) else { continue }
    match kinds.get(key) {
      Some((first_kind, first)) =>
        if kind != "item" && kind != first_kind {
          let diagnostic = prepared_error(
            prepared, path, "WIT-S008", "foreign member used as both interface and world",
          )
          errors.push({
            ..diagnostic,
            related: [
              {
                location: prepared.origins[first].location,
                message: "first foreign member use",
              },
            ],
          })
        }
      None =>
        kinds[key] = (if kind == "item" { "interface" } else { kind }, path)
    }
  }
  kinds
}

///|
/// Foreign members combine all path gates, while imported unknown types keep
/// the first selector's gate. Both rules precede local owner selection upstream.
fn foreign_gates(
  prepared : Prepared,
  scopes : Array[Map[String, Int32]],
  aliases : Map[String, Map[String, Int32]],
  infos : ReadOnlyArray[StabilityInfo],
  features : SemanticFeatures,
  binary_sources~ : Map[String, Bool] = Map([]),
) -> ForeignGates {
  let tree = prepared.tree
  let paths : Map[Int32, Bool] = Map([])
  let excluded : Map[Int32, Int32] = Map([])
  let versions = Array::make(tree.nodes.length(), false)
  let enabled : Map[String, Bool] = Map([])
  let first_types : Map[String, Int32] = Map([])
  let visited = Array::make(tree.nodes.length(), false)
  let work = []
  for i = prepared.roots.length() - 1; i >= 0; i = i - 1 {
    work.push(prepared.roots[i])
  }
  while work.pop() is Some(id) {
    if visited[id] {
      continue
    }
    visited[id] = true
    let children = tree.nodes[id].data.children()
    for i = children.length() - 1; i >= 0; i = i - 1 {
      work.push(children[i])
    }
    let path = match tree.nodes[id].data {
      Use(path~, ..) | Include(path~, ..) => path
      Import(target~, ..) | Export(target~, ..) => target
      _ => continue
    }
    let canonical = match prepared.foreign_package(path) {
      Some(package_index) => {
        guard tree.nodes[path].data is Path(segments~, ..) else { continue }
        let identity = prepared.identities[package_index]
        identity.namespace_name +
        ":" +
        identity.name +
        "/" +
        segments[1] +
        identity.version.map(v => "@" + v).unwrap_or("")
      }
      None =>
        match
          prepared.find_item(
            scopes,
            path,
            match tree.nodes[id].data {
              Include(..) => "world"
              Use(names~, ..) if names.is_empty() => "item"
              _ => "interface"
            },
            file_aliases=aliases,
          ) {
          Ok((target, _)) if prepared.node_packages[target] !=
            prepared.node_packages[id] => prepared.interface_name(target)
          _ => continue
        }
    }
    // Decoded named types and world items survive metadata feature gates.
    // Their dependencies must not inherit source-only first-selector gating.
    if binary_sources.contains(prepared.origins[id].location.source) {
      continue
    }
    paths[id] = true
    let key = prepared.node_packages[id].to_string() + ":" + canonical
    if prepared.foreign_package(path) is Some(_) {
      versions[id] = !enabled.get(key).unwrap_or(false)
      if features.includes(infos[id].value) {
        enabled[key] = true
      }
    }
    if tree.nodes[id].data is Use(names~, ..) {
      for selector in names {
        guard tree.nodes[selector].data is Rename(name~, ..) else { continue }
        let type_key = key + ":" + name
        let first = match first_types.get(type_key) {
          Some(first) => first
          None => {
            first_types[type_key] = selector
            selector
          }
        }
        if !features.includes(infos[first].value) {
          excluded[selector] = first
        }
      }
    }
  }
  { paths, excluded, versions: ReadOnlyArray::from_array(versions), }
}
