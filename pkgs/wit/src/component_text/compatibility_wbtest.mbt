///|
test "component value indices use signed LEB boundaries" {
  for index in [63, 64, 127, 128, 8191, 8192] {
    let source = StringBuilder()
    source.write_string("(component")
    for _ in 0..<=index {
      source.write_string("(type u32)")
    }
    source.write_string(
      "(type (func (param \"p\" " +
      index.to_string() +
      ") (result " +
      index.to_string() +
      "))))",
    )
    let parsed = @component.parse_component(
      parse_component_wat(source.to_string()),
    )
    guard parsed.types[index + 1] is FuncType(ty) else {
      fail("missing function type")
    }
    assert_eq(ty.params[0].ty, TypeIdx(index))
    assert_eq(ty.result, Some(TypeIdx(index)))
  }
}

///|
test "map syntax includes nested inline value types" {
  for
    source in [
      "(component(type(map string u32)))", "(component(type(func(param \"p\" (map string u32)))))",
      "(component(type(instance(type(map string (map string u32))))))", "(component(type(instance(type(func(param \"p\" (map string (list u8))))))))",
    ] {
    ignore(@component.parse_component(parse_component_wat(source)))
  }
  let parsed = @component.parse_component(
    parse_component_wat("(component(type(map string u32)))"),
  )
  assert_eq(parsed.types[0], MapType(Prim(String), Prim(U32)))
}

///|
test "component text reader bounds nesting without recursive parsing" {
  let source = StringBuilder()
  for _ in 0..<10000 {
    source.write_string("(")
  }
  for _ in 0..<10000 {
    source.write_string(")")
  }
  let rejected = try {
    ignore(parse_component_wat(source.to_string()))
    false
  } catch {
    Unsupported(_) => true
    _ => false
  }
  assert_true(rejected)
}

///|
test "component indices reject decimal overflow" {
  ignore(parse_component_wat("(component(type u32)(export \"x\" (type 0)))"))
  assert_eq(parse_decimal_index("2147483647"), Some(2147483647))
  for value in ["2147483648", "4294967296", "18446744073709551616"] {
    assert_eq(parse_decimal_index(value), None)
    let rejected = try {
      ignore(
        parse_component_wat(
          "(component(type u32)(export \"x\" (type " + value + ")))",
        ),
      )
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
}
