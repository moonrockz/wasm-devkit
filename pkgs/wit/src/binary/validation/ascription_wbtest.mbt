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

///|
test "type ascriptions compare deep definitions within a shared work budget" {
  let types : Array[@component.TypeDef?] = []
  for _ in 0..<2 {
    let mut child = @component.ValType::Prim(U32)
    for _ in 0..<6000 {
      let id = types.length()
      types.push(Some(List(child)))
      child = TypeIdx(id)
    }
  }
  let remaining = check_value_ascriptions(
    [Value(TypeIdx(5999), TypeIdx(11999))],
    types,
    [],
    20000,
  )
  assert_true(remaining > 0 && remaining < 10000)
  let exhausted = try {
    check_value_ascriptions(
      [Value(TypeIdx(5999), TypeIdx(11999))],
      types,
      [],
      remaining,
    )
    |> ignore
    false
  } catch {
    SectionParseError(11, _) => true
    _ => false
  }
  assert_true(exhausted)
  types[6000] = Some(List(Prim(U64)))
  let mismatch = try {
    check_value_ascriptions(
      [Value(TypeIdx(5999), TypeIdx(11999))],
      types,
      [],
      20000,
    )
    |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(mismatch)
}
