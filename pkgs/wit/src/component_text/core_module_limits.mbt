///|
// Preserve explicit default pages separately from the retained core AST, which
// stores only the effective page logarithm. Imports precede defined memories.
fn normalize_concrete_limits(
  items : Array[SExpr],
) -> (Array[SExpr], Array[Bool], Map[String, Int32]) raise ComponentTextError {
  let out : Array[SExpr] = []
  let imports : Array[Bool] = []
  let definitions : Array[Bool] = []
  let memory_exports : Array[(String, Int32, Bool)] = []
  for item in items {
    guard item is List(field) else {
      out.push(item)
      continue
    }
    let imported = field.get(0) is Some(Atom("import"))
    let desc = if imported && field.length() == 4 && field[3] is List(desc) {
      desc
    } else {
      field
    }
    guard desc.get(0) is Some(Atom("memory" | "table" as kind)) else {
      out.push(item)
      continue
    }
    let normalized = desc.copy()
    let mut start = 1
    if parse_optional_identifier(desc, start) is Some(_) {
      start += 1
    }
    let mut inline_import = false
    while start < desc.length() &&
          desc[start] is List(annotation) &&
          annotation.get(0) is Some(Atom("export" | "import" as head)) {
      if head == "import" {
        inline_import = true
      }
      start += 1
    }
    let wide = desc.get(start) is Some(Atom("i64"))
    if wide || desc.get(start) is Some(Atom("i32")) {
      start += 1
    }
    // Inline table elements and memory data abbreviations have no numeric
    // limits here. The retained parser expands those abbreviations itself.
    for _ in 0..<2 {
      guard desc.get(start) is Some(Atom(atom)) &&
        !atom.is_empty() &&
        (
          (atom.code_unit_at(0) >= 48 && atom.code_unit_at(0) <= 57) ||
          atom.has_prefix("+") ||
          atom.has_prefix("-")
        ) else {
        break
      }
      normalized[start] = Atom(
        parse_core_unsigned(desc[start], wide).to_string(),
      )
      start += 1
    }
    let mut explicit_default = false
    if kind == "memory" {
      for i in start..<desc.length() {
        if desc[i] is List(page) && page.get(0) is Some(Atom("pagesize")) {
          guard page.length() == 2 else {
            raise ParseError("invalid memory page size")
          }
          let size = parse_core_unsigned(page[1], false)
          if size != 1UL && size != 65536UL {
            raise Unsupported("unsupported memory page size")
          }
          explicit_default = size == 65536UL
          normalized[i] = List([Atom("pagesize"), Atom(size.to_string())])
        }
      }
      let is_import = imported || inline_import
      let index = if is_import {
        imports.length()
      } else {
        definitions.length()
      }
      for value in desc {
        if value is List(annotation) &&
          annotation.get(0) is Some(Atom("export")) &&
          annotation.length() == 2 {
          memory_exports.push(
            (
              parse_name_text(annotation[1], "core memory export"),
              index,
              is_import,
            ),
          )
        }
      }
      if imported || inline_import {
        imports.push(explicit_default)
      } else {
        definitions.push(explicit_default)
      }
    }
    out.push(
      if imported {
        List([field[0], field[1], field[2], List(normalized)])
      } else {
        List(normalized)
      },
    )
  }
  let exports : Map[String, Int32] = Map([])
  for (name, index, imported) in memory_exports {
    exports[name] = index + (if imported { 0 } else { imports.length() })
  }
  imports.append(definitions)
  (out, imports, exports)
}

///|
priv struct EncodedCoreReader {
  data : Bytes
  mut pos : Int32
  end : Int32
}

///|
fn EncodedCoreReader::byte(
  self : EncodedCoreReader,
) -> Int32 raise ComponentTextError {
  guard self.pos < self.end else {
    raise ParseError("truncated encoded core module")
  }
  let value = self.data[self.pos].to_int()
  self.pos += 1
  value
}

