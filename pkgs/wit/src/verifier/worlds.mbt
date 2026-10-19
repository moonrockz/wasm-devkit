///|
priv struct WorldTables {
  uses : Map[Int32, Array[(Int32, Int32)]]
  imports : Map[Int32, Array[WorldItem]]
  exports : Map[Int32, Array[WorldItem]]
  import_names : Map[Int32, Map[String, WorldItem]]
  export_names : Map[Int32, Map[String, WorldItem]]
}

///|
fn WorldTables::new() -> WorldTables {
  {
    uses: Map([]),
    imports: Map([]),
    exports: Map([]),
    import_names: Map([]),
    export_names: Map([]),
  }
}

///|
fn WorldTables::init(self : WorldTables, owner : Int32) -> Unit {
  self.uses[owner] = []
  self.imports[owner] = []
  self.exports[owner] = []
  self.import_names[owner] = Map([])
  self.export_names[owner] = Map([])
}

///|
fn world_key(item : WorldItem) -> String {
  if item.by_id {
    match item.kind {
      Interface(id) => "interface:\{id}"
      _ => "name:" + item.name
    }
  } else {
    "name:" + component_name_key(item.name)
  }
}

///|
fn WorldTables::add(
  self : WorldTables,
  prepared : Prepared,
  owner : Int32,
  imported : Bool,
  item : WorldItem,
  at : Int32,
  merge : Bool,
  errors : Array[Diagnostic],
  include_external~ : Bool? = None,
) -> Unit {
  let items = if imported { self.imports[owner] } else { self.exports[owner] }
  let names = if imported {
    self.import_names[owner]
  } else {
    self.export_names[owner]
  }
  let key = world_key(item)
  let item = if include_external is Some(external) && item.by_id {
    let previous = names.get(key)
    let into = previous.map(entry => entry.stability).unwrap_or(item.stability)
    let stability = if external && item.stability is Stable(_, _) {
      Unknown
    } else if item.stability == Unknown || item.stability == into {
      into
    } else if into == Unknown {
      item.stability
    } else {
      errors.push(
        prepared_error(
          prepared, at, "WIT-S013", "included interface stability annotations disagree",
        ),
      )
      into
    }
    if previous is Some(entry) {
      let updated = { ..entry, stability, }
      names[key] = updated
      for index, candidate in items {
        if world_key(candidate) == key {
          items[index] = updated
          break
        }
      }
      return
    }
    { ..item, stability, }
  } else {
    item
  }
  if names.get(key) is Some(previous) {
    if merge && item.by_id && previous.by_id && item.kind == previous.kind {
      return
    }
    let d = prepared_error(
      prepared,
      at,
      "WIT-S004",
      "conflicting world " +
      (if imported { "import" } else { "export" }) +
      " `" +
      item.name +
      "`",
    )
    errors.push({
      ..d,
      related: [
        { location: previous.location, message: "first declared here", },
        {
          location: item.location,
          message: "conflicting item originates here",
        },
      ],
    })
  } else {
    names[key] = item
    items.push(item)
  }
}

///|
fn Prepared::interface_name(self : Prepared, id : Int32) -> String {
  let identity = self.identities[self.node_packages[id]]
  let name = declaration(self.tree.nodes[id].data).unwrap_or("")
  identity.namespace_name +
  ":" +
  identity.name +
  "/" +
  name +
  (match identity.version {
    Some(v) => "@" + v
    None => ""
  })
}

