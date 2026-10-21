// ============================================================
// Value Type Parsing
// ============================================================

///|
fn Parser::resolve_heap_type_as_ref_value_type(
  self : Parser,
  heap_type : Int32,
  nullable : Bool,
) -> @types.ValueType raise ParserError {
  if heap_type >= 0 {
    guard self.types.get(heap_type) is Some(type_) else {
      raise ParseError("invalid heap type")
    }
    @types.typed_reference(type_.composite, nullable, heap_type)
  } else {
    match @types.ValueType::from_abstract_heap_type(heap_type, nullable) {
      Some(value) => value
      None => raise ParseError("invalid heap type")
    }
  }
}

///|
fn Parser::read_value_type(self : Parser) -> @types.ValueType raise ParserError {
  let start = self.pos
  let byte = self.read_byte()
  let result : @types.ValueType = match byte {
    0x7f => I32
    0x7e => I64
    0x7d => F32
    0x7c => F64
    0x7b => V128
    0x63 | 0x64 => self.read_heap_reference(byte == 0x63)
    0x65 => {
      self.pos -= 1
      self.read_heap_reference(true)
    }
    _ =>
      match @types.ValueType::from_abstract_heap_type(byte - 128, true) {
        Some(value) => value
        None => raise InvalidValueType(byte)
      }
  }
  if self.capture_text {
    self.text_values.push((start, self.value_text(start)))
  }
  result
}

///|
fn Parser::read_heap_reference(
  self : Parser,
  nullable : Bool,
) -> @types.ValueType raise ParserError {
  if self.peek_byte() == 0x65 {
    self.skip(1)
    let heap = self.read_byte() - 128
    guard @types.ValueType::from_abstract_heap_type(heap, nullable) is Some(_) else {
      raise ParseError("invalid shared heap type")
    }
    return HeapRef(nullable, true, heap)
  }
  let first = self.peek_byte()
  let heap = self.read_i32()
  if heap < 0 && first >= 128 {
    raise ParseError("invalid abstract heap type encoding")
  }
  self.resolve_heap_type_as_ref_value_type(heap, nullable)
}

///|
/// Read a heap type (signed LEB128 type index or abstract heap type)
fn Parser::read_heap_type(self : Parser) -> Int32 raise ParserError {
  // Heap types are encoded as signed LEB128
  // Negative values represent abstract heap types:
  //   -0x10 (0x70) = func
  //   -0x11 (0x6F) = extern
  // Positive values represent type indices
  if self.peek_byte() == 0x65 {
    self.skip(1)
  }
  self.read_i32()
}

///|
/// Read block type (uses peek to avoid rewind)
fn Parser::read_block_type(self : Parser) -> @types.BlockType raise ParserError {
  let byte = self.peek_byte()
  match byte {
    0x40 => {
      self.skip(1)
      Empty
    }
    0x7F
    | 0x7E
    | 0x7D
    | 0x7C
    | 0x7B
    | 0x70
    | 0x6F
    | 0x6E
    | 0x6D
    | 0x6C
    | 0x6B
    | 0x6A
    | 0x69
    | 0x71
    | 0x72
    | 0x73
    | 0x74
    | 0x64
    | 0x65
    | 0x63
    | 0x62 => Value(self.read_value_type())
    _ => TypeIndex(self.read_i32())
  }
}

///|
// Retain text spelling independently of the third-party ValueType enum, which
// has no distinct variants for a few non-null abstract bottom/reference types.
fn Parser::value_text(self : Parser, start : Int32) -> String raise ParserError {
  let byte = self.data[start].to_int()
  if byte == 0x63 || byte == 0x64 || byte == 0x65 {
    let reader = Parser(self.data)
    reader.pos = start + (if byte == 0x65 { 0 } else { 1 })
    let shared = reader.peek_byte() == 0x65
    if shared {
      reader.skip(1)
    }
    let heap = reader.read_heap_type()
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
      index if index >= 0 => index.to_string()
      _ => raise ParseError("unknown abstract heap type")
    }
    if shared {
      return "(ref \{if byte == 0x64 { "" } else { "null " }}(shared \{name}))"
    }
    if byte == 0x64 {
      return "(ref \{name})"
    }
    return match heap {
      -16 => "funcref"
      -17 => "externref"
      -18 => "anyref"
      -19 => "eqref"
      -20 => "i31ref"
      -21 => "structref"
      -22 => "arrayref"
      -23 => "exnref"
      -24 => "contref"
      -15 => "nullref"
      -14 => "nullexternref"
      -13 => "nullfuncref"
      -12 => "nullexnref"
      -11 => "nullcontref"
      _ => "(ref null \{name})"
    }
  }
  match byte {
    0x7f => "i32"
    0x7e => "i64"
    0x7d => "f32"
    0x7c => "f64"
    0x7b => "v128"
    0x70 => "funcref"
    0x6f => "externref"
    0x6e => "anyref"
    0x6d => "eqref"
    0x6c => "i31ref"
    0x6b => "structref"
    0x6a => "arrayref"
    0x69 => "exnref"
    0x68 => "contref"
    0x71 => "nullref"
    0x72 => "nullexternref"
    0x73 => "nullfuncref"
    0x74 => "nullexnref"
    0x75 => "nullcontref"
    _ => raise ParseError("unsupported value type spelling")
  }
}
