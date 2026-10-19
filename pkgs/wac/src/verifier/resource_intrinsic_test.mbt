///|
test "canonical resource intrinsic new-local" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="new-local.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-local.wat",
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
test "canonical resource intrinsic new-imported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="new-imported.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-imported.wat",
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
test "canonical resource intrinsic new-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x02\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x37\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x0c\x03\x02\x00\x01\x72\x01\x05\x61\x6c\x69\x61\x73",
    source_id="new-alias.wasm",
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
    "(component (type $r (resource (rep i32))) (export $alias \"r\" (type $r)) (core func $f (canon resource.new $alias)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-alias.wat",
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
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "canonical resource intrinsic new-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="new-value.wasm",
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
    "(component (type $r u32) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-value.wat",
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
test "canonical resource intrinsic new-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="new-future.wasm",
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
    "(component  (core func $f (canon resource.new 0)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-future.wat",
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
test "canonical resource intrinsic new-wrong-param" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="new-wrong-param.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-wrong-param.wat",
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
test "canonical resource intrinsic new-wrong-result" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="new-wrong-result.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-wrong-result.wat",
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
test "canonical resource intrinsic new-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x72\x08\x03\x01\x02\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x69\x01\x01\x72",
    source_id="new-instance.wasm",
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
    "(component (type $i (instance (export \"r\" (type (sub resource))))) (import \"api\" (instance (type $i))) (alias export 0 \"r\" (type $r)) (core func (canon resource.new $r)))",
    source_id="new-instance.wat",
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
test "canonical resource intrinsic drop-local" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x03\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="drop-local.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.drop $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-local.wat",
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
test "canonical resource intrinsic drop-imported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x08\x03\x01\x03\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="drop-imported.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (core func $f (canon resource.drop $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-imported.wat",
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
    "world", "", "0", "1", "r", "type", "resource", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "canonical resource intrinsic drop-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x03\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x37\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x0c\x03\x02\x00\x01\x72\x01\x05\x61\x6c\x69\x61\x73",
    source_id="drop-alias.wasm",
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
    "(component (type $r (resource (rep i32))) (export $alias \"r\" (type $r)) (core func $f (canon resource.drop $alias)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-alias.wat",
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
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "canonical resource intrinsic drop-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x08\x03\x01\x03\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="drop-value.wasm",
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
    "(component (type $r u32) (core func $f (canon resource.drop $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-value.wat",
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
test "canonical resource intrinsic drop-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x03\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="drop-future.wasm",
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
    "(component  (core func $f (canon resource.drop 0)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-future.wat",
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
test "canonical resource intrinsic drop-wrong-param" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x03\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="drop-wrong-param.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.drop $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-wrong-param.wat",
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
test "canonical resource intrinsic drop-wrong-result" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x03\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="drop-wrong-result.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.drop $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="drop-wrong-result.wat",
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
test "canonical resource intrinsic drop-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x72\x08\x03\x01\x03\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x69\x01\x01\x72",
    source_id="drop-instance.wasm",
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
    "(component (type $i (instance (export \"r\" (type (sub resource))))) (import \"api\" (instance (type $i))) (alias export 0 \"r\" (type $r)) (core func (canon resource.drop $r)))",
    source_id="drop-instance.wat",
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
    "world", "", "0", "1", "api", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "0", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "canonical resource intrinsic rep-local" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-local.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-local.wat",
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
test "canonical resource intrinsic rep-imported" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-imported.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-imported.wat",
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
test "canonical resource intrinsic rep-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x04\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x37\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x0c\x03\x02\x00\x01\x72\x01\x05\x61\x6c\x69\x61\x73",
    source_id="rep-alias.wasm",
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
    "(component (type $r (resource (rep i32))) (export $alias \"r\" (type $r)) (core func $f (canon resource.rep $alias)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-alias.wat",
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
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "canonical resource intrinsic rep-value" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-value.wasm",
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
    "(component (type $r u32) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-value.wat",
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
test "canonical resource intrinsic rep-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
    source_id="rep-future.wasm",
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
    "(component  (core func $f (canon resource.rep 0)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-future.wat",
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
test "canonical resource intrinsic rep-wrong-param" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-wrong-param.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-wrong-param.wat",
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
test "canonical resource intrinsic rep-wrong-result" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-wrong-result.wasm",
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
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-wrong-result.wat",
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
test "canonical resource intrinsic rep-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x72\x08\x03\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x69\x01\x01\x72",
    source_id="rep-instance.wasm",
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
    "(component (type $i (instance (export \"r\" (type (sub resource))))) (import \"api\" (instance (type $i))) (alias export 0 \"r\" (type $r)) (core func (canon resource.rep $r)))",
    source_id="rep-instance.wat",
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
test "canonical resource intrinsic rep-i64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7e\x00\x08\x03\x01\x04\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-i64.wasm",
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
    "(component (type $r (resource (rep i64))) (core func (canon resource.rep $r)))",
    source_id="rep-i64.wat",
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
test "canonical resource intrinsic drop-ordinary-type-import" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x0a\x07\x01\x00\x01\x76\x03\x00\x00\x08\x03\x01\x03\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x76\x01\x01\x74",
    source_id="drop-ordinary-type-import.wasm",
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
    "(component (type $v u32) (import \"v\" (type $t (eq $v))) (core func (canon resource.drop $t)))",
    source_id="drop-ordinary-type-import.wat",
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
test "canonical resource intrinsic drop-future-defined" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x03\x01\x03\x00\x07\x04\x01\x3f\x7f\x00",
    source_id="drop-future-defined.wasm",
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
    "(component (core func (canon resource.drop 0)) (type (resource (rep i32))))",
    source_id="drop-future-defined.wat",
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
test "canonical resource intrinsic new-i64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7e\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="new-i64.wasm",
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
    "(component (type $r (resource (rep i64))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i64) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="new-i64.wat",
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
test "canonical resource intrinsic rep-i64-consumer" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7e\x00\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="rep-i64-consumer.wasm",
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
    "(component (type $r (resource (rep i64))) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="rep-i64-consumer.wat",
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
test "canonical resource intrinsic destructor-i32-i32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7f\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72",
    source_id="destructor-i32-i32.wasm",
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
    "(component (core module $m (func (export \"drop\") (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"drop\" (core func $drop)) (type $r (resource (rep i32) (dtor $drop))) (core func (canon resource.new $r)))",
    source_id="destructor-i32-i32.wat",
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
test "canonical resource intrinsic destructor-i32-i64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7f\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72",
    source_id="destructor-i32-i64.wasm",
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
    "(component (core module $m (func (export \"drop\") (param i64))) (core instance $i (instantiate $m)) (alias core export $i \"drop\" (core func $drop)) (type $r (resource (rep i32) (dtor $drop))) (core func (canon resource.new $r)))",
    source_id="destructor-i32-i64.wat",
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
test "canonical resource intrinsic destructor-i64-i32" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7e\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72",
    source_id="destructor-i64-i32.wasm",
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
    "(component (core module $m (func (export \"drop\") (param i32))) (core instance $i (instantiate $m)) (alias core export $i \"drop\" (core func $drop)) (type $r (resource (rep i64) (dtor $drop))) (core func (canon resource.new $r)))",
    source_id="destructor-i64-i32.wat",
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
test "canonical resource intrinsic destructor-i64-i64" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7e\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72",
    source_id="destructor-i64-i64.wasm",
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
    "(component (core module $m (func (export \"drop\") (param i64))) (core instance $i (instantiate $m)) (alias core export $i \"drop\" (core func $drop)) (type $r (resource (rep i64) (dtor $drop))) (core func (canon resource.new $r)))",
    source_id="destructor-i64-i64.wat",
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
test "canonical resource intrinsic invalid-representation" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7d\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72",
    source_id="invalid-representation.wasm",
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
    "(component (type $r (resource (rep f32))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
    source_id="invalid-representation.wat",
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
test "canonical resource intrinsic destructor-result" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x31\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x06\x01\x04\x00\x20\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7f\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72",
    source_id="destructor-result.wasm",
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
    "(component (core module $m (func (export \"drop\") (param i32) (result i32) local.get 0)) (core instance $i (instantiate $m)) (alias core export $i \"drop\" (core func $drop)) (type $r (resource (rep i32) (dtor $drop))) (core func (canon resource.new $r)))",
    source_id="destructor-result.wat",
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
test "canonical resource intrinsic destructor-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x3f\x7f\x01\x00\x08\x03\x01\x03\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x72",
    source_id="destructor-future.wasm",
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
    "(component (type $r (resource (rep i32) (dtor 0))) (core func (canon resource.drop $r)))",
    source_id="destructor-future.wat",
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
test "canonical resource intrinsic new-outer-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x06\x05\x01\x03\x02\x00\x00\x08\x03\x01\x02\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x74",
    source_id="new-outer-alias.wasm",
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
    "(component (type $r (resource (rep i32))) (alias outer 0 $r (type $t)) (core func (canon resource.new $t)))",
    source_id="new-outer-alias.wat",
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
test "canonical resource intrinsic new-import-eq" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x02\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x74",
    source_id="new-import-eq.wasm",
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
    "(component (type $r (resource (rep i32))) (import \"r\" (type $t (eq $r))) (core func (canon resource.new $t)))",
    source_id="new-import-eq.wat",
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
test "canonical resource intrinsic drop-outer-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x06\x05\x01\x03\x02\x00\x00\x08\x03\x01\x03\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x74",
    source_id="drop-outer-alias.wasm",
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
    "(component (type $r (resource (rep i32))) (alias outer 0 $r (type $t)) (core func (canon resource.drop $t)))",
    source_id="drop-outer-alias.wat",
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
test "canonical resource intrinsic drop-import-eq" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x03\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x74",
    source_id="drop-import-eq.wasm",
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
    "(component (type $r (resource (rep i32))) (import \"r\" (type $t (eq $r))) (core func (canon resource.drop $t)))",
    source_id="drop-import-eq.wat",
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
test "canonical resource intrinsic rep-outer-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x06\x05\x01\x03\x02\x00\x00\x08\x03\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x74",
    source_id="rep-outer-alias.wasm",
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
    "(component (type $r (resource (rep i32))) (alias outer 0 $r (type $t)) (core func (canon resource.rep $t)))",
    source_id="rep-outer-alias.wat",
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
test "canonical resource intrinsic rep-import-eq" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0a\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x74",
    source_id="rep-import-eq.wasm",
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
    "(component (type $r (resource (rep i32))) (import \"r\" (type $t (eq $r))) (core func (canon resource.rep $t)))",
    source_id="rep-import-eq.wat",
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
