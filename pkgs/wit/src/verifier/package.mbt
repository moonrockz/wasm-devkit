///|
/// Caller-supplied immutable syntax and source context. No I/O is performed.
pub(all) struct Document {
  id : String
  text : String
  ast : @ast.Tree
  diagnostics : ReadOnlyArray[@diagnostic.Diagnostic]
}

///|
pub fn Document::from_parse(
  id : String,
  text : String,
  parsed : @parser.Parse,
) -> Document {
  { id, text, ast: parsed.ast, diagnostics: parsed.diagnostics, }
}

///|
/// Files belonging to one package. At least one file must declare its identity;
/// matching headers in other files are allowed. Discovery order is immaterial.
/// Top-level nested package blocks supply additional package identities while
/// retaining the same original document and source-qualified node provenance.
pub(all) struct SourcePackage {
  documents : ReadOnlyArray[Document]
}

///|
/// Original syntax index is present only when the provider supplied a source AST.
pub(all) struct Origin {
  location : Location
  node : Int32?
} derive(Eq, Debug)

///|
/// Verified closure with the original per-file ASTs and source provenance.
pub struct Resolution {
  priv model : SemanticModel
  priv root_location : Location
  priv documents : ReadOnlyArray[Document]
  priv encoded_packages : ReadOnlyArray[EncodedPackage]
  priv packages : ReadOnlyArray[PackageIdentity]
  priv origins : ReadOnlyArray[Origin]
}

///|
pub fn Resolution::root(self : Resolution) -> PackageIdentity {
  self.packages[0]
}

///|
pub fn Resolution::types(self : Resolution) -> ReadOnlyArray[ResolvedType] {
  self.model.resolved_types
}

///|
pub fn Resolution::declarations(self : Resolution) -> ReadOnlyArray[Binding] {
  self.model.bindings
}

///|
pub fn Resolution::sources(self : Resolution) -> ReadOnlyArray[Document] {
  self.documents
}

///|
/// Encoded inputs retain immutable bytes and caller-supplied provider identities.
pub fn Resolution::binaries(self : Resolution) -> ReadOnlyArray[EncodedPackage] {
  self.encoded_packages
}

///|
pub fn Resolution::identities(
  self : Resolution,
) -> ReadOnlyArray[PackageIdentity] {
  self.packages
}

///|
pub fn Resolution::origin(self : Resolution, node : Int32) -> Origin? {
  if node >= 0 && node < self.origins.length() {
    Some(self.origins[node])
  } else {
    None
  }
}

///|
priv struct Prepared {
  tree : @ast.Tree
  documents : ReadOnlyArray[Document]
  identities : ReadOnlyArray[PackageIdentity]
  origins : ReadOnlyArray[Origin]
  roots : ReadOnlyArray[Int32]
  node_packages : ReadOnlyArray[Int32]
  by_identity : Map[String, Int32]
}

///|
fn identity_key(identity : PackageIdentity) -> String {
  identity.namespace_name +
  ":" +
  identity.name +
  (match identity.version {
    Some(version) => "@" + version
    None => ""
  })
}

///|
fn semantic_version(text : String) -> Bool {
  // SemVer numeric core is bounded by the reference semver crate's u64 fields.
  let pieces = text.split("+").to_array()
  if pieces.length() > 2 {
    return false
  }
  let main = pieces[0].split("-").to_array()
  let core = main[0].split(".").to_array()
  if core.length() != 3 {
    return false
  }
  for number in core {
    if number.is_empty() || (number.length() > 1 && number.has_prefix("0")) {
      return false
    }
    let mut value : UInt64 = 0
    for i in 0..<number.length() {
      let c = number.code_unit_at(i).to_int()
      if c < 48 || c > 57 {
        return false
      }
      let digit = (c - 48).to_uint64()
      if value > (18446744073709551615UL - digit) / 10 {
        return false
      }
      value = value * 10 + digit
    }
  }
  let suffix = if main.length() > 1 { main[1:].join("-") } else { "" }
  for
    (part, numeric_rules) in [
      (suffix, true),
      (if pieces.length() == 2 { pieces[1].to_owned() } else { "" }, false),
    ] {
    if part.is_empty() {
      if (numeric_rules && main.length() > 1) ||
        (!numeric_rules && pieces.length() == 2) {
        return false
      }
      continue
    }
    for word in part.split(".") {
      if word.is_empty() {
        return false
      }
      let mut numeric = true
      for i in 0..<word.length() {
        let c = word.code_unit_at(i).to_int()
        if c >= 48 && c <= 57 {
          continue
        }
        numeric = false
        if c != 45 && !(c >= 65 && c <= 90) && !(c >= 97 && c <= 122) {
          return false
        }
      }
      if numeric_rules && numeric && word.length() > 1 && word.has_prefix("0") {
        return false
      }
    }
  }
  true
}