///|
fn collect_file_aliases(
  prepared : Prepared,
  scopes : Array[Map[String, Int32]],
  bindings : Array[Binding],
  package_edges : Array[(Int32, Int32, Int32)],
  foreign_kinds : Map[String, (String, Int32)],
  errors : Array[Diagnostic],
) -> Map[String, Map[String, Int32]] {
  let aliases : Map[String, Map[String, Int32]] = Map([])
  for root in prepared.roots {
    let source = prepared.alias_scope(root)
    let names : Map[String, Int32] = Map([])
    let seen : Map[String, Int32] = Map([])
    aliases[source] = names
    let items = section_items(prepared.tree.nodes[root].data)
    for item in items {
      if declaration(prepared.tree.nodes[item].data) is Some(name) {
        seen[name] = item
      }
    }
    for item in items {
      guard prepared.tree.nodes[item].data
        is Use(path~, names=selectors, renamed~, attributes~) else {
        continue
      }
      if !selectors.is_empty() {
        errors.push(
          prepared_error(
            prepared, item, "WIT-S001", "top-level use cannot select types",
          ),
        )
      }
      if !attributes.is_empty() {
        errors.push(
          prepared_error(
            prepared, item, "WIT-S007", "attributes cannot annotate top-level use",
          ),
        )
      }
      let introduced = match prepared.tree.nodes[path].data {
        Path(segments~, ..) =>
          renamed.unwrap_or(
            if segments.is_empty() {
              ""
            } else {
              segments[segments.length() - 1]
            },
          )
        _ => ""
      }
      if !identifier(introduced) {
        errors.push(
          prepared_error(
            prepared, item, "WIT-S001", "invalid interface/world alias name",
          ),
        )
      }
      if seen.get(introduced) is Some(previous) {
        let d = prepared_error(
          prepared,
          item,
          "WIT-S004",
          "duplicate file-local name `" + introduced + "`",
        )
        errors.push({
          ..d,
          related: [
            {
              location: prepared.origins[previous].location,
              message: "first declared here",
            },
          ],
        })
      } else {
        seen[introduced] = item
      }
      // Top-level aliases refer to direct declarations, never another alias.
      let expected = match prepared.foreign_key(path) {
        Some(key) =>
          foreign_kinds.get(key).map(entry => entry.0).unwrap_or("item")
        None => "item"
      }
      match prepared.find_item(scopes, path, expected) {
        Err(d) => errors.push(d)
        Ok((target, external)) => {
          names[introduced] = target
          bindings.push({
            name: introduced,
            scope: prepared.node_packages[root],
            node: item,
            target,
          })
          if external {
            package_edges.push(
              (
                prepared.node_packages[path],
                prepared.node_packages[target],
                path,
              ),
            )
          }
        }
      }
    }
  }
  aliases
}

///|
fn expand_worlds(
  prepared : Prepared,
  tables : WorldTables,
  includes : Array[(Int32, Int32, Int32, ReadOnlyArray[Int32])],
  arena : SemanticArena,
  edges : Array[(Int32, Int32, Int32)],
  stabilities : ReadOnlyArray[StabilityInfo],
  errors : Array[Diagnostic],
) -> Unit {
  let adjacency : Map[Int32, Array[(Int32, Int32, ReadOnlyArray[Int32])]] = Map([],
  )
  let dependencies : Map[Int32, Array[(Int32, Int32)]] = Map([])
  for id, node in prepared.tree.nodes {
    if node.data is World(..) {
      adjacency[id] = []
    }
    if node.data is Interface(..) {
      dependencies[id] = []
    }
  }
  for (owner, target, at, renames) in includes {
    adjacency[owner].push((target, at, renames))
  }
  for (owner, target, at) in edges {
    if prepared.tree.nodes[owner].data is Interface(..) {
      dependencies[owner].push((target, at))
    }
  }
  let done : Map[Int32, Bool] = Map([])
  for id, node in prepared.tree.nodes {
    if !(node.data is World(..)) {
      continue
    }
    let pending = [(id, false)]
    while pending.pop() is Some((owner, leaving)) {
      if done.contains(owner) {
        continue
      }
      if !leaving {
        pending.push((owner, true))
        for i = adjacency[owner].length() - 1; i >= 0; i = i - 1 {
          pending.push((adjacency[owner][i].0, false))
        }
        continue
      }
      for (target, at, selectors) in adjacency[owner] {
        let replacements : Map[String, (String, Int32)] = Map([])
        let used : Map[String, Bool] = Map([])
        for selector in selectors {
          guard prepared.tree.nodes[selector].data
            is Rename(name~, renamed=Some(replacement)) else {
            errors.push(
              prepared_error(
                prepared, selector, "WIT-S001", "include rename requires an original and replacement name",
              ),
            )
            continue
          }
          if !identifier(name) || !identifier(replacement) {
            errors.push(
              prepared_error(
                prepared, selector, "WIT-S001", "invalid include rename",
              ),
            )
          }
          if replacements.contains(name) {
            errors.push(
              prepared_error(
                prepared,
                selector,
                "WIT-S004",
                "duplicate include rename `" + name + "`",
              ),
            )
          }
          replacements[name] = (replacement, selector)
        }
        let (imports, exports) = arena.copy_world(
          prepared,
          target,
          owner,
          tables.imports[target],
          tables.exports[target],
          replacements,
          dependencies,
        )
        for imported in [true, false] {
          let items = if imported { imports } else { exports }
          let originals = if imported {
            tables.imports[target]
          } else {
            tables.exports[target]
          }
          for index, copied in items {
            let original = originals[index]
            let subject = include_rename_subject(original.name)
            if !original.by_id && replacements.contains(subject) {
              used[subject] = true
            }
            tables.add(
              prepared,
              owner,
              imported,
              copied,
              at,
              true,
              errors,
              include_external=Some(
                prepared.node_packages[target] != prepared.node_packages[owner],
              ),
            )
          }
        }
        for selector in selectors {
          if prepared.tree.nodes[selector].data is Rename(name~, ..) &&
            !used.contains(name) {
            errors.push(
              prepared_error(
                prepared,
                selector,
                "WIT-S005",
                "no named import or export `" +
                name +
                "`; interface IDs cannot be renamed",
              ),
            )
          }
        }
      }
      elaborate_world(
        prepared, tables, owner, dependencies, stabilities, errors,
      )
      done[owner] = true
    }
  }
}

