///|
priv struct ImportTypes {
  owners : Map[(Int32, Int32), String]
  copies : Map[Int32, Int32]
  redirects : Map[Int32, Int32]
  copied : Array[Int32]
  named : Array[(String, Int32)]
  merges : Array[(Int32, Int32)]
  budget : VerificationBudget
}

///|
fn ImportTypes::new() -> ImportTypes {
  {
    owners: Map([]),
    copies: Map([]),
    redirects: Map([]),
    copied: [],
    named: [],
    merges: [],
    budget: { remaining: 1000000, },
  }
}

///|
fn Check::import_step(
  self : Check,
  state : ImportTypes,
  node : Int32,
) -> Unit raise SemanticFailure {
  self.verification_step(state.budget, node)
}

///|
fn Check::import_type_id(
  self : Check,
  state : ImportTypes,
  node : Int32,
  initial : Int32,
) -> Int32 raise SemanticFailure {
  let mut current = initial
  let path = []
  while state.redirects.get(current) is Some(next) {
    self.import_step(state, node)
    if next == current {
      break
    }
    path.push(current)
    current = next
  }
  for id in path {
    state.redirects[id] = current
  }
  current
}

///|
fn Check::copy_import_type(
  self : Check,
  state : ImportTypes,
  node : Int32,
  root : Int32,
) -> Int32 raise SemanticFailure {
  let pending = [(root, false)]
  while pending.pop() is Some((id, finish)) {
    self.import_step(state, node)
    if finish {
      let target = state.copies[id]
      let kind = binary_remap(self.types[id].kind, state.copies)
      self.types[target] = { ..self.types[target], kind, }
      if kind is Interface(Some(name), _, _) {
        let mut previous : Int32? = None
        for (candidate, ty) in state.named {
          self.import_step(state, node)
          if compatible_external_version(candidate, name) {
            previous = Some(ty)
            break
          }
        }
        match previous {
          Some(previous) => state.merges.push((previous, target))
          None => state.named.push((name, target))
        }
      }
      continue
    }
    if state.copies.contains(id) {
      continue
    }
    let target = self.types.length()
    state.copies[id] = target
    state.copied.push(target)
    self.types.push({ ..self.types[id], id: target, })
    self.borrowed.push(self.borrowed[id])
    pending.push((id, true))
    let children = binary_children(self.types[id].kind)
    let uses = match self.types[id].kind {
      Interface(_, uses, _) | World(_, uses, _, _) => uses
      _ => []
    }
    for used in uses {
      children.push(used.interface)
      children.push(used.ty)
    }
    for i = children.length() - 1; i >= 0; i = i - 1 {
      pending.push((children[i], false))
    }
  }
  state.copies[root]
}

///|
fn Check::import_subtype(
  self : Check,
  state : ImportTypes,
  node : Int32,
  actual : ItemKind,
  expected : ItemKind,
  reverse~ : Bool = false,
) -> CompatibilityTrace? raise SemanticFailure {
  self.import_step(state, node)
  let trace : CompatibilityTrace = {
    types: Map([]),
    binders: [],
    resource_pairs: [],
    steps: 0,
  }
  let result = try {
    self.compatible(
      node,
      { kind: actual, node, external_name: None, value: None, },
      expected,
      Map([]),
      [],
      reverse~,
      nominal=false,
      trace=Some(trace),
    )
    Some(trace)
  } catch {
    Problem(problem) => {
      if problem.code == "WAC-C006" {
        raise Problem(problem)
      }
      None
    }
  }
  state.budget.remaining -= trace.steps
  self.import_step(state, node)
  result
}

///|
fn Check::redirect_import_types(
  self : Check,
  state : ImportTypes,
  node : Int32,
  trace : CompatibilityTrace,
  invert~ : Bool = false,
) -> Unit raise SemanticFailure {
  let keys = trace.types.keys().to_array()
  keys.sort()
  for source in keys {
    let (source, target) = if invert {
      (trace.types[source], source)
    } else {
      (source, trace.types[source])
    }
    let target = self.import_type_id(state, node, target)
    let source = self.import_type_id(state, node, source)
    if source != target {
      state.redirects[source] = target
    }
  }
}

///|
fn Check::merge_import_uses(
  self : Check,
  state : ImportTypes,
  node : Int32,
  first : ReadOnlyArray[UsedType],
  second : ReadOnlyArray[UsedType],
) -> ReadOnlyArray[UsedType] raise SemanticFailure {
  let result = first.iter().to_array()
  for used in second {
    self.import_step(state, node)
    let source = self.import_type_id(state, node, used.interface)
    guard self.types[source].kind is Interface(Some(source_name), _, _) else {
      raise Problem(
        self.problem(
          node, "WAC-C009", "implicit used type has no named interface",
        ),
      )
    }
    let mut previous : UsedType? = None
    for item in result {
      self.import_step(state, node)
      if item.name == used.name {
        previous = Some(item)
        break
      }
    }
    if previous is Some(previous) {
      let target = self.import_type_id(state, node, previous.interface)
      guard self.types[target].kind is Interface(Some(target_name), _, _) &&
        compatible_external_version(target_name, source_name) &&
        previous.original_name == used.original_name else {
        raise Problem(
          self.problem(
            node,
            "WAC-C009",
            "implicit used type `" + used.name + "` has conflicting origins",
          ),
        )
      }
      if source != target {
        state.merges.push((target, source))
      }
    } else {
      result.push(used)
    }
  }
  ReadOnlyArray::from_array(result)
}

