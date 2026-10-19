///|
priv enum WatToken {
  Open
  Close
  Atom(String)
  Quoted(Bytes)
  Identifier(String)
}

///|
fn wat_confusing(unit : Int32) -> Bool {
  [0x202a, 0x202b, 0x202d, 0x202e, 0x2066, 0x2067, 0x2068, 0x2069, 0x206c].contains(
    unit,
  )
}

///|
fn wat_hex(unit : Int32) -> Int32? {
  if unit >= 48 && unit <= 57 {
    Some(unit - 48)
  } else if unit >= 65 && unit <= 70 {
    Some(unit - 55)
  } else if unit >= 97 && unit <= 102 {
    Some(unit - 87)
  } else {
    None
  }
}

///|
fn wat_scalar(out : Array[Byte], scalar : Int32) -> Unit raise EncodedFailure {
  guard scalar >= 0 &&
    scalar <= 0x10ffff &&
    !(scalar >= 0xd800 && scalar <= 0xdfff) else {
    raise Invalid("invalid WAT Unicode scalar")
  }
  if scalar < 0x80 {
    out.push(scalar.to_byte())
  } else if scalar < 0x800 {
    out.push((0xc0 | (scalar >> 6)).to_byte())
    out.push((0x80 | (scalar & 63)).to_byte())
  } else if scalar < 0x10000 {
    out.push((0xe0 | (scalar >> 12)).to_byte())
    out.push((0x80 | ((scalar >> 6) & 63)).to_byte())
    out.push((0x80 | (scalar & 63)).to_byte())
  } else {
    out.push((0xf0 | (scalar >> 18)).to_byte())
    out.push((0x80 | ((scalar >> 12) & 63)).to_byte())
    out.push((0x80 | ((scalar >> 6) & 63)).to_byte())
    out.push((0x80 | (scalar & 63)).to_byte())
  }
}

///|
fn wat_quoted(
  text : String,
  start : Int32,
) -> (Bytes, Int32) raise EncodedFailure {
  let out : Array[Byte] = []
  let mut position = start + 1
  while position < text.length() {
    let unit = text.code_unit_at(position).to_int()
    position += 1
    if unit == 34 {
      return (Bytes::from_array(out), position)
    }
    if unit == 92 {
      guard position < text.length() else {
        raise Invalid("unterminated WAT escape")
      }
      let escape = text.code_unit_at(position).to_int()
      position += 1
      match escape {
        34 | 39 | 92 => out.push(escape.to_byte())
        110 => out.push(10)
        114 => out.push(13)
        116 => out.push(9)
        117 => {
          guard position < text.length() &&
            text.code_unit_at(position).to_int() == 123 else {
            raise Invalid("WAT Unicode escape needs a brace")
          }
          position += 1
          guard position < text.length() &&
            wat_hex(text.code_unit_at(position).to_int()) is Some(_) else {
            raise Invalid("WAT Unicode escape needs a digit")
          }
          let mut value = 0
          let mut underscore = false
          while position < text.length() {
            let unit = text.code_unit_at(position).to_int()
            if unit == 95 {
              underscore = true
              position += 1
              continue
            }
            guard wat_hex(unit) is Some(digit) else { break }
            value = value * 16 + digit
            guard value <= 0x10ffff else {
              raise Invalid("WAT Unicode scalar exceeds its range")
            }
            underscore = false
            position += 1
          }
          guard !underscore &&
            position < text.length() &&
            text.code_unit_at(position).to_int() == 125 else {
            raise Invalid("unterminated WAT Unicode escape")
          }
          position += 1
          wat_scalar(out, value)
        }
        _ => {
          guard wat_hex(escape) is Some(high) &&
            position < text.length() &&
            wat_hex(text.code_unit_at(position).to_int()) is Some(low) else {
            raise Invalid("invalid WAT string escape")
          }
          out.push((high * 16 + low).to_byte())
          position += 1
        }
      }
    } else {
      guard unit >= 32 && unit != 127 && !wat_confusing(unit) else {
        raise Invalid("invalid literal character in WAT string")
      }
      if unit >= 0xd800 && unit <= 0xdbff {
        guard position < text.length() else {
          raise Invalid("unpaired WAT surrogate")
        }
        let low = text.code_unit_at(position).to_int()
        guard low >= 0xdc00 && low <= 0xdfff else {
          raise Invalid("unpaired WAT surrogate")
        }
        position += 1
        wat_scalar(out, 0x10000 + ((unit - 0xd800) << 10) + low - 0xdc00)
      } else {
        wat_scalar(out, unit)
      }
    }
  }
  raise Invalid("unterminated WAT string")
}

///|
fn wat_idchar(unit : Int32) -> Bool {
  (unit >= 48 && unit <= 57) ||
  (unit >= 65 && unit <= 90) ||
  (unit >= 97 && unit <= 122) ||
  [
    33, 35, 36, 37, 38, 39, 42, 43, 45, 46, 47, 58, 60, 61, 62, 63, 64, 92, 94, 95,
    96, 124, 126,
  ].contains(unit)
}

