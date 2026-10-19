///|
/// A dependency key and the last requesting path, in first-use key order.
pub(all) struct PackageRequest {
  name : String
  version : String?
  location : Location
} derive(Eq, Debug)

///|
pub extend PackageRequest with Eq::{equal, not_equal}

///|
pub extend PackageRequest with @debug.Debug::{to_repr}

///|
/// Collect exact dependency keys without loading packages or resolving types.
/// Traversal uses an explicit stack. Self paths require no dependency; self
/// instantiation is an error even when nested inside another instantiation.
pub fn package_requests(
  parsed : @parser.Parse,
  source~ : String,
  source_id~ : String = "<input>",
) -> Result[ReadOnlyArray[PackageRequest], ReadOnlyArray[Diagnostic]] {
  if !parsed.is_valid() {
    let errors = []
    for diagnostic in parsed.diagnostics {
      if diagnostic.severity == Error {
        errors.push(
          error(
            source_id,
            diagnostic.primary.span,
            diagnostic.code,
            diagnostic.message,
          ),
        )
      }
    }
    return Err(ReadOnlyArray::from_array(errors))
  }
  let tree = parsed.ast
  guard tree.validate() && tree.root() is Some(root) else {
    return Err([
      error(
        source_id,
        { start: 0, end: 0, },
        "WAC-S001",
        "invalid AST structure",
      ),
    ])
  }
  for node in tree.nodes {
    guard node.span.start >= 0 && node.span.end <= source.length() else {
      return Err([
        error(
          source_id,
          node.span,
          "WAC-S001",
          "AST location is outside its source",
        ),
      ])
    }
  }
  guard tree.nodes[root].data is File(directive=Some(directive), ..) &&
    tree.nodes[directive].data is Package(path=identity, ..) &&
    tree.nodes[identity].data is Path(namespaces~, segments~, version~) &&
    !namespaces.is_empty() &&
    segments.length() == 1 &&
    namespaces.all(identifier) &&
    identifier(segments[0]) &&
    version.map(semantic_version).unwrap_or(true) else {
    return Err([
      error(
        source_id,
        tree.nodes[root].span,
        "WAC-S001",
        "invalid package directive",
      ),
    ])
  }
  let this = namespaces.join(":") + ":" + segments[0]
  let requests : Array[PackageRequest] = []
  let keys : Map[String, Int32] = Map([])
  let work = [root]
  while work.pop() is Some(node) {
    let data = tree.nodes[node].data
    if data is New(component~, ..) &&
      tree.nodes[component].data is Path(namespaces~, segments~, ..) &&
      !segments.is_empty() &&
      namespaces.join(":") + ":" + segments[0] == this {
      return Err([
        error(
          source_id,
          tree.nodes[component].span,
          "WAC-P005",
          "cannot instantiate the package being defined",
        ),
      ])
    }
    if node != identity &&
      data is Path(namespaces~, segments~, version~) &&
      !namespaces.is_empty() {
      guard !segments.is_empty() &&
        namespaces.all(identifier) &&
        segments.all(identifier) &&
        version.map(semantic_version).unwrap_or(true) else {
        return Err([
          error(
            source_id,
            tree.nodes[node].span,
            "WAC-S001",
            "invalid package path",
          ),
        ])
      }
      let name = namespaces.join(":") + ":" + segments[0]
      if name != this {
        let request : PackageRequest = {
          name,
          version,
          location: Location::text(source_id, tree.nodes[node].span),
        }
        let key = package_key(name, version)
        if keys.get(key) is Some(index) {
          requests[index] = request
        } else {
          keys[key] = requests.length()
          requests.push(request)
        }
      }
    }
    let children = data.children()
    for i = children.length() - 1; i >= 0; i = i - 1 {
      work.push(children[i])
    }
  }
  Ok(ReadOnlyArray::from_array(requests))
}
