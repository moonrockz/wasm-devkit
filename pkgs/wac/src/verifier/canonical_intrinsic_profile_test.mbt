///|
test "canonical intrinsic profile task.cancel" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x05\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="task.cancel.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon task.cancel)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="task.cancel.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile task.cancel-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x05\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="task.cancel-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon task.cancel)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="task.cancel-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile backpressure.inc" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x24\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="backpressure.inc.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon backpressure.inc)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="backpressure.inc.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile backpressure.inc-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x24\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="backpressure.inc-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon backpressure.inc)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="backpressure.inc-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile backpressure.dec" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x25\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="backpressure.dec.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon backpressure.dec)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="backpressure.dec.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile backpressure.dec-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x25\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="backpressure.dec-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon backpressure.dec)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="backpressure.dec-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile subtask.drop" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x0d\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="subtask.drop.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon subtask.drop)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="subtask.drop.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile subtask.drop-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x0d\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="subtask.drop-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon subtask.drop)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="subtask.drop-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile subtask.cancel" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x06\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="subtask.cancel.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon subtask.cancel)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="subtask.cancel.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile subtask.cancel-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x06\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="subtask.cancel-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon subtask.cancel)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="subtask.cancel-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile subtask.cancel-async" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x06\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="subtask.cancel-async.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon subtask.cancel async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="subtask.cancel-async.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile subtask.cancel-async-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x06\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="subtask.cancel-async-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon subtask.cancel async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="subtask.cancel-async-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable-set.new" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x1f\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable-set.new.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable-set.new)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.new.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable-set.new-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x1f\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable-set.new-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable-set.new)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.new-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable-set.drop" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x22\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable-set.drop.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable-set.drop)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.drop.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable-set.drop-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x22\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable-set.drop-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable-set.drop)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.drop-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable.join" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x23\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable.join.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable.join)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable.join.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable.join-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x23\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable.join-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable.join)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable.join-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile error-context.drop" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x1e\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="error-context.drop.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon error-context.drop)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="error-context.drop.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile error-context.drop-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x1e\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="error-context.drop-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon error-context.drop)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="error-context.drop-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.new" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.new.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.new.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.new-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.new-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.new-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.drop-readable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x13\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.drop-readable.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.drop-readable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.drop-readable.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.drop-readable-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x13\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.drop-readable-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.drop-readable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.drop-readable-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.drop-writable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x14\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.drop-writable.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.drop-writable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.drop-writable.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.drop-writable-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x14\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.drop-writable-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.drop-writable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.drop-writable-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.cancel-read" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x11\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-read.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-read $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-read.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.cancel-read-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x11\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-read-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-read $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-read-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.cancel-write" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x12\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-write.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-write $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-write.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.cancel-write-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x12\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-write-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-write $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-write-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.cancel-read-async" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x11\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-read-async.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-read $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-read-async.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.cancel-read-async-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x11\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-read-async-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-read $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-read-async-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream.cancel-write-async" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x12\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-write-async.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-write $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-write-async.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "stream", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile stream.cancel-write-async-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x12\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream.cancel-write-async-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.cancel-write $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream.cancel-write-async-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.new" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x15\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.new.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.new.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.new-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x15\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.new-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.new-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.drop-readable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x1a\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.drop-readable.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.drop-readable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.drop-readable.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.drop-readable-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x1a\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.drop-readable-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.drop-readable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.drop-readable-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.drop-writable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x1b\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.drop-writable.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.drop-writable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.drop-writable.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.drop-writable-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x1b\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.drop-writable-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.drop-writable $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.drop-writable-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.cancel-read" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x18\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-read.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-read $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-read.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.cancel-read-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x18\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-read-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-read $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-read-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.cancel-write" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x19\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-write.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-write $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-write.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.cancel-write-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x19\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-write-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-write $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-write-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.cancel-read-async" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x18\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-read-async.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-read $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-read-async.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.cancel-read-async-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x18\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-read-async-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-read $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-read-async-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future.cancel-write-async" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x19\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-write-async.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-write $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-write-async.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "t", "type", "future", "some", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "future", "some", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future.cancel-write-async-wrong-core" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x04\x01\x19\x00\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future.cancel-write-async-wrong-core.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32)) (export \"t\" (type $t))  (core func $f (canon future.cancel-write $t async)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future.cancel-write-async-wrong-core.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable-set.wait-32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x20\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    source_id="waitable-set.wait-32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $mem (memory (export \"memory\") 1)) (core instance $mem (instantiate $mem)) (alias core export $mem \"memory\" (core memory $memory)) (core func $f (canon waitable-set.wait (memory $memory))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.wait-32.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable-set.wait-64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x04\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x20\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    source_id="waitable-set.wait-64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $mem (memory (export \"memory\") i64 1)) (core instance $mem (instantiate $mem)) (alias core export $mem \"memory\" (core memory $memory)) (core func $f (canon waitable-set.wait (memory $memory))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.wait-64.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable-set.wait-missing-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x04\x01\x20\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable-set.wait-missing-memory.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable-set.wait (memory 0))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.wait-missing-memory.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable-set.wait-shared-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x03\x01\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x20\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    source_id="waitable-set.wait-shared-memory.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $mem (memory (export \"memory\") 1 1 shared)) (core instance $mem (instantiate $mem)) (alias core export $mem \"memory\" (core memory $memory)) (core func $f (canon waitable-set.wait (memory $memory))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.wait-shared-memory.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable-set.poll-32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x21\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    source_id="waitable-set.poll-32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $mem (memory (export \"memory\") 1)) (core instance $mem (instantiate $mem)) (alias core export $mem \"memory\" (core memory $memory)) (core func $f (canon waitable-set.poll (memory $memory))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.poll-32.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable-set.poll-64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x04\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x21\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    source_id="waitable-set.poll-64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $mem (memory (export \"memory\") i64 1)) (core instance $mem (instantiate $mem)) (alias core export $mem \"memory\" (core memory $memory)) (core func $f (canon waitable-set.poll (memory $memory))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.poll-64.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile waitable-set.poll-missing-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x04\x01\x21\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="waitable-set.poll-missing-memory.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon waitable-set.poll (memory 0))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.poll-missing-memory.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile waitable-set.poll-shared-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x03\x01\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x21\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    source_id="waitable-set.poll-shared-memory.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $mem (memory (export \"memory\") 1 1 shared)) (core instance $mem (instantiate $mem)) (alias core export $mem \"memory\" (core memory $memory)) (core func $f (canon waitable-set.poll (memory $memory))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32 i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="waitable-set.poll-shared-memory.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream-wrong-u32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream-wrong-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t u32)  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream-wrong-u32.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream-wrong-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream-wrong-resource.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (resource (rep i32)))  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream-wrong-resource.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream-wrong-other" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream-wrong-other.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future u32))  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream-wrong-other.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream-wrong-later" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x07\x04\x01\x66\x01\x79\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream-wrong-later.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon stream.new 0)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) (type $t (stream u32)))",
    source_id="stream-wrong-later.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future-wrong-u32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x08\x03\x01\x15\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future-wrong-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t u32)  (core func $f (canon future.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future-wrong-u32.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future-wrong-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x15\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future-wrong-resource.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (resource (rep i32)))  (core func $f (canon future.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future-wrong-resource.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future-wrong-other" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x08\x03\x01\x15\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future-wrong-other.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream u32))  (core func $f (canon future.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future-wrong-other.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile future-wrong-later" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x15\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x07\x04\x01\x65\x01\x79\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
    source_id="future-wrong-later.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component   (core func $f (canon future.new 0)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) (type $t (future u32)))",
    source_id="future-wrong-later.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x06\x02\x69\x00\x66\x01\x01\x0b\x07\x01\x00\x01\x74\x03\x02\x00\x08\x03\x01\x0e\x02\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x0d\x03\x03\x00\x01\x72\x01\x03\x6f\x77\x6e\x02\x01\x74",
    source_id="stream-resource.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (type $own (own $r)) (type $t (stream $own)) (export \"t\" (type $t))  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="stream-resource.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "t", "type", "stream",
    "some", "own", "0", "instance", "interface", "", "0", "1", "t", "type", "stream",
    "some", "own", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile future-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x06\x02\x69\x00\x65\x01\x01\x0b\x07\x01\x00\x01\x74\x03\x02\x00\x08\x03\x01\x15\x02\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x0d\x03\x03\x00\x01\x72\x01\x03\x6f\x77\x6e\x02\x01\x74",
    source_id="future-resource.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (type $own (own $r)) (type $t (future $own)) (export \"t\" (type $t))  (core func $f (canon future.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    source_id="future-resource.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "t", "type", "future",
    "some", "own", "0", "instance", "interface", "", "0", "1", "t", "type", "future",
    "some", "own", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lift-scalars" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x38\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x11\x01\x60\x0c\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7e\x7e\x7d\x7c\x7f\x01\x7e\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x37\x01\x40\x0c\x02\x70\x30\x7f\x02\x70\x31\x7e\x02\x70\x32\x7d\x02\x70\x33\x7c\x02\x70\x34\x7b\x02\x70\x35\x7a\x02\x70\x36\x79\x02\x70\x37\x78\x02\x70\x38\x77\x02\x70\x39\x76\x03\x70\x31\x30\x75\x03\x70\x31\x31\x74\x00\x77\x08\x07\x01\x00\x00\x00\x01\x09\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
    source_id="gc-lift-scalars.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $m (func (export \"f\") (param i32 i32 i32 i32 i32 i32 i32 i64 i64 f32 f64 i32) (result i64) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" bool) (param \"p1\" s8) (param \"p2\" u8) (param \"p3\" s16) (param \"p4\" u16) (param \"p5\" s32) (param \"p6\" u32) (param \"p7\" s64) (param \"p8\" u64) (param \"p9\" f32) (param \"p10\" f64) (param \"p11\" char) (result u64) (canon lift (core func $f) gc)))",
    source_id="gc-lift-scalars.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "12", "p0", "scalar",
    "bool", "p1", "scalar", "s8", "p2", "scalar", "u8", "p3", "scalar", "s16", "p4",
    "scalar", "u16", "p5", "scalar", "s32", "p6", "scalar", "u32", "p7", "scalar",
    "s64", "p8", "scalar", "u64", "p9", "scalar", "f32", "p10", "scalar", "f64",
    "p11", "scalar", "char", "some", "scalar", "u64", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "12", "p0", "scalar", "bool", "p1",
    "scalar", "s8", "p2", "scalar", "u8", "p3", "scalar", "s16", "p4", "scalar",
    "u16", "p5", "scalar", "s32", "p6", "scalar", "u32", "p7", "scalar", "s64", "p8",
    "scalar", "u64", "p9", "scalar", "f32", "p10", "scalar", "f64", "p11", "scalar",
    "char", "some", "scalar", "u64", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lower-scalars" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x11\x01\x60\x0c\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7e\x7e\x7d\x7c\x7f\x01\x7e\x07\x37\x01\x40\x0c\x02\x70\x30\x7f\x02\x70\x31\x7e\x02\x70\x32\x7d\x02\x70\x33\x7c\x02\x70\x34\x7b\x02\x70\x35\x7a\x02\x70\x36\x79\x02\x70\x37\x78\x02\x70\x38\x77\x02\x70\x39\x76\x03\x70\x31\x30\x75\x03\x70\x31\x31\x74\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-scalars.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32 i32 i32 i32 i32 i32 i32 i64 i64 f32 f64 i32) (result i64))) (import \"f\" (func $f  (param \"p0\" bool) (param \"p1\" s8) (param \"p2\" u8) (param \"p3\" s16) (param \"p4\" u16) (param \"p5\" s32) (param \"p6\" u32) (param \"p7\" s64) (param \"p8\" u64) (param \"p9\" f32) (param \"p10\" f64) (param \"p11\" char) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct))))",
    source_id="gc-lower-scalars.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "f", "func", "function", "false", "12", "p0", "scalar",
    "bool", "p1", "scalar", "s8", "p2", "scalar", "u8", "p3", "scalar", "s16", "p4",
    "scalar", "u16", "p5", "scalar", "s32", "p6", "scalar", "u32", "p7", "scalar",
    "s64", "p8", "scalar", "u64", "p9", "scalar", "f32", "p10", "scalar", "f64",
    "p11", "scalar", "char", "some", "scalar", "u64", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lift-many" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x40\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x19\x01\x60\x14\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x5f\x01\x40\x14\x02\x70\x30\x79\x02\x70\x31\x79\x02\x70\x32\x79\x02\x70\x33\x79\x02\x70\x34\x79\x02\x70\x35\x79\x02\x70\x36\x79\x02\x70\x37\x79\x02\x70\x38\x79\x02\x70\x39\x79\x03\x70\x31\x30\x79\x03\x70\x31\x31\x79\x03\x70\x31\x32\x79\x03\x70\x31\x33\x79\x03\x70\x31\x34\x79\x03\x70\x31\x35\x79\x03\x70\x31\x36\x79\x03\x70\x31\x37\x79\x03\x70\x31\x38\x79\x03\x70\x31\x39\x79\x00\x79\x08\x07\x01\x00\x00\x00\x01\x09\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
    source_id="gc-lift-many.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $m (func (export \"f\") (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" u32) (param \"p1\" u32) (param \"p2\" u32) (param \"p3\" u32) (param \"p4\" u32) (param \"p5\" u32) (param \"p6\" u32) (param \"p7\" u32) (param \"p8\" u32) (param \"p9\" u32) (param \"p10\" u32) (param \"p11\" u32) (param \"p12\" u32) (param \"p13\" u32) (param \"p14\" u32) (param \"p15\" u32) (param \"p16\" u32) (param \"p17\" u32) (param \"p18\" u32) (param \"p19\" u32) (result u32) (canon lift (core func $f) gc)))",
    source_id="gc-lift-many.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "20", "p0", "scalar",
    "u32", "p1", "scalar", "u32", "p2", "scalar", "u32", "p3", "scalar", "u32", "p4",
    "scalar", "u32", "p5", "scalar", "u32", "p6", "scalar", "u32", "p7", "scalar",
    "u32", "p8", "scalar", "u32", "p9", "scalar", "u32", "p10", "scalar", "u32",
    "p11", "scalar", "u32", "p12", "scalar", "u32", "p13", "scalar", "u32", "p14",
    "scalar", "u32", "p15", "scalar", "u32", "p16", "scalar", "u32", "p17", "scalar",
    "u32", "p18", "scalar", "u32", "p19", "scalar", "u32", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "20",
    "p0", "scalar", "u32", "p1", "scalar", "u32", "p2", "scalar", "u32", "p3", "scalar",
    "u32", "p4", "scalar", "u32", "p5", "scalar", "u32", "p6", "scalar", "u32", "p7",
    "scalar", "u32", "p8", "scalar", "u32", "p9", "scalar", "u32", "p10", "scalar",
    "u32", "p11", "scalar", "u32", "p12", "scalar", "u32", "p13", "scalar", "u32",
    "p14", "scalar", "u32", "p15", "scalar", "u32", "p16", "scalar", "u32", "p17",
    "scalar", "u32", "p18", "scalar", "u32", "p19", "scalar", "u32", "some", "scalar",
    "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lower-many" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x01\x60\x14\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x01\x7f\x07\x5f\x01\x40\x14\x02\x70\x30\x79\x02\x70\x31\x79\x02\x70\x32\x79\x02\x70\x33\x79\x02\x70\x34\x79\x02\x70\x35\x79\x02\x70\x36\x79\x02\x70\x37\x79\x02\x70\x38\x79\x02\x70\x39\x79\x03\x70\x31\x30\x79\x03\x70\x31\x31\x79\x03\x70\x31\x32\x79\x03\x70\x31\x33\x79\x03\x70\x31\x34\x79\x03\x70\x31\x35\x79\x03\x70\x31\x36\x79\x03\x70\x31\x37\x79\x03\x70\x31\x38\x79\x03\x70\x31\x39\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-many.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32) (result i32))) (import \"f\" (func $f  (param \"p0\" u32) (param \"p1\" u32) (param \"p2\" u32) (param \"p3\" u32) (param \"p4\" u32) (param \"p5\" u32) (param \"p6\" u32) (param \"p7\" u32) (param \"p8\" u32) (param \"p9\" u32) (param \"p10\" u32) (param \"p11\" u32) (param \"p12\" u32) (param \"p13\" u32) (param \"p14\" u32) (param \"p15\" u32) (param \"p16\" u32) (param \"p17\" u32) (param \"p18\" u32) (param \"p19\" u32) (result u32))) (core func $lower (canon lower (func $f) gc (core-type $ct))))",
    source_id="gc-lower-many.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "f", "func", "function", "false", "20", "p0", "scalar",
    "u32", "p1", "scalar", "u32", "p2", "scalar", "u32", "p3", "scalar", "u32", "p4",
    "scalar", "u32", "p5", "scalar", "u32", "p6", "scalar", "u32", "p7", "scalar",
    "u32", "p8", "scalar", "u32", "p9", "scalar", "u32", "p10", "scalar", "u32",
    "p11", "scalar", "u32", "p12", "scalar", "u32", "p13", "scalar", "u32", "p14",
    "scalar", "u32", "p15", "scalar", "u32", "p16", "scalar", "u32", "p17", "scalar",
    "u32", "p18", "scalar", "u32", "p19", "scalar", "u32", "some", "scalar", "u32",
    "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lift-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7e\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x08\x07\x01\x00\x00\x00\x01\x09\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
    source_id="gc-lift-mismatch.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core module $m (func (export \"f\") (param i64) (result i64) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" u32) (result u64) (canon lift (core func $f) gc)))",
    source_id="gc-lift-mismatch.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-lower-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7e\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-mismatch.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i64) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct))))",
    source_id="gc-lower-mismatch.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-lower-no-type" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x06\x01\x01\x00\x00\x01\x09\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-no-type.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc)))",
    source_id="gc-lower-no-type.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile core-type-no-gc" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x07\x01\x01\x00\x00\x01\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="core-type-no-gc.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) (core-type $ct))))",
    source_id="core-type-no-gc.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile core-type-on-lift" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x08\x09\x01\x00\x00\x00\x02\x09\x08\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
    source_id="core-type-on-lift.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $ct (func (param i32) (result i64))) (core module $m (func (export \"f\") (param i32) (result i64) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" u32) (result u64) (canon lift (core func $f) gc (core-type $ct))))",
    source_id="core-type-on-lift.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-duplicate" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x09\x01\x01\x00\x00\x03\x09\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-duplicate.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc gc (core-type $ct))))",
    source_id="gc-duplicate.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile core-type-duplicate" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x0a\x01\x01\x00\x00\x03\x09\x08\x00\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="core-type-duplicate.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct) (core-type $ct))))",
    source_id="core-type-duplicate.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile core-type-later" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x01\x03\x06\x01\x60\x01\x7f\x01\x7e\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="core-type-later.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type 1))) (core type (func (param i32) (result i64))))",
    source_id="core-type-later.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile core-type-module" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x08\x02\x50\x00\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x0c\x00\x10\x02\x00\x03\x6d\x6f\x64\x01\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="core-type-module.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $mod (module)) (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $mod))))",
    source_id="core-type-module.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-lower-async" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x43\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x09\x01\x01\x00\x00\x03\x09\x08\x00\x06\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-async.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f async (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct) async)))",
    source_id="gc-lower-async.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "f", "func", "function", "true", "1", "p0", "scalar",
    "u32", "some", "scalar", "u64", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lower-async-sync-type" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x09\x01\x01\x00\x00\x03\x09\x08\x00\x06\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-async-sync-type.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct) async)))",
    source_id="gc-lower-async-sync-type.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B003", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-lower-sync-async-type" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x43\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-sync-async-type.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f async (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct))))",
    source_id="gc-lower-sync-async-type.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "f", "func", "function", "true", "1", "p0", "scalar",
    "u32", "some", "scalar", "u64", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-aggregate-unsupported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x65\x00\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x03\x05\x01\x60\x01\x6f\x00\x07\x08\x01\x40\x01\x01\x70\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="gc-aggregate-unsupported.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (future)) (export \"t\" (type $t)) (core type $ct (func (param externref))) (import \"f\" (func $f (param \"p\" $t))) (core func (canon lower (func $f) gc (core-type $ct))))",
    source_id="gc-aggregate-unsupported.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B002", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile task-return-unsupported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x05\x01\x09\x01\x00\x00",
    source_id="task-return-unsupported.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core func (canon task.return)))",
    source_id="task-return-unsupported.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B002", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile stream-read-unsupported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x66\x00\x08\x05\x01\x0f\x00\x01\x06\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x74",
    source_id="stream-read-unsupported.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (stream)) (core func (canon stream.read $t async)))",
    source_id="stream-read-unsupported.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B002", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile context-get-unsupported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x04\x01\x0a\x7f\x00",
    source_id="context-get-unsupported.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core func (canon context.get i32 0)))",
    source_id="context-get-unsupported.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B002", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-lift-tuple-unsupported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x6f\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x09\x01\x40\x01\x02\x70\x30\x00\x01\x00\x08\x07\x01\x00\x00\x00\x01\x09\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x74",
    source_id="gc-lift-tuple-unsupported.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (tuple u32)) (export \"t\" (type $t)) (core module $m (func (export \"f\") (param i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" $t)  (canon lift (core func $f) gc)))",
    source_id="gc-lift-tuple-unsupported.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("unsupported or invalid input accepted")
    }
    assert_eq(errors[0].code, "WAC-B002", msg=errors[0].render())
  }
}