///|
fn prepare(
  root : SourcePackage,
  dependencies : ReadOnlyArray[SourcePackage],
  binary_sources~ : Map[String, Bool] = Map([]),
  merge_encoded~ : Bool = true,
) -> Result[Prepared, ReadOnlyArray[Diagnostic]] {
  let inputs = [root]
  inputs.append(dependencies.iter().to_array())
  let errors : Array[Diagnostic] = []
  let groups : Array[PackageGroup] = []
  let nested_groups : Array[PackageGroup] = []
  let source_ids : Map[String, Bool] = Map([])
  for input in inputs {
    let documents = input.documents.iter().to_array()
    documents.sort_by((a, b) => a.id.compare(b.id))
    let mut identity : PackageIdentity? = None
    if documents.is_empty() {
      errors.push(
        error(
          "<package>",
          { start: 0, end: 0, },
          "WIT-S002",
          "package has no source files",
        ),
      )
    }
    for document in documents {
      if source_ids.contains(document.id) {
        errors.push(
          error(
            document.id,
            { start: 0, end: 0, },
            "WIT-S011",
            "duplicate source identity",
          ),
        )
      }
      source_ids[document.id] = true
      for d in document.diagnostics {
        if d.severity == Error {
          errors.push(error(document.id, d.primary.span, d.code, d.message))
        }
      }
      if !document.ast.validate() {
        errors.push(
          error(
            document.id,
            { start: 0, end: 0, },
            "WIT-S001",
            "invalid AST structure",
          ),
        )
        continue
      }
      for node in document.ast.nodes {
        if node.span.end > document.text.length() {
          errors.push(
            error(
              document.id,
              node.span,
              "WIT-S001",
              "AST location is outside its source",
            ),
          )
        }
      }
      let root_node = document.ast.nodes[document.ast.nodes.length() - 1]
      guard root_node.data is File(items~) else {
        errors.push(
          error(
            document.id,
            root_node.span,
            "WIT-S001",
            "source AST must have a File root",
          ),
        )
        continue
      }
      let mut header_count = 0
      for index, item in items {
        if document.ast.nodes[item].data
          is Package(path~, items=package_items, nested~, ..) {
          guard package_identity_at(document, item, errors) is Some(candidate) else {
            continue
          }
          if nested {
            for child in package_items {
              if document.ast.nodes[child].data is Package(..) {
                errors.push(
                  error(
                    document.id,
                    document.ast.nodes[child].span,
                    "WIT-S001",
                    "nested packages must be placed at the top-level",
                  ),
                )
              }
            }
            nested_groups.push({
              identity: candidate,
              documents: [document],
              sections: [item],
            })
            continue
          }
          header_count += 1
          if index != 0 || header_count > 1 || !package_items.is_empty() {
            errors.push(
              error(
                document.id,
                document.ast.nodes[item].span,
                "WIT-S001",
                "expected one leading package header per file",
              ),
            )
          }
          if identity is Some(previous) && candidate != previous {
            errors.push(
              error(
                document.id,
                document.ast.nodes[path].span,
                "WIT-S011",
                "conflicting package headers: expected " +
                identity_key(previous) +
                ", found " +
                identity_key(candidate),
              ),
            )
          } else {
            identity = Some(candidate)
          }
        }
      }
    }
    match identity {
      Some(identity) =>
        groups.push({
          identity,
          documents,
          sections: ReadOnlyArray::from_array(
            documents.map(doc => doc.ast.nodes.length() - 1),
          ),
        })
      None =>
        errors.push(
          error(
            if documents.is_empty() {
              "<package>"
            } else {
              documents[0].id
            },
            { start: 0, end: 0, },
            "WIT-S002",
            "a complete WIT package requires a package header",
          ),
        )
    }
  }
  groups.append(nested_groups)
  if !errors.is_empty() {
    return Err(loading_diagnostics(root, groups, errors))
  }
  // Keep the root package first. Nested blocks and supplied dependencies share
  // the same identity space, while each original document is retained once.
  let deps = groups[1:].to_owned()
  deps.sort_by((a, b) => {
    identity_key(a.identity).compare(identity_key(b.identity))
  })
  let groups = [groups[0]]
  groups.append(deps)
  let identities : Array[PackageIdentity] = []
  let known : Map[String, Location] = Map([])
  let by_identity : Map[String, Int32] = Map([])
  for group in groups {
    let key = identity_key(group.identity)
    let partial = binary_sources.contains(group.documents[0].id) &&
      group.documents[0].ast.nodes[group.sections[0]].data
      is Package(nested=true, ..)
    let location : Location = {
      source: group.documents[0].id,
      position: SourceSpan(group.documents[0].ast.nodes[group.sections[0]].span),
    }
    if !partial && known.get(key) is Some(previous) {
      let d = error_at(
        location,
        "WIT-S011",
        "duplicate supplied package " + key,
      )
      errors.push({
        ..d,
        related: [{ location: previous, message: "first package definition", }],
      })
    }
    if !partial {
      known[key] = location
    }
    if !by_identity.contains(key) {
      by_identity[key] = identities.length()
      identities.push(group.identity)
    }
  }
  if !errors.is_empty() {
    return Err(ordered_diagnostics(errors))
  }
  let documents : Array[Document] = []
  let bases : Map[String, Int32] = Map([])
  let nodes : Array[@ast.Node] = []
  let origins : Array[Origin] = []
  let roots : Array[Int32] = []
  let root_owners : Map[Int32, Int32] = Map([])
  let node_packages : Array[Int32] = []
  let partial_roots : Map[Int32, Bool] = Map([])
  for group in groups {
    let package_index = by_identity[identity_key(group.identity)]
    for file_index, document in group.documents {
      let base = match bases.get(document.id) {
        Some(base) => base
        None => {
          let base = nodes.length()
          bases[document.id] = base
          for index, node in document.ast.nodes {
            nodes.push({
              data: node.data.map_children(child => base + child),
              span: node.span,
            })
            origins.push({
              location: Location::text(document.id, node.span),
              node: Some(index),
            })
            node_packages.push(-1)
          }
          documents.push(document)
          base
        }
      }
      let section = base + group.sections[file_index]
      roots.push(section)
      if binary_sources.contains(document.id) &&
        nodes[section].data is Package(nested=true, ..) {
        partial_roots[section] = true
      }
      root_owners[section] = package_index
    }
  }
  for root in roots {
    let owner = root_owners[root]
    let pending = [root]
    while pending.pop() is Some(id) {
      node_packages[id] = owner
      for child in nodes[id].data.children() {
        if !root_owners.contains(child) {
          pending.push(child)
        }
      }
    }
  }
  if merge_encoded {
    encoded_merge_sections(
      nodes, origins, roots, root_owners, partial_roots, errors,
    ) catch {
      Unsupported(message) | Invalid(message) => {
        let location = origins[roots[0]].location
        errors.push(error_at(location, "WIT-B002", message))
      }
    }
  }
  if !errors.is_empty() {
    return Err(ordered_diagnostics(errors))
  }
  if merge_encoded && !partial_roots.is_empty() {
    encoded_compact_closure(nodes, origins, roots, node_packages)
  }
  Ok({
    tree: { nodes: ReadOnlyArray::from_array(nodes), },
    documents: ReadOnlyArray::from_array(documents),
    identities: ReadOnlyArray::from_array(identities),
    origins: ReadOnlyArray::from_array(origins),
    roots: ReadOnlyArray::from_array(roots),
    node_packages: ReadOnlyArray::from_array(node_packages),
    by_identity,
  })
}

