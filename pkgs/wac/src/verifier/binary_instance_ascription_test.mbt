// Original fixtures and pinned reference results: tests/semantic/wac-instance-ascriptions/.

///|
test "instance export ascription empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x42\x00\x42\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="empty.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "0", "1", "a",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "a", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance )) (type $b (instance )) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "0", "1", "a",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "a", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x42\x02\x01\x40\x01\x01\x78\x79\x00\x73\x04\x00\x01\x66\x01\x00\x42\x02\x01\x40\x01\x01\x78\x79\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "1",
    "a", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (func (param \"x\" u32) (result string))) (export \"f\" (func (type 0))))) (type $b (instance (type (func (param \"x\" u32) (result string))) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="function.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "1",
    "a", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "definitions",
    "0",
  ])
}

///|
test "instance export ascription function-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x42\x02\x01\x40\x01\x01\x78\x77\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-type.wasm",
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
    "(component  (type $a (instance (type (func (param \"x\" u32))) (export \"f\" (func (type 0))))) (type $b (instance (type (func (param \"x\" u64))) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="function-type.wat",
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
test "instance export ascription function-name" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x42\x02\x01\x40\x01\x01\x79\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-name.wasm",
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
    "(component  (type $a (instance (type (func (param \"x\" u32))) (export \"f\" (func (type 0))))) (type $b (instance (type (func (param \"y\" u32))) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="function-name.wat",
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
test "instance export ascription function-result" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x42\x02\x01\x40\x00\x00\x77\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-result.wasm",
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
    "(component  (type $a (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (type $b (instance (type (func (result u64))) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="function-result.wat",
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
test "instance export ascription function-async" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x42\x02\x01\x43\x00\x01\x00\x04\x00\x01\x66\x01\x00\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-async.wasm",
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
    "(component  (type $a (instance (type (func async)) (export \"f\" (func (type 0))))) (type $b (instance (type (func)) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="function-async.wat",
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
test "instance export ascription extra-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x42\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="extra-export.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "a", "instance", "interface", "", "0",
    "0", "instance", "interface", "", "0", "1", "a", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (func)) (export \"f\" (func (type 0))))) (type $b (instance )) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="extra-export.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "a", "instance", "interface", "", "0",
    "0", "instance", "interface", "", "0", "1", "a", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription missing-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x42\x00\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="missing-export.wasm",
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
    "(component  (type $a (instance )) (type $b (instance (type (func)) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="missing-export.wat",
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
test "instance export ascription value" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x42\x02\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x42\x02\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="value.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "t", "type",
    "list", "scalar", "u32", "1", "a", "instance", "interface", "", "0", "1", "t",
    "type", "list", "scalar", "u32", "instance", "interface", "", "0", "1", "a",
    "instance", "interface", "", "0", "1", "t", "type", "list", "scalar", "u32",
    "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (list u32)) (export \"t\" (type (eq 0))))) (type $b (instance (type (list u32)) (export \"t\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="value.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "t", "type",
    "list", "scalar", "u32", "1", "a", "instance", "interface", "", "0", "1", "t",
    "type", "list", "scalar", "u32", "instance", "interface", "", "0", "1", "a",
    "instance", "interface", "", "0", "1", "t", "type", "list", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
test "instance export ascription value-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x42\x02\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x42\x02\x01\x70\x77\x04\x00\x01\x74\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="value-mismatch.wasm",
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
    "(component  (type $a (instance (type (list u32)) (export \"t\" (type (eq 0))))) (type $b (instance (type (list u64)) (export \"t\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="value-mismatch.wat",
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
test "instance export ascription record-name" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x42\x02\x01\x72\x01\x01\x79\x79\x04\x00\x01\x74\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="record-name.wasm",
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
    "(component  (type $a (instance (type (record (field \"x\" u32))) (export \"t\" (type (eq 0))))) (type $b (instance (type (record (field \"y\" u32))) (export \"t\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="record-name.wat",
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
test "instance export ascription resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x33\x02\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource.wasm",
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
    "(component  (type $a (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (type $b (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource.wat",
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
test "instance export ascription resource-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x02\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x42\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-hidden.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "a", "instance", "interface", "", "0", "0", "instance", "interface", "",
    "0", "1", "a", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (type $b (instance )) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-hidden.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "a", "instance", "interface", "", "0", "0", "instance", "interface", "",
    "0", "1", "a", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription resource-renamed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x02\x42\x01\x04\x00\x01\x72\x03\x01\x42\x01\x04\x00\x01\x73\x03\x01\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-renamed.wasm",
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
    "(component  (type $a (instance (export \"r\" (type (sub resource))))) (type $b (instance (export \"s\" (type (sub resource))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-renamed.wat",
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
test "instance export ascription resource-fresh-from-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x17\x02\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x61\x05\x01\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-fresh-from-capture.wasm",
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
    "(component (import \"r\" (type (sub resource))) (type $a (instance (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (type $b (instance (export \"r\" (type (sub resource))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-fresh-from-capture.wat",
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
test "instance export ascription resource-capture-from-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x17\x02\x42\x01\x04\x00\x01\x72\x03\x01\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x01\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-capture-from-fresh.wasm",
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
    "(component (import \"r\" (type (sub resource))) (type $a (instance (export \"r\" (type (sub resource))))) (type $b (instance (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-capture-from-fresh.wat",
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
test "instance export ascription resource-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x1d\x02\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x01\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-capture.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "a", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "1", "a", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "instance", "interface", "", "0",
    "1", "a", "instance", "interface", "", "0", "1", "r", "type", "resource", "0",
    "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type $a (instance (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (type $b (instance (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-capture.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "a", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "1", "a", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "instance", "interface", "", "0",
    "1", "a", "instance", "interface", "", "0", "1", "r", "type", "resource", "0",
    "definitions", "0",
  ])
}

