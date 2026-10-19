///|
test "runtime instance composition empty" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component)) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:runtime", version: None, source: "dep.wasm", bytes, },
    ])
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "1", "c", "component", "world", "", "0", "0", "0", "1", "out", "instance",
      "interface", "", "0", "1", "i", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "runtime instance composition inline-empty" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x05\x03\x01\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (instance $i) (export \"i\" (instance $i)))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:runtime", version: None, source: "dep.wasm", bytes, },
    ])
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "0", "1", "out", "instance", "interface", "", "0", "1", "i", "instance", "interface",
      "", "0", "0",
    ])
  }
}

///|
test "runtime instance composition function" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x07\x17\x01\x41\x03\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x01\x00\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x08\x03\x02\x00\x01\x66\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $f (func (param \"x\" u32))) (import \"f\" (func $f (type $f))) (type $c (component (type $f (func (param \"x\" u32))) (import \"f\" (func (type $f))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"f\" (func $f)))) (alias export $i \"f\" (func $out)) (export \"out\" (func $out)))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:runtime", version: None, source: "dep.wasm", bytes, },
    ])
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "2", "f", "func", "function", "false", "1", "x", "scalar", "u32", "none", "c",
      "component", "world", "", "0", "1", "f", "func", "function", "false", "1",
      "x", "scalar", "u32", "none", "1", "f", "func", "function", "false", "1", "x",
      "scalar", "u32", "none", "1", "out", "instance", "interface", "", "0", "1",
      "out", "func", "function", "false", "1", "x", "scalar", "u32", "none",
    ])
  }
}

///|
test "runtime instance composition resource-fresh" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x72\x03\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62"
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (export \"r\" (type (sub resource))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:runtime", version: None, source: "dep.wasm", bytes, },
    ])
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "1", "c", "component", "world", "", "0", "0", "1", "r", "type", "resource",
      "0", "1", "out", "instance", "interface", "", "0", "2", "a", "instance", "interface",
      "", "0", "1", "r", "type", "resource", "1", "b", "instance", "interface", "",
      "0", "1", "r", "type", "resource", "2",
    ])
  }
}

///|
test "runtime instance composition function-wrong" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x40\x01\x01\x78\x79\x01\x00\x40\x01\x01\x78\x77\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x07\x17\x01\x41\x03\x01\x40\x01\x01\x78\x79\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x06\x06\x01\x01\x00\x00\x01\x66\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x01\x00\x00\x3a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x01\x02\x00\x01\x66\x01\x03\x6f\x75\x74\x01\x0f\x03\x03\x00\x01\x66\x01\x05\x77\x72\x6f\x6e\x67\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:runtime", version: None, source: "dep.wasm", bytes, },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "runtime instance composition resource-fresh-wrong-use" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x41\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x01\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x09\x01\x00\x04\x6e\x65\x65\x64\x04\x02\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x3d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0e\x03\x03\x00\x01\x63\x01\x01\x72\x02\x04\x6e\x65\x65\x64\x01\x0b\x04\x02\x00\x01\x63\x01\x04\x6e\x65\x65\x64\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:runtime", version: None, source: "dep.wasm", bytes, },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}
