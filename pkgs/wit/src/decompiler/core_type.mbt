///|
// A cursor over one already-validated core type encoding. Reads past the end
// or encodings outside the print profile raise `PrintFailure`.
priv struct Reader {
  bytes : Bytes
  mut position : Int32
}

///|
fn Reader::byte(self : Reader) -> Int32 raise PrintFailure {
  guard self.position < self.bytes.length() else {
    raise PrintFailure(None, "WIT-D001", "core type ends early")
  }
  let byte = self.bytes[self.position].to_int()
  self.position += 1
  byte
}

///|
fn Reader::u64(self : Reader) -> UInt64 raise PrintFailure {
  let mut value = 0UL
  let mut shift = 0
  while shift < 64 {
    let byte = self.byte()
    value = value | ((byte & 0x7f).to_uint64() << shift)
    if (byte & 0x80) == 0 {
      return value
    }
    shift += 7
  }
  raise PrintFailure(None, "WIT-D001", "core type integer is too long")
}

///|
fn Reader::u32(self : Reader) -> Int32 raise PrintFailure {
  let value = self.u64()
  guard value <= 0xffffffffUL else {
    raise PrintFailure(None, "WIT-D001", "core type index is too large")
  }
  value.to_int()
}

///|
fn Reader::name(
  self : Reader,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  let size = self.u32()
  guard size <= self.bytes.length() - self.position else {
    raise PrintFailure(None, "WIT-D001", "core type name ends early")
  }
  let start = self.position
  self.position += size
  quote(@utf8.decode_lossy(self.bytes[start:start + size]), scope~)
}

///|
fn Reader::value_type(
  self : Reader,
  compatibility~ : Bool = false,
) -> String raise PrintFailure {
  if self.position < self.bytes.length() && self.bytes[self.position] == b'\x70' {
    self.position += 1
    return "funcref"
  }
  if self.position < self.bytes.length() && self.bytes[self.position] == b'\x6f' {
    self.position += 1
    return "externref"
  }
  let (end, value) = match
    @core_types.scan_value(self.bytes, self.position, self.bytes.length()) {
    Ok(result) => result
    Err(error) =>
      raise PrintFailure(Some(error.offset), "WIT-D001", error.message)
  }
  self.position = end
  match value {
    Number(name) => name
    Ref(nullable, shared, heap) => {
      let name = if heap >= 0 {
        heap.to_string()
      } else {
        match heap {
          -16 => "func"
          -17 => "extern"
          -18 => "any"
          -19 => "eq"
          -20 => "i31"
          -21 => "struct"
          -22 => "array"
          -23 => "exn"
          -15 => "none"
          -14 => "noextern"
          -13 => "nofunc"
          -12 => "noexn"
          _ => unsupported("unsupported abstract core heap type")
        }
      }
      if compatibility && nullable && !shared && heap < 0 {
        match heap {
          -15 => "nullref"
          -14 => "nullexternref"
          -13 => "nullfuncref"
          -12 => "nullexnref"
          _ => name + "ref"
        }
      } else {
        "(ref " +
        (if nullable { "null " } else { "" }) +
        (if shared { "(shared " + name + ")" } else { name }) +
        ")"
      }
    }
  }
}

///|
fn Reader::func_type(
  self : Reader,
  compatibility~ : Bool = false,
) -> String raise PrintFailure {
  let out = StringBuilder()
  out.write_string("(func")
  for keyword in ["param", "result"] {
    let count = self.u32()
    if count > 0 {
      out.write_string(" (\{keyword}")
      for _ in 0..<count {
        out.write_string(" " + self.value_type(compatibility~))
      }
      out.write_string(")")
    }
  }
  out.write_string(")")
  out.to_string()
}

///|
// `min [max] [shared] [(pagesize N)]` after an optional `i64` address type.
fn Reader::limits(
  self : Reader,
  memory : Bool,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  let flags = self.byte()
  guard (flags & 0xf0) == 0 && (memory || (flags & 0x08) == 0) else {
    unsupported("core limits flags are outside the print profile")
  }
  let out = StringBuilder()
  if !memory && (flags & 2) != 0 {
    out.write_string(" shared")
  }
  if (flags & 0x04) != 0 {
    out.write_string(" i64")
  }
  out.write_string(" \{self.u64()}")
  if (flags & 0x01) != 0 {
    out.write_string(" \{self.u64()}")
  }
  if memory && (flags & 0x02) != 0 {
    out.write_string(" shared")
  }
  if (flags & 0x08) != 0 {
    let log = self.u32()
    guard log == 0 || log == 16 else {
      unsupported(
        "memory page sizes other than 1 and 65536 are outside the print profile",
      )
    }
    out.write_string(
      if scope.compatibility {
        " (pagesize 0x\{(1 << log).to_string(radix=16)})"
      } else if log == 0 {
        " (pagesize 1)"
      } else {
        " (pagesize 65536)"
      },
    )
  }
  out.to_string()
}