///|
test "instance export ascription resource-wrong-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x1d\x02\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x42\x02\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x02\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x03\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x02\x01\x61\x03\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-wrong-capture.wasm",
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
    "(component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type $a (instance (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (type $b (instance (alias outer 1 1 (type)) (export \"r\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-wrong-capture.wat",
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
test "instance export ascription resource-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x42\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x42\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-alias.wasm",
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
    "(component  (type $a (instance (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (type $b (instance (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-alias.wat",
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
test "instance export ascription resource-distinct-to-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x42\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x01\x42\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-distinct-to-alias.wasm",
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
    "(component  (type $a (instance (export \"r\" (type (sub resource))) (export \"s\" (type (sub resource))))) (type $b (instance (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-distinct-to-alias.wat",
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
test "instance export ascription resource-alias-to-distinct" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x42\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x42\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x01\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-alias-to-distinct.wasm",
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
    "(component  (type $a (instance (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (type $b (instance (export \"r\" (type (sub resource))) (export \"s\" (type (sub resource))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-alias-to-distinct.wat",
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
test "instance export ascription nested" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x35\x02\x42\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x42\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "1", "a", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "instance", "interface", "", "0", "1", "a", "instance", "interface", "",
    "0", "1", "child", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "0", "some", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (export \"child\" (instance (type 0))))) (type $b (instance (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (export \"child\" (instance (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="nested.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "1", "a", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "instance", "interface", "", "0", "1", "a", "instance", "interface", "",
    "0", "1", "child", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "0", "some", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "instance export ascription nested-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x35\x02\x42\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x42\x02\x01\x42\x02\x01\x40\x00\x00\x77\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-mismatch.wasm",
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
    "(component  (type $a (instance (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (export \"child\" (instance (type 0))))) (type $b (instance (type (instance (type (func (result u64))) (export \"f\" (func (type 0))))) (export \"child\" (instance (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="nested-mismatch.wat",
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
test "instance export ascription nested-resources" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4d\x02\x42\x02\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x42\x02\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-resources.wasm",
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
    "(component  (type $a (instance (type (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"child\" (instance (type 0))))) (type $b (instance (type (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"child\" (instance (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="nested-resources.wat",
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
test "instance export ascription component" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x02\x42\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x42\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "0", "1", "a", "instance", "interface", "", "0", "1",
    "c", "component", "world", "", "0", "0", "0", "instance", "interface", "", "0",
    "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world", "",
    "0", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (component )) (export \"c\" (component (type 0))))) (type $b (instance (type (component )) (export \"c\" (component (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="component.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "0", "1", "a", "instance", "interface", "", "0", "1",
    "c", "component", "world", "", "0", "0", "0", "instance", "interface", "", "0",
    "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world", "",
    "0", "0", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription component-missing" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x02\x42\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x42\x02\x01\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-missing.wasm",
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
    "(component  (type $a (instance (type (component )) (export \"c\" (component (type 0))))) (type $b (instance (type (component (type (func)) (export \"f\" (func (type 0))))) (export \"c\" (component (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="component-missing.wat",
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
test "instance export ascription module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="module.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  assert_eq(binary_projection(result.unwrap()), [
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="module.wat",
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
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
}

///|
test "instance export ascription module-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="module-narrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(2UL, Some(5UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  assert_eq(binary_projection(result.unwrap()), [
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="module-narrow.wat",
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
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
}

///|
test "instance export ascription module-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="module-wide.wasm",
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
    "(component  (type $a (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="module-wide.wat",
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
test "instance export ascription nested-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x02\x42\x02\x01\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x42\x02\x01\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-module.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(2UL, Some(5UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  assert_eq(binary_projection(result.unwrap()), [
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "child",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "child",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "child",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (export \"child\" (instance (type 0))))) (type $b (instance (type (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (export \"child\" (instance (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="nested-module.wat",
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
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "child",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "child",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "child",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
}

///|
test "instance export ascription nested-module-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x02\x42\x02\x01\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x42\x02\x01\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-module-mismatch.wasm",
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
    "(component  (type $a (instance (type (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (export \"child\" (instance (type 0))))) (type $b (instance (type (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (export \"child\" (instance (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="nested-module-mismatch.wat",
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
test "instance export ascription alias-ascribed-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x0d\x01\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x06\x07\x01\x00\x11\x00\x01\x01\x6d\x03\x0a\x01\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="alias-ascribed-module.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(2UL, Some(5UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_2 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_2 = match kind_2 {
    Module(m) => m
    _ => fail("expected module")
  }
  assert_eq(binary_projection(result.unwrap()), [
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "m",
    "module",
    module_2.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "m",
    "module",
    module_2.to_repr().to_string(),
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (alias export 1 \"m\" (core module)) (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module 0) (core module (type 0))))\n",
    source_id="alias-ascribed-module.wat",
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
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "m",
    "module",
    module_2.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "m",
    "module",
    module_2.to_repr().to_string(),
    "definitions",
    "0",
  ])
}

///|
test "instance export ascription alias-ascribed-module-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x0d\x01\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x06\x07\x01\x00\x11\x00\x01\x01\x6d\x03\x0a\x01\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="alias-ascribed-module-mismatch.wasm",
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
    "(component (type $a (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (alias export 1 \"m\" (core module)) (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module 0) (core module (type 0))))\n",
    source_id="alias-ascribed-module-mismatch.wat",
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
test "instance export ascription reexport-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x01\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-module.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(2UL, Some(5UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(10UL), false, false, None), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  assert_eq(binary_projection(result.unwrap()), [
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (export \"second\" (instance 1) (instance (type $b))))\n",
    source_id="reexport-module.wat",
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
    "world",
    "",
    "0",
    "1",
    "a",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "2",
    "first",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ])
}

///|
test "instance export ascription reexport-module-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x01\x01\x05\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-module-mismatch.wasm",
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
    "(component (type $a (instance (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (instance (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (export \"second\" (instance 1) (instance (type $a))))\n",
    source_id="reexport-module-mismatch.wat",
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
test "instance export ascription component-import-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x45\x02\x42\x02\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x01\x63\x04\x00\x42\x02\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-import-resource.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "make", "func", "function",
    "false", "0", "some", "own", "0", "1", "a", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "1", "r", "type", "resource", "1", "1",
    "make", "func", "function", "false", "0", "some", "own", "1", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "1", "1", "make", "func", "function",
    "false", "0", "some", "own", "1", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (component (import \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"c\" (component (type 0))))) (type $b (instance (type (component (import \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"c\" (component (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="component-import-resource.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "make", "func", "function",
    "false", "0", "some", "own", "0", "1", "a", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "1", "r", "type", "resource", "1", "1",
    "make", "func", "function", "false", "0", "some", "own", "1", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "1", "1", "make", "func", "function",
    "false", "0", "some", "own", "1", "definitions", "0",
  ])
}

///|
test "instance export ascription component-export-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x45\x02\x42\x02\x01\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x01\x63\x04\x00\x42\x02\x01\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-export-resource.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "make", "func", "function",
    "false", "0", "some", "own", "0", "1", "a", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "0", "2", "r", "type", "resource", "1",
    "make", "func", "function", "false", "0", "some", "own", "1", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "1", "make", "func", "function",
    "false", "0", "some", "own", "1", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (instance (type (component (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"c\" (component (type 0))))) (type $b (instance (type (component (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"c\" (component (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="component-export-resource.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "make", "func", "function",
    "false", "0", "some", "own", "0", "1", "a", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "0", "2", "r", "type", "resource", "1",
    "make", "func", "function", "false", "0", "some", "own", "1", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "1", "make", "func", "function",
    "false", "0", "some", "own", "1", "definitions", "0",
  ])
}

///|
test "instance export ascription component-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x51\x02\x42\x02\x01\x41\x05\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x04\x00\x01\x63\x04\x00\x42\x02\x01\x41\x05\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x61\x05\x02\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x03\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x02\x01\x61\x03\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-capture.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "3", "r", "type", "resource", "0", "s", "type", "resource",
    "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world", "",
    "0", "0", "2", "r", "type", "resource", "0", "make", "func", "function", "false",
    "0", "some", "own", "0", "1", "a", "instance", "interface", "", "0", "1", "c",
    "component", "world", "", "0", "0", "2", "r", "type", "resource", "0", "make",
    "func", "function", "false", "0", "some", "own", "0", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "0", "make", "func", "function",
    "false", "0", "some", "own", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type $a (instance (type (component (alias outer 2 0 (type)) (export \"r\" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (export \"c\" (component (type 0))))) (type $b (instance (type (component (alias outer 2 0 (type)) (export \"r\" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (export \"c\" (component (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="component-capture.wat",
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
    "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world", "",
    "0", "0", "2", "r", "type", "resource", "0", "make", "func", "function", "false",
    "0", "some", "own", "0", "1", "a", "instance", "interface", "", "0", "1", "c",
    "component", "world", "", "0", "0", "2", "r", "type", "resource", "0", "make",
    "func", "function", "false", "0", "some", "own", "0", "instance", "interface",
    "", "0", "1", "a", "instance", "interface", "", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "0", "make", "func", "function",
    "false", "0", "some", "own", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription component-wrong-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x51\x02\x42\x02\x01\x41\x05\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x04\x00\x01\x63\x04\x00\x42\x02\x01\x41\x05\x02\x03\x02\x02\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x61\x05\x02\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x03\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x02\x01\x61\x03\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-wrong-capture.wasm",
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
    "(component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type $a (instance (type (component (alias outer 2 0 (type)) (export \"r\" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (export \"c\" (component (type 0))))) (type $b (instance (type (component (alias outer 2 1 (type)) (export \"r\" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (export \"c\" (component (type 0))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="component-wrong-capture.wat",
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
test "instance export ascription resource-same-template" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-same-template.wasm",
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
    "(component (type $a (instance (export \"r\" (type (sub resource))))) (import \"a\" (instance (type $a))) (export \"a\" (instance 0) (instance (type $a))))\n",
    source_id="resource-same-template.wat",
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
test "instance export ascription resource-from-instance" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x0a\x06\x01\x00\x01\x61\x05\x00\x06\x06\x01\x03\x00\x00\x01\x72\x07\x20\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-from-instance.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "a", "instance", "interface", "", "1", "r", "r", "", "2", "r", "type", "resource",
    "0", "make", "func", "function", "false", "0", "some", "own", "0", "instance",
    "interface", "", "0", "1", "a", "instance", "interface", "", "1", "r", "r", "",
    "2", "r", "type", "resource", "0", "make", "func", "function", "false", "0",
    "some", "own", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (import \"a\" (instance (type $a))) (alias export 0 \"r\" (type)) (type $b (instance (alias outer 1 1 (type)) (export \"r\" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-from-instance.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "a", "instance", "interface", "", "1", "r", "r", "", "2", "r", "type", "resource",
    "0", "make", "func", "function", "false", "0", "some", "own", "0", "instance",
    "interface", "", "0", "1", "a", "instance", "interface", "", "1", "r", "r", "",
    "2", "r", "type", "resource", "0", "make", "func", "function", "false", "0",
    "some", "own", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription resource-from-other-instance" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x0a\x0b\x02\x00\x01\x61\x05\x00\x00\x01\x62\x05\x00\x06\x06\x01\x03\x00\x01\x01\x72\x07\x20\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x0b\x09\x01\x00\x01\x61\x05\x00\x01\x05\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-from-other-instance.wasm",
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
    "(component (type $a (instance (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (import \"a\" (instance (type $a))) (import \"b\" (instance (type $a))) (alias export 1 \"r\" (type)) (type $b (instance (alias outer 1 1 (type)) (export \"r\" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (export \"a\" (instance 0) (instance (type $b))))\n",
    source_id="resource-from-other-instance.wat",
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
test "instance export ascription alias-ascribed-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x31\x02\x42\x04\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x01\x40\x00\x01\x00\x04\x00\x06\x68\x69\x64\x64\x65\x6e\x01\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x0d\x01\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x06\x06\x01\x01\x00\x01\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x09\x01\x00\x01\x66\x01\x00\x01\x01\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="alias-ascribed-function.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "2", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "hidden", "func", "function",
    "false", "0", "none", "2", "first", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "2", "first", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (instance (type (func (param \"x\" u32))) (export \"f\" (func (type 0))) (type (func)) (export \"hidden\" (func (type 1))))) (type $b (instance (type (func (param \"x\" u32))) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (alias export 1 \"f\" (func)) (type (func (param \"x\" u32))) (export \"f\" (func 0) (func (type 2))))\n",
    source_id="alias-ascribed-function.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "2", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "hidden", "func", "function",
    "false", "0", "none", "2", "first", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "2", "first", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "instance export ascription alias-ascribed-function-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x0d\x01\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x06\x06\x01\x01\x00\x01\x01\x66\x07\x08\x01\x40\x01\x01\x78\x77\x01\x00\x0b\x09\x01\x00\x01\x66\x01\x00\x01\x01\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="alias-ascribed-function-mismatch.wasm",
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
    "(component (type $a (instance (type (func (param \"x\" u32))) (export \"f\" (func (type 0))))) (type $b (instance (type (func (param \"x\" u32))) (export \"f\" (func (type 0))))) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (alias export 1 \"f\" (func)) (type (func (param \"x\" u64))) (export \"f\" (func 0) (func (type 2))))\n",
    source_id="alias-ascribed-function-mismatch.wat",
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
test "instance export ascription reexport-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x42\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x01\x01\x05\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-hidden.wasm",
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
    "(component (type $a (instance (type (func)) (export \"f\" (func (type 0))))) (type $b (instance)) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (export \"second\" (instance 1) (instance (type $a))))\n",
    source_id="reexport-hidden.wat",
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
test "instance export ascription reexport-visible" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x42\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x01\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-visible.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "2", "first", "instance", "interface", "",
    "0", "0", "second", "instance", "interface", "", "0", "0", "instance", "interface",
    "", "0", "2", "first", "instance", "interface", "", "0", "0", "second", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (instance (type (func)) (export \"f\" (func (type 0))))) (type $b (instance)) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (export \"second\" (instance 1) (instance (type $b))))\n",
    source_id="reexport-visible.wat",
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
    "world", "", "0", "1", "a", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "2", "first", "instance", "interface", "",
    "0", "0", "second", "instance", "interface", "", "0", "0", "instance", "interface",
    "", "0", "2", "first", "instance", "interface", "", "0", "0", "second", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "instance export ascription alias-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x42\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x0d\x01\x00\x05\x66\x69\x72\x73\x74\x05\x00\x01\x05\x01\x06\x06\x01\x01\x00\x01\x01\x66\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="alias-hidden.wasm",
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
    "(component (type $a (instance (type (func)) (export \"f\" (func (type 0))))) (type $b (instance)) (import \"a\" (instance (type $a))) (export \"first\" (instance 0) (instance (type $b))) (alias export 1 \"f\" (func)))\n",
    source_id="alias-hidden.wat",
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
