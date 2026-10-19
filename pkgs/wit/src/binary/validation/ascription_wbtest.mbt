///|
test "function ascription comparison uses a stack for deep type aliases" {
  let types : Array[@component.TypeDef?] = []
  let roots : Array[Int32] = []
  for _ in 0..<2 {
    let mut child = @component.ValType::Prim(U32)
    for _ in 0..<6000 {
      let id = types.length()
      types.push(Some(List(child)))
      child = TypeIdx(id)
    }
    roots.push(types.length() - 1)
  }
  let actual : @component.FuncType = {
    is_async: false,
    params: [{ label: "value", ty: TypeIdx(roots[0]), }],
    result: None,
  }
  let expected : @component.FuncType = {
    ..actual,
    params: [{ label: "value", ty: TypeIdx(roots[1]), }],
  }
  check_function_ascription(actual, expected, types, []) |> ignore
  let limited = try {
    check_function_ascription(actual, expected, types, [], budget=100) |> ignore
    false
  } catch {
    SectionParseError(11, _) => true
    _ => false
  }
  assert_true(limited)
  types[6000] = Some(List(Prim(U64)))
  let rejected = try {
    check_function_ascription(actual, expected, types, []) |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(rejected)
}
