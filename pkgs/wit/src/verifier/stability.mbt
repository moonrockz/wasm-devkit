///|
/// Semantic release/feature metadata, independent of parser grammar switches.
pub(all) enum Stability {
  Unknown
  Stable(String, String?)
  Unstable(String, String?)
} derive(Eq, Debug)

///|
priv struct StabilityInfo {
  value : Stability
  origin : Int32?
}

///|
fn item_attributes(data : @ast.Data) -> ReadOnlyArray[Int32] {
  match data {
    Package(attributes~, ..)
    | Interface(attributes~, ..)
    | World(attributes~, ..)
    | Alias(attributes~, ..)
    | Record(attributes~, ..)
    | Flags(attributes~, ..)
    | Enum(attributes~, ..)
    | Variant(attributes~, ..)
    | Resource(attributes~, ..)
    | Function(attributes~, ..)
    | Constructor(attributes~, ..)
    | Import(attributes~, ..)
    | Export(attributes~, ..)
    | Use(attributes~, ..)
    | Include(attributes~, ..)
    | Field(attributes~, ..)
    | Case(attributes~, ..) => attributes
    _ => []
  }
}

///|
fn semantic_attributes(
  tree : @ast.Tree,
  attributes : ReadOnlyArray[Int32],
) -> Bool {
  attributes.all(id => {
    match tree.nodes[id].data {
      Attribute(name="since" | "deprecated" | "unstable" | "external-id", ..) =>
        true
      _ => false
    }
  })
}

///|
fn parse_stabilities(
  prepared : Prepared,
  errors : Array[Diagnostic],
) -> Array[StabilityInfo] {
  let tree = prepared.tree
  let infos = Array::make(tree.nodes.length(), { value: Unknown, origin: None, })
  for id, node in tree.nodes {
    let mut since : (String, Int32)? = None
    let mut deprecated : (String, Int32)? = None
    let mut unstable : (String, Int32)? = None
    let seen : Map[String, Int32] = Map([])
    for attribute in item_attributes(node.data) {
      guard tree.nodes[attribute].data is Attribute(name~, field~, value~) else {
        errors.push(
          prepared_error(
            prepared, attribute, "WIT-S001", "invalid attribute AST role",
          ),
        )
        continue
      }
      if !["since", "deprecated", "unstable"].contains(name) {
        continue
      }
      if seen.get(name) is Some(first) {
        let d = prepared_error(
          prepared,
          attribute,
          "WIT-S013",
          "duplicate @" + name + " annotation",
        )
        errors.push({
          ..d,
          related: [
            {
              location: prepared.origins[first].location,
              message: "first annotation",
            },
          ],
        })
      }
      seen[name] = attribute
      if name == "unstable" {
        if field != "feature" || !identifier(value) {
          errors.push(
            prepared_error(
              prepared, attribute, "WIT-S013", "@unstable requires a feature identifier",
            ),
          )
        }
        unstable = Some((value, attribute))
      } else {
        if field != "version" || !semantic_version(value) {
          errors.push(
            prepared_error(
              prepared,
              attribute,
              "WIT-S013",
              "@" + name + " requires a semantic version",
            ),
          )
        }
        if name == "since" {
          since = Some((value, attribute))
        } else {
          deprecated = Some((value, attribute))
        }
      }
    }
    let deprecated_version = deprecated.map(entry => entry.0)
    match (since, unstable) {
      (Some((version, attribute)), None) =>
        infos[id] = {
          value: Stable(version, deprecated_version),
          origin: Some(attribute),
        }
      (None, Some((feature, attribute))) =>
        infos[id] = {
          value: Unstable(feature, deprecated_version),
          origin: Some(attribute),
        }
      (Some((_, attribute)), Some(_)) =>
        errors.push(
          prepared_error(
            prepared, attribute, "WIT-S013", "@since and @unstable cannot be combined",
          ),
        )
      (None, None) =>
        if deprecated is Some((_, attribute)) {
          errors.push(
            prepared_error(
              prepared, attribute, "WIT-S013", "@deprecated requires @since or @unstable",
            ),
          )
        }
    }
  }
  for id, node in tree.nodes {
    match node.data {
      Function(signature~, ..) => infos[signature] = infos[id]
      Import(target~, ..) | Export(target~, ..) =>
        match tree.nodes[target].data {
          Signature(..) | Interface(..) => infos[target] = infos[id]
          _ => ()
        }
      Use(names~, ..) =>
        for selector in names {
          infos[selector] = infos[id]
        }
      _ => ()
    }
  }
  infos
}

