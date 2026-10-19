// Original fixtures and pinned reference results: tests/semantic/wac-resource-intrinsics/import-capture-gaps/.

///|
test "imported resource capture instance-empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x02\x3f\x7f\x00\x42\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-empty.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance )) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-empty.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-unused-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x02\x3f\x7f\x00\x42\x01\x02\x03\x02\x01\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-unused-alias.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (alias outer 1 $r (type $r)))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-unused-alias.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x02\x3f\x7f\x00\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-fresh.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (export \"r\" (type (sub resource))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-fresh.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
test "imported resource capture instance-fresh-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x02\x3f\x7f\x00\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-fresh-own.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (export \"r\" (type (sub resource))) (type $f (func (param \"x\" (own 0)))) (export \"f\" (func (type $f))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-fresh-own.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-imported-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0f\x01\x42\x02\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x02\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x16\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-imported-type.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $imported (sub resource))) (type $i (instance (alias outer 1 $imported (type $r)) (export \"r\" (type (eq $r))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-imported-type.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-imported-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x02\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x16\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-imported-own.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $imported (sub resource))) (type $i (instance (alias outer 1 $imported (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (own 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-imported-own.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
test "imported resource capture instance-imported-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x02\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x16\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-imported-borrow.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0", "0",
    "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $imported (sub resource))) (type $i (instance (alias outer 1 $imported (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (borrow 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-imported-borrow.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0", "0",
    "definitions", "0",
  ])
}