///|
fn implicit_interface(
  prepared : Prepared,
  id : Int32,
  at : Int32,
  stability : Stability,
  external_id~ : String? = None,
) -> WorldItem {
  {
    stability,
    external_id,
    name: prepared.interface_name(id),
    kind: Interface(id),
    by_id: true,
    location: prepared.origins[at].location,
  }
}

///|
fn elaborate_world(
  prepared : Prepared,
  tables : WorldTables,
  owner : Int32,
  dependencies : Map[Int32, Array[(Int32, Int32)]],
  stabilities : ReadOnlyArray[StabilityInfo],
  errors : Array[Diagnostic],
) -> Unit {
  let imports = tables.imports[owner].copy()
  let exports = tables.exports[owner].copy()
  tables.imports[owner] = []
  tables.import_names[owner] = Map([])
  tables.exports[owner] = []
  tables.export_names[owner] = Map([])
  let add_import = fn(initial : WorldItem) {
    let work = [(initial, false)]
    while work.pop() is Some((item, leaving)) {
      if tables.import_names[owner].contains(world_key(item)) {
        continue
      }
      if leaving {
        tables.add(prepared, owner, true, item, owner, true, errors)
        continue
      }
      work.push((item, true))
      if item.kind is Interface(id) {
        for i = dependencies[id].length() - 1; i >= 0; i = i - 1 {
          let (dep, at) = dependencies[id][i]
          work.push(
            (implicit_interface(prepared, dep, at, item.stability), false),
          )
        }
      }
    }
  }
  for item in imports {
    if item.kind is Interface(_) {
      add_import(item)
    }
  }
  for (target, at) in tables.uses[owner] {
    add_import(implicit_interface(prepared, target, at, stabilities[at].value))
  }
  for item in imports {
    if !(item.kind is Interface(_)) {
      tables.add(prepared, owner, true, item, owner, false, errors)
    }
  }
  let export_interfaces : Map[String, WorldItem] = Map([])
  for item in exports {
    if item.kind is Interface(_) {
      export_interfaces[world_key(item)] = item
    } else {
      tables.add(prepared, owner, false, item, owner, false, errors)
    }
  }
  let required_imports : Map[Int32, Bool] = Map([])
  for item in exports {
    if !(item.kind is Interface(_)) {
      continue
    }
    let work = [(item, true, false)]
    while work.pop() is Some((item, exporting, leaving)) {
      guard item.kind is Interface(id) else { continue }
      let key = world_key(item)
      if !leaving {
        if tables.export_names[owner].contains(key) {
          if !exporting {
            let d = error_at(
              item.location,
              "WIT-S012",
              "interface required as both an imported and exported dependency",
            )
            errors.push({
              ..d,
              related: [
                {
                  location: tables.export_names[owner][key].location,
                  message: "exported dependency is here",
                },
              ],
            })
          }
          continue
        }
        if !exporting && required_imports.contains(id) {
          continue
        }
        work.push((item, exporting, true))
        for i = dependencies[id].length() - 1; i >= 0; i = i - 1 {
          let (dep, at) = dependencies[id][i]
          let dependency = implicit_interface(
            prepared,
            dep,
            at,
            item.stability,
            external_id=item.external_id,
          )
          let exporting = exporting &&
            export_interfaces.contains(world_key(dependency))
          work.push((dependency, exporting, false))
        }
      } else if exporting {
        if required_imports.contains(id) {
          let d = error_at(
            item.location,
            "WIT-S012",
            "interface transitively required as an import conflicts with its export",
          )
          errors.push({
            ..d,
            related: [
              {
                location: prepared.origins[owner].location,
                message: "while elaborating this world",
              },
            ],
          })
        } else {
          tables.add(prepared, owner, false, item, owner, true, errors)
        }
      } else {
        required_imports[id] = true
        tables.add(prepared, owner, true, item, owner, true, errors)
      }
    }
  }
  // Interfaces precede types and functions. Preserve dependency order within a class.
  let ordered = []
  for item in tables.imports[owner] {
    if item.kind is Interface(_) {
      ordered.push(item)
    }
  }
  for item in tables.imports[owner] {
    if item.kind is Type(_) {
      ordered.push(item)
    }
  }
  for item in tables.imports[owner] {
    if item.kind is Function(_) {
      ordered.push(item)
    }
  }
  tables.imports[owner] = ordered
}