///|
fn Reader::extern_type(
  self : Reader,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  match self.byte() {
    0x00 => {
      let index = self.u32()
      let signature = if scope.compatibility {
        scope.core_signatures.get(index).unwrap_or("")
      } else {
        ""
      }
      "(func (type \{scope.reference(0x110, index)})\{signature})"
    }
    0x01 => {
      let element = self.value_type(compatibility=scope.compatibility)
      "(table\{self.limits(false, scope~)} \{element})"
    }
    0x02 => "(memory\{self.limits(true, scope~)})"
    0x03 => {
      let type_ = self.value_type(compatibility=scope.compatibility)
      match self.byte() {
        0x00 => "(global \{type_})"
        0x01 => "(global (mut \{type_}))"
        0x02 => "(global (shared \{type_}))"
        0x03 => "(global (shared mut \{type_}))"
        _ => unsupported("core global flags are outside the print profile")
      }
    }
    0x04 => {
      guard self.byte() == 0x00 else {
        raise PrintFailure(None, "WIT-D001", "core tag attribute must be zero")
      }
      let index = self.u32()
      let signature = if scope.compatibility {
        scope.core_signatures.get(index).unwrap_or("")
      } else {
        ""
      }
      "(tag (type \{scope.reference(0x110, index)})\{signature})"
    }
    _ => unsupported("core extern kind is outside the print profile")
  }
}

///|
// Split a core type section payload into its entries. Each entry is one
// `core:type` encoding, the form component type declarations also carry.
fn core_type_entries(
  payload : Bytes,
  base : Int32?,
) -> Array[Bytes] raise PrintFailure {
  let reader = { bytes: payload, position: 0, }
  let entries : Array[Bytes] = []
  let count = reader.u32()
  for _ in 0..<count {
    let start = reader.position
    match @core_types.scan_declaration(payload, start, payload.length()) {
      Ok((end, _)) => reader.position = end
      Err(error) =>
        raise PrintFailure(at(base, error.offset), "WIT-D001", error.message)
    }
    entries.push(payload[start:reader.position].to_owned())
  }
  entries
}

///|
fn core_type_text(
  bytes : Bytes,
  depth : Int32,
  index : Int32,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  let reader = { bytes, position: 0, }
  let text = core_type(reader, depth, index, scope~)
  guard reader.position == bytes.length() else {
    raise PrintFailure(None, "WIT-D001", "core type has trailing bytes")
  }
  text
}

///|
// One `(core type ...)` definition. Module types contain only flat
// declarations, so this reads them without nesting.
fn core_type(
  reader : Reader,
  depth : Int32,
  index : Int32,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  let pad = indent(depth)
  let opcode = reader.byte()
  match opcode {
    0x50 => {
      let out = StringBuilder()
      out.write_string(
        "\{pad}(core type \{scope.declaration(0x110, index)}\n\{pad}  (module\n",
      )
      let scope = scope.child()
      let inner = indent(depth + 2)
      let mut types = 0
      let count = reader.u32()
      if scope.compatibility && count == 0 {
        return "\{pad}(core type \{scope.parents.last().unwrap().declaration(0x110, index)}\n\{pad}  (module)\n\{pad})\n"
      }
      for _ in 0..<count {
        match reader.byte() {
          0x00 => {
            let module_ = reader.name(scope~)
            let name = reader.name(scope~)
            out.write_string(
              "\{inner}(import \{module_} \{name} \{reader.extern_type(scope~)})\n",
            )
          }
          0x01 => {
            let (text, count) = reader.heap_group_text(
              reader.byte(),
              depth + 2,
              types,
              false,
              scope,
            )
            out.write_string(text)
            types += count
          }
          0x02 => {
            guard reader.byte() == 0x10 && reader.byte() == 0x01 else {
              unsupported(
                "module type aliases other than outer types are outside the print profile",
              )
            }
            let count = reader.u32()
            let target = reader.u32()
            let outer = if count > 0 && count <= scope.parents.length() {
              scope.parents[scope.parents.length() - count]
            } else {
              scope
            }
            let count_text = if scope.compatibility {
              outer.names.root_name().unwrap_or(count.to_string())
            } else {
              count.to_string()
            }
            out.write_string(
              "\{inner}(alias outer \{count_text} \{outer.reference(0x110, target)} (type (;\{types};)))\n",
            )
            types += 1
          }
          0x03 => {
            let name = reader.name(scope~)
            out.write_string(
              "\{inner}(export \{name} \{reader.extern_type(scope~)})\n",
            )
          }
          _ =>
            unsupported("module type declaration is outside the print profile")
        }
      }
      out.write_string("\{pad}  )\n\{pad})\n")
      out.to_string()
    }
    _ => {
      let (text, count) = reader.heap_group_text(
        opcode, depth, index, true, scope,
      )
      scope.counts[0x110] = index + count
      text
    }
  }
}
