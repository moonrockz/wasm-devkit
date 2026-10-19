// Original fixtures and pinned reference results: tests/semantic/wac-component-ascriptions/.

///|
test "component export ascription empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x41\x00\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "1", "c",
    "component", "world", "", "0", "0", "0", "instance", "interface", "", "0", "1",
    "c", "component", "world", "", "0", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component )) (type $b (component )) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "1", "c",
    "component", "world", "", "0", "0", "0", "instance", "interface", "", "0", "1",
    "c", "component", "world", "", "0", "0", "0", "definitions", "0",
  ])
}

///|
test "component export ascription function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x04\x00\x01\x66\x01\x00\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "1",
    "c", "component", "world", "", "0", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (func (param \"x\" u32) (result string))) (export \"f\" (func (type 0))))) (type $b (component (type (func (param \"x\" u32) (result string))) (export \"f\" (func (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "1",
    "c", "component", "world", "", "0", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "definitions",
    "0",
  ])
}

///|
test "component export ascription function-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x41\x02\x01\x40\x01\x01\x78\x77\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-mismatch.wasm",
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
    "(component  (type $a (component (type (func (param \"x\" u64))) (export \"f\" (func (type 0))))) (type $b (component (type (func (param \"x\" u32))) (export \"f\" (func (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="function-mismatch.wat",
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
test "component export ascription fewer-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x41\x00\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x03\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="fewer-imports.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "1", "c",
    "component", "world", "", "0", "1", "f", "func", "function", "false", "1", "x",
    "scalar", "u32", "some", "scalar", "string", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component )) (type $b (component (type (func (param \"x\" u32) (result string))) (import \"f\" (func (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="fewer-imports.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "1", "c",
    "component", "world", "", "0", "1", "f", "func", "function", "false", "1", "x",
    "scalar", "u32", "some", "scalar", "string", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "0", "definitions", "0",
  ])
}

///|
test "component export ascription extra-import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x03\x00\x01\x66\x01\x00\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="extra-import.wasm",
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
    "(component  (type $a (component (type (func (param \"x\" u32) (result string))) (import \"f\" (func (type 0))))) (type $b (component )) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="extra-import.wat",
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
test "component export ascription extra-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x04\x00\x01\x66\x01\x00\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "1",
    "c", "component", "world", "", "0", "0", "0", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (func (param \"x\" u32) (result string))) (export \"f\" (func (type 0))))) (type $b (component )) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "1",
    "c", "component", "world", "", "0", "0", "0", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "0", "0", "definitions", "0",
  ])
}

///|
test "component export ascription missing-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x41\x00\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component  (type $a (component )) (type $b (component (type (func (param \"x\" u32) (result string))) (export \"f\" (func (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
test "component export ascription import-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x03\x00\x01\x66\x01\x00\x41\x02\x01\x40\x01\x01\x78\x79\x00\x73\x03\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-function.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "0",
    "1", "c", "component", "world", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "0", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (func (param \"x\" u32) (result string))) (import \"f\" (func (type 0))))) (type $b (component (type (func (param \"x\" u32) (result string))) (import \"f\" (func (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-function.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "0",
    "1", "c", "component", "world", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "string", "0", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "string", "0", "definitions",
    "0",
  ])
}

///|
test "component export ascription import-function-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x02\x41\x02\x01\x40\x01\x01\x78\x77\x01\x00\x03\x00\x01\x66\x01\x00\x41\x02\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-function-mismatch.wasm",
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
    "(component  (type $a (component (type (func (param \"x\" u64))) (import \"f\" (func (type 0))))) (type $b (component (type (func (param \"x\" u32))) (import \"f\" (func (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-function-mismatch.wat",
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
test "component export ascription value" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x41\x02\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x41\x02\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "t", "type",
    "list", "scalar", "u32", "1", "c", "component", "world", "", "0", "0", "1", "t",
    "type", "list", "scalar", "u32", "instance", "interface", "", "0", "1", "c",
    "component", "world", "", "0", "0", "1", "t", "type", "list", "scalar", "u32",
    "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (list u32)) (export \"t\" (type (eq 0))))) (type $b (component (type (list u32)) (export \"t\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "t", "type",
    "list", "scalar", "u32", "1", "c", "component", "world", "", "0", "0", "1", "t",
    "type", "list", "scalar", "u32", "instance", "interface", "", "0", "1", "c",
    "component", "world", "", "0", "0", "1", "t", "type", "list", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
