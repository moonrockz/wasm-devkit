///|
test "runtime component values export-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="export-instance.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (export \"i\" (instance $i)))",
    source_id="export-instance.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "v", "value",
    "scalar", "u32", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "instance", "interface", "", "0", "1", "i", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values alias-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="alias-value.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="alias-value.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "v", "value",
    "scalar", "u32", "1", "v", "value", "scalar", "u32", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x07\x09\x01\x41\x01\x03\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="argument.wasm",
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
    "(component (import \"v\" (value $v u32)) (type $c (component (import \"v\" (value u32)))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
    source_id="argument.wat",
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
    "world", "", "0", "2", "v", "value", "scalar", "u32", "c", "component", "world",
    "", "0", "1", "v", "value", "scalar", "u32", "0", "1", "i", "instance", "interface",
    "", "0", "0", "instance", "interface", "", "0", "1", "i", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values inline" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x01\x01\x00\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline.wasm",
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
    "(component (import \"v\" (value $v u32)) (instance $i (export \"v\" (value $v))) (export \"i\" (instance $i)))",
    source_id="inline.wat",
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
    "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "i", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "instance", "interface", "", "0",
    "1", "i", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
    "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values argument-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x07\x09\x01\x41\x01\x03\x00\x01\x76\x02\x73\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="argument-wrong.wasm",
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
    "(component (import \"v\" (value $v u32)) (type $c (component (import \"v\" (value string)))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
    source_id="argument-wrong.wat",
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
test "runtime component values argument-twice" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x07\x09\x01\x41\x01\x03\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="argument-twice.wasm",
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
    "(component (import \"v\" (value $v u32)) (type $c (component (import \"v\" (value u32)))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"v\" (value $v)))",
    source_id="argument-twice.wat",
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
test "runtime component values alias-value-unused" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="alias-value-unused.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) )",
    source_id="alias-value-unused.wat",
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
test "runtime component values alias-value-twice" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x11\x02\x00\x01\x76\x02\x00\x00\x00\x05\x61\x67\x61\x69\x6e\x02\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="alias-value-twice.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)) (export \"again\" (value $v)))",
    source_id="alias-value-twice.wat",
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
test "runtime component values alias-value-repeat" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x02\x02\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x02\x02\x00\x01\x76\x02\x05\x6f\x74\x68\x65\x72\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="alias-value-repeat.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)) (alias export $i \"v\" (value $other)) (export \"again\" (value $other)))",
    source_id="alias-value-repeat.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "v", "value",
    "scalar", "u32", "2", "v", "value", "scalar", "u32", "again", "value", "scalar",
    "u32", "instance", "interface", "", "0", "2", "v", "value", "scalar", "u32",
    "again", "value", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values anonymous-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x72\x01\x01\x78\x79\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x08\x03\x02\x00\x01\x74\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-value.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="anonymous-value.wat",
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
test "runtime component values named-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x16\x01\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="named-value.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export $named \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $named)))) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="named-value.wat",
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
    "record", "1", "x", "scalar", "u32", "1", "v", "value", "record", "1", "x", "scalar",
    "u32", "2", "t", "type", "record", "1", "x", "scalar", "u32", "v", "value", "record",
    "1", "x", "scalar", "u32", "instance", "interface", "", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
    "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values anonymous-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x72\x01\x01\x78\x79\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-instance.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="anonymous-instance.wat",
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
test "runtime component values anonymous-private" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x72\x01\x01\x78\x79\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
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
    "(component (type $t (record (field \"x\" u32))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) )",
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
    "record", "1", "x", "scalar", "u32", "1", "v", "value", "record", "1", "x", "scalar",
    "u32", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values resource-substitution" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x07\x18\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x0c\x01\x00\x00\x02\x01\x72\x03\x00\x01\x76\x02\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x09\x01\x00\x03\x6f\x75\x74\x02\x01\x00\x00\x36\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x02\x02\x00\x01\x76\x01\x03\x6f\x75\x74\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="resource-substitution.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value $v (type $o))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))) (export \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $r)) (with \"v\" (value $v)))) (alias export $i \"v\" (value $out)) (export \"out\" (value $out)))",
    source_id="resource-substitution.wat",
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
    "world", "", "0", "3", "r", "type", "resource", "0", "v", "value", "own", "0",
    "c", "component", "world", "", "0", "2", "r", "type", "resource", "1", "v", "value",
    "own", "1", "1", "v", "value", "own", "1", "1", "out", "value", "own", "0", "instance",
    "interface", "", "0", "1", "out", "value", "own", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values resource-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x0f\x02\x00\x01\x76\x02\x01\x00\x05\x6f\x74\x68\x65\x72\x03\x01\x07\x18\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x03\x05\x0c\x01\x00\x00\x02\x01\x72\x03\x02\x01\x76\x02\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x09\x01\x00\x03\x6f\x75\x74\x02\x01\x00\x00\x3d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x02\x02\x00\x01\x76\x01\x03\x6f\x75\x74\x01\x12\x03\x04\x00\x01\x72\x01\x01\x6f\x02\x05\x6f\x74\x68\x65\x72\x03\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="resource-wrong.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value $v (type $o))) (import \"other\" (type $other (sub resource))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))) (export \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $other)) (with \"v\" (value $v)))) (alias export $i \"v\" (value $out)) (export \"out\" (value $out)))",
    source_id="resource-wrong.wat",
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
test "runtime component values borrow-substitution" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x68\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x07\x18\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x68\x00\x03\x00\x01\x76\x02\x01\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x0c\x01\x00\x00\x02\x01\x72\x03\x00\x01\x76\x02\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x09\x01\x00\x03\x6f\x75\x74\x02\x01\x00\x00\x36\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x02\x02\x00\x01\x76\x01\x03\x6f\x75\x74\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="borrow-substitution.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $o (borrow $r)) (import \"v\" (value $v (type $o))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (borrow $r)) (import \"v\" (value (type $o))) (export \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $r)) (with \"v\" (value $v)))) (alias export $i \"v\" (value $out)) (export \"out\" (value $out)))",
    source_id="borrow-substitution.wat",
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
    "world", "", "0", "3", "r", "type", "resource", "0", "v", "value", "borrow",
    "0", "c", "component", "world", "", "0", "2", "r", "type", "resource", "1", "v",
    "value", "borrow", "1", "1", "v", "value", "borrow", "1", "1", "out", "value",
    "borrow", "0", "instance", "interface", "", "0", "1", "out", "value", "borrow",
    "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values fresh-resource-hidden" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="fresh-resource-hidden.wasm",
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
    "(component (type $c (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (export \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="fresh-resource-hidden.wat",
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
test "runtime component values fresh-resource-visible" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="fresh-resource-visible.wasm",
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
    "(component (type $c (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (export \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (export \"i\" (instance $i)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="fresh-resource-visible.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "v", "value", "own", "0", "2", "i", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "1", "v", "value", "own", "1", "v", "value",
    "own", "1", "instance", "interface", "", "0", "2", "i", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "1", "v", "value", "own", "1", "v", "value",
    "own", "1", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values inline-duplicate" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x11\x01\x01\x02\x00\x01\x76\x02\x00\x00\x05\x61\x67\x61\x69\x6e\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-duplicate.wasm",
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
    "(component (import \"v\" (value $v u32)) (instance $i (export \"v\" (value $v)) (export \"again\" (value $v))) (export \"i\" (instance $i)))",
    source_id="inline-duplicate.wat",
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
test "runtime component values nested-output" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x41\x02\x01\x42\x01\x04\x00\x01\x76\x02\x79\x04\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x0f\x02\x05\x00\x00\x05\x69\x6e\x6e\x65\x72\x02\x00\x01\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x32\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x0c\x05\x02\x00\x01\x69\x01\x05\x69\x6e\x6e\x65\x72",
    source_id="nested-output.wasm",
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
    "(component (type $c (component (type $i (instance (export \"v\" (value u32)))) (export \"inner\" (instance (type $i))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (alias export $i \"inner\" (instance $inner)) (alias export $inner \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="nested-output.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "inner",
    "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32", "1", "v",
    "value", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values fresh-resource-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x70\x04\x00\x07\x12\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x10\x03\x03\x00\x00\x01\x72\x03\x00\x01\x01\x72\x02\x00\x00\x01\x76\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x02\x01\x76\x02\x00\x0b\x0a\x01\x00\x04\x75\x73\x65\x64\x05\x02\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x10\x03\x04\x00\x01\x70\x01\x01\x63\x02\x02\x72\x61\x03\x02\x72\x62\x01\x08\x04\x02\x00\x01\x70\x01\x01\x63\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65",
    source_id="fresh-resource-argument.wasm",
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
    "(component (type $p (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (export \"v\" (value (type $o))))) (import \"p\" (component $p (type $p))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $p)) (instance $b (instantiate $p)) (alias export $a \"r\" (type $ra)) (alias export $b \"r\" (type $rb)) (alias export $a \"v\" (value $v)) (instance $use (instantiate $c (with \"r\" (type $ra)) (with \"v\" (value $v)))) (export \"used\" (instance $use)))",
    source_id="fresh-resource-argument.wat",
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
    "world", "", "0", "2", "p", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "v", "value", "own", "0", "c", "component", "world", "", "0",
    "2", "r", "type", "resource", "1", "v", "value", "own", "1", "0", "1", "used",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "used", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values crossed-fresh-resource-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x70\x04\x00\x07\x12\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x10\x03\x03\x00\x00\x01\x72\x03\x00\x01\x01\x72\x02\x00\x00\x01\x76\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x03\x01\x76\x02\x00\x0b\x0a\x01\x00\x04\x75\x73\x65\x64\x05\x02\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x10\x03\x04\x00\x01\x70\x01\x01\x63\x02\x02\x72\x61\x03\x02\x72\x62\x01\x08\x04\x02\x00\x01\x70\x01\x01\x63\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65",
    source_id="crossed-fresh-resource-argument.wasm",
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
    "(component (type $p (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (export \"v\" (value (type $o))))) (import \"p\" (component $p (type $p))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $p)) (instance $b (instantiate $p)) (alias export $a \"r\" (type $ra)) (alias export $b \"r\" (type $rb)) (alias export $a \"v\" (value $v)) (instance $use (instantiate $c (with \"r\" (type $rb)) (with \"v\" (value $v)))) (export \"used\" (instance $use)))",
    source_id="crossed-fresh-resource-argument.wat",
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
test "runtime component values unused-before-instance-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="unused-before-instance-export.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (export \"i\" (instance $i)) )",
    source_id="unused-before-instance-export.wat",
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
test "runtime component values anonymous-value-ascribed" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x16\x01\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x09\x01\x00\x01\x76\x02\x00\x01\x02\x01\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="anonymous-value-ascribed.wasm",
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
    "(component (type $t (record (field \"x\" u32))) (export $named \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"v\" (value $v)) (export \"v\" (value $v) (value (type $named))))",
    source_id="anonymous-value-ascribed.wat",
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
    "record", "1", "x", "scalar", "u32", "1", "v", "value", "record", "1", "x", "scalar",
    "u32", "2", "t", "type", "record", "1", "x", "scalar", "u32", "v", "value", "record",
    "1", "x", "scalar", "u32", "instance", "interface", "", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
    "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values consumed-alias-plus-instance-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x0d\x02\x00\x01\x76\x02\x00\x00\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="consumed-alias-plus-instance-export.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)) (export \"i\" (instance $i)))",
    source_id="consumed-alias-plus-instance-export.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "v", "value",
    "scalar", "u32", "2", "v", "value", "scalar", "u32", "i", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "instance", "interface", "", "0",
    "2", "v", "value", "scalar", "u32", "i", "instance", "interface", "", "0", "1",
    "v", "value", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values instance-export-before-alias-use" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="instance-export-before-alias-use.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (export \"i\" (instance $i)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
    source_id="instance-export-before-alias-use.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "v", "value",
    "scalar", "u32", "2", "i", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "v", "value", "scalar", "u32", "instance", "interface", "",
    "0", "2", "i", "instance", "interface", "", "0", "1", "v", "value", "scalar",
    "u32", "v", "value", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values inline-alias-plus-source-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x05\x08\x01\x01\x01\x00\x01\x76\x02\x00\x0b\x10\x02\x00\x04\x63\x6f\x70\x79\x05\x01\x00\x00\x01\x69\x05\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x0b\x05\x02\x00\x01\x69\x01\x04\x63\x6f\x70\x79",
    source_id="inline-alias-plus-source-instance.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (instance $copy (export \"v\" (value $v))) (export \"copy\" (instance $copy)) (export \"i\" (instance $i)))",
    source_id="inline-alias-plus-source-instance.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "v", "value",
    "scalar", "u32", "2", "copy", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "i", "instance", "interface", "", "0", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "2", "copy", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "i", "instance", "interface", "",
    "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component values same-alias-two-inline-instances" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x05\x0f\x02\x01\x01\x00\x01\x76\x02\x00\x01\x01\x00\x01\x76\x02\x00\x0b\x16\x02\x00\x05\x66\x69\x72\x73\x74\x05\x01\x00\x00\x06\x73\x65\x63\x6f\x6e\x64\x05\x02\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x14\x05\x03\x00\x01\x69\x01\x05\x66\x69\x72\x73\x74\x02\x06\x73\x65\x63\x6f\x6e\x64",
    source_id="same-alias-two-inline-instances.wasm",
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
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (instance $first (export \"v\" (value $v))) (instance $second (export \"v\" (value $v))) (export \"first\" (instance $first)) (export \"second\" (instance $second)))",
    source_id="same-alias-two-inline-instances.wat",
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
