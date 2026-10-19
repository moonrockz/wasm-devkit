// Original wasm-devkit component contract comparison.

///|
priv enum ContractLeaf {
  Value(Int32, Int32, Int32, Int32)
  Function(Int32, CompleteFunctionSignature, Int32, CompleteFunctionSignature)
}

///|
fn check_scoped_contract(
  actual : ScopedContractMetadata,
  expected : ScopedContractMetadata,
  budget : Int32,
  core_contracts~ : @core_types.ContractGraph? = None,
  actual_node~ : Int32 = 0,
  expected_node~ : Int32 = 0,
  binders~ : Bool = false,
  bindings~ : Map[Int32, Int32]? = None,
  type_bindings~ : Map[TypeOrigin, TypeOrigin]? = None,
) -> Int32 raise ComponentValidationError {
  let graphs = [actual, expected]
  let work = [(0, actual_node, 1, expected_node, binders, true)]
  let leaves : Array[ContractLeaf] = []
  let substitutions : Map[(Int32, Int32), (Int32, Int32)] = Map([])
  let mut remaining = budget
  fn charge(count : Int32) -> Unit raise ComponentValidationError {
    if count < 0 || count > remaining {
      raise SectionParseError(
        11, "component contract exceeds the verification work limit",
      )
    }
    remaining -= count
  }
  fn resource_key(side : Int32, resource : Int32) -> (Int32, Int32) {
    (if graphs[side].locals.contains(resource) { side } else { 2 }, resource)
  }
  let mut resource_work = 0
  fn resolve(key : (Int32, Int32)) -> (Int32, Int32) {
    let mut key = key
    while substitutions.get(key) is Some(next) {
      resource_work += 1
      if resource_work > budget {
        break
      }
      key = next
    }
    key
  }
  fn resource(
    side : Int32,
    ty : Int32,
  ) -> Int32 raise ComponentValidationError {
    guard graphs[side].resources.get(ty) is Some(Some(id)) else {
      raise AscribedExportTypeIncompatible
    }
    id
  }
  while work.pop() is Some((a_side, a, b_side, b, binders, runtime_types)) {
    charge(1)
    guard graphs[a_side].nodes.get(a) is Some(an) &&
      graphs[b_side].nodes.get(b) is Some(bn) else {
      raise UnsupportedComponentAscription
    }
    if an.component != bn.component {
      raise AscribedExportTypeIncompatible
    }
    let runtime_types = runtime_types && !an.component
    let binders = binders || an.component
    let pairs = if an.component {
      [
        (b_side, bn.imports, bn.core_scope, a_side, an.imports, an.core_scope),
        (a_side, an.exports, an.core_scope, b_side, bn.exports, bn.core_scope),
      ]
    } else {
      [(a_side, an.exports, an.core_scope, b_side, bn.exports, bn.core_scope)]
    }
    for (left, lm, lc, right, rm, rc) in pairs {
      charge(rm.sorts.length())
      let names = rm.sorts.keys().to_array()
      names.sort()
      for name in names {
        let sort = rm.sorts[name]
        guard lm.sorts.get(name) is Some(actual_sort) && actual_sort == sort else {
          raise AscribedExportTypeIncompatible
        }
        match sort {
          Type => {
            guard lm.types.get(name) is Some(at) &&
              rm.types.get(name) is Some(bt) else {
              raise UnsupportedComponentAscription
            }
            if binders && rm.binders.contains(name) {
              let lhs = resolve(resource_key(left, resource(left, at)))
              let original = resource_key(right, resource(right, bt))
              let rhs = resolve(original)
              if rhs != lhs {
                if rhs != original {
                  raise AscribedExportTypeIncompatible
                }
                substitutions[rhs] = lhs
              }
            }
            if runtime_types &&
              left == 0 &&
              right == 1 &&
              type_bindings is Some(mapping) {
              guard graphs[left].origins.get(at) is Some(Some(actual_origin)) &&
                graphs[right].origins.get(bt) is Some(Some(expected_origin)) else {
                raise UnsupportedComponentAscription
              }
              if mapping.get(expected_origin) is Some(previous) &&
                previous != actual_origin {
                raise AscribedExportTypeIncompatible
              }
              mapping[expected_origin] = actual_origin
            }
            leaves.push(Value(left, at, right, bt))
          }
          Func => {
            guard lm.functions.get(name) is Some(af) &&
              af.complete is Some(af) &&
              rm.functions.get(name) is Some(bf) &&
              bf.complete is Some(bf) else {
              raise UnsupportedComponentAscription
            }
            leaves.push(Function(left, af, right, bf))
          }
          Value => {
            guard lm.values.get(name) is Some(av) &&
              rm.values.get(name) is Some(bv) else {
              raise UnsupportedComponentAscription
            }
            leaves.push(Function(left, av, right, bv))
          }
          Instance | Component => {
            guard lm.children.get(name) is Some(ac) &&
              rm.children.get(name) is Some(bc) else {
              raise UnsupportedComponentAscription
            }
            work.push((left, ac, right, bc, binders, runtime_types))
          }
          Core(0x11) => {
            fn module_contract(
              members : ContractMembers,
              scope : Int32?,
            ) -> @core_types.Module raise ComponentValidationError {
              if members.direct_modules.get(name) is Some(contract) {
                return contract
              }
              guard core_contracts is Some(graph) &&
                scope is Some(scope) &&
                graph.scope(scope) is Some(scope) &&
                members.modules.get(name) is Some(index) &&
                scope.definition(index) is Some(Module(contract)) else {
                raise UnsupportedComponentAscription
              }
              contract
            }
            let am = module_contract(lm, lc)
            let bm = module_contract(rm, rc)
            match
              @core_types.check_module_subtype(am, bm, work_limit=remaining) {
              Ok(rest) => remaining = rest
              Err(Mismatch(_)) => raise AscribedExportTypeIncompatible
              Err(WorkLimit) =>
                raise SectionParseError(
                  11, "component contract exceeds the verification work limit",
                )
            }
          }
          _ => raise UnsupportedComponentAscription
        }
      }
    }
    charge(resource_work)
    resource_work = 0
  }
  for leaf in leaves {
    charge(1)
    match leaf {
      Value(a, at, b, bt) =>
        remaining = check_value_ascriptions(
          [Value(TypeIdx(at), TypeIdx(bt))],
          graphs[a].types,
          graphs[a].resources,
          remaining,
          expected_types=Some(graphs[b].types),
          expected_resources=Some(graphs[b].resources),
          resource_equal=(ar, br) => {
            resolve(resource_key(a, ar)) == resolve(resource_key(b, br))
          },
        )
      Function(a, af, b, bf) =>
        remaining = check_function_ascription(
          af.function,
          bf.function,
          af.types,
          af.resources,
          expected_types=Some(bf.types),
          expected_resources=Some(bf.resources),
          budget=remaining,
          resource_equal=(ar, br) => {
            resolve(resource_key(a, ar)) == resolve(resource_key(b, br))
          },
        )
    }
    charge(resource_work)
    resource_work = 0
  }
  if bindings is Some(bindings) {
    for resource in expected.locals.keys() {
      charge(1)
      let (side, target) = resolve(resource_key(1, resource))
      if side != 1 {
        bindings[resource] = target
      }
      charge(resource_work)
      resource_work = 0
    }
  }
  remaining
}
