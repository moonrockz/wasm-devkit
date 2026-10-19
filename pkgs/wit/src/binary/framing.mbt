///|
priv suberror Boundary {
  Failure(Int32?, String, String)
}

///|
priv struct Reader {
  bytes : Bytes
  mut position : Int32
  end : Int32
}

///|
fn Reader::byte(self : Reader) -> Int32 raise Boundary {
  if self.position >= self.end {
    raise Failure(
      Some(self.position),
      "WIT-B001",
      "truncated component encoding",
    )
  }
  let value = self.bytes[self.position].to_int()
  self.position += 1
  value
}

///|
fn Reader::unsigned(self : Reader) -> UInt32 raise Boundary {
  let start = self.position
  let mut value = 0U
  for i in 0..<5 {
    let byte = self.byte()
    if i == 4 && byte > 15 {
      raise Failure(Some(start), "WIT-B001", "unsigned LEB128 exceeds u32")
    }
    value = value | ((byte & 127).reinterpret_as_uint() << (i * 7))
    if byte < 128 {
      return value
    }
  }
  raise Failure(Some(start), "WIT-B001", "unterminated LEB128")
}

///|
fn Reader::count(self : Reader) -> Int32 raise Boundary {
  let count = self.unsigned()
  if count > (self.end - self.position).reinterpret_as_uint() {
    raise Failure(
      Some(self.position),
      "WIT-B001",
      "vector or string exceeds its enclosing section",
    )
  }
  count.reinterpret_as_int()
}

///|
fn Reader::string(self : Reader) -> Unit raise Boundary {
  let count = self.count()
  let start = self.position
  self.position += count
  ignore(
    @utf8.decode(self.bytes[start:self.position].to_owned(), ignore_bom=false),
  ) catch {
    _ => raise Failure(Some(start), "WIT-B001", "invalid UTF-8 component name")
  }
}

///|
fn Reader::value_type(self : Reader) -> Unit raise Boundary {
  let start = self.position
  for i in 0..<5 {
    let byte = self.byte()
    if i == 4 && (byte & 0x78) != 0 && (byte & 0x78) != 0x78 {
      raise Failure(Some(start), "WIT-B001", "signed LEB128 exceeds i32")
    }
    if byte < 128 {
      return
    }
  }
  raise Failure(Some(start), "WIT-B001", "unterminated value type")
}

///|
fn Reader::optional_value(self : Reader) -> Unit raise Boundary {
  match self.byte() {
    0 => ()
    1 => self.value_type()
    _ =>
      raise Failure(
        Some(self.position - 1),
        "WIT-B001",
        "invalid optional value type",
      )
  }
}

///|
fn Reader::optional_index(self : Reader) -> Unit raise Boundary {
  match self.byte() {
    0 => ()
    1 => ignore(self.unsigned())
    _ =>
      raise Failure(
        Some(self.position - 1),
        "WIT-B001",
        "invalid optional index",
      )
  }
}

///|
fn Reader::external_name(self : Reader) -> Unit raise Boundary {
  let tag = self.byte()
  if tag > 2 {
    raise Failure(
      Some(self.position - 1),
      "WIT-B001",
      "invalid external name tag",
    )
  }
  self.string()
  if tag == 2 {
    let count = self.count()
    for _ in 0..<count {
      if self.byte() > 2 {
        raise Failure(
          Some(self.position - 1),
          "WIT-B001",
          "invalid name attribute",
        )
      }
      self.string()
    }
  }
}

///|
fn Reader::sort(self : Reader) -> Unit raise Boundary {
  match self.byte() {
    0 => ignore(self.byte())
    1 | 2 | 3 | 4 | 5 => ()
    _ =>
      raise Failure(
        Some(self.position - 1),
        "WIT-B001",
        "invalid component sort",
      )
  }
}

///|
fn Reader::description(
  self : Reader,
  core~ : Bool = false,
) -> Unit raise Boundary {
  match self.byte() {
    0 if core => {
      if self.byte() != 0x11 {
        raise Failure(
          Some(self.position - 1),
          "WIT-B001",
          "invalid core external description",
        )
      }
      ignore(self.unsigned())
    }
    0 =>
      raise Failure(
        Some(self.position - 1),
        "WIT-B002",
        "core module types are outside the WIT type-component boundary",
      )
    1 | 4 | 5 => ignore(self.unsigned())
    2 =>
      raise Failure(
        Some(self.position - 1),
        "WIT-B002",
        "component values are outside the supported binary profile",
      )
    3 =>
      match self.byte() {
        0 => ignore(self.unsigned())
        1 => ()
        _ =>
          raise Failure(
            Some(self.position - 1),
            "WIT-B001",
            "invalid component type bound",
          )
      }
    _ =>
      raise Failure(
        Some(self.position - 1),
        "WIT-B001",
        "invalid external description",
      )
  }
}

