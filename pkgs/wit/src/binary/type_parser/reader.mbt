// Retained from Milky2018/wasm_component@0.16.0.
// Modified by wasm-devkit: parse nested type scopes with an explicit work stack.

///|
priv struct Reader {
  data : Bytes
  mut pos : Int32
}

///|
fn Reader::Reader(data : Bytes) -> Reader {
  { data, pos: 0, }
}

///|
fn Reader::is_eof(self : Reader) -> Bool {
  self.pos >= self.data.length()
}

///|
fn Reader::read_u8(self : Reader) -> Int32 raise ComponentParseError {
  if self.pos >= self.data.length() {
    raise UnexpectedEndOfInput
  }
  let b = self.data[self.pos].to_int()
  self.pos += 1
  b
}

///|
fn Reader::read_bytes(
  self : Reader,
  n : Int32,
) -> Bytes raise ComponentParseError {
  if n < 0 || n > self.data.length() - self.pos {
    raise UnexpectedEndOfInput
  }
  let bytes : Array[Byte] = []
  for i in 0..<n {
    bytes.push(self.data[self.pos + i])
  }
  self.pos += n
  Bytes::from_array(bytes)
}

///|
fn decode_utf8_validated(bytes : Bytes) -> String raise ComponentParseError {
  let buf = StringBuilder::StringBuilder()
  let mut i = 0
  while i < bytes.length() {
    let b = bytes[i].to_int()
    if b < 0x80 {
      buf.write_char(b.unsafe_to_char())
      i = i + 1
    } else if b < 0xC0 {
      raise InvalidUtf8
    } else if b < 0xE0 {
      if i + 1 >= bytes.length() {
        raise InvalidUtf8
      }
      let b2 = bytes[i + 1].to_int()
      if (b2 & 0xC0) != 0x80 {
        raise InvalidUtf8
      }
      let cp = ((b & 0x1F) << 6) | (b2 & 0x3F)
      if cp < 0x80 {
        raise InvalidUtf8
      }
      buf.write_char(cp.unsafe_to_char())
      i = i + 2
    } else if b < 0xF0 {
      if i + 2 >= bytes.length() {
        raise InvalidUtf8
      }
      let b2 = bytes[i + 1].to_int()
      let b3 = bytes[i + 2].to_int()
      if (b2 & 0xC0) != 0x80 || (b3 & 0xC0) != 0x80 {
        raise InvalidUtf8
      }
      let cp = ((b & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F)
      if cp < 0x800 || (cp >= 0xD800 && cp <= 0xDFFF) {
        raise InvalidUtf8
      }
      buf.write_char(cp.unsafe_to_char())
      i = i + 3
    } else if b < 0xF8 {
      if i + 3 >= bytes.length() {
        raise InvalidUtf8
      }
      let b2 = bytes[i + 1].to_int()
      let b3 = bytes[i + 2].to_int()
      let b4 = bytes[i + 3].to_int()
      if (b2 & 0xC0) != 0x80 || (b3 & 0xC0) != 0x80 || (b4 & 0xC0) != 0x80 {
        raise InvalidUtf8
      }
      let cp = ((b & 0x07) << 18) |
        ((b2 & 0x3F) << 12) |
        ((b3 & 0x3F) << 6) |
        (b4 & 0x3F)
      if cp < 0x10000 || cp > 0x10FFFF {
        raise InvalidUtf8
      }
      buf.write_char(cp.unsafe_to_char())
      i = i + 4
    } else {
      raise InvalidUtf8
    }
  }
  buf.to_string()
}

///|
fn Reader::read_leb_u32(self : Reader) -> Int32 raise ComponentParseError {
  for result = 0, shift = 0 {
    if shift > 28 {
      raise Leb128TooLarge
    }
    let byte = self.read_u8()
    if shift == 28 && (byte & 0x7F) > 0x0F {
      raise Leb128TooLarge
    }
    let new_result = result | ((byte & 0x7F) << shift)
    if (byte & 0x80) == 0 {
      break new_result
    } else {
      continue new_result, shift + 7
    }
  }
}

///|
fn Reader::read_sleb_i32(self : Reader) -> Int32 raise ComponentParseError {
  for result = 0, shift = 0 {
    if shift >= 35 {
      raise Leb128TooLarge
    }
    let b = self.read_u8()
    let low = b & 0x7F
    let new_result = result | (low << shift)
    if (b & 0x80) == 0 {
      if shift < 32 && (b & 0x40) != 0 {
        break new_result | (-1 << (shift + 7))
      } else {
        break new_result
      }
    } else {
      continue new_result, shift + 7
    }
  }
}

///|
fn Reader::read_typeidx(self : Reader) -> Int32 raise ComponentParseError {
  self.read_leb_u32()
}

///|
// Every type or declaration consumes at least one byte. Check before scheduling
// work so malformed u32 counts cannot wrap or allocate an unbounded work stack.
fn Reader::read_count(self : Reader) -> Int32 raise ComponentParseError {
  let n = self.read_leb_u32()
  if n < 0 || n > self.data.length() - self.pos {
    raise UnexpectedEndOfInput
  }
  n
}