test "component export ascription value-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x41\x02\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x41\x02\x01\x70\x77\x04\x00\x01\x74\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component  (type $a (component (type (list u32)) (export \"t\" (type (eq 0))))) (type $b (component (type (list u64)) (export \"t\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
test "component export ascription import-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x33\x02\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-resource.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "r", "type",
    "resource", "0", "1", "make", "func", "function", "false", "0", "some", "own",
    "0", "1", "c", "component", "world", "", "0", "1", "r", "type", "resource", "1",
    "1", "make", "func", "function", "false", "0", "some", "own", "1", "instance",
    "interface", "", "0", "1", "c", "component", "world", "", "0", "1", "r", "type",
    "resource", "1", "1", "make", "func", "function", "false", "0", "some", "own",
    "1", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (import \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (type $b (component (import \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-resource.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "r", "type",
    "resource", "0", "1", "make", "func", "function", "false", "0", "some", "own",
    "0", "1", "c", "component", "world", "", "0", "1", "r", "type", "resource", "1",
    "1", "make", "func", "function", "false", "0", "some", "own", "1", "instance",
    "interface", "", "0", "1", "c", "component", "world", "", "0", "1", "r", "type",
    "resource", "1", "1", "make", "func", "function", "false", "0", "some", "own",
    "1", "definitions", "0",
  ])
}

///|
test "component export ascription import-resource-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x02\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-resource-hidden.wasm",
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
    "(component  (type $a (component (import \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (type $b (component )) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-resource-hidden.wat",
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
test "component export ascription export-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x33\x02\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-resource.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "c", "component", "world", "", "0", "0", "2", "r", "type", "resource", "1",
    "make", "func", "function", "false", "0", "some", "own", "1", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type", "resource",
    "1", "make", "func", "function", "false", "0", "some", "own", "1", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (type $b (component (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-resource.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "c", "component", "world", "", "0", "0", "2", "r", "type", "resource", "1",
    "make", "func", "function", "false", "0", "some", "own", "1", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type", "resource",
    "1", "make", "func", "function", "false", "0", "some", "own", "1", "definitions",
    "0",
  ])
}

///|
test "component export ascription export-resource-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x02\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-resource-hidden.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "c", "component", "world", "", "0", "0", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (export \"r\" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (type $b (component )) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-resource-hidden.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "make", "func", "function", "false", "0", "some", "own", "0",
    "1", "c", "component", "world", "", "0", "0", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "0", "0", "definitions", "0",
  ])
}

///|
test "component export ascription resource-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x1d\x02\x41\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "0", "1", "r", "type", "resource",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type $a (component (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (type $b (component (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "0", "1", "r", "type", "resource",
    "0", "definitions", "0",
  ])
}

///|
test "component export ascription resource-wrong-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x1d\x02\x41\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x41\x02\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x02\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x03\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x02\x01\x61\x03\x01\x62"
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
    "(component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type $a (component (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (type $b (component (alias outer 1 1 (type)) (export \"r\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
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
test "component export ascription import-instance" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2d\x02\x41\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x03\x00\x01\x69\x05\x00\x41\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x03\x00\x01\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-instance.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "i", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "0", "1", "c", "component", "world", "", "0", "1", "i", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar", "u32",
    "0", "instance", "interface", "", "0", "1", "c", "component", "world", "", "0",
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "some", "scalar", "u32", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (import \"i\" (instance (type 0))))) (type $b (component (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (import \"i\" (instance (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-instance.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "i", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "0", "1", "c", "component", "world", "", "0", "1", "i", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar", "u32",
    "0", "instance", "interface", "", "0", "1", "c", "component", "world", "", "0",
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "some", "scalar", "u32", "0", "definitions", "0",
  ])
}