///|
fn numeric_identifier(text : String) -> Bool {
  !text.is_empty() && text.iter().all(c => c >= '0' && c <= '9')
}

///|
fn numeric_compare(a : String, b : String) -> Int32 {
  let length = a.length().compare(b.length())
  if length != 0 {
    length
  } else {
    a.compare(b)
  }
}

///|
fn version_components(text : String) -> (ReadOnlyArray[String], String, String) {
  let build = text.split("+").map(StringView::to_owned).to_array()
  let parts = build[0].split("-").map(StringView::to_owned).to_array()
  (
    ReadOnlyArray::from_array(
      parts[0].split(".").map(StringView::to_owned).to_array(),
    ),
    if parts.length() > 1 {
      parts[1:].join("-")
    } else {
      ""
    },
    if build.length() > 1 {
      build[1]
    } else {
      ""
    },
  )
}

///|
fn version_identifiers_compare(a : String, b : String, build : Bool) -> Int32 {
  if !build && (a.is_empty() || b.is_empty()) {
    return if a.is_empty() && b.is_empty() {
      0
    } else if a.is_empty() {
      1
    } else {
      -1
    }
  }
  let a_parts = a.split(".").map(StringView::to_owned).to_array()
  let b_parts = b.split(".").map(StringView::to_owned).to_array()
  for i in 0..<a_parts.length() {
    if i >= b_parts.length() {
      return 1
    }
    let x = a_parts[i]
    let y = b_parts[i]
    let nx = numeric_identifier(x) || (build && x.is_empty())
    let ny = numeric_identifier(y) || (build && y.is_empty())
    let order = if nx && ny {
      if build {
        let mut ax = 0
        let mut by = 0
        while ax < x.length() && x.code_unit_at(ax) == 48 {
          ax += 1
        }
        while by < y.length() && y.code_unit_at(by) == 48 {
          by += 1
        }
        let value = numeric_compare(x[ax:].to_owned(), y[by:].to_owned())
        if value != 0 {
          value
        } else {
          x.length().compare(y.length())
        }
      } else {
        numeric_compare(x, y)
      }
    } else if nx {
      -1
    } else if ny {
      1
    } else {
      x.compare(y)
    }
    if order != 0 {
      return order
    }
  }
  a_parts.length().compare(b_parts.length())
}

///|
/// Matches semver::Version Ord at the reference pin, including build metadata.
fn version_compare(a : String, b : String) -> Int32 {
  let (ac, ap, ab) = version_components(a)
  let (bc, bp, bb) = version_components(b)
  for i in 0..<3 {
    let order = numeric_compare(ac[i], bc[i])
    if order != 0 {
      return order
    }
  }
  let prerelease = version_identifiers_compare(ap, bp, false)
  if prerelease != 0 {
    prerelease
  } else {
    version_identifiers_compare(ab, bb, true)
  }
}

///|
fn verify_stable_versions(
  prepared : Prepared,
  infos : ReadOnlyArray[StabilityInfo],
  relevant : ReadOnlyArray[Bool],
  errors : Array[Diagnostic],
) -> Unit {
  let headers : Map[Int32, Location] = Map([])
  for root in prepared.roots {
    let owner = prepared.node_packages[root]
    if prepared.tree.nodes[root].data is Package(path~, ..) {
      headers[owner] = prepared.origins[path].location
    } else {
      for item in section_items(prepared.tree.nodes[root].data) {
        if prepared.tree.nodes[item].data is Package(path~, nested=false, ..) {
          headers[owner] = prepared.origins[path].location
        }
      }
    }
  }
  // Check explicit gates once. For stable annotations, inherited anonymous
  // gates cannot be newer than this package's already-checked explicit gate.
  let checked : Map[Int32, Bool] = Map([])
  for id, info in infos {
    guard relevant[id] &&
      info.value is Stable(since, _) &&
      info.origin is Some(attribute) else {
      continue
    }
    if checked.contains(attribute) || !semantic_version(since) {
      continue
    }
    checked[attribute] = true
    let owner = prepared.node_packages[id]
    let identity = prepared.identities[owner]
    let valid = match identity.version {
      Some(version) => version_compare(since, version) <= 0
      None => false
    }
    if !valid {
      let d = prepared_error(
        prepared,
        attribute,
        "WIT-S013",
        match identity.version {
          None => "@since requires a versioned package"
          Some(version) =>
            "@since " + since + " is newer than package version " + version
        },
      )
      let related : Array[Label] = []
      if headers.get(owner) is Some(location) {
        related.push({ location, message: "package " + identity_key(identity), })
      }
      errors.push({ ..d, related: ReadOnlyArray::from_array(related), })
    }
  }
}

