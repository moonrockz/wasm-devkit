///|
fn shared_global_core() -> Array[Byte] {
  b"\x00asm\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x00\x0b".to_array()
}

///|
test "shared globals retain component depth 256" {
  let mut bytes = limits_component(shared_global_core())
  for _ in 0..<256 {
    bytes = nested_binary(bytes)
  }
  assert_true(@verifier.decode_component_package(bytes) is Ok(_))
  let error = @verifier.decode_component_package(nested_binary(bytes)).unwrap_err()[0]
  assert_eq(error.code, "WAC-B002")
  assert_true(error.message.contains("nesting"))
}

///|
test "shared globals retain binary control depth and validation budget" {
  for depth in [256, 257] {
    let body : Array[Byte] = [0]
    for _ in 0..<depth {
      body.append([2, 0x40])
    }
    for _ in 0..<(depth + 1) {
      body.push(0x0b)
    }
    let core = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00".to_array() +
      shared_global_core()[8:].to_owned() +
      runtime_section(b'\x0a', [b'\x01'] + runtime_leb(body.length()) + body)
    let result = @verifier.decode_component_package(limits_component(core))
    if depth == 256 {
      assert_true(result is Ok(_))
    } else {
      assert_eq(result.unwrap_err()[0].code, "WAC-B002")
    }
  }
  for count in [30, 2000] {
    let types = runtime_leb(count)
    for _ in 0..<count {
      types.append([0x60, 0, 0])
    }
    let core = b"\x00asm\x01\x00\x00\x00".to_array() +
      runtime_section(b'\x01', types) +
      shared_global_core()[8:].to_owned()
    let bytes = limits_component(core)
    let result = @verifier.decode_component_package(bytes)
    if count == 30 {
      assert_eq(result.unwrap().bytes(), bytes)
    } else {
      let error = result.unwrap_err()[0]
      assert_eq(error.code, "WAC-B002")
      assert_true(
        error.message.contains("1000000") && error.message.contains("work"),
      )
    }
  }
}

///|
test "shared globals retain WAT control depth 64" {
  for depth in [64, 65] {
    let source = "(component (core module (global (shared i32) (i32.const 0)) (func " +
      "block ".repeat(depth) +
      "end ".repeat(depth) +
      ")))"
    let result = @verifier.decode_wat_component_package(source)
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
test "shared global printing preserves imported and defined flags" {
  let source = "(component (core module $m (import \"env\" \"g\" (global $g (shared i32))) (global (export \"g\") (shared mut i64) (i64.const 0)) (export \"imported\" (global $g))) (export \"m\" (core module $m)))"
  let model = assert_package(source, "shared.wat")
  let unsupported = @decompiler.print_core_module(
    Bytes::from_array(shared_global_core()),
    compatibility=Some(@decompiler.Compatibility::Wabt),
  ).unwrap_err()
  assert_true(unsupported[0].message.contains("shared globals"))
  for compatibility in [None, Some(@decompiler.Compatibility::WasmTools)] {
    let text = @decompiler.print_component(model.bytes(), compatibility~)
      .unwrap()
      .root().text
    let again = assert_package(text, "printed.wat")
    assert_eq(binary_projection(again), binary_projection(model))
    assert_true(text.contains("shared"))
  }
}

///|
test "shared global contract round trip law" {
  @quickcheck.check(
    (sample : (Int32, Bool, Bool)) => {
      let (value, mutable, shared) = sample
      let type_ = if mutable { "(mut i32)" } else { "i32" }
      let type_ = if shared { "(shared " + type_ + ")" } else { type_ }
      let source = "(component (core module $m (global (export \"g\") " +
        type_ +
        " (i32.const " +
        value.to_string() +
        "))) (export \"m\" (core module $m)))"
      let expected : @core_types.Module = {
        imports: [],
        exports: [{ name: "g", kind: Global(Scalar("i32"), mutable, shared), }],
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
    seed=123,
  )
}
