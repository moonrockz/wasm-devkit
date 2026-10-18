///|
priv struct PackageGroup {
  identity : PackageIdentity
  documents : Array[Document]
  sections : ReadOnlyArray[Int32]
}

///|
fn package_identity_at(
  document : Document,
  item : Int32,
  errors : Array[Diagnostic],
) -> PackageIdentity? {
  guard document.ast.nodes[item].data
    is Package(path~, attributes~, nested~, ..) else {
    return None
  }
  let bad = fn(at : Int32, code : String, message : String) {
    errors.push(error(document.id, document.ast.nodes[at].span, code, message))
  }
  if !attributes.is_empty() {
    bad(
      item,
      if nested {
        "WIT-S001"
      } else {
        "WIT-S003"
      },
      "package attributes are not supported",
    )
  }
  guard document.ast.nodes[path].data is Path(namespaces~, segments~, version~) else {
    bad(path, "WIT-S001", "invalid package path role")
    return None
  }
  guard namespaces.length() == 1 &&
    segments.length() == 1 &&
    identifier(namespaces[0]) &&
    identifier(segments[0]) else {
    bad(path, "WIT-S001", "invalid package identity")
    return None
  }
  if version is Some(version) && !semantic_version(version) {
    bad(path, "WIT-S011", "invalid semantic package version")
  }
  Some({ namespace_name: namespaces[0], name: segments[0], version, })
}

///|
fn section_items(data : @ast.Data) -> ReadOnlyArray[Int32] {
  match data {
    File(items~) | Package(items~, nested=true, ..) => items
    _ => []
  }
}

///|
fn Prepared::alias_scope(self : Prepared, id : Int32) -> String {
  self.node_packages[id].to_string() + ":" + self.origins[id].location.source
}

///|
fn location_key(location : Location) -> String {
  location.span.start.to_string() +
  ":" +
  location.span.end.to_string() +
  ":" +
  location.source
}

///|
/// Ranges are disjoint top-level package blocks; the file's main package is the
/// fallback. Binary search avoids scanning all blocks for every diagnostic/path.
priv struct PackageRanges {
  main : Map[String, Int32]
  blocks : Map[String, Array[(Int32, Int32, Int32)]]
}

///|
fn PackageRanges::new() -> PackageRanges {
  { main: Map([]), blocks: Map([]), }
}

///|
fn PackageRanges::add(
  self : PackageRanges,
  source : String,
  data : @ast.Data,
  span : @span.Span,
  owner : Int32,
) -> Unit {
  if data is File(..) {
    self.main[source] = owner
  } else {
    let blocks = match self.blocks.get(source) {
      Some(blocks) => blocks
      None => {
        let blocks = []
        self.blocks[source] = blocks
        blocks
      }
    }
    blocks.push((span.start, span.end, owner))
  }
}

///|
fn PackageRanges::sort(self : PackageRanges) -> Unit {
  for _, blocks in self.blocks {
    blocks.sort_by((a, b) => {
      let start = a.0.compare(b.0)
      if start != 0 {
        start
      } else {
        a.1.compare(b.1)
      }
    })
  }
}

///|
fn PackageRanges::owner(self : PackageRanges, location : Location) -> Int32? {
  if self.blocks.get(location.source) is Some(blocks) {
    let mut low = 0
    let mut high = blocks.length()
    while low < high {
      let middle = low + (high - low) / 2
      if blocks[middle].0 <= location.span.start {
        low = middle + 1
      } else {
        high = middle
      }
    }
    if low > 0 {
      let (start, end, owner) = blocks[low - 1]
      if start <= location.span.start && location.span.end <= end {
        return Some(owner)
      }
    }
  }
  self.main.get(location.source)
}
