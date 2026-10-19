///|
test "complete function metadata keeps deep value graphs iterative" {
  let types : Array[@component.TypeDef?] = []
  let mut child = @component.ValType::Prim(U32)
  for _ in 0..<6000 {
    let index = types.length()
    types.push(Some(List(child)))
    child = TypeIdx(index)
  }
  let function : @component.FuncType = {
    is_async: true,
    params: [{ label: "value", ty: child, }],
    result: None,
  }
  let signature = complete_function_signature(function, [], [], types, []).unwrap()
  assert_eq(signature.types.length(), 6000)
  check_function_ascription(
    signature.function,
    function,
    signature.types,
    signature.resources,
    expected_types=Some(types),
  )
  |> ignore
}

///|
test "complete signatures distinguish separate index namespaces and resource contexts" {
  let function : @component.FuncType = {
    is_async: false,
    params: [{ label: "value", ty: TypeIdx(0), }],
    result: None,
  }
  let left : Array[@component.TypeDef?] = [Some(List(Prim(U32)))]
  let right : Array[@component.TypeDef?] = [Some(List(Prim(U64)))]
  let mismatch = try {
    check_function_ascription(
      function,
      function,
      left,
      [],
      expected_types=Some(right),
    )
    |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(mismatch)
  let types : Array[@component.TypeDef?] = [
    Some(Own(1)),
    Some(ResourceType(-1, 0x7f, None, HostDefined)),
  ]
  let signature = complete_function_signature(function, [], [], types, [
    None,
    Some(7),
  ]).unwrap()
  let changed = complete_signature_substitute(Some(signature), Map([(7, 9)])).unwrap()
  check_function_ascription(
    changed.function,
    function,
    changed.types,
    changed.resources,
    expected_types=Some(types),
    expected_resources=Some([None, Some(9)]),
  )
  |> ignore
  let crossed = try {
    check_function_ascription(
      signature.function,
      function,
      signature.types,
      signature.resources,
      expected_types=Some(types),
      expected_resources=Some([None, Some(9)]),
    )
    |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(crossed)
}

///|
test "complete signatures retain distinct named origins through normalization" {
  let types : Array[@component.TypeDef?] = [
    Some(Record([{ label: "x", ty: Prim(U32), }])),
    Some(Record([{ label: "x", ty: Prim(U32), }])),
  ]
  let origins : Array[TypeOrigin?] = [
    Some({ scope: 0, index: 3, }),
    Some({ scope: 0, index: 4, }),
  ]
  let function : @component.FuncType = {
    is_async: false,
    params: [{ label: "a", ty: TypeIdx(1), }, { label: "b", ty: TypeIdx(0), }],
    result: None,
  }
  let signature = complete_function_signature(
    function,
    [],
    [],
    types,
    [],
    global_type_origins=origins,
  ).unwrap()
  assert_eq(signature.origins[0].unwrap().index, 4)
  assert_eq(signature.origins[1].unwrap().index, 3)
  let substitutions = Map([({ scope: 0, index: 4, }, { scope: 9, index: 8, })])
  let remapped = complete_signature_substitute(
    Some(signature),
    Map([]),
    type_substitutions=substitutions,
  ).unwrap()
  assert_eq(remapped.origins[0].unwrap().scope, 9)
  assert_eq(remapped.origins[0].unwrap().index, 8)
  assert_eq(signature.origins[0].unwrap().scope, 0)
}

///|
test "origin visibility rejects equal anonymous records and bounds DAG work" {
  let types : Array[@component.TypeDef?] = [
    Some(Record([{ label: "x", ty: Prim(U32), }])),
    Some(Record([{ label: "x", ty: Prim(U32), }])),
  ]
  let first : TypeOrigin = { scope: 0, index: 1, }
  let second : TypeOrigin = { scope: 0, index: 2, }
  let origins = [Some(first), Some(second)]
  let named = Map([(first, true)])
  check_origin_values(
    [TypeIdx(0)],
    types,
    origins,
    [],
    named,
    Map([]),
    Counts::Counts(),
  )
  let rejected = try {
    check_origin_values(
      [TypeIdx(1)],
      types,
      origins,
      [],
      named,
      Map([]),
      Counts::Counts(),
    )
    false
  } catch {
    SectionParseError(11, _) => true
    _ => false
  }
  assert_true(rejected)
  let counts = Counts::Counts()
  counts.metadata_remaining = 1
  let limited = try {
    check_origin_values(
      [TypeIdx(0)],
      types,
      origins,
      [],
      named,
      Map([]),
      counts,
    )
    false
  } catch {
    UnsupportedComponentAscription => true
    _ => false
  }
  assert_true(limited)
}

///|
test "origin visibility walks deep shared graphs with one cumulative budget" {
  let types : Array[@component.TypeDef?] = []
  let origins : Array[TypeOrigin?] = []
  for index in 0..<6000 {
    types.push(Some(Option(TypeIdx(index + 1))))
    origins.push(None)
  }
  let origin : TypeOrigin = { scope: 7, index: 9, }
  types.push(Some(Record([{ label: "x", ty: Prim(U32), }])))
  origins.push(Some(origin))
  let counts = Counts::Counts()
  counts.metadata_remaining = 16001
  check_origin_values(
    Array::make(10000, TypeIdx(0)),
    types,
    origins,
    [],
    Map([(origin, true)]),
    Map([]),
    counts,
  )
  assert_eq(counts.metadata_remaining, 0)
  assert_eq(types.length(), 6001)
  assert_true(origins[6000] == Some(origin))
}
