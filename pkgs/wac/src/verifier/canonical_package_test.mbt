///|
test "synchronous canonical package empty" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="empty.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\"))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func)) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="empty.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "0", "none", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package scalar" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x07\x01\x05\x00\x20\x00\xac\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x7a\x00\x78\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="scalar.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32) (result i64) local.get 0 i64.extend_i32_s)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" s32) (result s64))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="scalar.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "s32", "some", "scalar", "s64", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "s32", "some", "scalar", "s64", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package bool" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x20\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x7f\x00\x7f\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="bool.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32) (result i32) local.get 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" bool) (result bool))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="bool.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "bool", "some", "scalar", "bool", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "scalar", "bool", "some", "scalar", "bool",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package wrong-parameter" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x7a\x01\x00\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="wrong-parameter.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" s32))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="wrong-parameter.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package wrong-result" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x42\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x05\x01\x40\x00\x00\x7a\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="wrong-result.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i64) i64.const 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (result s32))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="wrong-result.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package tuple" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7e\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x0c\x02\x6f\x02\x79\x77\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="tuple.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32 i64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (tuple u32 u64)))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="tuple.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "1", "x", "tuple",
    "2", "scalar", "u32", "scalar", "u64", "none", "instance", "interface", "", "0",
    "1", "f", "func", "function", "false", "1", "x", "tuple", "2", "scalar", "u32",
    "scalar", "u64", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package string-missing-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x73\x01\x00\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="string-missing-memory.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" string))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="string-missing-memory.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package string" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x08\x01\x40\x01\x01\x78\x73\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x4b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="string.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\") (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $t (func (param \"x\" string))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="string.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "string", "none", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "string", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package result-string" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x0e\x02\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x12\x02\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x07\x05\x01\x40\x00\x00\x73\x08\x08\x01\x00\x00\x00\x01\x03\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="result-string.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"f\") (result i32) i32.const 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (type $t (func (result string))) (func $f (type $t) (canon lift (core func $f) (memory $memory))) (export \"f\" (func $f)))",
    source_id="result-string.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "string", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "some", "scalar", "string", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package post-return" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x07\x0c\x02\x01\x66\x00\x00\x04\x70\x6f\x73\x74\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x10\x02\x00\x00\x01\x00\x01\x66\x00\x00\x01\x00\x04\x70\x6f\x73\x74\x07\x05\x01\x40\x00\x00\x79\x08\x08\x01\x00\x00\x00\x01\x05\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x3b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x00\x00\x02\x00\x01\x66\x01\x04\x70\x6f\x73\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="post-return.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 0) (func (export \"post\") (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"post\" (core func $post)) (type $t (func (result u32))) (func $f (type $t) (canon lift (core func $f) (post-return $post))) (export \"f\" (func $f)))",
    source_id="post-return.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "some", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package wrong-post-return" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x01\x7f\x60\x01\x7e\x00\x03\x03\x02\x00\x01\x07\x0c\x02\x01\x66\x00\x00\x04\x70\x6f\x73\x74\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x10\x02\x00\x00\x01\x00\x01\x66\x00\x00\x01\x00\x04\x70\x6f\x73\x74\x07\x05\x01\x40\x00\x00\x79\x08\x08\x01\x00\x00\x00\x01\x05\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x3b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x00\x00\x02\x00\x01\x66\x01\x04\x70\x6f\x73\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="wrong-post-return.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 0) (func (export \"post\") (param i64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"post\" (core func $post)) (type $t (func (result u32))) (func $f (type $t) (canon lift (core func $f) (post-return $post))) (export \"f\" (func $f)))",
    source_id="wrong-post-return.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package lower" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x05\x01\x01\x00\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x33\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x06\x07\x01\x00\x00\x01\x01\x01\x66\x08\x06\x01\x00\x00\x01\x00\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x00\x00\x48\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x00\x00\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x0b\x00\x12\x02\x00\x03\x65\x6e\x76\x01\x01\x69\x01\x0c\x01\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x05\x03\x01\x00\x01\x74",
    source_id="lower.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (func (param \"x\" u32) (result u32))) (import \"f\" (func $f (type $t))) (core func $f (canon lower (func $f))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func $f (param i32) (result i32))) (export \"f\" (func $f))) (core instance $i (instantiate $m (with \"env\" (instance $env)))) (alias core export $i \"f\" (core func $again)) (func $again (type $t) (canon lift (core func $again))) (export \"again\" (func $again)))",
    source_id="lower.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "u32", "1", "again", "func", "function", "false", "1",
    "x", "scalar", "u32", "some", "scalar", "u32", "instance", "interface", "", "0",
    "1", "again", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package wrong-lower" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x05\x01\x01\x00\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x33\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x06\x07\x01\x00\x00\x01\x01\x01\x66\x08\x06\x01\x00\x00\x01\x00\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x00\x00\x48\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x00\x00\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x0b\x00\x12\x02\x00\x03\x65\x6e\x76\x01\x01\x69\x01\x0c\x01\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x05\x03\x01\x00\x01\x74",
    source_id="wrong-lower.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (func (param \"x\" u32) (result u32))) (import \"f\" (func $f (type $t))) (core func $f (canon lower (func $f))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func $f (param i64) (result i32))) (export \"f\" (func $f))) (core instance $i (instantiate $m (with \"env\" (instance $env)))) (alias core export $i \"f\" (core func $again)) (func $again (type $t) (canon lift (core func $again))) (export \"again\" (func $again)))",
    source_id="wrong-lower.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package missing-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d",
    source_id="missing-argument.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"f\" (func))) (core instance (instantiate $m)))",
    source_id="missing-argument.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package missing-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x13\x00\x61\x73\x6d\x01\x00\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0d\x01\x00\x00\x01\x00\x07\x6d\x69\x73\x73\x69\x6e\x67\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
    source_id="missing-export.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m) (core instance $i (instantiate $m)) (alias core export $i \"missing\" (core func $f)))",
    source_id="missing-export.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package wrong-alias-sort" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x00\x07\x05\x01\x01\x6d\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x6d\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
    source_id="wrong-alias-sort.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"m\") 0)) (core instance $i (instantiate $m)) (alias core export $i \"m\" (core func $f)))",
    source_id="wrong-alias-sort.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package flags-0" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x0a\x02\x6e\x00\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="flags-0.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") )) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (flags )))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="flags-0.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package flags-1" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x0d\x02\x6e\x01\x02\x66\x30\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="flags-1.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (flags \"f0\")))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="flags-1.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package flags-32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x80\x01\x02\x6e\x20\x02\x66\x30\x02\x66\x31\x02\x66\x32\x02\x66\x33\x02\x66\x34\x02\x66\x35\x02\x66\x36\x02\x66\x37\x02\x66\x38\x02\x66\x39\x03\x66\x31\x30\x03\x66\x31\x31\x03\x66\x31\x32\x03\x66\x31\x33\x03\x66\x31\x34\x03\x66\x31\x35\x03\x66\x31\x36\x03\x66\x31\x37\x03\x66\x31\x38\x03\x66\x31\x39\x03\x66\x32\x30\x03\x66\x32\x31\x03\x66\x32\x32\x03\x66\x32\x33\x03\x66\x32\x34\x03\x66\x32\x35\x03\x66\x32\x36\x03\x66\x32\x37\x03\x66\x32\x38\x03\x66\x32\x39\x03\x66\x33\x30\x03\x66\x33\x31\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="flags-32.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (flags \"f0\" \"f1\" \"f2\" \"f3\" \"f4\" \"f5\" \"f6\" \"f7\" \"f8\" \"f9\" \"f10\" \"f11\" \"f12\" \"f13\" \"f14\" \"f15\" \"f16\" \"f17\" \"f18\" \"f19\" \"f20\" \"f21\" \"f22\" \"f23\" \"f24\" \"f25\" \"f26\" \"f27\" \"f28\" \"f29\" \"f30\" \"f31\")))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="flags-32.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package flags-33" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x84\x01\x02\x6e\x21\x02\x66\x30\x02\x66\x31\x02\x66\x32\x02\x66\x33\x02\x66\x34\x02\x66\x35\x02\x66\x36\x02\x66\x37\x02\x66\x38\x02\x66\x39\x03\x66\x31\x30\x03\x66\x31\x31\x03\x66\x31\x32\x03\x66\x31\x33\x03\x66\x31\x34\x03\x66\x31\x35\x03\x66\x31\x36\x03\x66\x31\x37\x03\x66\x31\x38\x03\x66\x31\x39\x03\x66\x32\x30\x03\x66\x32\x31\x03\x66\x32\x32\x03\x66\x32\x33\x03\x66\x32\x34\x03\x66\x32\x35\x03\x66\x32\x36\x03\x66\x32\x37\x03\x66\x32\x38\x03\x66\x32\x39\x03\x66\x33\x30\x03\x66\x33\x31\x03\x66\x33\x32\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="flags-33.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\")  (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (flags \"f0\" \"f1\" \"f2\" \"f3\" \"f4\" \"f5\" \"f6\" \"f7\" \"f8\" \"f9\" \"f10\" \"f11\" \"f12\" \"f13\" \"f14\" \"f15\" \"f16\" \"f17\" \"f18\" \"f19\" \"f20\" \"f21\" \"f22\" \"f23\" \"f24\" \"f25\" \"f26\" \"f27\" \"f28\" \"f29\" \"f30\" \"f31\" \"f32\")))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="flags-33.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package flags-64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x80\x02\x02\x6e\x40\x02\x66\x30\x02\x66\x31\x02\x66\x32\x02\x66\x33\x02\x66\x34\x02\x66\x35\x02\x66\x36\x02\x66\x37\x02\x66\x38\x02\x66\x39\x03\x66\x31\x30\x03\x66\x31\x31\x03\x66\x31\x32\x03\x66\x31\x33\x03\x66\x31\x34\x03\x66\x31\x35\x03\x66\x31\x36\x03\x66\x31\x37\x03\x66\x31\x38\x03\x66\x31\x39\x03\x66\x32\x30\x03\x66\x32\x31\x03\x66\x32\x32\x03\x66\x32\x33\x03\x66\x32\x34\x03\x66\x32\x35\x03\x66\x32\x36\x03\x66\x32\x37\x03\x66\x32\x38\x03\x66\x32\x39\x03\x66\x33\x30\x03\x66\x33\x31\x03\x66\x33\x32\x03\x66\x33\x33\x03\x66\x33\x34\x03\x66\x33\x35\x03\x66\x33\x36\x03\x66\x33\x37\x03\x66\x33\x38\x03\x66\x33\x39\x03\x66\x34\x30\x03\x66\x34\x31\x03\x66\x34\x32\x03\x66\x34\x33\x03\x66\x34\x34\x03\x66\x34\x35\x03\x66\x34\x36\x03\x66\x34\x37\x03\x66\x34\x38\x03\x66\x34\x39\x03\x66\x35\x30\x03\x66\x35\x31\x03\x66\x35\x32\x03\x66\x35\x33\x03\x66\x35\x34\x03\x66\x35\x35\x03\x66\x35\x36\x03\x66\x35\x37\x03\x66\x35\x38\x03\x66\x35\x39\x03\x66\x36\x30\x03\x66\x36\x31\x03\x66\x36\x32\x03\x66\x36\x33\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="flags-64.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\")  (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (flags \"f0\" \"f1\" \"f2\" \"f3\" \"f4\" \"f5\" \"f6\" \"f7\" \"f8\" \"f9\" \"f10\" \"f11\" \"f12\" \"f13\" \"f14\" \"f15\" \"f16\" \"f17\" \"f18\" \"f19\" \"f20\" \"f21\" \"f22\" \"f23\" \"f24\" \"f25\" \"f26\" \"f27\" \"f28\" \"f29\" \"f30\" \"f31\" \"f32\" \"f33\" \"f34\" \"f35\" \"f36\" \"f37\" \"f38\" \"f39\" \"f40\" \"f41\" \"f42\" \"f43\" \"f44\" \"f45\" \"f46\" \"f47\" \"f48\" \"f49\" \"f50\" \"f51\" \"f52\" \"f53\" \"f54\" \"f55\" \"f56\" \"f57\" \"f58\" \"f59\" \"f60\" \"f61\" \"f62\" \"f63\")))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="flags-64.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package flags-65" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x03\x7f\x7f\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x84\x02\x02\x6e\x41\x02\x66\x30\x02\x66\x31\x02\x66\x32\x02\x66\x33\x02\x66\x34\x02\x66\x35\x02\x66\x36\x02\x66\x37\x02\x66\x38\x02\x66\x39\x03\x66\x31\x30\x03\x66\x31\x31\x03\x66\x31\x32\x03\x66\x31\x33\x03\x66\x31\x34\x03\x66\x31\x35\x03\x66\x31\x36\x03\x66\x31\x37\x03\x66\x31\x38\x03\x66\x31\x39\x03\x66\x32\x30\x03\x66\x32\x31\x03\x66\x32\x32\x03\x66\x32\x33\x03\x66\x32\x34\x03\x66\x32\x35\x03\x66\x32\x36\x03\x66\x32\x37\x03\x66\x32\x38\x03\x66\x32\x39\x03\x66\x33\x30\x03\x66\x33\x31\x03\x66\x33\x32\x03\x66\x33\x33\x03\x66\x33\x34\x03\x66\x33\x35\x03\x66\x33\x36\x03\x66\x33\x37\x03\x66\x33\x38\x03\x66\x33\x39\x03\x66\x34\x30\x03\x66\x34\x31\x03\x66\x34\x32\x03\x66\x34\x33\x03\x66\x34\x34\x03\x66\x34\x35\x03\x66\x34\x36\x03\x66\x34\x37\x03\x66\x34\x38\x03\x66\x34\x39\x03\x66\x35\x30\x03\x66\x35\x31\x03\x66\x35\x32\x03\x66\x35\x33\x03\x66\x35\x34\x03\x66\x35\x35\x03\x66\x35\x36\x03\x66\x35\x37\x03\x66\x35\x38\x03\x66\x35\x39\x03\x66\x36\x30\x03\x66\x36\x31\x03\x66\x36\x32\x03\x66\x36\x33\x03\x66\x36\x34\x40\x01\x01\x78\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="flags-65.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\")  (param i32 i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (param \"x\" (flags \"f0\" \"f1\" \"f2\" \"f3\" \"f4\" \"f5\" \"f6\" \"f7\" \"f8\" \"f9\" \"f10\" \"f11\" \"f12\" \"f13\" \"f14\" \"f15\" \"f16\" \"f17\" \"f18\" \"f19\" \"f20\" \"f21\" \"f22\" \"f23\" \"f24\" \"f25\" \"f26\" \"f27\" \"f28\" \"f29\" \"f30\" \"f31\" \"f32\" \"f33\" \"f34\" \"f35\" \"f36\" \"f37\" \"f38\" \"f39\" \"f40\" \"f41\" \"f42\" \"f43\" \"f44\" \"f45\" \"f46\" \"f47\" \"f48\" \"f49\" \"f50\" \"f51\" \"f52\" \"f53\" \"f54\" \"f55\" \"f56\" \"f57\" \"f58\" \"f59\" \"f60\" \"f61\" \"f62\" \"f63\" \"f64\")))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="flags-65.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package empty-tuple-result" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x07\x02\x6f\x00\x40\x00\x00\x00\x08\x06\x01\x00\x00\x00\x00\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="empty-tuple-result.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\"))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func (result (tuple)))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="empty-tuple-result.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package map" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x0b\x02\x63\x73\x79\x40\x01\x01\x78\x00\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x01\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x4b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x01\x01\x74",
    source_id="map.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\") (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $t (func (param \"x\" (map string u32)))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="map.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "1", "x", "map",
    "scalar", "string", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "f", "func", "function", "false", "1", "x", "map", "scalar", "string", "scalar",
    "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package flags-named" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x07\x01\x6e\x02\x01\x61\x01\x62\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="flags-named.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (flags \"a\" \"b\")) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="flags-named.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "flags", "2", "a", "b", "f", "func",
    "function", "false", "1", "x", "flags", "2", "a", "b", "none", "instance", "interface",
    "", "0", "2", "v", "type", "flags", "2", "a", "b", "f", "func", "function", "false",
    "1", "x", "flags", "2", "a", "b", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package flags32-named" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x79\x01\x6e\x20\x02\x66\x30\x02\x66\x31\x02\x66\x32\x02\x66\x33\x02\x66\x34\x02\x66\x35\x02\x66\x36\x02\x66\x37\x02\x66\x38\x02\x66\x39\x03\x66\x31\x30\x03\x66\x31\x31\x03\x66\x31\x32\x03\x66\x31\x33\x03\x66\x31\x34\x03\x66\x31\x35\x03\x66\x31\x36\x03\x66\x31\x37\x03\x66\x31\x38\x03\x66\x31\x39\x03\x66\x32\x30\x03\x66\x32\x31\x03\x66\x32\x32\x03\x66\x32\x33\x03\x66\x32\x34\x03\x66\x32\x35\x03\x66\x32\x36\x03\x66\x32\x37\x03\x66\x32\x38\x03\x66\x32\x39\x03\x66\x33\x30\x03\x66\x33\x31\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="flags32-named.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (flags \"f0\" \"f1\" \"f2\" \"f3\" \"f4\" \"f5\" \"f6\" \"f7\" \"f8\" \"f9\" \"f10\" \"f11\" \"f12\" \"f13\" \"f14\" \"f15\" \"f16\" \"f17\" \"f18\" \"f19\" \"f20\" \"f21\" \"f22\" \"f23\" \"f24\" \"f25\" \"f26\" \"f27\" \"f28\" \"f29\" \"f30\" \"f31\")) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="flags32-named.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "flags", "32", "f0", "f1", "f2", "f3",
    "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15",
    "f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23", "f24", "f25", "f26",
    "f27", "f28", "f29", "f30", "f31", "f", "func", "function", "false", "1", "x",
    "flags", "32", "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10",
    "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20", "f21",
    "f22", "f23", "f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31", "none",
    "instance", "interface", "", "0", "2", "v", "type", "flags", "32", "f0", "f1",
    "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14",
    "f15", "f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23", "f24", "f25",
    "f26", "f27", "f28", "f29", "f30", "f31", "f", "func", "function", "false", "1",
    "x", "flags", "32", "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9",
    "f10", "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20",
    "f21", "f22", "f23", "f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31",
    "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package record-named" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7c\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x09\x01\x72\x02\x01\x78\x79\x01\x79\x75\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="record-named.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32 f64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (record (field \"x\" u32) (field \"y\" f64))) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="record-named.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "record", "2", "x", "scalar", "u32",
    "y", "scalar", "f64", "f", "func", "function", "false", "1", "x", "record", "2",
    "x", "scalar", "u32", "y", "scalar", "f64", "none", "instance", "interface",
    "", "0", "2", "v", "type", "record", "2", "x", "scalar", "u32", "y", "scalar",
    "f64", "f", "func", "function", "false", "1", "x", "record", "2", "x", "scalar",
    "u32", "y", "scalar", "f64", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package variant-join" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x0d\x01\x71\x02\x01\x61\x01\x76\x00\x01\x62\x01\x79\x00\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="variant-join.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (variant (case \"a\" f32) (case \"b\" u32))) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="variant-join.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "variant", "2", "a", "some", "scalar",
    "f32", "b", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "variant", "2", "a", "some", "scalar", "f32", "b", "some", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "v", "type", "variant", "2", "a", "some",
    "scalar", "f32", "b", "some", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "variant", "2", "a", "some", "scalar", "f32", "b", "some", "scalar",
    "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package variant-wide-join" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7e\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x0d\x01\x71\x02\x01\x61\x01\x76\x00\x01\x62\x01\x75\x00\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="variant-wide-join.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32 i64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (variant (case \"a\" f32) (case \"b\" f64))) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="variant-wide-join.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "variant", "2", "a", "some", "scalar",
    "f32", "b", "some", "scalar", "f64", "f", "func", "function", "false", "1", "x",
    "variant", "2", "a", "some", "scalar", "f32", "b", "some", "scalar", "f64", "none",
    "instance", "interface", "", "0", "2", "v", "type", "variant", "2", "a", "some",
    "scalar", "f32", "b", "some", "scalar", "f64", "f", "func", "function", "false",
    "1", "x", "variant", "2", "a", "some", "scalar", "f32", "b", "some", "scalar",
    "f64", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package result-join" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7e\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x06\x01\x6a\x01\x76\x01\x77\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="result-join.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32 i64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (result f32 (error u64))) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="result-join.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "result", "some", "scalar", "f32", "some",
    "scalar", "u64", "f", "func", "function", "false", "1", "x", "result", "some",
    "scalar", "f32", "some", "scalar", "u64", "none", "instance", "interface", "",
    "0", "2", "v", "type", "result", "some", "scalar", "f32", "some", "scalar", "u64",
    "f", "func", "function", "false", "1", "x", "result", "some", "scalar", "f32",
    "some", "scalar", "u64", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package option-string" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x53\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0f\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x03\x7f\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x03\x01\x6b\x73\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="option-string.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32 i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (option string)) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="option-string.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "option", "scalar", "string", "f", "func",
    "function", "false", "1", "x", "option", "scalar", "string", "none", "instance",
    "interface", "", "0", "2", "v", "type", "option", "scalar", "string", "f", "func",
    "function", "false", "1", "x", "option", "scalar", "string", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package tuple-indirect" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x14\x01\x6f\x11\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x79\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="tuple-indirect.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (tuple u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32 u32)) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="tuple-indirect.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "tuple", "17", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "tuple", "17", "scalar", "u32",
    "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "none", "instance", "interface", "", "0", "2", "v", "type",
    "tuple", "17", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32",
    "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "tuple", "17", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar",
    "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "scalar", "u32", "none",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package tuple-return" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x53\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x00\x01\x7f\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x0b\x02\x04\x00\x41\x00\x0b\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x05\x01\x6f\x02\x79\x77\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x05\x01\x40\x00\x00\x01\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="tuple-return.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (result i32) i32.const 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (tuple u32 u64)) (export $public \"v\" (type $v)) (type $t (func (result $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="tuple-return.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "tuple", "2", "scalar", "u32", "scalar",
    "u64", "f", "func", "function", "false", "0", "some", "tuple", "2", "scalar",
    "u32", "scalar", "u64", "instance", "interface", "", "0", "2", "v", "type", "tuple",
    "2", "scalar", "u32", "scalar", "u64", "f", "func", "function", "false", "0",
    "some", "tuple", "2", "scalar", "u32", "scalar", "u64", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package fixed-list" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x05\x01\x67\x79\xe8\x07\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="fixed-list.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (list u32 1000)) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="fixed-list.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "fixed-list", "1000", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "fixed-list", "1000", "scalar", "u32",
    "none", "instance", "interface", "", "0", "2", "v", "type", "fixed-list", "1000",
    "scalar", "u32", "f", "func", "function", "false", "1", "x", "fixed-list", "1000",
    "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package list-string" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x03\x01\x70\x73\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="list-string.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (list string)) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="list-string.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "list", "scalar", "string", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "string", "none", "instance",
    "interface", "", "0", "2", "v", "type", "list", "scalar", "string", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "string", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package map-return" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x53\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x00\x01\x7f\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x0b\x02\x04\x00\x41\x00\x0b\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x04\x01\x63\x73\x79\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x05\x01\x40\x00\x00\x01\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="map-return.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (result i32) i32.const 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (map string u32)) (export $public \"v\" (type $v)) (type $t (func (result $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="map-return.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "0", "some", "map", "scalar", "string",
    "scalar", "u32", "instance", "interface", "", "0", "2", "v", "type", "map", "scalar",
    "string", "scalar", "u32", "f", "func", "function", "false", "0", "some", "map",
    "scalar", "string", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package future-handle" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x04\x01\x65\x01\x73\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="future-handle.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (future string)) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="future-handle.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "future", "some", "scalar", "string",
    "f", "func", "function", "false", "1", "x", "future", "some", "scalar", "string",
    "none", "instance", "interface", "", "0", "2", "v", "type", "future", "some",
    "scalar", "string", "f", "func", "function", "false", "1", "x", "future", "some",
    "scalar", "string", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package stream-handle" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x76\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x56\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x76\x01\x06\x70\x75\x62\x6c\x69\x63\x02\x01\x74",
    source_id="stream-handle.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\")  (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $v (stream u32)) (export $public \"v\" (type $v)) (type $t (func (param \"x\" $public))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="stream-handle.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "v", "type", "stream", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "stream", "some", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "v", "type", "stream", "some", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "stream", "some", "scalar",
    "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package unused-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x38\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x0e\x02\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x12\x02\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x07\x05\x01\x40\x00\x01\x00\x08\x08\x01\x00\x00\x00\x01\x03\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="unused-memory.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"f\"))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (type $t (func)) (func $f (type $t) (canon lift (core func $f) (memory $memory))) (export \"f\" (func $f)))",
    source_id="unused-memory.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "0", "none", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package shared-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x39\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x05\x04\x01\x03\x01\x01\x07\x0e\x02\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x12\x02\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x07\x05\x01\x40\x00\x01\x00\x08\x08\x01\x00\x00\x00\x01\x03\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="shared-memory.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1 1 shared) (func (export \"f\"))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (type $t (func)) (func $f (type $t) (canon lift (core func $f) (memory $memory))) (export \"f\" (func $f)))",
    source_id="shared-memory.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package memory64-string" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7e\x7e\x7e\x7e\x01\x7e\x60\x02\x7e\x7e\x00\x03\x03\x02\x00\x01\x05\x03\x01\x04\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x42\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x08\x01\x40\x01\x01\x78\x73\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x4b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="memory64-string.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") i64 1) (func (export \"realloc\") (param i64 i64 i64 i64) (result i64) i64.const 0) (func (export \"f\") (param i64 i64))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $t (func (param \"x\" string))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="memory64-string.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "string", "none", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "string", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package wrong-realloc" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x51\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x03\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x08\x01\x40\x01\x01\x78\x73\x01\x00\x08\x0a\x01\x00\x00\x00\x02\x03\x00\x04\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x4b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="wrong-realloc.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32) (result i32) i32.const 0) (func (export \"f\") (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $t (func (param \"x\" string))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="wrong-realloc.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package post-lower" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x07\x01\x01\x00\x00\x01\x05\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x33\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x06\x07\x01\x00\x00\x01\x01\x01\x66\x08\x06\x01\x00\x00\x01\x00\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x00\x00\x48\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x00\x00\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x0b\x00\x12\x02\x00\x03\x65\x6e\x76\x01\x01\x69\x01\x0c\x01\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x05\x03\x01\x00\x01\x74",
    source_id="post-lower.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (func (param \"x\" u32) (result u32))) (import \"f\" (func $f (type $t))) (core func $f (canon lower (func $f) (post-return 0))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func $f (param i32) (result i32))) (export \"f\" (func $f))) (core instance $i (instantiate $m (with \"env\" (instance $env)))) (alias core export $i \"f\" (core func $again)) (func $again (type $t) (canon lift (core func $again))) (export \"again\" (func $again)))",
    source_id="post-lower.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package duplicate-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x52\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0e\x02\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x60\x02\x7f\x7f\x00\x03\x03\x02\x00\x01\x05\x03\x01\x00\x01\x07\x18\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x01\x66\x00\x01\x0a\x09\x02\x04\x00\x41\x00\x0b\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x1e\x03\x00\x00\x01\x00\x01\x66\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x07\x08\x01\x40\x01\x01\x78\x73\x01\x00\x08\x0c\x01\x00\x00\x00\x03\x03\x00\x03\x00\x04\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x4b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x00\x00\x02\x00\x01\x66\x01\x07\x72\x65\x61\x6c\x6c\x6f\x63\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="duplicate-memory.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"memory\") 1) (func (export \"realloc\") (param i32 i32 i32 i32) (result i32) i32.const 0) (func (export \"f\") (param i32 i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (alias core export $i \"memory\" (core memory $memory)) (alias core export $i \"realloc\" (core func $realloc)) (type $t (func (param \"x\" string))) (func $f (type $t) (canon lift (core func $f) (memory $memory) (memory $memory) (realloc $realloc))) (export \"f\" (func $f)))",
    source_id="duplicate-memory.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package duplicate-encoding" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x08\x08\x01\x00\x00\x00\x02\x00\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="duplicate-encoding.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\"))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f))  (type $t (func)) (func $f (type $t) (canon lift (core func $f) string-encoding=utf8 string-encoding=utf16)) (export \"f\" (func $f)))",
    source_id="duplicate-encoding.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package alias-lower" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x01\x73\x04\x00\x01\x73\x03\x00\x00\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x01\x3d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x11\x02\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x04\x74\x61\x6b\x65\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x07\x01\x01\x00\x00\x01\x03\x00\x02\x0a\x01\x01\x01\x04\x74\x61\x6b\x65\x00\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x02\x0c\x01\x03\x65\x6e\x76\x04\x74\x61\x6b\x65\x00\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x55\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x10\x00\x11\x02\x00\x01\x6d\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x0b\x00\x12\x02\x00\x01\x6d\x01\x03\x65\x6e\x76\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x69",
    source_id="alias-lower.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $s string) (export \"s\" (type (eq $s))) (type $f (func (param \"x\" $s))) (export \"f\" (func (type $f))))) (import \"api\" (instance (type $i))) (alias export 0 \"f\" (func $f)) (core module $m (memory (export \"memory\") 1) (func (export \"take\") (param i32 i32))) (core instance $m (instantiate $m)) (alias core export $m \"memory\" (core memory $memory)) (core func $lower (canon lower (func $f) (memory $memory))) (core instance $env (export \"take\" (func $lower))) (core module $consumer (import \"env\" \"take\" (func (param i32 i32)))) (core instance (instantiate $consumer (with \"env\" (instance $env)))))",
    source_id="alias-lower.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "1", "api", "instance", "interface", "", "0", "2", "s", "type",
    "scalar", "string", "f", "func", "function", "false", "1", "x", "scalar", "string",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package alias-lower-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x01\x73\x04\x00\x01\x73\x03\x00\x00\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x01\x3d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7f\x7f\x00\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x11\x02\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x04\x74\x61\x6b\x65\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x07\x01\x01\x00\x00\x01\x03\x00\x02\x0a\x01\x01\x01\x04\x74\x61\x6b\x65\x00\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x02\x7e\x7f\x00\x02\x0c\x01\x03\x65\x6e\x76\x04\x74\x61\x6b\x65\x00\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x55\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x10\x00\x11\x02\x00\x01\x6d\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x0b\x00\x12\x02\x00\x01\x6d\x01\x03\x65\x6e\x76\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x69",
    source_id="alias-lower-wrong.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $s string) (export \"s\" (type (eq $s))) (type $f (func (param \"x\" $s))) (export \"f\" (func (type $f))))) (import \"api\" (instance (type $i))) (alias export 0 \"f\" (func $f)) (core module $m (memory (export \"memory\") 1) (func (export \"take\") (param i32 i32))) (core instance $m (instantiate $m)) (alias core export $m \"memory\" (core memory $memory)) (core func $lower (canon lower (func $f) (memory $memory))) (core instance $env (export \"take\" (func $lower))) (core module $consumer (import \"env\" \"take\" (func (param i64 i32)))) (core instance (instantiate $consumer (with \"env\" (instance $env)))))",
    source_id="alias-lower-wrong.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package core-duplicate-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x05\x01\x01\x00\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x33\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x02\x10\x01\x00\x00\x02\x03\x65\x6e\x76\x12\x00\x03\x65\x6e\x76\x12\x00\x06\x07\x01\x00\x00\x01\x01\x01\x66\x08\x06\x01\x00\x00\x01\x00\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x00\x00\x48\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x00\x00\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x0b\x00\x12\x02\x00\x03\x65\x6e\x76\x01\x01\x69\x01\x0c\x01\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x05\x03\x01\x00\x01\x74",
    source_id="core-duplicate-argument.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (func (param \"x\" u32) (result u32))) (import \"f\" (func $f (type $t))) (core func $f (canon lower (func $f))) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func $f (param i32) (result i32))) (export \"f\" (func $f))) (core instance $i (instantiate $m (with \"env\" (instance $env)) (with \"env\" (instance $env)))) (alias core export $i \"f\" (core func $again)) (func $again (type $t) (canon lift (core func $again))) (export \"again\" (func $again)))",
    source_id="core-duplicate-argument.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package core-duplicate-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x05\x01\x01\x00\x00\x00\x02\x0b\x01\x01\x02\x01\x66\x00\x00\x01\x66\x00\x00\x01\x33\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x06\x07\x01\x00\x00\x01\x01\x01\x66\x08\x06\x01\x00\x00\x01\x00\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x00\x00\x48\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x00\x00\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x0b\x00\x12\x02\x00\x03\x65\x6e\x76\x01\x01\x69\x01\x0c\x01\x02\x00\x01\x66\x01\x05\x61\x67\x61\x69\x6e\x01\x05\x03\x01\x00\x01\x74",
    source_id="core-duplicate-export.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (func (param \"x\" u32) (result u32))) (import \"f\" (func $f (type $t))) (core func $f (canon lower (func $f))) (core instance $env (export \"f\" (func $f)) (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func $f (param i32) (result i32))) (export \"f\" (func $f))) (core instance $i (instantiate $m (with \"env\" (instance $env)))) (alias core export $i \"f\" (core func $again)) (func $again (type $t) (canon lift (core func $again))) (export \"again\" (func $again)))",
    source_id="core-duplicate-export.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package core-future-module" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x02\x04\x01\x00\x00\x00\x01\x08\x00\x61\x73\x6d\x01\x00\x00\x00",
    source_id="core-future-module.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core instance (instantiate 0)) (core module))",
    source_id="core-future-module.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package core-self-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d",
    source_id="core-self-instance.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"f\" (func))) (core instance (instantiate $m (with \"env\" (instance 0)))))",
    source_id="core-self-instance.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-memory" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x17\x02\x50\x01\x03\x01\x78\x02\x01\x02\x04\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x02\x01\x01\x05\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-memory.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (memory 2 4)))) (core type $c (module (import \"env\" \"x\" (memory 1 5)))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-memory.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "x", kind: Memory(2UL, Some(4UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "x",
        kind: Memory(1UL, Some(5UL), false, false, None),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "2",
    "provider",
    "module",
    module_0.to_repr().to_string(),
    "consumer",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "0",
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package contract-memory-min" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x17\x02\x50\x01\x03\x01\x78\x02\x01\x00\x04\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x02\x01\x01\x05\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-memory-min.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (memory 0 4)))) (core type $c (module (import \"env\" \"x\" (memory 1 5)))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-memory-min.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-memory-max" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x17\x02\x50\x01\x03\x01\x78\x02\x01\x02\x06\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x02\x01\x01\x05\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-memory-max.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (memory 2 6)))) (core type $c (module (import \"env\" \"x\" (memory 1 5)))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-memory-max.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-table64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x2b\x02\x50\x01\x03\x01\x78\x01\x70\x05\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x01\x70\x05\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-table64.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (table i64 1 18446744073709551615 funcref)))) (core type $c (module (import \"env\" \"x\" (table i64 0 18446744073709551615 funcref)))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-table64.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "x",
        kind: Table(
          Reference(true, "func"),
          1UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "x",
        kind: Table(
          Reference(true, "func"),
          0UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "2",
    "provider",
    "module",
    module_0.to_repr().to_string(),
    "consumer",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "0",
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package contract-table64-flag" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x17\x02\x50\x01\x03\x01\x78\x01\x70\x04\x01\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x01\x70\x00\x01\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-table64-flag.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (table i64 1 funcref)))) (core type $c (module (import \"env\" \"x\" (table 1 funcref)))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-table64-flag.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-global" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x02\x50\x01\x03\x01\x78\x03\x7f\x01\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x03\x7f\x01\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-global.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (global (mut i32))))) (core type $c (module (import \"env\" \"x\" (global (mut i32))))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-global.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "x", kind: Global(Scalar("i32"), true, false), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "x",
        kind: Global(Scalar("i32"), true, false),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "2",
    "provider",
    "module",
    module_0.to_repr().to_string(),
    "consumer",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "0",
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package contract-global-mut" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x02\x50\x01\x03\x01\x78\x03\x7f\x00\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x03\x7f\x01\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-global-mut.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (global i32)))) (core type $c (module (import \"env\" \"x\" (global (mut i32))))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-global-mut.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-global-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x02\x50\x01\x03\x01\x78\x03\x7f\x02\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x03\x7f\x02\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-global-shared.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (global (shared i32))))) (core type $c (module (import \"env\" \"x\" (global (shared i32))))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-global-shared.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "x", kind: Global(Scalar("i32"), false, true), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "x",
        kind: Global(Scalar("i32"), false, true),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "2",
    "provider",
    "module",
    module_0.to_repr().to_string(),
    "consumer",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "0",
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package contract-global-shared-flag" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x02\x50\x01\x03\x01\x78\x03\x7f\x02\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x03\x7f\x00\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-global-shared-flag.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (global (shared i32))))) (core type $c (module (import \"env\" \"x\" (global i32)))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-global-shared-flag.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-global-ref-narrow" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x02\x50\x01\x03\x01\x78\x03\x71\x00\x50\x01\x00\x03\x65\x6e\x76\x01\x78\x03\x6e\x00\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-global-ref-narrow.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (global (ref null none))))) (core type $c (module (import \"env\" \"x\" (global (ref null any))))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-global-ref-narrow.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package contract-tag" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x21\x02\x50\x02\x01\x60\x02\x7f\x7e\x00\x03\x01\x78\x04\x00\x00\x50\x02\x01\x60\x02\x7f\x7e\x00\x00\x03\x65\x6e\x76\x01\x78\x04\x00\x00\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-tag.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (tag (param i32 i64))))) (core type $c (module (import \"env\" \"x\" (tag (param i32 i64))))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-tag.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "x",
        kind: Tag({ params: [Scalar("i32"), Scalar("i64")], results: [], }),
      },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "x",
        kind: Tag({ params: [Scalar("i32"), Scalar("i64")], results: [], }),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "2",
    "provider",
    "module",
    module_0.to_repr().to_string(),
    "consumer",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "0",
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package contract-tag-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1f\x02\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x78\x04\x00\x00\x50\x02\x01\x60\x01\x7e\x00\x00\x03\x65\x6e\x76\x01\x78\x04\x00\x00\x0a\x1b\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x00\x11\x00\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x00\x11\x01\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x70\x01\x01\x63\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70",
    source_id="contract-tag-mismatch.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $p (module (export \"x\" (tag (param i32))))) (core type $c (module (import \"env\" \"x\" (tag (param i64))))) (import \"provider\" (core module $p (type $p))) (import \"consumer\" (core module $c (type $c))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))))",
    source_id="contract-tag-mismatch.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package missing-lower-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x05\x01\x01\x00\x00\x00",
    source_id="missing-lower-function.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core func (canon lower (func 0))))",
    source_id="missing-lower-function.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package resource-own" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x72\x01\x06\x70\x75\x62\x6c\x69\x63\x03\x01\x74",
    source_id="resource-own.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (type $r (resource (rep i32))) (export $public \"r\" (type $r)) (type $t (func (param \"x\" (own $public)))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="resource-own.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "instance", "interface", "", "0", "2",
    "r", "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own",
    "0", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package resource-result-own" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x07\x02\x69\x01\x40\x00\x00\x02\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x72\x01\x06\x70\x75\x62\x6c\x69\x63\x03\x01\x74",
    source_id="resource-result-own.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (type $r (resource (rep i32))) (export $public \"r\" (type $r)) (type $t (func (result (own $public)))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="resource-result-own.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "0", "some", "own", "0", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "0", "some", "own",
    "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package resource-borrow" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x68\x01\x40\x01\x01\x78\x02\x01\x00\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x72\x01\x06\x70\x75\x62\x6c\x69\x63\x03\x01\x74",
    source_id="resource-borrow.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (type $r (resource (rep i32))) (export $public \"r\" (type $r)) (type $t (func (param \"x\" (borrow $public)))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="resource-borrow.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "borrow", "0", "none", "instance", "interface", "", "0", "2",
    "r", "type", "resource", "0", "f", "func", "function", "false", "1", "x", "borrow",
    "0", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package resource-result-borrow" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x07\x02\x68\x01\x40\x00\x00\x02\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x03\x00\x01\x72\x01\x06\x70\x75\x62\x6c\x69\x63\x03\x01\x74",
    source_id="resource-result-borrow.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (type $r (resource (rep i32))) (export $public \"r\" (type $r)) (type $t (func (result (borrow $public)))) (func $f (type $t) (canon lift (core func $f) )) (export \"f\" (func $f)))",
    source_id="resource-result-borrow.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package alias-resource-lower" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x08\x05\x01\x01\x00\x00\x00\x02\x0a\x01\x01\x01\x04\x74\x61\x6b\x65\x00\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x0c\x01\x03\x65\x6e\x76\x04\x74\x61\x6b\x65\x00\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x0d\x00\x11\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x69",
    source_id="alias-resource-lower.wasm",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (export \"r\" (type (sub resource))) (type $f (func (param \"x\" (borrow 0)))) (export \"f\" (func (type $f))))) (import \"api\" (instance (type $i))) (alias export 0 \"f\" (func $f)) (core func $lower (canon lower (func $f))) (core instance $env (export \"take\" (func $lower))) (core module $consumer (import \"env\" \"take\" (func (param i32)))) (core instance (instantiate $consumer (with \"env\" (instance $env)))))",
    source_id="alias-resource-lower.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "1", "api", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "borrow", "0", "none",
    "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "synchronous canonical package core-future-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d",
    source_id="core-future-alias.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (alias core export 0 \"f\" (core func)) (core module $m (func (export \"f\"))) (core instance (instantiate $m)))",
    source_id="core-future-alias.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "synchronous canonical package core-future-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x05\x01\x01\x00\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    source_id="core-future-function.wasm",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core instance (export \"f\" (func 0))) (type $t (func)) (import \"f\" (func $f (type $t))) (core func (canon lower (func $f))))",
    source_id="core-future-function.wat",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}
