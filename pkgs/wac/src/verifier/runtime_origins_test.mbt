///|
test "runtime named type origins anonymous-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-export.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="anonymous-export.wat",
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
test "runtime named type origins named-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-export.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type 1)))) (export \"i\" (instance $i)))",
    source_id="named-export.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "2", "t", "type", "record", "1", "x", "scalar", "u32", "i", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "2", "t", "type", "record", "1", "x",
    "scalar", "u32", "i", "instance", "interface", "", "0", "2", "t", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins anonymous-private" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-private.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) )",
    source_id="anonymous-private.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "1", "t", "type", "record", "1", "x", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "record", "1", "x", "scalar", "u32",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins named-private" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-private.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type 1)))) )",
    source_id="named-private.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "1", "t", "type", "record", "1", "x", "scalar", "u32", "instance",
    "interface", "", "0", "1", "t", "type", "record", "1", "x", "scalar", "u32",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins anonymous-unused" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x18\x01\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-unused.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) )) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="anonymous-unused.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "0", "2", "t", "type", "record", "1", "x",
    "scalar", "u32", "i", "instance", "interface", "", "0", "0", "instance", "interface",
    "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "i", "instance",
    "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins named-import" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-import.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (import \"t\" (type $named (eq $t))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $named)))) (export \"i\" (instance $i)))",
    source_id="named-import.wat",
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
    "world", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "c",
    "component", "world", "", "0", "1", "t", "type", "record", "1", "x", "scalar",
    "u32", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "1", "i", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "i", "instance", "interface",
    "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins anonymous-under-named-import" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-under-named-import.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (import \"t\" (type $named (eq $t))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="anonymous-under-named-import.wat",
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
test "runtime named type origins named-alias-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-alias-export.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export $named \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $named)))) (export \"i\" (instance $i)))",
    source_id="named-alias-export.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "2", "t", "type", "record", "1", "x", "scalar", "u32", "i", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "2", "t", "type", "record", "1", "x",
    "scalar", "u32", "i", "instance", "interface", "", "0", "2", "t", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins instance-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x01\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x74\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x01\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x03\x03\x00\x03\x61\x70\x69\x01\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x0a\x05\x02\x00\x03\x61\x70\x69\x01\x01\x69",
    source_id="instance-alias.wasm",
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
    "(component (type $api (instance (type $t (record (field \"x\" u32))) (export \"t\" (type (eq $t))))) (import \"api\" (instance $api (type $api))) (alias export $api \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="instance-alias.wat",
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
    "world", "", "0", "2", "api", "instance", "interface", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "c", "component", "world", "", "0", "1",
    "t", "type", "record", "1", "x", "scalar", "u32", "2", "t", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "1", "i", "instance", "interface", "", "1",
    "t", "t", "", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "i", "instance", "interface", "", "1", "t", "t", "",
    "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins anonymous-export-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-export-function.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="anonymous-export-function.wat",
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
test "runtime named type origins named-export-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-export-function.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type 1)))) (alias export $i \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="named-export-function.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins instance-alias-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x01\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x74\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x06\x06\x01\x01\x00\x01\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0d\x03\x03\x00\x03\x61\x70\x69\x01\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x0a\x05\x02\x00\x03\x61\x70\x69\x01\x01\x69",
    source_id="instance-alias-function.wasm",
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
    "(component (type $api (instance (type $t (record (field \"x\" u32))) (export \"t\" (type (eq $t))))) (import \"api\" (instance $api (type $api))) (alias export $api \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="instance-alias-function.wat",
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
    "world", "", "0", "2", "api", "instance", "interface", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "c", "component", "world", "", "0", "1",
    "t", "type", "record", "1", "x", "scalar", "u32", "2", "t", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "1", "f", "func", "function", "false", "1",
    "x", "record", "1", "x", "scalar", "u32", "none", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins imported-function-no-type-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x42\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69",
    source_id="imported-function-no-type-alias.wasm",
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
    "(component (type $i (instance (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"i\" (instance $i (type $i))) (alias export $i \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="imported-function-no-type-alias.wat",
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
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "1", "f", "func", "function", "false",
    "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "1", "x", "record", "1", "x",
    "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins fresh-instance-hidden-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x01\x00\x01\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="fresh-instance-hidden-function.wasm",
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
    "(component (type $c (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (instance $j (instantiate $c)) (export \"i\" (instance $i)) (alias export $j \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="fresh-instance-hidden-function.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "2", "i", "instance", "interface",
    "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "f",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "i", "instance", "interface", "", "0",
    "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins distinct-template-hidden-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x64\x04\x01\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x01\x00\x01\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x63\x01\x01\x64\x01\x08\x04\x02\x00\x01\x63\x01\x01\x64\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="distinct-template-hidden-function.wasm",
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
    "(component (type $c (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (type $d (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"d\" (component $d (type $d))) (instance $j (instantiate $d)) (export \"i\" (instance $i)) (alias export $j \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="distinct-template-hidden-function.wat",
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
test "runtime named type origins same-instance-visible-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="same-instance-visible-function.wasm",
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
    "(component (type $c (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (instance $j (instantiate $c)) (export \"i\" (instance $i)) (alias export $i \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="same-instance-visible-function.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "2", "i", "instance", "interface",
    "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "f",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "i", "instance", "interface", "", "0",
    "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins second-instance-visible-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x69\x05\x00\x00\x00\x01\x6a\x05\x01\x00\x06\x06\x01\x01\x00\x01\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="second-instance-visible-function.wasm",
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
    "(component (type $c (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (instance $j (instantiate $c)) (export \"i\" (instance $i)) (export \"j\" (instance $j)) (alias export $j \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="second-instance-visible-function.wat",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "runtime named type origins named-export-nested" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x36\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x66\x01\x01\x04\x00\x03\x6f\x75\x74\x05\x03\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-export-nested.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (type $out (instance (alias outer 1 $it (type $t)) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"out\" (instance (type $out))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type 1)))) (export \"i\" (instance $i)))",
    source_id="named-export-nested.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "1", "out", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "2", "t", "type", "record", "1", "x", "scalar", "u32", "i", "instance",
    "interface", "", "0", "1", "out", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "i", "instance", "interface", "", "0", "1", "out", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "1", "x", "record", "1", "x",
    "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins anonymous-export-nested" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x36\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x66\x01\x01\x04\x00\x03\x6f\x75\x74\x05\x03\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-export-nested.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (type $out (instance (alias outer 1 $it (type $t)) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"out\" (instance (type $out))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="anonymous-export-nested.wat",
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
test "runtime named type origins anonymous-instance-ascribed" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x07\x1d\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x66\x01\x02\x0b\x09\x01\x00\x01\x69\x05\x00\x01\x05\x03\x00\x2c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x03\x03\x00\x01\x74\x02\x01\x63\x03\x03\x6f\x75\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-instance-ascribed.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (type $out (instance (alias outer 1 1 (type $t)) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"i\" (instance $i) (instance (type $out))))",
    source_id="anonymous-instance-ascribed.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "2", "t", "type", "record", "1", "x", "scalar", "u32", "i", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "instance", "interface", "", "0", "2", "t", "type", "record", "1", "x",
    "scalar", "u32", "i", "instance", "interface", "", "0", "2", "t", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins anonymous-function-ascribed" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x09\x01\x00\x01\x66\x01\x00\x01\x01\x03\x00\x32\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0c\x03\x03\x00\x01\x74\x02\x01\x63\x03\x02\x66\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-function-ascribed.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"f\" (func $f)) (type $ft (func (param \"x\" 1))) (export \"f\" (func $f) (func (type $ft))))",
    source_id="anonymous-function-ascribed.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins ascribed-function-reexport" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x13\x02\x00\x01\x66\x01\x00\x01\x01\x03\x00\x05\x61\x67\x61\x69\x6e\x01\x01\x00\x00\x3b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0e\x01\x02\x00\x01\x66\x01\x07\x76\x69\x73\x69\x62\x6c\x65\x01\x0c\x03\x03\x00\x01\x74\x02\x01\x63\x03\x02\x66\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="ascribed-function-reexport.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"f\" (func $f)) (type $ft (func (param \"x\" 1))) (export $visible \"f\" (func $f) (func (type $ft))) (export \"again\" (func $visible)))",
    source_id="ascribed-function-reexport.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "t", "type",
    "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "3", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "again",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "3", "t", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "again", "func", "function", "false", "1", "x", "record", "1",
    "x", "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins same-component-type-imports" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0a\x06\x01\x00\x01\x64\x04\x00\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x01\x00\x01\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x63\x01\x08\x04\x02\x00\x01\x63\x01\x01\x64\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="same-component-type-imports.wasm",
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
    "(component (type $c (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (import \"d\" (component $d (type $c))) (instance $j (instantiate $d)) (export \"i\" (instance $i)) (alias export $j \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="same-component-type-imports.wat",
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
    "world", "", "0", "2", "c", "component", "world", "", "0", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "d", "component", "world", "", "0",
    "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "2", "i", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "instance", "interface", "", "0", "2", "i", "instance", "interface",
    "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "f",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime named type origins same-component-type-imports-later-types" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x01\x41\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x07\x05\x02\x70\x79\x6b\x77\x0a\x06\x01\x00\x01\x64\x04\x00\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x01\x00\x01\x01\x66\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x63\x01\x08\x04\x02\x00\x01\x63\x01\x01\x64\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="same-component-type-imports-later-types.wasm",
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
    "(component (type $c (component (type $t (record (field \"x\" u32))) (export \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (type (list u32)) (type (option u64)) (import \"d\" (component $d (type $c))) (instance $j (instantiate $d)) (export \"i\" (instance $i)) (alias export $j \"f\" (func $f)) (export \"f\" (func $f)))",
    source_id="same-component-type-imports-later-types.wat",
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
    "world", "", "0", "2", "c", "component", "world", "", "0", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "d", "component", "world", "", "0",
    "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "2", "i", "instance",
    "interface", "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
    "none", "f", "func", "function", "false", "1", "x", "record", "1", "x", "scalar",
    "u32", "none", "instance", "interface", "", "0", "2", "i", "instance", "interface",
    "", "0", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none", "f",
    "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}
