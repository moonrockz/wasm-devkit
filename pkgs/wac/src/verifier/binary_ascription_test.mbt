///|
test "binary function ascription empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x02\x40\x00\x01\x00\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "f", "func", "function", "false", "0", "none", "1", "out",
    "func", "function", "false", "0", "none", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "0", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (func)) (type $b (func)) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
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
    "world", "", "0", "1", "f", "func", "function", "false", "0", "none", "1", "out",
    "func", "function", "false", "0", "none", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "0", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x00\x73\x40\x01\x01\x78\x79\x00\x73\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="equal.wasm")
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "string", "1", "out", "func", "function", "false", "1",
    "x", "scalar", "u32", "some", "scalar", "string", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "string", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (func (param \"x\" u32) (result string))) (type $b (func (param \"x\" u32) (result string))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
    source_id="equal.wat",
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "string", "1", "out", "func", "function", "false", "1",
    "x", "scalar", "u32", "some", "scalar", "string", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "string", "definitions", "0",
  ])
}

///|
test "binary function ascription param-name" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x79\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component (type $a (func (param \"x\" u32))) (type $b (func (param \"y\" u32))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
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
test "binary function ascription param-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x78\x77\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component (type $a (func (param \"x\" u32))) (type $b (func (param \"x\" u64))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
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
test "binary function ascription param-count" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x02\x40\x00\x01\x00\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="param-count.wasm",
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
    "(component (type $a (func)) (type $b (func (param \"x\" u32))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
    source_id="param-count.wat",
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
test "binary function ascription result-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x02\x40\x00\x00\x79\x40\x00\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-type.wasm",
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
    "(component (type $a (func (result u32))) (type $b (func (result u64))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
    source_id="result-type.wat",
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
test "binary function ascription result-count" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x02\x40\x00\x01\x00\x40\x00\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-count.wasm",
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
    "(component (type $a (func)) (type $b (func (result u32))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
    source_id="result-count.wat",
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
test "binary function ascription async-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x43\x01\x01\x78\x79\x01\x00\x43\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="async-equal.wasm",
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
    "world", "", "0", "1", "f", "func", "function", "true", "1", "x", "scalar", "u32",
    "none", "1", "out", "func", "function", "true", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "1", "out", "func", "function", "true", "1",
    "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (func async (param \"x\" u32))) (type $b (func async (param \"x\" u32))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
    source_id="async-equal.wat",
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
    "world", "", "0", "1", "f", "func", "function", "true", "1", "x", "scalar", "u32",
    "none", "1", "out", "func", "function", "true", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "1", "out", "func", "function", "true", "1",
    "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription async-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x01\x00\x43\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component (type $a (func (param \"x\" u32))) (type $b (func async (param \"x\" u32))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
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
test "binary function ascription instance-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-alias.wasm",
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
    "(component (type $i (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="instance-alias.wat",
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
test "binary function ascription list-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x70\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x03\x01\x70\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "list", "scalar", "u32", "b", "type", "list",
    "scalar", "u32", "f", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "list", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (list u32)) (import \"a\" (type $a (eq $ad))) (type $bd (list u32)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "list", "scalar", "u32", "b", "type", "list",
    "scalar", "u32", "f", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "list", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription list-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x70\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x03\x01\x70\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (list u32)) (import \"a\" (type $a (eq $ad))) (type $bd (list u64)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription fixed-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x67\x79\x03\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x67\x79\x03\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "fixed-list", "3", "scalar", "u32", "b",
    "type", "fixed-list", "3", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "fixed-list", "3", "scalar", "u32", "none", "1", "out", "func", "function",
    "false", "1", "x", "fixed-list", "3", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "fixed-list", "3",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (list u32 3)) (import \"a\" (type $a (eq $ad))) (type $bd (list u32 3)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "fixed-list", "3", "scalar", "u32", "b",
    "type", "fixed-list", "3", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "fixed-list", "3", "scalar", "u32", "none", "1", "out", "func", "function",
    "false", "1", "x", "fixed-list", "3", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "fixed-list", "3",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription fixed-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x67\x79\x03\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x67\x77\x03\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (list u32 3)) (import \"a\" (type $a (eq $ad))) (type $bd (list u64 3)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription map-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x63\x73\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x63\x73\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "map", "scalar", "string", "scalar", "u32",
    "b", "type", "map", "scalar", "string", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "1", "out",
    "func", "function", "false", "1", "x", "map", "scalar", "string", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (map string u32)) (import \"a\" (type $a (eq $ad))) (type $bd (map string u32)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "map", "scalar", "string", "scalar", "u32",
    "b", "type", "map", "scalar", "string", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "1", "out",
    "func", "function", "false", "1", "x", "map", "scalar", "string", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "binary function ascription map-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x63\x73\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x63\x73\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (map string u32)) (import \"a\" (type $a (eq $ad))) (type $bd (map string u64)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription future-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x65\x01\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "future", "some", "scalar", "u32", "b", "type",
    "future", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "future", "some", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "future", "some", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "future", "some",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (future u32)) (import \"a\" (type $a (eq $ad))) (type $bd (future u32)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "future", "some", "scalar", "u32", "b", "type",
    "future", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "future", "some", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "future", "some", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "future", "some",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription future-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x65\x01\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x65\x01\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (future u32)) (import \"a\" (type $a (eq $ad))) (type $bd (future u64)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription stream-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x66\x01\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "stream", "some", "scalar", "u32", "b", "type",
    "stream", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "stream", "some", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "stream", "some", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "stream", "some",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (stream u32)) (import \"a\" (type $a (eq $ad))) (type $bd (stream u32)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "stream", "some", "scalar", "u32", "b", "type",
    "stream", "some", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "stream", "some", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "stream", "some", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "stream", "some",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription stream-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x04\x01\x66\x01\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (stream u32)) (import \"a\" (type $a (eq $ad))) (type $bd (stream u64)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription record-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "record", "1", "x", "scalar", "u32", "b",
    "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "record", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "record", "1", "x",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (record (field \"x\" u32))) (import \"a\" (type $a (eq $ad))) (type $bd (record (field \"x\" u32))) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "record", "1", "x", "scalar", "u32", "b",
    "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
    "1", "x", "record", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "record", "1", "x",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription record-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x06\x01\x72\x01\x01\x78\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (record (field \"x\" u32))) (import \"a\" (type $a (eq $ad))) (type $bd (record (field \"x\" u64))) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription variant-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x71\x01\x01\x78\x01\x79\x00\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x08\x01\x71\x01\x01\x78\x01\x79\x00\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "variant", "1", "x", "some", "scalar", "u32",
    "b", "type", "variant", "1", "x", "some", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "1",
    "out", "func", "function", "false", "1", "x", "variant", "1", "x", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (variant (case \"x\" u32))) (import \"a\" (type $a (eq $ad))) (type $bd (variant (case \"x\" u32))) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "variant", "1", "x", "some", "scalar", "u32",
    "b", "type", "variant", "1", "x", "some", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "1",
    "out", "func", "function", "false", "1", "x", "variant", "1", "x", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "variant", "1", "x", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "binary function ascription variant-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x71\x01\x01\x78\x01\x79\x00\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x08\x01\x71\x01\x01\x78\x01\x77\x00\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (variant (case \"x\" u32))) (import \"a\" (type $a (eq $ad))) (type $bd (variant (case \"x\" u64))) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription tuple-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x6f\x02\x79\x73\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x05\x01\x6f\x02\x79\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "tuple", "2", "scalar", "u32", "scalar",
    "string", "b", "type", "tuple", "2", "scalar", "u32", "scalar", "string", "f",
    "func", "function", "false", "1", "x", "tuple", "2", "scalar", "u32", "scalar",
    "string", "none", "1", "out", "func", "function", "false", "1", "x", "tuple",
    "2", "scalar", "u32", "scalar", "string", "none", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "tuple", "2", "scalar",
    "u32", "scalar", "string", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (tuple u32 string)) (import \"a\" (type $a (eq $ad))) (type $bd (tuple u32 string)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "tuple", "2", "scalar", "u32", "scalar",
    "string", "b", "type", "tuple", "2", "scalar", "u32", "scalar", "string", "f",
    "func", "function", "false", "1", "x", "tuple", "2", "scalar", "u32", "scalar",
    "string", "none", "1", "out", "func", "function", "false", "1", "x", "tuple",
    "2", "scalar", "u32", "scalar", "string", "none", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "tuple", "2", "scalar",
    "u32", "scalar", "string", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription tuple-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x6f\x02\x79\x73\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x05\x01\x6f\x02\x77\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (tuple u32 string)) (import \"a\" (type $a (eq $ad))) (type $bd (tuple u64 string)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription option-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x6b\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x03\x01\x6b\x79\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "world", "", "0", "3", "a", "type", "option", "scalar", "u32", "b", "type", "option",
    "scalar", "u32", "f", "func", "function", "false", "1", "x", "option", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "option", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "option", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (option u32)) (import \"a\" (type $a (eq $ad))) (type $bd (option u32)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
    "world", "", "0", "3", "a", "type", "option", "scalar", "u32", "b", "type", "option",
    "scalar", "u32", "f", "func", "function", "false", "1", "x", "option", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "option", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "option", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription option-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x6b\x79\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x03\x01\x6b\x77\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (option u32)) (import \"a\" (type $a (eq $ad))) (type $bd (option u64)) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription result-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x6a\x01\x79\x01\x73\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x06\x01\x6a\x01\x79\x01\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-equal.wasm",
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
    "world", "", "0", "3", "a", "type", "result", "some", "scalar", "u32", "some",
    "scalar", "string", "b", "type", "result", "some", "scalar", "u32", "some", "scalar",
    "string", "f", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "1", "out", "func", "function", "false",
    "1", "x", "result", "some", "scalar", "u32", "some", "scalar", "string", "none",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "result", "some", "scalar", "u32", "some", "scalar", "string", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (result u32 (error string))) (import \"a\" (type $a (eq $ad))) (type $bd (result u32 (error string))) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="result-equal.wat",
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
    "world", "", "0", "3", "a", "type", "result", "some", "scalar", "u32", "some",
    "scalar", "string", "b", "type", "result", "some", "scalar", "u32", "some", "scalar",
    "string", "f", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "1", "out", "func", "function", "false",
    "1", "x", "result", "some", "scalar", "u32", "some", "scalar", "string", "none",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "result", "some", "scalar", "u32", "some", "scalar", "string", "none", "definitions",
    "0",
  ])
}

///|
test "binary function ascription result-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x6a\x01\x79\x01\x73\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x06\x01\x6a\x01\x77\x01\x73\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
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
    "(component (type $ad (result u32 (error string))) (import \"a\" (type $a (eq $ad))) (type $bd (result u64 (error string))) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
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
test "binary function ascription resource-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x13\x04\x69\x00\x69\x00\x40\x01\x01\x78\x02\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x16\x03\x06\x00\x01\x72\x01\x01\x73\x02\x01\x61\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-equal.wasm",
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
    "1", "f", "func", "function", "false", "1", "x", "own", "0", "none", "1", "out",
    "func", "function", "false", "1", "x", "own", "0", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "own", "0", "none",
    "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (import \"s\" (type $s (sub resource))) (type $a (own $r)) (type $b (own $r)) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="resource-equal.wat",
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
    "1", "f", "func", "function", "false", "1", "x", "own", "0", "none", "1", "out",
    "func", "function", "false", "1", "x", "own", "0", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "own", "0", "none",
    "definitions", "0",
  ])
}

///|
test "binary function ascription resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x13\x04\x69\x00\x69\x01\x40\x01\x01\x78\x02\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x16\x03\x06\x00\x01\x72\x01\x01\x73\x02\x01\x61\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-mismatch.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (import \"s\" (type $s (sub resource))) (type $a (own $r)) (type $b (own $s)) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="resource-mismatch.wat",
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
test "binary function ascription scalar-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x03\x79\x40\x01\x01\x78\x00\x01\x00\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x6e\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-alias.wasm",
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $n u32) (type $a (func (param \"x\" $n))) (type $b (func (param \"x\" u32))) (import \"f\" (func $f (type $a))) (export \"out\" (func $f) (func (type $b))))",
    source_id="scalar-alias.wat",
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription reexport-chain" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x01\x00\x01\x01\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x01\x01\x01\x01\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "first", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "second", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "2", "first", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "second", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (func (param \"x\" u32))) (type $b (func (param \"x\" u32))) (import \"f\" (func (type $a))) (export \"first\" (func 0) (func (type $b))) (export \"second\" (func 1) (func (type $a))))",
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "first", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "second", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "2", "first", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "second", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription reexport-chain-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x03\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x78\x77\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x01\x00\x01\x01\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x01\x01\x01\x01\x02\x00\x1c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0b\x03\x03\x00\x01\x61\x01\x01\x62\x02\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-chain-mismatch.wasm",
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
    "(component (type $a (func (param \"x\" u32))) (type $b (func (param \"x\" u32))) (type $c (func (param \"x\" u64))) (import \"f\" (func (type $a))) (export \"first\" (func 0) (func (type $b))) (export \"second\" (func 1) (func (type $c))))",
    source_id="reexport-chain-mismatch.wat",
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
test "binary function ascription resource-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x06\x05\x01\x03\x02\x00\x00\x07\x13\x04\x69\x00\x69\x01\x40\x01\x01\x78\x02\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x16\x03\x06\x00\x01\x72\x01\x01\x73\x02\x01\x61\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-alias.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "1", "out", "func", "function", "false",
    "1", "x", "own", "0", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "own", "0", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (alias outer 0 $r (type $s)) (type $a (own $r)) (type $b (own $s)) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="resource-alias.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "1", "out", "func", "function", "false",
    "1", "x", "own", "0", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "own", "0", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription resource-handle-kind" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x13\x04\x69\x00\x68\x00\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x02\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x03\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x04\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x13\x03\x05\x00\x01\x72\x01\x01\x61\x02\x01\x62\x03\x02\x66\x61\x04\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-handle-kind.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $a (own $r)) (type $b (borrow $r)) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="resource-handle-kind.wat",
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
test "binary function ascription flags-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x01\x6e\x02\x03\x6f\x6e\x65\x03\x74\x77\x6f\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x0b\x01\x6e\x02\x03\x6f\x6e\x65\x03\x74\x77\x6f\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="flags-equal.wasm",
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
    "world", "", "0", "3", "a", "type", "flags", "2", "one", "two", "b", "type",
    "flags", "2", "one", "two", "f", "func", "function", "false", "1", "x", "flags",
    "2", "one", "two", "none", "1", "out", "func", "function", "false", "1", "x",
    "flags", "2", "one", "two", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "flags", "2", "one", "two", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (flags \"one\" \"two\")) (import \"a\" (type $a (eq $ad))) (type $bd (flags \"one\" \"two\")) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="flags-equal.wat",
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
    "world", "", "0", "3", "a", "type", "flags", "2", "one", "two", "b", "type",
    "flags", "2", "one", "two", "f", "func", "function", "false", "1", "x", "flags",
    "2", "one", "two", "none", "1", "out", "func", "function", "false", "1", "x",
    "flags", "2", "one", "two", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "flags", "2", "one", "two", "none", "definitions",
    "0",
  ])
}

///|
test "binary function ascription flags-order" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x01\x6e\x02\x03\x6f\x6e\x65\x03\x74\x77\x6f\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x0b\x01\x6e\x02\x03\x74\x77\x6f\x03\x6f\x6e\x65\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="flags-order.wasm",
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
    "(component (type $ad (flags \"one\" \"two\")) (import \"a\" (type $a (eq $ad))) (type $bd (flags \"two\" \"one\")) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="flags-order.wat",
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
test "binary function ascription enum-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x01\x6d\x02\x03\x6f\x6e\x65\x03\x74\x77\x6f\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x0b\x01\x6d\x02\x03\x6f\x6e\x65\x03\x74\x77\x6f\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="enum-equal.wasm",
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
    "world", "", "0", "3", "a", "type", "enum", "2", "one", "two", "b", "type", "enum",
    "2", "one", "two", "f", "func", "function", "false", "1", "x", "enum", "2", "one",
    "two", "none", "1", "out", "func", "function", "false", "1", "x", "enum", "2",
    "one", "two", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "enum", "2", "one", "two", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $ad (enum \"one\" \"two\")) (import \"a\" (type $a (eq $ad))) (type $bd (enum \"one\" \"two\")) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="enum-equal.wat",
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
    "world", "", "0", "3", "a", "type", "enum", "2", "one", "two", "b", "type", "enum",
    "2", "one", "two", "f", "func", "function", "false", "1", "x", "enum", "2", "one",
    "two", "none", "1", "out", "func", "function", "false", "1", "x", "enum", "2",
    "one", "two", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "enum", "2", "one", "two", "none", "definitions", "0",
  ])
}

///|
test "binary function ascription enum-order" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x01\x6d\x02\x03\x6f\x6e\x65\x03\x74\x77\x6f\x0a\x07\x01\x00\x01\x61\x03\x00\x00\x07\x0b\x01\x6d\x02\x03\x74\x77\x6f\x03\x6f\x6e\x65\x0a\x07\x01\x00\x01\x62\x03\x00\x02\x07\x0f\x02\x40\x01\x01\x78\x01\x01\x00\x40\x01\x01\x78\x03\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x04\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x05\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x18\x03\x06\x00\x02\x61\x64\x01\x01\x61\x02\x02\x62\x64\x03\x01\x62\x04\x02\x66\x61\x05\x02\x66\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="enum-order.wasm",
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
    "(component (type $ad (enum \"one\" \"two\")) (import \"a\" (type $a (eq $ad))) (type $bd (enum \"two\" \"one\")) (import \"b\" (type $b (eq $bd))) (type $fa (func (param \"x\" $a))) (type $fb (func (param \"x\" $b))) (import \"f\" (func $f (type $fa))) (export \"out\" (func $f) (func (type $fb))))",
    source_id="enum-order.wat",
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
