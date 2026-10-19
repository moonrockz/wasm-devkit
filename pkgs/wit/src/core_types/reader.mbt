///|
priv suberror Failure {
  Failure(Diagnostic)
}

///|
priv struct Reader {
  bytes : Bytes
  mut position : Int32
  end : Int32
}

///|
fn Reader::fail(
  self : Reader,
  kind : ErrorKind,
  message : String,
) -> Unit raise Failure {
  raise Failure({ offset: self.position, kind, message, })
}

///|
fn Reader::byte(self : Reader) -> Int32 raise Failure {
  if self.position >= self.end {
    self.fail(Malformed, "truncated core type")
  }
  let byte = self.bytes[self.position].to_int()
  self.position += 1
  byte
}

///|
fn Reader::unsigned(self : Reader, bits : Int32) -> UInt64 raise Failure {
  let mut result = 0UL
  let count = (bits + 6) / 7
  for i in 0..<count {
    let byte = self.byte()
    let remaining = bits - i * 7
    if remaining < 7 && byte >= 1 << remaining {
      self.fail(Malformed, "core unsigned LEB exceeds its width")
    }
    result = result | ((byte & 127).to_uint64() << (i * 7))
    if byte < 128 {
      return result
    }
  }
  self.fail(Malformed, "unterminated core unsigned LEB")
  0UL
}

///|
fn Reader::count(self : Reader) -> Int32 raise Failure {
  let n = self.unsigned(32)
  if n > (self.end - self.position).to_uint64() {
    self.fail(Malformed, "core vector exceeds its enclosing bytes")
  }
  n.to_int()
}

///|
fn Reader::index(self : Reader) -> Int32 raise Failure {
  let n = self.unsigned(32)
  if n > 2147483647UL {
    self.fail(Invalid, "core type index is out of bounds")
  }
  n.to_int()
}

///|
fn Reader::name(self : Reader) -> String raise Failure {
  let n = self.count()
  let start = self.position
  self.position += n
  @utf8.decode(self.bytes[start:self.position].to_owned(), ignore_bom=false) catch {
    _ => {
      self.fail(Malformed, "invalid UTF-8 core name")
      ""
    }
  }
}

///|
fn Reader::value(self : Reader) -> Value raise Failure {
  let byte = self.byte()
  match byte {
    0x7f => return Scalar("i32")
    0x7e => return Scalar("i64")
    0x7d => return Scalar("f32")
    0x7c => return Scalar("f64")
    0x7b => return Scalar("v128")
    _ => ()
  }
  let nullable = byte != 0x64
  let heap = if byte == 0x63 || byte == 0x64 {
    let mut value = 0L
    let mut finished = false
    for i in 0..<5 {
      let b = self.byte()
      if i == 4 && (b & 0x70) != 0 && (b & 0x70) != 0x70 {
        self.fail(Malformed, "core heap LEB exceeds s33")
      }
      value = value | ((b & 127).to_int64() << (i * 7))
      if b < 128 {
        if (b & 64) != 0 {
          value = value | (-1L << ((i + 1) * 7))
        }
        finished = true
        break
      }
    }
    if !finished {
      self.fail(Malformed, "unterminated core heap type")
    }
    if value >= 0L {
      self.fail(
        Unsupported,
        "concrete core reference types are outside this codec",
      )
    }
    value.to_int()
  } else {
    byte - 128
  }
  let name = match heap {
    -16 => "func"
    -17 => "extern"
    -18 => "any"
    -19 => "eq"
    -20 => "i31"
    -21 => "struct"
    -22 => "array"
    -23 => "exn"
    -24 => "cont"
    -15 => "none"
    -14 => "noextern"
    -13 => "nofunc"
    -12 => "noexn"
    -11 => "nocont"
    -27 => {
      self.fail(
        Unsupported,
        "shared core reference types are not supported by pinned WAC",
      )
      ""
    }
    _ => {
      self.fail(Malformed, "invalid core value type")
      ""
    }
  }
  Reference(nullable, name)
}

///|
fn Reader::function_body(self : Reader) -> Function raise Failure {
  let params : Array[Value] = []
  let count = self.count()
  for _ in 0..<count {
    params.push(self.value())
  }
  let results : Array[Value] = []
  let count = self.count()
  for _ in 0..<count {
    results.push(self.value())
  }
  {
    params: ReadOnlyArray::from_array(params),
    results: ReadOnlyArray::from_array(results),
  }
}