///|
test "component export ascription import-instance-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2d\x02\x41\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x03\x00\x01\x69\x05\x00\x41\x02\x01\x42\x02\x01\x40\x00\x00\x77\x04\x00\x01\x66\x01\x00\x03\x00\x01\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-instance-mismatch.wasm",
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
    "(component  (type $a (component (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (import \"i\" (instance (type 0))))) (type $b (component (type (instance (type (func (result u64))) (export \"f\" (func (type 0))))) (import \"i\" (instance (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-instance-mismatch.wat",
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
test "component export ascription import-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x03\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x03\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-module.wasm",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (core type (module (export \"m\" (memory 1 10)))) (import \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 1 10)))) (import \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-module.wat",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ])
}

///|
test "component export ascription import-module-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x03\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x03\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-module-narrow.wasm",
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
    "(component  (type $a (component (core type (module (export \"m\" (memory 2 5)))) (import \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 1 10)))) (import \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-module-narrow.wat",
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
test "component export ascription import-module-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x03\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x03\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-module-wide.wasm",
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
    exports: [{ name: "m", kind: Memory(2UL, Some(5UL), false, false, None), }],
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
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (core type (module (export \"m\" (memory 1 10)))) (import \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 2 5)))) (import \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-module-wide.wat",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ])
}

///|
test "component export ascription export-instance" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2d\x02\x41\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x04\x00\x01\x69\x05\x00\x41\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x04\x00\x01\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-instance.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "i", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "1", "c", "component", "world", "", "0", "0", "1", "i", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "0",
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "some", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (export \"i\" (instance (type 0))))) (type $b (component (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (export \"i\" (instance (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-instance.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "i", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar",
    "u32", "1", "c", "component", "world", "", "0", "0", "1", "i", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "0",
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "some", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "component export ascription export-instance-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2d\x02\x41\x02\x01\x42\x02\x01\x40\x00\x00\x79\x04\x00\x01\x66\x01\x00\x04\x00\x01\x69\x05\x00\x41\x02\x01\x42\x02\x01\x40\x00\x00\x77\x04\x00\x01\x66\x01\x00\x04\x00\x01\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-instance-mismatch.wasm",
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
    "(component  (type $a (component (type (instance (type (func (result u32))) (export \"f\" (func (type 0))))) (export \"i\" (instance (type 0))))) (type $b (component (type (instance (type (func (result u64))) (export \"f\" (func (type 0))))) (export \"i\" (instance (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-instance-mismatch.wat",
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
test "component export ascription export-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-module.wasm",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
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
    "c",
    "component",
    "world",
    "",
    "0",
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
    "(component  (type $a (component (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-module.wat",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
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
    "c",
    "component",
    "world",
    "",
    "0",
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
test "component export ascription export-module-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-module-narrow.wasm",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
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
    "c",
    "component",
    "world",
    "",
    "0",
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
    "(component  (type $a (component (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-module-narrow.wat",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
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
    "c",
    "component",
    "world",
    "",
    "0",
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
test "component export ascription export-module-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-module-wide.wasm",
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
    "(component  (type $a (component (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-module-wide.wat",
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
test "component export ascription nested-component" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x02\x41\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x41\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-component.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "c", "component",
    "world", "", "0", "0", "0", "1", "c", "component", "world", "", "0", "0", "1",
    "c", "component", "world", "", "0", "0", "0", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "0", "1", "c", "component", "world",
    "", "0", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (component)) (export \"c\" (component (type 0))))) (type $b (component (type (component)) (export \"c\" (component (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="nested-component.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "c", "component",
    "world", "", "0", "0", "0", "1", "c", "component", "world", "", "0", "0", "1",
    "c", "component", "world", "", "0", "0", "0", "instance", "interface", "", "0",
    "1", "c", "component", "world", "", "0", "0", "1", "c", "component", "world",
    "", "0", "0", "0", "definitions", "0",
  ])
}