///|
test "canonical intrinsic profile gc-lower-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x06\x06\x01\x00\x10\x02\x00\x00\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x01\x00\x32\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x0e\x00\x10\x02\x00\x02\x63\x74\x01\x05\x61\x6c\x69\x61\x73\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-alias.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component  (core type $ct (func (param i32) (result i64))) (alias outer 0 $ct (core type $alias)) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $alias))))",
    source_id="gc-lower-alias.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "1", "f", "func", "function", "false", "1", "p0", "scalar",
    "u32", "some", "scalar", "u64", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lower-outer" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x04\x50\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x06\x01\x00\x10\x02\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x10\x01\x00\x05\x61\x6c\x69\x61\x73\x01\x05\x01\x01\x00\x01\x66\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x00\x10\x01\x00\x02\x63\x74",
    source_id="gc-lower-outer.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $ct (func (param i32) (result i64))) (component (alias outer 1 $ct (core type $alias)) (import \"f\" (func $f (param \"x\" u32) (result u64))) (core func (canon lower (func $f) gc (core-type $alias)))))",
    source_id="gc-lower-outer.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lower-nested" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x5a\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x01\x60\x01\x7f\x01\x7e\x07\x09\x01\x40\x01\x02\x70\x30\x79\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
    source_id="gc-lower-nested.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (component  (core type $ct (func (param i32) (result i64))) (import \"f\" (func $f  (param \"p0\" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct)))))",
    source_id="gc-lower-nested.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lift-enum" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x01\x6d\x02\x01\x61\x01\x62\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x09\x01\x40\x01\x02\x70\x30\x01\x00\x01\x08\x07\x01\x00\x00\x00\x01\x09\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x0a\x03\x02\x00\x03\x72\x61\x77\x01\x01\x74",
    source_id="gc-lift-enum.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $raw (enum \"a\" \"b\")) (export $t \"t\" (type $raw)) (core module $m (func (export \"f\") (param i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" $t) (result $t) (canon lift (core func $f) gc)))",
    source_id="gc-lift-enum.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "2", "t", "type", "enum", "2", "a", "b", "f", "func",
    "function", "false", "1", "p0", "enum", "2", "a", "b", "some", "enum", "2", "a",
    "b", "instance", "interface", "", "0", "2", "t", "type", "enum", "2", "a", "b",
    "f", "func", "function", "false", "1", "p0", "enum", "2", "a", "b", "some", "enum",
    "2", "a", "b", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}