///|
priv enum Frame {
  Type(Int32)
  Declaration(Int32, Bool)
}

///|
/// Bound physical scope nesting before invoking the maintained recursive parser.
/// Type references remain flat indices; vector work is bounded by input bytes.
fn type_framing(reader : Reader, core~ : Bool = false) -> Unit raise Boundary {
  let work : Array[Frame] = []
  let count = reader.count()
  for _ in 0..<count {
    work.push(Type(0))
  }
  while work.pop() is Some(frame) {
    match frame {
      Type(depth) => {
        let offset = reader.position
        match reader.byte() {
          0x40 | 0x43 => {
            let count = reader.count()
            for _ in 0..<count {
              reader.string()
              reader.value_type()
            }
            match reader.byte() {
              0 => reader.value_type()
              1 =>
                if reader.byte() != 0 {
                  raise Failure(
                    Some(offset),
                    "WIT-B001",
                    "invalid function result vector",
                  )
                }
              _ =>
                raise Failure(
                  Some(offset),
                  "WIT-B001",
                  "invalid function result tag",
                )
            }
          }
          0x41 | 0x42 as opcode => {
            if depth >= 256 {
              raise Failure(
                Some(offset),
                "WIT-B002",
                "type scope nesting exceeds the supported encoding boundary of 256",
              )
            }
            let count = reader.count()
            for _ in 0..<count {
              work.push(Declaration(depth + 1, opcode == 0x41))
            }
          }
          0x63 => {
            reader.value_type()
            reader.value_type()
          }
          0x65 | 0x66 => reader.optional_value()
          0x67 => {
            reader.value_type()
            let count = reader.unsigned()
            if count == 0U || count > 1073741824U {
              raise Failure(
                Some(offset),
                "WIT-B003",
                "fixed-length list element count must be between 1 and 1073741824",
              )
            }
          }
          0x68 | 0x69 => ignore(reader.unsigned())
          0x6a => {
            reader.optional_value()
            reader.optional_value()
          }
          0x6b | 0x70 => reader.value_type()
          0x6d | 0x6e => {
            let count = reader.count()
            if count > 10000 {
              raise Failure(
                Some(offset),
                "WIT-B003",
                "component aggregate exceeds 10000 fields or cases",
              )
            }
            for _ in 0..<count {
              reader.string()
            }
          }
          0x6f => {
            let count = reader.count()
            if count > 10000 {
              raise Failure(
                Some(offset),
                "WIT-B003",
                "component aggregate exceeds 10000 fields or cases",
              )
            }
            for _ in 0..<count {
              reader.value_type()
            }
          }
          0x71 => {
            let count = reader.count()
            if count > 10000 {
              raise Failure(
                Some(offset),
                "WIT-B003",
                "component aggregate exceeds 10000 fields or cases",
              )
            }
            for _ in 0..<count {
              reader.string()
              reader.optional_value()
              reader.optional_index()
            }
          }
          0x72 => {
            let count = reader.count()
            if count > 10000 {
              raise Failure(
                Some(offset),
                "WIT-B003",
                "component aggregate exceeds 10000 fields or cases",
              )
            }
            for _ in 0..<count {
              reader.string()
              reader.value_type()
            }
          }
          0x3f => {
            ignore(reader.byte())
            reader.optional_index()
          }
          0x64 | 0x73..<=0x7f => ()
          _ =>
            raise Failure(
              Some(offset),
              "WIT-B001",
              "unknown component type opcode",
            )
        }
      }
      Declaration(depth, component) => {
        let offset = reader.position
        match reader.byte() {
          0 if core => reader.core_type(legacy_nested=true)
          0 =>
            raise Failure(
              Some(offset),
              "WIT-B002",
              "core type declarations are outside the WIT type-component boundary",
            )
          1 => work.push(Type(depth))
          2 => {
            reader.sort()
            match reader.byte() {
              0 => {
                ignore(reader.unsigned())
                reader.string()
              }
              2 => {
                ignore(reader.unsigned())
                ignore(reader.unsigned())
              }
              _ =>
                raise Failure(
                  Some(offset),
                  "WIT-B001",
                  "invalid type alias target",
                )
            }
          }
          3 if component => {
            reader.external_name()
            reader.description(core~)
          }
          4 => {
            reader.external_name()
            reader.description(core~)
          }
          _ =>
            raise Failure(
              Some(offset),
              "WIT-B001",
              "invalid type scope declaration",
            )
        }
      }
    }
  }
}

