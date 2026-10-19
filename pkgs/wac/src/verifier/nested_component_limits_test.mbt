///|
fn nested_binary(child : Bytes) -> Bytes {
  let out : Array[Byte] = [0, 0x61, 0x73, 0x6d, 0x0d, 0, 1, 0, 4]
  let mut size = child.length()
  while size >= 128 {
    out.push(((size & 127) | 128).to_byte())
    size = size >> 7
  }
  out.push(size.to_byte())
  for byte in child {
    out.push(byte)
  }
  Bytes::from_array(out)
}

///|
test "concrete component binary depth limit" {
  let mut bytes = b"\x00asm\x0d\x00\x01\x00"
  for _ in 0..<256 {
    bytes = nested_binary(bytes)
  }
  let result = @verifier.decode_component_package(bytes)
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let result = @verifier.decode_component_package(nested_binary(bytes))
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
}

///|
test "concrete component text depth limit" {
  let text = "(component ".repeat(256) + ")".repeat(256)
  let result = @verifier.decode_wat_component_package(text)
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let result = @verifier.decode_wat_component_package(
    "(component " + text + ")",
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
}

///|
test "concrete component nested malformed headers and sections" {
  for
    child in [
      b"", b"\x00asm\x01\x00\x00\x00", b"\x00asm\x0d\x00\x01\x00\x07\x03\x01",
    ] {
    let result = @verifier.decode_component_package(nested_binary(child))
    assert_eq(result.unwrap_err()[0].code, "WAC-B001")
  }
}

///|
test "concrete component nested value encoding cumulative copy bound" {
  // A valid value import/export followed by opaque custom data. No large
  // fixture is stored; repeated component envelopes charge each rebuilt byte.
  let value = b"\x00asm\x0d\x00\x01\x00\x0a\x06\x01\x00\x01v\x02\x79\x0b\x07\x01\x00\x01v\x02\x00\x00"
  for size in [512, 600000] {
    let data : Array[Byte] = []
    for byte in value {
      data.push(byte)
    }
    data.push(0)
    let mut length = size + 1
    while length >= 128 {
      data.push(((length & 127) | 128).to_byte())
      length = length >> 7
    }
    data.push(length.to_byte())
    data.push(0)
    for _ in 0..<size {
      data.push(0)
    }
    let mut bytes = Bytes::from_array(data)
    for _ in 0..<32 {
      bytes = nested_binary(bytes)
    }
    let result = @verifier.decode_component_package(bytes)
    if size == 512 {
      assert_true(
        result is Ok(_),
        msg=match result {
          Ok(_) => "accepted"
          Err(e) => e[0].render()
        },
      )
    } else {
      assert_eq(result.unwrap_err()[0].code, "WAC-B002")
      assert_true(
        result.unwrap_err()[0].message.contains("compatibility encoding"),
      )
    }
  }
}

///|
test "concrete component cumulative scope budget is unsupported" {
  let mut chain = b"\x00asm\x0d\x00\x01\x00"
  for _ in 0..<255 {
    chain = nested_binary(chain)
  }
  let envelope = nested_binary(chain)
  let bytes : Array[Byte] = [0, 0x61, 0x73, 0x6d, 0x0d, 0, 1, 0]
  for _ in 0..<32 {
    for index in 8..<envelope.length() {
      bytes.push(envelope[index])
    }
  }
  let result = @verifier.decode_component_package(Bytes::from_array(bytes))
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
  assert_true(result.unwrap_err()[0].message.contains("scope work limit"))
}
