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
  assert_eq(parse_index_literal("2147483647"), Some(2147483647))
  for value in ["2147483648", "4294967296", "18446744073709551616"] {
    assert_eq(parse_index_literal(value), None)
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

///|
test "binary text compilation leaves byte validation to the caller" {
  assert_eq(parse_component_wat("(component binary \"bad\")"), b"bad")
  let rejected = try {
    ignore(parse_component_wat("(component definition binary \"bad\")"))
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
}

///|
test "component indices accept WAT radix sign and digit separators" {
  for
    text in [
      "15", "+15", "1_5", "+1_5", "0xf", "0xF", "+0xf", "0x0_f", "+0x0_F",
    ] {
    assert_eq(parse_index_literal(text), Some(15))
    let declarations = "(type u32)".repeat(16)
    let expected = parse_component_wat(
      "(component" + declarations + "(type(func(param \"x\" 15))))",
    )
    assert_eq(
      parse_component_wat(
        "(component" + declarations + "(type(func(param \"x\" " + text + "))))",
      ),
      expected,
    )
  }
  for
    text in [
      "", "+", "-0", "-0x0", "0X0", "_0", "0_", "0__0", "+_0", "0x", "0x_0", "0x0_",
      "0x0__0", "0xg", "0x80000000", "0x100000000", "+4294967296", "4_294_967_296",
    ] {
    assert_eq(parse_index_literal(text), None)
  }
  assert_eq(parse_index_literal("+0x7fff_ffff"), Some(2147483647))
}

///|
test "explicit named outer aliases retain the parent type index" {
  for scope in ["instance", "component"] {
    let parsed = @component.parse_component(
      parse_component_wat(
        "(component (type u32) (type $r u64) (type (" +
        scope +
        " (alias outer 1 $r (type $r)) (type (func (param \"x\" $r))))))",
      ),
    )
    let mut aliases = 0
    match parsed.types[2] {
      InstanceType(declarations) =>
        for declaration in declarations {
          if declaration is AliasOuter(_, depth, index) {
            assert_eq(depth, 1)
            assert_eq(index, 1)
            aliases += 1
          }
        }
      ComponentType(declarations) =>
        for declaration in declarations {
          if declaration is AliasOuter(_, depth, index) {
            assert_eq(depth, 1)
            assert_eq(index, 1)
            aliases += 1
          }
        }
      _ => fail("missing inline scope")
    }
    assert_true(aliases >= 1)
  }
}
