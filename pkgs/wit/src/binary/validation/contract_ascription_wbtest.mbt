///|
test "component contracts compare deep scopes with bounded work" {
  fn metadata(result : @component.ValType) -> ScopedContractMetadata {
    let mut child : @component.TypeDef = ComponentType([
      Type(FuncType({ is_async: false, params: [], result: Some(result), })),
      Export("f", [], FuncType(0)),
    ])
    for _ in 0..<6000 {
      child = ComponentType([Type(child), Export("child", [], ComponentType(0))])
    }
    let (metadata, _, _) = scoped_contract_metadata(
      child,
      [],
      [],
      Map([]),
      0,
      1000000,
    )
    metadata.unwrap()
  }
  let a = metadata(Prim(U32))
  let b = metadata(Prim(U32))
  let remaining = check_scoped_contract(a, b, 20000)
  assert_true(remaining > 0 && remaining < 10000)
  let exhausted = try {
    check_scoped_contract(a, b, remaining) |> ignore
    false
  } catch {
    SectionParseError(11, _) => true
    _ => false
  }
  assert_true(exhausted)
  let mismatch = try {
    check_scoped_contract(a, metadata(Prim(U64)), 1000000) |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(mismatch)
}