///|
fn preflight(
  bytes : Bytes,
  declarations~ : Bool = false,
) -> Unit raise Boundary {
  if bytes.length() < 8 || bytes[0:4] != b"\x00asm".exact_view() {
    raise Failure(Some(0), "WIT-B001", "invalid component header")
  }
  if bytes[4:8] != b"\x0d\x00\x01\x00".exact_view() {
    raise Failure(Some(4), "WIT-B002", "expected a component-model binary")
  }
  let reader : Reader = { bytes, position: 8, end: bytes.length(), }
  let mut core_work = 0
  while reader.position < reader.end {
    let section = reader.byte()
    let length = reader.count()
    let end = reader.position + length
    let payload : Reader = { bytes, position: reader.position, end, }
    match section {
      0 => {
        payload.string()
        payload.position = end
      }
      1 if declarations =>
        match
          @core_types.inspect_module(bytes[payload.position:end].to_owned()) {
          Ok(metadata) => {
            core_work += metadata.validation_work
            if core_work > 1000000 {
              raise Failure(
                Some(payload.position),
                "WIT-B002",
                "component core validation work estimate exceeds 1000000",
              )
            }
            payload.position = end
          }
          Err(error) =>
            raise Failure(
              Some(payload.position + error.offset),
              match error.kind {
                Malformed => "WIT-B001"
                Invalid => "WIT-B003"
                Unsupported => "WIT-B002"
              },
              error.message,
            )
        }
      3 if declarations => {
        let count = payload.count()
        for _ in 0..<count {
          payload.core_type()
        }
      }
      6 if declarations => {
        let count = payload.count()
        for _ in 0..<count {
          let offset = payload.position
          let sort = payload.byte()
          if sort == 0 {
            let core_sort = payload.byte()
            if core_sort != 0x10 && core_sort != 0x11 {
              raise Failure(
                Some(offset),
                "WIT-B002",
                "core runtime aliases are outside this profile",
              )
            }
          } else if sort < 1 || sort > 5 {
            raise Failure(
              Some(offset),
              "WIT-B002",
              "core aliases are outside the declarative component boundary",
            )
          }
          match payload.byte() {
            0 => {
              ignore(payload.unsigned())
              payload.string()
            }
            2 => {
              ignore(payload.unsigned())
              ignore(payload.unsigned())
            }
            _ =>
              raise Failure(
                Some(offset),
                "WIT-B001",
                "invalid component alias target",
              )
          }
        }
      }
      7 => type_framing(payload, core=declarations)
      10 if declarations => {
        let count = payload.count()
        for _ in 0..<count {
          payload.external_name()
          payload.description(core=declarations)
        }
      }
      11 => {
        let count = payload.count()
        for _ in 0..<count {
          payload.external_name()
          payload.sort()
          ignore(payload.unsigned())
          match payload.byte() {
            0 => ()
            1 if declarations &&
              payload.position < payload.end &&
              (
                payload.bytes[payload.position] == b'\x00' ||
                payload.bytes[payload.position] == b'\x01' ||
                payload.bytes[payload.position] == b'\x03' ||
                payload.bytes[payload.position] == b'\x04' ||
                payload.bytes[payload.position] == b'\x05'
              ) => payload.description(core=declarations)
            1 =>
              raise Failure(
                Some(payload.position - 1),
                "WIT-B002",
                "root export ascriptions are outside the supported binary profile",
              )
            _ =>
              raise Failure(
                Some(payload.position - 1),
                "WIT-B001",
                "invalid export ascription tag",
              )
          }
        }
      }
      1..<=10 =>
        raise Failure(
          Some(reader.position),
          "WIT-B002",
          "section is outside the WIT type-component encoding boundary",
        )
      _ =>
        raise Failure(
          Some(reader.position - 1),
          "WIT-B001",
          "invalid component section identifier",
        )
    }
    if payload.position != end {
      raise Failure(
        Some(payload.position),
        "WIT-B001",
        "trailing bytes in component section",
      )
    }
    reader.position = end
  }
}

///|
fn Reader::core_type(
  self : Reader,
  legacy_nested~ : Bool = false,
) -> Unit raise Boundary {
  match
    @core_types.scan_type(self.bytes, self.position, self.end, legacy_nested~) {
    Ok(end) => self.position = end
    Err(error) =>
      raise Failure(
        Some(error.offset),
        match error.kind {
          Malformed => "WIT-B001"
          Invalid => "WIT-B003"
          Unsupported => "WIT-B002"
        },
        error.message,
      )
  }
}
