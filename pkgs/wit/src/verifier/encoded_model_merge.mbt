///|
// Selected input models keep anonymous allocations separate until merge. Named
// interface types are rebound by identity; anonymous types retain input sharing.
priv struct EncodedModelCopy {
  model : Resolution
  types : Map[Int32, ResolvedType]
  mapping : Map[Int32, Int32]
}

///|
fn encoded_merge_stability(
  from : Stability,
  into : Stability,
) -> Stability raise EncodedFailure {
  if from == into || from == Unknown {
    return into
  }
  if into == Unknown {
    return from
  }
  raise Invalid("conflicting stability on merged declaration")
}

///|
fn encoded_copy_model_type(
  input : EncodedModelCopy,
  root : Int32,
  owner : Int32,
  arena : SemanticArena,
  budget : EncodedMergeBudget,
) -> Int32 raise EncodedFailure {
  let pending = [(root, false)]
  while pending.pop() is Some((id, leaving)) {
    encoded_merge_charge(budget, 1)
    if !leaving && input.mapping.contains(id) {
      continue
    }
    let ty = match input.types.get(id) {
      Some(ty) => ty
      None => raise Invalid("missing selected input type")
    }
    if !leaving {
      guard ty.name is None else {
        raise Unsupported("unbound named type in selected input")
      }
      let target = arena.origins.length()
      arena.origins.push(input.model.origins[id])
      input.mapping[id] = target
      arena.owners[target] = owner
      pending.push((id, true))
      for child in kind_children(ty.kind) {
        pending.push((child, false))
      }
    } else {
      let target = input.mapping[id]
      arena.types[target] = {
        ..ty,
        id: target,
        scope: owner,
        kind: remap_kind(ty.kind, child => input.mapping[child]),
      }
      arena.type_order.push(target)
    }
  }
  input.mapping[root]
}

///|
// Run after feature selection and before world copies. Replaying selected model
// graphs avoids re-gating retained binary types using supplied source metadata.
fn encoded_merge_models(
  arena : SemanticArena,
  models : Array[Resolution],
  input_ranks : Map[String, Int32],
) -> Unit raise EncodedFailure {
  if models.is_empty() {
    return
  }
  let budget : EncodedMergeBudget = { remaining: 1000000, }
  let interfaces : Map[(String, String), Int32] = Map([])
  let named : Map[(String, String, String), Int32] = Map([])
  let functions : Map[(String, String, String), Int32] = Map([])
  for id in arena.interface_order {
    encoded_merge_charge(budget, 1)
    let info = arena.interfaces[id]
    guard info.name is Some(name) else { continue }
    let package_key = identity_key(info.package_identity)
    interfaces[(package_key, name)] = id
    for ty in info.types {
      encoded_merge_charge(budget, 1)
      named[(package_key, name, ty.name)] = ty.ty
    }
    for function in info.functions {
      encoded_merge_charge(budget, 1)
      functions[(package_key, name, function.name)] = function.id
    }
  }
  let inputs : Array[EncodedModelCopy] = []
  let type_choices : Map[Int32, (Int32, Int32, Int32)] = Map([])
  let function_choices : Map[Int32, (Int32, Int32, ResolvedFunction)] = Map([])
  let type_stability : Map[Int32, Stability] = Map([])
  for model_index, model in models {
    let types : Map[Int32, ResolvedType] = Map([])
    for ty in model.types() {
      encoded_merge_charge(budget, 1)
      types[ty.id] = ty
    }
    let input : EncodedModelCopy = { model, types, mapping: Map([]), }
    inputs.push(input)
    for info in model.interfaces() {
      encoded_merge_charge(budget, 1)
      guard info.name is Some(name) else { continue }
      let package_key = identity_key(info.package_identity)
      guard interfaces.get((package_key, name)) is Some(target_interface) else {
        continue
      }
      let current = arena.interfaces[target_interface]
      arena.interfaces[target_interface] = {
        ..current,
        stability: encoded_merge_stability(info.stability, current.stability),
      }
      for entry in info.types {
        encoded_merge_charge(budget, 1)
        guard named.get((package_key, name, entry.name)) is Some(target) else {
          continue
        }
        input.mapping[entry.ty] = target
        let ty = types[entry.ty]
        let rank = input_ranks[ty.location.source]
        type_stability[target] = encoded_merge_stability(
          ty.stability,
          type_stability.get(target).unwrap_or(Unknown),
        )
        if type_choices.get(target) is Some((previous, _, _)) &&
          previous <= rank {
          continue
        }
        type_choices[target] = (rank, model_index, entry.ty)
      }
      for function in info.functions {
        encoded_merge_charge(budget, 1)
        guard functions.get((package_key, name, function.name)) is Some(target) else {
          continue
        }
        let rank = input_ranks[function.location.source]
        if function_choices.get(target) is Some((previous, _, _)) &&
          previous <= rank {
          continue
        }
        function_choices[target] = (rank, model_index, function)
      }
    }
  }
  // Stable arena order controls allocation and budget accounting.
  let type_order = arena.type_order.copy()
  for target in type_order {
    encoded_merge_charge(budget, 1)
    guard type_choices.get(target) is Some((_, input_index, source)) else {
      continue
    }
    let input = inputs[input_index]
    let ty = input.types[source]
    let current = arena.types[target]
    for child in kind_children(ty.kind) {
      ignore(
        encoded_copy_model_type(input, child, current.scope, arena, budget),
      )
    }
    arena.types[target] = {
      ..current,
      stability: type_stability[target],
      kind: remap_kind(ty.kind, child => input.mapping[child]),
    }
  }
  for target in arena.function_order {
    encoded_merge_charge(budget, 1)
    guard function_choices.get(target) is Some((_, input_index, source)) else {
      continue
    }
    let input = inputs[input_index]
    let current = arena.functions[target]
    let owner = arena.owners[target]
    guard current.params.length() == source.params.length() else {
      raise Invalid("incompatible merged function parameters")
    }
    for param in source.params {
      ignore(encoded_copy_model_type(input, param.ty, owner, arena, budget))
    }
    if source.result is Some(result) {
      ignore(encoded_copy_model_type(input, result, owner, arena, budget))
    }
    let kind = match source.kind {
      Freestanding => Freestanding
      Method(id) => Method(input.mapping[id])
      Static(id) => Static(input.mapping[id])
      Constructor(id) => Constructor(input.mapping[id])
    }
    arena.functions[target] = {
      ..current,
      stability: source.stability,
      kind,
      params: current.params.mapi((i, param) => {
        ..param,
        ty: input.mapping[source.params[i].ty],
      }),
      result: source.result.map(id => input.mapping[id]),
    }
  }
  encoded_check_merged_types(arena, budget)
  for id in arena.interface_order {
    encoded_merge_charge(budget, 1)
    let info = arena.interfaces[id]
    arena.interfaces[id] = {
      ..info,
      functions: info.functions.map(function => arena.functions[function.id]),
    }
  }
}

