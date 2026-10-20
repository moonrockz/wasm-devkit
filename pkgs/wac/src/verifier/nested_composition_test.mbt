///|
test "nested composition empty" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "1", "i", "instance", "interface",
      "", "0", "0",
    ])
  }
}

///|
test "nested composition function" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x43\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x05\x08\x01\x00\x00\x01\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x66\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (type $f (func)) (import \"f\" (func $f (type $f))) (export \"f\" (func $f))) (type $f (func)) (import \"f\" (func $f (type $f))) (instance $i (instantiate $c (with \"f\" (func $f)))) (export \"i\" (instance $i)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "1", "f", "func", "function", "false", "0", "none", "1", "out", "instance",
      "interface", "", "0", "1", "i", "instance", "interface", "", "0", "1", "f",
      "func", "function", "false", "0", "none",
    ])
  }
}

///|
test "nested composition value" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x35\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x02\x01\x00\x01\x76\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (import \"v\" (value $v u32)) (export \"v\" (value $v))) (import \"v\" (value $v u32)) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
test "nested composition local-resource" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x05\x07\x02\x00\x00\x00\x00\x00\x00\x0b\x0d\x02\x00\x01\x61\x05\x00\x00\x00\x01\x62\x05\x01\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (type $r (resource (rep i32))) (export \"r\" (type $r))) (instance $a (instantiate $c)) (instance $b (instantiate $c)) (export \"a\" (instance $a)) (export \"b\" (instance $b)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "2", "a", "instance", "interface",
      "", "0", "1", "r", "type", "resource", "0", "b", "instance", "interface", "",
      "0", "1", "r", "type", "resource", "1",
    ])
  }
}

///|
test "nested composition outer-record" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x79\x72\x01\x01\x78\x00\x04\x34\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x01\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x74\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x75\x01\x01\x74\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (type $u u32) (type $t (record (field \"x\" $u))) (component $c (alias outer 1 $t (type $t)) (export \"t\" (type $t))) (instance $i (instantiate $c)) (export \"i\" (instance $i)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "1", "i", "instance", "interface",
      "", "0", "1", "t", "type", "record", "1", "x", "scalar", "u32",
    ])
  }
}

///|
test "nested composition outer-component" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x21\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x06\x05\x66\x69\x72\x73\x74\x04\x46\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x04\x02\x01\x00\x05\x04\x01\x00\x00\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x07\x06\x73\x65\x63\x6f\x6e\x64\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x11\x04\x02\x00\x05\x66\x69\x72\x73\x74\x01\x06\x73\x65\x63\x6f\x6e\x64\x01\x05\x05\x01\x00\x01\x69",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $first) (component $second (alias outer 1 $first (component $c)) (instance $i (instantiate $c)) (export \"i\" (instance $i))) (instance $i (instantiate $second)) (export \"i\" (instance $i)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "1", "i", "instance", "interface",
      "", "0", "1", "i", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "nested composition export-nested-component" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x4c\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x1d\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x13\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x62\x0b\x07\x01\x00\x01\x62\x04\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x61\x01\x05\x04\x01\x00\x01\x62\x05\x04\x01\x00\x00\x00\x06\x06\x01\x04\x00\x00\x01\x62\x05\x04\x01\x00\x01\x00\x0b\x07\x01\x00\x01\x6a\x05\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x04\x02\x00\x01\x61\x01\x01\x62\x01\x08\x05\x02\x00\x01\x69\x01\x01\x6a",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $a (component $b) (export \"b\" (component $b))) (instance $i (instantiate $a)) (alias export $i \"b\" (component $b)) (instance $j (instantiate $b)) (export \"j\" (instance $j)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "1", "j", "instance", "interface",
      "", "0", "0",
    ])
  }
}

///|
test "nested composition crossed-local-resource" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xb0\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x3e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x72\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x6f\x03\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x01\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x49\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
test "nested composition matched-local-resource" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xb0\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x69\x01\x40\x01\x01\x78\x02\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x03\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x3e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x12\x03\x04\x00\x01\x72\x01\x05\x6e\x61\x6d\x65\x64\x02\x01\x6f\x03\x01\x66\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x01\x00\x00\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x49\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x0d\x05\x03\x00\x01\x61\x01\x01\x62\x02\x03\x75\x73\x65",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (type $r (resource (rep i32))) (export $named \"r\" (type $r)) (type $o (own $named)) (type $f (func (param \"x\" $o))) (core module $m (func (export \"f\") (param i32))) (core instance $m (instantiate $m)) (func $f (type $f) (canon lift (core func $m \"f\"))) (export \"f\" (func $f)))(type $consumer (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"consumer\" (component $consumer (type $consumer)))(instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"r\" (type $ra)) (alias export $a \"f\" (func $fb)) (instance $use (instantiate $consumer (with \"r\" (type $ra)) (with \"f\" (func $fb)))))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "1", "consumer", "component", "world", "", "0", "2", "r", "type", "resource",
      "0", "f", "func", "function", "false", "1", "x", "own", "0", "none", "0", "1",
      "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "nested composition crossed-nested-local-resource" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xbb\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x03\x3f\x7f\x00\x69\x00\x40\x01\x01\x78\x01\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x02\x05\x0d\x01\x01\x02\x00\x01\x72\x03\x00\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x09\x05\x01\x00\x05\x69\x6e\x6e\x65\x72\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x1d\x04\x05\x00\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x01\x05\x69\x6e\x6e\x65\x72\x03\x00\x02\x01\x72\x01\x00\x03\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x51\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x15\x05\x05\x00\x01\x61\x01\x01\x62\x02\x02\x61\x69\x03\x02\x62\x69\x04\x03\x75\x73\x65",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
test "nested composition matched-nested-local-resource" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\xbb\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x03\x3f\x7f\x00\x69\x00\x40\x01\x01\x78\x01\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x08\x06\x01\x00\x00\x00\x00\x02\x05\x0d\x01\x01\x02\x00\x01\x72\x03\x00\x00\x01\x66\x01\x00\x0b\x0b\x01\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x00\x00\x42\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x6d\x01\x05\x01\x01\x00\x01\x66\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66\x01\x09\x05\x01\x00\x05\x69\x6e\x6e\x65\x72\x07\x1a\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x04\x00\x05\x07\x02\x00\x00\x00\x00\x00\x00\x06\x1d\x04\x05\x00\x00\x05\x69\x6e\x6e\x65\x72\x05\x00\x01\x05\x69\x6e\x6e\x65\x72\x03\x00\x02\x01\x72\x01\x00\x02\x01\x66\x05\x0c\x01\x00\x01\x02\x01\x72\x03\x01\x01\x66\x01\x00\x00\x51\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x01\x01\x00\x02\x66\x62\x01\x10\x03\x02\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x02\x72\x61\x01\x0f\x04\x02\x00\x01\x63\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x15\x05\x05\x00\x01\x61\x01\x01\x62\x02\x02\x61\x69\x03\x02\x62\x69\x04\x03\x75\x73\x65",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (type $r (resource (rep i32)))  (type $o (own $r)) (type $f (func (param \"x\" $o))) (core module $m (func (export \"f\") (param i32))) (core instance $m (instantiate $m)) (func $f (type $f) (canon lift (core func $m \"f\"))) (instance $inner (export \"r\" (type $r)) (export \"f\" (func $f))) (export \"inner\" (instance $inner)))(type $consumer (component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (type $f (func (param \"x\" $o))) (import \"f\" (func (type $f))))) (import \"consumer\" (component $consumer (type $consumer)))(instance $a (instantiate $c)) (instance $b (instantiate $c)) (alias export $a \"inner\" (instance $ai)) (alias export $b \"inner\" (instance $bi)) (alias export $ai \"r\" (type $ra)) (alias export $ai \"f\" (func $fb)) (instance $use (instantiate $consumer (with \"r\" (type $ra)) (with \"f\" (func $fb)))))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "1", "consumer", "component", "world", "", "0", "2", "r", "type", "resource",
      "0", "f", "func", "function", "false", "1", "x", "own", "0", "none", "0", "1",
      "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "nested composition component-annotation" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x07\x09\x01\x41\x01\x04\x00\x01\x72\x03\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x01\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x05\x04\x01\x00\x01\x63",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (type $r (resource (rep i32))) (export \"r\" (type $r))) (type $expected (component (export \"r\" (type (sub resource))))) (export \"c\" (component $c) (component (type $expected))))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "1", "c", "component", "world",
      "", "0", "0", "1", "r", "type", "resource", "0",
    ])
  }
}

///|
test "nested composition component-annotation-missing" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x33\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x03\x01\x00\x01\x72\x07\x0d\x01\x41\x01\x04\x00\x05\x6f\x74\x68\x65\x72\x03\x01\x0b\x09\x01\x00\x01\x63\x04\x00\x01\x04\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x01\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x05\x04\x01\x00\x01\x63",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
test "nested composition value-grandchild" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let data : Array[Byte] = []
  for
    part in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x84\x01\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x35\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x64\x01\x05\x02\x01\x00\x01\x76\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x28\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x64\x01\x05\x05\x01\x00\x01\x69\x0a\x06\x01\x00\x01\x76\x02\x79\x05\x08\x01\x00\x00\x01\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76\x01\x05\x04\x01\x00\x01\x63\x01\x05\x05\x01\x00\x01\x69",
    ] {
    for byte in part {
      data.push(byte)
    }
  }
  let bytes = Bytes::from_array(data)
  let text = @verifier.decode_wat_component_package(
    [
      "(component (component $c (component $d (import \"v\" (value $v u32)) (export \"v\" (value $v))) (import \"v\" (value $v u32)) (instance $i (instantiate $d (with \"v\" (value $v)))) (export \"i\" (instance $i))) (import \"v\" (value $v u32)) (instance $i (instantiate $c (with \"v\" (value $v)))) (export \"i\" (instance $i)))",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "i", "instance", "interface", "", "0", "1", "i", "instance", "interface",
      "", "0", "1", "v", "value", "scalar", "u32",
    ])
  }
}