///|
test "component export ascription nested-component-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x02\x41\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-component-mismatch.wasm",
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
    "(component  (type $a (component (type (component)) (export \"c\" (component (type 0))))) (type $b (component (type (component (type (func)) (export \"f\" (func (type 0))))) (export \"c\" (component (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="nested-component-mismatch.wat",
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
test "component export ascription import-fresh-to-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x17\x02\x41\x01\x03\x00\x01\x72\x03\x01\x41\x02\x02\x03\x02\x01\x00\x03\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-fresh-to-capture.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "1", "0", "1", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "1", "r", "type", "resource", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type $a (component (import \"r\" (type (sub resource))))) (type $b (component (alias outer 1 0 (type)) (import \"r\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-fresh-to-capture.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "1", "0", "1", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "1", "r", "type", "resource", "0",
    "0", "definitions", "0",
  ])
}

///|
test "component export ascription import-capture-to-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x17\x02\x41\x02\x02\x03\x02\x01\x00\x03\x00\x01\x72\x03\x00\x00\x41\x01\x03\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-capture-to-fresh.wasm",
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
    "(component (import \"r\" (type (sub resource))) (type $a (component (alias outer 1 0 (type)) (import \"r\" (type (eq 0))))) (type $b (component (import \"r\" (type (sub resource))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-capture-to-fresh.wat",
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
test "component export ascription import-resource-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x41\x02\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x00\x00\x41\x02\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-resource-alias.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "0", "0", "1", "c", "component", "world",
    "", "0", "2", "r", "type", "resource", "1", "s", "type", "resource", "1", "0",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "2",
    "r", "type", "resource", "1", "s", "type", "resource", "1", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (import \"r\" (type (sub resource))) (import \"s\" (type (eq 0))))) (type $b (component (import \"r\" (type (sub resource))) (import \"s\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-resource-alias.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "0", "0", "1", "c", "component", "world",
    "", "0", "2", "r", "type", "resource", "1", "s", "type", "resource", "1", "0",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "2",
    "r", "type", "resource", "1", "s", "type", "resource", "1", "0", "definitions",
    "0",
  ])
}

///|
test "component export ascription import-resource-distinct-to-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x41\x02\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x41\x02\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-resource-distinct-to-alias.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "1", "0", "1", "c", "component", "world",
    "", "0", "2", "r", "type", "resource", "2", "s", "type", "resource", "2", "0",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "2",
    "r", "type", "resource", "2", "s", "type", "resource", "2", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))))) (type $b (component (import \"r\" (type (sub resource))) (import \"s\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-resource-distinct-to-alias.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "1", "0", "1", "c", "component", "world",
    "", "0", "2", "r", "type", "resource", "2", "s", "type", "resource", "2", "0",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "2",
    "r", "type", "resource", "2", "s", "type", "resource", "2", "0", "definitions",
    "0",
  ])
}

///|
test "component export ascription import-resource-alias-to-distinct" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x41\x02\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x00\x00\x41\x02\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-resource-alias-to-distinct.wasm",
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
    "(component  (type $a (component (import \"r\" (type (sub resource))) (import \"s\" (type (eq 0))))) (type $b (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-resource-alias-to-distinct.wat",
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
test "component export ascription export-fresh-to-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x17\x02\x41\x01\x04\x00\x01\x72\x03\x01\x41\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-fresh-to-capture.wasm",
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
    "(component (import \"r\" (type (sub resource))) (type $a (component (export \"r\" (type (sub resource))))) (type $b (component (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-fresh-to-capture.wat",
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
test "component export ascription export-capture-to-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x17\x02\x41\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x41\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-capture-to-fresh.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "1", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "0", "1", "r", "type", "resource",
    "1", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type $a (component (alias outer 1 0 (type)) (export \"r\" (type (eq 0))))) (type $b (component (export \"r\" (type (sub resource))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-capture-to-fresh.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "1", "instance", "interface", "",
    "0", "1", "c", "component", "world", "", "0", "0", "1", "r", "type", "resource",
    "1", "definitions", "0",
  ])
}