///|
fn EncodedCoreReader::unsigned(
  self : EncodedCoreReader,
  bits : Int32,
) -> UInt64 raise ComponentTextError {
  let mut value = 0UL
  for i in 0..<((bits + 6) / 7) {
    let byte = self.byte()
    let remaining = bits - 7 * i
    if remaining < 7 && byte >= 1 << remaining {
      raise ParseError("encoded core integer overflow")
    }
    value = value | ((byte & 127).to_uint64() << (7 * i))
    if byte < 128 {
      return value
    }
  }
  raise ParseError("unterminated encoded core integer")
}

///|
fn EncodedCoreReader::name(
  self : EncodedCoreReader,
) -> Unit raise ComponentTextError {
  let size = self.unsigned(32)
  guard size <= (self.end - self.pos).to_uint64() else {
    raise ParseError("truncated encoded core name")
  }
  self.pos += size.to_int()
}

///|
fn EncodedCoreReader::value(
  self : EncodedCoreReader,
) -> Unit raise ComponentTextError {
  let opcode = self.byte()
  if opcode == 0x63 || opcode == 0x64 {
    // Heap types are signed LEB33, but only byte framing is needed here.
    for _ in 0..<5 {
      if self.byte() < 128 {
        return
      }
    }
    raise ParseError("unterminated encoded core heap type")
  }
}

///|
fn EncodedCoreReader::limits(
  self : EncodedCoreReader,
  memory : Bool,
) -> Int32 raise ComponentTextError {
  let flags = self.byte()
  let width = if (flags & 4) != 0 { 64 } else { 32 }
  ignore(self.unsigned(width))
  if (flags & 1) != 0 {
    ignore(self.unsigned(width))
  }
  if memory && (flags & 8) != 0 {
    ignore(self.unsigned(32))
  }
  flags
}

///|
// Restore only the explicit default-page annotation lost by the retained
// encoder. All other bytes, index spaces and instruction bodies remain intact.
fn restore_concrete_memory_pages(
  bytes : Bytes,
  explicit : Array[Bool],
) -> Bytes raise ComponentTextError {
  if !explicit.any(value => value) {
    return bytes
  }
  let reader : EncodedCoreReader = { data: bytes, pos: 8, end: bytes.length(), }
  let out = ByteBuf::ByteBuf()
  out.push_bytes(bytes[:8].to_owned())
  let mut memory_index = 0
  while reader.pos < reader.end {
    let id = reader.byte()
    let size = reader.unsigned(32).to_int()
    let start = reader.pos
    guard size >= 0 && size <= reader.end - start else {
      raise ParseError("truncated encoded core section")
    }
    let end = start + size
    let payload = ByteBuf::ByteBuf()
    if id == 2 || id == 5 {
      let section : EncodedCoreReader = { data: bytes, pos: start, end, }
      let count = section.unsigned(32).to_int()
      let mut copied = start
      for _ in 0..<count {
        let kind = if id == 2 {
          section.name()
          section.name()
          section.byte()
        } else {
          2
        }
        match kind {
          0 => ignore(section.unsigned(32))
          1 => {
            section.value()
            ignore(section.limits(false))
          }
          2 => {
            let flags_at = section.pos
            let flags = section.limits(true)
            guard explicit.get(memory_index) is Some(default_page) else {
              raise ParseError("encoded memory index mismatch")
            }
            memory_index += 1
            if default_page && (flags & 8) == 0 {
              payload.push_bytes(bytes[copied:flags_at].to_owned())
              payload.push_u8(flags | 8)
              payload.push_bytes(bytes[flags_at + 1:section.pos].to_owned())
              payload.push_u8(16)
              copied = section.pos
            }
          }
          3 => {
            section.value()
            ignore(section.byte())
          }
          4 => {
            ignore(section.byte())
            ignore(section.unsigned(32))
          }
          _ => raise ParseError("invalid encoded core import")
        }
      }
      payload.push_bytes(bytes[copied:end].to_owned())
    } else {
      payload.push_bytes(bytes[start:end].to_owned())
    }
    let data = payload.to_bytes()
    out.push_u8(id)
    out.push_uleb_u32(data.length())
    out.push_bytes(data)
    reader.pos = end
  }
  out.to_bytes()
}
