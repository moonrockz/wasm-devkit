///|
pub(all) struct InstantiationArgument {
  name : String
  value : Int32
  location : Location
} derive(Eq, Debug)

///|
pub extend InstantiationArgument with Eq::{equal, not_equal}

///|
pub extend InstantiationArgument with @debug.Debug::{to_repr}

///|
priv struct InstantiationPackage {
  name : String
  version : String?
  world : Int32
  instance : Int32
}

///|
fn Check::instantiation_package(
  self : Check,
  node : Int32,
) -> InstantiationPackage raise SemanticFailure {
  guard self.tree.nodes[node].data is Path(namespaces~, segments~, version~) &&
    !namespaces.is_empty() &&
    segments.length() == 1 &&
    version.map(semantic_version).unwrap_or(true) else {
    raise Problem(
      self.problem(node, "WAC-S001", "invalid instantiation package identity"),
    )
  }
  for part in namespaces {
    self.name(node, part)
  }
  self.name(node, segments[0])
  let name = namespaces.join(":") + ":" + segments[0]
  if name == self.package_name {
    raise Problem(
      self.problem(
        node, "WAC-P005", "cannot instantiate the package being defined",
      ),
    )
  }
  let loaded = self.load_package(node, name, version)
  { name, version, world: loaded.world, instance: loaded.instance, }
}

///|
fn Check::argument_name(
  self : Check,
  node : Int32,
  item : LocalItem,
  expected : ReadOnlyArray[Extern],
) -> String raise SemanticFailure {
  match self.tree.nodes[node].data {
    NamedArgument(name~, ..) => {
      guard self.tree.nodes[name].data is Name(value~, quoted~) else {
        raise Problem(self.problem(name, "WAC-S001", "invalid argument name"))
      }
      if quoted {
        value
      } else {
        self.name(name, value)
        matching_external_name(value, expected)
      }
    }
    InferredArgument(name~) => {
      if item.kind is Instance(id) &&
        self.types[id].kind is Interface(Some(identity), _, _) &&
        expected.any(item => item.name == identity) {
        return identity
      }
      if item.external_name is Some(external) &&
        expected.any(item => item.name == external) {
        return external
      }
      matching_external_name(name, expected)
    }
    _ =>
      raise Problem(
        self.problem(node, "WAC-S001", "invalid instantiation argument role"),
      )
  }
}

///|
fn Check::instantiate(
  self : Check,
  node : Int32,
  component : Int32,
  loaded : InstantiationPackage,
  arguments : ReadOnlyArray[Int32],
  values : Map[Int32, LocalItem],
) -> LocalItem raise SemanticFailure {
  guard self.types[loaded.world].kind is World(_, _, imports, _) else {
    raise Problem(
      self.problem(component, "WAC-S001", "invalid package component type"),
    )
  }
  let named : Array[(String, Int32, LocalItem)] = []
  let seen : Map[String, Int32] = Map([])
  for argument in arguments {
    let item = values[argument]
    let name = self.argument_name(argument, item, imports)
    if seen.get(name) is Some(first) {
      raise Problem(
        self.problem(
          argument,
          "WAC-C003",
          "duplicate instantiation argument `" + name + "`",
          first=Some(first),
        ),
      )
    }
    seen[name] = argument
    named.push((name, argument, item))
  }
  let bindings : Map[Int32, Int32] = Map([])
  let constraints : Array[ResourceConstraint] = []
  let edges : Array[InstantiationArgument] = []
  for entry in named {
    let (name, argument, item) = entry
    let mut expected : ItemKind? = None
    for imported in imports {
      if imported.name == name {
        expected = Some(imported.kind)
        break
      }
    }
    guard expected is Some(expected) else {
      raise Problem(
        self.problem(
          argument,
          "WAC-C003",
          "component has no import named `" + name + "`",
        ),
      )
    }
    self.compatible(argument, item, expected, bindings, constraints)
    guard item.value is Some(value) else {
      raise Problem(
        self.problem(argument, "WAC-S001", "argument has no composition value"),
      )
    }
    edges.push({ name, value, location: self.location(argument), })
  }
  for imported in imports {
    if !seen.contains(imported.name) {
      raise Problem(
        self.problem(
          component,
          "WAC-C004",
          "missing instantiation argument `" + imported.name + "`",
        ),
      )
    }
  }
  for constraint in constraints {
    if bindings.get(constraint.expected) != Some(constraint.actual) {
      let problem = self.problem(
        constraint.node,
        "WAC-C005",
        constraint.context + ": resource types are not the same",
      )
      raise Problem({
        ..problem,
        related: [
          {
            location: self.types[constraint.expected].location,
            message: "expected resource declared here",
          },
        ],
      })
    }
  }
  let (resources, _) = self.resource_parameters(node, Instance(loaded.instance))
  let context : Array[ResourceBinding] = []
  for ty in resources {
    context.push({
      ty,
      identity: match bindings.get(ty) {
        Some(identity) => identity
        None => self.new_resource_identity()
      },
    })
  }
  let value = self.composition_node(
    node,
    Instantiate(loaded.name, loaded.version, ReadOnlyArray::from_array(edges)),
    Instance(loaded.instance),
    resources=Some(ReadOnlyArray::from_array(context)),
  )
  {
    kind: Instance(loaded.instance),
    node,
    external_name: None,
    value: Some(value),
  }
}