///|
/// Verify supplied package sources and dependency bytes decoded by the caller.
/// Source loading, registry policy and caching belong to separate adapters.
pub fn resolve(
  root : SourcePackage,
  dependencies~ : ReadOnlyArray[SourcePackage] = [],
  semantic_features~ : SemanticFeatures = SemanticFeatures::default(),
) -> Result[Resolution, ReadOnlyArray[Diagnostic]] {
  match prepare(root, dependencies) {
    Err(errors) => Err(errors)
    Ok(prepared) => verify_prepared(prepared, semantic_features)
  }
}

///|
pub extend Origin with Eq::{equal, not_equal}

///|
pub extend Origin with @debug.Debug::{to_repr}

///|
fn prepared_error(
  prepared : Prepared,
  id : Int32,
  code : String,
  message : String,
) -> Diagnostic {
  let location = prepared.origins[id].location
  error_at(location, code, message)
}

///|
fn Prepared::find_item(
  self : Prepared,
  scopes : Array[Map[String, Int32]],
  path : Int32,
  expected : String,
  file_aliases~ : Map[String, Map[String, Int32]] = Map([]),
) -> Result[(Int32, Bool), Diagnostic] {
  guard self.tree.nodes[path].data is Path(namespaces~, segments~, version~) else {
    return Err(
      prepared_error(self, path, "WIT-S001", "invalid reference path role"),
    )
  }
  let mut package_index = self.node_packages[path]
  let external = !namespaces.is_empty()
  let item_name = if !external {
    if segments.length() != 1 || version is Some(_) {
      return Err(
        prepared_error(self, path, "WIT-S001", "invalid local item path"),
      )
    }
    segments[0]
  } else {
    if namespaces.length() != 1 || segments.length() != 2 {
      return Err(
        prepared_error(
          self, path, "WIT-S003", "nested package paths are not yet supported",
        ),
      )
    }
    let key = namespaces[0] +
      ":" +
      segments[0] +
      (match version {
        Some(v) => "@" + v
        None => ""
      })
    match self.by_identity.get(key) {
      Some(index) => package_index = index
      None =>
        return Err(
          prepared_error(
            self,
            path,
            "WIT-S009",
            "unresolved package `" + key + "`",
          ),
        )
    }
    segments[1]
  }
  if !identifier(item_name) {
    return Err(
      prepared_error(self, path, "WIT-S001", "invalid decoded item name"),
    )
  }
  let alias_target = if !external {
    match file_aliases.get(self.alias_scope(path)) {
      Some(names) => names.get(item_name)
      None => None
    }
  } else {
    None
  }
  match
    (match alias_target {
      Some(target) => Some(target)
      None => scopes[package_index].get(item_name)
    }) {
    None =>
      Err(
        prepared_error(
          self,
          path,
          "WIT-S005",
          "unresolved " +
          expected +
          " `" +
          item_name +
          "` in " +
          identity_key(self.identities[package_index]),
        ),
      )
    Some(target) => {
      let right_kind = match self.tree.nodes[target].data {
        Interface(..) => expected == "interface" || expected == "item"
        World(..) => expected == "world" || (expected == "item" && !external)
        _ => false
      }
      if right_kind {
        Ok((target, external))
      } else {
        let d = prepared_error(
          self,
          path,
          "WIT-S008",
          "expected an " + expected + ", found `" + item_name + "`",
        )
        Err({
          ..d,
          related: [
            {
              location: self.origins[target].location,
              message: "declaration is here",
            },
          ],
        })
      }
    }
  }
}

