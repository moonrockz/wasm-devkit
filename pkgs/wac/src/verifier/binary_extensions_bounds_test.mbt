///|
fn extension_uleb(value : Int32) -> Bytes {
  let bytes = []
  let mut value = value
  while value >= 128 {
    bytes.push(((value & 127) | 128).to_byte())
    value = value >> 7
  }
  bytes.push(value.to_byte())
  Bytes::from_array(bytes)
}

///|
fn extension_component(body : Bytes, locals~ : Bytes = b"\x00") -> Bytes {
  let code = locals + body + b"\x0b"
  let payload = b"\x01" + extension_uleb(code.length()) + code
  let module_ = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a" +
    extension_uleb(payload.length()) +
    payload
  b"\x00asm\x0d\x00\x01\x00\x01" + extension_uleb(module_.length()) + module_
}

///|
test "GC and EH malformed immediates fail atomically" {
  for
    body in [
      b"\xfb\x18\x04\x00\x6e\x6d", // reserved branch-cast flag
       b"\xfb\x18\x00\x00", // missing heap types
       b"\xfb\x00\x80\x80\x80\x80\x80", // unterminated type index
       b"\x1f\x40\x01\x04", // unknown handler kind
       b"\x1f\x40\x01\x00", // truncated catch tag/depth
       b"\x07\x00", // catch outside legacy try
       b"\x19", // catch_all outside legacy try
       b"\x18\x00", // delegate outside legacy try
       b"\x06\x40\x19\x07\x00\x0b", // catch after catch_all
       b"\x06\x40\x19\x18\x00", // delegate after catch_all
       b"\xfb\x1f", // excluded GC opcode
       b"\xfe\x71", // excluded shared-everything opcode
    ] {
    let bytes = extension_component(body)
    let verified = @verifier.decode_component_package(bytes)
    assert_true(verified is Err(_))
    assert_eq(verified.unwrap_err().length(), 1)
    assert_false(verified.unwrap_err()[0].message.is_empty())
    let printed = @decompiler.print_component(bytes)
    assert_true(printed is Err(_))
    assert_eq(printed.unwrap_err().length(), 1)
  }
}

///|
test "exception binary control depth remains 256" {
  for (head, tail) in [(b"\x06\x40", b"\x0b"), (b"\x1f\x40\x00", b"\x0b")] {
    for depth in [256, 257] {
      let body = []
      for _ in 0..<depth {
        body.append(head.to_array())
      }
      for _ in 0..<depth {
        body.append(tail.to_array())
      }
      let bytes = extension_component(Bytes::from_array(body))
      let result = @verifier.decode_component_package(bytes)
      assert_eq(result is Ok(_), depth == 256)
      assert_eq(@decompiler.print_component(bytes) is Ok(_), depth == 256)
      if depth == 257 {
        assert_eq(result.unwrap_err()[0].code, "WAC-B002")
        assert_true(result.unwrap_err()[0].message.contains("256"))
      }
    }
  }
}

///|
test "legacy catch local-state work is charged per arm" {
  let body = [b'\x06', b'\x40']
  for _ in 0..<600 {
    body.append([b'\x07', b'\x00'])
  }
  body.push(b'\x0b')
  // No tag section is needed: framing rejects the work estimate first.
  let locals = b"\x01" + extension_uleb(2000) + b"\x7f"
  let bytes = extension_component(Bytes::from_array(body), locals~)
  let result = @verifier.decode_component_package(bytes)
  assert_true(result is Err(_))
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
  assert_true(result.unwrap_err()[0].message.contains("1000000"))
}

///|
test "invalid structured constant initializers return diagnostics" {
  for
    source in [
      "(component (core module (global i32 (block (param i32) (result i32)))))",
      "(component (core module (type (array i32)) (global (ref 0) (try (param i32) (result (ref 0)) end))))",
    ] {
    assert_true(@verifier.decode_wat_component_package(source) is Err(_))
  }
}

///|
test "exception WAT control depth remains bounded" {
  for keyword in ["try", "try_table"] {
    let small = "(component (core module (func " +
      (keyword + " ").repeat(60) +
      "nop " +
      "end ".repeat(60) +
      ")))"
    let large = "(component (core module (func " +
      (keyword + " ").repeat(65) +
      "nop " +
      "end ".repeat(65) +
      ")))"
    let accepted = @verifier.decode_wat_component_package(small)
    assert_true(
      accepted is Ok(_),
      msg=match accepted {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    let rejected = @verifier.decode_wat_component_package(large)
    assert_true(rejected is Err(_))
    assert_eq(rejected.unwrap_err()[0].code, "WAC-B002")
    assert_true(rejected.unwrap_err()[0].message.contains("64"))
  }
}

///|
test "unsupported WAT instructions cannot become unreachable placeholders" {
  for
    source in [
      "(component (core module (func (result v128) i32.const 0 i32x4.splat)))", "(component (core module (global v128 (i32x4.splat (i32.const 0)))))",
    ] {
    let result = @verifier.decode_wat_component_package(source)
    assert_true(result is Err(_))
    assert_eq(result.unwrap_err()[0].code, "WAC-B002")
    assert_true(result.unwrap_err()[0].message.contains("cannot be encoded"))
  }
}
