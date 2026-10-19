///|
// The retained parser predates direct value extern descriptors. The strict
// framing pass records only those positions, never bytes inside core bodies,
// names, custom data or value type definitions. Adapt metadata for that parser
// without replacing the original snapshot or changing any core module body.
fn legacy_value_encoding(
  bytes : Bytes,
  offsets : Array[Int32],
) -> Bytes raise Boundary {
  if offsets.is_empty() {
    return bytes
  }
  if bytes.length() > 2147483647 - offsets.length() {
    raise Failure(
      None,
      "WIT-B002",
      "value compatibility encoding exceeds size limit",
    )
  }
  let out : Array[Byte] = []
  fn copy(start : Int32, end : Int32) -> Unit {
    for i in start..<end {
      out.push(bytes[i])
    }
  }
  fn unsigned(value : Int32) -> Unit {
    let mut value = value
    while value >= 128 {
      out.push(((value & 127) | 128).to_byte())
      value = value >> 7
    }
    out.push(value.to_byte())
  }
  copy(0, 8)
  let reader : Reader = { bytes, position: 8, end: bytes.length(), }
  let mut index = 0
  while reader.position < reader.end {
    let start = reader.position
    let section = reader.byte()
    let length = reader.count()
    let payload = reader.position
    let end = payload + length
    let first = index
    while index < offsets.length() && offsets[index] < end {
      guard offsets[index] >= payload &&
        (index == 0 || offsets[index] > offsets[index - 1]) else {
        raise Failure(None, "WIT-B001", "invalid value descriptor position")
      }
      index += 1
    }
    if first == index {
      copy(start, end)
    } else {
      out.push(section.to_byte())
      unsigned(length + index - first)
      let mut cursor = payload
      for i in first..<index {
        copy(cursor, offsets[i])
        out.push(1)
        cursor = offsets[i]
      }
      copy(cursor, end)
    }
    reader.position = end
  }
  guard index == offsets.length() else {
    raise Failure(None, "WIT-B001", "invalid value descriptor position")
  }
  Bytes::from_array(out)
}