///|
fn Check::merge_import_externs(
  self : Check,
  state : ImportTypes,
  node : Int32,
  first : ReadOnlyArray[Extern],
  second : ReadOnlyArray[Extern],
  importing : Bool,
) -> ReadOnlyArray[Extern] raise SemanticFailure {
  let result = first.iter().to_array()
  for source in second {
    self.import_step(state, node)
    let mut found : Int32? = None
    for index, target in result {
      self.import_step(state, node)
      if target.name == source.name {
        found = Some(index)
        break
      }
    }
    if found is Some(index) {
      let target = result[index]
      let (actual, expected) = if importing {
        (target.kind, source.kind)
      } else {
        (source.kind, target.kind)
      }
      if self.import_subtype(state, node, actual, expected, reverse=importing)
        is Some(trace) {
        if !importing {
          self.redirect_import_types(state, node, trace, invert=true)
        }
        continue
      }
      guard self.import_subtype(
          state,
          node,
          expected,
          actual,
          reverse=importing,
        )
        is Some(_) else {
        raise Problem(
          self.problem(
            node,
            "WAC-C009",
            "incompatible shared implicit export `" + source.name + "`",
          ),
        )
      }
      result[index] = source
    } else {
      result.push(source)
    }
  }
  ReadOnlyArray::from_array(result)
}

///|
fn Check::merge_import_type(
  self : Check,
  state : ImportTypes,
  node : Int32,
  first : ItemKind,
  second : ItemKind,
) -> Unit raise SemanticFailure {
  let target = self.import_type_id(state, node, binary_kind_id(first))
  let source = self.import_type_id(state, node, binary_kind_id(second))
  if target == source {
    return
  }
  let sorts_match = match (first, second) {
    (Type(_), Type(_))
    | (Function(_), Function(_))
    | (Instance(_), Instance(_))
    | (Component(_), Component(_))
    | (Module(_), Module(_)) => true
    _ => false
  }
  if !sorts_match {
    raise Problem(
      self.problem(
        node, "WAC-C009", "shared implicit imports have different item kinds",
      ),
    )
  }
  match (self.types[target].kind, self.types[source].kind) {
    (Module(a), Module(b)) => {
      let merged = self.merge_core_modules(state, node, a, b)
      self.types[target] = { ..self.types[target], kind: Module(merged), }
      state.redirects[source] = target
    }
    (Interface(name, au, ae), Interface(_, bu, be)) => {
      let uses = self.merge_import_uses(state, node, au, bu)
      let exports = self.merge_import_externs(state, node, ae, be, false)
      self.types[target] = {
        ..self.types[target],
        kind: Interface(name, uses, exports),
      }
      state.redirects[source] = target
    }
    (World(name, au, ai, ae), World(_, bu, bi, be)) => {
      let uses = self.merge_import_uses(state, node, au, bu)
      let imports = self.merge_import_externs(state, node, ai, bi, true)
      let exports = self.merge_import_externs(state, node, ae, be, false)
      self.types[target] = {
        ..self.types[target],
        kind: World(name, uses, imports, exports),
      }
      state.redirects[source] = target
    }
    _ => {
      let first = binary_kind_with_id(first, target)
      let second = binary_kind_with_id(second, source)
      guard self.import_subtype(state, node, second, first) is Some(_) &&
        self.import_subtype(state, node, first, second) is Some(trace) else {
        raise Problem(
          self.problem(
            node, "WAC-C009", "shared implicit imports have incompatible types",
          ),
        )
      }
      self.redirect_import_types(state, node, trace)
      state.redirects[source] = target
    }
  }
}

///|
fn Check::finish_import_types(
  self : Check,
  state : ImportTypes,
  node : Int32,
) -> Unit raise SemanticFailure {
  let mut index = 0
  while index < state.merges.length() {
    let (target, source) = state.merges[index]
    index += 1
    self.merge_import_type(state, node, Instance(target), Instance(source))
  }
  state.merges.clear()
  let mapping : Map[Int32, Int32] = Map([])
  for id in state.copied {
    mapping[id] = self.import_type_id(state, node, id)
  }
  for id in state.copied {
    self.import_step(state, node)
    self.types[id] = {
      ..self.types[id],
      kind: binary_remap(self.types[id].kind, mapping),
    }
  }
}
