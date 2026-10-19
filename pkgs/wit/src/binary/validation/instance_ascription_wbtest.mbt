///|
test "instance annotations use an explicit stack and cumulative allowance" {
  fn tree(result : @component.ValType) -> @component.TypeDef {
    let mut child : @component.TypeDef = InstanceType([
      Type(FuncType({ is_async: false, params: [], result: Some(result), })),
      Export("f", [], FuncType(0)),
    ])
    for _ in 0..<6000 {
      child = InstanceType([Type(child), Export("child", [], InstanceType(0))])
    }
    child
  }
  fn metadata(result : @component.ValType) -> ScopedContractMetadata {
    let (metadata, _, _) = scoped_contract_metadata(
      tree(result),
      [],
      [],
      Map([]),
      0,
      1000000,
    )
    metadata.unwrap()
  }
  let actual = metadata(Prim(U32))
  let expected = metadata(Prim(U32))
  let remaining = check_scoped_contract(actual, expected, 20000)
  assert_true(remaining > 0 && remaining < 10000)
  let exhausted = try {
    check_scoped_contract(actual, expected, remaining) |> ignore
    false
  } catch {
    SectionParseError(11, _) => true
    _ => false
  }
  assert_true(exhausted)
  let rejected = try {
    check_scoped_contract(actual, metadata(Prim(U64)), 1000000) |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "scoped instance contracts keep seeded deep resource identities" {
  let mut td : @component.TypeDef = InstanceType([
    Export("r", [], Type(SubResource)),
  ])
  for _ in 0..<6000 {
    td = InstanceType([Type(td), Export("child", [], InstanceType(0))])
  }
  let (seed, next, _) = imported_instance_metadata(
    td,
    [],
    [],
    Map([]),
    Map([]),
    77,
    1000000,
  )
  assert_eq(next, 78)
  let (contract, next, _) = scoped_contract_metadata(
    td,
    [],
    [],
    Map([]),
    next,
    1000000,
    seed=Some((seed.unwrap(), 0)),
  )
  let contract = contract.unwrap()
  assert_eq(next, 78)
  assert_true(contract.locals.is_empty())
  let mut node = 0
  for _ in 0..<6000 {
    node = contract.nodes[node].exports.children["child"]
  }
  assert_eq(
    contract.resources[contract.nodes[node].exports.types["r"]],
    Some(77),
  )
  let (fresh, _, _) = scoped_contract_metadata(
    td,
    [],
    [],
    Map([]),
    next,
    1000000,
  )
  let rejected = try {
    check_scoped_contract(contract, fresh.unwrap(), 1000000) |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(rejected)
}
