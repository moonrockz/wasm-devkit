///|
test "runtime component instance empty" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
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
    "(component (type $c (component)) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "1", "i",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "i", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-empty" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x03\x01\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-empty.wasm",
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
    "(component (instance $i) (export \"i\" (instance $i)))",
    source_id="inline-empty.wat",
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
test "runtime component instance function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x07\x17\x01\x41\x03\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x01\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x08\x03\x02\x00\x01\x66\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
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
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (type $c (component (type $f (func (param \"x\" u32))) (import \"f\" (func (type $f))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"f\" (func $f)))) (alias export $i \"f\" (func $out)) (export \"out\" (func $out)))",
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
    "world", "", "0", "2", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "c", "component", "world", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "1", "out", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "instance", "interface", "", "0", "1", "out", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x05\x08\x01\x01\x01\x00\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x0d\x02\x00\x01\x69\x05\x00\x00\x00\x01\x66\x01\x01\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x05\x03\x01\x00\x01\x66\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-function.wasm",
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
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (instance $i (export \"f\" (func $f))) (alias export $i \"f\" (func $out)) (export \"i\" (instance $i)) (export \"f\" (func $out)))",
    source_id="inline-function.wat",
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "none", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "none", "instance", "interface", "", "0",
    "2", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "f", "func", "function", "false", "1", "x",
    "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-fresh" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="resource-fresh.wasm",
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
    "(component (type $c (component (export \"r\" (type (sub resource))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-fresh.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "r", "type",
    "resource", "0", "2", "a", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "1", "b", "instance", "interface", "", "0", "1", "r", "type", "resource",
    "2", "instance", "interface", "", "0", "2", "a", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "1", "b", "instance", "interface", "", "0",
    "1", "r", "type", "resource", "2", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x10\x01\x41\x02\x03\x00\x01\x72\x03\x01\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x72\x03\x00\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="resource-argument.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $c (component (import \"r\" (type $r (sub resource))) (export \"r\" (type (eq $r))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $r)))) (export \"r\" (type $r)) (export \"i\" (instance $i)))",
    source_id="resource-argument.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "c", "component", "world",
    "", "0", "1", "r", "type", "resource", "1", "1", "r", "type", "resource", "1",
    "2", "r", "type", "resource", "0", "i", "instance", "interface", "", "0", "1",
    "r", "type", "resource", "0", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "i", "instance", "interface", "", "0", "1", "r", "type", "resource",
    "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-resource" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x05\x08\x01\x01\x01\x00\x01\x72\x03\x00\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x72\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-resource.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (instance $i (export \"r\" (type $r))) (export \"r\" (type $r)) (export \"i\" (instance $i)))",
    source_id="inline-resource.wat",
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
    "world", "", "0", "1", "r", "type", "resource", "0", "2", "r", "type", "resource",
    "0", "i", "instance", "interface", "", "0", "1", "r", "type", "resource", "0",
    "instance", "interface", "", "0", "2", "r", "type", "resource", "0", "i", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-component" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x08\x01\x01\x01\x00\x01\x63\x04\x00\x06\x06\x01\x04\x00\x00\x01\x63\x05\x04\x01\x00\x01\x00\x0b\x0c\x01\x00\x06\x72\x65\x73\x75\x6c\x74\x05\x01\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x0c\x04\x02\x00\x01\x63\x01\x05\x61\x67\x61\x69\x6e\x01\x0d\x05\x02\x00\x01\x69\x01\x06\x72\x65\x73\x75\x6c\x74",
    source_id="inline-component.wasm",
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
    "(component (type $c (component)) (import \"c\" (component $c (type $c))) (instance $i (export \"c\" (component $c))) (alias export $i \"c\" (component $again)) (instance $result (instantiate $again)) (export \"result\" (instance $result)))",
    source_id="inline-component.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "0", "1", "result",
    "instance", "interface", "", "0", "0", "instance", "interface", "", "0", "1",
    "result", "instance", "interface", "", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-module" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x05\x09\x01\x01\x01\x00\x01\x6d\x00\x11\x00\x06\x07\x01\x00\x11\x00\x00\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x01\x00\x00\x2d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x0d\x00\x11\x02\x00\x01\x6d\x01\x05\x61\x67\x61\x69\x6e\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-module.wasm",
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
    "(component (core type $m (module (export \"f\" (func (param i32))))) (import \"m\" (core module $m (type $m))) (instance $i (export \"m\" (core module $m))) (alias export $i \"m\" (core module $again)) (export \"m\" (core module $again)))",
    source_id="inline-module.wat",
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
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
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
test "runtime component instance future-component" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x04\x01\x00\x00\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63",
    source_id="future-component.wasm",
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
    "(component (instance (instantiate 0)) (type $c (component)) (import \"c\" (component (type $c))))",
    source_id="future-component.wat",
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
test "runtime component instance future-instance" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x08\x01\x01\x01\x00\x01\x69\x05\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x05\x01\x00\x01\x69",
    source_id="future-instance.wasm",
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
    "(component (instance $i (export \"i\" (instance 0))))",
    source_id="future-instance.wat",
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
test "runtime component instance function-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x78\x77\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x07\x17\x01\x41\x03\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x01\x00\x00\x3a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x0f\x03\x03\x00\x01\x66\x01\x05\x77\x72\x6f\x6e\x67\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
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
    "(component (type $f (func (param \"x\" u32))) (type $wrong (func (param \"x\" u64))) (import \"f\" (func $f (type $wrong))) (type $c (component (type $f (func (param \"x\" u32))) (import \"f\" (func (type $f))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"f\" (func $f)))) (alias export $i \"f\" (func $out)) (export \"out\" (func $out)))",
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
test "runtime component instance function-missing" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x07\x17\x01\x41\x03\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x04\x01\x00\x00\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x01\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x08\x03\x02\x00\x01\x66\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="function-missing.wasm",
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
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (type $c (component (type $f (func (param \"x\" u32))) (import \"f\" (func (type $f))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (alias export $i \"f\" (func $out)) (export \"out\" (func $out)))",
    source_id="function-missing.wat",
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
test "runtime component instance function-duplicate" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x07\x17\x01\x41\x03\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x0c\x01\x00\x00\x02\x01\x66\x01\x00\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x01\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x08\x03\x02\x00\x01\x66\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="function-duplicate.wasm",
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
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (type $c (component (type $f (func (param \"x\" u32))) (import \"f\" (func (type $f))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"f\" (func $f)) (with \"f\" (func $f)))) (alias export $i \"f\" (func $out)) (export \"out\" (func $out)))",
    source_id="function-duplicate.wat",
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
test "runtime component instance extra-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x05\x0c\x01\x00\x00\x01\x05\x65\x78\x74\x72\x61\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x08\x03\x02\x00\x01\x63\x01\x01\x66\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="extra-argument.wasm",
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
    "(component (type $c (component)) (import \"c\" (component $c (type $c))) (type $f (func)) (import \"f\" (func $f (type $f))) (instance $i (instantiate $c (with \"extra\" (func $f)))) (export \"i\" (instance $i)))",
    source_id="extra-argument.wat",
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
    "world", "", "0", "2", "c", "component", "world", "", "0", "0", "0", "f", "func",
    "function", "false", "0", "none", "1", "i", "instance", "interface", "", "0",
    "0", "instance", "interface", "", "0", "1", "i", "instance", "interface", "",
    "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-duplicate" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x05\x0d\x01\x01\x02\x00\x01\x66\x01\x00\x00\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x0d\x02\x00\x01\x69\x05\x00\x00\x00\x01\x66\x01\x01\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x05\x03\x01\x00\x01\x66\x01\x05\x05\x01\x00\x01\x69",
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
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (instance $i (export \"f\" (func $f)) (export \"f\" (func $f))) (alias export $i \"f\" (func $out)) (export \"i\" (instance $i)) (export \"f\" (func $out)))",
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
test "runtime component instance resource-nested" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x04\x00\x03\x61\x70\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="resource-nested.wasm",
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
    "(component (type $c (component (type $i (instance (export \"r\" (type (sub resource))))) (export \"api\" (instance (type $i))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-nested.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "api", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "2", "a", "instance",
    "interface", "", "0", "1", "api", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "1", "b", "instance", "interface", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "2", "instance", "interface",
    "", "0", "2", "a", "instance", "interface", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "1", "b", "instance", "interface",
    "", "0", "1", "api", "instance", "interface", "", "0", "1", "r", "type", "resource",
    "2", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-nested" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x05\x08\x01\x01\x01\x00\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x05\x0a\x01\x01\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x0d\x02\x00\x01\x69\x05\x01\x00\x00\x01\x66\x01\x01\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x05\x03\x01\x00\x01\x66\x01\x0c\x05\x02\x00\x01\x69\x01\x05\x6f\x75\x74\x65\x72",
    source_id="inline-nested.wasm",
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
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (instance $i (export \"f\" (func $f))) (alias export $i \"f\" (func $out)) (instance $outer (export \"api\" (instance $i))) (export \"i\" (instance $outer)) (export \"f\" (func $out)))",
    source_id="inline-nested.wat",
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
    "world", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "2", "i", "instance", "interface", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "none", "f", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    "instance", "interface", "", "0", "2", "i", "instance", "interface", "", "0",
    "1", "api", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "none", "f", "func", "function", "false", "1", "x",
    "scalar", "u32", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance module-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x07\x1e\x01\x41\x03\x00\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x66\x00\x00\x03\x00\x01\x6d\x00\x11\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x09\x01\x00\x00\x01\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="module-argument.wasm",
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
    "(component (core type $m (module (export \"f\" (func (param i32))))) (import \"m\" (core module $m (type $m))) (type $c (component (core type $m (module (export \"f\" (func (param i32))))) (import \"m\" (core module (type $m))) (export \"m\" (core module (type $m))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"m\" (core module $m)))) (export \"i\" (instance $i)))",
    source_id="module-argument.wat",
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
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "2",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "c",
    "component",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "1",
    "i",
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
    "i",
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
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance module-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x01\x60\x01\x7e\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x07\x1e\x01\x41\x03\x00\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x66\x00\x00\x03\x00\x01\x6d\x00\x11\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x09\x01\x00\x00\x01\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x34\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="module-wrong.wasm",
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
    "(component (core type $m (module (export \"f\" (func (param i64))))) (import \"m\" (core module $m (type $m))) (type $c (component (core type $m (module (export \"f\" (func (param i32))))) (import \"m\" (core module (type $m))) (export \"m\" (core module (type $m))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"m\" (core module $m)))) (export \"i\" (instance $i)))",
    source_id="module-wrong.wat",
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
test "runtime component instance resource-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x07\x27\x01\x41\x06\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x04\x00\x01\x72\x03\x00\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x03\x05\x0c\x01\x00\x00\x02\x01\x72\x03\x00\x01\x66\x01\x00\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x69\x05\x00\x00\x00\x36\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x10\x03\x04\x00\x01\x72\x01\x03\x6f\x77\x6e\x02\x01\x66\x03\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="resource-function.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $own (own $r)) (type $f (func (param \"x\" $own))) (import \"f\" (func $f (type $f))) (type $c (component (import \"r\" (type $r (sub resource))) (type $own (own $r)) (type $f (func (param \"x\" $own))) (import \"f\" (func (type $f))) (export \"r\" (type (eq $r))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $r)) (with \"f\" (func $f)))) (export \"r\" (type $r)) (export \"i\" (instance $i)))",
    source_id="resource-function.wat",
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
    "world", "", "0", "3", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "c", "component", "world", "", "0", "2",
    "r", "type", "resource", "1", "f", "func", "function", "false", "1", "x", "own",
    "1", "none", "2", "r", "type", "resource", "1", "f", "func", "function", "false",
    "1", "x", "own", "1", "none", "2", "r", "type", "resource", "0", "i", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "instance", "interface", "", "0", "2",
    "r", "type", "resource", "0", "i", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0",
    "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-function-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0f\x02\x00\x01\x72\x03\x01\x00\x05\x6f\x74\x68\x65\x72\x03\x01\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x03\x07\x27\x01\x41\x06\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x04\x00\x01\x72\x03\x00\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x04\x05\x0c\x01\x00\x00\x02\x01\x72\x03\x00\x01\x66\x01\x00\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x69\x05\x00\x00\x00\x3d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x17\x03\x05\x00\x01\x72\x01\x05\x6f\x74\x68\x65\x72\x02\x03\x6f\x77\x6e\x03\x01\x66\x04\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="resource-function-wrong.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (import \"other\" (type $other (sub resource))) (type $own (own $other)) (type $f (func (param \"x\" $own))) (import \"f\" (func $f (type $f))) (type $c (component (import \"r\" (type $r (sub resource))) (type $own (own $r)) (type $f (func (param \"x\" $own))) (import \"f\" (func (type $f))) (export \"r\" (type (eq $r))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $r)) (with \"f\" (func $f)))) (export \"r\" (type $r)) (export \"i\" (instance $i)))",
    source_id="resource-function-wrong.wat",
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
test "runtime component instance resource-instance-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x07\x21\x01\x41\x04\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x03\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x04\x00\x01\x72\x03\x00\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x0a\x01\x00\x00\x01\x03\x61\x70\x69\x05\x00\x0b\x0f\x02\x00\x03\x61\x70\x69\x05\x00\x00\x00\x01\x69\x05\x01\x00\x00\x2c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x69\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x0a\x05\x02\x00\x03\x61\x70\x69\x01\x01\x69",
    source_id="resource-instance-argument.wasm",
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
    "(component (type $i (instance (export \"r\" (type (sub resource))))) (import \"api\" (instance $api (type $i))) (type $c (component (type $i (instance (export \"r\" (type (sub resource))))) (import \"api\" (instance $api (type $i))) (alias export $api \"r\" (type $r)) (export \"r\" (type (eq $r))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"api\" (instance $api)))) (export \"api\" (instance $api)) (export \"i\" (instance $i)))",
    source_id="resource-instance-argument.wat",
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
    "world", "", "0", "2", "api", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "0", "c", "component", "world", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "1", "1", "r", "type", "resource",
    "1", "2", "api", "instance", "interface", "", "0", "1", "r", "type", "resource",
    "0", "i", "instance", "interface", "", "1", "r", "r", "", "1", "r", "type", "resource",
    "0", "instance", "interface", "", "0", "2", "api", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "0", "i", "instance", "interface", "", "1",
    "r", "r", "", "1", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-instance-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x07\x32\x01\x41\x04\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x03\x00\x03\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x04\x00\x01\x72\x03\x00\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x0a\x01\x00\x00\x01\x03\x61\x70\x69\x05\x00\x0b\x0f\x02\x00\x03\x61\x70\x69\x05\x00\x00\x00\x01\x69\x05\x01\x00\x00\x2c\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x69\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x0a\x05\x02\x00\x03\x61\x70\x69\x01\x01\x69",
    source_id="resource-instance-function.wasm",
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
    "(component (type $i (instance (export \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (export \"f\" (func (type $f))))) (import \"api\" (instance $api (type $i))) (type $c (component (type $i (instance (export \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (export \"f\" (func (type $f))))) (import \"api\" (instance $api (type $i))) (alias export $api \"r\" (type $r)) (export \"r\" (type (eq $r))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"api\" (instance $api)))) (export \"api\" (instance $api)) (export \"i\" (instance $i)))",
    source_id="resource-instance-function.wat",
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
    "world", "", "0", "2", "api", "instance", "interface", "", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "c", "component", "world", "", "0", "1", "api", "instance", "interface", "",
    "0", "2", "r", "type", "resource", "1", "f", "func", "function", "false", "1",
    "x", "own", "1", "none", "1", "r", "type", "resource", "1", "2", "api", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "i", "instance", "interface", "", "1",
    "r", "r", "", "1", "r", "type", "resource", "0", "instance", "interface", "",
    "0", "2", "api", "instance", "interface", "", "0", "2", "r", "type", "resource",
    "0", "f", "func", "function", "false", "1", "x", "own", "0", "none", "i", "instance",
    "interface", "", "1", "r", "r", "", "1", "r", "type", "resource", "0", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-fresh-alias" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x06\x01\x03\x00\x00\x01\x72\x0b\x13\x03\x00\x01\x72\x03\x01\x00\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x63\x01\x01\x72\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="resource-fresh-alias.wasm",
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
    "(component (type $c (component (export \"r\" (type (sub resource))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"r\" (type $r)) (export \"r\" (type $r)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-fresh-alias.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "r", "type",
    "resource", "0", "3", "r", "type", "resource", "1", "a", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "1", "b", "instance", "interface", "",
    "0", "1", "r", "type", "resource", "2", "instance", "interface", "", "0", "3",
    "r", "type", "resource", "1", "a", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "1", "b", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "2", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-fresh-capture" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="resource-fresh-capture.wasm",
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
    "(component (type $c (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-fresh-capture.wat",
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
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "2", "a", "instance", "interface", "", "0", "2", "r", "type", "resource", "1",
    "f", "func", "function", "false", "1", "x", "own", "1", "none", "b", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "2", "f", "func", "function",
    "false", "1", "x", "own", "2", "none", "instance", "interface", "", "0", "2",
    "a", "instance", "interface", "", "0", "2", "r", "type", "resource", "1", "f",
    "func", "function", "false", "1", "x", "own", "1", "none", "b", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "2", "f", "func", "function", "false",
    "1", "x", "own", "2", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance resource-fresh-wrong-use" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x01\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x09\x01\x00\x04\x6e\x65\x65\x64\x04\x02\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x3d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x03\x00\x01\x63\x01\x01\x72\x02\x04\x6e\x65\x65\x64\x01\x0b\x04\x02\x00\x01\x63\x01\x04\x6e\x65\x65\x64\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="resource-fresh-wrong-use.wasm",
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
    "(component (type $c (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"r\" (type $r)) (alias export $b \"f\" (func $f)) (type $need (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"need\" (component $need (type $need))) (instance (instantiate $need (with \"r\" (type $r)) (with \"f\" (func $f)))) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-fresh-wrong-use.wat",
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
test "runtime component instance resource-fresh-right-use" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x00\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x09\x01\x00\x04\x6e\x65\x65\x64\x04\x02\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x3d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x03\x00\x01\x63\x01\x01\x72\x02\x04\x6e\x65\x65\x64\x01\x0b\x04\x02\x00\x01\x63\x01\x04\x6e\x65\x65\x64\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    source_id="resource-fresh-right-use.wasm",
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
    "(component (type $c (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"r\" (type $r)) (alias export $a \"f\" (func $f)) (type $need (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"need\" (component $need (type $need))) (instance (instantiate $need (with \"r\" (type $r)) (with \"f\" (func $f)))) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-fresh-right-use.wat",
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
    "world", "", "0", "2", "c", "component", "world", "", "0", "0", "2", "r", "type",
    "resource", "0", "f", "func", "function", "false", "1", "x", "own", "0", "none",
    "need", "component", "world", "", "0", "2", "r", "type", "resource", "1", "f",
    "func", "function", "false", "1", "x", "own", "1", "none", "0", "2", "a", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "2", "f", "func", "function",
    "false", "1", "x", "own", "2", "none", "b", "instance", "interface", "", "0",
    "2", "r", "type", "resource", "3", "f", "func", "function", "false", "1", "x",
    "own", "3", "none", "instance", "interface", "", "0", "2", "a", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "2", "f", "func", "function", "false",
    "1", "x", "own", "2", "none", "b", "instance", "interface", "", "0", "2", "r",
    "type", "resource", "3", "f", "func", "function", "false", "1", "x", "own", "3",
    "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-missing-resource-name" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x05\x08\x01\x01\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-missing-resource-name.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func $f (type $f))) (instance $i (export \"f\" (func $f))) (export \"i\" (instance $i)))",
    source_id="inline-missing-resource-name.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "1", "i", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "1", "x", "own", "0", "none", "instance",
    "interface", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "1", "x", "own", "0", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-resource-name" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x05\x0d\x01\x01\x02\x00\x01\x72\x03\x00\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-resource-name.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func $f (type $f))) (instance $i (export \"r\" (type $r)) (export \"f\" (func $f))) (export \"i\" (instance $i)))",
    source_id="inline-resource-name.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "1", "i", "instance", "interface", "",
    "0", "2", "r", "type", "resource", "0", "f", "func", "function", "false", "1",
    "x", "own", "0", "none", "instance", "interface", "", "0", "1", "i", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-resource-name-after" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x05\x0d\x01\x01\x02\x00\x01\x66\x01\x00\x00\x01\x72\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-resource-name-after.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func $f (type $f))) (instance $i (export \"f\" (func $f)) (export \"r\" (type $r))) (export \"i\" (instance $i)))",
    source_id="inline-resource-name-after.wat",
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
    "world", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "x", "own", "0", "none", "1", "i", "instance", "interface", "",
    "0", "2", "f", "func", "function", "false", "1", "x", "own", "0", "none", "r",
    "type", "resource", "0", "instance", "interface", "", "0", "1", "i", "instance",
    "interface", "", "0", "2", "f", "func", "function", "false", "1", "x", "own",
    "0", "none", "r", "type", "resource", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance component-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x70\x04\x00\x07\x18\x01\x41\x03\x01\x41\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x70\x04\x00\x04\x00\x01\x70\x04\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x01\x01\x01\x70\x04\x00\x06\x06\x01\x04\x00\x00\x01\x70\x05\x07\x02\x00\x02\x00\x00\x02\x00\x0b\x17\x03\x00\x01\x69\x05\x00\x00\x00\x03\x6f\x6e\x65\x05\x01\x00\x00\x03\x74\x77\x6f\x05\x02\x00\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x70\x01\x01\x63\x01\x0c\x04\x03\x00\x01\x70\x01\x01\x63\x02\x02\x70\x32\x01\x0f\x05\x03\x00\x01\x69\x01\x03\x6f\x6e\x65\x02\x03\x74\x77\x6f",
    source_id="component-argument.wasm",
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
    "(component (type $p (component (export \"r\" (type (sub resource))))) (import \"p\" (component $p (type $p))) (type $c (component (type $p (component (export \"r\" (type (sub resource))))) (import \"p\" (component (type $p))) (export \"p\" (component (type $p))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"p\" (component $p)))) (alias export $i \"p\" (component $p2)) (instance $one (instantiate $p2)) (instance $two (instantiate $p2)) (export \"i\" (instance $i)) (export \"one\" (instance $one)) (export \"two\" (instance $two)))",
    source_id="component-argument.wat",
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
    "world", "", "0", "2", "p", "component", "world", "", "0", "0", "1", "r", "type",
    "resource", "0", "c", "component", "world", "", "0", "1", "p", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "1", "1", "p", "component", "world",
    "", "0", "0", "1", "r", "type", "resource", "1", "3", "i", "instance", "interface",
    "", "0", "1", "p", "component", "world", "", "0", "0", "1", "r", "type", "resource",
    "1", "one", "instance", "interface", "", "0", "1", "r", "type", "resource", "2",
    "two", "instance", "interface", "", "0", "1", "r", "type", "resource", "3", "instance",
    "interface", "", "0", "3", "i", "instance", "interface", "", "0", "1", "p", "component",
    "world", "", "0", "0", "1", "r", "type", "resource", "1", "one", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "2", "two", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "3", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance component-argument-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x70\x04\x00\x07\x18\x01\x41\x03\x01\x41\x01\x04\x00\x01\x72\x03\x01\x03\x00\x01\x70\x04\x00\x04\x00\x01\x70\x04\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x01\x01\x01\x70\x04\x00\x06\x06\x01\x04\x00\x00\x01\x70\x05\x07\x02\x00\x02\x00\x00\x02\x00\x0b\x17\x03\x00\x01\x69\x05\x00\x00\x00\x03\x6f\x6e\x65\x05\x01\x00\x00\x03\x74\x77\x6f\x05\x02\x00\x00\x38\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x70\x01\x01\x63\x01\x0c\x04\x03\x00\x01\x70\x01\x01\x63\x02\x02\x70\x32\x01\x0f\x05\x03\x00\x01\x69\x01\x03\x6f\x6e\x65\x02\x03\x74\x77\x6f",
    source_id="component-argument-wrong.wasm",
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
    "(component (type $p (component)) (import \"p\" (component $p (type $p))) (type $c (component (type $p (component (export \"r\" (type (sub resource))))) (import \"p\" (component (type $p))) (export \"p\" (component (type $p))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"p\" (component $p)))) (alias export $i \"p\" (component $p2)) (instance $one (instantiate $p2)) (instance $two (instantiate $p2)) (export \"i\" (instance $i)) (export \"one\" (instance $one)) (export \"two\" (instance $two)))",
    source_id="component-argument-wrong.wat",
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
test "runtime component instance type-argument" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="type-argument.wasm",
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
    source_id="type-argument.wat",
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
test "runtime component instance type-argument-wrong" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x77\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="type-argument-wrong.wasm",
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
    "(component (type $t (record (field \"x\" u64))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
    source_id="type-argument-wrong.wat",
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
test "runtime component instance inline-method" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0d\x02\x68\x00\x40\x01\x04\x73\x65\x6c\x66\x01\x01\x00\x0a\x12\x01\x00\x0d\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x67\x65\x74\x01\x02\x05\x19\x01\x01\x02\x00\x01\x72\x03\x00\x00\x0d\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x67\x65\x74\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x62\x02\x01\x66\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-method.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $b (borrow $r)) (type $f (func (param \"self\" $b))) (import \"[method]r.get\" (func $f (type $f))) (instance $i (export \"r\" (type $r)) (export \"[method]r.get\" (func $f))) (export \"i\" (instance $i)))",
    source_id="inline-method.wat",
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
test "runtime component instance inline-method-wrong-name" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x0d\x02\x68\x00\x40\x01\x04\x73\x65\x6c\x66\x01\x01\x00\x0a\x12\x01\x00\x0d\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x67\x65\x74\x01\x02\x05\x19\x01\x01\x02\x00\x01\x72\x03\x00\x00\x0d\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x73\x2e\x67\x65\x74\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x62\x02\x01\x66\x01\x05\x05\x01\x00\x01\x69",
    source_id="inline-method-wrong-name.wasm",
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
    "(component (import \"r\" (type $r (sub resource))) (type $b (borrow $r)) (type $f (func (param \"self\" $b))) (import \"[method]r.get\" (func $f (type $f))) (instance $i (export \"r\" (type $r)) (export \"[method]s.get\" (func $f))) (export \"i\" (instance $i)))",
    source_id="inline-method-wrong-name.wat",
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
test "runtime component instance resource-nested-use" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x41\x02\x01\x42\x01\x04\x00\x01\x72\x03\x01\x04\x00\x03\x61\x70\x69\x05\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0d\x02\x05\x00\x00\x03\x61\x70\x69\x03\x00\x02\x01\x72\x0b\x13\x03\x00\x01\x72\x03\x01\x00\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x63\x01\x01\x72\x01\x05\x04\x01\x00\x01\x63\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x61\x70\x69",
    source_id="resource-nested-use.wasm",
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
    "(component (type $c (component (type $i (instance (export \"r\" (type (sub resource))))) (export \"api\" (instance (type $i))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"api\" (instance $api)) (alias export $api \"r\" (type $r)) (export \"r\" (type $r)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    source_id="resource-nested-use.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "api", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "3", "r", "type", "resource",
    "1", "a", "instance", "interface", "", "0", "1", "api", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "1", "b", "instance", "interface", "",
    "0", "1", "api", "instance", "interface", "", "0", "1", "r", "type", "resource",
    "2", "instance", "interface", "", "0", "3", "r", "type", "resource", "1", "a",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "", "0",
    "1", "r", "type", "resource", "1", "b", "instance", "interface", "", "0", "1",
    "api", "instance", "interface", "", "0", "1", "r", "type", "resource", "2", "definitions",
    "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "runtime component instance inline-type-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x08\x01\x01\x01\x00\x01\x74\x03\x00\x07\x02\x01\x79",
    source_id="inline-type-future.wasm",
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
    "(component (instance (export \"t\" (type 0))) (type u32))",
    source_id="inline-type-future.wat",
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
test "runtime component instance inline-function-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x08\x01\x01\x01\x00\x01\x66\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x66",
    source_id="inline-function-future.wasm",
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
    "(component (instance (export \"f\" (func 0))) (type $f (func)) (import \"f\" (func (type $f))))",
    source_id="inline-function-future.wat",
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
test "runtime component instance module-future" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x09\x01\x01\x01\x00\x01\x6d\x00\x11\x00\x03\x03\x01\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d",
    source_id="module-future.wasm",
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
    "(component (instance (export \"m\" (core module 0))) (core type $m (module)) (import \"m\" (core module (type $m))))",
    source_id="module-future.wat",
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
test "runtime component instance type-argument-named" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="type-argument-named.wasm",
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
    source_id="type-argument-named.wat",
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
test "runtime component instance component-result-implements" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x26\x01\x41\x02\x01\x41\x02\x01\x42\x00\x03\x02\x03\x61\x70\x69\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x04\x00\x01\x70\x04\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    source_id="component-result-implements.wasm",
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
    "(component (type $c (component (type $p (component (type $i (instance)) (import \"api\" (implements \"test:dep/api\") (instance (type $i))))) (export \"p\" (component (type $p))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    source_id="component-result-implements.wat",
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
    "world", "", "0", "1", "c", "component", "world", "", "0", "0", "1", "p", "component",
    "world", "", "0", "1", "api", "instance", "interface", "test:dep/api", "0", "0",
    "0", "1", "i", "instance", "interface", "", "0", "1", "p", "component", "world",
    "", "0", "1", "api", "instance", "interface", "test:dep/api", "0", "0", "0",
    "instance", "interface", "", "0", "1", "i", "instance", "interface", "", "0",
    "1", "p", "component", "world", "", "0", "1", "api", "instance", "interface",
    "test:dep/api", "0", "0", "0", "definitions", "0",
  ]
  assert_eq(binary_projection(binary.unwrap()), expected)
  assert_eq(binary_projection(text.unwrap()), expected)
}