///|
test "imported resource capture instance-nested-instance-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x3f\x7f\x00\x42\x02\x01\x42\x02\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-nested-instance-capture.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (type $inner (instance (alias outer 2 $r (type $r)) (export \"r\" (type (eq $r))))) (export \"child\" (instance (type $inner))))) (import \"i\" (instance (type $i))))\n",
    source_id="instance-nested-instance-capture.wat",
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
test "imported resource capture instance-nested-instance-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x3f\x7f\x00\x42\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-nested-instance-fresh.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (type $inner (instance (export \"r\" (type (sub resource))))) (export \"child\" (instance (type $inner))))) (import \"i\" (instance (type $i))))\n",
    source_id="instance-nested-instance-fresh.wat",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-nested-component-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x3f\x7f\x00\x42\x02\x01\x41\x02\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-nested-component-capture.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (type $inner (component (alias outer 2 $r (type $r)) (export \"r\" (type (eq $r))))) (export \"child\" (component (type $inner))))) (import \"i\" (instance (type $i))))\n",
    source_id="instance-nested-component-capture.wat",
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
test "imported resource capture instance-nested-component-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x3f\x7f\x00\x42\x02\x01\x41\x01\x04\x00\x01\x72\x03\x01\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-nested-component-fresh.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "component",
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (type $inner (component (export \"r\" (type (sub resource))))) (export \"child\" (component (type $inner))))) (import \"i\" (instance (type $i))))\n",
    source_id="instance-nested-component-fresh.wat",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "component",
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x02\x3f\x7f\x00\x41\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-empty.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component )) (import \"allowed\" (component (type $i))))\n",
    source_id="component-empty.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-unused-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x02\x3f\x7f\x00\x41\x01\x02\x03\x02\x01\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-unused-alias.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (alias outer 1 $r (type $r)))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-unused-alias.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x02\x3f\x7f\x00\x41\x01\x04\x00\x01\x72\x03\x01\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-fresh.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "1", "r",
    "type", "resource", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (export \"r\" (type (sub resource))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-fresh.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "1", "r",
    "type", "resource", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
test "imported resource capture component-fresh-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x02\x3f\x7f\x00\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-fresh-own.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (export \"r\" (type (sub resource))) (type $f (func (param \"x\" (own 0)))) (export \"f\" (func (type $f))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-fresh-own.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-imported-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0f\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x02\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x16\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-imported-type.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $imported (sub resource))) (type $i (component (alias outer 1 $imported (type $r)) (export \"r\" (type (eq $r))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-imported-type.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-imported-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x41\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x02\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x16\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-imported-own.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $imported (sub resource))) (type $i (component (alias outer 1 $imported (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (own 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-imported-own.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-imported-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x41\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x02\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x16\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-imported-borrow.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $imported (sub resource))) (type $i (component (alias outer 1 $imported (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (borrow 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-imported-borrow.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-nested-instance-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x3f\x7f\x00\x41\x02\x01\x42\x02\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-nested-instance-capture.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (type $inner (instance (alias outer 2 $r (type $r)) (export \"r\" (type (eq $r))))) (export \"child\" (instance (type $inner))))) (import \"i\" (component (type $i))))\n",
    source_id="component-nested-instance-capture.wat",
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
test "imported resource capture component-nested-instance-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x3f\x7f\x00\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-nested-instance-fresh.wasm",
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
    "world", "", "0", "1", "i", "component", "world", "", "0", "0", "1", "child",
    "instance", "interface", "", "0", "1", "r", "type", "resource", "0", "0", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (type $inner (instance (export \"r\" (type (sub resource))))) (export \"child\" (instance (type $inner))))) (import \"i\" (component (type $i))))\n",
    source_id="component-nested-instance-fresh.wat",
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
    "world", "", "0", "1", "i", "component", "world", "", "0", "0", "1", "child",
    "instance", "interface", "", "0", "1", "r", "type", "resource", "0", "0", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-nested-component-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x02\x3f\x7f\x00\x41\x02\x01\x41\x02\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x0a\x06\x01\x00\x01\x69\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-nested-component-capture.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (type $inner (component (alias outer 2 $r (type $r)) (export \"r\" (type (eq $r))))) (export \"child\" (component (type $inner))))) (import \"i\" (component (type $i))))\n",
    source_id="component-nested-component-capture.wat",
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
test "imported resource capture component-nested-component-fresh" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x02\x3f\x7f\x00\x41\x02\x01\x41\x01\x04\x00\x01\x72\x03\x01\x04\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x0a\x06\x01\x00\x01\x69\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-nested-component-fresh.wasm",
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
    "world", "", "0", "1", "i", "component", "world", "", "0", "0", "1", "child",
    "component", "world", "", "0", "0", "1", "r", "type", "resource", "0", "0", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (type $inner (component (export \"r\" (type (sub resource))))) (export \"child\" (component (type $inner))))) (import \"i\" (component (type $i))))\n",
    source_id="component-nested-component-fresh.wat",
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
    "world", "", "0", "1", "i", "component", "world", "", "0", "0", "1", "child",
    "component", "world", "", "0", "0", "1", "r", "type", "resource", "0", "0", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-shadowed-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x02\x3f\x7f\x00\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-shadowed-resource.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (export \"r\" (type $r (sub resource))) (type $f (func (param \"x\" (own 0)))) (export \"f\" (func (type $f))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-shadowed-resource.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-shadowed-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x02\x3f\x7f\x00\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-shadowed-function.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (type $r (func)) (export \"f\" (func (type $r))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-shadowed-function.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-unused-nested-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x02\x3f\x7f\x00\x42\x01\x01\x42\x02\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-unused-nested-capture.wasm",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (type (instance (alias outer 2 $r (type $r)) (export \"r\" (type (eq $r))))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-unused-nested-capture.wat",
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
    "world", "", "0", "1", "allowed", "instance", "interface", "", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-same-name-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x02\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x01\x72\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-same-name-own.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $r (sub resource))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (own 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-same-name-own.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
test "imported resource capture instance-same-name-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x05\x02\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x01\x72\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-same-name-borrow.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0", "0",
    "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $r (sub resource))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (borrow 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (instance (type $i))))\n",
    source_id="instance-same-name-borrow.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false",
    "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0", "0",
    "definitions", "0",
  ])
}

///|
test "imported resource capture component-shadowed-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x02\x3f\x7f\x00\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-shadowed-resource.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (export \"r\" (type $r (sub resource))) (type $f (func (param \"x\" (own 0)))) (export \"f\" (func (type $f))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-shadowed-resource.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-shadowed-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x02\x3f\x7f\x00\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-shadowed-function.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "1", "f",
    "func", "function", "false", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (type $r (func)) (export \"f\" (func (type $r))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-shadowed-function.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "1", "f",
    "func", "function", "false", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-unused-nested-capture" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x02\x3f\x7f\x00\x41\x01\x01\x42\x02\x02\x03\x02\x02\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-unused-nested-capture.wasm",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (type (instance (alias outer 2 $r (type $r)) (export \"r\" (type (eq $r))))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-unused-nested-capture.wat",
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
    "world", "", "0", "1", "allowed", "component", "world", "", "0", "0", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-same-name-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x41\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x02\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x01\x72\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-same-name-own.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $r (sub resource))) (type $i (component (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (own 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-same-name-own.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
test "imported resource capture component-same-name-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x41\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0c\x01\x00\x07\x61\x6c\x6c\x6f\x77\x65\x64\x04\x02\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x05\x6c\x6f\x63\x61\x6c\x01\x01\x72\x02\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-same-name-borrow.wasm",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $local (resource (rep i32))) (import \"r\" (type $r (sub resource))) (type $i (component (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (borrow 1)))) (export \"f\" (func (type $f))))) (import \"allowed\" (component (type $i))))\n",
    source_id="component-same-name-borrow.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "allowed", "component",
    "world", "", "0", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "borrow", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
test "imported resource capture instance-export-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x02\x3f\x7f\x00\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-export-type.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))))) (import \"captured\" (instance (type $i))))",
    source_id="instance-export-type.wat",
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
test "imported resource capture instance-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x02\x3f\x7f\x00\x42\x05\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-own.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (own 1)))) (export \"f\" (func (type $f))))) (import \"captured\" (instance (type $i))))",
    source_id="instance-own.wat",
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
test "imported resource capture instance-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x02\x3f\x7f\x00\x42\x05\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-borrow.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (borrow 1)))) (export \"f\" (func (type $f))))) (import \"captured\" (instance (type $i))))",
    source_id="instance-borrow.wat",
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
test "imported resource capture component-import-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x02\x3f\x7f\x00\x41\x02\x02\x03\x02\x01\x00\x03\x00\x01\x72\x03\x00\x00\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-import-type.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (alias outer 1 $r (type $r)) (import \"r\" (type (eq $r))))) (import \"captured\" (component (type $i))))",
    source_id="component-import-type.wat",
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
test "imported resource capture component-export-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x02\x3f\x7f\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-export-type.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))))) (import \"captured\" (component (type $i))))",
    source_id="component-export-type.wat",
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
test "imported resource capture component-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x02\x3f\x7f\x00\x41\x05\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-own.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (own 1)))) (export \"f\" (func (type $f))))) (import \"captured\" (component (type $i))))",
    source_id="component-own.wat",
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
test "imported resource capture component-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x02\x3f\x7f\x00\x41\x05\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x0d\x01\x00\x08\x63\x61\x70\x74\x75\x72\x65\x64\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="component-borrow.wasm",
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
  assert_true(
    result.unwrap_err()[0]
    .render()
    .contains("local resource type found in imports"),
  )
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (component (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $f (func (param \"x\" (borrow 1)))) (export \"f\" (func (type $f))))) (import \"captured\" (component (type $i))))",
    source_id="component-borrow.wat",
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
