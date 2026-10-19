///|
test "aliased function ascription empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(bytes, source_id="empty.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "out", "func", "function", "false", "0",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "0", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func)) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func)) (export \"out\" (func $f) (func (type $b))))",
    source_id="empty.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "out", "func", "function", "false", "0",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "0", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription scalar" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func (param \"x\" u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $b))))",
    source_id="scalar.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription param-name" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x79\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="param-name.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func (param \"x\" u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (param \"y\" u32))) (export \"out\" (func $f) (func (type $b))))",
    source_id="param-name.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription param-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x77\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="param-type.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func (param \"x\" u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (param \"x\" u64))) (export \"out\" (func $f) (func (type $b))))",
    source_id="param-type.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription result" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x05\x01\x40\x00\x00\x79\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "some", "scalar", "u32", "1", "out", "func", "function",
    "false", "0", "some", "scalar", "u32", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "0", "some", "scalar", "u32", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func (result u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (result u32))) (export \"out\" (func $f) (func (type $b))))",
    source_id="result.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "some", "scalar", "u32", "1", "out", "func", "function",
    "false", "0", "some", "scalar", "u32", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "0", "some", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription result-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x05\x01\x40\x00\x00\x77\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func (result u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (result u64))) (export \"out\" (func $f) (func (type $b))))",
    source_id="result-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription async" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x43\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x43\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(bytes, source_id="async.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "true", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function",
    "true", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "true", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func async (param \"x\" u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func async (param \"x\" u32))) (export \"out\" (func $f) (func (type $b))))",
    source_id="async.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "true", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function",
    "true", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "true", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription async-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x43\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="async-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func async (param \"x\" u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $b))))",
    source_id="async-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription list-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x01\x42\x04\x01\x70\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x03\x01\x70\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="list-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "list", "scalar", "u32", "f", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "b", "type", "list", "scalar", "u32", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (list u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (list u32)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="list-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "list", "scalar", "u32", "f", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "b", "type", "list", "scalar", "u32", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription list-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x01\x42\x04\x01\x70\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x03\x01\x70\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="list-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (list u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (list u64)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="list-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription fixed-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x67\x79\x03\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x67\x79\x03\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="fixed-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "fixed-list", "3", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "fixed-list", "3", "scalar", "u32", "none", "b", "type", "fixed-list", "3", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "fixed-list", "3",
    "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "fixed-list", "3", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (list u32 3)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (list u32 3)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="fixed-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "fixed-list", "3", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "fixed-list", "3", "scalar", "u32", "none", "b", "type", "fixed-list", "3", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "fixed-list", "3",
    "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "fixed-list", "3", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription fixed-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x67\x79\x03\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x67\x77\x03\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="fixed-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (list u32 3)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (list u64 3)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="fixed-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription map-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x63\x73\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x63\x73\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="map-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "map", "scalar", "string", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "b", "type", "map",
    "scalar", "string", "scalar", "u32", "1", "out", "func", "function", "false",
    "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "map", "scalar",
    "string", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (map string u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (map string u32)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="map-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "map", "scalar", "string", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "b", "type", "map",
    "scalar", "string", "scalar", "u32", "1", "out", "func", "function", "false",
    "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "map", "scalar",
    "string", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription map-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x63\x73\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x63\x73\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="map-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (map string u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (map string u64)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="map-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription future-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x65\x01\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x65\x01\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="future-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "future", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "future", "some", "scalar", "u32", "none", "b", "type", "future", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (future u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (future u32)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="future-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "future", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "future", "some", "scalar", "u32", "none", "b", "type", "future", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription future-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x65\x01\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x65\x01\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="future-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (future u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (future u64)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="future-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription stream-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x66\x01\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x66\x01\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="stream-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "stream", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "stream", "some", "scalar", "u32", "none", "b", "type", "stream", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "stream", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "stream", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (stream u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (stream u32)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="stream-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "stream", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "stream", "some", "scalar", "u32", "none", "b", "type", "stream", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "stream", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "stream", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription stream-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x04\x01\x66\x01\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x04\x01\x66\x01\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="stream-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (stream u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (stream u64)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="stream-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription record-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="record-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "b", "type", "record", "1", "x",
    "scalar", "u32", "1", "out", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (record (field \"x\" u32))) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (record (field \"x\" u32))) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="record-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "b", "type", "record", "1", "x",
    "scalar", "u32", "1", "out", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "definitions", "0",
  ])
}

///|
test "aliased function ascription record-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x06\x01\x72\x01\x01\x78\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="record-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (record (field \"x\" u32))) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (record (field \"x\" u64))) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="record-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription variant-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x04\x01\x71\x01\x01\x78\x01\x79\x00\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x71\x01\x01\x78\x01\x79\x00\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="variant-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "variant", "1", "x", "some", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "b", "type",
    "variant", "1", "x", "some", "scalar", "u32", "1", "out", "func", "function",
    "false", "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "variant",
    "1", "x", "some", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (variant (case \"x\" u32))) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (variant (case \"x\" u32))) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="variant-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "variant", "1", "x", "some", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "b", "type",
    "variant", "1", "x", "some", "scalar", "u32", "1", "out", "func", "function",
    "false", "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "variant",
    "1", "x", "some", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription variant-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x04\x01\x71\x01\x01\x78\x01\x79\x00\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x71\x01\x01\x78\x01\x77\x00\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="variant-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (variant (case \"x\" u32))) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (variant (case \"x\" u64))) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="variant-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription tuple-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x01\x42\x04\x01\x6f\x02\x79\x73\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x05\x01\x6f\x02\x79\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tuple-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "tuple", "2", "scalar", "u32", "scalar", "string", "f", "func", "function", "false",
    "1", "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none", "b", "type",
    "tuple", "2", "scalar", "u32", "scalar", "string", "1", "out", "func", "function",
    "false", "1", "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (tuple u32 string)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (tuple u32 string)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="tuple-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "tuple", "2", "scalar", "u32", "scalar", "string", "f", "func", "function", "false",
    "1", "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none", "b", "type",
    "tuple", "2", "scalar", "u32", "scalar", "string", "1", "out", "func", "function",
    "false", "1", "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription tuple-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x01\x42\x04\x01\x6f\x02\x79\x73\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x05\x01\x6f\x02\x77\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tuple-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (tuple u32 string)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (tuple u64 string)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="tuple-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription option-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x01\x42\x04\x01\x6b\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x03\x01\x6b\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="option-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "option", "scalar", "u32", "f", "func", "function", "false", "1", "x", "option",
    "scalar", "u32", "none", "b", "type", "option", "scalar", "u32", "1", "out",
    "func", "function", "false", "1", "x", "option", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "option",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (option u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (option u32)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="option-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "option", "scalar", "u32", "f", "func", "function", "false", "1", "x", "option",
    "scalar", "u32", "none", "b", "type", "option", "scalar", "u32", "1", "out",
    "func", "function", "false", "1", "x", "option", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "option",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription option-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x01\x42\x04\x01\x6b\x79\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x03\x01\x6b\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="option-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (option u32)) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (option u64)) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="option-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription result-type-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x04\x01\x6a\x01\x79\x01\x73\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x06\x01\x6a\x01\x79\x01\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-type-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "result", "some", "scalar", "u32", "some", "scalar", "string", "f", "func", "function",
    "false", "1", "x", "result", "some", "scalar", "u32", "some", "scalar", "string",
    "none", "b", "type", "result", "some", "scalar", "u32", "some", "scalar", "string",
    "1", "out", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (result u32 (error string))) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (result u32 (error string))) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="result-type-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "a", "type",
    "result", "some", "scalar", "u32", "some", "scalar", "string", "f", "func", "function",
    "false", "1", "x", "result", "some", "scalar", "u32", "some", "scalar", "string",
    "none", "b", "type", "result", "some", "scalar", "u32", "some", "scalar", "string",
    "1", "out", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription result-type-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x04\x01\x6a\x01\x79\x01\x73\x04\x00\x01\x61\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x06\x01\x6a\x01\x77\x01\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x69\x01\x02\x62\x64\x02\x01\x62\x03\x02\x66\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-type-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $ad (result u32 (error string))) (export \"a\" (type $a (eq $ad))) (type $fa (func (param \"x\" $a))) (export \"f\" (func (type $fa))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $bd (result u64 (error string))) (import \"b\" (type $b (eq $bd))) (type $fb (func (param \"x\" $b))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="result-type-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription resource-own-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0b\x02\x00\x01\x69\x05\x00\x00\x01\x6a\x05\x00\x06\x0b\x02\x01\x00\x00\x01\x66\x03\x00\x00\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x69\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-own-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "j", "instance", "interface", "", "0", "2", "r", "type", "resource", "1", "f",
    "func", "function", "false", "1", "x", "own", "1", "none", "1", "out", "func",
    "function", "false", "1", "x", "own", "0", "none", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "own", "0", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (export \"r\" (type $r (sub resource))) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (import \"j\" (instance $j (type $i))) (alias export $i \"f\" (func $f)) (alias export $i \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="resource-own-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "j", "instance", "interface", "", "0", "2", "r", "type", "resource", "1", "f",
    "func", "function", "false", "1", "x", "own", "1", "none", "1", "out", "func",
    "function", "false", "1", "x", "own", "0", "none", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "own", "0", "none", "definitions",
    "0",
  ])
}

///|
test "aliased function ascription resource-borrow-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0b\x02\x00\x01\x69\x05\x00\x00\x01\x6a\x05\x00\x06\x0b\x02\x01\x00\x00\x01\x66\x03\x00\x00\x01\x72\x07\x0a\x02\x68\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x69\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-borrow-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "borrow", "0", "none",
    "j", "instance", "interface", "", "0", "2", "r", "type", "resource", "1", "f",
    "func", "function", "false", "1", "x", "borrow", "1", "none", "1", "out", "func",
    "function", "false", "1", "x", "borrow", "0", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "borrow", "0", "none",
    "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (export \"r\" (type $r (sub resource))) (type $h (borrow $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (import \"j\" (instance $j (type $i))) (alias export $i \"f\" (func $f)) (alias export $i \"r\" (type $r)) (type $h (borrow $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="resource-borrow-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "borrow", "0", "none",
    "j", "instance", "interface", "", "0", "2", "r", "type", "resource", "1", "f",
    "func", "function", "false", "1", "x", "borrow", "1", "none", "1", "out", "func",
    "function", "false", "1", "x", "borrow", "0", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "borrow", "0", "none",
    "definitions", "0",
  ])
}

///|
test "aliased function ascription resource-own-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0b\x02\x00\x01\x69\x05\x00\x00\x01\x6a\x05\x00\x06\x0b\x02\x01\x00\x00\x01\x66\x03\x00\x01\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x69\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-own-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (export \"r\" (type $r (sub resource))) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (import \"j\" (instance $j (type $i))) (alias export $i \"f\" (func $f)) (alias export $j \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="resource-own-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription resource-borrow-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0b\x02\x00\x01\x69\x05\x00\x00\x01\x6a\x05\x00\x06\x0b\x02\x01\x00\x00\x01\x66\x03\x00\x01\x01\x72\x07\x0a\x02\x68\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x69\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-borrow-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (export \"r\" (type $r (sub resource))) (type $h (borrow $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (import \"j\" (instance $j (type $i))) (alias export $i \"f\" (func $f)) (alias export $j \"r\" (type $r)) (type $h (borrow $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="resource-borrow-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription outer-resource-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x19\x01\x42\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x02\x06\x06\x01\x01\x00\x00\x01\x66\x07\x0a\x02\x69\x00\x40\x01\x01\x78\x03\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x04\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x11\x03\x05\x00\x01\x72\x01\x01\x73\x02\x01\x69\x03\x01\x68\x04\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-resource-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "3", "r", "type", "resource", "0", "s", "type", "resource",
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "own", "0", "none", "1", "out", "func", "function", "false", "1", "x",
    "own", "0", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "own", "0", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (import \"s\" (type $s (sub resource))) (type $i (instance (alias outer 1 $r (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="outer-resource-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "3", "r", "type", "resource", "0", "s", "type", "resource",
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "own", "0", "none", "1", "out", "func", "function", "false", "1", "x",
    "own", "0", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "own", "0", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription outer-value-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x03\x79\x70\x00\x42\x04\x01\x70\x77\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x02\x06\x06\x01\x01\x00\x00\x01\x66\x07\x0a\x02\x70\x79\x40\x01\x01\x78\x03\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x04\x00\x36\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x17\x03\x05\x00\x04\x6c\x65\x61\x66\x01\x04\x62\x61\x73\x65\x02\x01\x69\x03\x01\x6e\x04\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-value-equal.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $leaf u32) (type $base (list $leaf)) (type $i (instance (type $collision (list u64)) (alias outer 1 $base (type $n)) (type $f (func (param \"x\" $n))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $n (list u32)) (type $f (func (param \"x\" $n))) (export \"out\" (func $f) (func (type $f))))",
    source_id="outer-value-equal.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription outer-resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x19\x01\x42\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x02\x06\x06\x01\x01\x00\x00\x01\x66\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x03\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x04\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x11\x03\x05\x00\x01\x72\x01\x01\x73\x02\x01\x69\x03\x01\x68\x04\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-resource-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (import \"s\" (type $s (sub resource))) (type $i (instance (alias outer 1 $r (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $h (own $s)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="outer-resource-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription outer-value-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x03\x79\x70\x00\x42\x04\x01\x70\x77\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x02\x06\x06\x01\x01\x00\x00\x01\x66\x07\x0a\x02\x70\x77\x40\x01\x01\x78\x03\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x04\x00\x36\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x17\x03\x05\x00\x04\x6c\x65\x61\x66\x01\x04\x62\x61\x73\x65\x02\x01\x69\x03\x01\x6e\x04\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-value-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $leaf u32) (type $base (list $leaf)) (type $i (instance (type $collision (list u64)) (alias outer 1 $base (type $n)) (type $f (func (param \"x\" $n))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $n (list u64)) (type $f (func (param \"x\" $n))) (export \"out\" (func $f) (func (type $f))))",
    source_id="outer-value-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "aliased function ascription outer-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x03\x70\x79\x40\x01\x01\x78\x00\x01\x00\x42\x03\x01\x70\x77\x02\x03\x02\x01\x01\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x69\x05\x02\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x6e\x01\x01\x66\x02\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-function.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $n (list u32)) (type $f (func (param \"x\" $n))) (type $i (instance (type $collision (list u64)) (alias outer 1 $f (type $f)) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (export \"out\" (func $f) (func (type $f))))",
    source_id="outer-function.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription nested-instance" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x0b\x01\x00\x06\x70\x61\x72\x65\x6e\x74\x05\x00\x06\x0f\x02\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0d\x03\x02\x00\x06\x70\x61\x72\x65\x6e\x74\x01\x01\x66\x01\x11\x05\x02\x00\x06\x70\x61\x72\x65\x6e\x74\x01\x05\x63\x68\x69\x6c\x64"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-instance.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "parent", "instance", "interface", "", "0", "1", "child",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x",
    "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $parent (instance (type $child (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $child))))) (import \"parent\" (instance $parent (type $parent))) (alias export $parent \"child\" (instance $child)) (alias export $child \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="nested-instance.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "parent", "instance", "interface", "", "0", "1", "child",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x",
    "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "aliased function ascription reexport-chain" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x17\x02\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x62\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-chain.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )

  let model = result.unwrap()
  assert_eq(binary_projection(model), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "2", "out", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "again", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "2", "out",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "again", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $a (func (param \"x\" u32))) (export \"f\" (func (type $a))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $b (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $b))) (export \"again\" (func 1) (func (type $b))))",
    source_id="reexport-chain.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "2", "out", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "again", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "2", "out",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "again", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}
