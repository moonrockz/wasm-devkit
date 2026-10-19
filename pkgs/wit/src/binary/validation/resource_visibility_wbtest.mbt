///|
test "resource import visibility follows deep value graphs iteratively" {
  let types : Array[@component.TypeDef?] = [
    Some(ResourceType(-1, 0x7f, None, HostDefined)),
    Some(Own(0)),
  ]
  for i in 2..<10002 {
    types.push(Some(Option(TypeIdx(i - 1))))
  }
  assert_false(
    valtype_uses_disallowed_resources(
      TypeIdx(10001),
      types,
      Map([(0, 1)]),
      Map([]),
    ),
  )
  assert_true(
    valtype_uses_disallowed_resources(TypeIdx(10001), types, Map([]), Map([])),
  )
}
