///|
test "runtime value composition export-instance" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (export \"i\" (instance $i)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "1", "c", "component", "world", "", "0", "0", "1", "v", "value", "scalar",
      "u32", "1", "out", "instance", "interface", "", "0", "1", "i", "instance",
      "interface", "", "0", "1", "v", "value", "scalar", "u32",
    ])
  }
}

///|
test "runtime value composition alias-value" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x41\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x04\x01\x00\x00\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (export \"v\" (value u32)))) (import \"c\" (component (type $c))) (instance $i (instantiate 0)) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "1", "c", "component", "world", "", "0", "0", "1", "v", "value", "scalar",
      "u32", "1", "out", "instance", "interface", "", "0", "1", "v", "value", "scalar",
      "u32",
    ])
  }
}

///|
test "runtime value composition argument" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x07\x09\x01\x41\x01\x03\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value $v u32)) (type $c (component (import \"v\" (value u32)))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "2", "v", "value", "scalar", "u32", "c", "component", "world", "", "0", "1",
      "v", "value", "scalar", "u32", "0", "1", "out", "instance", "interface", "",
      "0", "1", "i", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "runtime value composition inline" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x01\x01\x00\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value $v u32)) (instance $i (export \"v\" (value $v))) (export \"i\" (instance $i)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "1", "v", "value", "scalar", "u32", "1", "out", "instance", "interface", "",
      "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value", "scalar",
      "u32",
    ])
  }
}

///|
test "runtime value composition resource-substitution" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x07\x18\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x0c\x01\x00\x00\x02\x01\x72\x03\x00\x01\x76\x02\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x09\x01\x00\x03\x6f\x75\x74\x02\x01\x00\x00\x36\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x02\x02\x00\x01\x76\x01\x03\x6f\x75\x74\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value $v (type $o))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))) (export \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"r\" (type $r)) (with \"v\" (value $v)))) (alias export $i \"v\" (value $out)) (export \"out\" (value $out)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "3", "r", "type", "resource", "0", "v", "value", "own", "0", "c", "component",
      "world", "", "0", "2", "r", "type", "resource", "1", "v", "value", "own", "1",
      "1", "v", "value", "own", "1", "1", "out", "instance", "interface", "", "0",
      "1", "out", "value", "own", "0",
    ])
  }
}

///|
test "runtime value composition named-value" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x07\x16\x01\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x02\x05\x08\x01\x00\x00\x01\x01\x74\x03\x01\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x0f\x03\x03\x00\x01\x74\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (export $named \"t\" (type $t)) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $named)))) (alias export $i \"v\" (value $v)) (export \"v\" (value $v)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "1", "c", "component", "world", "", "0", "1", "t", "type", "record", "1", "x",
      "scalar", "u32", "1", "v", "value", "record", "1", "x", "scalar", "u32", "1",
      "out", "instance", "interface", "", "0", "2", "t", "type", "record", "1", "x",
      "scalar", "u32", "v", "value", "record", "1", "x", "scalar", "u32",
    ])
  }
}

///|
test "runtime value composition anonymous-private" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x72\x01\x01\x78\x79\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x74\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
  let text = @verifier.decode_wat_component_package(
    "(component (type $t (record (field \"x\" u32))) (type $c (component (type $t (record (field \"x\" u32))) (import \"t\" (type $it (eq $t))) (export \"v\" (value (type $it))))) (import \"c\" (component $c (type $c))) (instance $i (instantiate $c (with \"t\" (type $t)))) )",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "1", "c", "component", "world", "", "0", "1", "t", "type", "record", "1", "x",
      "scalar", "u32", "1", "v", "value", "record", "1", "x", "scalar", "u32", "1",
      "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "runtime value composition anonymous-value" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x72\x01\x01\x78\x79\x41\x03\x01\x72\x01\x01\x78\x79\x03\x00\x01\x74\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x08\x01\x00\x00\x01\x01\x74\x03\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x2e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x08\x03\x02\x00\x01\x74\x01\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
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
test "runtime value composition argument-twice" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x07\x09\x01\x41\x01\x03\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x03\x01\x00\x01\x63\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69"
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
test "runtime value composition fresh-resource-argument" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x70\x04\x00\x07\x12\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x10\x03\x03\x00\x00\x01\x72\x03\x00\x01\x01\x72\x02\x00\x00\x01\x76\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x02\x01\x76\x02\x00\x0b\x0a\x01\x00\x04\x75\x73\x65\x64\x05\x02\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x10\x03\x04\x00\x01\x70\x01\x01\x63\x02\x02\x72\x61\x03\x02\x72\x62\x01\x08\x04\x02\x00\x01\x70\x01\x01\x63\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65"
  let text = @verifier.decode_wat_component_package(
    "(component (type $p (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (export \"v\" (value (type $o))))) (import \"p\" (component $p (type $p))) (type $c (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))))) (import \"c\" (component $c (type $c))) (instance $a (instantiate $p)) (instance $b (instantiate $p)) (alias export $a \"r\" (type $ra)) (alias export $b \"r\" (type $rb)) (alias export $a \"v\" (value $v)) (instance $use (instantiate $c (with \"r\" (type $ra)) (with \"v\" (value $v)))) (export \"used\" (instance $use)))",
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
    assert_eq(source_runtime_projection(result.unwrap()), [
      "2", "p", "component", "world", "", "0", "0", "2", "r", "type", "resource",
      "0", "v", "value", "own", "0", "c", "component", "world", "", "0", "2", "r",
      "type", "resource", "1", "v", "value", "own", "1", "0", "1", "out", "instance",
      "interface", "", "0", "1", "used", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "runtime value composition crossed-fresh-resource-argument" {
  let source = "package test:app; let i = new test:runtime {...}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x70\x04\x00\x07\x12\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x10\x03\x03\x00\x00\x01\x72\x03\x00\x01\x01\x72\x02\x00\x00\x01\x76\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x03\x01\x76\x02\x00\x0b\x0a\x01\x00\x04\x75\x73\x65\x64\x05\x02\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x10\x03\x04\x00\x01\x70\x01\x01\x63\x02\x02\x72\x61\x03\x02\x72\x62\x01\x08\x04\x02\x00\x01\x70\x01\x01\x63\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65"
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
