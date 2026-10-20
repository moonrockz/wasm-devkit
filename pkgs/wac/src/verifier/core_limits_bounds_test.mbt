///|
fn wide_memory_core() -> Array[Byte] {
  // memory64 minimum 2^63 with one-byte pages.
  b"\x00asm\x01\x00\x00\x00\x05\x0d\x01\x0c\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00".to_array()
}

///|
fn limits_component(core : Array[Byte]) -> Bytes {
  Bytes::from_array(
    b"\x00asm\x0d\x00\x01\x00".to_array() + runtime_section(b'\x01', core),
  )
}

///|
test "core limits preserve binary component depth 256" {
  let mut bytes = limits_component(wide_memory_core())
  for _ in 0..<256 {
    bytes = nested_binary(bytes)
  }
  assert_true(@verifier.decode_component_package(bytes) is Ok(_))
  let errors = @verifier.decode_component_package(nested_binary(bytes)).unwrap_err()
  assert_eq(errors[0].code, "WAC-B002")
  assert_true(errors[0].message.contains("nesting"))
}

///|
test "core limits preserve binary control depth 256 and original validation" {
  for depth in [256, 257] {
    let body : Array[Byte] = [0]
    for _ in 0..<depth {
      body.append([2, 0x40])
    }
    for _ in 0..<(depth + 1) {
      body.push(0x0b)
    }
    let core = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00".to_array() +
      wide_memory_core()[8:].to_owned() +
      runtime_section(b'\x0a', [b'\x01'] + runtime_leb(body.length()) + body)
    let result = @verifier.decode_component_package(limits_component(core))
    if depth == 256 {
      assert_true(result is Ok(_))
    } else {
      assert_eq(result.unwrap_err()[0].code, "WAC-B002")
    }
  }
  let invalid = @verifier.decode_wat_component_package(
    "(component (core module (memory i64 9223372036854775808 (pagesize 1)) (func (result i64) i32.const 0)))",
  )
  assert_eq(invalid.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core limits preserve WAT control nesting 64" {
  for depth in [64, 65] {
    let text = "(component (core module (memory i64 18446744073709551615 (pagesize 1)) (func " +
      "block ".repeat(depth) +
      "end ".repeat(depth) +
      ")))"
    let result = @verifier.decode_wat_component_package(text)
    if depth == 64 {
      assert_true(result is Ok(_))
    } else {
      let error = result.unwrap_err()[0]
      assert_eq(error.code, "WAC-B002")
      assert_true(error.message.contains("64"))
    }
  }
}

///|
test "core limits preserve the million-step core validation allowance" {
  for count in [30, 2000] {
    let types = runtime_leb(count)
    for _ in 0..<count {
      types.append([0x60, 0, 0])
    }
    let core = b"\x00asm\x01\x00\x00\x00".to_array() +
      runtime_section(b'\x01', types) +
      wide_memory_core()[8:].to_owned()
    let bytes = limits_component(core)
    let result = @verifier.decode_component_package(bytes)
    if count == 30 {
      assert_eq(result.unwrap().bytes(), bytes)
    } else {
      let error = result.unwrap_err()[0]
      assert_eq(error.code, "WAC-B002")
      assert_true(
        error.message.contains("work") && error.message.contains("1000000"),
      )
    }
  }
}

///|
test "core limits reject overflowing WAT literals before retained compilation" {
  for
    desc in [
      "memory i64 18446744073709551616 (pagesize 1)", "memory i64 0x1ffffffffffffffff (pagesize 1)",
      "memory 4294967296 (pagesize 1)", "table i64 0x1ffffffffffffffff funcref",
      "table 4294967296 funcref", "memory i64 1 (pagesize 4294967296)",
    ] {
    for
      declaration in [
        "(" + desc + ")",
        "(import \"env\" \"value\" (" + desc + "))",
      ] {
      let error = @verifier.decode_wat_component_package(
          "(component (core module " + declaration + "))",
        ).unwrap_err()[0]
      assert_true(error.code.has_prefix("WAC-B"))
      assert_true(error.message.contains("unsigned width"), msg=error.render())
    }
  }
}

///|
test "core limits admit shared concrete global imports and definitions" {
  for
    declaration in [
      "(import \"env\" \"g\" (global (shared i32)))", "(global (import \"env\" \"g\") (shared i32))",
      "(global (export \"g\") (shared mut i32) (i32.const 0))",
    ] {
    assert_true(
      @verifier.decode_wat_component_package(
        "(component (core module " + declaration + "))",
      )
      is Ok(_),
    )
  }
}

///|
test "core limits law preserves arbitrary UInt64 contracts through WAT and binary" {
  @quickcheck.check(
    (limit : UInt64) => {
      let source = "(component (core module $m (memory (export \"memory\") i64 \{limit} \{limit} (pagesize 1)) (table (export \"table\") i64 \{limit} \{limit} funcref)) (export \"m\" (core module $m)))"
      let expected : @core_types.Module = {
        imports: [],
        exports: [
          {
            name: "memory",
            kind: Memory(limit, Some(limit), true, false, Some(0)),
          },
          {
            name: "table",
            kind: Table(
              Reference(true, "func"),
              limit,
              Some(limit),
              true,
              false,
            ),
          },
        ],
      }
      match @verifier.decode_wat_component_package(source) {
        Ok(model) => {
          let roundtrip = match
            @verifier.decode_component_package(model.bytes()) {
            Ok(again) =>
              again.types().any(type_ => type_.kind == Module(expected))
            Err(_) => false
          }
          model.types().any(type_ => type_.kind == Module(expected)) &&
          roundtrip
        }
        Err(_) => false
      }
    },
    count=128,
    max_size=64,
    seed=122,
  )
}

///|
test "core limits newly admitted UInt64 modules print valid unsigned WAT" {
  for
    declaration in [
      "(memory (export \"value\") i64 9223372036854775808 18446744073709551615 (pagesize 1))",
      "(table (export \"value\") i64 9223372036854775808 18446744073709551615 funcref)",
    ] {
    let model = assert_package(
      "(component (core module $m " +
      declaration +
      ") (export \"m\" (core module $m)))",
      "limits.wat",
    )
    for compatibility in [None, Some(@decompiler.Compatibility::WasmTools)] {
      let printed = @decompiler.print_component(model.bytes(), compatibility~)
        .unwrap()
        .root().text
      let again = assert_package(printed, "printed.wat")
      assert_eq(binary_projection(again), binary_projection(model))
      assert_true(printed.contains("9223372036854775808 18446744073709551615"))
    }
  }
}