///|
test "component export ascription export-resource-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x41\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x41\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-resource-alias.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "1", "s", "type", "resource", "1",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "0",
    "2", "r", "type", "resource", "1", "s", "type", "resource", "1", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (type $b (component (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-resource-alias.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "1", "s", "type", "resource", "1",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "0",
    "2", "r", "type", "resource", "1", "s", "type", "resource", "1", "definitions",
    "0",
  ])
}

///|
test "component export ascription export-resource-distinct-to-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x41\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x01\x41\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-resource-distinct-to-alias.wasm",
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
    "(component  (type $a (component (export \"r\" (type (sub resource))) (export \"s\" (type (sub resource))))) (type $b (component (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-resource-distinct-to-alias.wat",
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
test "component export ascription export-resource-alias-to-distinct" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x41\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x00\x00\x41\x02\x04\x00\x01\x72\x03\x01\x04\x00\x01\x73\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-resource-alias-to-distinct.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "1", "s", "type", "resource", "2",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "0",
    "2", "r", "type", "resource", "1", "s", "type", "resource", "2", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (type $b (component (export \"r\" (type (sub resource))) (export \"s\" (type (sub resource))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-resource-alias-to-distinct.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "s", "type", "resource", "0", "1", "c", "component", "world",
    "", "0", "0", "2", "r", "type", "resource", "1", "s", "type", "resource", "2",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "0",
    "2", "r", "type", "resource", "1", "s", "type", "resource", "2", "definitions",
    "0",
  ])
}

///|
test "component export ascription resource-use-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x3f\x02\x41\x05\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x01\x69\x00\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x41\x05\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-use-mismatch.wasm",
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
    "(component  (type $a (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (own 0)) (type (func (result 2))) (export \"make\" (func (type 3))))) (type $b (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="resource-use-mismatch.wat",
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
test "component export ascription import-instance-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x02\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x69\x05\x00\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-instance-resource.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "0", "1", "c", "component",
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "0", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (instance (export \"r\" (type (sub resource))))) (import \"i\" (instance (type 0))))) (type $b (component (type (instance (export \"r\" (type (sub resource))))) (import \"i\" (instance (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="import-instance-resource.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "0", "1", "c", "component",
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "0", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "0", "definitions", "0",
  ])
}

///|
test "component export ascription export-instance-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x02\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x04\x00\x01\x69\x05\x00\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x04\x00\x01\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="export-instance-resource.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "1", "c", "component",
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "1", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "1", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (instance (export \"r\" (type (sub resource))))) (export \"i\" (instance (type 0))))) (type $b (component (type (instance (export \"r\" (type (sub resource))))) (export \"i\" (instance (type 0))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="export-instance-resource.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "1", "c", "component",
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "1", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "1", "definitions", "0",
  ])
}

