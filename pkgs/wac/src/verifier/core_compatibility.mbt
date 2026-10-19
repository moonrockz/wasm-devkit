///|
fn core_limits_match(
  ai : UInt64,
  am : UInt64?,
  bi : UInt64,
  bm : UInt64?,
) -> Bool {
  if ai < bi {
    return false
  }
  match (am, bm) {
    (Some(a), Some(b)) => a <= b
    (None, Some(_)) => false
    _ => true
  }
}

///|
fn core_external_work(value : @core_types.External) -> Int32 {
  match value {
    Func(f) | Tag(f) => f.params.length() + f.results.length() + 1
    _ => 1
  }
}

///|
fn core_external_matches(
  a : @core_types.External,
  b : @core_types.External,
) -> Bool {
  match (a, b) {
    (Func(a), Func(b)) | (Tag(a), Tag(b)) => a == b
    (Table(ae, ai, am, a64, ash), Table(be, bi, bm, b64, bsh)) =>
      ae == be && a64 == b64 && ash == bsh && core_limits_match(ai, am, bi, bm)
    (Memory(ai, am, a64, ash, ap), Memory(bi, bm, b64, bsh, bp)) =>
      a64 == b64 && ash == bsh && ap == bp && core_limits_match(ai, am, bi, bm)
    (Global(at, am, ash), Global(bt, bm, bsh)) =>
      at == bt && am == bm && ash == bsh
    _ => false
  }
}

///|
fn core_compatible(
  a : @core_types.Module,
  b : @core_types.Module,
  reverse : Bool,
  charge : (Int32) -> Unit raise SemanticFailure,
) -> String? raise SemanticFailure {
  let (a, b) = if reverse { (b, a) } else { (a, b) }
  let imports : Map[(String, String), @core_types.External] = Map([])
  for item in b.imports {
    charge(1)
    imports[(item.module_name, item.name)] = item.kind
  }
  for item in a.imports {
    charge(1)
    guard imports.get((item.module_name, item.name)) is Some(expected) else {
      return Some(
        "unexpected core module import `" +
        item.module_name +
        "::" +
        item.name +
        "`",
      )
    }
    charge(core_external_work(expected))
    charge(core_external_work(item.kind))
    if !core_external_matches(expected, item.kind) {
      return Some(
        "incompatible core module import `" +
        item.module_name +
        "::" +
        item.name +
        "`",
      )
    }
  }
  let exports : Map[String, @core_types.External] = Map([])
  for item in a.exports {
    charge(1)
    exports[item.name] = item.kind
  }
  for item in b.exports {
    charge(1)
    guard exports.get(item.name) is Some(actual) else {
      return Some("missing core module export `" + item.name + "`")
    }
    charge(core_external_work(actual))
    charge(core_external_work(item.kind))
    if !core_external_matches(actual, item.kind) {
      return Some("incompatible core module export `" + item.name + "`")
    }
  }
  None
}

///|
fn Check::merge_core_modules(
  self : Check,
  state : ImportTypes,
  node : Int32,
  a : @core_types.Module,
  b : @core_types.Module,
) -> @core_types.Module raise SemanticFailure {
  let charge = fn(kind : @core_types.External) raise SemanticFailure {
    let amount = core_external_work(kind)
    if amount > state.budget.remaining {
      raise Problem(
        self.problem(
          node, "WAC-C006", "core module aggregation exceeds the verification work limit",
        ),
      )
    }
    state.budget.remaining -= amount
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
      charge(prior)
      charge(item.kind)
      if core_external_matches(prior, item.kind) {
        continue
      }
      if !core_external_matches(item.kind, prior) {
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
      charge(prior)
      charge(item.kind)
      if core_external_matches(item.kind, prior) {
        continue
      }
      if !core_external_matches(prior, item.kind) {
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