///|
fn qualified_item(identity : PackageIdentity, name : String) -> String {
  identity.namespace_name +
  ":" +
  identity.name +
  "/" +
  name +
  (match identity.version {
    Some(v) => "@" + v
    None => ""
  })
}

///|
/// Omit a name to require exactly one world in the root package. Short names
/// select root worlds. Qualified package/interface IDs select across the closure.
pub fn Verified::select_world(
  self : Verified,
  name~ : String? = None,
) -> Result[ResolvedWorld, ReadOnlyArray[Diagnostic]] {
  self
  .semantic_model()
  .select_world(
    {
      source: self.source_id,
      position: SourceSpan(self.tree.nodes[self.tree.nodes.length() - 1].span),
    },
    name~,
  )
}

///|
fn SemanticModel::select_world(
  self : SemanticModel,
  at : Location,
  name~ : String? = None,
) -> Result[ResolvedWorld, ReadOnlyArray[Diagnostic]] {
  let candidates = self.resolved_worlds.filter(world => {
    match name {
      None => world.package_identity == self.package_identity
      Some(selector) =>
        if selector.contains("/") {
          qualified_item(world.package_identity, world.name) == selector
        } else if selector.contains(":") {
          world.package_identity.key() == selector
        } else {
          world.package_identity == self.package_identity &&
          world.name == selector
        }
    }
  })
  if candidates.length() == 1 {
    return Ok(candidates[0])
  }
  let d = error_at(
    at,
    if candidates.is_empty() {
      "WIT-S005"
    } else {
      "WIT-S010"
    },
    if candidates.is_empty() {
      "unknown world " + name.unwrap_or("in root package")
    } else {
      "ambiguous world selection; select a world by name"
    },
  )
  let related = []
  for i in 0..<candidates.length().min(32) {
    related.push({
      location: candidates[i].location,
      message: "candidate " +
      qualified_item(candidates[i].package_identity, candidates[i].name),
    })
  }
  Err([{ ..d, related: ReadOnlyArray::from_array(related), }])
}