///|
test "nested composition http-0.2.0" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let bytes = http_component_0_2_0()
  let text = @verifier.decode_wat_component_package(
    [
      "(component\n  (type (;0;)\n    (instance\n      (type (;0;) (list u8))\n      (type (;1;) (func (param \"len\" u64) (result 0)))\n      (export (;0;) \"get-random-bytes\" (func (type 1)))\n      (type (;2;) (func (result u64)))\n      (export (;1;) \"get-random-u64\" (func (type 2)))\n    )\n  )\n  (import \"wasi:random/random@0.2.0\" (instance (;0;) (type 0)))\n  (type (;1;)\n    (instance\n      (export (;0;) \"error\" (type (sub resource)))\n      (type (;1;) (borrow 0))\n      (type (;2;) (func (param \"self\" 1) (result string)))\n      (export (;0;) \"[method]error.to-debug-string\" (func (type 2)))\n    )\n  )\n  (import \"wasi:io/error@0.2.0\" (instance (;1;) (type 1)))\n  (type (;2;)\n    (instance\n      (export (;0;) \"pollable\" (type (sub resource)))\n      (type (;1;) (borrow 0))\n      (type (;2;) (func (param \"self\" 1) (result bool)))\n      (export (;0;) \"[method]pollable.ready\" (func (type 2)))\n      (type (;3;) (func (param \"self\" 1)))\n      (export (;1;) \"[method]pollable.block\" (func (type 3)))\n      (type (;4;) (list 1))\n      (type (;5;) (list u32))\n      (type (;6;) (func (param \"in\" 4) (result 5)))\n      (export (;2;) \"poll\" (func (type 6)))\n    )\n  )\n  (import \"wasi:io/poll@0.2.0\" (instance (;2;) (type 2)))\n  (alias export 1 \"error\" (type (;3;)))\n  (alias export 2 \"pollable\" (type (;4;)))\n  (type (;5;)\n    (instance\n      (export (;0;) \"input-stream\" (type (sub resource)))\n      (alias outer 1 3 (type (;1;)))\n      (export (;2;) \"error\" (type (eq 1)))\n      (type (;3;) (own 2))\n      (type (;4;) (variant (case \"last-operation-failed\" 3) (case \"closed\")))\n      (export (;5;) \"stream-error\" (type (eq 4)))\n      (alias outer 1 4 (type (;6;)))\n      (export (;7;) \"pollable\" (type (eq 6)))\n      (export (;8;) \"output-stream\" (type (sub resource)))\n      (type (;9;) (borrow 0))\n      (type (;10;) (list u8))\n      (type (;11;) (result 10 (error 5)))\n      (type (;12;) (func (param \"self\" 9) (param \"len\" u64) (result 11)))\n      (export (;0;) \"[method]input-stream.read\" (func (type 12)))\n      (export (;1;) \"[method]input-stream.blocking-read\" (func (type 12)))\n      (type (;13;) (result u64 (error 5)))\n      (type (;14;) (func (param \"self\" 9) (param \"len\" u64) (result 13)))\n      (export (;2;) \"[method]input-stream.skip\" (func (type 14)))\n      (export (;3;) \"[method]input-stream.blocking-skip\" (func (type 14)))\n      (type (;15;) (own 7))\n      (type (;16;) (func (param \"self\" 9) (result 15)))\n      (export (;4;) \"[method]input-stream.subscribe\" (func (type 16)))\n      (type (;17;) (borrow 8))\n      (type (;18;) (func (param \"self\" 17) (result 13)))\n      (export (;5;) \"[method]output-stream.check-write\" (func (type 18)))\n      (type (;19;) (result (error 5)))\n      (type (;20;) (func (param \"self\" 17) (param \"contents\" 10) (result 19)))\n      (export (;6;) \"[method]output-stream.write\" (func (type 20)))\n      (export (;7;) \"[method]output-stream.blocking-write-and-flush\" (func (type 20)))\n      (type (;21;) (func (param \"self\" 17) (result 19)))\n      (export (;8;) \"[method]output-stream.flush\" (func (type 21)))\n      (export (;9;) \"[method]output-stream.blocking-flush\" (func (type 21)))\n      (type (;22;) (func (param \"self\" 17) (result 15)))\n      (export (;10;) \"[method]output-stream.subscribe\" (func (type 22)))\n      (type (;23;) (func (param \"self\" 17) (param \"len\" u64) (result 19)))\n      (export (;11;) \"[method]output-stream.write-zeroes\" (func (type 23)))\n      (export (;12;) \"[method]output-stream.blocking-write-zeroes-and-flush\" (func (type 23)))\n      (type (;24;) (func (param \"self\" 17) (param \"src\" 9) (param \"len\" u64) (result 13)))\n      (export (;13;) \"[method]output-stream.splice\" (func (type 24)))\n      (export (;14;) \"[method]output-stream.blocking-splice\" (func (type 24)))\n    )\n  )\n  (import \"wasi:io/streams@0.2.0\" (instance (;3;) (type 5)))\n  (alias export 3 \"output-stream\" (type (;6;)))\n  (type (;7;)\n    (instance\n      (alias outer 1 6 (type (;0;)))\n      (export (;1;) \"output-stream\" (type (eq 0)))\n      (type (;2;) (own 1))\n      (type (;3;) (func (result 2)))\n      (export (;0;) \"get-stdout\" (func (type 3)))\n    )\n  )\n  (import \"wasi:cli/stdout@0.2.0\" (instance (;4;) (type 7)))\n  (alias export 3 \"output-stream\" (type (;8;)))\n  (type (;9;)\n    (instance\n      (alias outer 1 8 (type (;0;)))\n      (export (;1;) \"output-stream\" (type (eq 0)))\n      (type (;2;) (own 1))\n      (type (;3;) (func (result 2)))\n      (export (;0;) \"get-stderr\" (func (type 3)))\n    )\n  )\n  (import \"wasi:cli/stderr@0.2.0\" (instance (;5;) (type 9)))\n  (alias export 3 \"input-stream\" (type (;10;)))\n  (type (;11;)\n    (instance\n      (alias outer 1 10 (type (;0;)))\n      (export (;1;) \"input-stream\" (type (eq 0)))\n      (type (;2;) (own 1))\n      (type (;3;) (func (result 2)))\n      (export (;0;) \"get-stdin\" (func (type 3)))\n    )\n  )\n  (import \"wasi:cli/stdin@0.2.0\" (instance (;6;) (type 11)))\n  (alias export 2 \"pollable\" (type (;12;)))\n  (type (;13;)\n    (instance\n      (type (;0;) u64)\n      (export (;1;) \"instant\" (type (eq 0)))\n      (type (;2;) u64)\n      (export (;3;) \"duration\" (type (eq 2)))\n      (alias outer 1 12 (type (;4;)))\n      (export (;5;) \"pollable\" (type (eq 4)))\n      (type (;6;) (func (result 1)))\n      (export (;0;) \"now\" (func (type 6)))\n      (type (;7;) (func (result 3)))\n      (export (;1;) \"resolution\" (func (type 7)))\n      (type (;8;) (own 5))\n      (type (;9;) (func (param \"when\" 1) (result 8)))\n      (export (;2;) \"subscribe-instant\" (func (type 9)))\n      (type (;10;) (func (param \"when\" 3) (result 8)))\n      (export (;3;) \"subscribe-duration\" (func (type 10)))\n    )\n  )\n  (import \"wasi:clocks/monotonic-clock@0.2.0\" (instance (;7;) (type 13)))\n  (alias export 7 \"duration\" (type (;14;)))\n  (alias export 3 \"input-stream\" (type (;15;)))\n  (alias export 2 \"pollable\" (type (;16;)))\n  (alias export 3 \"output-stream\" (type (;17;)))\n  (alias export 1 \"error\" (type (;18;)))\n  (type (;19;)\n    (instance\n      (export (;0;) \"fields\" (type (sub resource)))\n      (type (;1;) string)\n      (export (;2;) \"field-key\" (type (eq 1)))\n      (type (;3;) (list u8))\n      (export (;4;) \"field-value\" (type (eq 3)))\n      (type (;5;) (variant (case \"invalid-syntax\") (case \"forbidden\") (case \"immutable\")))\n      (export (;6;) \"header-error\" (type (eq 5)))\n      (export (;7;) \"incoming-request\" (type (sub resource)))\n      (type (;8;) (variant (case \"get\") (case \"head\") (case \"post\") (case \"put\") (case \"delete\") (case \"connect\") (case \"options\") (case \"trace\") (case \"patch\") (case \"other\" string)))\n      (export (;9;) \"method\" (type (eq 8)))\n      (type (;10;) (variant (case \"HTTP\") (case \"HTTPS\") (case \"other\" string)))\n      (export (;11;) \"scheme\" (type (eq 10)))\n      (export (;12;) \"headers\" (type (eq 0)))\n      (export (;13;) \"incoming-body\" (type (sub resource)))\n      (export (;14;) \"outgoing-request\" (type (sub resource)))\n      (export (;15;) \"outgoing-body\" (type (sub resource)))\n      (export (;16;) \"request-options\" (type (sub resource)))\n      (alias outer 1 14 (type (;17;)))\n      (export (;18;) \"duration\" (type (eq 17)))\n      (export (;19;) \"response-outparam\" (type (sub resource)))\n      (export (;20;) \"outgoing-response\" (type (sub resource)))\n      (type (;21;) (option string))\n      (type (;22;) (option u16))\n      (type (;23;) (record (field \"rcode\" 21) (field \"info-code\" 22)))\n      (export (;24;) \"DNS-error-payload\" (type (eq 23)))\n      (type (;25;) (option u8))\n      (type (;26;) (record (field \"alert-id\" 25) (field \"alert-message\" 21)))\n      (export (;27;) \"TLS-alert-received-payload\" (type (eq 26)))\n      (type (;28;) (option u32))\n      (type (;29;) (record (field \"field-name\" 21) (field \"field-size\" 28)))\n      (export (;30;) \"field-size-payload\" (type (eq 29)))\n      (type (;31;) (option u64))\n      (type (;32;) (option 30))\n      (type (;33;) (variant (case \"DNS-timeout\") (case \"DNS-error\" 24) (case \"destination-not-found\") (case \"destination-unavailable\") (case \"destination-IP-prohibited\") (case \"destination-IP-unroutable\") (case \"conne",
      "ction-refused\") (case \"connection-terminated\") (case \"connection-timeout\") (case \"connection-read-timeout\") (case \"connection-write-timeout\") (case \"connection-limit-reached\") (case \"TLS-protocol-error\") (case \"TLS-certificate-error\") (case \"TLS-alert-received\" 27) (case \"HTTP-request-denied\") (case \"HTTP-request-length-required\") (case \"HTTP-request-body-size\" 31) (case \"HTTP-request-method-invalid\") (case \"HTTP-request-URI-invalid\") (case \"HTTP-request-URI-too-long\") (case \"HTTP-request-header-section-size\" 28) (case \"HTTP-request-header-size\" 32) (case \"HTTP-request-trailer-section-size\" 28) (case \"HTTP-request-trailer-size\" 30) (case \"HTTP-response-incomplete\") (case \"HTTP-response-header-section-size\" 28) (case \"HTTP-response-header-size\" 30) (case \"HTTP-response-body-size\" 31) (case \"HTTP-response-trailer-section-size\" 28) (case \"HTTP-response-trailer-size\" 30) (case \"HTTP-response-transfer-coding\" 21) (case \"HTTP-response-content-coding\" 21) (case \"HTTP-response-timeout\") (case \"HTTP-upgrade-failed\") (case \"HTTP-protocol-error\") (case \"loop-detected\") (case \"configuration-error\") (case \"internal-error\" 21)))\n      (export (;34;) \"error-code\" (type (eq 33)))\n      (export (;35;) \"incoming-response\" (type (sub resource)))\n      (type (;36;) u16)\n      (export (;37;) \"status-code\" (type (eq 36)))\n      (alias outer 1 15 (type (;38;)))\n      (export (;39;) \"input-stream\" (type (eq 38)))\n      (export (;40;) \"future-trailers\" (type (sub resource)))\n      (alias outer 1 16 (type (;41;)))\n      (export (;42;) \"pollable\" (type (eq 41)))\n      (export (;43;) \"trailers\" (type (eq 0)))\n      (alias outer 1 17 (type (;44;)))\n      (export (;45;) \"output-stream\" (type (eq 44)))\n      (export (;46;) \"future-incoming-response\" (type (sub resource)))\n      (alias outer 1 18 (type (;47;)))\n      (export (;48;) \"io-error\" (type (eq 47)))\n      (type (;49;) (own 0))\n      (type (;50;) (func (result 49)))\n      (export (;0;) \"[constructor]fields\" (func (type 50)))\n      (type (;51;) (tuple 2 4))\n      (type (;52;) (list 51))\n      (type (;53;) (result 49 (error 6)))\n      (type (;54;) (func (param \"entries\" 52) (result 53)))\n      (export (;1;) \"[static]fields.from-list\" (func (type 54)))\n      (type (;55;) (borrow 0))\n      (type (;56;) (list 4))\n      (type (;57;) (func (param \"self\" 55) (param \"name\" 2) (result 56)))\n      (export (;2;) \"[method]fields.get\" (func (type 57)))\n      (type (;58;) (func (param \"self\" 55) (param \"name\" 2) (result bool)))\n      (export (;3;) \"[method]fields.has\" (func (type 58)))\n      (type (;59;) (result (error 6)))\n      (type (;60;) (func (param \"self\" 55) (param \"name\" 2) (param \"value\" 56) (result 59)))\n      (export (;4;) \"[method]fields.set\" (func (type 60)))\n      (type (;61;) (func (param \"self\" 55) (param \"name\" 2) (result 59)))\n      (export (;5;) \"[method]fields.delete\" (func (type 61)))\n      (type (;62;) (func (param \"self\" 55) (param \"name\" 2) (param \"value\" 4) (result 59)))\n      (export (;6;) \"[method]fields.append\" (func (type 62)))\n      (type (;63;) (func (param \"self\" 55) (result 52)))\n      (export (;7;) \"[method]fields.entries\" (func (type 63)))\n      (type (;64;) (func (param \"self\" 55) (result 49)))\n      (export (;8;) \"[method]fields.clone\" (func (type 64)))\n      (type (;65;) (borrow 7))\n      (type (;66;) (func (param \"self\" 65) (result 9)))\n      (export (;9;) \"[method]incoming-request.method\" (func (type 66)))\n      (type (;67;) (func (param \"self\" 65) (result 21)))\n      (export (;10;) \"[method]incoming-request.path-with-query\" (func (type 67)))\n      (type (;68;) (option 11))\n      (type (;69;) (func (param \"self\" 65) (result 68)))\n      (export (;11;) \"[method]incoming-request.scheme\" (func (type 69)))\n      (export (;12;) \"[method]incoming-request.authority\" (func (type 67)))\n      (type (;70;) (own 12))\n      (type (;71;) (func (param \"self\" 65) (result 70)))\n      (export (;13;) \"[method]incoming-request.headers\" (func (type 71)))\n      (type (;72;) (own 13))\n      (type (;73;) (result 72))\n      (type (;74;) (func (param \"self\" 65) (result 73)))\n      (export (;14;) \"[method]incoming-request.consume\" (func (type 74)))\n      (type (;75;) (own 14))\n      (type (;76;) (func (param \"headers\" 70) (result 75)))\n      (export (;15;) \"[constructor]outgoing-request\" (func (type 76)))\n      (type (;77;) (borrow 14))\n      (type (;78;) (own 15))\n      (type (;79;) (result 78))\n      (type (;80;) (func (param \"self\" 77) (result 79)))\n      (export (;16;) \"[method]outgoing-request.body\" (func (type 80)))\n      (type (;81;) (func (param \"self\" 77) (result 9)))\n      (export (;17;) \"[method]outgoing-request.method\" (func (type 81)))\n      (type (;82;) (result))\n      (type (;83;) (func (param \"self\" 77) (param \"method\" 9) (result 82)))\n      (export (;18;) \"[method]outgoing-request.set-method\" (func (type 83)))\n      (type (;84;) (func (param \"self\" 77) (result 21)))\n      (export (;19;) \"[method]outgoing-request.path-with-query\" (func (type 84)))\n      (type (;85;) (func (param \"self\" 77) (param \"path-with-query\" 21) (result 82)))\n      (export (;20;) \"[method]outgoing-request.set-path-with-query\" (func (type 85)))\n      (type (;86;) (func (param \"self\" 77) (result 68)))\n      (export (;21;) \"[method]outgoing-request.scheme\" (func (type 86)))\n      (type (;87;) (func (param \"self\" 77) (param \"scheme\" 68) (result 82)))\n      (export (;22;) \"[method]outgoing-request.set-scheme\" (func (type 87)))\n      (export (;23;) \"[method]outgoing-request.authority\" (func (type 84)))\n      (type (;88;) (func (param \"self\" 77) (param \"authority\" 21) (result 82)))\n      (export (;24;) \"[method]outgoing-request.set-authority\" (func (type 88)))\n      (type (;89;) (func (param \"self\" 77) (result 70)))\n      (export (;25;) \"[method]outgoing-request.headers\" (func (type 89)))\n      (type (;90;) (own 16))\n      (type (;91;) (func (result 90)))\n      (export (;26;) \"[constructor]request-options\" (func (type 91)))\n      (type (;92;) (borrow 16))\n      (type (;93;) (option 18))\n      (type (;94;) (func (param \"self\" 92) (result 93)))\n      (export (;27;) \"[method]request-options.connect-timeout\" (func (type 94)))\n      (type (;95;) (func (param \"self\" 92) (param \"duration\" 93) (result 82)))\n      (export (;28;) \"[method]request-options.set-connect-timeout\" (func (type 95)))\n      (export (;29;) \"[method]request-options.first-byte-timeout\" (func (type 94)))\n      (export (;30;) \"[method]request-options.set-first-byte-timeout\" (func (type 95)))\n      (export (;31;) \"[method]request-options.between-bytes-timeout\" (func (type 94)))\n      (export (;32;) \"[method]request-options.set-between-bytes-timeout\" (func (type 95)))\n      (type (;96;) (own 19))\n      (type (;97;) (own 20))\n      (type (;98;) (result 97 (error 34)))\n      (type (;99;) (func (param \"param\" 96) (param \"response\" 98)))\n      (export (;33;) \"[static]response-outparam.set\" (func (type 99)))\n      (type (;100;) (borrow 35))\n      (type (;101;) (func (param \"self\" 100) (result 37)))\n      (export (;34;) \"[method]incoming-response.status\" (func (type 101)))\n      (type (;102;) (func (param \"self\" 100) (result 70)))\n      (export (;35;) \"[method]incoming-response.headers\" (func (type 102)))\n      (type (;103;) (func (param \"self\" 100) (result 73)))\n      (export (;36;) \"[method]incoming-response.consume\" (func (type 103)))\n      (type (;104;) (borrow 13))\n      (type (;105;) (own 39))\n      (type (;106;) (result 105))\n      (type (;107;) (func (param \"self\" 104) (result 106)))\n      (export (;37;) \"[method]incoming-body.stream\" (func (type 107)))\n      (type (;108;) (own 40))\n      (type (;109;) (func (param \"this\" 72) (result 108)))\n      (export (;38;) \"[static]incoming-body.finish\" (func (type 109)))\n      (type (;110;) (borrow 40))\n      (type (;111;) (own 42))\n      (type (;112;) (func (param \"self\" 110) (result 111)))\n      (export (;39;) \"[method]future-trailers.subscribe\" (func (type 112)))\n      (type (;113;) (own 43))\n      (type (;114;) (option 113))\n      (type (;",
      "115;) (result 114 (error 34)))\n      (type (;116;) (result 115))\n      (type (;117;) (option 116))\n      (type (;118;) (func (param \"self\" 110) (result 117)))\n      (export (;40;) \"[method]future-trailers.get\" (func (type 118)))\n      (type (;119;) (func (param \"headers\" 70) (result 97)))\n      (export (;41;) \"[constructor]outgoing-response\" (func (type 119)))\n      (type (;120;) (borrow 20))\n      (type (;121;) (func (param \"self\" 120) (result 37)))\n      (export (;42;) \"[method]outgoing-response.status-code\" (func (type 121)))\n      (type (;122;) (func (param \"self\" 120) (param \"status-code\" 37) (result 82)))\n      (export (;43;) \"[method]outgoing-response.set-status-code\" (func (type 122)))\n      (type (;123;) (func (param \"self\" 120) (result 70)))\n      (export (;44;) \"[method]outgoing-response.headers\" (func (type 123)))\n      (type (;124;) (func (param \"self\" 120) (result 79)))\n      (export (;45;) \"[method]outgoing-response.body\" (func (type 124)))\n      (type (;125;) (borrow 15))\n      (type (;126;) (own 45))\n      (type (;127;) (result 126))\n      (type (;128;) (func (param \"self\" 125) (result 127)))\n      (export (;46;) \"[method]outgoing-body.write\" (func (type 128)))\n      (type (;129;) (result (error 34)))\n      (type (;130;) (func (param \"this\" 78) (param \"trailers\" 114) (result 129)))\n      (export (;47;) \"[static]outgoing-body.finish\" (func (type 130)))\n      (type (;131;) (borrow 46))\n      (type (;132;) (func (param \"self\" 131) (result 111)))\n      (export (;48;) \"[method]future-incoming-response.subscribe\" (func (type 132)))\n      (type (;133;) (own 35))\n      (type (;134;) (result 133 (error 34)))\n      (type (;135;) (result 134))\n      (type (;136;) (option 135))\n      (type (;137;) (func (param \"self\" 131) (result 136)))\n      (export (;49;) \"[method]future-incoming-response.get\" (func (type 137)))\n      (type (;138;) (borrow 48))\n      (type (;139;) (option 34))\n      (type (;140;) (func (param \"err\" 138) (result 139)))\n      (export (;50;) \"http-error-code\" (func (type 140)))\n    )\n  )\n  (import \"wasi:http/types@0.2.0\" (instance (;8;) (type 19)))\n  (alias export 8 \"outgoing-request\" (type (;20;)))\n  (alias export 8 \"request-options\" (type (;21;)))\n  (alias export 8 \"future-incoming-response\" (type (;22;)))\n  (alias export 8 \"error-code\" (type (;23;)))\n  (type (;24;)\n    (instance\n      (alias outer 1 20 (type (;0;)))\n      (export (;1;) \"outgoing-request\" (type (eq 0)))\n      (alias outer 1 21 (type (;2;)))\n      (export (;3;) \"request-options\" (type (eq 2)))\n      (alias outer 1 22 (type (;4;)))\n      (export (;5;) \"future-incoming-response\" (type (eq 4)))\n      (alias outer 1 23 (type (;6;)))\n      (export (;7;) \"error-code\" (type (eq 6)))\n      (type (;8;) (own 1))\n      (type (;9;) (own 3))\n      (type (;10;) (option 9))\n      (type (;11;) (own 5))\n      (type (;12;) (result 11 (error 7)))\n      (type (;13;) (func (param \"request\" 8) (param \"options\" 10) (result 12)))\n      (export (;0;) \"handle\" (func (type 13)))\n    )\n  )\n  (import \"wasi:http/outgoing-handler@0.2.0\" (instance (;9;) (type 24)))\n  (type (;25;)\n    (instance\n      (type (;0;) (record (field \"seconds\" u64) (field \"nanoseconds\" u32)))\n      (export (;1;) \"datetime\" (type (eq 0)))\n      (type (;2;) (func (result 1)))\n      (export (;0;) \"now\" (func (type 2)))\n      (export (;1;) \"resolution\" (func (type 2)))\n    )\n  )\n  (import \"wasi:clocks/wall-clock@0.2.0\" (instance (;10;) (type 25)))\n  (core module (;0;)\n    (type (;0;) (func (param i64 i32)))\n    (type (;1;) (func (result i64)))\n    (type (;2;) (func (param i32 i32)))\n    (type (;3;) (func (param i32)))\n    (type (;4;) (func (param i32) (result i32)))\n    (type (;5;) (func (param i32 i32 i32)))\n    (type (;6;) (func (param i32 i64 i32)))\n    (type (;7;) (func (param i32 i32 i32 i32)))\n    (type (;8;) (func (param i32 i32 i64 i32)))\n    (type (;9;) (func (result i32)))\n    (type (;10;) (func (param i64) (result i32)))\n    (type (;11;) (func (param i32 i32 i32) (result i32)))\n    (type (;12;) (func (param i32 i32 i32 i32 i32 i32)))\n    (type (;13;) (func (param i32 i32 i32 i32) (result i32)))\n    (type (;14;) (func (param i32 i32 i32 i32 i32) (result i32)))\n    (type (;15;) (func (param i32 i32 i64) (result i32)))\n    (type (;16;) (func (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (type (;17;) (func (param i32 i32) (result i32)))\n    (type (;18;) (func))\n    (import \"cm32p2|wasi:random/random@0.2\" \"get-random-bytes\" (func (;0;) (type 0) (param i64 i32)))\n    (import \"cm32p2|wasi:random/random@0.2\" \"get-random-u64\" (func (;1;) (type 1) (result i64)))\n    (import \"cm32p2|wasi:io/error@0.2\" \"[method]error.to-debug-string\" (func (;2;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:io/error@0.2\" \"error_drop\" (func (;3;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"[method]pollable.ready\" (func (;4;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"[method]pollable.block\" (func (;5;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"poll\" (func (;6;) (type 5) (param i32 i32 i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"pollable_drop\" (func (;7;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.read\" (func (;8;) (type 6) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.blocking-read\" (func (;9;) (type 6) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.skip\" (func (;10;) (type 6) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.blocking-skip\" (func (;11;) (type 6) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.subscribe\" (func (;12;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.check-write\" (func (;13;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.write\" (func (;14;) (type 7) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-write-and-flush\" (func (;15;) (type 7) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.flush\" (func (;16;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-flush\" (func (;17;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.subscribe\" (func (;18;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.write-zeroes\" (func (;19;) (type 6) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-write-zeroes-and-flush\" (func (;20;) (type 6) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.splice\" (func (;21;) (type 8) (param i32 i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-splice\" (func (;22;) (type 8) (param i32 i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"input-stream_drop\" (func (;23;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"output-stream_drop\" (func (;24;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:cli/stdout@0.2\" \"get-stdout\" (func (;25;) (type 9) (result i32)))\n    (import \"cm32p2|wasi:cli/stderr@0.2\" \"get-stderr\" (func (;26;) (type 9) (result i32)))\n    (import \"cm32p2|wasi:cli/stdin@0.2\" \"get-stdin\" (func (;27;) (type 9) (result i32)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"now\" (func (;28;) (type 1) (result i64)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"resolution\" (func (;29;) (type 1) (result i64)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"subscribe-instant\" (func (;30;) (type 10) (param i64) (result i32)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"subscribe-duration\" (func (;31;) (type 10) (param i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]fields\" (func (;32;) (type 9) (result",
      " i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]fields.from-list\" (func (;33;) (type 5) (param i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.get\" (func (;34;) (type 7) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.has\" (func (;35;) (type 11) (param i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.set\" (func (;36;) (type 12) (param i32 i32 i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.delete\" (func (;37;) (type 7) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.append\" (func (;38;) (type 12) (param i32 i32 i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.entries\" (func (;39;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.clone\" (func (;40;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.method\" (func (;41;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.path-with-query\" (func (;42;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.scheme\" (func (;43;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.authority\" (func (;44;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.headers\" (func (;45;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.consume\" (func (;46;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]outgoing-request\" (func (;47;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.body\" (func (;48;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.method\" (func (;49;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-method\" (func (;50;) (type 13) (param i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.path-with-query\" (func (;51;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-path-with-query\" (func (;52;) (type 13) (param i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.scheme\" (func (;53;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-scheme\" (func (;54;) (type 14) (param i32 i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.authority\" (func (;55;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-authority\" (func (;56;) (type 13) (param i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.headers\" (func (;57;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]request-options\" (func (;58;) (type 9) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.connect-timeout\" (func (;59;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.set-connect-timeout\" (func (;60;) (type 15) (param i32 i32 i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.first-byte-timeout\" (func (;61;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.set-first-byte-timeout\" (func (;62;) (type 15) (param i32 i32 i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.between-bytes-timeout\" (func (;63;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.set-between-bytes-timeout\" (func (;64;) (type 15) (param i32 i32 i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]response-outparam.set\" (func (;65;) (type 16) (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-response.status\" (func (;66;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-response.headers\" (func (;67;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-response.consume\" (func (;68;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-body.stream\" (func (;69;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]incoming-body.finish\" (func (;70;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-trailers.subscribe\" (func (;71;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-trailers.get\" (func (;72;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]outgoing-response\" (func (;73;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.status-code\" (func (;74;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.set-status-code\" (func (;75;) (type 17) (param i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.headers\" (func (;76;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.body\" (func (;77;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-body.write\" (func (;78;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]outgoing-body.finish\" (func (;79;) (type 7) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-incoming-response.subscribe\" (func (;80;) (type 4) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-incoming-response.get\" (func (;81;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"http-error-code\" (func (;82;) (type 2) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"fields_drop\" (func (;83;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"incoming-request_drop\" (func (;84;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"outgoing-request_drop\" (func (;85;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"request-options_drop\" (func (;86;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"response-outparam_drop\" (func (;87;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"incoming-response_drop\" (func (;88;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"incoming-body_drop\" (func (;89;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"future-trailers_drop\" (func (;90;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"outgoing-response_drop\" (func (;91;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"outgoing-body_drop\" (func (;92;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"future-incoming-response_drop\" (func (;93;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:http/outgoing-handler@0.2\" \"handle\" (func (;94;) (type 7) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:clocks/wall-clock@0.2\" \"now\" (func (;95;) (type 3) (param i32)))\n    (import \"cm32p2|wasi:clocks/wall-clock@0.2\" \"resolution\" (func (;96;) (type 3) (param i32)))\n    (memory (;0;) 0)\n    (export \"cm32p2|wasi:http/incoming-handler@0.2|handle\" (func 97))\n    (export \"cm32p2|wasi:http/incoming-handler@0.2|handle_post\" (func 98))\n    (export \"cm32p2_memory\" (memory 0))\n    (export \"cm32p2_realloc\" (func 99))\n    (export \"cm32p2_initialize\" (func 100))\n    (func (;97;) (type 2) (param i32 i32)\n      unreachable\n    )\n    (func (;98;) (type 18))\n    (func (;99;) (type 13) (param i32 i3",
      "2 i32 i32) (result i32)\n      unreachable\n    )\n    (func (;100;) (type 18))\n    (@producers\n      (processed-by \"wit-component\" \"0.229.0\")\n    )\n  )\n  (core module (;1;)\n    (type (;0;) (func (param i64 i32)))\n    (type (;1;) (func (param i32 i32)))\n    (type (;2;) (func (param i32 i32 i32)))\n    (type (;3;) (func (param i32 i64 i32)))\n    (type (;4;) (func (param i32 i32 i32 i32)))\n    (type (;5;) (func (param i32 i32 i64 i32)))\n    (type (;6;) (func (param i32 i32 i32) (result i32)))\n    (type (;7;) (func (param i32 i32 i32 i32 i32 i32)))\n    (type (;8;) (func (param i32 i32 i32 i32) (result i32)))\n    (type (;9;) (func (param i32 i32 i32 i32 i32) (result i32)))\n    (type (;10;) (func (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (type (;11;) (func (param i32 i32 i32 i32)))\n    (type (;12;) (func (param i32)))\n    (table (;0;) 52 52 funcref)\n    (export \"0\" (func $indirect-cm32p2|wasi:random/random@0.2-get-random-bytes))\n    (export \"1\" (func $\"indirect-cm32p2|wasi:io/error@0.2-[method]error.to-debug-string\"))\n    (export \"2\" (func $indirect-cm32p2|wasi:io/poll@0.2-poll))\n    (export \"3\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.read\"))\n    (export \"4\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-read\"))\n    (export \"5\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.skip\"))\n    (export \"6\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-skip\"))\n    (export \"7\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.check-write\"))\n    (export \"8\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write\"))\n    (export \"9\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-and-flush\"))\n    (export \"10\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.flush\"))\n    (export \"11\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-flush\"))\n    (export \"12\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write-zeroes\"))\n    (export \"13\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-zeroes-and-flush\"))\n    (export \"14\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.splice\"))\n    (export \"15\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-splice\"))\n    (export \"16\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]fields.from-list\"))\n    (export \"17\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.get\"))\n    (export \"18\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.has\"))\n    (export \"19\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.set\"))\n    (export \"20\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.delete\"))\n    (export \"21\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.append\"))\n    (export \"22\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.entries\"))\n    (export \"23\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.method\"))\n    (export \"24\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.path-with-query\"))\n    (export \"25\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.scheme\"))\n    (export \"26\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.authority\"))\n    (export \"27\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.consume\"))\n    (export \"28\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.body\"))\n    (export \"29\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.method\"))\n    (export \"30\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-method\"))\n    (export \"31\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.path-with-query\"))\n    (export \"32\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-path-with-query\"))\n    (export \"33\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.scheme\"))\n    (export \"34\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-scheme\"))\n    (export \"35\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.authority\"))\n    (export \"36\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-authority\"))\n    (export \"37\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.connect-timeout\"))\n    (export \"38\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.first-byte-timeout\"))\n    (export \"39\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.between-bytes-timeout\"))\n    (export \"40\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]response-outparam.set\"))\n    (export \"41\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-response.consume\"))\n    (export \"42\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-body.stream\"))\n    (export \"43\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-trailers.get\"))\n    (export \"44\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-response.body\"))\n    (export \"45\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-body.write\"))\n    (export \"46\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]outgoing-body.finish\"))\n    (export \"47\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-incoming-response.get\"))\n    (export \"48\" (func $indirect-cm32p2|wasi:http/types@0.2-http-error-code))\n    (export \"49\" (func $indirect-cm32p2|wasi:http/outgoing-handler@0.2-handle))\n    (export \"50\" (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-now))\n    (export \"51\" (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-resolution))\n    (export \"$imports\" (table 0))\n    (func $indirect-cm32p2|wasi:random/random@0.2-get-random-bytes (;0;) (type 0) (param i64 i32)\n      local.get 0\n      local.get 1\n      i32.const 0\n      call_indirect (type 0)\n    )\n    (func $\"indirect-cm32p2|wasi:io/error@0.2-[method]error.to-debug-string\" (;1;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 1\n      call_indirect (type 1)\n    )\n    (func $indirect-cm32p2|wasi:io/poll@0.2-poll (;2;) (type 2) (param i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 2\n      call_indirect (type 2)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.read\" (;3;) (type 3) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 3\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-read\" (;4;) (type 3) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 4\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.skip\" (;5;) (type 3) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 5\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-skip\" (;6;) (type 3) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 6\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.check-write\" (;7;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 7\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write\" (;8;) (type 4) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 8\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-and-flush\" (;9;) (type 4) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 9\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.",
      "2-[method]output-stream.flush\" (;10;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 10\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-flush\" (;11;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 11\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write-zeroes\" (;12;) (type 3) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 12\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-zeroes-and-flush\" (;13;) (type 3) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 13\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.splice\" (;14;) (type 5) (param i32 i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 14\n      call_indirect (type 5)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-splice\" (;15;) (type 5) (param i32 i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 15\n      call_indirect (type 5)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]fields.from-list\" (;16;) (type 2) (param i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 16\n      call_indirect (type 2)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.get\" (;17;) (type 4) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 17\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.has\" (;18;) (type 6) (param i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 18\n      call_indirect (type 6)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.set\" (;19;) (type 7) (param i32 i32 i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      local.get 5\n      i32.const 19\n      call_indirect (type 7)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.delete\" (;20;) (type 4) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 20\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.append\" (;21;) (type 7) (param i32 i32 i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      local.get 5\n      i32.const 21\n      call_indirect (type 7)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.entries\" (;22;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 22\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.method\" (;23;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 23\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.path-with-query\" (;24;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 24\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.scheme\" (;25;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 25\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.authority\" (;26;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 26\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.consume\" (;27;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 27\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.body\" (;28;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 28\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.method\" (;29;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 29\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-method\" (;30;) (type 8) (param i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 30\n      call_indirect (type 8)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.path-with-query\" (;31;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 31\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-path-with-query\" (;32;) (type 8) (param i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 32\n      call_indirect (type 8)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.scheme\" (;33;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 33\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-scheme\" (;34;) (type 9) (param i32 i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      i32.const 34\n      call_indirect (type 9)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.authority\" (;35;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 35\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-authority\" (;36;) (type 8) (param i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 36\n      call_indirect (type 8)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.connect-timeout\" (;37;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 37\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.first-byte-timeout\" (;38;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 38\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.between-bytes-timeout\" (;39;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 39\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]response-outparam.set\" (;40;) (type 10) (param i32 i32 i32 i32 i64 i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      local.get 5\n      local.get 6\n      local.get 7\n      local.get 8\n      i32.const 40\n      call_indirect (type 10)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-response.consume\" (;41;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 41\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-body.stream\" (;42;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 42\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-trailers.get\" (;43;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 43\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-response.body\" (;44;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 44\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[met",
      "hod]outgoing-body.write\" (;45;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 45\n      call_indirect (type 1)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]outgoing-body.finish\" (;46;) (type 11) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 46\n      call_indirect (type 11)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-incoming-response.get\" (;47;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 47\n      call_indirect (type 1)\n    )\n    (func $indirect-cm32p2|wasi:http/types@0.2-http-error-code (;48;) (type 1) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 48\n      call_indirect (type 1)\n    )\n    (func $indirect-cm32p2|wasi:http/outgoing-handler@0.2-handle (;49;) (type 11) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 49\n      call_indirect (type 11)\n    )\n    (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-now (;50;) (type 12) (param i32)\n      local.get 0\n      i32.const 50\n      call_indirect (type 12)\n    )\n    (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-resolution (;51;) (type 12) (param i32)\n      local.get 0\n      i32.const 51\n      call_indirect (type 12)\n    )\n    (@producers\n      (processed-by \"wit-component\" \"0.229.0\")\n    )\n  )\n  (core module (;2;)\n    (type (;0;) (func (param i64 i32)))\n    (type (;1;) (func (param i32 i32)))\n    (type (;2;) (func (param i32 i32 i32)))\n    (type (;3;) (func (param i32 i64 i32)))\n    (type (;4;) (func (param i32 i32 i32 i32)))\n    (type (;5;) (func (param i32 i32 i64 i32)))\n    (type (;6;) (func (param i32 i32 i32) (result i32)))\n    (type (;7;) (func (param i32 i32 i32 i32 i32 i32)))\n    (type (;8;) (func (param i32 i32 i32 i32) (result i32)))\n    (type (;9;) (func (param i32 i32 i32 i32 i32) (result i32)))\n    (type (;10;) (func (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (type (;11;) (func (param i32 i32 i32 i32)))\n    (type (;12;) (func (param i32)))\n    (import \"\" \"0\" (func (;0;) (type 0) (param i64 i32)))\n    (import \"\" \"1\" (func (;1;) (type 1) (param i32 i32)))\n    (import \"\" \"2\" (func (;2;) (type 2) (param i32 i32 i32)))\n    (import \"\" \"3\" (func (;3;) (type 3) (param i32 i64 i32)))\n    (import \"\" \"4\" (func (;4;) (type 3) (param i32 i64 i32)))\n    (import \"\" \"5\" (func (;5;) (type 3) (param i32 i64 i32)))\n    (import \"\" \"6\" (func (;6;) (type 3) (param i32 i64 i32)))\n    (import \"\" \"7\" (func (;7;) (type 1) (param i32 i32)))\n    (import \"\" \"8\" (func (;8;) (type 4) (param i32 i32 i32 i32)))\n    (import \"\" \"9\" (func (;9;) (type 4) (param i32 i32 i32 i32)))\n    (import \"\" \"10\" (func (;10;) (type 1) (param i32 i32)))\n    (import \"\" \"11\" (func (;11;) (type 1) (param i32 i32)))\n    (import \"\" \"12\" (func (;12;) (type 3) (param i32 i64 i32)))\n    (import \"\" \"13\" (func (;13;) (type 3) (param i32 i64 i32)))\n    (import \"\" \"14\" (func (;14;) (type 5) (param i32 i32 i64 i32)))\n    (import \"\" \"15\" (func (;15;) (type 5) (param i32 i32 i64 i32)))\n    (import \"\" \"16\" (func (;16;) (type 2) (param i32 i32 i32)))\n    (import \"\" \"17\" (func (;17;) (type 4) (param i32 i32 i32 i32)))\n    (import \"\" \"18\" (func (;18;) (type 6) (param i32 i32 i32) (result i32)))\n    (import \"\" \"19\" (func (;19;) (type 7) (param i32 i32 i32 i32 i32 i32)))\n    (import \"\" \"20\" (func (;20;) (type 4) (param i32 i32 i32 i32)))\n    (import \"\" \"21\" (func (;21;) (type 7) (param i32 i32 i32 i32 i32 i32)))\n    (import \"\" \"22\" (func (;22;) (type 1) (param i32 i32)))\n    (import \"\" \"23\" (func (;23;) (type 1) (param i32 i32)))\n    (import \"\" \"24\" (func (;24;) (type 1) (param i32 i32)))\n    (import \"\" \"25\" (func (;25;) (type 1) (param i32 i32)))\n    (import \"\" \"26\" (func (;26;) (type 1) (param i32 i32)))\n    (import \"\" \"27\" (func (;27;) (type 1) (param i32 i32)))\n    (import \"\" \"28\" (func (;28;) (type 1) (param i32 i32)))\n    (import \"\" \"29\" (func (;29;) (type 1) (param i32 i32)))\n    (import \"\" \"30\" (func (;30;) (type 8) (param i32 i32 i32 i32) (result i32)))\n    (import \"\" \"31\" (func (;31;) (type 1) (param i32 i32)))\n    (import \"\" \"32\" (func (;32;) (type 8) (param i32 i32 i32 i32) (result i32)))\n    (import \"\" \"33\" (func (;33;) (type 1) (param i32 i32)))\n    (import \"\" \"34\" (func (;34;) (type 9) (param i32 i32 i32 i32 i32) (result i32)))\n    (import \"\" \"35\" (func (;35;) (type 1) (param i32 i32)))\n    (import \"\" \"36\" (func (;36;) (type 8) (param i32 i32 i32 i32) (result i32)))\n    (import \"\" \"37\" (func (;37;) (type 1) (param i32 i32)))\n    (import \"\" \"38\" (func (;38;) (type 1) (param i32 i32)))\n    (import \"\" \"39\" (func (;39;) (type 1) (param i32 i32)))\n    (import \"\" \"40\" (func (;40;) (type 10) (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (import \"\" \"41\" (func (;41;) (type 1) (param i32 i32)))\n    (import \"\" \"42\" (func (;42;) (type 1) (param i32 i32)))\n    (import \"\" \"43\" (func (;43;) (type 1) (param i32 i32)))\n    (import \"\" \"44\" (func (;44;) (type 1) (param i32 i32)))\n    (import \"\" \"45\" (func (;45;) (type 1) (param i32 i32)))\n    (import \"\" \"46\" (func (;46;) (type 11) (param i32 i32 i32 i32)))\n    (import \"\" \"47\" (func (;47;) (type 1) (param i32 i32)))\n    (import \"\" \"48\" (func (;48;) (type 1) (param i32 i32)))\n    (import \"\" \"49\" (func (;49;) (type 11) (param i32 i32 i32 i32)))\n    (import \"\" \"50\" (func (;50;) (type 12) (param i32)))\n    (import \"\" \"51\" (func (;51;) (type 12) (param i32)))\n    (import \"\" \"$imports\" (table (;0;) 52 52 funcref))\n    (elem (;0;) (i32.const 0) func 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51)\n    (@producers\n      (processed-by \"wit-component\" \"0.229.0\")\n    )\n  )\n  (core instance (;0;) (instantiate 1))\n  (alias export 8 \"incoming-request\" (type (;26;)))\n  (alias export 8 \"response-outparam\" (type (;27;)))\n  (alias core export 0 \"0\" (core func (;0;)))\n  (alias export 0 \"get-random-u64\" (func (;0;)))\n  (core func (;1;) (canon lower (func 0)))\n  (core instance (;1;)\n    (export \"get-random-bytes\" (func 0))\n    (export \"get-random-u64\" (func 1))\n  )\n  (alias core export 0 \"1\" (core func (;2;)))\n  (alias export 1 \"error\" (type (;28;)))\n  (core func (;3;) (canon resource.drop 28))\n  (core instance (;2;)\n    (export \"[method]error.to-debug-string\" (func 2))\n    (export \"error_drop\" (func 3))\n  )\n  (alias export 2 \"[method]pollable.ready\" (func (;1;)))\n  (core func (;4;) (canon lower (func 1)))\n  (alias export 2 \"[method]pollable.block\" (func (;2;)))\n  (core func (;5;) (canon lower (func 2)))\n  (alias core export 0 \"2\" (core func (;6;)))\n  (alias export 2 \"pollable\" (type (;29;)))\n  (core func (;7;) (canon resource.drop 29))\n  (core instance (;3;)\n    (export \"[method]pollable.ready\" (func 4))\n    (export \"[method]pollable.block\" (func 5))\n    (export \"poll\" (func 6))\n    (export \"pollable_drop\" (func 7))\n  )\n  (alias core export 0 \"3\" (core func (;8;)))\n  (alias core export 0 \"4\" (core func (;9;)))\n  (alias core export 0 \"5\" (core func (;10;)))\n  (alias core export 0 \"6\" (core func (;11;)))\n  (alias export 3 \"[method]input-stream.subscribe\" (func (;3;)))\n  (core func (;12;) (canon lower (func 3)))\n  (alias core export 0 \"7\" (core func (;13;)))\n  (alias core export 0 \"8\" (core func (;14;)))\n  (alias core export 0 \"9\" (core func (;15;)))\n  (alias core export 0 \"10\" (core func (;16;)))\n  (alias core export 0 \"11\" (core func (;17;)))\n  (alias export 3 \"[method]output-stream.subscribe\" (func (;4;)))\n  (core func (;18;) (canon lower (func 4)))\n  (alias core export 0 \"12\" (core func (;19;)))\n  (alias core export 0 \"13\" (core func (;20;)))\n  (alias core export 0 \"14\" (core func (;21;)))\n  (alias core export 0 \"15\" (core func (;22;)))\n  (alias export 3 \"input-stream\" (type (;30;)))\n  (core func (;23;) (canon resource.drop 30))\n  (alias export 3 \"output-stream\" (type (;31;)))\n  (core func (;24;) (canon resource.drop 31))\n  (core instance (;4;)\n    (export \"[method]input-",
      "stream.read\" (func 8))\n    (export \"[method]input-stream.blocking-read\" (func 9))\n    (export \"[method]input-stream.skip\" (func 10))\n    (export \"[method]input-stream.blocking-skip\" (func 11))\n    (export \"[method]input-stream.subscribe\" (func 12))\n    (export \"[method]output-stream.check-write\" (func 13))\n    (export \"[method]output-stream.write\" (func 14))\n    (export \"[method]output-stream.blocking-write-and-flush\" (func 15))\n    (export \"[method]output-stream.flush\" (func 16))\n    (export \"[method]output-stream.blocking-flush\" (func 17))\n    (export \"[method]output-stream.subscribe\" (func 18))\n    (export \"[method]output-stream.write-zeroes\" (func 19))\n    (export \"[method]output-stream.blocking-write-zeroes-and-flush\" (func 20))\n    (export \"[method]output-stream.splice\" (func 21))\n    (export \"[method]output-stream.blocking-splice\" (func 22))\n    (export \"input-stream_drop\" (func 23))\n    (export \"output-stream_drop\" (func 24))\n  )\n  (alias export 4 \"get-stdout\" (func (;5;)))\n  (core func (;25;) (canon lower (func 5)))\n  (core instance (;5;)\n    (export \"get-stdout\" (func 25))\n  )\n  (alias export 5 \"get-stderr\" (func (;6;)))\n  (core func (;26;) (canon lower (func 6)))\n  (core instance (;6;)\n    (export \"get-stderr\" (func 26))\n  )\n  (alias export 6 \"get-stdin\" (func (;7;)))\n  (core func (;27;) (canon lower (func 7)))\n  (core instance (;7;)\n    (export \"get-stdin\" (func 27))\n  )\n  (alias export 7 \"now\" (func (;8;)))\n  (core func (;28;) (canon lower (func 8)))\n  (alias export 7 \"resolution\" (func (;9;)))\n  (core func (;29;) (canon lower (func 9)))\n  (alias export 7 \"subscribe-instant\" (func (;10;)))\n  (core func (;30;) (canon lower (func 10)))\n  (alias export 7 \"subscribe-duration\" (func (;11;)))\n  (core func (;31;) (canon lower (func 11)))\n  (core instance (;8;)\n    (export \"now\" (func 28))\n    (export \"resolution\" (func 29))\n    (export \"subscribe-instant\" (func 30))\n    (export \"subscribe-duration\" (func 31))\n  )\n  (alias export 8 \"[constructor]fields\" (func (;12;)))\n  (core func (;32;) (canon lower (func 12)))\n  (alias core export 0 \"16\" (core func (;33;)))\n  (alias core export 0 \"17\" (core func (;34;)))\n  (alias core export 0 \"18\" (core func (;35;)))\n  (alias core export 0 \"19\" (core func (;36;)))\n  (alias core export 0 \"20\" (core func (;37;)))\n  (alias core export 0 \"21\" (core func (;38;)))\n  (alias core export 0 \"22\" (core func (;39;)))\n  (alias export 8 \"[method]fields.clone\" (func (;13;)))\n  (core func (;40;) (canon lower (func 13)))\n  (alias core export 0 \"23\" (core func (;41;)))\n  (alias core export 0 \"24\" (core func (;42;)))\n  (alias core export 0 \"25\" (core func (;43;)))\n  (alias core export 0 \"26\" (core func (;44;)))\n  (alias export 8 \"[method]incoming-request.headers\" (func (;14;)))\n  (core func (;45;) (canon lower (func 14)))\n  (alias core export 0 \"27\" (core func (;46;)))\n  (alias export 8 \"[constructor]outgoing-request\" (func (;15;)))\n  (core func (;47;) (canon lower (func 15)))\n  (alias core export 0 \"28\" (core func (;48;)))\n  (alias core export 0 \"29\" (core func (;49;)))\n  (alias core export 0 \"30\" (core func (;50;)))\n  (alias core export 0 \"31\" (core func (;51;)))\n  (alias core export 0 \"32\" (core func (;52;)))\n  (alias core export 0 \"33\" (core func (;53;)))\n  (alias core export 0 \"34\" (core func (;54;)))\n  (alias core export 0 \"35\" (core func (;55;)))\n  (alias core export 0 \"36\" (core func (;56;)))\n  (alias export 8 \"[method]outgoing-request.headers\" (func (;16;)))\n  (core func (;57;) (canon lower (func 16)))\n  (alias export 8 \"[constructor]request-options\" (func (;17;)))\n  (core func (;58;) (canon lower (func 17)))\n  (alias core export 0 \"37\" (core func (;59;)))\n  (alias export 8 \"[method]request-options.set-connect-timeout\" (func (;18;)))\n  (core func (;60;) (canon lower (func 18)))\n  (alias core export 0 \"38\" (core func (;61;)))\n  (alias export 8 \"[method]request-options.set-first-byte-timeout\" (func (;19;)))\n  (core func (;62;) (canon lower (func 19)))\n  (alias core export 0 \"39\" (core func (;63;)))\n  (alias export 8 \"[method]request-options.set-between-bytes-timeout\" (func (;20;)))\n  (core func (;64;) (canon lower (func 20)))\n  (alias core export 0 \"40\" (core func (;65;)))\n  (alias export 8 \"[method]incoming-response.status\" (func (;21;)))\n  (core func (;66;) (canon lower (func 21)))\n  (alias export 8 \"[method]incoming-response.headers\" (func (;22;)))\n  (core func (;67;) (canon lower (func 22)))\n  (alias core export 0 \"41\" (core func (;68;)))\n  (alias core export 0 \"42\" (core func (;69;)))\n  (alias export 8 \"[static]incoming-body.finish\" (func (;23;)))\n  (core func (;70;) (canon lower (func 23)))\n  (alias export 8 \"[method]future-trailers.subscribe\" (func (;24;)))\n  (core func (;71;) (canon lower (func 24)))\n  (alias core export 0 \"43\" (core func (;72;)))\n  (alias export 8 \"[constructor]outgoing-response\" (func (;25;)))\n  (core func (;73;) (canon lower (func 25)))\n  (alias export 8 \"[method]outgoing-response.status-code\" (func (;26;)))\n  (core func (;74;) (canon lower (func 26)))\n  (alias export 8 \"[method]outgoing-response.set-status-code\" (func (;27;)))\n  (core func (;75;) (canon lower (func 27)))\n  (alias export 8 \"[method]outgoing-response.headers\" (func (;28;)))\n  (core func (;76;) (canon lower (func 28)))\n  (alias core export 0 \"44\" (core func (;77;)))\n  (alias core export 0 \"45\" (core func (;78;)))\n  (alias core export 0 \"46\" (core func (;79;)))\n  (alias export 8 \"[method]future-incoming-response.subscribe\" (func (;29;)))\n  (core func (;80;) (canon lower (func 29)))\n  (alias core export 0 \"47\" (core func (;81;)))\n  (alias core export 0 \"48\" (core func (;82;)))\n  (alias export 8 \"fields\" (type (;32;)))\n  (core func (;83;) (canon resource.drop 32))\n  (alias export 8 \"incoming-request\" (type (;33;)))\n  (core func (;84;) (canon resource.drop 33))\n  (alias export 8 \"outgoing-request\" (type (;34;)))\n  (core func (;85;) (canon resource.drop 34))\n  (alias export 8 \"request-options\" (type (;35;)))\n  (core func (;86;) (canon resource.drop 35))\n  (alias export 8 \"response-outparam\" (type (;36;)))\n  (core func (;87;) (canon resource.drop 36))\n  (alias export 8 \"incoming-response\" (type (;37;)))\n  (core func (;88;) (canon resource.drop 37))\n  (alias export 8 \"incoming-body\" (type (;38;)))\n  (core func (;89;) (canon resource.drop 38))\n  (alias export 8 \"future-trailers\" (type (;39;)))\n  (core func (;90;) (canon resource.drop 39))\n  (alias export 8 \"outgoing-response\" (type (;40;)))\n  (core func (;91;) (canon resource.drop 40))\n  (alias export 8 \"outgoing-body\" (type (;41;)))\n  (core func (;92;) (canon resource.drop 41))\n  (alias export 8 \"future-incoming-response\" (type (;42;)))\n  (core func (;93;) (canon resource.drop 42))\n  (core instance (;9;)\n    (export \"[constructor]fields\" (func 32))\n    (export \"[static]fields.from-list\" (func 33))\n    (export \"[method]fields.get\" (func 34))\n    (export \"[method]fields.has\" (func 35))\n    (export \"[method]fields.set\" (func 36))\n    (export \"[method]fields.delete\" (func 37))\n    (export \"[method]fields.append\" (func 38))\n    (export \"[method]fields.entries\" (func 39))\n    (export \"[method]fields.clone\" (func 40))\n    (export \"[method]incoming-request.method\" (func 41))\n    (export \"[method]incoming-request.path-with-query\" (func 42))\n    (export \"[method]incoming-request.scheme\" (func 43))\n    (export \"[method]incoming-request.authority\" (func 44))\n    (export \"[method]incoming-request.headers\" (func 45))\n    (export \"[method]incoming-request.consume\" (func 46))\n    (export \"[constructor]outgoing-request\" (func 47))\n    (export \"[method]outgoing-request.body\" (func 48))\n    (export \"[method]outgoing-request.method\" (func 49))\n    (export \"[method]outgoing-request.set-method\" (func 50))\n    (export \"[method]outgoing-request.path-with-query\" (func 51))\n    (export \"[method]outgoing-request.set-path-with-query\" (func 52))\n    (export \"[method]outgoing-request.scheme\" (func 53))\n    (export \"[method]outgoing-request.set-scheme\" (func 54))\n    (export \"[method]outgoing-request.authority\" (f",
      "unc 55))\n    (export \"[method]outgoing-request.set-authority\" (func 56))\n    (export \"[method]outgoing-request.headers\" (func 57))\n    (export \"[constructor]request-options\" (func 58))\n    (export \"[method]request-options.connect-timeout\" (func 59))\n    (export \"[method]request-options.set-connect-timeout\" (func 60))\n    (export \"[method]request-options.first-byte-timeout\" (func 61))\n    (export \"[method]request-options.set-first-byte-timeout\" (func 62))\n    (export \"[method]request-options.between-bytes-timeout\" (func 63))\n    (export \"[method]request-options.set-between-bytes-timeout\" (func 64))\n    (export \"[static]response-outparam.set\" (func 65))\n    (export \"[method]incoming-response.status\" (func 66))\n    (export \"[method]incoming-response.headers\" (func 67))\n    (export \"[method]incoming-response.consume\" (func 68))\n    (export \"[method]incoming-body.stream\" (func 69))\n    (export \"[static]incoming-body.finish\" (func 70))\n    (export \"[method]future-trailers.subscribe\" (func 71))\n    (export \"[method]future-trailers.get\" (func 72))\n    (export \"[constructor]outgoing-response\" (func 73))\n    (export \"[method]outgoing-response.status-code\" (func 74))\n    (export \"[method]outgoing-response.set-status-code\" (func 75))\n    (export \"[method]outgoing-response.headers\" (func 76))\n    (export \"[method]outgoing-response.body\" (func 77))\n    (export \"[method]outgoing-body.write\" (func 78))\n    (export \"[static]outgoing-body.finish\" (func 79))\n    (export \"[method]future-incoming-response.subscribe\" (func 80))\n    (export \"[method]future-incoming-response.get\" (func 81))\n    (export \"http-error-code\" (func 82))\n    (export \"fields_drop\" (func 83))\n    (export \"incoming-request_drop\" (func 84))\n    (export \"outgoing-request_drop\" (func 85))\n    (export \"request-options_drop\" (func 86))\n    (export \"response-outparam_drop\" (func 87))\n    (export \"incoming-response_drop\" (func 88))\n    (export \"incoming-body_drop\" (func 89))\n    (export \"future-trailers_drop\" (func 90))\n    (export \"outgoing-response_drop\" (func 91))\n    (export \"outgoing-body_drop\" (func 92))\n    (export \"future-incoming-response_drop\" (func 93))\n  )\n  (alias core export 0 \"49\" (core func (;94;)))\n  (core instance (;10;)\n    (export \"handle\" (func 94))\n  )\n  (alias core export 0 \"50\" (core func (;95;)))\n  (alias core export 0 \"51\" (core func (;96;)))\n  (core instance (;11;)\n    (export \"now\" (func 95))\n    (export \"resolution\" (func 96))\n  )\n  (core instance (;12;) (instantiate 0\n      (with \"cm32p2|wasi:random/random@0.2\" (instance 1))\n      (with \"cm32p2|wasi:io/error@0.2\" (instance 2))\n      (with \"cm32p2|wasi:io/poll@0.2\" (instance 3))\n      (with \"cm32p2|wasi:io/streams@0.2\" (instance 4))\n      (with \"cm32p2|wasi:cli/stdout@0.2\" (instance 5))\n      (with \"cm32p2|wasi:cli/stderr@0.2\" (instance 6))\n      (with \"cm32p2|wasi:cli/stdin@0.2\" (instance 7))\n      (with \"cm32p2|wasi:clocks/monotonic-clock@0.2\" (instance 8))\n      (with \"cm32p2|wasi:http/types@0.2\" (instance 9))\n      (with \"cm32p2|wasi:http/outgoing-handler@0.2\" (instance 10))\n      (with \"cm32p2|wasi:clocks/wall-clock@0.2\" (instance 11))\n    )\n  )\n  (alias core export 12 \"cm32p2_memory\" (core memory (;0;)))\n  (alias core export 0 \"$imports\" (core table (;0;)))\n  (alias export 0 \"get-random-bytes\" (func (;30;)))\n  (alias core export 12 \"cm32p2_realloc\" (core func (;97;)))\n  (core func (;98;) (canon lower (func 30) (memory 0) (realloc 97)))\n  (alias export 1 \"[method]error.to-debug-string\" (func (;31;)))\n  (core func (;99;) (canon lower (func 31) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 2 \"poll\" (func (;32;)))\n  (core func (;100;) (canon lower (func 32) (memory 0) (realloc 97)))\n  (alias export 3 \"[method]input-stream.read\" (func (;33;)))\n  (core func (;101;) (canon lower (func 33) (memory 0) (realloc 97)))\n  (alias export 3 \"[method]input-stream.blocking-read\" (func (;34;)))\n  (core func (;102;) (canon lower (func 34) (memory 0) (realloc 97)))\n  (alias export 3 \"[method]input-stream.skip\" (func (;35;)))\n  (core func (;103;) (canon lower (func 35) (memory 0)))\n  (alias export 3 \"[method]input-stream.blocking-skip\" (func (;36;)))\n  (core func (;104;) (canon lower (func 36) (memory 0)))\n  (alias export 3 \"[method]output-stream.check-write\" (func (;37;)))\n  (core func (;105;) (canon lower (func 37) (memory 0)))\n  (alias export 3 \"[method]output-stream.write\" (func (;38;)))\n  (core func (;106;) (canon lower (func 38) (memory 0)))\n  (alias export 3 \"[method]output-stream.blocking-write-and-flush\" (func (;39;)))\n  (core func (;107;) (canon lower (func 39) (memory 0)))\n  (alias export 3 \"[method]output-stream.flush\" (func (;40;)))\n  (core func (;108;) (canon lower (func 40) (memory 0)))\n  (alias export 3 \"[method]output-stream.blocking-flush\" (func (;41;)))\n  (core func (;109;) (canon lower (func 41) (memory 0)))\n  (alias export 3 \"[method]output-stream.write-zeroes\" (func (;42;)))\n  (core func (;110;) (canon lower (func 42) (memory 0)))\n  (alias export 3 \"[method]output-stream.blocking-write-zeroes-and-flush\" (func (;43;)))\n  (core func (;111;) (canon lower (func 43) (memory 0)))\n  (alias export 3 \"[method]output-stream.splice\" (func (;44;)))\n  (core func (;112;) (canon lower (func 44) (memory 0)))\n  (alias export 3 \"[method]output-stream.blocking-splice\" (func (;45;)))\n  (core func (;113;) (canon lower (func 45) (memory 0)))\n  (alias export 8 \"[static]fields.from-list\" (func (;46;)))\n  (core func (;114;) (canon lower (func 46) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]fields.get\" (func (;47;)))\n  (core func (;115;) (canon lower (func 47) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]fields.has\" (func (;48;)))\n  (core func (;116;) (canon lower (func 48) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]fields.set\" (func (;49;)))\n  (core func (;117;) (canon lower (func 49) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]fields.delete\" (func (;50;)))\n  (core func (;118;) (canon lower (func 50) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]fields.append\" (func (;51;)))\n  (core func (;119;) (canon lower (func 51) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]fields.entries\" (func (;52;)))\n  (core func (;120;) (canon lower (func 52) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]incoming-request.method\" (func (;53;)))\n  (core func (;121;) (canon lower (func 53) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]incoming-request.path-with-query\" (func (;54;)))\n  (core func (;122;) (canon lower (func 54) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]incoming-request.scheme\" (func (;55;)))\n  (core func (;123;) (canon lower (func 55) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]incoming-request.authority\" (func (;56;)))\n  (core func (;124;) (canon lower (func 56) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]incoming-request.consume\" (func (;57;)))\n  (core func (;125;) (canon lower (func 57) (memory 0)))\n  (alias export 8 \"[method]outgoing-request.body\" (func (;58;)))\n  (core func (;126;) (canon lower (func 58) (memory 0)))\n  (alias export 8 \"[method]outgoing-request.method\" (func (;59;)))\n  (core func (;127;) (canon lower (func 59) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-request.set-method\" (func (;60;)))\n  (core func (;128;) (canon lower (func 60) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-request.path-with-query\" (func (;61;)))\n  (core func (;129;) (canon lower (func 61) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-request.set-path-with-query\" (func (;62;)))\n  (core func (;130;) (canon lower (func 62) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-request.scheme\" (func (;63;)))\n  (core func (;131;) (canon lower (func 63) (memory 0) (realloc 97) string-enco",
      "ding=utf8))\n  (alias export 8 \"[method]outgoing-request.set-scheme\" (func (;64;)))\n  (core func (;132;) (canon lower (func 64) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-request.authority\" (func (;65;)))\n  (core func (;133;) (canon lower (func 65) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-request.set-authority\" (func (;66;)))\n  (core func (;134;) (canon lower (func 66) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]request-options.connect-timeout\" (func (;67;)))\n  (core func (;135;) (canon lower (func 67) (memory 0)))\n  (alias export 8 \"[method]request-options.first-byte-timeout\" (func (;68;)))\n  (core func (;136;) (canon lower (func 68) (memory 0)))\n  (alias export 8 \"[method]request-options.between-bytes-timeout\" (func (;69;)))\n  (core func (;137;) (canon lower (func 69) (memory 0)))\n  (alias export 8 \"[static]response-outparam.set\" (func (;70;)))\n  (core func (;138;) (canon lower (func 70) (memory 0) string-encoding=utf8))\n  (alias export 8 \"[method]incoming-response.consume\" (func (;71;)))\n  (core func (;139;) (canon lower (func 71) (memory 0)))\n  (alias export 8 \"[method]incoming-body.stream\" (func (;72;)))\n  (core func (;140;) (canon lower (func 72) (memory 0)))\n  (alias export 8 \"[method]future-trailers.get\" (func (;73;)))\n  (core func (;141;) (canon lower (func 73) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]outgoing-response.body\" (func (;74;)))\n  (core func (;142;) (canon lower (func 74) (memory 0)))\n  (alias export 8 \"[method]outgoing-body.write\" (func (;75;)))\n  (core func (;143;) (canon lower (func 75) (memory 0)))\n  (alias export 8 \"[static]outgoing-body.finish\" (func (;76;)))\n  (core func (;144;) (canon lower (func 76) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"[method]future-incoming-response.get\" (func (;77;)))\n  (core func (;145;) (canon lower (func 77) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 8 \"http-error-code\" (func (;78;)))\n  (core func (;146;) (canon lower (func 78) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"handle\" (func (;79;)))\n  (core func (;147;) (canon lower (func 79) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 10 \"now\" (func (;80;)))\n  (core func (;148;) (canon lower (func 80) (memory 0)))\n  (alias export 10 \"resolution\" (func (;81;)))\n  (core func (;149;) (canon lower (func 81) (memory 0)))\n  (core instance (;13;)\n    (export \"$imports\" (table 0))\n    (export \"0\" (func 98))\n    (export \"1\" (func 99))\n    (export \"2\" (func 100))\n    (export \"3\" (func 101))\n    (export \"4\" (func 102))\n    (export \"5\" (func 103))\n    (export \"6\" (func 104))\n    (export \"7\" (func 105))\n    (export \"8\" (func 106))\n    (export \"9\" (func 107))\n    (export \"10\" (func 108))\n    (export \"11\" (func 109))\n    (export \"12\" (func 110))\n    (export \"13\" (func 111))\n    (export \"14\" (func 112))\n    (export \"15\" (func 113))\n    (export \"16\" (func 114))\n    (export \"17\" (func 115))\n    (export \"18\" (func 116))\n    (export \"19\" (func 117))\n    (export \"20\" (func 118))\n    (export \"21\" (func 119))\n    (export \"22\" (func 120))\n    (export \"23\" (func 121))\n    (export \"24\" (func 122))\n    (export \"25\" (func 123))\n    (export \"26\" (func 124))\n    (export \"27\" (func 125))\n    (export \"28\" (func 126))\n    (export \"29\" (func 127))\n    (export \"30\" (func 128))\n    (export \"31\" (func 129))\n    (export \"32\" (func 130))\n    (export \"33\" (func 131))\n    (export \"34\" (func 132))\n    (export \"35\" (func 133))\n    (export \"36\" (func 134))\n    (export \"37\" (func 135))\n    (export \"38\" (func 136))\n    (export \"39\" (func 137))\n    (export \"40\" (func 138))\n    (export \"41\" (func 139))\n    (export \"42\" (func 140))\n    (export \"43\" (func 141))\n    (export \"44\" (func 142))\n    (export \"45\" (func 143))\n    (export \"46\" (func 144))\n    (export \"47\" (func 145))\n    (export \"48\" (func 146))\n    (export \"49\" (func 147))\n    (export \"50\" (func 148))\n    (export \"51\" (func 149))\n  )\n  (core instance (;14;) (instantiate 2\n      (with \"\" (instance 13))\n    )\n  )\n  (alias core export 12 \"cm32p2_initialize\" (core func (;150;)))\n  (core module (;3;)\n    (type (;0;) (func))\n    (import \"\" \"\" (func (;0;) (type 0)))\n    (start 0)\n  )\n  (core instance (;15;)\n    (export \"\" (func 150))\n  )\n  (core instance (;16;) (instantiate 3\n      (with \"\" (instance 15))\n    )\n  )\n  (type (;43;) (own 26))\n  (type (;44;) (own 27))\n  (type (;45;) (func (param \"request\" 43) (param \"response-out\" 44)))\n  (alias core export 12 \"cm32p2|wasi:http/incoming-handler@0.2|handle\" (core func (;151;)))\n  (alias core export 12 \"cm32p2|wasi:http/incoming-handler@0.2|handle_post\" (core func (;152;)))\n  (func (;82;) (type 45) (canon lift (core func 151) (post-return 152)))\n  (alias export 8 \"incoming-request\" (type (;46;)))\n  (alias export 8 \"response-outparam\" (type (;47;)))\n  (component (;0;)\n    (import \"import-type-incoming-request\" (type (;0;) (sub resource)))\n    (import \"import-type-response-outparam\" (type (;1;) (sub resource)))\n    (import \"import-type-incoming-request0\" (type (;2;) (eq 0)))\n    (type (;3;) (own 2))\n    (import \"import-type-response-outparam0\" (type (;4;) (eq 1)))\n    (type (;5;) (own 4))\n    (type (;6;) (func (param \"request\" 3) (param \"response-out\" 5)))\n    (import \"import-func-handle\" (func (;0;) (type 6)))\n    (export (;7;) \"incoming-request\" (type 0))\n    (export (;8;) \"response-outparam\" (type 1))\n    (type (;9;) (own 7))\n    (type (;10;) (own 8))\n    (type (;11;) (func (param \"request\" 9) (param \"response-out\" 10)))\n    (export (;1;) \"handle\" (func 0) (func (type 11)))\n  )\n  (instance (;11;) (instantiate 0\n      (with \"import-func-handle\" (func 82))\n      (with \"import-type-incoming-request\" (type 46))\n      (with \"import-type-response-outparam\" (type 47))\n      (with \"import-type-incoming-request0\" (type 26))\n      (with \"import-type-response-outparam0\" (type 27))\n    )\n  )\n  (export (;12;) \"wasi:http/incoming-handler@0.2.0\" (instance 11))\n  (@producers\n    (processed-by \"wit-component\" \"0.229.0\")\n  )\n)\n",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "11", "wasi:random/random@0.2.0", "instance", "interface", "wasi:random/random@0.2.0",
      "0", "2", "get-random-bytes", "func", "function", "false", "1", "len", "scalar",
      "u64", "some", "list", "scalar", "u8", "get-random-u64", "func", "function",
      "false", "0", "some", "scalar", "u64", "wasi:io/error@0.2.0", "instance", "interface",
      "wasi:io/error@0.2.0", "0", "2", "error", "type", "resource", "0", "[method]error.to-debug-string",
      "func", "function", "false", "1", "self", "borrow", "0", "some", "scalar",
      "string", "wasi:io/poll@0.2.0", "instance", "interface", "wasi:io/poll@0.2.0",
      "0", "4", "pollable", "type", "resource", "1", "[method]pollable.ready", "func",
      "function", "false", "1", "self", "borrow", "1", "some", "scalar", "bool",
      "[method]pollable.block", "func", "function", "false", "1", "self", "borrow",
      "1", "none", "poll", "func", "function", "false", "1", "in", "list", "borrow",
      "1", "some", "list", "scalar", "u32", "wasi:io/streams@0.2.0", "instance",
      "interface", "wasi:io/streams@0.2.0", "2", "error", "error", "wasi:io/error@0.2.0",
      "pollable", "pollable", "wasi:io/poll@0.2.0", "20", "input-stream", "type",
      "resource", "2", "error", "type", "resource", "0", "stream-error", "type",
      "variant", "2", "last-operation-failed", "some", "own", "0", "closed", "none",
      "pollable", "type", "resource", "1", "output-stream", "type", "resource", "3",
      "[method]input-stream.read", "func", "function", "false", "2", "self", "borrow",
      "2", "len", "scalar", "u64", "some", "result", "some", "list", "scalar", "u8",
      "some", "variant", "2", "last-operation-failed", "some", "own", "0", "closed",
      "none", "[method]input-stream.blocking-read", "func", "function", "false",
      "2", "self", "borrow", "2", "len", "scalar", "u64", "some", "result", "some",
      "list", "scalar", "u8", "some", "variant", "2", "last-operation-failed", "some",
      "own", "0", "closed", "none", "[method]input-stream.skip", "func", "function",
      "false", "2", "self", "borrow", "2", "len", "scalar", "u64", "some", "result",
      "some", "scalar", "u64", "some", "variant", "2", "last-operation-failed", "some",
      "own", "0", "closed", "none", "[method]input-stream.blocking-skip", "func",
      "function", "false", "2", "self", "borrow", "2", "len", "scalar", "u64", "some",
      "result", "some", "scalar", "u64", "some", "variant", "2", "last-operation-failed",
      "some", "own", "0", "closed", "none", "[method]input-stream.subscribe", "func",
      "function", "false", "1", "self", "borrow", "2", "some", "own", "1", "[method]output-stream.check-write",
      "func", "function", "false", "1", "self", "borrow", "3", "some", "result",
      "some", "scalar", "u64", "some", "variant", "2", "last-operation-failed", "some",
      "own", "0", "closed", "none", "[method]output-stream.write", "func", "function",
      "false", "2", "self", "borrow", "3", "contents", "list", "scalar", "u8", "some",
      "result", "none", "some", "variant", "2", "last-operation-failed", "some",
      "own", "0", "closed", "none", "[method]output-stream.blocking-write-and-flush",
      "func", "function", "false", "2", "self", "borrow", "3", "contents", "list",
      "scalar", "u8", "some", "result", "none", "some", "variant", "2", "last-operation-failed",
      "some", "own", "0", "closed", "none", "[method]output-stream.flush", "func",
      "function", "false", "1", "self", "borrow", "3", "some", "result", "none",
      "some", "variant", "2", "last-operation-failed", "some", "own", "0", "closed",
      "none", "[method]output-stream.blocking-flush", "func", "function", "false",
      "1", "self", "borrow", "3", "some", "result", "none", "some", "variant", "2",
      "last-operation-failed", "some", "own", "0", "closed", "none", "[method]output-stream.subscribe",
      "func", "function", "false", "1", "self", "borrow", "3", "some", "own", "1",
      "[method]output-stream.write-zeroes", "func", "function", "false", "2", "self",
      "borrow", "3", "len", "scalar", "u64", "some", "result", "none", "some", "variant",
      "2", "last-operation-failed", "some", "own", "0", "closed", "none", "[method]output-stream.blocking-write-zeroes-and-flush",
      "func", "function", "false", "2", "self", "borrow", "3", "len", "scalar", "u64",
      "some", "result", "none", "some", "variant", "2", "last-operation-failed",
      "some", "own", "0", "closed", "none", "[method]output-stream.splice", "func",
      "function", "false", "3", "self", "borrow", "3", "src", "borrow", "2", "len",
      "scalar", "u64", "some", "result", "some", "scalar", "u64", "some", "variant",
      "2", "last-operation-failed", "some", "own", "0", "closed", "none", "[method]output-stream.blocking-splice",
      "func", "function", "false", "3", "self", "borrow", "3", "src", "borrow", "2",
      "len", "scalar", "u64", "some", "result", "some", "scalar", "u64", "some",
      "variant", "2", "last-operation-failed", "some", "own", "0", "closed", "none",
      "wasi:cli/stdout@0.2.0", "instance", "interface", "wasi:cli/stdout@0.2.0",
      "1", "output-stream", "output-stream", "wasi:io/streams@0.2.0", "2", "output-stream",
      "type", "resource", "3", "get-stdout", "func", "function", "false", "0", "some",
      "own", "3", "wasi:cli/stderr@0.2.0", "instance", "interface", "wasi:cli/stderr@0.2.0",
      "1", "output-stream", "output-stream", "wasi:io/streams@0.2.0", "2", "output-stream",
      "type", "resource", "3", "get-stderr", "func", "function", "false", "0", "some",
      "own", "3", "wasi:cli/stdin@0.2.0", "instance", "interface", "wasi:cli/stdin@0.2.0",
      "1", "input-stream", "input-stream", "wasi:io/streams@0.2.0", "2", "input-stream",
      "type", "resource", "2", "get-stdin", "func", "function", "false", "0", "some",
      "own", "2", "wasi:clocks/monotonic-clock@0.2.0", "instance", "interface", "wasi:clocks/monotonic-clock@0.2.0",
      "1", "pollable", "pollable", "wasi:io/poll@0.2.0", "7", "instant", "type",
      "scalar", "u64", "duration", "type", "scalar", "u64", "pollable", "type", "resource",
      "1", "now", "func", "function", "false", "0", "some", "scalar", "u64", "resolution",
      "func", "function", "false", "0", "some", "scalar", "u64", "subscribe-instant",
      "func", "function", "false", "1", "when", "scalar", "u64", "some", "own", "1",
      "subscribe-duration", "func", "function", "false", "1", "when", "scalar", "u64",
      "some", "own", "1", "wasi:http/types@0.2.0", "instance", "interface", "wasi:http/types@0.2.0",
      "5", "duration", "duration", "wasi:clocks/monotonic-clock@0.2.0", "input-stream",
      "input-stream", "wasi:io/streams@0.2.0", "pollable", "pollable", "wasi:io/poll@0.2.0",
      "output-stream", "output-stream", "wasi:io/streams@0.2.0", "io-error", "error",
      "wasi:io/error@0.2.0", "79", "fields", "type", "resource", "4", "field-key",
      "type", "scalar", "string", "field-value", "type", "list", "scalar", "u8",
      "header-error", "type", "variant", "3", "invalid-syntax", "none", "forbidden",
      "none", "immutable", "none", "incoming-request", "type", "resource", "5", "method",
      "type", "variant", "10", "get", "none", "head", "none", "post", "none", "put",
      "none", "delete", "none", "connect", "none", "options", "none", "trace", "none",
      "patch", "none", "other", "some", "scalar", "string", "scheme", "type", "variant",
      "3", "HTTP", "none", "HTTPS", "none", "other", "some", "scalar", "string",
      "headers", "type", "resource", "4", "incoming-body", "type", "resource", "6",
      "outgoing-request", "type", "resource", "7", "outgoing-body", "type", "resource",
      "8", "request-options", "type", "resource", "9", "duration", "type", "scalar",
      "u64", "response-outparam", "type", "resource", "10", "outgoing-response",
      "type", "resource", "11", "DNS-error-payload", "type", "record", "2", "rcode",
      "option", "scalar", "string", "info-code", "option", "scalar", "u16", "TLS-alert-received-payload",
      "type", "record", "2", "alert-id", "option", "scalar", "u8", "alert-message",
      "option", "scalar", "string", "field-size-payload", "type", "record", "2",
      "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "error-code", "type", "variant", "39", "DNS-timeout", "none", "DNS-error",
      "some", "record", "2", "rcode", "option", "scalar", "string", "info-code",
      "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "incoming-response", "type", "resource", "12", "status-code",
      "type", "scalar", "u16", "input-stream", "type", "resource", "2", "future-trailers",
      "type", "resource", "13", "pollable", "type", "resource", "1", "trailers",
      "type", "resource", "4", "output-stream", "type", "resource", "3", "future-incoming-response",
      "type", "resource", "14", "io-error", "type", "resource", "0", "[constructor]fields",
      "func", "function", "false", "0", "some", "own", "4", "[static]fields.from-list",
      "func", "function", "false", "1", "entries", "list", "tuple", "2", "scalar",
      "string", "list", "scalar", "u8", "some", "result", "some", "own", "4", "some",
      "variant", "3", "invalid-syntax", "none", "forbidden", "none", "immutable",
      "none", "[method]fields.get", "func", "function", "false", "2", "self", "borrow",
      "4", "name", "scalar", "string", "some", "list", "list", "scalar", "u8", "[method]fields.has",
      "func", "function", "false", "2", "self", "borrow", "4", "name", "scalar",
      "string", "some", "scalar", "bool", "[method]fields.set", "func", "function",
      "false", "3", "self", "borrow", "4", "name", "scalar", "string", "value", "list",
      "list", "scalar", "u8", "some", "result", "none", "some", "variant", "3", "invalid-syntax",
      "none", "forbidden", "none", "immutable", "none", "[method]fields.delete",
      "func", "function", "false", "2", "self", "borrow", "4", "name", "scalar",
      "string", "some", "result", "none", "some", "variant", "3", "invalid-syntax",
      "none", "forbidden", "none", "immutable", "none", "[method]fields.append",
      "func", "function", "false", "3", "self", "borrow", "4", "name", "scalar",
      "string", "value", "list", "scalar", "u8", "some", "result", "none", "some",
      "variant", "3", "invalid-syntax", "none", "forbidden", "none", "immutable",
      "none", "[method]fields.entries", "func", "function", "false", "1", "self",
      "borrow", "4", "some", "list", "tuple", "2", "scalar", "string", "list", "scalar",
      "u8", "[method]fields.clone", "func", "function", "false", "1", "self", "borrow",
      "4", "some", "own", "4", "[method]incoming-request.method", "func", "function",
      "false", "1", "self", "borrow", "5", "some", "variant", "10", "get", "none",
      "head", "none", "post", "none", "put", "none", "delete", "none", "connect",
      "none", "options", "none", "trace", "none", "patch", "none", "other", "some",
      "scalar", "string", "[method]incoming-request.path-with-query", "func", "function",
      "false", "1", "self", "borrow", "5", "some", "option", "scalar", "string",
      "[method]incoming-request.scheme", "func", "function", "false", "1", "self",
      "borrow", "5", "some", "option", "variant", "3", "HTTP", "none", "HTTPS", "none",
      "other", "some", "scalar", "string", "[method]incoming-request.authority",
      "func", "function", "false", "1", "self", "borrow", "5", "some", "option",
      "scalar", "string", "[method]incoming-request.headers", "func", "function",
      "false", "1", "self", "borrow", "5", "some", "own", "4", "[method]incoming-request.consume",
      "func", "function", "false", "1", "self", "borrow", "5", "some", "result",
      "some", "own", "6", "none", "[constructor]outgoing-request", "func", "function",
      "false", "1", "headers", "own", "4", "some", "own", "7", "[method]outgoing-request.body",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "result",
      "some", "own", "8", "none", "[method]outgoing-request.method", "func", "function",
      "false", "1", "self", "borrow", "7", "some", "variant", "10", "get", "none",
      "head", "none", "post", "none", "put", "none", "delete", "none", "connect",
      "none", "options", "none", "trace", "none", "patch", "none", "other", "some",
      "scalar", "string", "[method]outgoing-request.set-method", "func", "function",
      "false", "2", "self", "borrow", "7", "method", "variant", "10", "get", "none",
      "head", "none", "post", "none", "put", "none", "delete", "none", "connect",
      "none", "options", "none", "trace", "none", "patch", "none", "other", "some",
      "scalar", "string", "some", "result", "none", "none", "[method]outgoing-request.path-with-query",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "option",
      "scalar", "string", "[method]outgoing-request.set-path-with-query", "func",
      "function", "false", "2", "self", "borrow", "7", "path-with-query", "option",
      "scalar", "string", "some", "result", "none", "none", "[method]outgoing-request.scheme",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "option",
      "variant", "3", "HTTP", "none", "HTTPS", "none", "other", "some", "scalar",
      "string", "[method]outgoing-request.set-scheme", "func", "function", "false",
      "2", "self", "borrow", "7", "scheme", "option", "variant", "3", "HTTP", "none",
      "HTTPS", "none", "other", "some", "scalar", "string", "some", "result", "none",
      "none", "[method]outgoing-request.authority", "func", "function", "false",
      "1", "self", "borrow", "7", "some", "option", "scalar", "string", "[method]outgoing-request.set-authority",
      "func", "function", "false", "2", "self", "borrow", "7", "authority", "option",
      "scalar", "string", "some", "result", "none", "none", "[method]outgoing-request.headers",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "own", "4",
      "[constructor]request-options", "func", "function", "false", "0", "some", "own",
      "9", "[method]request-options.connect-timeout", "func", "function", "false",
      "1", "self", "borrow", "9", "some", "option", "scalar", "u64", "[method]request-options.set-connect-timeout",
      "func", "function", "false", "2", "self", "borrow", "9", "duration", "option",
      "scalar", "u64", "some", "result", "none", "none", "[method]request-options.first-byte-timeout",
      "func", "function", "false", "1", "self", "borrow", "9", "some", "option",
      "scalar", "u64", "[method]request-options.set-first-byte-timeout", "func",
      "function", "false", "2", "self", "borrow", "9", "duration", "option", "scalar",
      "u64", "some", "result", "none", "none", "[method]request-options.between-bytes-timeout",
      "func", "function", "false", "1", "self", "borrow", "9", "some", "option",
      "scalar", "u64", "[method]request-options.set-between-bytes-timeout", "func",
      "function", "false", "2", "self", "borrow", "9", "duration", "option", "scalar",
      "u64", "some", "result", "none", "none", "[static]response-outparam.set", "func",
      "function", "false", "2", "param", "own", "10", "response", "result", "some",
      "own", "11", "some", "variant", "39", "DNS-timeout", "none", "DNS-error", "some",
      "record", "2", "rcode", "option", "scalar", "string", "info-code", "option",
      "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "none", "[method]incoming-response.status", "func", "function",
      "false", "1", "self", "borrow", "12", "some", "scalar", "u16", "[method]incoming-response.headers",
      "func", "function", "false", "1", "self", "borrow", "12", "some", "own", "4",
      "[method]incoming-response.consume", "func", "function", "false", "1", "self",
      "borrow", "12", "some", "result", "some", "own", "6", "none", "[method]incoming-body.stream",
      "func", "function", "false", "1", "self", "borrow", "6", "some", "result",
      "some", "own", "2", "none", "[static]incoming-body.finish", "func", "function",
      "false", "1", "this", "own", "6", "some", "own", "13", "[method]future-trailers.subscribe",
      "func", "function", "false", "1", "self", "borrow", "13", "some", "own", "1",
      "[method]future-trailers.get", "func", "function", "false", "1", "self", "borrow",
      "13", "some", "option", "result", "some", "result", "some", "option", "own",
      "4", "some", "variant", "39", "DNS-timeout", "none", "DNS-error", "some", "record",
      "2", "rcode", "option", "scalar", "string", "info-code", "option", "scalar",
      "u16", "destination-not-found", "none", "destination-unavailable", "none",
      "destination-IP-prohibited", "none", "destination-IP-unroutable", "none", "connection-refused",
      "none", "connection-terminated", "none", "connection-timeout", "none", "connection-read-timeout",
      "none", "connection-write-timeout", "none", "connection-limit-reached", "none",
      "TLS-protocol-error", "none", "TLS-certificate-error", "none", "TLS-alert-received",
      "some", "record", "2", "alert-id", "option", "scalar", "u8", "alert-message",
      "option", "scalar", "string", "HTTP-request-denied", "none", "HTTP-request-length-required",
      "none", "HTTP-request-body-size", "some", "option", "scalar", "u64", "HTTP-request-method-invalid",
      "none", "HTTP-request-URI-invalid", "none", "HTTP-request-URI-too-long", "none",
      "HTTP-request-header-section-size", "some", "option", "scalar", "u32", "HTTP-request-header-size",
      "some", "option", "record", "2", "field-name", "option", "scalar", "string",
      "field-size", "option", "scalar", "u32", "HTTP-request-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-incomplete", "none", "HTTP-response-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-header-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-body-size", "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "none", "[constructor]outgoing-response", "func", "function",
      "false", "1", "headers", "own", "4", "some", "own", "11", "[method]outgoing-response.status-code",
      "func", "function", "false", "1", "self", "borrow", "11", "some", "scalar",
      "u16", "[method]outgoing-response.set-status-code", "func", "function", "false",
      "2", "self", "borrow", "11", "status-code", "scalar", "u16", "some", "result",
      "none", "none", "[method]outgoing-response.headers", "func", "function", "false",
      "1", "self", "borrow", "11", "some", "own", "4", "[method]outgoing-response.body",
      "func", "function", "false", "1", "self", "borrow", "11", "some", "result",
      "some", "own", "8", "none", "[method]outgoing-body.write", "func", "function",
      "false", "1", "self", "borrow", "8", "some", "result", "some", "own", "3",
      "none", "[static]outgoing-body.finish", "func", "function", "false", "2", "this",
      "own", "8", "trailers", "option", "own", "4", "some", "result", "none", "some",
      "variant", "39", "DNS-timeout", "none", "DNS-error", "some", "record", "2",
      "rcode", "option", "scalar", "string", "info-code", "option", "scalar", "u16",
      "destination-not-found", "none", "destination-unavailable", "none", "destination-IP-prohibited",
      "none", "destination-IP-unroutable", "none", "connection-refused", "none",
      "connection-terminated", "none", "connection-timeout", "none", "connection-read-timeout",
      "none", "connection-write-timeout", "none", "connection-limit-reached", "none",
      "TLS-protocol-error", "none", "TLS-certificate-error", "none", "TLS-alert-received",
      "some", "record", "2", "alert-id", "option", "scalar", "u8", "alert-message",
      "option", "scalar", "string", "HTTP-request-denied", "none", "HTTP-request-length-required",
      "none", "HTTP-request-body-size", "some", "option", "scalar", "u64", "HTTP-request-method-invalid",
      "none", "HTTP-request-URI-invalid", "none", "HTTP-request-URI-too-long", "none",
      "HTTP-request-header-section-size", "some", "option", "scalar", "u32", "HTTP-request-header-size",
      "some", "option", "record", "2", "field-name", "option", "scalar", "string",
      "field-size", "option", "scalar", "u32", "HTTP-request-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-incomplete", "none", "HTTP-response-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-header-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-body-size", "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "[method]future-incoming-response.subscribe", "func", "function",
      "false", "1", "self", "borrow", "14", "some", "own", "1", "[method]future-incoming-response.get",
      "func", "function", "false", "1", "self", "borrow", "14", "some", "option",
      "result", "some", "result", "some", "own", "12", "some", "variant", "39", "DNS-timeout",
      "none", "DNS-error", "some", "record", "2", "rcode", "option", "scalar", "string",
      "info-code", "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "none", "http-error-code", "func", "function", "false",
      "1", "err", "borrow", "0", "some", "option", "variant", "39", "DNS-timeout",
      "none", "DNS-error", "some", "record", "2", "rcode", "option", "scalar", "string",
      "info-code", "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "wasi:http/outgoing-handler@0.2.0", "instance", "interface",
      "wasi:http/outgoing-handler@0.2.0", "4", "outgoing-request", "outgoing-request",
      "wasi:http/types@0.2.0", "request-options", "request-options", "wasi:http/types@0.2.0",
      "future-incoming-response", "future-incoming-response", "wasi:http/types@0.2.0",
      "error-code", "error-code", "wasi:http/types@0.2.0", "5", "outgoing-request",
      "type", "resource", "7", "request-options", "type", "resource", "9", "future-incoming-response",
      "type", "resource", "14", "error-code", "type", "variant", "39", "DNS-timeout",
      "none", "DNS-error", "some", "record", "2", "rcode", "option", "scalar", "string",
      "info-code", "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "handle", "func", "function", "false", "2", "request",
      "own", "7", "options", "option", "own", "9", "some", "result", "some", "own",
      "14", "some", "variant", "39", "DNS-timeout", "none", "DNS-error", "some",
      "record", "2", "rcode", "option", "scalar", "string", "info-code", "option",
      "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "wasi:clocks/wall-clock@0.2.0", "instance", "interface",
      "wasi:clocks/wall-clock@0.2.0", "0", "3", "datetime", "type", "record", "2",
      "seconds", "scalar", "u64", "nanoseconds", "scalar", "u32", "now", "func",
      "function", "false", "0", "some", "record", "2", "seconds", "scalar", "u64",
      "nanoseconds", "scalar", "u32", "resolution", "func", "function", "false",
      "0", "some", "record", "2", "seconds", "scalar", "u64", "nanoseconds", "scalar",
      "u32", "1", "out", "instance", "interface", "", "0", "1", "wasi:http/incoming-handler@0.2.0",
      "instance", "interface", "wasi:http/incoming-handler@0.2.0", "2", "incoming-request",
      "incoming-request", "wasi:http/types@0.2.0", "response-outparam", "response-outparam",
      "wasi:http/types@0.2.0", "3", "incoming-request", "type", "resource", "5",
      "response-outparam", "type", "resource", "10", "handle", "func", "function",
      "false", "2", "request", "own", "5", "response-out", "own", "10", "none",
    ])
  }
}

