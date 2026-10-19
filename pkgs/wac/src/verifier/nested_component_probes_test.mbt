///|
test "concrete component empty" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
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
    "(component (component $c) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
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
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "0", "instance",
    "interface", "", "0", "1", "i", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x43\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="function.wasm",
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
    "(component (component $c (type $f (func)) (import \"f\" (func $f (type $f))) (export \"f\" (func $f))) (type $f (func)) (import \"f\" (func $f (type $f))) (instance $i (instantiate $c (with \"f\" (func $f)))) (export \"i\" (instance $i)))",
    source_id="function.wat",
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
    "world", "", "0", "1", "f", "func", "function", "false", "0", "none", "1", "i",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "0",
    "none", "instance", "interface", "", "0", "1", "i", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x35\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x02\x01\x00\x01\x76\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="value.wasm",
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
    "(component (component $c (import \"v\" (value $v u32)) (export \"v\" (value $v))) (import \"v\" (value $v u32)) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
    source_id="value.wat",
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
test "concrete component local-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="local-resource.wasm",
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
    "(component (component $c (type $r (resource (rep i32))) (export \"r\" (type $r))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="local-resource.wat",
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
    "world", "", "0", "0", "2", "a", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "0", "b", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "instance", "interface", "", "0", "2", "a", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "b", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "1", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component outer-primitive" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x04\x34\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x00\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x74\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="outer-primitive.wasm",
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
    "(component (type $t u32) (component $c (alias outer 1 $t (type $t)) (export \"t\" (type $t))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="outer-primitive.wat",
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
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "t",
    "type", "scalar", "u32", "instance", "interface", "", "0", "1", "i", "instance",
    "interface", "", "0", "1", "t", "type", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component outer-record" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x79\x72\x01\x01\x78\x00\x04\x34\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x01\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x74\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x75\x01\x01\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="outer-record.wasm",
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
    "(component (type $u u32) (type $t (record (field \"x\" $u))) (component $c (alias outer 1 $t (type $t)) (export \"t\" (type $t))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="outer-record.wat",
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
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "t",
    "type", "record", "1", "x", "scalar", "u32", "instance", "interface", "", "0",
    "1", "i", "instance", "interface", "", "0", "1", "t", "type", "record", "1",
    "x", "scalar", "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component outer-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x04\x34\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x72\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="outer-resource.wasm",
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
    "(component (type $r (resource (rep i32))) (component $c (alias outer 1 $r (type $r)) (export \"r\" (type $r))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="outer-resource.wat",
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
test "concrete component outer-component" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x21\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x06\x05\x66\x69\x72\x73\x74\x04\x46\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x04\x02\x01\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x07\x06\x73\x65\x63\x6f\x6e\x64\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x11\x04\x02\x00\x05\x66\x69\x72\x73\x74\x01\x06\x73\x65\x63\x6f\x6e\x64\x01\x05\x05\x01\x00\x01\x69",
    source_id="outer-component.wasm",
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
    "(component (component $first) (component $second (alias outer 1 $first (component $c)) (instance $i (instantiate $c)) (export \"i\" (instance $i))) (instance $i (instantiate $second)) (export \"i\" (instance $i)))",
    source_id="outer-component.wat",
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
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "i",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "i", "instance", "interface", "", "0", "1", "i", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component export-component" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x0b\x07\x01\x00\x01\x63\x04\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63",
    source_id="export-component.wasm",
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
    "(component (component $c) (export \"c\" (component $c)))",
    source_id="export-component.wat",
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
    "world", "", "0", "0", "1", "c", "component", "world", "", "0", "0", "0", "instance",
    "interface", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component nested-definition" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x59\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x62\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x61\x01\x05\x04\x01\x00\x01\x62\x01\x05\x05\x01\x00\x01\x69\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x61\x01\x05\x05\x01\x00\x01\x69",
    source_id="nested-definition.wasm",
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
    "(component (component $a (component $b) (instance $i (instantiate $b)) (export \"i\" (instance $i))) (instance $i (instantiate $a)) (export \"i\" (instance $i)))",
    source_id="nested-definition.wat",
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
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "1", "i",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "i", "instance", "interface", "", "0", "1", "i", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component export-nested-component" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x4c\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x62\x0b\x07\x01\x00\x01\x62\x04\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x61\x01\x05\x04\x01\x00\x01\x62\x05\x04\x01\x00\x00\x00\x06\x06\x01\x04\x00\x00\x01\x62\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x6a\x05\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x04\x02\x00\x01\x61\x01\x01\x62\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    source_id="export-nested-component.wasm",
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
    "(component (component $a (component $b) (export \"b\" (component $b))) (instance $i (instantiate $a)) (alias export $i \"b\" (component $b)) (instance $j (instantiate $b)) (export \"j\" (instance $j)))",
    source_id="export-nested-component.wat",
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
    "world", "", "0", "0", "1", "j", "instance", "interface", "", "0", "0", "instance",
    "interface", "", "0", "1", "j", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component module" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x51\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x00\x1b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="module.wasm",
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
    "(component (component $c (core module $m (func (export \"f\")))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="module.wat",
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
    "world", "", "0", "0", "1", "i", "instance", "interface", "", "0", "0", "instance",
    "interface", "", "0", "1", "i", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component module-export" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x5b\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x1b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="module-export.wasm",
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
    "(component (component $c (core module $m (func (export \"f\"))) (export \"m\" (core module $m))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="module-export.wat",
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
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component bad-child" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x26\x00\x61\x73\x6d\x0d\x00\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63",
    source_id="bad-child.wasm",
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
    "(component (component $c (export \"f\" (func 0))))",
    source_id="bad-child.wat",
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
test "concrete component future-child" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x04\x01\x00\x00\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="future-child.wasm",
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
    "(component (instance $i (instantiate 0)) (component $c))",
    source_id="future-child.wat",
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
test "concrete component unused-definition" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63",
    source_id="unused-definition.wasm",
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
    "(component (component $c))",
    source_id="unused-definition.wat",
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
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component function-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x43\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="function-wrong.wasm",
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
    "(component (component $c (type $f (func)) (import \"f\" (func $f (type $f))) (export \"f\" (func $f))) (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (instance $i (instantiate $c (with \"f\" (func $f)))) (export \"i\" (instance $i)))",
    source_id="function-wrong.wat",
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
test "concrete component value-twice" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x35\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x02\x01\x00\x01\x76\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x0d\x02\x00\x01\x69\x05\x00\x00\x00\x01\x76\x02\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="value-twice.wasm",
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
    "(component (component $c (import \"v\" (value $v u32)) (export \"v\" (value $v))) (import \"v\" (value $v u32)) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)) (export \"v\" (value $v)))",
    source_id="value-twice.wat",
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
test "concrete component unused-child-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x25\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63",
    source_id="unused-child-value.wasm",
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
    "(component (component $c (import \"v\" (value u32))))",
    source_id="unused-child-value.wat",
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
test "concrete component crossed-local-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xb0\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x3e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x72\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x6f\x03\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x01\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x49\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65",
    source_id="crossed-local-resource.wasm",
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
    "(component (component $c (type $r (resource (rep i32))) (export $named \"r\" (type $r)) (type $o (own $named)) (type $f (func (param \"x\" $o))) (core module $m (func (export \"f\") (param i32))) (core instance $m (instantiate $m)) (func $f (type $f) (canon lift (core func $m \"f\"))) (export \"f\" (func $f)))(type $consumer (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"consumer\" (component $consumer (type $consumer)))(instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"r\" (type $ra)) (alias export $b \"f\" (func $fb)) (instance $use (instantiate $consumer (with \"r\" (type $ra)) (with \"f\" (func $fb)))))",
    source_id="crossed-local-resource.wat",
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
test "concrete component matched-local-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xb0\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x3e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x72\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x6f\x03\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x00\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x49\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65",
    source_id="matched-local-resource.wasm",
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
    "(component (component $c (type $r (resource (rep i32))) (export $named \"r\" (type $r)) (type $o (own $named)) (type $f (func (param \"x\" $o))) (core module $m (func (export \"f\") (param i32))) (core instance $m (instantiate $m)) (func $f (type $f) (canon lift (core func $m \"f\"))) (export \"f\" (func $f)))(type $consumer (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"consumer\" (component $consumer (type $consumer)))(instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"r\" (type $ra)) (alias export $a \"f\" (func $fb)) (instance $use (instantiate $consumer (with \"r\" (type $ra)) (with \"f\" (func $fb)))))",
    source_id="matched-local-resource.wat",
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
    "world", "", "0", "1", "consumer", "component", "world", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "0", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component nested-local-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x51\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x05\x08\x01\x01\x01\x00\x01\x72\x03\x00\x0b\x0b\x01\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x01\x05\x05\x01\x00\x01\x69\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="nested-local-resource.wasm",
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
    "(component (component $c (type $r (resource (rep i32))) (export \"r\" (type $r)) (instance $i (export \"r\" (type $r))) (export \"inner\" (instance $i))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="nested-local-resource.wat",
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
    "world", "", "0", "0", "2", "a", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "inner", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "0", "b", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "1", "inner", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "instance", "interface", "", "0", "2", "a", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "inner", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "b", "instance", "interface", "",
    "0", "2", "r", "type", "resource", "1", "inner", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "1", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component imported-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x04\x35\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x05\x0f\x02\x00\x00\x01\x01\x72\x03\x00\x00\x00\x01\x01\x72\x03\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x72\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="imported-resource.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (component $c (import \"r\" (type $r (sub resource))) (export \"r\" (type $r))) (instance $a (instantiate $c (with \"r\" (type $r)))) (instance $b (instantiate $c (with \"r\" (type $r)))) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="imported-resource.wat",
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
test "concrete component outer-module" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x04\x37\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x06\x01\x00\x11\x02\x01\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x1b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x25\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="outer-module.wasm",
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
    "(component (core module $m (func (export \"f\"))) (component $c (alias outer 1 $m (core module $m)) (export \"m\" (core module $m))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="outer-module.wat",
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
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component outer-record-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x79\x72\x01\x01\x78\x00\x04\x60\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x01\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x66\x0b\x07\x01\x00\x01\x63\x04\x00\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x75\x01\x01\x74\x01\x05\x04\x01\x00\x01\x63",
    source_id="outer-record-function.wasm",
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
    "(component (type $u u32) (type $t (record (field \"x\" $u))) (component $c (alias outer 1 $t (type $t)) (export $named \"t\" (type $t)) (type $f (func (param \"x\" $named))) (import \"f\" (func $f (type $f))) (export \"f\" (func $f))) (export \"c\" (component $c)))",
    source_id="outer-record-function.wat",
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
test "concrete component value-grandchild" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x84\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x35\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x64\x01\x05\x02\x01\x00\x01\x76\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x28\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x64\x01\x05\x05\x01\x00\x01\x69\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="value-grandchild.wasm",
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
    "(component (component $c (component $d (import \"v\" (value $v u32)) (export \"v\" (value $v))) (import \"v\" (value $v u32)) (instance $i (instantiate $d (with \"v\" (value $v)))) (export \"i\" (instance $i))) (import \"v\" (value $v u32)) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
    source_id="value-grandchild.wat",
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
    "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "i", "instance", "interface", "",
    "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value", "scalar",
    "u32", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component outer-record-import-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x79\x72\x01\x01\x78\x00\x04\x60\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x01\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x66\x0b\x07\x01\x00\x01\x63\x04\x00\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x75\x01\x01\x74\x01\x05\x04\x01\x00\x01\x63",
    source_id="outer-record-import-function.wasm",
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
    "(component (type $u u32) (type $t (record (field \"x\" $u))) (component $c (alias outer 1 $t (type $t)) (import \"t\" (type $named (eq $t))) (type $f (func (param \"x\" $named))) (import \"f\" (func $f (type $f))) (export \"f\" (func $f))) (export \"c\" (component $c)))",
    source_id="outer-record-import-function.wat",
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
    "world", "", "0", "0", "1", "c", "component", "world", "", "0", "2", "t", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "record", "1", "x", "scalar", "u32", "none", "1", "f", "func", "function", "false",
    "1", "x", "record", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "c", "component", "world", "", "0", "2", "t", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
    "1", "x", "scalar", "u32", "none", "1", "f", "func", "function", "false", "1",
    "x", "record", "1", "x", "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component component-annotation" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x07\x09\x01\x41\x01\x04\x00\x01\x72\x03\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x01\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x05\x04\x01\x00\x01\x63",
    source_id="component-annotation.wasm",
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
    "(component (component $c (type $r (resource (rep i32))) (export \"r\" (type $r))) (type $expected (component (export \"r\" (type (sub resource))))) (export \"c\" (component $c) (component (type $expected))))",
    source_id="component-annotation.wat",
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
    "world", "", "0", "0", "1", "c", "component", "world", "", "0", "0", "1", "r",
    "type", "resource", "0", "instance", "interface", "", "0", "1", "c", "component",
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component component-annotation-missing" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x07\x0d\x01\x41\x01\x04\x00\x05\x6f\x74\x68\x65\x72\x03\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x01\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x05\x04\x01\x00\x01\x63",
    source_id="component-annotation-missing.wasm",
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
    "(component (component $c (type $r (resource (rep i32))) (export \"r\" (type $r))) (type $expected (component (export \"other\" (type (sub resource))))) (export \"c\" (component $c) (component (type $expected))))",
    source_id="component-annotation-missing.wat",
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
test "concrete component component-narrowing" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x43\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x07\x0e\x01\x41\x02\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x05\x08\x01\x00\x01\x01\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x62\x61\x64\x01\x0f\x03\x02\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x01\x66\x01\x0d\x04\x02\x00\x01\x63\x01\x06\x6e\x61\x72\x72\x6f\x77\x01\x05\x05\x01\x00\x01\x69",
    source_id="component-narrowing.wasm",
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
    "(component (component $c (type $f (func)) (import \"f\" (func $f (type $f))) (export \"f\" (func $f))) (type $expected (component (type $f (func)) (import \"f\" (func (type $f))))) (export $narrow \"c\" (component $c) (component (type $expected))) (type $f (func)) (import \"f\" (func $f (type $f))) (instance $i (instantiate $narrow (with \"f\" (func $f)))) (alias export $i \"f\" (func $bad)))",
    source_id="component-narrowing.wat",
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
test "concrete component crossed-nested-local-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xbb\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x03\x3f\x7f\x00\x69\x00\x40\x01\x01\x78\x01\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x02\x05\x0d\x01\x01\x02\x00\x01\x72\x03\x00\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x09\x05\x01\x00\x05\x69\x6e\x6e\x65\x72\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x1d\x04\x05\x00\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x01\x05\x69\x6e\x6e\x65\x72\x03\x00\x02\x01\x72\x01\x00\x03\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x51\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x15\x05\x05\x00\x01\x61\x01\x01\x62\x02\x02\x61\x69\x03\x02\x62\x69\x04\x03\x75\x73\x65",
    source_id="crossed-nested-local-resource.wasm",
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
    "(component (component $c (type $r (resource (rep i32)))  (type $o (own $r)) (type $f (func (param \"x\" $o))) (core module $m (func (export \"f\") (param i32))) (core instance $m (instantiate $m)) (func $f (type $f) (canon lift (core func $m \"f\"))) (instance $inner (export \"r\" (type $r)) (export \"f\" (func $f))) (export \"inner\" (instance $inner)))(type $consumer (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"consumer\" (component $consumer (type $consumer)))(instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"inner\" (instance $ai)) (alias export $b \"inner\" (instance $bi)) (alias export $ai \"r\" (type $ra)) (alias export $bi \"f\" (func $fb)) (instance $use (instantiate $consumer (with \"r\" (type $ra)) (with \"f\" (func $fb)))))",
    source_id="crossed-nested-local-resource.wat",
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
test "concrete component matched-nested-local-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xbb\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x03\x3f\x7f\x00\x69\x00\x40\x01\x01\x78\x01\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x02\x05\x0d\x01\x01\x02\x00\x01\x72\x03\x00\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x09\x05\x01\x00\x05\x69\x6e\x6e\x65\x72\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x1d\x04\x05\x00\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x01\x05\x69\x6e\x6e\x65\x72\x03\x00\x02\x01\x72\x01\x00\x02\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x51\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x15\x05\x05\x00\x01\x61\x01\x01\x62\x02\x02\x61\x69\x03\x02\x62\x69\x04\x03\x75\x73\x65",
    source_id="matched-nested-local-resource.wasm",
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
    "(component (component $c (type $r (resource (rep i32)))  (type $o (own $r)) (type $f (func (param \"x\" $o))) (core module $m (func (export \"f\") (param i32))) (core instance $m (instantiate $m)) (func $f (type $f) (canon lift (core func $m \"f\"))) (instance $inner (export \"r\" (type $r)) (export \"f\" (func $f))) (export \"inner\" (instance $inner)))(type $consumer (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"consumer\" (component $consumer (type $consumer)))(instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"inner\" (instance $ai)) (alias export $b \"inner\" (instance $bi)) (alias export $ai \"r\" (type $ra)) (alias export $ai \"f\" (func $fb)) (instance $use (instantiate $consumer (with \"r\" (type $ra)) (with \"f\" (func $fb)))))",
    source_id="matched-nested-local-resource.wat",
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
    "world", "", "0", "1", "consumer", "component", "world", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "0", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component value-custom" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x45\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x08\x00\x61\x73\x6d\x01\x00\x00\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x08\x04\x62\x6c\x6f\x62\xff\x00\x80\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76",
    source_id="value-custom.wasm",
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
    "(component (component (core module) (import \"v\" (value $v u32)) (export \"v\" (value $v)) (@custom \"blob\" \"\\ff\\00\\80\")))",
    source_id="value-custom.wat",
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
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component hidden-outer-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x72\x01\x01\x68\x01\x04\x00\x03\x72\x65\x63\x03\x00\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x08\x01\x03\x00\x00\x03\x72\x65\x63\x04\x3c\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x01\x0b\x09\x01\x00\x03\x72\x65\x63\x03\x00\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x06\x05\x63\x68\x69\x6c\x64\x01\x07\x03\x01\x00\x03\x72\x65\x63\x0b\x0b\x01\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x02\x00\x03\x61\x70\x69\x01\x03\x72\x65\x63\x01\x09\x04\x01\x00\x05\x63\x68\x69\x6c\x64\x01\x07\x05\x01\x00\x03\x61\x70\x69",
    source_id="hidden-outer-resource.wasm",
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
    "(component\n  (type $api (instance\n    (export \"r\" (type $r (sub resource)))\n    (type $record (record (field \"h\" (own $r))))\n    (export \"rec\" (type (eq $record)))\n  ))\n  (import \"api\" (instance $api (type $api)))\n  (alias export $api \"rec\" (type $rec))\n  (component $child\n    (alias outer 1 $rec (type $rec))\n    (export \"rec\" (type $rec))\n  )\n  (export \"child\" (component $child))\n)\n",
    source_id="hidden-outer-resource.wat",
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
test "concrete component hidden-outer-record" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x72\x01\x01\x68\x79\x04\x00\x03\x72\x65\x63\x03\x00\x01\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x08\x01\x03\x00\x00\x03\x72\x65\x63\x04\x3c\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x01\x0b\x09\x01\x00\x03\x72\x65\x63\x03\x00\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x06\x05\x63\x68\x69\x6c\x64\x01\x07\x03\x01\x00\x03\x72\x65\x63\x0b\x0b\x01\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x02\x00\x03\x61\x70\x69\x01\x03\x72\x65\x63\x01\x09\x04\x01\x00\x05\x63\x68\x69\x6c\x64\x01\x07\x05\x01\x00\x03\x61\x70\x69",
    source_id="hidden-outer-record.wasm",
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
    "(component\n  (type $api (instance\n    (export \"r\" (type $r (sub resource)))\n    (type $record (record (field \"h\" u32)))\n    (export \"rec\" (type (eq $record)))\n  ))\n  (import \"api\" (instance $api (type $api)))\n  (alias export $api \"rec\" (type $rec))\n  (component $child\n    (alias outer 1 $rec (type $rec))\n    (export \"rec\" (type $rec))\n  )\n  (export \"child\" (component $child))\n)\n",
    source_id="hidden-outer-record.wat",
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
    "resource", "0", "rec", "type", "record", "1", "h", "scalar", "u32", "1", "child",
    "component", "world", "", "0", "0", "1", "rec", "type", "record", "1", "h", "scalar",
    "u32", "instance", "interface", "", "0", "1", "child", "component", "world",
    "", "0", "0", "1", "rec", "type", "record", "1", "h", "scalar", "u32", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "concrete component nested-producers" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x29\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0b\x6e\x65\x73\x74\x65\x64\x2d\x74\x65\x73\x74\x03\x31\x2e\x30",
    source_id="nested-producers.wasm",
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
    "(component (component (@producers (processed-by \"nested-test\" \"1.0\"))))",
    source_id="nested-producers.wat",
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
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}
