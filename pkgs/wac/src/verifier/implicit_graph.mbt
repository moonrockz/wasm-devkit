///|
fn Check::finish_import_graph(
  self : Check,
  state : ImportTypes,
  groups : Array[ImportGroup],
  order : Array[Int32],
  parents : Array[Int32],
) -> Unit raise SemanticFailure {
  let replacements : Map[Int32, Int32] = Map([])
  let imported : Map[Int32, Int32] = Map([])
  for index, group in groups {
    let first = group.requests[0].value
    imported[first] = index
    for request in group.requests {
      replacements[request.value] = first
    }
  }
  let nodes : Array[CompositionNode] = []
  let mapping : Map[Int32, Int32] = Map([])
  let active : Map[Int32, Bool] = Map([])
  for start in 0..<self.composition_nodes.length() {
    let pending = [(start, false)]
    while pending.pop() is Some((original, finish)) {
      let original = replacements.get(original).unwrap_or(original)
      if mapping.contains(original) {
        continue
      }
      let item = self.composition_nodes[original]
      let node = groups[0].requests[0].node
      self.import_step(state, node)
      if !finish {
        if active.contains(original) {
          raise Problem(
            self.problem(
              node, "WAC-C009", "implicit import aggregation creates a composition cycle",
            ),
          )
        }
        active[original] = true
        pending.push((original, true))
        match item.operation {
          Access(parent, _) => pending.push((parent, false))
          Instantiate(_, _, arguments) =>
            for i = arguments.length() - 1; i >= 0; i = i - 1 {
              pending.push((arguments[i].value, false))
            }
          _ => ()
        }
        continue
      }
      let value = fn(old : Int32) {
        mapping[replacements.get(old).unwrap_or(old)]
      }
      let mut kind = item.kind
      let mut resources = item.resources.map(binding => {
        ..binding,
        identity: import_identity(parents, binding.identity),
      })
      let operation = match item.operation {
        Import(name) =>
          if imported.get(original) is Some(index) {
            let group = groups[index]
            kind = binary_kind_with_id(
              group.kind,
              self.import_type_id(state, node, binary_kind_id(group.kind)),
            )
            resources = group.resources
            Import(group.name)
          } else {
            Import(name)
          }
        Access(parent, name) => {
          let parent = value(parent)
          guard nodes[parent].kind is Instance(ty) &&
            self.types[ty].kind is Interface(_, _, exports) else {
            raise Problem(
              self.problem(
                node, "WAC-C009", "aggregated access no longer has an instance",
              ),
            )
          }
          let mut found : ItemKind? = None
          for item in exports {
            self.import_step(state, node)
            if item.name == name {
              found = Some(item.kind)
              break
            }
          }
          guard found is Some(found) else {
            raise Problem(
              self.problem(
                node,
                "WAC-C009",
                "aggregated instance lacks accessed export `" + name + "`",
              ),
            )
          }
          kind = found
          resources = nodes[parent].resources
          Access(parent, name)
        }
        Instantiate(name, version, arguments) =>
          Instantiate(
            name,
            version,
            arguments.map(argument => {
              ..argument,
              value: value(argument.value),
            }),
          )
        Definition => Definition
      }
      let id = nodes.length()
      mapping[original] = id
      active.remove(original) |> ignore
      nodes.push({ ..item, id, operation, kind, resources, })
    }
  }
  let remap = fn(old : Int32) { mapping[replacements.get(old).unwrap_or(old)] }
  let outputs = self.composition_outputs.map(output => {
    ..output,
    value: remap(output.value),
  })
  self.composition_outputs.clear()
  self.composition_outputs.append(outputs)
  self.composition_nodes.clear()
  self.composition_nodes.append(nodes)
  for consumer in self.instantiation_checks {
    let bindings : Map[Int32, Int32] = Map([])
    for binding in consumer.resources {
      bindings[binding.ty] = import_identity(parents, binding.identity)
    }
    let constraints : Array[ResourceConstraint] = []
    for argument in consumer.arguments {
      let actual = self.composition_nodes[remap(argument.value)]
      let mut expected : ItemKind? = None
      for imported in consumer.imports {
        self.import_step(state, consumer.node)
        if imported.name == argument.name {
          expected = Some(imported.kind)
          break
        }
      }
      guard expected is Some(expected) else {
        raise Problem(
          self.problem(
            consumer.node,
            "WAC-C009",
            "aggregated argument has no expected import",
          ),
        )
      }
      let trace : CompatibilityTrace = {
        types: Map([]),
        binders: [],
        resource_pairs: [],
        steps: 0,
      }
      self.compatible(
        consumer.node,
        {
          kind: actual.kind,
          node: consumer.node,
          external_name: None,
          value: Some(actual.id),
        },
        expected,
        bindings,
        constraints,
        trace=Some(trace),
      )
      state.budget.remaining -= trace.steps
      self.import_step(state, consumer.node)
    }
    for constraint in constraints {
      if bindings.get(constraint.expected) != Some(constraint.actual) {
        raise Problem(
          self.problem(
            consumer.node,
            "WAC-C005",
            "aggregated argument captures a different resource",
          ),
        )
      }
    }
  }
  let scope = self.scopes[0]
  scope.imports.clear()
  for index in order {
    let group = groups[index]
    let item = self.composition_nodes[remap(group.requests[0].value)]
    scope.imports.push({
      name: group.name,
      kind: item.kind,
      location: item.location,
    })
  }
  for output in outputs {
    for i in 0..<scope.exports.length() {
      if scope.exports[i].name == output.name {
        scope.exports[i] = {
          ..scope.exports[i],
          kind: self.composition_nodes[output.value].kind,
        }
      }
    }
  }
  let names = scope.names.keys().to_array()
  names.sort()
  for name in names {
    let item = scope.names[name]
    if item.value is Some(old) {
      let value = remap(old)
      scope.names[name] = {
        ..item,
        kind: self.composition_nodes[value].kind,
        value: Some(value),
      }
    }
  }
  for i in 0..<self.declarations.length() {
    let declaration = self.declarations[i]
    if declaration.scope == 0 && scope.names.get(declaration.name) is Some(item) {
      self.declarations[i] = { ..declaration, kind: item.kind, }
    }
  }
}