///|
pub fn Resolution::select_world(
  self : Resolution,
  name~ : String? = None,
) -> Result[ResolvedWorld, ReadOnlyArray[Diagnostic]] {
  self.model.select_world(self.root_location, name~)
}

///|
/// A bounded, arena-independent summary of world keys, item kinds and named
/// interface/resource identities. Type/function bodies remain in typed APIs.
pub fn Verified::world_summary(self : Verified) -> Json {
  self.semantic_model().world_summary()
}

///|
fn SemanticModel::world_summary(self : SemanticModel) -> Json {
  let identities : Map[Int32, String] = Map([])
  for interface_ in self.resolved_interfaces {
    identities[interface_.id] = match interface_.name {
      Some(name) => qualified_item(interface_.package_identity, name)
      None => "inline"
    }
  }
  let scopes : Map[Int32, String] = Map([])
  for interface_ in self.resolved_interfaces {
    if interface_.name is Some(name) {
      scopes[interface_.id] = qualified_item(interface_.package_identity, name)
    }
  }
  for world in self.resolved_worlds {
    let qualified = qualified_item(world.package_identity, world.name)
    scopes[world.id] = qualified
    for imported in [true, false] {
      for item in (if imported { world.imports } else { world.exports }) {
        if item.kind is Interface(id) && identities[id] == "inline" {
          scopes[id] = qualified +
            (if imported { "/import:" } else { "/export:" }) +
            item.name
        }
      }
    }
  }
  let types : Map[Int32, ResolvedType] = Map([])
  for ty in self.resolved_types {
    types[ty.id] = ty
  }
  let roots : Map[Int32, Int32] = Map([])
  for ty in self.resolved_types {
    let mut id = ty.id
    let path = []
    while !roots.contains(id) {
      path.push(id)
      match types[id].kind {
        Alias(target) => id = target
        _ => {
          roots[id] = id
          break
        }
      }
    }
    let root = roots[id]
    for id in path {
      roots[id] = root
    }
  }
  let resource = fn(id : Int32) -> String? {
    let ty = types[roots[id]]
    if ty.kind is Resource {
      Some(scopes[ty.scope] + "#" + ty.name.unwrap_or("resource"))
    } else {
      None
    }
  }
  let interface_resources : Map[Int32, Json] = Map([])
  for interface_ in self.resolved_interfaces {
    let resources : Map[String, Json] = Map([])
    for ty in interface_.types {
      if resource(ty.ty) is Some(identity) {
        resources[ty.name] = Json::string(identity)
      }
    }
    if !resources.is_empty() {
      interface_resources[interface_.id] = Json::object(resources)
    }
  }
  let worlds : Map[String, Json] = Map([])
  for world in self.resolved_worlds {
    let imports : Map[String, Json] = Map([])
    let exports : Map[String, Json] = Map([])
    for imported in [true, false] {
      let fields = if imported { imports } else { exports }
      let items = if imported { world.imports } else { world.exports }
      for item in items {
        let kind = match item.kind {
          Interface(id) =>
            match interface_resources.get(id) {
              Some(resources) =>
                Json::object({
                  "interface": Json::string(identities[id]),
                  "resources": resources,
                })
              None =>
                Json::object({ "interface": Json::string(identities[id]) })
            }
          Type(id) => {
            let ty = types[roots[id]]
            if ty.kind is Resource {
              Json::object({
                "type": Json::boolean(true),
                "resource": Json::string(
                  scopes[ty.scope] + "#" + ty.name.unwrap_or("resource"),
                ),
              })
            } else {
              Json::object({ "type": Json::boolean(true) })
            }
          }
          Function(_) => Json::object({ "function": Json::boolean(true) })
        }
        fields[item.name] = kind
      }
    }
    worlds[qualified_item(world.package_identity, world.name)] = Json::object({
      "imports": Json::object(imports),
      "exports": Json::object(exports),
    })
  }
  Json::object(worlds)
}

///|
pub fn Resolution::world_summary(self : Resolution) -> Json {
  self.model.world_summary()
}
