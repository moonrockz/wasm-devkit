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
  fn metadata(result : @component.ValType) -> InstanceMetadata {
    let (metadata, _, _) = imported_instance_metadata(
      tree(result),
      [],
      [],
      Map([]),
      Map([]),
      0,
      1000000,
    )
    metadata.unwrap()
  }
  let actual = metadata(Prim(U32))
  let expected = metadata(Prim(U32))
  let remaining = check_instance_ascription(actual, 0, expected, 20000)
  assert_true(remaining > 0 && remaining < 10000)
  let exhausted = try {
    check_instance_ascription(actual, 0, expected, remaining) |> ignore
    false
  } catch {
    SectionParseError(11, _) => true
    _ => false
  }
  assert_true(exhausted)
  let rejected = try {
    check_instance_ascription(actual, 0, metadata(Prim(U64)), 1000000) |> ignore
    false
  } catch {
    AscribedExportTypeIncompatible => true
    _ => false
  }
  assert_true(rejected)
}
