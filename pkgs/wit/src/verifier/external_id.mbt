///|
fn external_id_hex(code : Int32) -> Int32? {
  if code >= 48 && code <= 57 {
    Some(code - 48)
  } else if code >= 65 && code <= 70 {
    Some(code - 65 + 10)
  } else if code >= 97 && code <= 102 {
    Some(code - 97 + 10)
  } else {
    None
  }
}

///|
fn external_id_scalar(bytes : Array[Byte], scalar : Int32) -> Unit {
  if scalar < 0x80 {
    bytes.push(scalar.to_byte())
  } else if scalar < 0x800 {
    bytes.push((0xc0 | (scalar >> 6)).to_byte())
    bytes.push((0x80 | (scalar & 63)).to_byte())
  } else if scalar < 0x10000 {
    bytes.push((0xe0 | (scalar >> 12)).to_byte())
    bytes.push((0x80 | ((scalar >> 6) & 63)).to_byte())
    bytes.push((0x80 | (scalar & 63)).to_byte())
  } else {
    bytes.push((0xf0 | (scalar >> 18)).to_byte())
    bytes.push((0x80 | ((scalar >> 12) & 63)).to_byte())
    bytes.push((0x80 | ((scalar >> 6) & 63)).to_byte())
    bytes.push((0x80 | (scalar & 63)).to_byte())
  }
}

///|
// Attribute ASTs retain the original quoted spelling. Decode without filesystem
// access, including byte escapes whose UTF-8 validity depends on adjacent bytes.
fn external_id_string(text : String) -> String? {
  guard text.length() >= 2 &&
    text.code_unit_at(0) == 34 &&
    text.code_unit_at(text.length() - 1) == 34 else {
    return None
  }
  let bytes : Array[Byte] = []
  let end = text.length() - 1
  let mut index = 1
  while index < end {
    let mut code = text.code_unit_at(index).to_int()
    index += 1
    if code == 92 {
      guard index < end else { return None }
      code = text.code_unit_at(index).to_int()
      index += 1
      match code {
        34 | 39 | 92 => bytes.push(code.to_byte())
        116 => bytes.push(9)
        110 => bytes.push(10)
        114 => bytes.push(13)
        117 => {
          guard index < end && text.code_unit_at(index) == 123 else {
            return None
          }
          index += 1
          let mut scalar = 0
          let mut digits = 0
          let mut last_digit = false
          while index < end && text.code_unit_at(index) != 125 {
            let code = text.code_unit_at(index).to_int()
            index += 1
            if code == 95 && digits > 0 {
              last_digit = false
              continue
            }
            guard external_id_hex(code) is Some(digit) &&
              scalar <= (0x10ffff - digit) / 16 else {
              return None
            }
            scalar = scalar * 16 + digit
            digits += 1
            last_digit = true
          }
          guard index < end &&
            last_digit &&
            !(scalar >= 0xd800 && scalar <= 0xdfff) else {
            return None
          }
          index += 1
          external_id_scalar(bytes, scalar)
        }
        _ => {
          guard external_id_hex(code) is Some(high) &&
            index < end &&
            external_id_hex(text.code_unit_at(index).to_int()) is Some(low) else {
            return None
          }
          index += 1
          bytes.push((high * 16 + low).to_byte())
        }
      }
    } else {
      guard code >= 32 && code != 127 && code != 34 else { return None }
      if code >= 0xd800 && code <= 0xdbff {
        guard index < end else { return None }
        let low = text.code_unit_at(index).to_int()
        guard low >= 0xdc00 && low <= 0xdfff else { return None }
        index += 1
        code = 0x10000 + ((code - 0xd800) << 10) + low - 0xdc00
      } else if code >= 0xdc00 && code <= 0xdfff {
        return None
      }
      external_id_scalar(bytes, code)
    }
  }
  Some(@utf8.decode(Bytes::from_array(bytes), ignore_bom=false)) catch {
    _ => None
  }
}

///|
fn parse_external_ids(
  prepared : Prepared,
  errors : Array[Diagnostic],
) -> ReadOnlyArray[String?] {
  let values : Array[String?] = Array::make(prepared.tree.nodes.length(), None)
  for id, node in prepared.tree.nodes {
    let retained = type_declaration(node.data) ||
      (match node.data {
        Function(..) | Constructor(..) | Import(..) | Export(..) | Use(..) =>
          true
        _ => false
      })
    let mut first : Int32? = None
    for attribute in item_attributes(node.data) {
      guard prepared.tree.nodes[attribute].data
        is Attribute(name="external-id", field~, value~) else {
        continue
      }
      let decoded = if field == "" { external_id_string(value) } else { None }
      if decoded is None {
        errors.push(
          prepared_error(
            prepared, attribute, "WIT-S013", "@external-id requires a valid quoted string",
          ),
        )
      }
      if retained {
        if first is Some(previous) {
          let error = prepared_error(
            prepared, attribute, "WIT-S013", "duplicate @external-id annotation",
          )
          errors.push({
            ..error,
            related: [
              {
                location: prepared.origins[previous].location,
                message: "first annotation",
              },
            ],
          })
        }
        first = Some(attribute)
        values[id] = decoded
      }
    }
    if node.data is Use(names~, ..) {
      for selector in names {
        values[selector] = values[id]
      }
    }
  }
  ReadOnlyArray::from_array(values)
}