///|
/// Foreign feature gates defer member lookup, but never package lookup or path
/// validation. Local names continue through ordinary lexical validation.
fn Prepared::foreign_package(self : Prepared, path : Int32) -> Int32? {
  guard self.tree.nodes[path].data is Path(namespaces~, segments~, version~) &&
    namespaces.length() == 1 &&
    segments.length() == 2 &&
    identifier(segments[1]) else {
    return None
  }
  let key = namespaces[0] +
    ":" +
    segments[0] +
    version.map(v => "@" + v).unwrap_or("")
  self.by_identity.get(key)
}

///|
pub(all) enum WorldItemKind {
  Interface(Int32)
  Function(Int32)
  Type(Int32)
} derive(Eq, Debug)

///|
pub(all) struct WorldItem {
  external_id : String?
  name : String
  by_id : Bool
  kind : WorldItemKind
  location : Location
  stability : Stability
} derive(Eq, Debug)

///|
pub(all) struct ResolvedWorld {
  package_identity : PackageIdentity
  id : Int32
  name : String
  imports : ReadOnlyArray[WorldItem]
  exports : ReadOnlyArray[WorldItem]
  location : Location
  stability : Stability
} derive(Eq, Debug)

///|
pub fn Resolution::worlds(self : Resolution) -> ReadOnlyArray[ResolvedWorld] {
  self.model.resolved_worlds
}

///|
pub extend WorldItemKind with Eq::{equal, not_equal}

