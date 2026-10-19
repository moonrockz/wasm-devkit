///|
fn Check::target_step(
  self : Check,
  path : Int32,
  state : TargetResources,
) -> Unit raise SemanticFailure {
  state.steps += 1
  if state.steps > 1000000 {
    raise Problem(
      self.problem(
        path, "WAC-C006", "target comparison exceeds the verification work limit",
      ),
    )
  }
}

///|
fn Check::target_parameters(
  self : Check,
  path : Int32,
  kind : ItemKind,
  state : TargetResources,
) -> (Array[Int32], Map[Int32, Bool]) raise SemanticFailure {
  let budget : VerificationBudget = { remaining: 1000000 - state.steps, }
  let result = self.resource_parameters(path, kind, budget=Some(budget))
  state.steps = 1000000 - budget.remaining
  result
}

///|
// Copies only paths affected by resource substitutions. All copies are private
// to the target check and removed before returning the verified model.
fn Check::target_substitute(
  self : Check,
  path : Int32,
  root : Int32,
  substitutions : Map[Int32, Int32],
  state : TargetResources,
) -> Int32 raise SemanticFailure {
  let mapping : Map[Int32, Int32] = Map([])
  for source, target in substitutions {
    self.target_step(path, state)
    mapping[source] = target
  }
  let pending = [(root, false)]
  let seen : Map[Int32, Bool] = Map([])
  while pending.pop() is Some((id, finish)) {
    self.target_step(path, state)
    if mapping.contains(id) {
      continue
    }
    let children = binary_children(self.types[id].kind)
    let uses = match self.types[id].kind {
      Interface(_, uses, _) | World(_, uses, _, _) => uses
      _ => []
    }
    for used in uses {
      children.push(used.interface)
      children.push(used.ty)
    }
    if !finish {
      if seen.contains(id) {
        continue
      }
      seen[id] = true
      pending.push((id, true))
      for i = children.length() - 1; i >= 0; i = i - 1 {
        pending.push((children[i], false))
      }
      continue
    }
    let mut changed = false
    for child in children {
      self.target_step(path, state)
      if mapping.get(child).unwrap_or(child) != child {
        changed = true
      }
    }
    if changed {
      let copy = self.types.length()
      self.types.push({
        ..self.types[id],
        id: copy,
        kind: binary_remap(self.types[id].kind, mapping),
      })
      self.borrowed.push(self.borrowed[id])
      mapping[id] = copy
    } else {
      mapping[id] = id
    }
  }
  mapping.get(root).unwrap_or(root)
}

///|
// Component parameters are generic scopes. Two instance declarations using one
// source interface template introduce separate binders. Aliases and handles
// capture the binder already introduced in their surrounding component scope.
fn Check::target_scoped_kind(
  self : Check,
  path : Int32,
  kind : ItemKind,
  context : Map[Int32, Int32],
  state : TargetResources,
  actual : Bool,
  variables : Map[Int32, Bool],
) -> ItemKind raise SemanticFailure {
  let root = binary_kind_id(kind)
  let normalized : Map[Int32, Int32] = Map([])
  let seen : Map[Int32, Bool] = Map([])
  let pending = [(root, false)]
  while pending.pop() is Some((id, finish)) {
    self.target_step(path, state)
    let original = self.types[id]
    if !finish {
      if seen.contains(id) {
        continue
      }
      seen[id] = true
      pending.push((id, true))
      let children = binary_children(original.kind)
      for i = children.length() - 1; i >= 0; i = i - 1 {
        pending.push((children[i], false))
      }
      continue
    }
    let kind = binary_remap(original.kind, normalized)
    if kind is World(name, uses, imports, exports) {
      let substitutions : Map[Int32, Int32] = Map([])
      let canonical : Map[Int32, Bool] = Map([])
      let implicit : Map[String, Extern] = Map([])
      self.target_scope_uses(path, uses, implicit, state)
      for entry in imports {
        self.target_step(path, state)
        if entry.kind is Instance(instance) &&
          self.types[instance].kind is Interface(_, used, _) {
          self.target_scope_uses(path, used, implicit, state)
        }
      }
      let names : Array[String] = []
      for name, _ in implicit {
        self.target_step(path, state)
        names.push(name)
      }
      names.sort_by((a, b) => a.lexical_compare(b))
      let entries : Array[Extern] = []
      for name in names {
        entries.push(implicit[name])
      }
      for entry in imports {
        self.target_step(path, state)
        if !implicit.contains(entry.name) {
          entries.push(entry)
        }
      }
      let import_count = entries.length()
      for entry in exports {
        self.target_step(path, state)
        entries.push(entry)
      }
      let result : Array[Extern] = []
      for entry in entries {
        self.target_step(path, state)
        let bindings : Map[Int32, Int32] = Map([])
        for source, target in substitutions {
          self.target_step(path, state)
          bindings[source] = target
        }
        let (parameters, owned) = self.target_parameters(
          path,
          entry.kind,
          state,
        )
        for resource in parameters {
          self.target_step(path, state)
          if !owned.contains(resource) {
            continue
          }
          let copy = self.types.length()
          self.types.push({ ..self.types[resource], id: copy, })
          self.borrowed.push(self.borrowed[resource])
          bindings[resource] = copy
          let identity = if actual {
            self.new_resource_identity()
          } else {
            state.fresh()
          }
          context[copy] = identity
          if !actual {
            variables[identity] = true
          }
          let named_owner = match self.types[binary_kind_id(entry.kind)].kind {
            Interface(Some(name), _, _) => name == entry.name
            _ => false
          }
          if !(entry.kind is Component(_)) &&
            (named_owner || !canonical.contains(resource)) {
            substitutions[resource] = copy
            if named_owner {
              canonical[resource] = true
            }
          }
        }
        let ty = self.target_substitute(
          path,
          binary_kind_id(entry.kind),
          bindings,
          state,
        )
        result.push({ ..entry, kind: binary_kind_with_id(entry.kind, ty), })
      }
      let copied = self.types.length()
      let imports = ReadOnlyArray::from_array(result[:import_count].to_owned())
      let exports = ReadOnlyArray::from_array(result[import_count:].to_owned())
      self.types.push({
        ..original,
        id: copied,
        kind: World(name, uses, imports, exports),
      })
      self.borrowed.push(self.borrowed[id])
      normalized[id] = copied
    } else if kind != original.kind {
      let copy = self.types.length()
      self.types.push({ ..original, id: copy, kind, })
      self.borrowed.push(self.borrowed[id])
      normalized[id] = copy
    }
  }
  binary_kind_with_id(kind, normalized.get(root).unwrap_or(root))
}

///|
// Binary aliases may name anonymous instance declarations already present in
// the world. Only named source uses imply an additional interface import.
fn Check::target_scope_uses(
  self : Check,
  path : Int32,
  uses : ReadOnlyArray[UsedType],
  imports : Map[String, Extern],
  state : TargetResources,
) -> Unit raise SemanticFailure {
  for used in uses {
    self.target_step(path, state)
    if self.types[used.interface].kind is Interface(Some(name), _, _) {
      imports[name] = {
        name,
        kind: Instance(used.interface),
        location: used.location,
      }
    }
  }
}
