///|
/// A verified WAC dependency. Its contract is adapted without encoding or
/// executing its composition. Lookup identity is separate from source identity.
pub(all) struct CompositionPackage {
  name : String
  version : String?
  model : Verified
}

///|
pub(all) struct SourcePackage {
  name : String
  version : String?
  source : String
  text : String
}

///|
fn Check::register_compositions(
  self : Check,
  inputs : ReadOnlyArray[CompositionPackage],
) -> Unit raise SemanticFailure {
  for input in inputs {
    let key = package_key(input.name, input.version)
    if !input.name.split(":").all(p => identifier(p.to_owned())) ||
      !input.name.contains(":") ||
      !input.version.map(semantic_version).unwrap_or(true) {
      raise Problem(
        binary_problem(
          input.model.source(),
          "WAC-P001",
          "invalid WAC package lookup identity",
        ),
      )
    }
    if self.dependencies.contains(key) ||
      self.wit_dependencies.contains(key) ||
      self.compositions.contains(key) {
      raise Problem(
        binary_problem(
          input.model.source(),
          "WAC-P002",
          "duplicate package input `" + key + "`",
        ),
      )
    }
    self.compositions[key] = input
  }
}

///|
fn Check::append_composition(self : Check, model : Verified) -> LoadedPackage {
  let arena = model.types().iter().to_array()
  let location = Location::text(model.source(), { start: 0, end: 0, })
  let world = arena.length()
  arena.push({
    id: world,
    name: None,
    kind: World(None, [], model.imports(), model.exports()),
    location,
  })
  let instance = arena.length()
  arena.push({
    id: instance,
    name: None,
    kind: Interface(None, [], model.exports()),
    location,
  })
  let definitions = model
    .items()
    .iter()
    .filter(item => item.scope == 0 && item.kind is Type(_))
    .map(item => { name: item.name, kind: item.kind, location, })
    .to_array()
  self.append_type_graph(
    ReadOnlyArray::from_array(arena),
    world,
    instance,
    ReadOnlyArray::from_array(definitions),
  )
}

///|
/// Resolve a caller-supplied WAC dependency DAG with an explicit work stack.
/// Missing binary/WIT dependencies use the usual verifier diagnostics. Cycles
/// and duplicate lookup keys fail before a partial package list can escape.
pub fn resolve_composition_packages(
  inputs : ReadOnlyArray[SourcePackage],
  dependencies~ : ReadOnlyArray[PackageSource] = [],
  wit_dependencies~ : ReadOnlyArray[WitPackageSource] = [],
) -> Result[ReadOnlyArray[CompositionPackage], ReadOnlyArray[Diagnostic]] {
  if inputs.length() > 10000 {
    return Err([
      binary_problem(
        "<packages>", "WAC-P008", "WAC dependency closure exceeds 10000 packages",
      ),
    ])
  }
  let mut remaining = 1000000
  let indexed : Map[String, Int32] = Map([])
  let parsed : Array[@parser.Parse] = []
  let requests : Array[ReadOnlyArray[PackageRequest]] = []
  for i, input in inputs {
    let key = package_key(input.name, input.version)
    if indexed.contains(key) {
      return Err([
        binary_problem(
          input.source,
          "WAC-P002",
          "duplicate WAC package input `" + key + "`",
        ),
      ])
    }
    indexed[key] = i
    let syntax = @parser.parse(input.text)
    parsed.push(syntax)
    match package_requests(syntax, source=input.text, source_id=input.source) {
      Ok(value) => requests.push(value)
      Err(errors) => return Err(errors)
    }
  }
  let state : Array[Int32] = Array::make(inputs.length(), 0)
  let work : Array[(Int32, Bool)] = []
  let resolved : Array[CompositionPackage] = []
  for i in 0..<inputs.length() {
    work.push((i, false))
    while work.pop() is Some((index, finish)) {
      let input = inputs[index]
      if finish {
        let model = match
          verify(
            parsed[index],
            source_id=input.source,
            source=input.text,
            dependencies~,
            wit_dependencies~,
            compositions=ReadOnlyArray::from_array(resolved.copy()),
          ) {
          Ok(model) => model
          Err(errors) => return Err(errors)
        }
        if model.types().length() > remaining {
          return Err([
            binary_problem(
              input.source,
              "WAC-P008",
              "WAC dependency type graphs exceed the resolution work limit",
            ),
          ])
        }
        remaining -= model.types().length()
        resolved.push({ name: input.name, version: input.version, model, })
        state[index] = 2
      } else {
        if state[index] == 2 {
          continue
        }
        if state[index] == 1 {
          return Err([
            binary_problem(
              input.source,
              "WAC-P007",
              "cyclic WAC package dependency",
            ),
          ])
        }
        state[index] = 1
        work.push((index, true))
        for request in requests[index] {
          if indexed.get(package_key(request.name, request.version))
            is Some(child) {
            work.push((child, false))
          }
        }
      }
    }
  }
  Ok(ReadOnlyArray::from_array(resolved))
}
