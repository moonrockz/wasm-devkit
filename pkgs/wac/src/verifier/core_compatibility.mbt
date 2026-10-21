///|
fn Check::merge_core_modules(
  self : Check,
  state : ImportTypes,
  node : Int32,
  a : @core_types.Module,
  b : @core_types.Module,
) -> @core_types.Module raise SemanticFailure {
  let matches = fn(
    actual : @core_types.External,
    expected : @core_types.External,
  ) -> Bool raise SemanticFailure {
    match
      @core_types.compare_external(
        actual,
        expected,
        work_limit=state.budget.remaining,
      ) {
      Ok((matches, remaining)) => {
        state.budget.remaining = remaining
        matches
      }
      Err(Mismatch(_)) => false
      Err(WorkLimit) =>
        raise Problem(
          self.problem(
            node, "WAC-C006", "core module aggregation exceeds the verification work limit",
          ),
        )
    }
  }
  let imports : Array[@core_types.Import] = []
  for item in a.imports {
    self.import_step(state, node)
    imports.push(item)
  }
  let import_indices : Map[(String, String), Int32] = Map([])
  for i in 0..<imports.length() {
    self.import_step(state, node)
    import_indices[(imports[i].module_name, imports[i].name)] = i
  }
  for item in b.imports {
    self.import_step(state, node)
    let key = (item.module_name, item.name)
    if import_indices.get(key) is Some(index) {
      let prior = imports[index].kind
      if matches(prior, item.kind) {
        continue
      }
      if !matches(item.kind, prior) {
        raise Problem(
          self.problem(node, "WAC-C009", "incompatible core module imports"),
        )
      }
      imports[index] = item
    } else {
      import_indices[key] = imports.length()
      imports.push(item)
    }
  }
  let exports : Array[@core_types.Export] = []
  for item in a.exports {
    self.import_step(state, node)
    exports.push(item)
  }
  let export_indices : Map[String, Int32] = Map([])
  for i in 0..<exports.length() {
    self.import_step(state, node)
    export_indices[exports[i].name] = i
  }
  for item in b.exports {
    self.import_step(state, node)
    if export_indices.get(item.name) is Some(index) {
      let prior = exports[index].kind
      if matches(item.kind, prior) {
        continue
      }
      if !matches(prior, item.kind) {
        raise Problem(
          self.problem(node, "WAC-C009", "incompatible core module exports"),
        )
      }
      exports[index] = item
    } else {
      export_indices[item.name] = exports.length()
      exports.push(item)
    }
  }
  {
    imports: ReadOnlyArray::from_array(imports),
    exports: ReadOnlyArray::from_array(exports),
  }
}
