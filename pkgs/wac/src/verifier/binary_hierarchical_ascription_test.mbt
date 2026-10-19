///|
test "hierarchical function ascription scalar-1-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0f\x02\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-1-equal.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (alias export 1 \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="scalar-1-equal.wat",
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
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription scalar-1-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0f\x02\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x07\x08\x01\x40\x01\x01\x78\x77\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-1-mismatch.wasm",
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
    "(component (type $i (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (alias export 1 \"f\" (func $f)) (type $f (func (param \"x\" u64))) (export \"out\" (func $f) (func (type $f))))",
    source_id="scalar-1-mismatch.wat",
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
test "hierarchical function ascription scalar-2-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x18\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-2-equal.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "child", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $c (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (alias export 1 \"child\" (instance)) (alias export 2 \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="scalar-2-equal.wat",
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
    "interface", "", "0", "1", "child", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32",
    "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription scalar-2-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x18\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x07\x08\x01\x40\x01\x01\x78\x77\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-2-mismatch.wasm",
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
    "(component (type $i (instance (type $c (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (alias export 1 \"child\" (instance)) (alias export 2 \"f\" (func $f)) (type $f (func (param \"x\" u64))) (export \"out\" (func $f) (func (type $f))))",
    source_id="scalar-2-mismatch.wat",
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
test "hierarchical function ascription scalar-4-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x45\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x2a\x05\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x05\x00\x02\x05\x63\x68\x69\x6c\x64\x05\x00\x03\x05\x63\x68\x69\x6c\x64\x01\x00\x04\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-4-equal.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "child", "instance", "interface", "", "0", "1", "child",
    "instance", "interface", "", "0", "1", "child", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $c (instance (type $c (instance (type $c (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (alias export 1 \"child\" (instance)) (alias export 2 \"child\" (instance)) (alias export 3 \"child\" (instance)) (alias export 4 \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="scalar-4-equal.wat",
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
    "interface", "", "0", "1", "child", "instance", "interface", "", "0", "1", "child",
    "instance", "interface", "", "0", "1", "child", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription scalar-4-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x45\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x2a\x05\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x05\x00\x02\x05\x63\x68\x69\x6c\x64\x05\x00\x03\x05\x63\x68\x69\x6c\x64\x01\x00\x04\x01\x66\x07\x08\x01\x40\x01\x01\x78\x77\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-4-mismatch.wasm",
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
    "(component (type $i (instance (type $c (instance (type $c (instance (type $c (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (alias export 1 \"child\" (instance)) (alias export 2 \"child\" (instance)) (alias export 3 \"child\" (instance)) (alias export 4 \"f\" (func $f)) (type $f (func (param \"x\" u64))) (export \"out\" (func $f) (func (type $f))))",
    source_id="scalar-4-mismatch.wat",
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
test "hierarchical function ascription resource-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x42\x02\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x0b\x02\x00\x01\x69\x05\x00\x00\x01\x6a\x05\x00\x06\x1d\x04\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x03\x00\x02\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x69\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x10\x05\x04\x00\x01\x69\x01\x01\x6a\x02\x02\x69\x63\x03\x02\x6a\x63"
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
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "j", "instance", "interface", "", "0",
    "1", "child", "instance", "interface", "", "0", "2", "r", "type", "resource",
    "1", "f", "func", "function", "false", "1", "x", "own", "1", "none", "1", "out",
    "func", "function", "false", "1", "x", "own", "0", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "own", "0", "none",
    "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $c (instance (export \"r\" (type $r (sub resource))) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (import \"j\" (instance $j (type $i))) (alias export $i \"child\" (instance $ic)) (alias export $j \"child\" (instance $jc)) (alias export $ic \"f\" (func $f)) (alias export $ic \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
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
    "world", "", "0", "2", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "j", "instance", "interface", "", "0",
    "1", "child", "instance", "interface", "", "0", "2", "r", "type", "resource",
    "1", "f", "func", "function", "false", "1", "x", "own", "1", "none", "1", "out",
    "func", "function", "false", "1", "x", "own", "0", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "own", "0", "none",
    "definitions", "0",
  ])
}

///|
test "hierarchical function ascription resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x42\x02\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x0b\x02\x00\x01\x69\x05\x00\x00\x01\x6a\x05\x00\x06\x1d\x04\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x03\x00\x03\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x69\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x10\x05\x04\x00\x01\x69\x01\x01\x6a\x02\x02\x69\x63\x03\x02\x6a\x63"
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
    "(component (type $i (instance (type $c (instance (export \"r\" (type $r (sub resource))) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (import \"j\" (instance $j (type $i))) (alias export $i \"child\" (instance $ic)) (alias export $j \"child\" (instance $jc)) (alias export $ic \"f\" (func $f)) (alias export $jc \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
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
test "hierarchical function ascription outer-resource-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2c\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x42\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x01\x0a\x0b\x02\x00\x01\x70\x05\x00\x00\x01\x71\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x03\x00\x00\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x70\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x0b\x05\x03\x00\x01\x70\x01\x01\x71\x02\x01\x63"
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "child", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "own", "0", "none", "q", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "1", "child", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "1", "x", "own", "1", "none",
    "1", "out", "func", "function", "false", "1", "x", "own", "0", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "own",
    "0", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (export \"r\" (type $r (sub resource))) (type $c (instance (alias outer 1 $r (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (import \"q\" (instance $q (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $p \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "child", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "own", "0", "none", "q", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "1", "child", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "1", "x", "own", "1", "none",
    "1", "out", "func", "function", "false", "1", "x", "own", "0", "none", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "own",
    "0", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription sibling-resource-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x32\x01\x42\x03\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x66\x69\x72\x73\x74\x05\x00\x04\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x1e\x04\x05\x00\x00\x05\x66\x69\x72\x73\x74\x05\x00\x00\x06\x73\x65\x63\x6f\x6e\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x70\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x0b\x05\x03\x00\x01\x70\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="sibling-resource-equal.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "2", "first", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "second", "instance", "interface", "",
    "0", "2", "r", "type", "resource", "1", "f", "func", "function", "false", "1",
    "x", "own", "1", "none", "1", "out", "func", "function", "false", "1", "x", "own",
    "0", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "own", "0", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (export \"r\" (type $r (sub resource))) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (export \"first\" (instance (type $c))) (export \"second\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"first\" (instance $a)) (alias export $p \"second\" (instance $b)) (alias export $a \"f\" (func $f)) (alias export $a \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="sibling-resource-equal.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "2", "first", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "second", "instance", "interface", "",
    "0", "2", "r", "type", "resource", "1", "f", "func", "function", "false", "1",
    "x", "own", "1", "none", "1", "out", "func", "function", "false", "1", "x", "own",
    "0", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "own", "0", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription outer-resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2c\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x42\x04\x02\x03\x02\x01\x00\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x01\x0a\x0b\x02\x00\x01\x70\x05\x00\x00\x01\x71\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x03\x00\x01\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x70\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x0b\x05\x03\x00\x01\x70\x01\x01\x71\x02\x01\x63"
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
    "(component (type $p (instance (export \"r\" (type $r (sub resource))) (type $c (instance (alias outer 1 $r (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (import \"q\" (instance $q (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $q \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
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
test "hierarchical function ascription sibling-resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x32\x01\x42\x03\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x66\x69\x72\x73\x74\x05\x00\x04\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x1e\x04\x05\x00\x00\x05\x66\x69\x72\x73\x74\x05\x00\x00\x06\x73\x65\x63\x6f\x6e\x64\x01\x00\x01\x01\x66\x03\x00\x02\x01\x72\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x04\x00\x01\x70\x01\x01\x72\x02\x01\x68\x03\x01\x66\x01\x0b\x05\x03\x00\x01\x70\x01\x01\x61\x02\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="sibling-resource-mismatch.wasm",
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
    "(component (type $p (instance (type $c (instance (export \"r\" (type $r (sub resource))) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"f\" (func (type $f))))) (export \"first\" (instance (type $c))) (export \"second\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"first\" (instance $a)) (alias export $p \"second\" (instance $b)) (alias export $a \"f\" (func $f)) (alias export $b \"r\" (type $r)) (type $h (own $r)) (type $f (func (param \"x\" $h))) (export \"out\" (func $f) (func (type $f))))",
    source_id="sibling-resource-mismatch.wat",
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
test "hierarchical function ascription parent-reexport" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x05\x00\x00\x06\x0f\x02\x05\x00\x01\x05\x63\x68\x69\x6c\x64\x01\x00\x02\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="parent-reexport.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "again", "instance", "interface", "", "0", "1", "child",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "instance", "interface", "", "0", "2", "again", "instance", "interface",
    "", "0", "1", "child", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (export \"again\" (instance 0)) (alias export 1 \"child\" (instance)) (alias export 2 \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="parent-reexport.wat",
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
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "again", "instance", "interface", "", "0", "1", "child",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "instance", "interface", "", "0", "2", "again", "instance", "interface",
    "", "0", "1", "child", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription child-reexport" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x02\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0a\x01\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x05\x01\x00\x06\x06\x01\x01\x00\x02\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x69\x01\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="child-reexport.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "again", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "out", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "2", "again", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $c (instance (type $f (func (param \"x\" u32))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"i\" (instance $i (type $i))) (alias export 0 \"child\" (instance)) (export \"again\" (instance 1)) (alias export 2 \"f\" (func $f)) (type $f (func (param \"x\" u32))) (export \"out\" (func $f) (func (type $f))))",
    source_id="child-reexport.wat",
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
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "again", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "out", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "2", "again", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription outer-value-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x03\x01\x70\x79\x01\x42\x04\x01\x70\x77\x02\x03\x02\x01\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x01\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x0f\x02\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x07\x0a\x02\x70\x79\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x70\x01\x01\x6e\x02\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $n (list u32)) (type $c (instance (type $collision (list u64)) (alias outer 1 $n (type $n)) (type $f (func (param \"x\" $n))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (type $n (list u32)) (type $f (func (param \"x\" $n))) (export \"out\" (func $f) (func (type $f))))",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription outer-value-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x03\x01\x70\x79\x01\x42\x04\x01\x70\x77\x02\x03\x02\x01\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x01\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x0f\x02\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x07\x0a\x02\x70\x77\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x70\x01\x01\x6e\x02\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
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
    "(component (type $p (instance (type $n (list u32)) (type $c (instance (type $collision (list u64)) (alias outer 1 $n (type $n)) (type $f (func (param \"x\" $n))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (type $n (list u64)) (type $f (func (param \"x\" $n))) (export \"out\" (func $f) (func (type $f))))",
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
test "hierarchical function ascription exported-type-list" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x28\x01\x42\x02\x01\x42\x04\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x70\x01\x01\x74\x02\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="exported-type-list.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (list u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $f (func (param \"x\" $t))) (export \"out\" (func $f) (func (type $f))))",
    source_id="exported-type-list.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription exported-type-map" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x01\x42\x04\x01\x63\x73\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x70\x01\x01\x74\x02\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="exported-type-map.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x", "map",
    "scalar", "string", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (map string u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $f (func (param \"x\" $t))) (export \"out\" (func $f) (func (type $f))))",
    source_id="exported-type-map.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x", "map",
    "scalar", "string", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription exported-type-future" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x01\x42\x04\x01\x65\x01\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x70\x01\x01\x74\x02\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="exported-type-future.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "future", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "1", "out", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (future u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $f (func (param \"x\" $t))) (export \"out\" (func $f) (func (type $f))))",
    source_id="exported-type-future.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "future", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "1", "out", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription exported-type-scalar" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x42\x02\x01\x42\x04\x01\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x70\x01\x01\x74\x02\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="exported-type-scalar.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition u32) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $f (func (param \"x\" $t))) (export \"out\" (func $f) (func (type $f))))",
    source_id="exported-type-scalar.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription type-alias-chain-list" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x28\x01\x42\x02\x01\x42\x04\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x18\x04\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x03\x02\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x70\x01\x01\x74\x02\x05\x61\x6c\x69\x61\x73\x03\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="type-alias-chain-list.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (list u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (alias outer 0 $t (type $alias)) (type $f (func (param \"x\" $alias))) (export \"out\" (func $f) (func (type $f))))",
    source_id="type-alias-chain-list.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "1", "out", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "out", "func", "function", "false", "1", "x", "list", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription transitive-capture-list" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x28\x01\x42\x02\x01\x42\x04\x01\x70\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x16\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x67\x01\x01\x0a\x09\x01\x00\x04\x6e\x65\x78\x74\x05\x02\x06\x06\x01\x01\x00\x02\x01\x67\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x1a\x02\x00\x08\x6e\x65\x78\x74\x2d\x6f\x75\x74\x01\x01\x01\x01\x03\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x3c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x01\x02\x00\x01\x66\x01\x01\x67\x01\x11\x03\x04\x00\x01\x70\x01\x01\x74\x02\x04\x6e\x65\x78\x74\x03\x01\x66\x01\x0e\x05\x03\x00\x01\x70\x01\x01\x63\x02\x04\x6e\x65\x78\x74"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="transitive-capture-list.wasm",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "next", "instance",
    "interface", "", "0", "1", "g", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "2", "next-out", "func", "function", "false", "1", "x",
    "list", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x",
    "list", "scalar", "u32", "none", "instance", "interface", "", "0", "2", "next-out",
    "func", "function", "false", "1", "x", "list", "scalar", "u32", "none", "out",
    "func", "function", "false", "1", "x", "list", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (list u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $next (instance (alias outer 1 $t (type $local)) (type $function (func (param \"x\" $local))) (export \"g\" (func (type $function))))) (import \"next\" (instance $next (type $next))) (alias export $next \"g\" (func $g)) (type $f (func (param \"x\" $t))) (export \"next-out\" (func $g) (func (type $f))) (export \"out\" (func $f) (func (type $f))))",
    source_id="transitive-capture-list.wat",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "scalar", "u32", "none", "next", "instance",
    "interface", "", "0", "1", "g", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "2", "next-out", "func", "function", "false", "1", "x",
    "list", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x",
    "list", "scalar", "u32", "none", "instance", "interface", "", "0", "2", "next-out",
    "func", "function", "false", "1", "x", "list", "scalar", "u32", "none", "out",
    "func", "function", "false", "1", "x", "list", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription type-alias-chain-map" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x01\x42\x04\x01\x63\x73\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x18\x04\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x03\x02\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x70\x01\x01\x74\x02\x05\x61\x6c\x69\x61\x73\x03\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="type-alias-chain-map.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x", "map",
    "scalar", "string", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (map string u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (alias outer 0 $t (type $alias)) (type $f (func (param \"x\" $alias))) (export \"out\" (func $f) (func (type $f))))",
    source_id="type-alias-chain-map.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "1", "out", "func", "function", "false", "1", "x", "map",
    "scalar", "string", "scalar", "u32", "none", "instance", "interface", "", "0",
    "1", "out", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription transitive-capture-map" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x01\x42\x04\x01\x63\x73\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x16\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x67\x01\x01\x0a\x09\x01\x00\x04\x6e\x65\x78\x74\x05\x02\x06\x06\x01\x01\x00\x02\x01\x67\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x1a\x02\x00\x08\x6e\x65\x78\x74\x2d\x6f\x75\x74\x01\x01\x01\x01\x03\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x3c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x01\x02\x00\x01\x66\x01\x01\x67\x01\x11\x03\x04\x00\x01\x70\x01\x01\x74\x02\x04\x6e\x65\x78\x74\x03\x01\x66\x01\x0e\x05\x03\x00\x01\x70\x01\x01\x63\x02\x04\x6e\x65\x78\x74"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="transitive-capture-map.wasm",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "next", "instance", "interface", "", "0", "1", "g",
    "func", "function", "false", "1", "x", "map", "scalar", "string", "scalar", "u32",
    "none", "2", "next-out", "func", "function", "false", "1", "x", "map", "scalar",
    "string", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none", "instance", "interface",
    "", "0", "2", "next-out", "func", "function", "false", "1", "x", "map", "scalar",
    "string", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (map string u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $next (instance (alias outer 1 $t (type $local)) (type $function (func (param \"x\" $local))) (export \"g\" (func (type $function))))) (import \"next\" (instance $next (type $next))) (alias export $next \"g\" (func $g)) (type $f (func (param \"x\" $t))) (export \"next-out\" (func $g) (func (type $f))) (export \"out\" (func $f) (func (type $f))))",
    source_id="transitive-capture-map.wat",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "map", "scalar", "string", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "map", "scalar", "string",
    "scalar", "u32", "none", "next", "instance", "interface", "", "0", "1", "g",
    "func", "function", "false", "1", "x", "map", "scalar", "string", "scalar", "u32",
    "none", "2", "next-out", "func", "function", "false", "1", "x", "map", "scalar",
    "string", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none", "instance", "interface",
    "", "0", "2", "next-out", "func", "function", "false", "1", "x", "map", "scalar",
    "string", "scalar", "u32", "none", "out", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription type-alias-chain-future" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x01\x42\x04\x01\x65\x01\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x18\x04\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x03\x02\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x70\x01\x01\x74\x02\x05\x61\x6c\x69\x61\x73\x03\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="type-alias-chain-future.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "future", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "1", "out", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (future u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (alias outer 0 $t (type $alias)) (type $f (func (param \"x\" $alias))) (export \"out\" (func $f) (func (type $f))))",
    source_id="type-alias-chain-future.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "future", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "1", "out", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "instance", "interface", "", "0", "1", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription transitive-capture-future" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x01\x42\x04\x01\x65\x01\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x16\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x67\x01\x01\x0a\x09\x01\x00\x04\x6e\x65\x78\x74\x05\x02\x06\x06\x01\x01\x00\x02\x01\x67\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x1a\x02\x00\x08\x6e\x65\x78\x74\x2d\x6f\x75\x74\x01\x01\x01\x01\x03\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x3c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x01\x02\x00\x01\x66\x01\x01\x67\x01\x11\x03\x04\x00\x01\x70\x01\x01\x74\x02\x04\x6e\x65\x78\x74\x03\x01\x66\x01\x0e\x05\x03\x00\x01\x70\x01\x01\x63\x02\x04\x6e\x65\x78\x74"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="transitive-capture-future.wasm",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "future", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "next", "instance", "interface", "", "0", "1", "g", "func", "function", "false",
    "1", "x", "future", "some", "scalar", "u32", "none", "2", "next-out", "func",
    "function", "false", "1", "x", "future", "some", "scalar", "u32", "none", "out",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "next-out", "func", "function", "false",
    "1", "x", "future", "some", "scalar", "u32", "none", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition (future u32)) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $next (instance (alias outer 1 $t (type $local)) (type $function (func (param \"x\" $local))) (export \"g\" (func (type $function))))) (import \"next\" (instance $next (type $next))) (alias export $next \"g\" (func $g)) (type $f (func (param \"x\" $t))) (export \"next-out\" (func $g) (func (type $f))) (export \"out\" (func $f) (func (type $f))))",
    source_id="transitive-capture-future.wat",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "future", "some", "scalar", "u32", "f",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "next", "instance", "interface", "", "0", "1", "g", "func", "function", "false",
    "1", "x", "future", "some", "scalar", "u32", "none", "2", "next-out", "func",
    "function", "false", "1", "x", "future", "some", "scalar", "u32", "none", "out",
    "func", "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "next-out", "func", "function", "false",
    "1", "x", "future", "some", "scalar", "u32", "none", "out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription type-alias-chain-scalar" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x42\x02\x01\x42\x04\x01\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x18\x04\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x03\x02\x00\x01\x07\x08\x01\x40\x01\x01\x78\x02\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x70\x01\x01\x74\x02\x05\x61\x6c\x69\x61\x73\x03\x01\x66\x01\x08\x05\x02\x00\x01\x70\x01\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="type-alias-chain-scalar.wasm",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition u32) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (alias outer 0 $t (type $alias)) (type $f (func (param \"x\" $alias))) (export \"out\" (func $f) (func (type $f))))",
    source_id="type-alias-chain-scalar.wat",
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
    "world", "", "0", "1", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "1", "out", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ])
}

///|
test "hierarchical function ascription transitive-capture-scalar" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x42\x02\x01\x42\x04\x01\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x05\x63\x68\x69\x6c\x64\x05\x00\x0a\x06\x01\x00\x01\x70\x05\x00\x06\x14\x03\x05\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x01\x01\x66\x03\x00\x01\x01\x74\x07\x16\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x67\x01\x01\x0a\x09\x01\x00\x04\x6e\x65\x78\x74\x05\x02\x06\x06\x01\x01\x00\x02\x01\x67\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x1a\x02\x00\x08\x6e\x65\x78\x74\x2d\x6f\x75\x74\x01\x01\x01\x01\x03\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x03\x00\x3c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x01\x02\x00\x01\x66\x01\x01\x67\x01\x11\x03\x04\x00\x01\x70\x01\x01\x74\x02\x04\x6e\x65\x78\x74\x03\x01\x66\x01\x0e\x05\x03\x00\x01\x70\x01\x01\x63\x02\x04\x6e\x65\x78\x74"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="transitive-capture-scalar.wasm",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "next", "instance", "interface",
    "", "0", "1", "g", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "2", "next-out", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "2", "next-out", "func", "function", "false", "1", "x",
    "scalar", "u32", "none", "out", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $p (instance (type $c (instance (type $definition u32) (export \"t\" (type $t (eq $definition))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"child\" (instance (type $c))))) (import \"p\" (instance $p (type $p))) (alias export $p \"child\" (instance $c)) (alias export $c \"f\" (func $f)) (alias export $c \"t\" (type $t)) (type $next (instance (alias outer 1 $t (type $local)) (type $function (func (param \"x\" $local))) (export \"g\" (func (type $function))))) (import \"next\" (instance $next (type $next))) (alias export $next \"g\" (func $g)) (type $f (func (param \"x\" $t))) (export \"next-out\" (func $g) (func (type $f))) (export \"out\" (func $f) (func (type $f))))",
    source_id="transitive-capture-scalar.wat",
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
    "world", "", "0", "2", "p", "instance", "interface", "", "0", "1", "child", "instance",
    "interface", "", "0", "2", "t", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "next", "instance", "interface",
    "", "0", "1", "g", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "2", "next-out", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "2", "next-out", "func", "function", "false", "1", "x",
    "scalar", "u32", "none", "out", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "definitions", "0",
  ])
}

///|
test "hierarchical function ascription root-composite-type-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x28\x01\x42\x06\x01\x70\x79\x04\x00\x04\x6c\x65\x61\x66\x03\x00\x00\x01\x70\x01\x04\x00\x01\x74\x03\x00\x02\x01\x40\x01\x01\x78\x03\x01\x00\x04\x00\x01\x66\x01\x04\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0b\x02\x01\x00\x00\x01\x66\x03\x00\x00\x01\x74\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x0b\x01\x00\x03\x6f\x75\x74\x01\x00\x01\x01\x02\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x69\x01\x01\x74\x02\x01\x66\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="root-composite-type-alias.wasm",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "3", "leaf", "type",
    "list", "scalar", "u32", "t", "type", "list", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "list", "scalar", "u32", "none", "1",
    "out", "func", "function", "false", "1", "x", "list", "list", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "list", "list", "scalar", "u32", "none", "definitions", "0",
  ])
  assert_eq(model.bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $leaf (list u32)) (export \"leaf\" (type $named-leaf (eq $leaf))) (type $t (list $named-leaf)) (export \"t\" (type $named-t (eq $t))) (type $f (func (param \"x\" $named-t))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (alias export $i \"t\" (type $t)) (type $f (func (param \"x\" $t))) (export \"out\" (func $f) (func (type $f))))",
    source_id="root-composite-type-alias.wat",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "3", "leaf", "type",
    "list", "scalar", "u32", "t", "type", "list", "list", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "list", "list", "scalar", "u32", "none", "1",
    "out", "func", "function", "false", "1", "x", "list", "list", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "out", "func", "function", "false",
    "1", "x", "list", "list", "scalar", "u32", "none", "definitions", "0",
  ])
}
