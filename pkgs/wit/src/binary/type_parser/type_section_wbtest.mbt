///|
fn parser_nested_types(depth : Int32) -> Bytes {
  let bytes : Array[Byte] = [1]
  for i in 1..<depth {
    bytes.append([if i % 2 == 0 { 0x41 } else { 0x42 }, 1, 1])
  }
  bytes.append([0x42, 0])
  Bytes::from_array(bytes)
}

///|
test "type parser uses constant call stack beyond the public profile" {
  let mut td = parse_type_section(parser_nested_types(6000))[0]
  let mut count = 1
  while true {
    match td {
      ComponentType([Type(child)]) | InstanceType([Type(child)]) => {
        td = child
        count += 1
      }
      InstanceTypeEmpty => break
      _ => fail("unexpected nested type")
    }
  }
  assert_eq(count, 6000)
}

///|
test "type parser agrees with the pinned parser for shallow scope structure" {
  for depth in 1..<16 {
    let payload = parser_nested_types(depth)
    assert_eq(
      parse_type_section(payload),
      @component.parse_type_section(payload),
    )
  }
  for
    payload in [
      b"\x01\x42\x02\x00\x50\x02\x01\x60\x01\x7f\x00\x03\x01t\x04\x00\x00\x04\x00\x01m\x00\x11\x00",
      b"\x01\x42\x02\x00\x50\x01\x00\x00\x01t\x01\x64\x6c\x00\x01\x04\x00\x01m\x00\x11\x00",
      // Import/export attributes, equality bounds and instance aliases.
       b"\x01\x41\x04\x01\x79\x03\x02\x01x\x01\x02\x01y\x03\x00\x00\x04\x00\x01z\x03\x01\x02\x03\x00\x00\x01a",
    ] {
    assert_eq(
      parse_type_section(payload),
      @component.parse_type_section(payload),
    )
  }
}

///|
test "truncated deep types and oversized counts return parse errors" {
  let payload = parser_nested_types(256)
  for end in 0..<payload.length() {
    let rejected = try {
      ignore(parse_type_section(payload[:end].to_owned()))
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
  for
    payload in [
      b"\xff\xff\xff\xff\x0f", b"\x01\x41\xff\xff\xff\xff\x0f", b"\x01\x42\xff\xff\xff\xff\x0f",
    ] {
    let rejected = try {
      ignore(parse_type_section(payload))
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
}
