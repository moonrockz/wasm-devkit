///|
priv struct ValueEncodingFrame {
  reader : Reader
  output : Array[Byte]
}

///|
// Rebuild enclosing section lengths after inserting the retained parser's
// legacy value-bound tag. Nested component bodies use an explicit stack;
// core bodies, names and custom data remain byte-for-byte unchanged.
fn legacy_value_encoding(
  bytes : Bytes,
  offsets : Array[Int32],
) -> Bytes raise Boundary {
  if offsets.is_empty() {
    return bytes
  }
  let positions : Map[Int32, Bool] = Map([])
  for offset in offsets {
    positions[offset] = true
  }
  let stack : Array[ValueEncodingFrame] = [
    {
      reader: { bytes, position: 8, end: bytes.length(), },
      output: [0, 0x61, 0x73, 0x6d, 0x0d, 0, 1, 0],
    },
  ]
  let mut inserted = 0
  let mut work = 0
  fn append(target : Array[Byte], value : Byte) -> Unit raise Boundary {
    work += 1
    if work > 16777216 {
      raise Failure(
        None,
        "WIT-B002",
        "value compatibility encoding exceeds work limit",
      )
    }
    target.push(value)
  }
  fn unsigned(target : Array[Byte], value : Int32) -> Unit raise Boundary {
    let mut value = value
    while value >= 128 {
      append(target, ((value & 127) | 128).to_byte())
      value = value >> 7
    }
    append(target, value.to_byte())
  }
  while stack.last() is Some(frame) {
    let reader = frame.reader
    if reader.position == reader.end {
      ignore(stack.pop())
      if stack.last() is Some(parent) {
        append(parent.output, 4)
        unsigned(parent.output, frame.output.length())
        for byte in frame.output {
          append(parent.output, byte)
        }
        continue
      }
      guard inserted == offsets.length() else {
        raise Failure(None, "WIT-B001", "invalid value descriptor position")
      }
      return Bytes::from_array(frame.output)
    }
    let start = reader.position
    let section = reader.byte()
    let length = reader.count()
    let payload = reader.position
    let end = payload + length
    reader.position = end
    if section == 4 {
      stack.push({
        reader: { bytes, position: payload + 8, end, },
        output: [0, 0x61, 0x73, 0x6d, 0x0d, 0, 1, 0],
      })
      continue
    }
    let mut count = 0
    for position in payload..<end {
      if positions.contains(position) {
        count += 1
      }
    }
    if count == 0 {
      for position in start..<end {
        append(frame.output, bytes[position])
      }
    } else {
      append(frame.output, section.to_byte())
      unsigned(frame.output, length + count)
      for position in payload..<end {
        if positions.contains(position) {
          append(frame.output, 1)
          inserted += 1
        }
        append(frame.output, bytes[position])
      }
    }
  }
  raise Failure(None, "WIT-B001", "missing component encoding")
}