///|
pub extend WorldItemKind with @debug.Debug::{to_repr}

///|
pub extend WorldItem with Eq::{equal, not_equal}

///|
pub extend WorldItem with @debug.Debug::{to_repr}

///|
pub extend ResolvedWorld with Eq::{equal, not_equal}

///|
pub extend ResolvedWorld with @debug.Debug::{to_repr}

///|
fn graph_cycles(
  prepared : Prepared,
  edges : Array[(Int32, Int32, Int32)],
  packages : Bool,
  errors : Array[Diagnostic],
) -> Unit {
  let count = if packages {
    prepared.identities.length()
  } else {
    prepared.tree.nodes.length()
  }
  let adjacency : Array[Array[(Int32, Int32)]] = []
  for _ in 0..<count {
    adjacency.push([])
  }
  for (from, target, path) in edges {
    adjacency[from].push((target, path))
  }
  let colors = Array::make(count, 0)
  for start in 0..<count {
    if colors[start] != 0 {
      continue
    }
    let work = [(start, false, -1)]
    while work.pop() is Some((node, leaving, path)) {
      if leaving {
        colors[node] = 2
        continue
      }
      if colors[node] == 2 {
        continue
      }
      if colors[node] == 1 {
        if path >= 0 {
          let related : Array[Label] = []
          for i = work.length() - 1
              i >= 0 && i >= work.length() - 64
              i = i - 1 {
            let (_, leaving, ancestor_path) = work[i]
            if leaving && ancestor_path >= 0 && related.length() < 32 {
              related.push({
                location: prepared.origins[ancestor_path].location,
                message: "dependency passes through here",
              })
            }
          }
          let d = prepared_error(
            prepared,
            path,
            "WIT-S006",
            if packages {
              "cyclic package dependency"
            } else {
              "cyclic interface dependency"
            },
          )
          errors.push({ ..d, related: ReadOnlyArray::from_array(related), })
        }
        continue
      }
      colors[node] = 1
      work.push((node, true, path))
      for i = adjacency[node].length() - 1; i >= 0; i = i - 1 {
        let (target, path) = adjacency[node][i]
        work.push((target, false, path))
      }
    }
  }
}

///|
fn dependency_chains(
  prepared : Prepared,
  edges : Array[(Int32, Int32, Int32)],
  diagnostics : Array[Diagnostic],
) -> ReadOnlyArray[Diagnostic] {
  let owners : Map[String, Int32] = Map([])
  for id, origin in prepared.origins {
    let key = location_key(origin.location)
    let owner = prepared.node_packages[id]
    // Caller-built trees may give distinct package nodes identical locations.
    // Preserve the primary location without inventing an ambiguous chain.
    if owners.get(key) is Some(previous) && previous != owner {
      owners[key] = -1
    } else if !owners.contains(key) {
      owners[key] = owner
    }
  }
  let locations = edges.map(edge => {
    (edge.0, edge.1, prepared.origins[edge.2].location)
  })
  chain_diagnostics(
    prepared.identities,
    location => {
      match owners.get(location_key(location)) {
        Some(owner) if owner >= 0 => Some(owner)
        _ => None
      }
    },
    locations,
    diagnostics,
  )
}

///|
fn chain_diagnostics(
  identities : ReadOnlyArray[PackageIdentity],
  package_at : (Location) -> Int32?,
  edges : Array[(Int32, Int32, Location)],
  diagnostics : Array[Diagnostic],
) -> ReadOnlyArray[Diagnostic] {
  let parent = Array::make(identities.length(), -1)
  let incoming : Array[Location?] = Array::make(identities.length(), None)
  let adjacency : Array[Array[(Int32, Location)]] = []
  for _ in identities {
    adjacency.push([])
  }
  for (from, target, location) in edges {
    adjacency[from].push((target, location))
  }
  let queue = [0]
  parent[0] = 0
  let mut at = 0
  while at < queue.length() {
    let current = queue[at]
    at += 1
    for (target, location) in adjacency[current] {
      if parent[target] < 0 {
        parent[target] = current
        incoming[target] = Some(location)
        queue.push(target)
      }
    }
  }
  let result = []
  for diagnostic in diagnostics {
    let related = diagnostic.related.iter().to_array()
    if package_at(diagnostic.primary.location) is Some(package_index) {
      let mut current = package_index
      let mut steps = 0
      while current != 0 && parent[current] >= 0 && steps < 32 {
        if incoming[current] is Some(location) {
          related.push({
            location,
            message: "required by dependency " +
            identity_key(identities[parent[current]]),
          })
        }
        current = parent[current]
        steps += 1
      }
    }
    result.push({ ..diagnostic, related: ReadOnlyArray::from_array(related), })
  }
  ordered_diagnostics(result)
}

