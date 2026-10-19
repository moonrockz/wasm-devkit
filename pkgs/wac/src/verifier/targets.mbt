///|
fn Check::target_uses(
  self : Check,
  path : Int32,
  uses : ReadOnlyArray[UsedType],
  imports : Map[String, Extern],
) -> Unit raise SemanticFailure {
  for used in uses {
    guard self.types[used.interface].kind is Interface(Some(name), _, _) else {
      raise Problem(
        self.problem(path, "WAC-T001", "target use requires a named interface"),
      )
    }
    imports[name] = {
      name,
      kind: Instance(used.interface),
      location: used.location,
    }
  }
}

///|
fn Check::target_error(
  self : Check,
  path : Int32,
  world : Int32,
  location : Location,
  code : String,
  message : String,
) -> Diagnostic {
  {
    code,
    message,
    primary: { location, message, },
    related: [
      { location: self.location(path), message: "target selected here", },
      {
        location: self.types[world].location,
        message: "target world declared here",
      },
    ],
  }
}

///|
fn Check::target_item(
  self : Check,
  path : Int32,
  world : Int32,
  value : Int32,
  actual : Extern,
  expected : Extern,
  context : Map[Int32, Int32],
  variables : Map[Int32, Bool],
  state : TargetResources,
  importing : Bool,
) -> Unit raise SemanticFailure {
  let actual_context : Map[Int32, Int32] = Map([])
  for binding in self.composition_nodes[value].resources {
    actual_context[binding.ty] = binding.identity
  }
  let actual_kind = self.target_scoped_kind(
    path,
    actual.kind,
    actual_context,
    state,
    true,
    Map([]),
  )
  let expected_kind = self.target_scoped_kind(
    path,
    self.promote(expected.kind),
    context,
    state,
    false,
    variables,
  )
  let trace : CompatibilityTrace = {
    types: Map([]),
    binders: [],
    resource_pairs: [],
    steps: state.steps,
  }
  let kind = if importing { "import" } else { "export" }
  self.compatible(
    path,
    {
      kind: actual_kind,
      node: path,
      external_name: Some(actual.name),
      value: Some(value),
    },
    expected_kind,
    Map([]),
    [],
    reverse=importing,
    nominal=false,
    trace=Some(trace),
  ) catch {
    Problem(problem) => {
      let message = "target " +
        kind +
        " `" +
        actual.name +
        "`: " +
        problem.message
      let related = [
        { location: self.location(path), message: "target selected here", },
        {
          location: self.types[world].location,
          message: "target world declared here",
        },
      ]
      for label in problem.related {
        related.push(label)
      }
      raise Problem({
        code: if problem.code == "WAC-C006" {
          problem.code
        } else {
          "WAC-T003"
        },
        message,
        primary: { location: actual.location, message, },
        related: ReadOnlyArray::from_array(related),
      })
    }
  }
  state.steps = trace.steps
  self.target_resource_pairs(
    path,
    world,
    actual_context,
    actual.location,
    trace.resource_pairs,
    context,
    variables,
    state,
    importing,
  )
}

///|
// Resolve the directive after declarations and finalized implicit imports. The
// pinned source resolver matches exact names; its separate binary target checker
// has a broader semver lookup policy.
fn Check::verify_target(self : Check) -> Unit raise SemanticFailure {
  guard self.tree.nodes[self.tree.nodes.length() - 1].data
    is File(directive=Some(directive), ..) &&
    self.tree.nodes[directive].data is Package(targets=Some(path), ..) else {
    return
  }
  let item = self.local_path(path)
  guard item.kind is Type(world) &&
    self.types[world].kind is World(_, uses, declared_imports, exports) else {
    raise Problem(
      self.problem(path, "WAC-T001", "target must name a world type"),
    )
  }
  let saved_types = self.types.length()
  let saved_resources = self.next_resource_identity
  let imports : Map[String, Extern] = Map([])
  self.target_uses(path, uses, imports)
  for imported in declared_imports {
    if imported.kind is Instance(id) &&
      self.types[id].kind is Interface(_, uses, _) {
      self.target_uses(path, uses, imports)
    }
  }
  for imported in declared_imports {
    if !imports.contains(imported.name) {
      imports[imported.name] = imported
    }
  }
  let state : TargetResources = {
    globals: Map([]),
    actual: Map([]),
    outputs: Map([]),
    pending: [],
    next: 0,
    steps: 0,
  }
  let contexts = self.target_import_contexts(path, imports, state)
  let import_values : Map[String, Int32] = Map([])
  for node in self.composition_nodes {
    if node.operation is Import(name) {
      import_values[name] = node.id
    }
  }
  let export_values : Map[String, CompositionExport] = Map([])
  for exported in self.composition_outputs {
    export_values[exported.name] = exported
  }
  for actual in self.scopes[0].imports {
    guard imports.get(actual.name) is Some(expected) else {
      raise Problem(
        self.target_error(
          path,
          world,
          actual.location,
          "WAC-T001",
          "target has no import named `" + actual.name + "`",
        ),
      )
    }
    guard import_values.get(actual.name) is Some(value) else {
      raise Problem(
        self.problem(path, "WAC-S001", "target import has no composition value"),
      )
    }
    self.target_item(
      path,
      world,
      value,
      actual,
      expected,
      contexts[actual.name],
      Map([]),
      state,
      true,
    )
  }
  for expected in exports {
    guard export_values.get(expected.name) is Some(exported) else {
      raise Problem(
        self.target_error(
          path,
          world,
          self.location(path),
          "WAC-T002",
          "target requires an export named `" + expected.name + "`",
        ),
      )
    }
    let value = exported.value
    let actual : Extern = {
      name: exported.name,
      kind: self.composition_nodes[value].kind,
      location: exported.location,
    }
    let (context, variables) = self.target_export_context(
      path,
      expected.kind,
      state,
    )
    self.target_item(
      path, world, value, actual, expected, context, variables, state, false,
    )
  }
  for equation in state.pending {
    let expected = match state.outputs.get(equation.expected) {
      Some(id) => Some(id)
      None => if equation.variable { None } else { Some(equation.expected) }
    }
    if expected is None || state.actual.get(equation.actual) != expected {
      raise Problem(
        self.target_error(
          path,
          world,
          equation.location,
          "WAC-T003",
          "target resource identities do not match",
        ),
      )
    }
  }
  while self.types.length() > saved_types {
    self.types.pop() |> ignore
    self.borrowed.pop() |> ignore
  }
  self.next_resource_identity = saved_resources
}
