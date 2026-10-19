///|
test "canonical intrinsic flags reject malformed bytes before parsing" {
  for flag in 0..<256 {
    let bytes = b"\x00asm\x0d\x00\x01\x00\x08\x03\x01\x06" +
      Bytes::from_array([flag.to_byte()])
    let result = @verifier.decode_component_package(bytes)
    if flag <= 1 {
      assert_true(result is Ok(_))
    } else {
      assert_eq(result.unwrap_err()[0].code, "WAC-B001")
    }
  }
  for tag in [0x20, 0x21] {
    for flag in 1..<256 {
      let bytes = b"\x00asm\x0d\x00\x01\x00\x08\x04\x01" +
        Bytes::from_array([tag.to_byte(), flag.to_byte(), 0])
      let errors = @verifier.decode_component_package(bytes).unwrap_err()
      assert_eq(errors[0].code, if flag == 1 { "WAC-B002" } else { "WAC-B001" })
    }
  }
}

///|
test "canonical intrinsic truncated immediates never produce models" {
  for
    payload in [
      b"\x01\x06\x00", b"\x01\x11\x00\x01", b"\x01\x20\x00\x00", b"\x01\x01\x00\x00\x01\x08\x00",
    ] {
    let bytes = b"\x00asm\x0d\x00\x01\x00\x08" +
      Bytes::from_array([payload.length().to_byte()]) +
      payload
    for end in 9..<bytes.length() {
      let result = @verifier.decode_component_package(bytes[:end].to_owned())
      assert_eq(result.unwrap_err()[0].code, "WAC-B001")
    }
  }
}

///|
test "canonical intrinsics preserve component depth limits" {
  let leaf = b"\x00asm\x0d\x00\x01\x00\x08\x02\x01\x05"
  let mut bytes = leaf
  for _ in 0..<256 {
    bytes = nested_binary(bytes)
  }
  let model = @verifier.decode_component_package(bytes).unwrap()
  assert_eq(model.bytes(), bytes)
  assert_eq(
    binary_projection(model),
    binary_projection(@verifier.decode_component_package(leaf).unwrap()),
  )
  assert_eq(
    @verifier.decode_component_package(nested_binary(bytes)).unwrap_err()[0].code,
    "WAC-B002",
  )
  let text = "(component ".repeat(253) +
    "(component (core func (canon task.cancel)))" +
    ")".repeat(253)
  let result = @verifier.decode_wat_component_package(text)
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(
    @verifier.decode_wat_component_package("(component " + text + ")").unwrap_err()[0].code,
    "WAC-B002",
  )
}

///|
test "GC scalar ABI does not accept flattened aggregates" {
  let message = assert_rejected(
    "(component (type $t (tuple u32)) (core type $ct (func (param i32))) (import \"f\" (func $f (param \"x\" $t))) (core func (canon lower (func $f) gc (core-type $ct))))",
    "gc-tuple.wat", "WAC-B002",
  )
  assert_true(message.contains("canonical"))
}

///|
test "async component type without async option uses synchronous flat ABI" {
  let _ = assert_package(
    "(component (import \"f\" (func $f async (param \"a\" u32) (param \"b\" u32) (param \"c\" u32) (param \"d\" u32) (param \"e\" u32) (result u32))) (core func $f (canon lower (func $f))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32 i32 i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    "sync-option-async-type.wat",
  )
}

///|
test "canonical WAT rejects flags and duplicate waitable memories" {
  for
    text in [
      "(component (core func (canon subtask.cancel cancellable)))", "(component (type $t (stream)) (core func (canon stream.cancel-read $t cancellable)))",
      "(component (type $t (future)) (core func (canon future.cancel-write $t cancellable)))",
      "(component (core func (canon waitable-set.wait (memory 0) (memory 1))))",
    ] {
    let _ = assert_rejected(text, "canon-options.wat", "WAC-B002")
  }
}
