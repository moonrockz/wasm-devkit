///|
fn runtime_leb(value : Int32) -> Array[Byte] {
  let mut value = value
  let bytes = []
  while value >= 128 {
    bytes.push(((value & 127) | 128).to_byte())
    value = value >> 7
  }
  bytes.push(value.to_byte())
  bytes
}

///|
fn runtime_section(id : Byte, payload : Array[Byte]) -> Array[Byte] {
  [id] + runtime_leb(payload.length()) + payload
}

///|
fn runtime_body(body : Array[Byte]) -> Bytes {
  let core_bytes = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00".to_array() +
    runtime_section(b'\x0a', [b'\x01'] + runtime_leb(body.length()) + body)
  Bytes::from_array(
    b"\x00asm\x0d\x00\x01\x00".to_array() + runtime_section(b'\x01', core_bytes),
  )
}

///|
test "concrete modules validate long flat functions without recursive walks" {
  let bytes = runtime_body([b'\x00'] + Array::make(20000, b'\x01') + [b'\x0b'])
  let result = @verifier.decode_component_package(bytes)
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap().bytes(), bytes)
}

///|
test "concrete module control depth rejects before instruction parsing" {
  let body = [b'\x00']
  for _ in 0..<10000 {
    body.push(b'\x02')
    body.push(b'\x40')
  }
  for _ in 0..<10001 {
    body.push(b'\x0b')
  }
  assert_eq(
    @verifier.decode_component_package(runtime_body(body)).unwrap_err()[0].code,
    "WAC-B002",
  )
  let source = "(component (core module (func " +
    Array::make(10000, "block ").join("") +
    Array::make(10000, "end ").join("") +
    ")))"
  assert_eq(
    @verifier.decode_wat_component_package(source).unwrap_err()[0].code,
    "WAC-B002",
  )
}

///|
test "concrete module local expansion has a checked budget" {
  let body = [b'\x01'] + runtime_leb(1000001) + [b'\x7f', b'\x0b']
  assert_eq(
    @verifier.decode_component_package(runtime_body(body)).unwrap_err()[0].code,
    "WAC-B002",
  )
}

///|
test "concrete module malformed code preserves binary provenance" {
  for
    body in [
      [b'\x00', b'\x41', b'\x80'],
      [b'\x00', b'\x0b', b'\x0b'],
      [b'\x00', b'\x41', b'\xff', b'\xff', b'\xff', b'\xff', b'\x0f', b'\x0b'],
      [
        b'\x00', b'\x42', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80',
        b'\x80', b'\x80', b'\x02', b'\x0b',
      ],
    ] {
    let errors = @verifier.decode_component_package(
      runtime_body(body),
      source_id="broken.wasm",
    ).unwrap_err()
    assert_eq(errors[0].code, "WAC-B001")
    assert_true(errors[0].render().contains("broken.wasm"))
  }
}

///|
test "concrete module validation bounds retained type comparisons" {
  let types = runtime_leb(2000)
  for _ in 0..<2000 {
    types.push(b'\x60')
    types.push(b'\x00')
    types.push(b'\x00')
  }
  let core_bytes = b"\x00asm\x01\x00\x00\x00".to_array() +
    runtime_section(b'\x01', types)
  let bytes = Bytes::from_array(
    b"\x00asm\x0d\x00\x01\x00".to_array() + runtime_section(b'\x01', core_bytes),
  )
  assert_eq(
    @verifier.decode_component_package(bytes).unwrap_err()[0].code,
    "WAC-B002",
  )
}

///|
test "component shares validation work across concrete modules" {
  let body = [b'\x01'] + runtime_leb(500000) + [b'\x7f', b'\x0b']
  let core_bytes = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00".to_array() +
    runtime_section(b'\x0a', [b'\x01'] + runtime_leb(body.length()) + body)
  let section = runtime_section(b'\x01', core_bytes)
  let bytes = Bytes::from_array(
    b"\x00asm\x0d\x00\x01\x00".to_array() + section + section,
  )
  let diagnostic = @verifier.decode_component_package(bytes).unwrap_err()[0]
  assert_eq(diagnostic.code, "WAC-B002")
  assert_true(diagnostic.message.contains("component core validation work"))
}