///|
fn wat_separated(text : String, end : Int32) -> Unit raise EncodedFailure {
  if end < text.length() {
    let next = text.code_unit_at(end).to_int()
    guard next != 34 && !wat_idchar(next) else {
      raise Invalid("reserved adjacent WAT tokens")
    }
  }
}

///|
fn wat_tokens(text : String) -> Array[WatToken] raise EncodedFailure {
  let tokens : Array[WatToken] = []
  let mut position = 0
  while position < text.length() {
    let unit = text.code_unit_at(position).to_int()
    let next = if position + 1 < text.length() {
      text.code_unit_at(position + 1).to_int()
    } else {
      -1
    }
    if [9, 10, 13, 32].contains(unit) {
      position += 1
    } else if unit == 59 && next == 59 {
      position += 2
      while position < text.length() &&
            ![10, 13].contains(text.code_unit_at(position).to_int()) {
        guard !wat_confusing(text.code_unit_at(position).to_int()) else {
          raise Invalid("confusing Unicode in WAT comment")
        }
        position += 1
      }
    } else if unit == 40 && next == 59 {
      position += 2
      let mut depth = 1
      while position < text.length() && depth > 0 {
        let unit = text.code_unit_at(position).to_int()
        let next = if position + 1 < text.length() {
          text.code_unit_at(position + 1).to_int()
        } else {
          -1
        }
        guard !wat_confusing(unit) else {
          raise Invalid("confusing Unicode in WAT comment")
        }
        if unit == 40 && next == 59 {
          depth += 1
          position += 2
        } else if unit == 59 && next == 41 {
          depth -= 1
          position += 2
        } else {
          position += 1
        }
      }
      guard depth == 0 else { raise Invalid("unclosed WAT block comment") }
    } else if unit == 40 {
      tokens.push(Open)
      position += 1
    } else if unit == 41 {
      tokens.push(Close)
      position += 1
    } else if unit == 34 {
      let (bytes, end) = wat_quoted(text, position)
      wat_separated(text, end)
      tokens.push(Quoted(bytes))
      position = end
    } else {
      let start = position
      while position < text.length() &&
            ![9, 10, 13, 32, 34, 40, 41, 59].contains(
              text.code_unit_at(position).to_int(),
            ) {
        guard wat_idchar(text.code_unit_at(position).to_int()) else {
          raise Invalid("invalid WAT token character")
        }
        position += 1
      }
      guard position > start else { raise Invalid("invalid WAT token") }
      let atom = text[start:position].to_owned()
      if position < text.length() && text.code_unit_at(position).to_int() == 34 {
        guard atom == "$" || atom == "@" else {
          raise Invalid("reserved adjacent WAT tokens")
        }
        let (bytes, end) = wat_quoted(text, position)
        wat_separated(text, end)
        let name = wat_text(bytes)
        guard !name.is_empty() else { raise Invalid("empty quoted WAT name") }
        if atom == "$" {
          tokens.push(Identifier(name))
        } else {
          guard name == "custom" || name == "producers" else {
            raise Unsupported("quoted WAT annotation")
          }
          tokens.push(Atom("@" + name))
        }
        position = end
      } else {
        guard atom != "$" && atom != "@" else {
          raise Invalid("empty WAT identifier or annotation")
        }
        if atom.has_prefix("$") {
          tokens.push(Identifier(atom[1:].to_owned()))
        } else {
          tokens.push(Atom(atom))
        }
      }
    }
  }
  tokens
}

///|
fn wat_text(bytes : Bytes) -> String raise EncodedFailure {
  @utf8.decode(bytes, ignore_bom=false) catch {
    _ => raise Invalid("WAT name is not UTF-8")
  }
}

///|
fn wat_string(
  tokens : Array[WatToken],
  index : Int32,
) -> Bytes raise EncodedFailure {
  guard index < tokens.length() && tokens[index] is Quoted(bytes) else {
    raise Invalid("expected WAT string")
  }
  bytes
}

///|
fn wat_unsigned(out : Array[Byte], value : Int32) -> Unit {
  let mut value = value
  while value >= 128 {
    out.push(((value & 127) | 128).to_byte())
    value = value >> 7
  }
  out.push(value.to_byte())
}

///|
fn wat_bytes(out : Array[Byte], bytes : Bytes) -> Unit {
  wat_unsigned(out, bytes.length())
  out.append(bytes.to_array())
}

///|
fn wat_end(
  tokens : Array[WatToken],
  start : Int32,
) -> Int32 raise EncodedFailure {
  let mut depth = 0
  for position in start..<tokens.length() {
    match tokens[position] {
      Open => depth += 1
      Close => {
        depth -= 1
        if depth == 0 {
          return position
        }
      }
      _ => ()
    }
  }
  raise Invalid("unclosed WAT annotation")
}