///|
test "nested composition http-0.2.3" {
  let source = "package test:app; let i = new test:nested {...}; export i as \"out\";"
  let bytes = http_component_0_2_3()
  let text = @verifier.decode_wat_component_package(
    [
      "(component\n  (type (;0;)\n    (instance\n      (export (;0;) \"pollable\" (type (sub resource)))\n      (type (;1;) (borrow 0))\n      (type (;2;) (func (param \"self\" 1) (result bool)))\n      (export (;0;) \"[method]pollable.ready\" (func (type 2)))\n      (type (;3;) (func (param \"self\" 1)))\n      (export (;1;) \"[method]pollable.block\" (func (type 3)))\n      (type (;4;) (list 1))\n      (type (;5;) (list u32))\n      (type (;6;) (func (param \"in\" 4) (result 5)))\n      (export (;2;) \"poll\" (func (type 6)))\n    )\n  )\n  (import \"wasi:io/poll@0.2.3\" (instance (;0;) (type 0)))\n  (alias export 0 \"pollable\" (type (;1;)))\n  (type (;2;)\n    (instance\n      (type (;0;) u64)\n      (export (;1;) \"instant\" (type (eq 0)))\n      (type (;2;) u64)\n      (export (;3;) \"duration\" (type (eq 2)))\n      (alias outer 1 1 (type (;4;)))\n      (export (;5;) \"pollable\" (type (eq 4)))\n      (type (;6;) (func (result 1)))\n      (export (;0;) \"now\" (func (type 6)))\n      (type (;7;) (func (result 3)))\n      (export (;1;) \"resolution\" (func (type 7)))\n      (type (;8;) (own 5))\n      (type (;9;) (func (param \"when\" 1) (result 8)))\n      (export (;2;) \"subscribe-instant\" (func (type 9)))\n      (type (;10;) (func (param \"when\" 3) (result 8)))\n      (export (;3;) \"subscribe-duration\" (func (type 10)))\n    )\n  )\n  (import \"wasi:clocks/monotonic-clock@0.2.3\" (instance (;1;) (type 2)))\n  (type (;3;)\n    (instance\n      (type (;0;) (record (field \"seconds\" u64) (field \"nanoseconds\" u32)))\n      (export (;1;) \"datetime\" (type (eq 0)))\n      (type (;2;) (func (result 1)))\n      (export (;0;) \"now\" (func (type 2)))\n      (export (;1;) \"resolution\" (func (type 2)))\n    )\n  )\n  (import \"wasi:clocks/wall-clock@0.2.3\" (instance (;2;) (type 3)))\n  (type (;4;)\n    (instance\n      (type (;0;) (list u8))\n      (type (;1;) (func (param \"len\" u64) (result 0)))\n      (export (;0;) \"get-random-bytes\" (func (type 1)))\n      (type (;2;) (func (result u64)))\n      (export (;1;) \"get-random-u64\" (func (type 2)))\n    )\n  )\n  (import \"wasi:random/random@0.2.3\" (instance (;3;) (type 4)))\n  (type (;5;)\n    (instance\n      (export (;0;) \"error\" (type (sub resource)))\n      (type (;1;) (borrow 0))\n      (type (;2;) (func (param \"self\" 1) (result string)))\n      (export (;0;) \"[method]error.to-debug-string\" (func (type 2)))\n    )\n  )\n  (import \"wasi:io/error@0.2.3\" (instance (;4;) (type 5)))\n  (alias export 4 \"error\" (type (;6;)))\n  (alias export 0 \"pollable\" (type (;7;)))\n  (type (;8;)\n    (instance\n      (export (;0;) \"input-stream\" (type (sub resource)))\n      (alias outer 1 6 (type (;1;)))\n      (export (;2;) \"error\" (type (eq 1)))\n      (type (;3;) (own 2))\n      (type (;4;) (variant (case \"last-operation-failed\" 3) (case \"closed\")))\n      (export (;5;) \"stream-error\" (type (eq 4)))\n      (alias outer 1 7 (type (;6;)))\n      (export (;7;) \"pollable\" (type (eq 6)))\n      (export (;8;) \"output-stream\" (type (sub resource)))\n      (type (;9;) (borrow 0))\n      (type (;10;) (list u8))\n      (type (;11;) (result 10 (error 5)))\n      (type (;12;) (func (param \"self\" 9) (param \"len\" u64) (result 11)))\n      (export (;0;) \"[method]input-stream.read\" (func (type 12)))\n      (export (;1;) \"[method]input-stream.blocking-read\" (func (type 12)))\n      (type (;13;) (result u64 (error 5)))\n      (type (;14;) (func (param \"self\" 9) (param \"len\" u64) (result 13)))\n      (export (;2;) \"[method]input-stream.skip\" (func (type 14)))\n      (export (;3;) \"[method]input-stream.blocking-skip\" (func (type 14)))\n      (type (;15;) (own 7))\n      (type (;16;) (func (param \"self\" 9) (result 15)))\n      (export (;4;) \"[method]input-stream.subscribe\" (func (type 16)))\n      (type (;17;) (borrow 8))\n      (type (;18;) (func (param \"self\" 17) (result 13)))\n      (export (;5;) \"[method]output-stream.check-write\" (func (type 18)))\n      (type (;19;) (result (error 5)))\n      (type (;20;) (func (param \"self\" 17) (param \"contents\" 10) (result 19)))\n      (export (;6;) \"[method]output-stream.write\" (func (type 20)))\n      (export (;7;) \"[method]output-stream.blocking-write-and-flush\" (func (type 20)))\n      (type (;21;) (func (param \"self\" 17) (result 19)))\n      (export (;8;) \"[method]output-stream.flush\" (func (type 21)))\n      (export (;9;) \"[method]output-stream.blocking-flush\" (func (type 21)))\n      (type (;22;) (func (param \"self\" 17) (result 15)))\n      (export (;10;) \"[method]output-stream.subscribe\" (func (type 22)))\n      (type (;23;) (func (param \"self\" 17) (param \"len\" u64) (result 19)))\n      (export (;11;) \"[method]output-stream.write-zeroes\" (func (type 23)))\n      (export (;12;) \"[method]output-stream.blocking-write-zeroes-and-flush\" (func (type 23)))\n      (type (;24;) (func (param \"self\" 17) (param \"src\" 9) (param \"len\" u64) (result 13)))\n      (export (;13;) \"[method]output-stream.splice\" (func (type 24)))\n      (export (;14;) \"[method]output-stream.blocking-splice\" (func (type 24)))\n    )\n  )\n  (import \"wasi:io/streams@0.2.3\" (instance (;5;) (type 8)))\n  (alias export 5 \"output-stream\" (type (;9;)))\n  (type (;10;)\n    (instance\n      (alias outer 1 9 (type (;0;)))\n      (export (;1;) \"output-stream\" (type (eq 0)))\n      (type (;2;) (own 1))\n      (type (;3;) (func (result 2)))\n      (export (;0;) \"get-stdout\" (func (type 3)))\n    )\n  )\n  (import \"wasi:cli/stdout@0.2.3\" (instance (;6;) (type 10)))\n  (alias export 5 \"output-stream\" (type (;11;)))\n  (type (;12;)\n    (instance\n      (alias outer 1 11 (type (;0;)))\n      (export (;1;) \"output-stream\" (type (eq 0)))\n      (type (;2;) (own 1))\n      (type (;3;) (func (result 2)))\n      (export (;0;) \"get-stderr\" (func (type 3)))\n    )\n  )\n  (import \"wasi:cli/stderr@0.2.3\" (instance (;7;) (type 12)))\n  (alias export 5 \"input-stream\" (type (;13;)))\n  (type (;14;)\n    (instance\n      (alias outer 1 13 (type (;0;)))\n      (export (;1;) \"input-stream\" (type (eq 0)))\n      (type (;2;) (own 1))\n      (type (;3;) (func (result 2)))\n      (export (;0;) \"get-stdin\" (func (type 3)))\n    )\n  )\n  (import \"wasi:cli/stdin@0.2.3\" (instance (;8;) (type 14)))\n  (alias export 1 \"duration\" (type (;15;)))\n  (alias export 5 \"input-stream\" (type (;16;)))\n  (alias export 0 \"pollable\" (type (;17;)))\n  (alias export 5 \"output-stream\" (type (;18;)))\n  (alias export 4 \"error\" (type (;19;)))\n  (type (;20;)\n    (instance\n      (export (;0;) \"fields\" (type (sub resource)))\n      (type (;1;) string)\n      (export (;2;) \"field-key\" (type (eq 1)))\n      (export (;3;) \"field-name\" (type (eq 2)))\n      (type (;4;) (list u8))\n      (export (;5;) \"field-value\" (type (eq 4)))\n      (type (;6;) (variant (case \"invalid-syntax\") (case \"forbidden\") (case \"immutable\")))\n      (export (;7;) \"header-error\" (type (eq 6)))\n      (export (;8;) \"incoming-request\" (type (sub resource)))\n      (type (;9;) (variant (case \"get\") (case \"head\") (case \"post\") (case \"put\") (case \"delete\") (case \"connect\") (case \"options\") (case \"trace\") (case \"patch\") (case \"other\" string)))\n      (export (;10;) \"method\" (type (eq 9)))\n      (type (;11;) (variant (case \"HTTP\") (case \"HTTPS\") (case \"other\" string)))\n      (export (;12;) \"scheme\" (type (eq 11)))\n      (export (;13;) \"headers\" (type (eq 0)))\n      (export (;14;) \"incoming-body\" (type (sub resource)))\n      (export (;15;) \"outgoing-request\" (type (sub resource)))\n      (export (;16;) \"outgoing-body\" (type (sub resource)))\n      (export (;17;) \"request-options\" (type (sub resource)))\n      (alias outer 1 15 (type (;18;)))\n      (export (;19;) \"duration\" (type (eq 18)))\n      (export (;20;) \"response-outparam\" (type (sub resource)))\n      (export (;21;) \"outgoing-response\" (type (sub resource)))\n      (type (;22;) (option string))\n      (type (;23;) (option u16))\n      (type (;24;) (record (field \"rcode\" 22) (field \"info-code\" 23)))\n      (export (;25;) \"DNS-error-payload\" (type (eq 24)))\n      (type (;26;) (option u8))\n      (type (;27;) (record (field \"alert-id\" 26) (field \"alert-message\" 22)))\n      (export (;28;) \"TLS-alert-received-payload\" (type (eq 27)))\n      (type (;29;) (option u32))\n      (t",
      "ype (;30;) (record (field \"field-name\" 22) (field \"field-size\" 29)))\n      (export (;31;) \"field-size-payload\" (type (eq 30)))\n      (type (;32;) (option u64))\n      (type (;33;) (option 31))\n      (type (;34;) (variant (case \"DNS-timeout\") (case \"DNS-error\" 25) (case \"destination-not-found\") (case \"destination-unavailable\") (case \"destination-IP-prohibited\") (case \"destination-IP-unroutable\") (case \"connection-refused\") (case \"connection-terminated\") (case \"connection-timeout\") (case \"connection-read-timeout\") (case \"connection-write-timeout\") (case \"connection-limit-reached\") (case \"TLS-protocol-error\") (case \"TLS-certificate-error\") (case \"TLS-alert-received\" 28) (case \"HTTP-request-denied\") (case \"HTTP-request-length-required\") (case \"HTTP-request-body-size\" 32) (case \"HTTP-request-method-invalid\") (case \"HTTP-request-URI-invalid\") (case \"HTTP-request-URI-too-long\") (case \"HTTP-request-header-section-size\" 29) (case \"HTTP-request-header-size\" 33) (case \"HTTP-request-trailer-section-size\" 29) (case \"HTTP-request-trailer-size\" 31) (case \"HTTP-response-incomplete\") (case \"HTTP-response-header-section-size\" 29) (case \"HTTP-response-header-size\" 31) (case \"HTTP-response-body-size\" 32) (case \"HTTP-response-trailer-section-size\" 29) (case \"HTTP-response-trailer-size\" 31) (case \"HTTP-response-transfer-coding\" 22) (case \"HTTP-response-content-coding\" 22) (case \"HTTP-response-timeout\") (case \"HTTP-upgrade-failed\") (case \"HTTP-protocol-error\") (case \"loop-detected\") (case \"configuration-error\") (case \"internal-error\" 22)))\n      (export (;35;) \"error-code\" (type (eq 34)))\n      (export (;36;) \"incoming-response\" (type (sub resource)))\n      (type (;37;) u16)\n      (export (;38;) \"status-code\" (type (eq 37)))\n      (alias outer 1 16 (type (;39;)))\n      (export (;40;) \"input-stream\" (type (eq 39)))\n      (export (;41;) \"future-trailers\" (type (sub resource)))\n      (alias outer 1 17 (type (;42;)))\n      (export (;43;) \"pollable\" (type (eq 42)))\n      (export (;44;) \"trailers\" (type (eq 0)))\n      (alias outer 1 18 (type (;45;)))\n      (export (;46;) \"output-stream\" (type (eq 45)))\n      (export (;47;) \"future-incoming-response\" (type (sub resource)))\n      (alias outer 1 19 (type (;48;)))\n      (export (;49;) \"io-error\" (type (eq 48)))\n      (type (;50;) (own 0))\n      (type (;51;) (func (result 50)))\n      (export (;0;) \"[constructor]fields\" (func (type 51)))\n      (type (;52;) (tuple 3 5))\n      (type (;53;) (list 52))\n      (type (;54;) (result 50 (error 7)))\n      (type (;55;) (func (param \"entries\" 53) (result 54)))\n      (export (;1;) \"[static]fields.from-list\" (func (type 55)))\n      (type (;56;) (borrow 0))\n      (type (;57;) (list 5))\n      (type (;58;) (func (param \"self\" 56) (param \"name\" 3) (result 57)))\n      (export (;2;) \"[method]fields.get\" (func (type 58)))\n      (type (;59;) (func (param \"self\" 56) (param \"name\" 3) (result bool)))\n      (export (;3;) \"[method]fields.has\" (func (type 59)))\n      (type (;60;) (result (error 7)))\n      (type (;61;) (func (param \"self\" 56) (param \"name\" 3) (param \"value\" 57) (result 60)))\n      (export (;4;) \"[method]fields.set\" (func (type 61)))\n      (type (;62;) (func (param \"self\" 56) (param \"name\" 3) (result 60)))\n      (export (;5;) \"[method]fields.delete\" (func (type 62)))\n      (type (;63;) (func (param \"self\" 56) (param \"name\" 3) (param \"value\" 5) (result 60)))\n      (export (;6;) \"[method]fields.append\" (func (type 63)))\n      (type (;64;) (func (param \"self\" 56) (result 53)))\n      (export (;7;) \"[method]fields.entries\" (func (type 64)))\n      (type (;65;) (func (param \"self\" 56) (result 50)))\n      (export (;8;) \"[method]fields.clone\" (func (type 65)))\n      (type (;66;) (borrow 8))\n      (type (;67;) (func (param \"self\" 66) (result 10)))\n      (export (;9;) \"[method]incoming-request.method\" (func (type 67)))\n      (type (;68;) (func (param \"self\" 66) (result 22)))\n      (export (;10;) \"[method]incoming-request.path-with-query\" (func (type 68)))\n      (type (;69;) (option 12))\n      (type (;70;) (func (param \"self\" 66) (result 69)))\n      (export (;11;) \"[method]incoming-request.scheme\" (func (type 70)))\n      (export (;12;) \"[method]incoming-request.authority\" (func (type 68)))\n      (type (;71;) (own 13))\n      (type (;72;) (func (param \"self\" 66) (result 71)))\n      (export (;13;) \"[method]incoming-request.headers\" (func (type 72)))\n      (type (;73;) (own 14))\n      (type (;74;) (result 73))\n      (type (;75;) (func (param \"self\" 66) (result 74)))\n      (export (;14;) \"[method]incoming-request.consume\" (func (type 75)))\n      (type (;76;) (own 15))\n      (type (;77;) (func (param \"headers\" 71) (result 76)))\n      (export (;15;) \"[constructor]outgoing-request\" (func (type 77)))\n      (type (;78;) (borrow 15))\n      (type (;79;) (own 16))\n      (type (;80;) (result 79))\n      (type (;81;) (func (param \"self\" 78) (result 80)))\n      (export (;16;) \"[method]outgoing-request.body\" (func (type 81)))\n      (type (;82;) (func (param \"self\" 78) (result 10)))\n      (export (;17;) \"[method]outgoing-request.method\" (func (type 82)))\n      (type (;83;) (result))\n      (type (;84;) (func (param \"self\" 78) (param \"method\" 10) (result 83)))\n      (export (;18;) \"[method]outgoing-request.set-method\" (func (type 84)))\n      (type (;85;) (func (param \"self\" 78) (result 22)))\n      (export (;19;) \"[method]outgoing-request.path-with-query\" (func (type 85)))\n      (type (;86;) (func (param \"self\" 78) (param \"path-with-query\" 22) (result 83)))\n      (export (;20;) \"[method]outgoing-request.set-path-with-query\" (func (type 86)))\n      (type (;87;) (func (param \"self\" 78) (result 69)))\n      (export (;21;) \"[method]outgoing-request.scheme\" (func (type 87)))\n      (type (;88;) (func (param \"self\" 78) (param \"scheme\" 69) (result 83)))\n      (export (;22;) \"[method]outgoing-request.set-scheme\" (func (type 88)))\n      (export (;23;) \"[method]outgoing-request.authority\" (func (type 85)))\n      (type (;89;) (func (param \"self\" 78) (param \"authority\" 22) (result 83)))\n      (export (;24;) \"[method]outgoing-request.set-authority\" (func (type 89)))\n      (type (;90;) (func (param \"self\" 78) (result 71)))\n      (export (;25;) \"[method]outgoing-request.headers\" (func (type 90)))\n      (type (;91;) (own 17))\n      (type (;92;) (func (result 91)))\n      (export (;26;) \"[constructor]request-options\" (func (type 92)))\n      (type (;93;) (borrow 17))\n      (type (;94;) (option 19))\n      (type (;95;) (func (param \"self\" 93) (result 94)))\n      (export (;27;) \"[method]request-options.connect-timeout\" (func (type 95)))\n      (type (;96;) (func (param \"self\" 93) (param \"duration\" 94) (result 83)))\n      (export (;28;) \"[method]request-options.set-connect-timeout\" (func (type 96)))\n      (export (;29;) \"[method]request-options.first-byte-timeout\" (func (type 95)))\n      (export (;30;) \"[method]request-options.set-first-byte-timeout\" (func (type 96)))\n      (export (;31;) \"[method]request-options.between-bytes-timeout\" (func (type 95)))\n      (export (;32;) \"[method]request-options.set-between-bytes-timeout\" (func (type 96)))\n      (type (;97;) (own 20))\n      (type (;98;) (own 21))\n      (type (;99;) (result 98 (error 35)))\n      (type (;100;) (func (param \"param\" 97) (param \"response\" 99)))\n      (export (;33;) \"[static]response-outparam.set\" (func (type 100)))\n      (type (;101;) (borrow 36))\n      (type (;102;) (func (param \"self\" 101) (result 38)))\n      (export (;34;) \"[method]incoming-response.status\" (func (type 102)))\n      (type (;103;) (func (param \"self\" 101) (result 71)))\n      (export (;35;) \"[method]incoming-response.headers\" (func (type 103)))\n      (type (;104;) (func (param \"self\" 101) (result 74)))\n      (export (;36;) \"[method]incoming-response.consume\" (func (type 104)))\n      (type (;105;) (borrow 14))\n      (type (;106;) (own 40))\n      (type (;107;) (result 106))\n      (type (;108;) (func (param \"self\" 105) (result 107)))\n      (export (;37;) \"[method]incoming-body.stream\" (func (type 108)))\n      (type (;109;) (ow",
      "n 41))\n      (type (;110;) (func (param \"this\" 73) (result 109)))\n      (export (;38;) \"[static]incoming-body.finish\" (func (type 110)))\n      (type (;111;) (borrow 41))\n      (type (;112;) (own 43))\n      (type (;113;) (func (param \"self\" 111) (result 112)))\n      (export (;39;) \"[method]future-trailers.subscribe\" (func (type 113)))\n      (type (;114;) (own 44))\n      (type (;115;) (option 114))\n      (type (;116;) (result 115 (error 35)))\n      (type (;117;) (result 116))\n      (type (;118;) (option 117))\n      (type (;119;) (func (param \"self\" 111) (result 118)))\n      (export (;40;) \"[method]future-trailers.get\" (func (type 119)))\n      (type (;120;) (func (param \"headers\" 71) (result 98)))\n      (export (;41;) \"[constructor]outgoing-response\" (func (type 120)))\n      (type (;121;) (borrow 21))\n      (type (;122;) (func (param \"self\" 121) (result 38)))\n      (export (;42;) \"[method]outgoing-response.status-code\" (func (type 122)))\n      (type (;123;) (func (param \"self\" 121) (param \"status-code\" 38) (result 83)))\n      (export (;43;) \"[method]outgoing-response.set-status-code\" (func (type 123)))\n      (type (;124;) (func (param \"self\" 121) (result 71)))\n      (export (;44;) \"[method]outgoing-response.headers\" (func (type 124)))\n      (type (;125;) (func (param \"self\" 121) (result 80)))\n      (export (;45;) \"[method]outgoing-response.body\" (func (type 125)))\n      (type (;126;) (borrow 16))\n      (type (;127;) (own 46))\n      (type (;128;) (result 127))\n      (type (;129;) (func (param \"self\" 126) (result 128)))\n      (export (;46;) \"[method]outgoing-body.write\" (func (type 129)))\n      (type (;130;) (result (error 35)))\n      (type (;131;) (func (param \"this\" 79) (param \"trailers\" 115) (result 130)))\n      (export (;47;) \"[static]outgoing-body.finish\" (func (type 131)))\n      (type (;132;) (borrow 47))\n      (type (;133;) (func (param \"self\" 132) (result 112)))\n      (export (;48;) \"[method]future-incoming-response.subscribe\" (func (type 133)))\n      (type (;134;) (own 36))\n      (type (;135;) (result 134 (error 35)))\n      (type (;136;) (result 135))\n      (type (;137;) (option 136))\n      (type (;138;) (func (param \"self\" 132) (result 137)))\n      (export (;49;) \"[method]future-incoming-response.get\" (func (type 138)))\n      (type (;139;) (borrow 49))\n      (type (;140;) (option 35))\n      (type (;141;) (func (param \"err\" 139) (result 140)))\n      (export (;50;) \"http-error-code\" (func (type 141)))\n    )\n  )\n  (import \"wasi:http/types@0.2.3\" (instance (;9;) (type 20)))\n  (alias export 9 \"outgoing-request\" (type (;21;)))\n  (alias export 9 \"request-options\" (type (;22;)))\n  (alias export 9 \"future-incoming-response\" (type (;23;)))\n  (alias export 9 \"error-code\" (type (;24;)))\n  (type (;25;)\n    (instance\n      (alias outer 1 21 (type (;0;)))\n      (export (;1;) \"outgoing-request\" (type (eq 0)))\n      (alias outer 1 22 (type (;2;)))\n      (export (;3;) \"request-options\" (type (eq 2)))\n      (alias outer 1 23 (type (;4;)))\n      (export (;5;) \"future-incoming-response\" (type (eq 4)))\n      (alias outer 1 24 (type (;6;)))\n      (export (;7;) \"error-code\" (type (eq 6)))\n      (type (;8;) (own 1))\n      (type (;9;) (own 3))\n      (type (;10;) (option 9))\n      (type (;11;) (own 5))\n      (type (;12;) (result 11 (error 7)))\n      (type (;13;) (func (param \"request\" 8) (param \"options\" 10) (result 12)))\n      (export (;0;) \"handle\" (func (type 13)))\n    )\n  )\n  (import \"wasi:http/outgoing-handler@0.2.3\" (instance (;10;) (type 25)))\n  (core module (;0;)\n    (type (;0;) (func (param i32) (result i32)))\n    (type (;1;) (func (param i32)))\n    (type (;2;) (func (param i32 i32 i32)))\n    (type (;3;) (func (result i64)))\n    (type (;4;) (func (param i64) (result i32)))\n    (type (;5;) (func (param i64 i32)))\n    (type (;6;) (func (param i32 i32)))\n    (type (;7;) (func (param i32 i64 i32)))\n    (type (;8;) (func (param i32 i32 i32 i32)))\n    (type (;9;) (func (param i32 i32 i64 i32)))\n    (type (;10;) (func (result i32)))\n    (type (;11;) (func (param i32 i32 i32) (result i32)))\n    (type (;12;) (func (param i32 i32 i32 i32 i32 i32)))\n    (type (;13;) (func (param i32 i32 i32 i32) (result i32)))\n    (type (;14;) (func (param i32 i32 i32 i32 i32) (result i32)))\n    (type (;15;) (func (param i32 i32 i64) (result i32)))\n    (type (;16;) (func (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (type (;17;) (func (param i32 i32) (result i32)))\n    (type (;18;) (func))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"[method]pollable.ready\" (func (;0;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"[method]pollable.block\" (func (;1;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"poll\" (func (;2;) (type 2) (param i32 i32 i32)))\n    (import \"cm32p2|wasi:io/poll@0.2\" \"pollable_drop\" (func (;3;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"now\" (func (;4;) (type 3) (result i64)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"resolution\" (func (;5;) (type 3) (result i64)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"subscribe-instant\" (func (;6;) (type 4) (param i64) (result i32)))\n    (import \"cm32p2|wasi:clocks/monotonic-clock@0.2\" \"subscribe-duration\" (func (;7;) (type 4) (param i64) (result i32)))\n    (import \"cm32p2|wasi:clocks/wall-clock@0.2\" \"now\" (func (;8;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:clocks/wall-clock@0.2\" \"resolution\" (func (;9;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:random/random@0.2\" \"get-random-bytes\" (func (;10;) (type 5) (param i64 i32)))\n    (import \"cm32p2|wasi:random/random@0.2\" \"get-random-u64\" (func (;11;) (type 3) (result i64)))\n    (import \"cm32p2|wasi:io/error@0.2\" \"[method]error.to-debug-string\" (func (;12;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:io/error@0.2\" \"error_drop\" (func (;13;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.read\" (func (;14;) (type 7) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.blocking-read\" (func (;15;) (type 7) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.skip\" (func (;16;) (type 7) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.blocking-skip\" (func (;17;) (type 7) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]input-stream.subscribe\" (func (;18;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.check-write\" (func (;19;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.write\" (func (;20;) (type 8) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-write-and-flush\" (func (;21;) (type 8) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.flush\" (func (;22;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-flush\" (func (;23;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.subscribe\" (func (;24;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.write-zeroes\" (func (;25;) (type 7) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-write-zeroes-and-flush\" (func (;26;) (type 7) (param i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.splice\" (func (;27;) (type 9) (param i32 i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"[method]output-stream.blocking-splice\" (func (;28;) (type 9) (param i32 i32 i64 i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"input-stream_drop\" (func (;29;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:io/streams@0.2\" \"output-stream_drop\" (func (;30;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:cli/stdout@0.2\" \"get-stdout\" (func (;31;) (type 10) (result i32)))\n    (import \"cm32p2|wasi:cli/std",
      "err@0.2\" \"get-stderr\" (func (;32;) (type 10) (result i32)))\n    (import \"cm32p2|wasi:cli/stdin@0.2\" \"get-stdin\" (func (;33;) (type 10) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]fields\" (func (;34;) (type 10) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]fields.from-list\" (func (;35;) (type 2) (param i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.get\" (func (;36;) (type 8) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.has\" (func (;37;) (type 11) (param i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.set\" (func (;38;) (type 12) (param i32 i32 i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.delete\" (func (;39;) (type 8) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.append\" (func (;40;) (type 12) (param i32 i32 i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.entries\" (func (;41;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]fields.clone\" (func (;42;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.method\" (func (;43;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.path-with-query\" (func (;44;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.scheme\" (func (;45;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.authority\" (func (;46;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.headers\" (func (;47;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-request.consume\" (func (;48;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]outgoing-request\" (func (;49;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.body\" (func (;50;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.method\" (func (;51;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-method\" (func (;52;) (type 13) (param i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.path-with-query\" (func (;53;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-path-with-query\" (func (;54;) (type 13) (param i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.scheme\" (func (;55;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-scheme\" (func (;56;) (type 14) (param i32 i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.authority\" (func (;57;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.set-authority\" (func (;58;) (type 13) (param i32 i32 i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-request.headers\" (func (;59;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]request-options\" (func (;60;) (type 10) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.connect-timeout\" (func (;61;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.set-connect-timeout\" (func (;62;) (type 15) (param i32 i32 i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.first-byte-timeout\" (func (;63;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.set-first-byte-timeout\" (func (;64;) (type 15) (param i32 i32 i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.between-bytes-timeout\" (func (;65;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]request-options.set-between-bytes-timeout\" (func (;66;) (type 15) (param i32 i32 i64) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]response-outparam.set\" (func (;67;) (type 16) (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-response.status\" (func (;68;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-response.headers\" (func (;69;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-response.consume\" (func (;70;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]incoming-body.stream\" (func (;71;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]incoming-body.finish\" (func (;72;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-trailers.subscribe\" (func (;73;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-trailers.get\" (func (;74;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[constructor]outgoing-response\" (func (;75;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.status-code\" (func (;76;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.set-status-code\" (func (;77;) (type 17) (param i32 i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.headers\" (func (;78;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-response.body\" (func (;79;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]outgoing-body.write\" (func (;80;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[static]outgoing-body.finish\" (func (;81;) (type 8) (param i32 i32 i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-incoming-response.subscribe\" (func (;82;) (type 0) (param i32) (result i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"[method]future-incoming-response.get\" (func (;83;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"http-error-code\" (func (;84;) (type 6) (param i32 i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"fields_drop\" (func (;85;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"incoming-request_drop\" (func (;86;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"outgoing-request_drop\" (func (;87;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"request-options_drop\" (func (;88;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"response-outparam_drop\" (func (;89;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"incoming-response_drop\" (func (;90;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"incoming-body_drop\" (func (;91;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"future-trailers_drop\" (func (;92;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"outgoing-response_drop\" (func (;93;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"outgoing-body_drop\" (func (;94;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/types@0.2\" \"future-incoming-response_drop\" (func (;95;) (type 1) (param i32)))\n    (import \"cm32p2|wasi:http/outgoing-handler@0.2\" \"handle\" (func (;96;) (type 8) (param i32 i32 i32 i32)))\n    (memory (;0;) 0)\n    (export \"cm32p2|wasi:http/incoming-handler@0.2|handle\" (func 97))\n    (export \"cm32p2|wasi:http/incoming-handler@0.2|handle_post\" (func 98))\n    (export \"cm32p2_memory\" (memory 0))\n    (export \"cm32p2_realloc\" (func 99))\n    (export \"cm32p2_initialize\" (func 100))\n    (func (;97;) (type 6) (param i32 i32)\n      unreachable\n    )\n    (func (",
      ";98;) (type 18))\n    (func (;99;) (type 13) (param i32 i32 i32 i32) (result i32)\n      unreachable\n    )\n    (func (;100;) (type 18))\n    (@producers\n      (processed-by \"wit-component\" \"0.229.0\")\n    )\n  )\n  (core module (;1;)\n    (type (;0;) (func (param i32 i32 i32)))\n    (type (;1;) (func (param i32)))\n    (type (;2;) (func (param i64 i32)))\n    (type (;3;) (func (param i32 i32)))\n    (type (;4;) (func (param i32 i64 i32)))\n    (type (;5;) (func (param i32 i32 i32 i32)))\n    (type (;6;) (func (param i32 i32 i64 i32)))\n    (type (;7;) (func (param i32 i32 i32) (result i32)))\n    (type (;8;) (func (param i32 i32 i32 i32 i32 i32)))\n    (type (;9;) (func (param i32 i32 i32 i32) (result i32)))\n    (type (;10;) (func (param i32 i32 i32 i32 i32) (result i32)))\n    (type (;11;) (func (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (type (;12;) (func (param i32 i32 i32 i32)))\n    (table (;0;) 52 52 funcref)\n    (export \"0\" (func $indirect-cm32p2|wasi:io/poll@0.2-poll))\n    (export \"1\" (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-now))\n    (export \"2\" (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-resolution))\n    (export \"3\" (func $indirect-cm32p2|wasi:random/random@0.2-get-random-bytes))\n    (export \"4\" (func $\"indirect-cm32p2|wasi:io/error@0.2-[method]error.to-debug-string\"))\n    (export \"5\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.read\"))\n    (export \"6\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-read\"))\n    (export \"7\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.skip\"))\n    (export \"8\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-skip\"))\n    (export \"9\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.check-write\"))\n    (export \"10\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write\"))\n    (export \"11\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-and-flush\"))\n    (export \"12\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.flush\"))\n    (export \"13\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-flush\"))\n    (export \"14\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write-zeroes\"))\n    (export \"15\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-zeroes-and-flush\"))\n    (export \"16\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.splice\"))\n    (export \"17\" (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-splice\"))\n    (export \"18\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]fields.from-list\"))\n    (export \"19\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.get\"))\n    (export \"20\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.has\"))\n    (export \"21\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.set\"))\n    (export \"22\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.delete\"))\n    (export \"23\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.append\"))\n    (export \"24\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.entries\"))\n    (export \"25\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.method\"))\n    (export \"26\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.path-with-query\"))\n    (export \"27\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.scheme\"))\n    (export \"28\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.authority\"))\n    (export \"29\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.consume\"))\n    (export \"30\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.body\"))\n    (export \"31\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.method\"))\n    (export \"32\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-method\"))\n    (export \"33\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.path-with-query\"))\n    (export \"34\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-path-with-query\"))\n    (export \"35\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.scheme\"))\n    (export \"36\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-scheme\"))\n    (export \"37\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.authority\"))\n    (export \"38\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-authority\"))\n    (export \"39\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.connect-timeout\"))\n    (export \"40\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.first-byte-timeout\"))\n    (export \"41\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.between-bytes-timeout\"))\n    (export \"42\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]response-outparam.set\"))\n    (export \"43\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-response.consume\"))\n    (export \"44\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-body.stream\"))\n    (export \"45\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-trailers.get\"))\n    (export \"46\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-response.body\"))\n    (export \"47\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-body.write\"))\n    (export \"48\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]outgoing-body.finish\"))\n    (export \"49\" (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-incoming-response.get\"))\n    (export \"50\" (func $indirect-cm32p2|wasi:http/types@0.2-http-error-code))\n    (export \"51\" (func $indirect-cm32p2|wasi:http/outgoing-handler@0.2-handle))\n    (export \"$imports\" (table 0))\n    (func $indirect-cm32p2|wasi:io/poll@0.2-poll (;0;) (type 0) (param i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 0\n      call_indirect (type 0)\n    )\n    (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-now (;1;) (type 1) (param i32)\n      local.get 0\n      i32.const 1\n      call_indirect (type 1)\n    )\n    (func $indirect-cm32p2|wasi:clocks/wall-clock@0.2-resolution (;2;) (type 1) (param i32)\n      local.get 0\n      i32.const 2\n      call_indirect (type 1)\n    )\n    (func $indirect-cm32p2|wasi:random/random@0.2-get-random-bytes (;3;) (type 2) (param i64 i32)\n      local.get 0\n      local.get 1\n      i32.const 3\n      call_indirect (type 2)\n    )\n    (func $\"indirect-cm32p2|wasi:io/error@0.2-[method]error.to-debug-string\" (;4;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 4\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.read\" (;5;) (type 4) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 5\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-read\" (;6;) (type 4) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 6\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.skip\" (;7;) (type 4) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 7\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]input-stream.blocking-skip\" (;8;) (type 4) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 8\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.check-write\" (;9;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 9\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write\" (;10;) (type 5) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n",
      "      local.get 3\n      i32.const 10\n      call_indirect (type 5)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-and-flush\" (;11;) (type 5) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 11\n      call_indirect (type 5)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.flush\" (;12;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 12\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-flush\" (;13;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 13\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.write-zeroes\" (;14;) (type 4) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 14\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-write-zeroes-and-flush\" (;15;) (type 4) (param i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 15\n      call_indirect (type 4)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.splice\" (;16;) (type 6) (param i32 i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 16\n      call_indirect (type 6)\n    )\n    (func $\"indirect-cm32p2|wasi:io/streams@0.2-[method]output-stream.blocking-splice\" (;17;) (type 6) (param i32 i32 i64 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 17\n      call_indirect (type 6)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]fields.from-list\" (;18;) (type 0) (param i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 18\n      call_indirect (type 0)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.get\" (;19;) (type 5) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 19\n      call_indirect (type 5)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.has\" (;20;) (type 7) (param i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      i32.const 20\n      call_indirect (type 7)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.set\" (;21;) (type 8) (param i32 i32 i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      local.get 5\n      i32.const 21\n      call_indirect (type 8)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.delete\" (;22;) (type 5) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 22\n      call_indirect (type 5)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.append\" (;23;) (type 8) (param i32 i32 i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      local.get 5\n      i32.const 23\n      call_indirect (type 8)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]fields.entries\" (;24;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 24\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.method\" (;25;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 25\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.path-with-query\" (;26;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 26\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.scheme\" (;27;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 27\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.authority\" (;28;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 28\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-request.consume\" (;29;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 29\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.body\" (;30;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 30\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.method\" (;31;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 31\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-method\" (;32;) (type 9) (param i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 32\n      call_indirect (type 9)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.path-with-query\" (;33;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 33\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-path-with-query\" (;34;) (type 9) (param i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 34\n      call_indirect (type 9)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.scheme\" (;35;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 35\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-scheme\" (;36;) (type 10) (param i32 i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      i32.const 36\n      call_indirect (type 10)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.authority\" (;37;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 37\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-request.set-authority\" (;38;) (type 9) (param i32 i32 i32 i32) (result i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 38\n      call_indirect (type 9)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.connect-timeout\" (;39;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 39\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.first-byte-timeout\" (;40;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 40\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]request-options.between-bytes-timeout\" (;41;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 41\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]response-outparam.set\" (;42;) (type 11) (param i32 i32 i32 i32 i64 i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      local.get 4\n      local.get 5\n      local.get 6\n      local.get 7\n      local.get 8\n      i32.const 42\n      call_indirect (type 11)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-response.consume\" (;43;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 43\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]incoming-body.stream\" (;44;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 44\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-trailers",
      ".get\" (;45;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 45\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-response.body\" (;46;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 46\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]outgoing-body.write\" (;47;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 47\n      call_indirect (type 3)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[static]outgoing-body.finish\" (;48;) (type 12) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 48\n      call_indirect (type 12)\n    )\n    (func $\"indirect-cm32p2|wasi:http/types@0.2-[method]future-incoming-response.get\" (;49;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 49\n      call_indirect (type 3)\n    )\n    (func $indirect-cm32p2|wasi:http/types@0.2-http-error-code (;50;) (type 3) (param i32 i32)\n      local.get 0\n      local.get 1\n      i32.const 50\n      call_indirect (type 3)\n    )\n    (func $indirect-cm32p2|wasi:http/outgoing-handler@0.2-handle (;51;) (type 12) (param i32 i32 i32 i32)\n      local.get 0\n      local.get 1\n      local.get 2\n      local.get 3\n      i32.const 51\n      call_indirect (type 12)\n    )\n    (@producers\n      (processed-by \"wit-component\" \"0.229.0\")\n    )\n  )\n  (core module (;2;)\n    (type (;0;) (func (param i32 i32 i32)))\n    (type (;1;) (func (param i32)))\n    (type (;2;) (func (param i64 i32)))\n    (type (;3;) (func (param i32 i32)))\n    (type (;4;) (func (param i32 i64 i32)))\n    (type (;5;) (func (param i32 i32 i32 i32)))\n    (type (;6;) (func (param i32 i32 i64 i32)))\n    (type (;7;) (func (param i32 i32 i32) (result i32)))\n    (type (;8;) (func (param i32 i32 i32 i32 i32 i32)))\n    (type (;9;) (func (param i32 i32 i32 i32) (result i32)))\n    (type (;10;) (func (param i32 i32 i32 i32 i32) (result i32)))\n    (type (;11;) (func (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (type (;12;) (func (param i32 i32 i32 i32)))\n    (import \"\" \"0\" (func (;0;) (type 0) (param i32 i32 i32)))\n    (import \"\" \"1\" (func (;1;) (type 1) (param i32)))\n    (import \"\" \"2\" (func (;2;) (type 1) (param i32)))\n    (import \"\" \"3\" (func (;3;) (type 2) (param i64 i32)))\n    (import \"\" \"4\" (func (;4;) (type 3) (param i32 i32)))\n    (import \"\" \"5\" (func (;5;) (type 4) (param i32 i64 i32)))\n    (import \"\" \"6\" (func (;6;) (type 4) (param i32 i64 i32)))\n    (import \"\" \"7\" (func (;7;) (type 4) (param i32 i64 i32)))\n    (import \"\" \"8\" (func (;8;) (type 4) (param i32 i64 i32)))\n    (import \"\" \"9\" (func (;9;) (type 3) (param i32 i32)))\n    (import \"\" \"10\" (func (;10;) (type 5) (param i32 i32 i32 i32)))\n    (import \"\" \"11\" (func (;11;) (type 5) (param i32 i32 i32 i32)))\n    (import \"\" \"12\" (func (;12;) (type 3) (param i32 i32)))\n    (import \"\" \"13\" (func (;13;) (type 3) (param i32 i32)))\n    (import \"\" \"14\" (func (;14;) (type 4) (param i32 i64 i32)))\n    (import \"\" \"15\" (func (;15;) (type 4) (param i32 i64 i32)))\n    (import \"\" \"16\" (func (;16;) (type 6) (param i32 i32 i64 i32)))\n    (import \"\" \"17\" (func (;17;) (type 6) (param i32 i32 i64 i32)))\n    (import \"\" \"18\" (func (;18;) (type 0) (param i32 i32 i32)))\n    (import \"\" \"19\" (func (;19;) (type 5) (param i32 i32 i32 i32)))\n    (import \"\" \"20\" (func (;20;) (type 7) (param i32 i32 i32) (result i32)))\n    (import \"\" \"21\" (func (;21;) (type 8) (param i32 i32 i32 i32 i32 i32)))\n    (import \"\" \"22\" (func (;22;) (type 5) (param i32 i32 i32 i32)))\n    (import \"\" \"23\" (func (;23;) (type 8) (param i32 i32 i32 i32 i32 i32)))\n    (import \"\" \"24\" (func (;24;) (type 3) (param i32 i32)))\n    (import \"\" \"25\" (func (;25;) (type 3) (param i32 i32)))\n    (import \"\" \"26\" (func (;26;) (type 3) (param i32 i32)))\n    (import \"\" \"27\" (func (;27;) (type 3) (param i32 i32)))\n    (import \"\" \"28\" (func (;28;) (type 3) (param i32 i32)))\n    (import \"\" \"29\" (func (;29;) (type 3) (param i32 i32)))\n    (import \"\" \"30\" (func (;30;) (type 3) (param i32 i32)))\n    (import \"\" \"31\" (func (;31;) (type 3) (param i32 i32)))\n    (import \"\" \"32\" (func (;32;) (type 9) (param i32 i32 i32 i32) (result i32)))\n    (import \"\" \"33\" (func (;33;) (type 3) (param i32 i32)))\n    (import \"\" \"34\" (func (;34;) (type 9) (param i32 i32 i32 i32) (result i32)))\n    (import \"\" \"35\" (func (;35;) (type 3) (param i32 i32)))\n    (import \"\" \"36\" (func (;36;) (type 10) (param i32 i32 i32 i32 i32) (result i32)))\n    (import \"\" \"37\" (func (;37;) (type 3) (param i32 i32)))\n    (import \"\" \"38\" (func (;38;) (type 9) (param i32 i32 i32 i32) (result i32)))\n    (import \"\" \"39\" (func (;39;) (type 3) (param i32 i32)))\n    (import \"\" \"40\" (func (;40;) (type 3) (param i32 i32)))\n    (import \"\" \"41\" (func (;41;) (type 3) (param i32 i32)))\n    (import \"\" \"42\" (func (;42;) (type 11) (param i32 i32 i32 i32 i64 i32 i32 i32 i32)))\n    (import \"\" \"43\" (func (;43;) (type 3) (param i32 i32)))\n    (import \"\" \"44\" (func (;44;) (type 3) (param i32 i32)))\n    (import \"\" \"45\" (func (;45;) (type 3) (param i32 i32)))\n    (import \"\" \"46\" (func (;46;) (type 3) (param i32 i32)))\n    (import \"\" \"47\" (func (;47;) (type 3) (param i32 i32)))\n    (import \"\" \"48\" (func (;48;) (type 12) (param i32 i32 i32 i32)))\n    (import \"\" \"49\" (func (;49;) (type 3) (param i32 i32)))\n    (import \"\" \"50\" (func (;50;) (type 3) (param i32 i32)))\n    (import \"\" \"51\" (func (;51;) (type 12) (param i32 i32 i32 i32)))\n    (import \"\" \"$imports\" (table (;0;) 52 52 funcref))\n    (elem (;0;) (i32.const 0) func 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51)\n    (@producers\n      (processed-by \"wit-component\" \"0.229.0\")\n    )\n  )\n  (core instance (;0;) (instantiate 1))\n  (alias export 9 \"incoming-request\" (type (;26;)))\n  (alias export 9 \"response-outparam\" (type (;27;)))\n  (alias export 0 \"[method]pollable.ready\" (func (;0;)))\n  (core func (;0;) (canon lower (func 0)))\n  (alias export 0 \"[method]pollable.block\" (func (;1;)))\n  (core func (;1;) (canon lower (func 1)))\n  (alias core export 0 \"0\" (core func (;2;)))\n  (alias export 0 \"pollable\" (type (;28;)))\n  (core func (;3;) (canon resource.drop 28))\n  (core instance (;1;)\n    (export \"[method]pollable.ready\" (func 0))\n    (export \"[method]pollable.block\" (func 1))\n    (export \"poll\" (func 2))\n    (export \"pollable_drop\" (func 3))\n  )\n  (alias export 1 \"now\" (func (;2;)))\n  (core func (;4;) (canon lower (func 2)))\n  (alias export 1 \"resolution\" (func (;3;)))\n  (core func (;5;) (canon lower (func 3)))\n  (alias export 1 \"subscribe-instant\" (func (;4;)))\n  (core func (;6;) (canon lower (func 4)))\n  (alias export 1 \"subscribe-duration\" (func (;5;)))\n  (core func (;7;) (canon lower (func 5)))\n  (core instance (;2;)\n    (export \"now\" (func 4))\n    (export \"resolution\" (func 5))\n    (export \"subscribe-instant\" (func 6))\n    (export \"subscribe-duration\" (func 7))\n  )\n  (alias core export 0 \"1\" (core func (;8;)))\n  (alias core export 0 \"2\" (core func (;9;)))\n  (core instance (;3;)\n    (export \"now\" (func 8))\n    (export \"resolution\" (func 9))\n  )\n  (alias core export 0 \"3\" (core func (;10;)))\n  (alias export 3 \"get-random-u64\" (func (;6;)))\n  (core func (;11;) (canon lower (func 6)))\n  (core instance (;4;)\n    (export \"get-random-bytes\" (func 10))\n    (export \"get-random-u64\" (func 11))\n  )\n  (alias core export 0 \"4\" (core func (;12;)))\n  (alias export 4 \"error\" (type (;29;)))\n  (core func (;13;) (canon resource.drop 29))\n  (core instance (;5;)\n    (export \"[method]error.to-debug-string\" (func 12))\n    (export \"error_drop\" (func 13))\n  )\n  (alias core export 0 \"5\" (core func (;14;)))\n  (alias core export 0 \"6\" (core func (;15;)))\n  (alias core export 0 \"7\" (core func (;16;)))\n  (alias core export 0 \"8\" (core func (;17;)))\n  (alias export 5 \"[method]input-stream.subscribe\" (func (;7;)))\n  (core func (;18;) (canon lower (func 7)",
      "))\n  (alias core export 0 \"9\" (core func (;19;)))\n  (alias core export 0 \"10\" (core func (;20;)))\n  (alias core export 0 \"11\" (core func (;21;)))\n  (alias core export 0 \"12\" (core func (;22;)))\n  (alias core export 0 \"13\" (core func (;23;)))\n  (alias export 5 \"[method]output-stream.subscribe\" (func (;8;)))\n  (core func (;24;) (canon lower (func 8)))\n  (alias core export 0 \"14\" (core func (;25;)))\n  (alias core export 0 \"15\" (core func (;26;)))\n  (alias core export 0 \"16\" (core func (;27;)))\n  (alias core export 0 \"17\" (core func (;28;)))\n  (alias export 5 \"input-stream\" (type (;30;)))\n  (core func (;29;) (canon resource.drop 30))\n  (alias export 5 \"output-stream\" (type (;31;)))\n  (core func (;30;) (canon resource.drop 31))\n  (core instance (;6;)\n    (export \"[method]input-stream.read\" (func 14))\n    (export \"[method]input-stream.blocking-read\" (func 15))\n    (export \"[method]input-stream.skip\" (func 16))\n    (export \"[method]input-stream.blocking-skip\" (func 17))\n    (export \"[method]input-stream.subscribe\" (func 18))\n    (export \"[method]output-stream.check-write\" (func 19))\n    (export \"[method]output-stream.write\" (func 20))\n    (export \"[method]output-stream.blocking-write-and-flush\" (func 21))\n    (export \"[method]output-stream.flush\" (func 22))\n    (export \"[method]output-stream.blocking-flush\" (func 23))\n    (export \"[method]output-stream.subscribe\" (func 24))\n    (export \"[method]output-stream.write-zeroes\" (func 25))\n    (export \"[method]output-stream.blocking-write-zeroes-and-flush\" (func 26))\n    (export \"[method]output-stream.splice\" (func 27))\n    (export \"[method]output-stream.blocking-splice\" (func 28))\n    (export \"input-stream_drop\" (func 29))\n    (export \"output-stream_drop\" (func 30))\n  )\n  (alias export 6 \"get-stdout\" (func (;9;)))\n  (core func (;31;) (canon lower (func 9)))\n  (core instance (;7;)\n    (export \"get-stdout\" (func 31))\n  )\n  (alias export 7 \"get-stderr\" (func (;10;)))\n  (core func (;32;) (canon lower (func 10)))\n  (core instance (;8;)\n    (export \"get-stderr\" (func 32))\n  )\n  (alias export 8 \"get-stdin\" (func (;11;)))\n  (core func (;33;) (canon lower (func 11)))\n  (core instance (;9;)\n    (export \"get-stdin\" (func 33))\n  )\n  (alias export 9 \"[constructor]fields\" (func (;12;)))\n  (core func (;34;) (canon lower (func 12)))\n  (alias core export 0 \"18\" (core func (;35;)))\n  (alias core export 0 \"19\" (core func (;36;)))\n  (alias core export 0 \"20\" (core func (;37;)))\n  (alias core export 0 \"21\" (core func (;38;)))\n  (alias core export 0 \"22\" (core func (;39;)))\n  (alias core export 0 \"23\" (core func (;40;)))\n  (alias core export 0 \"24\" (core func (;41;)))\n  (alias export 9 \"[method]fields.clone\" (func (;13;)))\n  (core func (;42;) (canon lower (func 13)))\n  (alias core export 0 \"25\" (core func (;43;)))\n  (alias core export 0 \"26\" (core func (;44;)))\n  (alias core export 0 \"27\" (core func (;45;)))\n  (alias core export 0 \"28\" (core func (;46;)))\n  (alias export 9 \"[method]incoming-request.headers\" (func (;14;)))\n  (core func (;47;) (canon lower (func 14)))\n  (alias core export 0 \"29\" (core func (;48;)))\n  (alias export 9 \"[constructor]outgoing-request\" (func (;15;)))\n  (core func (;49;) (canon lower (func 15)))\n  (alias core export 0 \"30\" (core func (;50;)))\n  (alias core export 0 \"31\" (core func (;51;)))\n  (alias core export 0 \"32\" (core func (;52;)))\n  (alias core export 0 \"33\" (core func (;53;)))\n  (alias core export 0 \"34\" (core func (;54;)))\n  (alias core export 0 \"35\" (core func (;55;)))\n  (alias core export 0 \"36\" (core func (;56;)))\n  (alias core export 0 \"37\" (core func (;57;)))\n  (alias core export 0 \"38\" (core func (;58;)))\n  (alias export 9 \"[method]outgoing-request.headers\" (func (;16;)))\n  (core func (;59;) (canon lower (func 16)))\n  (alias export 9 \"[constructor]request-options\" (func (;17;)))\n  (core func (;60;) (canon lower (func 17)))\n  (alias core export 0 \"39\" (core func (;61;)))\n  (alias export 9 \"[method]request-options.set-connect-timeout\" (func (;18;)))\n  (core func (;62;) (canon lower (func 18)))\n  (alias core export 0 \"40\" (core func (;63;)))\n  (alias export 9 \"[method]request-options.set-first-byte-timeout\" (func (;19;)))\n  (core func (;64;) (canon lower (func 19)))\n  (alias core export 0 \"41\" (core func (;65;)))\n  (alias export 9 \"[method]request-options.set-between-bytes-timeout\" (func (;20;)))\n  (core func (;66;) (canon lower (func 20)))\n  (alias core export 0 \"42\" (core func (;67;)))\n  (alias export 9 \"[method]incoming-response.status\" (func (;21;)))\n  (core func (;68;) (canon lower (func 21)))\n  (alias export 9 \"[method]incoming-response.headers\" (func (;22;)))\n  (core func (;69;) (canon lower (func 22)))\n  (alias core export 0 \"43\" (core func (;70;)))\n  (alias core export 0 \"44\" (core func (;71;)))\n  (alias export 9 \"[static]incoming-body.finish\" (func (;23;)))\n  (core func (;72;) (canon lower (func 23)))\n  (alias export 9 \"[method]future-trailers.subscribe\" (func (;24;)))\n  (core func (;73;) (canon lower (func 24)))\n  (alias core export 0 \"45\" (core func (;74;)))\n  (alias export 9 \"[constructor]outgoing-response\" (func (;25;)))\n  (core func (;75;) (canon lower (func 25)))\n  (alias export 9 \"[method]outgoing-response.status-code\" (func (;26;)))\n  (core func (;76;) (canon lower (func 26)))\n  (alias export 9 \"[method]outgoing-response.set-status-code\" (func (;27;)))\n  (core func (;77;) (canon lower (func 27)))\n  (alias export 9 \"[method]outgoing-response.headers\" (func (;28;)))\n  (core func (;78;) (canon lower (func 28)))\n  (alias core export 0 \"46\" (core func (;79;)))\n  (alias core export 0 \"47\" (core func (;80;)))\n  (alias core export 0 \"48\" (core func (;81;)))\n  (alias export 9 \"[method]future-incoming-response.subscribe\" (func (;29;)))\n  (core func (;82;) (canon lower (func 29)))\n  (alias core export 0 \"49\" (core func (;83;)))\n  (alias core export 0 \"50\" (core func (;84;)))\n  (alias export 9 \"fields\" (type (;32;)))\n  (core func (;85;) (canon resource.drop 32))\n  (alias export 9 \"incoming-request\" (type (;33;)))\n  (core func (;86;) (canon resource.drop 33))\n  (alias export 9 \"outgoing-request\" (type (;34;)))\n  (core func (;87;) (canon resource.drop 34))\n  (alias export 9 \"request-options\" (type (;35;)))\n  (core func (;88;) (canon resource.drop 35))\n  (alias export 9 \"response-outparam\" (type (;36;)))\n  (core func (;89;) (canon resource.drop 36))\n  (alias export 9 \"incoming-response\" (type (;37;)))\n  (core func (;90;) (canon resource.drop 37))\n  (alias export 9 \"incoming-body\" (type (;38;)))\n  (core func (;91;) (canon resource.drop 38))\n  (alias export 9 \"future-trailers\" (type (;39;)))\n  (core func (;92;) (canon resource.drop 39))\n  (alias export 9 \"outgoing-response\" (type (;40;)))\n  (core func (;93;) (canon resource.drop 40))\n  (alias export 9 \"outgoing-body\" (type (;41;)))\n  (core func (;94;) (canon resource.drop 41))\n  (alias export 9 \"future-incoming-response\" (type (;42;)))\n  (core func (;95;) (canon resource.drop 42))\n  (core instance (;10;)\n    (export \"[constructor]fields\" (func 34))\n    (export \"[static]fields.from-list\" (func 35))\n    (export \"[method]fields.get\" (func 36))\n    (export \"[method]fields.has\" (func 37))\n    (export \"[method]fields.set\" (func 38))\n    (export \"[method]fields.delete\" (func 39))\n    (export \"[method]fields.append\" (func 40))\n    (export \"[method]fields.entries\" (func 41))\n    (export \"[method]fields.clone\" (func 42))\n    (export \"[method]incoming-request.method\" (func 43))\n    (export \"[method]incoming-request.path-with-query\" (func 44))\n    (export \"[method]incoming-request.scheme\" (func 45))\n    (export \"[method]incoming-request.authority\" (func 46))\n    (export \"[method]incoming-request.headers\" (func 47))\n    (export \"[method]incoming-request.consume\" (func 48))\n    (export \"[constructor]outgoing-request\" (func 49))\n    (export \"[method]outgoing-request.body\" (func 50))\n    (export \"[method]outgoing-request.method\" (func 51))\n    (export \"[method]outgoing-request.set-method\" (func 52))\n    (export \"[method]outgoing-request.path-with-query\" (func 5",
      "3))\n    (export \"[method]outgoing-request.set-path-with-query\" (func 54))\n    (export \"[method]outgoing-request.scheme\" (func 55))\n    (export \"[method]outgoing-request.set-scheme\" (func 56))\n    (export \"[method]outgoing-request.authority\" (func 57))\n    (export \"[method]outgoing-request.set-authority\" (func 58))\n    (export \"[method]outgoing-request.headers\" (func 59))\n    (export \"[constructor]request-options\" (func 60))\n    (export \"[method]request-options.connect-timeout\" (func 61))\n    (export \"[method]request-options.set-connect-timeout\" (func 62))\n    (export \"[method]request-options.first-byte-timeout\" (func 63))\n    (export \"[method]request-options.set-first-byte-timeout\" (func 64))\n    (export \"[method]request-options.between-bytes-timeout\" (func 65))\n    (export \"[method]request-options.set-between-bytes-timeout\" (func 66))\n    (export \"[static]response-outparam.set\" (func 67))\n    (export \"[method]incoming-response.status\" (func 68))\n    (export \"[method]incoming-response.headers\" (func 69))\n    (export \"[method]incoming-response.consume\" (func 70))\n    (export \"[method]incoming-body.stream\" (func 71))\n    (export \"[static]incoming-body.finish\" (func 72))\n    (export \"[method]future-trailers.subscribe\" (func 73))\n    (export \"[method]future-trailers.get\" (func 74))\n    (export \"[constructor]outgoing-response\" (func 75))\n    (export \"[method]outgoing-response.status-code\" (func 76))\n    (export \"[method]outgoing-response.set-status-code\" (func 77))\n    (export \"[method]outgoing-response.headers\" (func 78))\n    (export \"[method]outgoing-response.body\" (func 79))\n    (export \"[method]outgoing-body.write\" (func 80))\n    (export \"[static]outgoing-body.finish\" (func 81))\n    (export \"[method]future-incoming-response.subscribe\" (func 82))\n    (export \"[method]future-incoming-response.get\" (func 83))\n    (export \"http-error-code\" (func 84))\n    (export \"fields_drop\" (func 85))\n    (export \"incoming-request_drop\" (func 86))\n    (export \"outgoing-request_drop\" (func 87))\n    (export \"request-options_drop\" (func 88))\n    (export \"response-outparam_drop\" (func 89))\n    (export \"incoming-response_drop\" (func 90))\n    (export \"incoming-body_drop\" (func 91))\n    (export \"future-trailers_drop\" (func 92))\n    (export \"outgoing-response_drop\" (func 93))\n    (export \"outgoing-body_drop\" (func 94))\n    (export \"future-incoming-response_drop\" (func 95))\n  )\n  (alias core export 0 \"51\" (core func (;96;)))\n  (core instance (;11;)\n    (export \"handle\" (func 96))\n  )\n  (core instance (;12;) (instantiate 0\n      (with \"cm32p2|wasi:io/poll@0.2\" (instance 1))\n      (with \"cm32p2|wasi:clocks/monotonic-clock@0.2\" (instance 2))\n      (with \"cm32p2|wasi:clocks/wall-clock@0.2\" (instance 3))\n      (with \"cm32p2|wasi:random/random@0.2\" (instance 4))\n      (with \"cm32p2|wasi:io/error@0.2\" (instance 5))\n      (with \"cm32p2|wasi:io/streams@0.2\" (instance 6))\n      (with \"cm32p2|wasi:cli/stdout@0.2\" (instance 7))\n      (with \"cm32p2|wasi:cli/stderr@0.2\" (instance 8))\n      (with \"cm32p2|wasi:cli/stdin@0.2\" (instance 9))\n      (with \"cm32p2|wasi:http/types@0.2\" (instance 10))\n      (with \"cm32p2|wasi:http/outgoing-handler@0.2\" (instance 11))\n    )\n  )\n  (alias core export 12 \"cm32p2_memory\" (core memory (;0;)))\n  (alias core export 0 \"$imports\" (core table (;0;)))\n  (alias export 0 \"poll\" (func (;30;)))\n  (alias core export 12 \"cm32p2_realloc\" (core func (;97;)))\n  (core func (;98;) (canon lower (func 30) (memory 0) (realloc 97)))\n  (alias export 2 \"now\" (func (;31;)))\n  (core func (;99;) (canon lower (func 31) (memory 0)))\n  (alias export 2 \"resolution\" (func (;32;)))\n  (core func (;100;) (canon lower (func 32) (memory 0)))\n  (alias export 3 \"get-random-bytes\" (func (;33;)))\n  (core func (;101;) (canon lower (func 33) (memory 0) (realloc 97)))\n  (alias export 4 \"[method]error.to-debug-string\" (func (;34;)))\n  (core func (;102;) (canon lower (func 34) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 5 \"[method]input-stream.read\" (func (;35;)))\n  (core func (;103;) (canon lower (func 35) (memory 0) (realloc 97)))\n  (alias export 5 \"[method]input-stream.blocking-read\" (func (;36;)))\n  (core func (;104;) (canon lower (func 36) (memory 0) (realloc 97)))\n  (alias export 5 \"[method]input-stream.skip\" (func (;37;)))\n  (core func (;105;) (canon lower (func 37) (memory 0)))\n  (alias export 5 \"[method]input-stream.blocking-skip\" (func (;38;)))\n  (core func (;106;) (canon lower (func 38) (memory 0)))\n  (alias export 5 \"[method]output-stream.check-write\" (func (;39;)))\n  (core func (;107;) (canon lower (func 39) (memory 0)))\n  (alias export 5 \"[method]output-stream.write\" (func (;40;)))\n  (core func (;108;) (canon lower (func 40) (memory 0)))\n  (alias export 5 \"[method]output-stream.blocking-write-and-flush\" (func (;41;)))\n  (core func (;109;) (canon lower (func 41) (memory 0)))\n  (alias export 5 \"[method]output-stream.flush\" (func (;42;)))\n  (core func (;110;) (canon lower (func 42) (memory 0)))\n  (alias export 5 \"[method]output-stream.blocking-flush\" (func (;43;)))\n  (core func (;111;) (canon lower (func 43) (memory 0)))\n  (alias export 5 \"[method]output-stream.write-zeroes\" (func (;44;)))\n  (core func (;112;) (canon lower (func 44) (memory 0)))\n  (alias export 5 \"[method]output-stream.blocking-write-zeroes-and-flush\" (func (;45;)))\n  (core func (;113;) (canon lower (func 45) (memory 0)))\n  (alias export 5 \"[method]output-stream.splice\" (func (;46;)))\n  (core func (;114;) (canon lower (func 46) (memory 0)))\n  (alias export 5 \"[method]output-stream.blocking-splice\" (func (;47;)))\n  (core func (;115;) (canon lower (func 47) (memory 0)))\n  (alias export 9 \"[static]fields.from-list\" (func (;48;)))\n  (core func (;116;) (canon lower (func 48) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]fields.get\" (func (;49;)))\n  (core func (;117;) (canon lower (func 49) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]fields.has\" (func (;50;)))\n  (core func (;118;) (canon lower (func 50) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]fields.set\" (func (;51;)))\n  (core func (;119;) (canon lower (func 51) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]fields.delete\" (func (;52;)))\n  (core func (;120;) (canon lower (func 52) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]fields.append\" (func (;53;)))\n  (core func (;121;) (canon lower (func 53) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]fields.entries\" (func (;54;)))\n  (core func (;122;) (canon lower (func 54) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]incoming-request.method\" (func (;55;)))\n  (core func (;123;) (canon lower (func 55) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]incoming-request.path-with-query\" (func (;56;)))\n  (core func (;124;) (canon lower (func 56) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]incoming-request.scheme\" (func (;57;)))\n  (core func (;125;) (canon lower (func 57) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]incoming-request.authority\" (func (;58;)))\n  (core func (;126;) (canon lower (func 58) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]incoming-request.consume\" (func (;59;)))\n  (core func (;127;) (canon lower (func 59) (memory 0)))\n  (alias export 9 \"[method]outgoing-request.body\" (func (;60;)))\n  (core func (;128;) (canon lower (func 60) (memory 0)))\n  (alias export 9 \"[method]outgoing-request.method\" (func (;61;)))\n  (core func (;129;) (canon lower (func 61) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.set-method\" (func (;62;)))\n  (core func (;130;) (canon lower (func 62) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.path-with-query\" (func (;63;)))\n  (core func (;131;) (canon lower (func 63) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.set-pat",
      "h-with-query\" (func (;64;)))\n  (core func (;132;) (canon lower (func 64) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.scheme\" (func (;65;)))\n  (core func (;133;) (canon lower (func 65) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.set-scheme\" (func (;66;)))\n  (core func (;134;) (canon lower (func 66) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.authority\" (func (;67;)))\n  (core func (;135;) (canon lower (func 67) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-request.set-authority\" (func (;68;)))\n  (core func (;136;) (canon lower (func 68) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]request-options.connect-timeout\" (func (;69;)))\n  (core func (;137;) (canon lower (func 69) (memory 0)))\n  (alias export 9 \"[method]request-options.first-byte-timeout\" (func (;70;)))\n  (core func (;138;) (canon lower (func 70) (memory 0)))\n  (alias export 9 \"[method]request-options.between-bytes-timeout\" (func (;71;)))\n  (core func (;139;) (canon lower (func 71) (memory 0)))\n  (alias export 9 \"[static]response-outparam.set\" (func (;72;)))\n  (core func (;140;) (canon lower (func 72) (memory 0) string-encoding=utf8))\n  (alias export 9 \"[method]incoming-response.consume\" (func (;73;)))\n  (core func (;141;) (canon lower (func 73) (memory 0)))\n  (alias export 9 \"[method]incoming-body.stream\" (func (;74;)))\n  (core func (;142;) (canon lower (func 74) (memory 0)))\n  (alias export 9 \"[method]future-trailers.get\" (func (;75;)))\n  (core func (;143;) (canon lower (func 75) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]outgoing-response.body\" (func (;76;)))\n  (core func (;144;) (canon lower (func 76) (memory 0)))\n  (alias export 9 \"[method]outgoing-body.write\" (func (;77;)))\n  (core func (;145;) (canon lower (func 77) (memory 0)))\n  (alias export 9 \"[static]outgoing-body.finish\" (func (;78;)))\n  (core func (;146;) (canon lower (func 78) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"[method]future-incoming-response.get\" (func (;79;)))\n  (core func (;147;) (canon lower (func 79) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 9 \"http-error-code\" (func (;80;)))\n  (core func (;148;) (canon lower (func 80) (memory 0) (realloc 97) string-encoding=utf8))\n  (alias export 10 \"handle\" (func (;81;)))\n  (core func (;149;) (canon lower (func 81) (memory 0) (realloc 97) string-encoding=utf8))\n  (core instance (;13;)\n    (export \"$imports\" (table 0))\n    (export \"0\" (func 98))\n    (export \"1\" (func 99))\n    (export \"2\" (func 100))\n    (export \"3\" (func 101))\n    (export \"4\" (func 102))\n    (export \"5\" (func 103))\n    (export \"6\" (func 104))\n    (export \"7\" (func 105))\n    (export \"8\" (func 106))\n    (export \"9\" (func 107))\n    (export \"10\" (func 108))\n    (export \"11\" (func 109))\n    (export \"12\" (func 110))\n    (export \"13\" (func 111))\n    (export \"14\" (func 112))\n    (export \"15\" (func 113))\n    (export \"16\" (func 114))\n    (export \"17\" (func 115))\n    (export \"18\" (func 116))\n    (export \"19\" (func 117))\n    (export \"20\" (func 118))\n    (export \"21\" (func 119))\n    (export \"22\" (func 120))\n    (export \"23\" (func 121))\n    (export \"24\" (func 122))\n    (export \"25\" (func 123))\n    (export \"26\" (func 124))\n    (export \"27\" (func 125))\n    (export \"28\" (func 126))\n    (export \"29\" (func 127))\n    (export \"30\" (func 128))\n    (export \"31\" (func 129))\n    (export \"32\" (func 130))\n    (export \"33\" (func 131))\n    (export \"34\" (func 132))\n    (export \"35\" (func 133))\n    (export \"36\" (func 134))\n    (export \"37\" (func 135))\n    (export \"38\" (func 136))\n    (export \"39\" (func 137))\n    (export \"40\" (func 138))\n    (export \"41\" (func 139))\n    (export \"42\" (func 140))\n    (export \"43\" (func 141))\n    (export \"44\" (func 142))\n    (export \"45\" (func 143))\n    (export \"46\" (func 144))\n    (export \"47\" (func 145))\n    (export \"48\" (func 146))\n    (export \"49\" (func 147))\n    (export \"50\" (func 148))\n    (export \"51\" (func 149))\n  )\n  (core instance (;14;) (instantiate 2\n      (with \"\" (instance 13))\n    )\n  )\n  (alias core export 12 \"cm32p2_initialize\" (core func (;150;)))\n  (core module (;3;)\n    (type (;0;) (func))\n    (import \"\" \"\" (func (;0;) (type 0)))\n    (start 0)\n  )\n  (core instance (;15;)\n    (export \"\" (func 150))\n  )\n  (core instance (;16;) (instantiate 3\n      (with \"\" (instance 15))\n    )\n  )\n  (type (;43;) (own 26))\n  (type (;44;) (own 27))\n  (type (;45;) (func (param \"request\" 43) (param \"response-out\" 44)))\n  (alias core export 12 \"cm32p2|wasi:http/incoming-handler@0.2|handle\" (core func (;151;)))\n  (alias core export 12 \"cm32p2|wasi:http/incoming-handler@0.2|handle_post\" (core func (;152;)))\n  (func (;82;) (type 45) (canon lift (core func 151) (post-return 152)))\n  (alias export 9 \"incoming-request\" (type (;46;)))\n  (alias export 9 \"response-outparam\" (type (;47;)))\n  (component (;0;)\n    (import \"import-type-incoming-request\" (type (;0;) (sub resource)))\n    (import \"import-type-response-outparam\" (type (;1;) (sub resource)))\n    (import \"import-type-incoming-request0\" (type (;2;) (eq 0)))\n    (type (;3;) (own 2))\n    (import \"import-type-response-outparam0\" (type (;4;) (eq 1)))\n    (type (;5;) (own 4))\n    (type (;6;) (func (param \"request\" 3) (param \"response-out\" 5)))\n    (import \"import-func-handle\" (func (;0;) (type 6)))\n    (export (;7;) \"incoming-request\" (type 0))\n    (export (;8;) \"response-outparam\" (type 1))\n    (type (;9;) (own 7))\n    (type (;10;) (own 8))\n    (type (;11;) (func (param \"request\" 9) (param \"response-out\" 10)))\n    (export (;1;) \"handle\" (func 0) (func (type 11)))\n  )\n  (instance (;11;) (instantiate 0\n      (with \"import-func-handle\" (func 82))\n      (with \"import-type-incoming-request\" (type 46))\n      (with \"import-type-response-outparam\" (type 47))\n      (with \"import-type-incoming-request0\" (type 26))\n      (with \"import-type-response-outparam0\" (type 27))\n    )\n  )\n  (export (;12;) \"wasi:http/incoming-handler@0.2.3\" (instance 11))\n  (@producers\n    (processed-by \"wit-component\" \"0.229.0\")\n  )\n)\n",
    ].join(""),
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:nested", version: None, source: "dep.wasm", bytes, },
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
      "11", "wasi:io/poll@0.2.3", "instance", "interface", "wasi:io/poll@0.2.3",
      "0", "4", "pollable", "type", "resource", "0", "[method]pollable.ready", "func",
      "function", "false", "1", "self", "borrow", "0", "some", "scalar", "bool",
      "[method]pollable.block", "func", "function", "false", "1", "self", "borrow",
      "0", "none", "poll", "func", "function", "false", "1", "in", "list", "borrow",
      "0", "some", "list", "scalar", "u32", "wasi:clocks/monotonic-clock@0.2.3",
      "instance", "interface", "wasi:clocks/monotonic-clock@0.2.3", "1", "pollable",
      "pollable", "wasi:io/poll@0.2.3", "7", "instant", "type", "scalar", "u64",
      "duration", "type", "scalar", "u64", "pollable", "type", "resource", "0", "now",
      "func", "function", "false", "0", "some", "scalar", "u64", "resolution", "func",
      "function", "false", "0", "some", "scalar", "u64", "subscribe-instant", "func",
      "function", "false", "1", "when", "scalar", "u64", "some", "own", "0", "subscribe-duration",
      "func", "function", "false", "1", "when", "scalar", "u64", "some", "own", "0",
      "wasi:clocks/wall-clock@0.2.3", "instance", "interface", "wasi:clocks/wall-clock@0.2.3",
      "0", "3", "datetime", "type", "record", "2", "seconds", "scalar", "u64", "nanoseconds",
      "scalar", "u32", "now", "func", "function", "false", "0", "some", "record",
      "2", "seconds", "scalar", "u64", "nanoseconds", "scalar", "u32", "resolution",
      "func", "function", "false", "0", "some", "record", "2", "seconds", "scalar",
      "u64", "nanoseconds", "scalar", "u32", "wasi:random/random@0.2.3", "instance",
      "interface", "wasi:random/random@0.2.3", "0", "2", "get-random-bytes", "func",
      "function", "false", "1", "len", "scalar", "u64", "some", "list", "scalar",
      "u8", "get-random-u64", "func", "function", "false", "0", "some", "scalar",
      "u64", "wasi:io/error@0.2.3", "instance", "interface", "wasi:io/error@0.2.3",
      "0", "2", "error", "type", "resource", "1", "[method]error.to-debug-string",
      "func", "function", "false", "1", "self", "borrow", "1", "some", "scalar",
      "string", "wasi:io/streams@0.2.3", "instance", "interface", "wasi:io/streams@0.2.3",
      "2", "error", "error", "wasi:io/error@0.2.3", "pollable", "pollable", "wasi:io/poll@0.2.3",
      "20", "input-stream", "type", "resource", "2", "error", "type", "resource",
      "1", "stream-error", "type", "variant", "2", "last-operation-failed", "some",
      "own", "1", "closed", "none", "pollable", "type", "resource", "0", "output-stream",
      "type", "resource", "3", "[method]input-stream.read", "func", "function", "false",
      "2", "self", "borrow", "2", "len", "scalar", "u64", "some", "result", "some",
      "list", "scalar", "u8", "some", "variant", "2", "last-operation-failed", "some",
      "own", "1", "closed", "none", "[method]input-stream.blocking-read", "func",
      "function", "false", "2", "self", "borrow", "2", "len", "scalar", "u64", "some",
      "result", "some", "list", "scalar", "u8", "some", "variant", "2", "last-operation-failed",
      "some", "own", "1", "closed", "none", "[method]input-stream.skip", "func",
      "function", "false", "2", "self", "borrow", "2", "len", "scalar", "u64", "some",
      "result", "some", "scalar", "u64", "some", "variant", "2", "last-operation-failed",
      "some", "own", "1", "closed", "none", "[method]input-stream.blocking-skip",
      "func", "function", "false", "2", "self", "borrow", "2", "len", "scalar", "u64",
      "some", "result", "some", "scalar", "u64", "some", "variant", "2", "last-operation-failed",
      "some", "own", "1", "closed", "none", "[method]input-stream.subscribe", "func",
      "function", "false", "1", "self", "borrow", "2", "some", "own", "0", "[method]output-stream.check-write",
      "func", "function", "false", "1", "self", "borrow", "3", "some", "result",
      "some", "scalar", "u64", "some", "variant", "2", "last-operation-failed", "some",
      "own", "1", "closed", "none", "[method]output-stream.write", "func", "function",
      "false", "2", "self", "borrow", "3", "contents", "list", "scalar", "u8", "some",
      "result", "none", "some", "variant", "2", "last-operation-failed", "some",
      "own", "1", "closed", "none", "[method]output-stream.blocking-write-and-flush",
      "func", "function", "false", "2", "self", "borrow", "3", "contents", "list",
      "scalar", "u8", "some", "result", "none", "some", "variant", "2", "last-operation-failed",
      "some", "own", "1", "closed", "none", "[method]output-stream.flush", "func",
      "function", "false", "1", "self", "borrow", "3", "some", "result", "none",
      "some", "variant", "2", "last-operation-failed", "some", "own", "1", "closed",
      "none", "[method]output-stream.blocking-flush", "func", "function", "false",
      "1", "self", "borrow", "3", "some", "result", "none", "some", "variant", "2",
      "last-operation-failed", "some", "own", "1", "closed", "none", "[method]output-stream.subscribe",
      "func", "function", "false", "1", "self", "borrow", "3", "some", "own", "0",
      "[method]output-stream.write-zeroes", "func", "function", "false", "2", "self",
      "borrow", "3", "len", "scalar", "u64", "some", "result", "none", "some", "variant",
      "2", "last-operation-failed", "some", "own", "1", "closed", "none", "[method]output-stream.blocking-write-zeroes-and-flush",
      "func", "function", "false", "2", "self", "borrow", "3", "len", "scalar", "u64",
      "some", "result", "none", "some", "variant", "2", "last-operation-failed",
      "some", "own", "1", "closed", "none", "[method]output-stream.splice", "func",
      "function", "false", "3", "self", "borrow", "3", "src", "borrow", "2", "len",
      "scalar", "u64", "some", "result", "some", "scalar", "u64", "some", "variant",
      "2", "last-operation-failed", "some", "own", "1", "closed", "none", "[method]output-stream.blocking-splice",
      "func", "function", "false", "3", "self", "borrow", "3", "src", "borrow", "2",
      "len", "scalar", "u64", "some", "result", "some", "scalar", "u64", "some",
      "variant", "2", "last-operation-failed", "some", "own", "1", "closed", "none",
      "wasi:cli/stdout@0.2.3", "instance", "interface", "wasi:cli/stdout@0.2.3",
      "1", "output-stream", "output-stream", "wasi:io/streams@0.2.3", "2", "output-stream",
      "type", "resource", "3", "get-stdout", "func", "function", "false", "0", "some",
      "own", "3", "wasi:cli/stderr@0.2.3", "instance", "interface", "wasi:cli/stderr@0.2.3",
      "1", "output-stream", "output-stream", "wasi:io/streams@0.2.3", "2", "output-stream",
      "type", "resource", "3", "get-stderr", "func", "function", "false", "0", "some",
      "own", "3", "wasi:cli/stdin@0.2.3", "instance", "interface", "wasi:cli/stdin@0.2.3",
      "1", "input-stream", "input-stream", "wasi:io/streams@0.2.3", "2", "input-stream",
      "type", "resource", "2", "get-stdin", "func", "function", "false", "0", "some",
      "own", "2", "wasi:http/types@0.2.3", "instance", "interface", "wasi:http/types@0.2.3",
      "5", "duration", "duration", "wasi:clocks/monotonic-clock@0.2.3", "input-stream",
      "input-stream", "wasi:io/streams@0.2.3", "pollable", "pollable", "wasi:io/poll@0.2.3",
      "output-stream", "output-stream", "wasi:io/streams@0.2.3", "io-error", "error",
      "wasi:io/error@0.2.3", "80", "fields", "type", "resource", "4", "field-key",
      "type", "scalar", "string", "field-name", "type", "scalar", "string", "field-value",
      "type", "list", "scalar", "u8", "header-error", "type", "variant", "3", "invalid-syntax",
      "none", "forbidden", "none", "immutable", "none", "incoming-request", "type",
      "resource", "5", "method", "type", "variant", "10", "get", "none", "head",
      "none", "post", "none", "put", "none", "delete", "none", "connect", "none",
      "options", "none", "trace", "none", "patch", "none", "other", "some", "scalar",
      "string", "scheme", "type", "variant", "3", "HTTP", "none", "HTTPS", "none",
      "other", "some", "scalar", "string", "headers", "type", "resource", "4", "incoming-body",
      "type", "resource", "6", "outgoing-request", "type", "resource", "7", "outgoing-body",
      "type", "resource", "8", "request-options", "type", "resource", "9", "duration",
      "type", "scalar", "u64", "response-outparam", "type", "resource", "10", "outgoing-response",
      "type", "resource", "11", "DNS-error-payload", "type", "record", "2", "rcode",
      "option", "scalar", "string", "info-code", "option", "scalar", "u16", "TLS-alert-received-payload",
      "type", "record", "2", "alert-id", "option", "scalar", "u8", "alert-message",
      "option", "scalar", "string", "field-size-payload", "type", "record", "2",
      "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "error-code", "type", "variant", "39", "DNS-timeout", "none", "DNS-error",
      "some", "record", "2", "rcode", "option", "scalar", "string", "info-code",
      "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "incoming-response", "type", "resource", "12", "status-code",
      "type", "scalar", "u16", "input-stream", "type", "resource", "2", "future-trailers",
      "type", "resource", "13", "pollable", "type", "resource", "0", "trailers",
      "type", "resource", "4", "output-stream", "type", "resource", "3", "future-incoming-response",
      "type", "resource", "14", "io-error", "type", "resource", "1", "[constructor]fields",
      "func", "function", "false", "0", "some", "own", "4", "[static]fields.from-list",
      "func", "function", "false", "1", "entries", "list", "tuple", "2", "scalar",
      "string", "list", "scalar", "u8", "some", "result", "some", "own", "4", "some",
      "variant", "3", "invalid-syntax", "none", "forbidden", "none", "immutable",
      "none", "[method]fields.get", "func", "function", "false", "2", "self", "borrow",
      "4", "name", "scalar", "string", "some", "list", "list", "scalar", "u8", "[method]fields.has",
      "func", "function", "false", "2", "self", "borrow", "4", "name", "scalar",
      "string", "some", "scalar", "bool", "[method]fields.set", "func", "function",
      "false", "3", "self", "borrow", "4", "name", "scalar", "string", "value", "list",
      "list", "scalar", "u8", "some", "result", "none", "some", "variant", "3", "invalid-syntax",
      "none", "forbidden", "none", "immutable", "none", "[method]fields.delete",
      "func", "function", "false", "2", "self", "borrow", "4", "name", "scalar",
      "string", "some", "result", "none", "some", "variant", "3", "invalid-syntax",
      "none", "forbidden", "none", "immutable", "none", "[method]fields.append",
      "func", "function", "false", "3", "self", "borrow", "4", "name", "scalar",
      "string", "value", "list", "scalar", "u8", "some", "result", "none", "some",
      "variant", "3", "invalid-syntax", "none", "forbidden", "none", "immutable",
      "none", "[method]fields.entries", "func", "function", "false", "1", "self",
      "borrow", "4", "some", "list", "tuple", "2", "scalar", "string", "list", "scalar",
      "u8", "[method]fields.clone", "func", "function", "false", "1", "self", "borrow",
      "4", "some", "own", "4", "[method]incoming-request.method", "func", "function",
      "false", "1", "self", "borrow", "5", "some", "variant", "10", "get", "none",
      "head", "none", "post", "none", "put", "none", "delete", "none", "connect",
      "none", "options", "none", "trace", "none", "patch", "none", "other", "some",
      "scalar", "string", "[method]incoming-request.path-with-query", "func", "function",
      "false", "1", "self", "borrow", "5", "some", "option", "scalar", "string",
      "[method]incoming-request.scheme", "func", "function", "false", "1", "self",
      "borrow", "5", "some", "option", "variant", "3", "HTTP", "none", "HTTPS", "none",
      "other", "some", "scalar", "string", "[method]incoming-request.authority",
      "func", "function", "false", "1", "self", "borrow", "5", "some", "option",
      "scalar", "string", "[method]incoming-request.headers", "func", "function",
      "false", "1", "self", "borrow", "5", "some", "own", "4", "[method]incoming-request.consume",
      "func", "function", "false", "1", "self", "borrow", "5", "some", "result",
      "some", "own", "6", "none", "[constructor]outgoing-request", "func", "function",
      "false", "1", "headers", "own", "4", "some", "own", "7", "[method]outgoing-request.body",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "result",
      "some", "own", "8", "none", "[method]outgoing-request.method", "func", "function",
      "false", "1", "self", "borrow", "7", "some", "variant", "10", "get", "none",
      "head", "none", "post", "none", "put", "none", "delete", "none", "connect",
      "none", "options", "none", "trace", "none", "patch", "none", "other", "some",
      "scalar", "string", "[method]outgoing-request.set-method", "func", "function",
      "false", "2", "self", "borrow", "7", "method", "variant", "10", "get", "none",
      "head", "none", "post", "none", "put", "none", "delete", "none", "connect",
      "none", "options", "none", "trace", "none", "patch", "none", "other", "some",
      "scalar", "string", "some", "result", "none", "none", "[method]outgoing-request.path-with-query",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "option",
      "scalar", "string", "[method]outgoing-request.set-path-with-query", "func",
      "function", "false", "2", "self", "borrow", "7", "path-with-query", "option",
      "scalar", "string", "some", "result", "none", "none", "[method]outgoing-request.scheme",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "option",
      "variant", "3", "HTTP", "none", "HTTPS", "none", "other", "some", "scalar",
      "string", "[method]outgoing-request.set-scheme", "func", "function", "false",
      "2", "self", "borrow", "7", "scheme", "option", "variant", "3", "HTTP", "none",
      "HTTPS", "none", "other", "some", "scalar", "string", "some", "result", "none",
      "none", "[method]outgoing-request.authority", "func", "function", "false",
      "1", "self", "borrow", "7", "some", "option", "scalar", "string", "[method]outgoing-request.set-authority",
      "func", "function", "false", "2", "self", "borrow", "7", "authority", "option",
      "scalar", "string", "some", "result", "none", "none", "[method]outgoing-request.headers",
      "func", "function", "false", "1", "self", "borrow", "7", "some", "own", "4",
      "[constructor]request-options", "func", "function", "false", "0", "some", "own",
      "9", "[method]request-options.connect-timeout", "func", "function", "false",
      "1", "self", "borrow", "9", "some", "option", "scalar", "u64", "[method]request-options.set-connect-timeout",
      "func", "function", "false", "2", "self", "borrow", "9", "duration", "option",
      "scalar", "u64", "some", "result", "none", "none", "[method]request-options.first-byte-timeout",
      "func", "function", "false", "1", "self", "borrow", "9", "some", "option",
      "scalar", "u64", "[method]request-options.set-first-byte-timeout", "func",
      "function", "false", "2", "self", "borrow", "9", "duration", "option", "scalar",
      "u64", "some", "result", "none", "none", "[method]request-options.between-bytes-timeout",
      "func", "function", "false", "1", "self", "borrow", "9", "some", "option",
      "scalar", "u64", "[method]request-options.set-between-bytes-timeout", "func",
      "function", "false", "2", "self", "borrow", "9", "duration", "option", "scalar",
      "u64", "some", "result", "none", "none", "[static]response-outparam.set", "func",
      "function", "false", "2", "param", "own", "10", "response", "result", "some",
      "own", "11", "some", "variant", "39", "DNS-timeout", "none", "DNS-error", "some",
      "record", "2", "rcode", "option", "scalar", "string", "info-code", "option",
      "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "none", "[method]incoming-response.status", "func", "function",
      "false", "1", "self", "borrow", "12", "some", "scalar", "u16", "[method]incoming-response.headers",
      "func", "function", "false", "1", "self", "borrow", "12", "some", "own", "4",
      "[method]incoming-response.consume", "func", "function", "false", "1", "self",
      "borrow", "12", "some", "result", "some", "own", "6", "none", "[method]incoming-body.stream",
      "func", "function", "false", "1", "self", "borrow", "6", "some", "result",
      "some", "own", "2", "none", "[static]incoming-body.finish", "func", "function",
      "false", "1", "this", "own", "6", "some", "own", "13", "[method]future-trailers.subscribe",
      "func", "function", "false", "1", "self", "borrow", "13", "some", "own", "0",
      "[method]future-trailers.get", "func", "function", "false", "1", "self", "borrow",
      "13", "some", "option", "result", "some", "result", "some", "option", "own",
      "4", "some", "variant", "39", "DNS-timeout", "none", "DNS-error", "some", "record",
      "2", "rcode", "option", "scalar", "string", "info-code", "option", "scalar",
      "u16", "destination-not-found", "none", "destination-unavailable", "none",
      "destination-IP-prohibited", "none", "destination-IP-unroutable", "none", "connection-refused",
      "none", "connection-terminated", "none", "connection-timeout", "none", "connection-read-timeout",
      "none", "connection-write-timeout", "none", "connection-limit-reached", "none",
      "TLS-protocol-error", "none", "TLS-certificate-error", "none", "TLS-alert-received",
      "some", "record", "2", "alert-id", "option", "scalar", "u8", "alert-message",
      "option", "scalar", "string", "HTTP-request-denied", "none", "HTTP-request-length-required",
      "none", "HTTP-request-body-size", "some", "option", "scalar", "u64", "HTTP-request-method-invalid",
      "none", "HTTP-request-URI-invalid", "none", "HTTP-request-URI-too-long", "none",
      "HTTP-request-header-section-size", "some", "option", "scalar", "u32", "HTTP-request-header-size",
      "some", "option", "record", "2", "field-name", "option", "scalar", "string",
      "field-size", "option", "scalar", "u32", "HTTP-request-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-incomplete", "none", "HTTP-response-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-header-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-body-size", "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "none", "[constructor]outgoing-response", "func", "function",
      "false", "1", "headers", "own", "4", "some", "own", "11", "[method]outgoing-response.status-code",
      "func", "function", "false", "1", "self", "borrow", "11", "some", "scalar",
      "u16", "[method]outgoing-response.set-status-code", "func", "function", "false",
      "2", "self", "borrow", "11", "status-code", "scalar", "u16", "some", "result",
      "none", "none", "[method]outgoing-response.headers", "func", "function", "false",
      "1", "self", "borrow", "11", "some", "own", "4", "[method]outgoing-response.body",
      "func", "function", "false", "1", "self", "borrow", "11", "some", "result",
      "some", "own", "8", "none", "[method]outgoing-body.write", "func", "function",
      "false", "1", "self", "borrow", "8", "some", "result", "some", "own", "3",
      "none", "[static]outgoing-body.finish", "func", "function", "false", "2", "this",
      "own", "8", "trailers", "option", "own", "4", "some", "result", "none", "some",
      "variant", "39", "DNS-timeout", "none", "DNS-error", "some", "record", "2",
      "rcode", "option", "scalar", "string", "info-code", "option", "scalar", "u16",
      "destination-not-found", "none", "destination-unavailable", "none", "destination-IP-prohibited",
      "none", "destination-IP-unroutable", "none", "connection-refused", "none",
      "connection-terminated", "none", "connection-timeout", "none", "connection-read-timeout",
      "none", "connection-write-timeout", "none", "connection-limit-reached", "none",
      "TLS-protocol-error", "none", "TLS-certificate-error", "none", "TLS-alert-received",
      "some", "record", "2", "alert-id", "option", "scalar", "u8", "alert-message",
      "option", "scalar", "string", "HTTP-request-denied", "none", "HTTP-request-length-required",
      "none", "HTTP-request-body-size", "some", "option", "scalar", "u64", "HTTP-request-method-invalid",
      "none", "HTTP-request-URI-invalid", "none", "HTTP-request-URI-too-long", "none",
      "HTTP-request-header-section-size", "some", "option", "scalar", "u32", "HTTP-request-header-size",
      "some", "option", "record", "2", "field-name", "option", "scalar", "string",
      "field-size", "option", "scalar", "u32", "HTTP-request-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-incomplete", "none", "HTTP-response-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-header-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-body-size", "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size",
      "some", "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "[method]future-incoming-response.subscribe", "func", "function",
      "false", "1", "self", "borrow", "14", "some", "own", "0", "[method]future-incoming-response.get",
      "func", "function", "false", "1", "self", "borrow", "14", "some", "option",
      "result", "some", "result", "some", "own", "12", "some", "variant", "39", "DNS-timeout",
      "none", "DNS-error", "some", "record", "2", "rcode", "option", "scalar", "string",
      "info-code", "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "none", "http-error-code", "func", "function", "false",
      "1", "err", "borrow", "1", "some", "option", "variant", "39", "DNS-timeout",
      "none", "DNS-error", "some", "record", "2", "rcode", "option", "scalar", "string",
      "info-code", "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "wasi:http/outgoing-handler@0.2.3", "instance", "interface",
      "wasi:http/outgoing-handler@0.2.3", "4", "outgoing-request", "outgoing-request",
      "wasi:http/types@0.2.3", "request-options", "request-options", "wasi:http/types@0.2.3",
      "future-incoming-response", "future-incoming-response", "wasi:http/types@0.2.3",
      "error-code", "error-code", "wasi:http/types@0.2.3", "5", "outgoing-request",
      "type", "resource", "7", "request-options", "type", "resource", "9", "future-incoming-response",
      "type", "resource", "14", "error-code", "type", "variant", "39", "DNS-timeout",
      "none", "DNS-error", "some", "record", "2", "rcode", "option", "scalar", "string",
      "info-code", "option", "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "handle", "func", "function", "false", "2", "request",
      "own", "7", "options", "option", "own", "9", "some", "result", "some", "own",
      "14", "some", "variant", "39", "DNS-timeout", "none", "DNS-error", "some",
      "record", "2", "rcode", "option", "scalar", "string", "info-code", "option",
      "scalar", "u16", "destination-not-found", "none", "destination-unavailable",
      "none", "destination-IP-prohibited", "none", "destination-IP-unroutable", "none",
      "connection-refused", "none", "connection-terminated", "none", "connection-timeout",
      "none", "connection-read-timeout", "none", "connection-write-timeout", "none",
      "connection-limit-reached", "none", "TLS-protocol-error", "none", "TLS-certificate-error",
      "none", "TLS-alert-received", "some", "record", "2", "alert-id", "option",
      "scalar", "u8", "alert-message", "option", "scalar", "string", "HTTP-request-denied",
      "none", "HTTP-request-length-required", "none", "HTTP-request-body-size", "some",
      "option", "scalar", "u64", "HTTP-request-method-invalid", "none", "HTTP-request-URI-invalid",
      "none", "HTTP-request-URI-too-long", "none", "HTTP-request-header-section-size",
      "some", "option", "scalar", "u32", "HTTP-request-header-size", "some", "option",
      "record", "2", "field-name", "option", "scalar", "string", "field-size", "option",
      "scalar", "u32", "HTTP-request-trailer-section-size", "some", "option", "scalar",
      "u32", "HTTP-request-trailer-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-incomplete",
      "none", "HTTP-response-header-section-size", "some", "option", "scalar", "u32",
      "HTTP-response-header-size", "some", "record", "2", "field-name", "option",
      "scalar", "string", "field-size", "option", "scalar", "u32", "HTTP-response-body-size",
      "some", "option", "scalar", "u64", "HTTP-response-trailer-section-size", "some",
      "option", "scalar", "u32", "HTTP-response-trailer-size", "some", "record",
      "2", "field-name", "option", "scalar", "string", "field-size", "option", "scalar",
      "u32", "HTTP-response-transfer-coding", "some", "option", "scalar", "string",
      "HTTP-response-content-coding", "some", "option", "scalar", "string", "HTTP-response-timeout",
      "none", "HTTP-upgrade-failed", "none", "HTTP-protocol-error", "none", "loop-detected",
      "none", "configuration-error", "none", "internal-error", "some", "option",
      "scalar", "string", "1", "out", "instance", "interface", "", "0", "1", "wasi:http/incoming-handler@0.2.3",
      "instance", "interface", "wasi:http/incoming-handler@0.2.3", "2", "incoming-request",
      "incoming-request", "wasi:http/types@0.2.3", "response-outparam", "response-outparam",
      "wasi:http/types@0.2.3", "3", "incoming-request", "type", "resource", "5",
      "response-outparam", "type", "resource", "10", "handle", "func", "function",
      "false", "2", "request", "own", "5", "response-out", "own", "10", "none",
    ])
  }
}
