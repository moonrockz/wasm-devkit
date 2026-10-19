///|
test "resource intrinsic composition new-local" {
  let source = "package test:app; let i = new test:resource {}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x08\x03\x01\x02\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72"
  let text = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (core func $f (canon resource.new $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:resource", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "resource intrinsic composition new-alias" {
  let source = "package test:app; let i = new test:resource {}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x08\x03\x01\x02\x01\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x37\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x0c\x03\x02\x00\x01\x72\x01\x05\x61\x6c\x69\x61\x73"
  let text = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (export $alias \"r\" (type $r)) (core func $f (canon resource.new $alias)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i32)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:resource", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "1", "r", "type", "resource",
      "0",
    ])
  }
}

///|
test "resource intrinsic composition rep-i64-consumer" {
  let source = "package test:app; let i = new test:resource {}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7e\x00\x08\x03\x01\x04\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x72"
  let text = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i64))) (core func $f (canon resource.rep $r)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (param i32) (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:resource", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "resource intrinsic composition destructor-i64-i64" {
  let source = "package test:app; let i = new test:resource {}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7e\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7e\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72"
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"drop\") (param i64))) (core instance $i (instantiate $m)) (alias core export $i \"drop\" (core func $drop)) (type $r (resource (rep i64) (dtor $drop))) (core func (canon resource.new $r)))",
  ).unwrap()
  for bytes in [bytes, text.bytes()] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:resource", version: None, source: "dep.wasm", bytes, },
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
      "0", "1", "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "resource intrinsic composition destructor-i64-i32" {
  let source = "package test:app; let i = new test:resource {}; export i as \"out\";"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x72\x6f\x70\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x07\x05\x01\x3f\x7e\x01\x00\x08\x03\x01\x02\x00\x00\x31\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x00\x01\x00\x04\x64\x72\x6f\x70\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x03\x01\x00\x01\x72"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:resource", version: None, source: "dep.wasm", bytes, },
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
