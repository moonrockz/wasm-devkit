// Original wasm-devkit instance export annotation comparison.

///|
// An imported instance already has concrete resource identities. An export
// annotation must preserve them, including captured aliases. Component types
// have different binder rules and are handled by a separate comparison.
fn check_instance_ascription(
  actual : InstanceMetadata,
  actual_node : Int32,
  expected : InstanceMetadata,
  budget : Int32,
  core_contracts~ : @core_types.ContractGraph? = None,
  core_scopes~ : (Int32, Int32)? = None,
) -> Int32 raise ComponentValidationError {
  let work = [(actual_node, 0, core_scopes)]
  let seen : Map[(Int32, Int32), Bool] = Map([])
  let mut remaining = budget
  fn charge(count : Int32) -> Unit raise ComponentValidationError {
    if count < 0 || count > remaining {
      raise SectionParseError(
        11, "instance ascription exceeds the verification work limit",
      )
    }
    remaining -= count
  }
  while work.pop() is Some((a, b, scopes)) {
    charge(1)
    if seen.contains((a, b)) {
      continue
    }
    seen[(a, b)] = true
    guard actual.nodes.get(a) is Some(actual_scope) &&
      expected.nodes.get(b) is Some(expected_scope) else {
      raise UnsupportedInstanceAscription
    }
    charge(expected_scope.exports.length())
    let names = expected_scope.exports.keys().to_array()
    names.sort()
    for name in names {
      let expected_sort = expected_scope.exports[name]
      guard actual_scope.exports.get(name) is Some(actual_sort) &&
        actual_sort == expected_sort else {
        raise AscribedExportTypeIncompatible
      }
      match expected_sort {
        Type => {
          guard actual_scope.types.get(name) is Some(actual_type) &&
            expected_scope.types.get(name) is Some(expected_type) else {
            raise UnsupportedInstanceAscription
          }
          remaining = check_value_ascriptions(
            [Value(TypeIdx(actual_type), TypeIdx(expected_type))],
            actual.types,
            actual.resources,
            remaining,
            expected_types=Some(expected.types),
            expected_resources=Some(expected.resources),
          )
        }
        Func => {
          guard actual_scope.functions.get(name) is Some(actual_shape) &&
            expected_scope.functions.get(name) is Some(expected_shape) &&
            actual_shape.complete is Some(actual_function) &&
            expected_shape.complete is Some(expected_function) else {
            raise UnsupportedInstanceAscription
          }
          remaining = check_function_ascription(
            actual_function.function,
            expected_function.function,
            actual_function.types,
            actual_function.resources,
            expected_types=Some(expected_function.types),
            expected_resources=Some(expected_function.resources),
            budget=remaining,
          )
        }
        Instance => {
          guard actual_scope.children.get(name) is Some(actual_child) &&
            expected_scope.children.get(name) is Some(expected_child) else {
            raise UnsupportedInstanceAscription
          }
          let child_scopes = match (core_contracts, scopes) {
            (Some(graph), Some((a, b))) =>
              match (graph.scope(a), graph.scope(b)) {
                (Some(actual), Some(expected)) =>
                  match (actual.exported(name), expected.exported(name)) {
                    (Some(Scope(a)), Some(Scope(b))) => Some((a, b))
                    _ => None
                  }
                _ => None
              }
            _ => None
          }
          work.push((actual_child, expected_child, child_scopes))
        }
        Core(0x11) => {
          guard core_contracts is Some(graph) &&
            scopes is Some((a, b)) &&
            graph.scope(a) is Some(actual) &&
            graph.scope(b) is Some(expected) &&
            actual.exported(name) is Some(Module(actual)) &&
            expected.exported(name) is Some(Module(expected)) else {
            raise UnsupportedInstanceAscription
          }
          match
            @core_types.check_module_subtype(
              actual,
              expected,
              work_limit=remaining,
            ) {
            Ok(left) => remaining = left
            Err(Mismatch(_)) => raise AscribedExportTypeIncompatible
            Err(WorkLimit) =>
              raise SectionParseError(
                11, "instance ascription exceeds the verification work limit",
              )
          }
        }
        _ => raise UnsupportedInstanceAscription
      }
    }
  }
  remaining
}