///|
test "canonical intrinsic profile gc-lift-flags" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x01\x6e\x02\x01\x61\x01\x62\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x09\x01\x40\x01\x02\x70\x30\x01\x00\x01\x08\x07\x01\x00\x00\x00\x01\x09\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x0a\x03\x02\x00\x03\x72\x61\x77\x01\x01\x74",
    source_id="gc-lift-flags.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $raw (flags \"a\" \"b\")) (export $t \"t\" (type $raw)) (core module $m (func (export \"f\") (param i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" $t) (result $t) (canon lift (core func $f) gc)))",
    source_id="gc-lift-flags.wat",
  )
  for result in [binary, text] {
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
  }
  let expected = [
    "world", "", "0", "0", "2", "t", "type", "flags", "2", "a", "b", "f", "func",
    "function", "false", "1", "p0", "flags", "2", "a", "b", "some", "flags", "2",
    "a", "b", "instance", "interface", "", "0", "2", "t", "type", "flags", "2", "a",
    "b", "f", "func", "function", "false", "1", "p0", "flags", "2", "a", "b", "some",
    "flags", "2", "a", "b", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
  assert_eq(
    binary_projection(
      @verifier.decode_component_package(
        text.unwrap().bytes(),
        source_id="roundtrip",
      ).unwrap(),
    ),
    expected,
  )
}