///|
// Replaced signatures can leave source-oriented anonymous nodes unreachable.
// Keep the selected graph and reject nominal inconsistencies that the pinned
// Resolve merge currently permits through its unchecked named-type remapping.
fn encoded_check_merged_types(
  arena : SemanticArena,
  budget : EncodedMergeBudget,
) -> Unit raise EncodedFailure {
  let roots : Array[Int32] = []
  for id in arena.type_order {
    encoded_merge_charge(budget, 1)
    if arena.types[id].name is Some(_) {
      roots.push(id)
    }
  }
  for id in arena.function_order {
    encoded_merge_charge(budget, 1)
    let function = arena.functions[id]
    for param in function.params {
      roots.push(param.ty)
    }
    if function.result is Some(id) {
      roots.push(id)
    }
    match function.kind {
      Method(id) | Static(id) | Constructor(id) => roots.push(id)
      Freestanding => ()
    }
  }
  let states : Map[Int32, Int32] = Map([])
  let borrowed : Map[Int32, Bool] = Map([])
  for root in roots {
    let pending = [(root, false)]
    while pending.pop() is Some((id, leaving)) {
      encoded_merge_charge(budget, 1)
      if leaving {
        let kind = arena.types[id].kind
        borrowed[id] = match kind {
          Borrow(_) => true
          Own(_) | Resource => false
          _ => kind_children(kind).any(child => borrowed[child])
        }
        states[id] = 2
        continue
      }
      match states.get(id) {
        Some(2) => continue
        Some(1) => raise Invalid("cycle in merged type graph")
        _ => ()
      }
      guard arena.types.get(id) is Some(ty) else {
        raise Invalid("missing merged type")
      }
      states[id] = 1
      pending.push((id, true))
      for child in kind_children(ty.kind) {
        pending.push((child, false))
      }
    }
  }
  let resource_roots : Map[Int32, Bool] = Map([])
  let retained : Array[Int32] = []
  for id in arena.type_order {
    encoded_merge_charge(budget, 1)
    if !states.contains(id) {
      continue
    }
    retained.push(id)
    let target = match arena.types[id].kind {
      Own(target) | Borrow(target) => target
      _ => continue
    }
    let resource = encoded_merged_resource(
      arena, target, resource_roots, budget,
    )
    guard resource else {
      raise Invalid("merged handle target is not a resource")
    }
  }
  let aliases : Map[Int32, Int32] = Map([])
  for id in retained {
    encoded_merge_charge(budget, 1)
    let kind = arena.types[id].kind
    match kind {
      Alias(_) | Own(_) | Borrow(_) => ()
      _ =>
        for child in kind_children(kind) {
          let root = encoded_merged_type_root(arena, child, aliases, budget)
          guard !(arena.types[root].kind is Resource) else {
            raise Invalid("merged value type contains a bare resource")
          }
        }
    }
  }
  for id in arena.function_order {
    encoded_merge_charge(budget, 1)
    let function = arena.functions[id]
    let values = function.params.map(param => param.ty).iter().to_array()
    if function.result is Some(result) {
      values.push(result)
    }
    for value in values {
      let root = encoded_merged_type_root(arena, value, aliases, budget)
      guard !(arena.types[root].kind is Resource) else {
        raise Invalid("merged function value is a bare resource")
      }
    }
    if function.result is Some(result) {
      guard !borrowed[result] else {
        raise Invalid("merged function result contains a borrowed handle")
      }
      if function.flavor is Setter {
        let root = encoded_merged_type_root(arena, result, aliases, budget)
        guard arena.types[root].kind is Result(None, _) else {
          raise Invalid("merged setter result must have no success type")
        }
      }
    }
    if function.kind is Constructor(owner) {
      guard function.result is Some(result) else {
        raise Invalid("merged constructor has no result")
      }
      let root = encoded_merged_type_root(arena, result, aliases, budget)
      let success = match arena.types[root].kind {
        Result(Some(ok), _) =>
          encoded_merged_type_root(arena, ok, aliases, budget)
        _ => root
      }
      guard arena.types[success].kind is Own(target) &&
        encoded_merged_type_root(arena, target, aliases, budget) ==
        encoded_merged_type_root(arena, owner, aliases, budget) else {
        raise Invalid("merged constructor must construct its own resource")
      }
    }
    if function.kind is Method(owner) {
      guard !function.params.is_empty() else {
        raise Invalid("merged method has no receiver")
      }
      let root = encoded_merged_type_root(
        arena,
        function.params[0].ty,
        aliases,
        budget,
      )
      guard arena.types[root].kind is Borrow(target) &&
        encoded_merged_type_root(arena, target, aliases, budget) ==
        encoded_merged_type_root(arena, owner, aliases, budget) else {
        raise Invalid("merged method receiver has a different resource")
      }
    }
    match function.kind {
      Freestanding => ()
      Method(target) | Static(target) | Constructor(target) => {
        guard encoded_merged_resource(arena, target, resource_roots, budget) else {
          raise Invalid("merged function owner is not a resource")
        }
      }
    }
  }
  arena.type_order.clear()
  arena.type_order.append(retained)
}

///|
fn encoded_merged_resource(
  arena : SemanticArena,
  target : Int32,
  cache : Map[Int32, Bool],
  budget : EncodedMergeBudget,
) -> Bool raise EncodedFailure {
  let path : Array[Int32] = []
  let mut current = target
  let resource = while true {
    encoded_merge_charge(budget, 1)
    if cache.get(current) is Some(value) {
      break value
    }
    path.push(current)
    match arena.types[current].kind {
      Alias(next) => current = next
      Resource => break true
      _ => break false
    }
  } nobreak {
    false
  }
  for id in path {
    cache[id] = resource
  }
  resource
}

///|
fn encoded_merged_type_root(
  arena : SemanticArena,
  target : Int32,
  cache : Map[Int32, Int32],
  budget : EncodedMergeBudget,
) -> Int32 raise EncodedFailure {
  let path : Array[Int32] = []
  let mut current = target
  while true {
    encoded_merge_charge(budget, 1)
    if cache.get(current) is Some(root) {
      current = root
      break
    }
    path.push(current)
    match arena.types[current].kind {
      Alias(next) => current = next
      _ => break
    }
  }
  for id in path {
    cache[id] = current
  }
  current
}