///|
fn wat_producers(
  tokens : Array[WatToken],
  start : Int32,
  end : Int32,
) -> Bytes raise EncodedFailure {
  let fields : Map[String, Array[(Bytes, Bytes)]] = Map([])
  let mut position = start
  while position < end {
    guard position + 4 < end &&
      tokens[position] is Open &&
      tokens[position + 1] is Atom(kind) &&
      ["language", "sdk", "processed-by"].contains(kind) &&
      tokens[position + 4] is Close else {
      raise Invalid("invalid WAT producers field")
    }
    let name = wat_string(tokens, position + 2)
    let version = wat_string(tokens, position + 3)
    ignore(wat_text(name))
    ignore(wat_text(version))
    if !fields.contains(kind) {
      fields[kind] = []
    }
    fields[kind].push((name, version))
    position += 5
  }
  let out : Array[Byte] = []
  wat_unsigned(out, fields.length())
  for kind in ["language", "sdk", "processed-by"] {
    if fields.get(kind) is Some(values) {
      wat_bytes(out, @utf8.encode(kind))
      wat_unsigned(out, values.length())
      for (name, version) in values {
        wat_bytes(out, name)
        wat_bytes(out, version)
      }
    }
  }
  Bytes::from_array(out)
}

///|
fn wat_literal(bytes : Bytes) -> String raise EncodedFailure {
  let text = wat_text(bytes)
  let out = StringBuilder()
  out.write_string("\"")
  for c in text {
    match c {
      '"' => out.write_string("\\\"")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      _ => {
        let value = c.to_int()
        if value < 32 || value == 127 {
          let hex = "0123456789abcdef"
          out.write_string(
            "\\" +
            hex[value >> 4:value / 16 + 1].to_owned() +
            hex[value & 15:(value & 15) + 1].to_owned(),
          )
        } else {
          out.write_char(c)
        }
      }
    }
  }
  out.write_string("\"")
  out.to_string()
}

///|
// Compile the type syntax through the maintained frontend. Extracted customs
// retain their original bytes; they do not participate in component index spaces.
fn compile_encoded_wat(text : String) -> Bytes raise EncodedFailure {
  let tokens = wat_tokens(text)
  if tokens.length() >= 3 && tokens[0] is Open && tokens[1] is Atom("component") {
    let index = if tokens[2] is Identifier(_) { 3 } else { 2 }
    if index < tokens.length() && tokens[index] is Atom("binary") {
      guard tokens[tokens.length() - 1] is Close else {
        raise Invalid("unclosed binary WAT component")
      }
      let data : Array[Byte] = []
      for position in (index + 1)..<(tokens.length() - 1) {
        data.append(wat_string(tokens, position).to_array())
      }
      return Bytes::from_array(data)
    }
  }
  let normalized = StringBuilder()
  let customs : Array[(Bytes, Bytes)] = []
  let identifiers : Map[String, String] = Map([])
  let mut depth = 0
  let mut position = 0
  while position < tokens.length() {
    let token = tokens[position]
    if token is Open && depth == 1 && position + 1 < tokens.length() {
      let (annotation, first) = match tokens[position + 1] {
        Atom(name) =>
          if name == "@" && position + 2 < tokens.length() {
            ("@" + wat_text(wat_string(tokens, position + 2)), position + 3)
          } else {
            (name, position + 2)
          }
        _ => ("", position + 2)
      }
      if annotation == "@custom" || annotation == "@producers" {
        let end = wat_end(tokens, position)
        if annotation == "@custom" {
          let name = wat_string(tokens, first)
          ignore(wat_text(name))
          let data : Array[Byte] = []
          for i in (first + 1)..<end {
            data.append(wat_string(tokens, i).to_array())
          }
          customs.push((name, Bytes::from_array(data)))
        } else {
          customs.push((b"producers", wat_producers(tokens, first, end)))
        }
        position = end + 1
        continue
      }
    }
    match token {
      Open => {
        depth += 1
        normalized.write_string("( ")
      }
      Close => {
        depth -= 1
        normalized.write_string(") ")
      }
      Atom(atom) => normalized.write_string(atom + " ")
      Identifier(name) => {
        if !identifiers.contains(name) {
          identifiers[name] = "$wit-id-" + identifiers.length().to_string()
        }
        normalized.write_string(identifiers[name] + " ")
      }
      Quoted(bytes) => normalized.write_string(wat_literal(bytes) + " ")
    }
    position += 1
  }
  let bytes = @component_text.parse_component_wat(normalized.to_string()) catch {
    @component_text.Unsupported(message) => raise Unsupported(message)
    @component_text.ParseError(message) => raise Invalid(message)
  }
  let out = bytes.to_array()
  for (name, data) in customs {
    let payload : Array[Byte] = []
    wat_bytes(payload, name)
    payload.append(data.to_array())
    out.push(0)
    wat_unsigned(out, payload.length())
    out.append(payload)
  }
  Bytes::from_array(out)
}
