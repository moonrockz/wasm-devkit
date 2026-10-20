///|
fn deep_type_leb(out : Array[Byte], value : Int32) -> Unit {
  for rest = value {
    let next = rest >> 7
    out.push(((rest & 127) | (if next == 0 { 0 } else { 128 })).to_byte())
    if next == 0 {
      break
    }
    continue next
  }
}

///|
fn deep_type_component(
  depth : Int32,
  mode : Int32,
  invalid~ : Bool = false,
) -> Bytes {
  // The leaf aliases its parent's preceding u32, then uses that alias.
  let mut td : Array[Byte] = [
    0x41,
    2,
    2,
    3,
    2,
    1,
    0,
    1,
    0x70,
    if invalid {
      1
    } else {
      0
    },
  ]
  for i in 1..<depth {
    let op : Byte = if mode == 0 || (mode == 2 && i % 2 == 0) {
      0x41
    } else {
      0x42
    }
    let parent : Array[Byte] = [op, 3, 1, 0x79, 1]
    parent.append(td)
    // This must run after the child has been validated and recorded at slot 1.
    parent.append([2, 3, 2, 0, 1])
    td = parent
  }
  let payload : Array[Byte] = [1]
  payload.append(td)
  let bytes : Array[Byte] = [0, 0x61, 0x73, 0x6d, 0x0d, 0, 1, 0, 7]
  deep_type_leb(bytes, payload.length())
  bytes.append(payload)
  Bytes::from_array(bytes)
}

///|
test "256 type scopes preserve outer aliases and declaration order" {
  for mode in 0..<3 {
    let bytes = deep_type_component(256, mode)
    assert_true(@binary.validate_declarative_component(bytes) is Ok(_))
    assert_true(@binary.validate_type_component(bytes) is Ok(_))
    let invalid = deep_type_component(256, mode, invalid=true)
    assert_eq(
      @binary.validate_declarative_component(invalid).unwrap_err()[0].code,
      "WIT-B003",
    )
    assert_eq(
      @binary.validate_type_component(invalid).unwrap_err()[0].code,
      "WIT-B003",
    )
    let beyond = deep_type_component(257, mode)
    assert_eq(
      @binary.validate_declarative_component(beyond).unwrap_err()[0].code,
      "WIT-B002",
    )
    assert_eq(
      @binary.validate_type_component(beyond).unwrap_err()[0].code,
      "WIT-B002",
    )
  }
}