///|
pub extend Stability with Eq::{equal, not_equal}

///|
pub extend Stability with @debug.Debug::{to_repr}

///|
/// Named declarations keep their own annotation. Anonymous composites inherit
/// the declaration's context, or the first directly referenced known stability.
/// A named alias with unknown stability deliberately stops that propagation.
fn type_stabilities(
  prepared : Prepared,
  references : Map[Int32, Int32],
  resources : ReadOnlyArray[Int32],
  infos : ReadOnlyArray[StabilityInfo],
  interface_edges : Array[(Int32, Int32, Int32)],
  binary_sources~ : Map[String, Bool] = Map([]),
) -> ReadOnlyArray[Stability] {
  let tree = prepared.tree
  let values = infos.map(info => info.value).iter().to_array()
  let named_roots = Array::make(tree.nodes.length(), false)
  for id, node in tree.nodes {
    if type_declaration(node.data) &&
      !binary_sources.contains(prepared.origins[id].location.source) {
      let pending = type_edges(node.data).iter().to_array()
      if node.data is Alias(ty~, ..) {
        named_roots[ty] = true
      }
      while !pending.is_empty() {
        let child = pending.pop().unwrap()
        values[child] = infos[id].value
        for next in type_edges(tree.nodes[child].data) {
          pending.push(next)
        }
      }
    }
  }
  let canonical = Array::make(tree.nodes.length(), "")
  for id in 0..<tree.nodes.length() {
    canonical[id] = "t" + id.to_string()
  }
  let interned : Map[String, (String, Stability)] = Map([])
  let intern = fn(key : String, stability : Stability) {
    match interned.get(key) {
      Some(entry) => entry
      None => {
        let entry = ("a" + interned.length().to_string(), stability)
        interned[key] = entry
        entry
      }
    }
  }
  let done = Array::make(tree.nodes.length(), false)
  for action in allocation_order(prepared, references, interface_edges) {
    let start = match action {
      Receiver(signature, resource) => {
        let key = prepared.node_packages[signature].to_string() +
          ":borrow:t" +
          resource.to_string()
        let initial = if binary_sources.contains(
            prepared.origins[signature].location.source,
          ) {
          Stability::Unknown
        } else {
          infos[resource].value
        }
        let (_, stability) = intern(key, initial)
        values[signature] = stability
        continue
      }
      Type(start) => start
      Scope(_) => continue
    }
    let pending = [(start, false)]
    while pending.pop() is Some((id, leaving)) {
      if done[id] {
        continue
      }
      let data = tree.nodes[id].data
      if !leaving {
        pending.push((id, true))
        let children = type_edges(data)
        for i = children.length() - 1; i >= 0; i = i - 1 {
          pending.push((children[i], false))
        }
        continue
      }
      done[id] = true
      match data {
        NamedType(..) =>
          if references.get(id) is Some(target) {
            values[id] = values[target]
            canonical[id] = "t" + target.to_string()
          }
        PrimitiveType(name~) => {
          values[id] = Unknown
          canonical[id] = "b" + name
        }
        OwnType(resource~) => {
          values[id] = values[resource]
          canonical[id] = canonical[resource]
        }
        _ =>
          if values[id] == Unknown &&
            !type_declaration(data) &&
            !named_roots[id] {
            for child in type_edges(data) {
              if values[child] != Unknown {
                values[id] = values[child]
                break
              }
            }
          }
      }
      if binary_sources.contains(prepared.origins[id].location.source) &&
        !type_declaration(data) {
        values[id] = Unknown
      }
      if !named_roots[id] && anonymous_key(data, canonical) is Some(key) {
        let key = prepared.node_packages[id].to_string() + ":" + key
        let (identity, stability) = intern(key, values[id])
        canonical[id] = identity
        values[id] = stability
      }
    }
  }
  // Owned handles are introduced after source type stability was inferred.
  for id, node in tree.nodes {
    match node.data {
      OwnType(..) | NamedType(..) if resources[id] >= 0 => values[id] = Unknown
      _ => ()
    }
  }
  ReadOnlyArray::from_array(values)
}
