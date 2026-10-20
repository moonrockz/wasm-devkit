///|
/// A caller-supplied dependency. Lookup identity is independent of the encoded
/// interface identities. Versioned and unversioned keys are distinct.
pub(all) struct PackageSource {
  name : String
  version : String?
  source : String
  bytes : Bytes
} derive(Eq, Debug)

///|
pub extend PackageSource with Eq::{equal, not_equal}

///|
pub extend PackageSource with @debug.Debug::{to_repr}

///|
priv struct LoadedPackage {
  world : Int32
  instance : Int32
  definitions : ReadOnlyArray[Extern]
}

///|
fn package_key(name : String, version : String?) -> String {
  name + version.map(value => "@" + value).unwrap_or("")
}

///|
fn Check::register_packages(
  self : Check,
  dependencies : ReadOnlyArray[PackageSource],
) -> Unit raise SemanticFailure {
  for input in dependencies {
    let parts = input.name.split(":").to_array()
    guard parts.length() >= 2 &&
      parts.all(part => identifier(part.to_owned())) &&
      input.version.map(semantic_version).unwrap_or(true) else {
      raise Problem(
        binary_problem(
          input.source,
          "WAC-P001",
          "invalid package lookup identity",
        ),
      )
    }
    let key = package_key(input.name, input.version)
    if self.dependencies.get(key) is Some(first) {
      let problem = binary_problem(
        input.source,
        "WAC-P002",
        "duplicate package input `" + key + "`",
      )
      raise Problem({
        ..problem,
        related: [
          {
            location: Location::binary(first.source),
            message: "first package input",
          },
        ],
      })
    }
    self.dependencies[key] = input
  }
}

///|
// Binary type arenas can contain forward references. Populate all slots, then
// propagate borrow containment through value edges with an explicit work queue.
fn Check::append_package(self : Check, model : BinaryPackage) -> LoadedPackage {
  self.append_type_graph(
    model.arena,
    model.world_type,
    model.instance_type,
    model.defined_items,
  )
}

///|
fn Check::append_type_graph(
  self : Check,
  arena : ReadOnlyArray[ResolvedType],
  world_type : Int32,
  instance_type : Int32,
  defined_items : ReadOnlyArray[Extern],
) -> LoadedPackage {
  let base = self.types.length()
  let ids : Map[Int32, Int32] = Map([])
  for ty in arena {
    ids[ty.id] = base + ty.id
  }
  let parents : Array[Array[Int32]] = Array::makei(arena.length(), _ => [])
  let pending : Array[Int32] = []
  for ty in arena {
    self.types.push({
      ..ty,
      id: base + ty.id,
      kind: binary_remap(ty.kind, ids),
    })
    self.borrowed.push(ty.kind is Borrow(_))
    if ty.kind is Borrow(_) {
      pending.push(ty.id)
    }
    match ty.kind {
      Alias(_)
      | List(_)
      | FixedList(_, _)
      | Map(_, _)
      | Tuple(_)
      | Option(_)
      | Result(_, _)
      | Future(_)
      | Stream(_)
      | Record(_)
      | Variant(_) =>
        for child in binary_children(ty.kind) {
          parents[child].push(ty.id)
        }
      _ => ()
    }
  }
  while pending.pop() is Some(child) {
    for parent in parents[child] {
      if !self.borrowed[base + parent] {
        self.borrowed[base + parent] = true
        pending.push(parent)
      }
    }
  }
  {
    world: base + world_type,
    instance: base + instance_type,
    definitions: defined_items.map(item => {
      ..item,
      kind: binary_kind_with_id(item.kind, base + binary_kind_id(item.kind)),
    }),
  }
}

///|
fn Check::load_package(
  self : Check,
  node : Int32,
  name : String,
  version : String?,
) -> LoadedPackage raise SemanticFailure {
  let key = package_key(name, version)
  if self.loaded_packages.get(key) is Some(model) {
    return model
  }
  let result = if self.dependencies.get(key) is Some(input) {
    decode_component_package(input.bytes, source_id=input.source).map(model => {
      self.append_package(model)
    })
  } else if self.compositions.get(key) is Some(input) {
    Ok(self.append_composition(input.model))
  } else if self.wit_dependencies.get(key) is Some(input) {
    resolve_wit_package(input.root, dependencies=input.dependencies).map(model => {
      self.append_type_graph(
        model.arena,
        model.world_type,
        model.instance_type,
        model.defined_items,
      )
    })
  } else {
    raise Problem(
      self.problem(node, "WAC-P003", "unknown package `" + key + "`"),
    )
  }
  let loaded = match result {
    Ok(model) => model
    Err(errors) => {
      let problem = errors[0]
      let related : Array[Label] = []
      for label in problem.related {
        related.push(label)
      }
      related.push({
        location: self.location(node),
        message: "package `" + key + "` requested here",
      })
      raise Problem({ ..problem, related: ReadOnlyArray::from_array(related), })
    }
  }
  self.loaded_packages[key] = loaded
  loaded
}

///|
fn Check::path_export(
  self : Check,
  node : Int32,
  kind : ItemKind,
  name : String,
) -> ItemKind raise SemanticFailure {
  let mut id = binary_kind_id(kind)
  for _ in 0..<self.types.length() {
    if self.types[id].kind is Alias(next) {
      id = next
    } else {
      break
    }
  }
  let exports = match self.types[id].kind {
    Interface(_, _, exports) | World(_, _, _, exports) => exports
    _ => []
  }
  for item in exports {
    if item.name == name {
      return item.kind
    }
  }
  raise Problem(
    self.problem(node, "WAC-P004", "package path has no export `" + name + "`"),
  )
}

///|
fn Check::package_path(
  self : Check,
  node : Int32,
  namespaces : ReadOnlyArray[String],
  segments : ReadOnlyArray[String],
  version : String?,
) -> LocalItem raise SemanticFailure {
  guard segments.length() >= 2 && version.map(semantic_version).unwrap_or(true) else {
    raise Problem(self.problem(node, "WAC-S001", "invalid package path"))
  }
  for part in namespaces {
    self.name(node, part)
  }
  for part in segments {
    self.name(node, part)
  }
  let name = namespaces.join(":") + ":" + segments[0]
  let mut kind = if name == self.package_name {
    // Like the pinned resolver, self paths use local ordered scope regardless
    // of a supplied version and never request a dependency with the same name.
    self.lookup(0, node, segments[1]).kind
  } else {
    let loaded = self.load_package(node, name, version)
    let mut found : ItemKind? = None
    for item in loaded.definitions {
      if item.name == segments[1] {
        found = Some(item.kind)
        break
      }
    }
    guard found is Some(kind) else {
      raise Problem(
        self.problem(
          node,
          "WAC-P004",
          "package `" + name + "` has no definition `" + segments[1] + "`",
        ),
      )
    }
    kind
  }
  for i in 2..<segments.length() {
    kind = self.path_export(node, kind, segments[i])
  }
  { kind, node, external_name: None, value: None, }
}
