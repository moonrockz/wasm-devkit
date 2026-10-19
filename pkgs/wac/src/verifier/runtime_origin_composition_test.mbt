///|
test "runtime origin composition named-export" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type 1)))) (export \"i\" (instance $i)))",
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
      "1", "c", "component", "world", "", "0", "1", "t", "type", "record", "1", "x",
      "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f",
      "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
      "none", "1", "out", "instance", "interface", "", "0", "2", "t", "type", "record",
      "1", "x", "scalar", "u32", "i", "instance", "interface", "", "0", "2", "t",
      "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
      "1", "x", "record", "1", "x", "scalar", "u32", "none",
    ])
  }
}

///|
test "runtime origin composition named-import" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (import \"t\" (type $named (eq $t))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $named)))) (export \"i\" (instance $i)))",
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
      "2", "t", "type", "record", "1", "x", "scalar", "u32", "c", "component", "world",
      "", "0", "1", "t", "type", "record", "1", "x", "scalar", "u32", "2", "t", "type",
      "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1",
      "x", "record", "1", "x", "scalar", "u32", "none", "1", "out", "instance", "interface",
      "", "0", "1", "i", "instance", "interface", "", "0", "2", "t", "type", "record",
      "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
      "1", "x", "scalar", "u32", "none",
    ])
  }
}

///|
test "runtime origin composition instance-alias" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x01\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x74\x03\x00\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x74\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x01\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0d\x03\x03\x00\x03\x61\x70\x69\x01\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x0a\x05\x02\x00\x03\x61\x70\x69\x01\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $api (instance (type $t (record (field \"x\" u32))) (export \"t\" (type (eq $t))))) (import \"api\" (instance $api (type $api))) (alias export $api \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (export \"i\" (instance $i)))",
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
      "2", "api", "instance", "interface", "", "0", "1", "t", "type", "record", "1",
      "x", "scalar", "u32", "c", "component", "world", "", "0", "1", "t", "type",
      "record", "1", "x", "scalar", "u32", "2", "t", "type", "record", "1", "x",
      "scalar", "u32", "f", "func", "function", "false", "1", "x", "record", "1",
      "x", "scalar", "u32", "none", "1", "out", "instance", "interface", "", "0",
      "1", "i", "instance", "interface", "", "1", "t", "t", "", "2", "t", "type",
      "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1",
      "x", "record", "1", "x", "scalar", "u32", "none",
    ])
  }
}

///|
test "runtime origin composition anonymous-private" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) )",
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
      "1", "c", "component", "world", "", "0", "1", "t", "type", "record", "1", "x",
      "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f",
      "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
      "none", "1", "out", "instance", "interface", "", "0", "1", "t", "type", "record",
      "1", "x", "scalar", "u32",
    ])
  }
}

///|
test "runtime origin composition anonymous-export" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
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
test "runtime origin composition anonymous-function-ascribed" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x25\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x74\x03\x00\x01\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x01\x00\x00\x01\x66\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0b\x09\x01\x00\x01\x66\x01\x00\x01\x01\x03\x00\x32\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x0c\x03\x03\x00\x01\x74\x02\x01\x63\x03\x02\x66\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (export \"t\" (type (eq $it))) (export \"f\" (func (type $f))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) (alias export $i \"f\" (func $f)) (type $ft (func (param \"x\" 1))) (export \"f\" (func $f) (func (type $ft))))",
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
      "1", "c", "component", "world", "", "0", "1", "t", "type", "record", "1", "x",
      "scalar", "u32", "2", "t", "type", "record", "1", "x", "scalar", "u32", "f",
      "func", "function", "false", "1", "x", "record", "1", "x", "scalar", "u32",
      "none", "1", "out", "instance", "interface", "", "0", "2", "t", "type", "record",
      "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "x", "record",
      "1", "x", "scalar", "u32", "none",
    ])
  }
}

///|
test "runtime origin composition named-export-nested" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x36\x01\x41\x05\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x01\x42\x03\x02\x03\x02\x01\x01\x01\x40\x01\x01\x78\x00\x01\x00\x04\x00\x01\x66\x01\x01\x04\x00\x03\x6f\x75\x74\x05\x03\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (export \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (type $f (func (param \"x\" $it))) (type $out (instance (alias outer 1 $it (type $t)) (type $f (func (param \"x\" $t))) (export \"f\" (func (type $f))))) (export \"out\" (instance (type $out))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type 1)))) (export \"i\" (instance $i)))",
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
      "1", "c", "component", "world", "", "0", "1", "t", "type", "record", "1", "x",
      "scalar", "u32", "1", "out", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "1", "x", "record", "1", "x", "scalar", "u32", "none",
      "1", "out", "instance", "interface", "", "0", "2", "t", "type", "record", "1",
      "x", "scalar", "u32", "i", "instance", "interface", "", "0", "1", "out", "instance",
      "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "record",
      "1", "x", "scalar", "u32", "none",
    ])
  }
}