///|
test "component export ascription instance-resource-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x5d\x02\x41\x07\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x69\x05\x00\x03\x00\x01\x6a\x05\x00\x02\x03\x00\x00\x01\x72\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x41\x07\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x69\x05\x00\x03\x00\x01\x6a\x05\x00\x02\x03\x00\x00\x01\x72\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-resource-capture.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "2", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "j", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "1", "1", "make", "func", "function",
    "false", "0", "some", "own", "0", "1", "c", "component", "world", "", "0", "2",
    "i", "instance", "interface", "", "0", "1", "r", "type", "resource", "2", "j",
    "instance", "interface", "", "0", "1", "r", "type", "resource", "3", "1", "make",
    "func", "function", "false", "0", "some", "own", "2", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "2", "i", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "2", "j", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "3", "1", "make", "func", "function", "false",
    "0", "some", "own", "2", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component  (type $a (component (type (instance (export \"r\" (type (sub resource))))) (import \"i\" (instance (type 0))) (import \"j\" (instance (type 0))) (alias export 0 \"r\" (type)) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (type $b (component (type (instance (export \"r\" (type (sub resource))))) (import \"i\" (instance (type 0))) (import \"j\" (instance (type 0))) (alias export 0 \"r\" (type)) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="instance-resource-capture.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "2", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "j", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "1", "1", "make", "func", "function",
    "false", "0", "some", "own", "0", "1", "c", "component", "world", "", "0", "2",
    "i", "instance", "interface", "", "0", "1", "r", "type", "resource", "2", "j",
    "instance", "interface", "", "0", "1", "r", "type", "resource", "3", "1", "make",
    "func", "function", "false", "0", "some", "own", "2", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "2", "i", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "2", "j", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "3", "1", "make", "func", "function", "false",
    "0", "some", "own", "2", "definitions", "0",
  ])
}

///|
test "component export ascription instance-resource-wrong-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x5d\x02\x41\x07\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x69\x05\x00\x03\x00\x01\x6a\x05\x00\x02\x03\x00\x00\x01\x72\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x41\x07\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x69\x05\x00\x03\x00\x01\x6a\x05\x00\x02\x03\x00\x01\x01\x72\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-resource-wrong-capture.wasm",
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
    "(component  (type $a (component (type (instance (export \"r\" (type (sub resource))))) (import \"i\" (instance (type 0))) (import \"j\" (instance (type 0))) (alias export 0 \"r\" (type)) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (type $b (component (type (instance (export \"r\" (type (sub resource))))) (import \"i\" (instance (type 0))) (import \"j\" (instance (type 0))) (alias export 1 \"r\" (type)) (type (own 1)) (type (func (result 2))) (export \"make\" (func (type 3))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="instance-resource-wrong-capture.wat",
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
test "component export ascription nested-component-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x63\x02\x41\x04\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x01\x41\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x02\x41\x04\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x01\x41\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-component-capture.wasm",
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
    "(component  (type $a (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (component (alias outer 1 0 (type)) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"child\" (component (type 2))))) (type $b (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (component (alias outer 1 0 (type)) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"child\" (component (type 2))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="nested-component-capture.wat",
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
test "component export ascription nested-component-wrong-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x63\x02\x41\x04\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x01\x41\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x02\x41\x04\x03\x00\x01\x72\x03\x01\x03\x00\x01\x73\x03\x01\x01\x41\x04\x02\x03\x02\x01\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-component-wrong-capture.wasm",
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
    "(component  (type $a (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (component (alias outer 1 0 (type)) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"child\" (component (type 2))))) (type $b (component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (component (alias outer 1 1 (type)) (type (own 0)) (type (func (result 1))) (export \"make\" (func (type 2))))) (export \"child\" (component (type 2))))) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type $b))))\n",
    source_id="nested-component-wrong-capture.wat",
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
test "component export ascription reexport-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x04\x00\x01\x04\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x04\x01\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "component",
    "world",
    "",
    "0",
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
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "component",
    "world",
    "",
    "0",
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
    "(component (type $a (component (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"first\" (component 0) (component (type $b))) (export \"second\" (component 1) (component (type $b))))\n",
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
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "component",
    "world",
    "",
    "0",
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
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "component",
    "world",
    "",
    "0",
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
test "component export ascription reexport-module-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x02\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x02\x05\x04\x00\x01\x6d\x00\x11\x00\x41\x02\x00\x50\x01\x03\x01\x6d\x02\x01\x01\x0a\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x04\x00\x01\x04\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x04\x01\x01\x04\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component (type $a (component (core type (module (export \"m\" (memory 2 5)))) (export \"m\" (core module (type 0))))) (type $b (component (core type (module (export \"m\" (memory 1 10)))) (export \"m\" (core module (type 0))))) (import \"c\" (component (type $a))) (export \"first\" (component 0) (component (type $b))) (export \"second\" (component 1) (component (type $a))))\n",
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
test "component export ascription alias-component" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x01\x42\x02\x01\x41\x00\x04\x00\x01\x63\x04\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x04\x00\x00\x01\x63\x07\x03\x01\x41\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="alias-component.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type (instance (type (component)) (export \"c\" (component (type 0))))) (import \"i\" (instance (type 0))) (alias export 0 \"c\" (component)) (type (component)) (export \"c\" (component 0) (component (type 1))))\n",
    source_id="alias-component.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B002")
}