///|
fn loading_diagnostics(
  root : SourcePackage,
  groups : Array[PackageGroup],
  errors : Array[Diagnostic],
) -> ReadOnlyArray[Diagnostic] {
  // Valid headers and structurally safe paths can still explain how a package
  // with syntax errors was requested. This is diagnostic context, never a model.
  if groups.is_empty() ||
    root.documents.is_empty() ||
    groups[0].sections[0] != groups[0].documents[0].ast.nodes.length() - 1 ||
    !groups[0].documents.any(doc => {
      root.documents.any(original => original.id == doc.id)
    }) {
    return ordered_diagnostics(errors)
  }
  let identities = ReadOnlyArray::from_array(
    groups.map(group => group.identity),
  )
  let by_key : Map[String, Int32] = Map([])
  let ranges = PackageRanges::new()
  for i, group in groups {
    by_key[identity_key(group.identity)] = i
    for file_index, doc in group.documents {
      let section = group.sections[file_index]
      if doc.ast.validate() && section >= 0 && section < doc.ast.nodes.length() {
        let node = doc.ast.nodes[section]
        ranges.add(doc.id, node.data, node.span, i)
      }
    }
  }
  ranges.sort()
  let edges : Array[(Int32, Int32, Location)] = []
  let seen : Map[String, Bool] = Map([])
  for group in groups {
    for doc in group.documents {
      if seen.contains(doc.id) || !doc.ast.validate() {
        continue
      }
      seen[doc.id] = true
      for node in doc.ast.nodes {
        if node.data is Path(namespaces~, segments~, version~) &&
          namespaces.length() == 1 &&
          segments.length() >= 2 {
          let key = namespaces[0] +
            ":" +
            segments[0] +
            (match version {
              Some(v) => "@" + v
              None => ""
            })
          let location : Location = Location::text(doc.id, node.span)
          if by_key.get(key) is Some(target) &&
            ranges.owner(location) is Some(from) {
            edges.push((from, target, location))
          }
        }
      }
    }
  }
  chain_diagnostics(
    identities,
    location => ranges.owner(location),
    edges,
    errors,
  )
}

///|
/// Inspect supplied package metadata without claiming semantic verification.
pub fn SourcePackage::identity(
  self : SourcePackage,
) -> Result[PackageIdentity, ReadOnlyArray[Diagnostic]] {
  match prepare(self, []) {
    Ok(prepared) => Ok(prepared.identities[0])
    Err(errors) => Err(errors)
  }
}

///|
pub fn PackageIdentity::key(self : PackageIdentity) -> String {
  identity_key(self)
}

///|
fn ordered_diagnostics(errors : Array[Diagnostic]) -> ReadOnlyArray[Diagnostic] {
  errors.sort_by((a, b) => {
    let source = a.primary.location.source.compare(b.primary.location.source)
    if source != 0 {
      return source
    }
    let position = a.primary.location
      .order_key()
      .compare(b.primary.location.order_key())
    if position != 0 {
      return position
    }
    let code = a.code.compare(b.code)
    if code != 0 {
      return code
    }
    a.message.compare(b.message)
  })
  ReadOnlyArray::from_array(errors)
}

///|
/// Worlds in stable dependency order, with included worlds before their users.
/// Source declaration order breaks ties; encoded worlds retain their input order.
pub fn Resolution::worlds_in_dependency_order(
  self : Resolution,
) -> ReadOnlyArray[ResolvedWorld] {
  let worlds : Map[Int32, ResolvedWorld] = Map([])
  for world in self.model.resolved_worlds {
    worlds[world.id] = world
  }
  let result = []
  for id in self.model.world_dependency_order {
    if worlds.get(id) is Some(world) {
      result.push(world)
    }
  }
  ReadOnlyArray::from_array(result)
}

///|
/// Location of the root package declaration in its original source or binary.
pub fn Resolution::root_location(self : Resolution) -> Location {
  self.root_location
}
