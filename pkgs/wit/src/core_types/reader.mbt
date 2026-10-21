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