///|
test "component export ascription reexport-unannotated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x18\x02\x00\x05\x66\x69\x72\x73\x74\x04\x00\x00\x00\x06\x73\x65\x63\x6f\x6e\x64\x04\x01\x01\x04\x00"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-unannotated.wasm",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "2", "first",
    "component", "world", "", "0", "0", "0", "second", "component", "world", "",
    "0", "0", "0", "instance", "interface", "", "0", "2", "first", "component", "world",
    "", "0", "0", "0", "second", "component", "world", "", "0", "0", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type (component)) (import \"c\" (component (type 0))) (export \"first\" (component 0)) (export \"second\" (component 1) (component (type 0))))\n",
    source_id="reexport-unannotated.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "2", "first",
    "component", "world", "", "0", "0", "0", "second", "component", "world", "",
    "0", "0", "0", "instance", "interface", "", "0", "2", "first", "component", "world",
    "", "0", "0", "0", "second", "component", "world", "", "0", "0", "0", "definitions",
    "0",
  ])
}

///|
test "component export ascription reexport-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x04\x00\x01\x04\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x04\x01\x01\x04\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "(component (type $a (component (type (func)) (export \"f\" (func (type 0))))) (type $b (component)) (import \"c\" (component (type $a))) (export \"first\" (component 0) (component (type $b))) (export \"second\" (component 1) (component (type $a))))\n",
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
test "component export ascription reexport-visible" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x02\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x1a\x02\x00\x05\x66\x69\x72\x73\x74\x04\x00\x01\x04\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x04\x01\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func",
    "function", "false", "0", "none", "2", "first", "component", "world", "", "0",
    "0", "0", "second", "component", "world", "", "0", "0", "0", "instance", "interface",
    "", "0", "2", "first", "component", "world", "", "0", "0", "0", "second", "component",
    "world", "", "0", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (component (type (func)) (export \"f\" (func (type 0))))) (type $b (component)) (import \"c\" (component (type $a))) (export \"first\" (component 0) (component (type $b))) (export \"second\" (component 1) (component (type $b))))\n",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "f", "func",
    "function", "false", "0", "none", "2", "first", "component", "world", "", "0",
    "0", "0", "second", "component", "world", "", "0", "0", "0", "instance", "interface",
    "", "0", "2", "first", "component", "world", "", "0", "0", "0", "second", "component",
    "world", "", "0", "0", "0", "definitions", "0",
  ])
}

///|
test "component export ascription future-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x07\x03\x01\x41\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="future-type.wasm",
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
    "(component (type $a (component)) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type 1))) (type (component)))\n",
    source_id="future-type.wat",
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
test "component export ascription wrong-type-sort" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x41\x00\x42\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x01\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="wrong-type-sort.wasm",
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
    "(component (type $a (component)) (type (instance)) (import \"c\" (component (type $a))) (export \"c\" (component 0) (component (type 1))))\n",
    source_id="wrong-type-sort.wat",
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
