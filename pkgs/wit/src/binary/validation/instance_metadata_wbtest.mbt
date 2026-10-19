///|
test "hierarchical metadata walks deep scopes with a shared budget" {
  let mut child : @component.TypeDef = InstanceType([
    Type(FuncType({ is_async: false, params: [], result: None, })),
    Export("f", [], FuncType(0)),
  ])
  for _ in 0..<6000 {
    child = InstanceType([Type(child), Export("child", [], InstanceType(0))])
  }
  let (metadata, next, remaining) = imported_instance_metadata(
    child,
    [],
    [],
    Map([]),
    Map([]),
    8,
    1000000,
  )
  let metadata = metadata.unwrap()
  assert_eq(metadata.nodes.length(), 6001)
  assert_eq(next, 8)
  assert_true(remaining < 1000000)
  let mut node = 0
  for _ in 0..<6000 {
    node = metadata.nodes[node].children["child"]
  }
  assert_true(metadata.nodes[node].functions.contains("f"))
  let (limited, _, remaining) = imported_instance_metadata(
    child,
    [],
    [],
    Map([]),
    Map([]),
    8,
    100,
  )
  assert_true(limited is None)
  assert_eq(remaining, 0)
}

///|
test "hierarchical legacy and complete function metadata avoid value recursion" {
  let types : Array[@component.TypeDef?] = []
  let mut value : @component.ValType = Prim(U32)
  for _ in 0..<6000 {
    types.push(Some(List(value)))
    value = TypeIdx(types.length() - 1)
  }
  let function : @component.FuncType = {
    is_async: false,
    params: [{ label: "x", ty: value, }],
    result: None,
  }
  let (signature, remaining) = metadata_function(function, types, [], 1000000)
  assert_eq(signature.params.length(), 1)
  assert_eq(signature.complete.unwrap().types.length(), 6000)
  assert_true(remaining < 1000000)
}
