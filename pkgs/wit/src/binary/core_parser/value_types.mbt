// ============================================================
// Value Type Parsing
// ============================================================

///|
fn Parser::resolve_heap_type_as_ref_value_type(
  self : Parser,
  heap_type : Int32,
  nullable : Bool,
) -> @types.ValueType raise ParserError {
  fn resolve_typed_ref(
    type_idx : Int32,
    nullable : Bool,
  ) -> @types.ValueType raise ParserError {
    if type_idx < 0 || type_idx >= self.types.length() {
      raise ParseError("invalid heap type")
    }
    match self.types[type_idx].composite {
      Cont(_) =>
        if nullable {
          RefNullContTyped(type_idx)
        } else {
          RefContTyped(type_idx)
        }
      Func(_) =>
        if nullable {
          RefNullFuncTyped(type_idx)
        } else {
          RefFuncTyped(type_idx)
        }
      Struct(_) =>
        if nullable {
          RefNullStruct(type_idx)
        } else {
          RefStruct(type_idx)
        }
      Array(_) =>
        if nullable {
          RefNullArray(type_idx)
        } else {
          RefArray(type_idx)
        }
    }
  }

  if heap_type < 0 {
    match @types.ValueType::from_abstract_heap_type(heap_type, nullable) {
      Some(value) => value
      None => raise ParseError("invalid heap type")
    }
  } else {
    resolve_typed_ref(heap_type, nullable)
  }
}

///|
fn Parser::read_value_type(self : Parser) -> @types.ValueType raise ParserError {
  fn resolve_typed_ref(
    type_idx : Int32,
    nullable : Bool,
  ) -> @types.ValueType raise ParserError {
    self.resolve_heap_type_as_ref_value_type(type_idx, nullable)
  }

  fn resolve_abstract_heap(
    heap_type : Int32,
    nullable : Bool,
  ) -> @types.ValueType raise ParserError {
    self.resolve_heap_type_as_ref_value_type(heap_type, nullable)
  }

  let start = self.pos
  let byte = self.read_byte()
  let result : @types.ValueType = match byte {
    0x7F => I32
    0x7E => I64
    0x7D => F32
    0x7C => F64
    0x7B => V128

    // Reference shorthands
    0x70 => FuncRef
    0x6F => ExternRef
    0x6E => AnyRef
    0x6D => RefNullEq
    0x6C => RefNullI31
    0x6B => StructRef
    0x6A => ArrayRef
    0x69 => ExnRef
    0x68 => ContRef
    0x75 => NullContRef
    0x71 => NullRef
    0x72 => NullExternRef
    0x73 => NullFuncRef
    0x74 => NullExnRef

    // ref heaptype
    0x64 => {
      let heap_type = self.read_heap_type()
      if heap_type < 0 {
        resolve_abstract_heap(heap_type, false)
      } else {
        resolve_typed_ref(heap_type, false)
      }
    }

    // ref shared heaptype (shared reference types proposal)
    0x65 => {
      self.read_heap_type() |> ignore
      raise ParseError("shared reference types not supported")
    }

    // ref null shared heaptype (shared reference types proposal)
    0x62 => {
      self.read_heap_type() |> ignore
      raise ParseError("shared reference types not supported")
    }

    // ref null heaptype
    0x63 => {
      let heap_type = self.read_heap_type()
      if heap_type < 0 {
        resolve_abstract_heap(heap_type, true)
      } else {
        resolve_typed_ref(heap_type, true)
      }
    }
    _ => raise InvalidValueType(byte)
  }
  if self.capture_text {
    self.text_values.push((start, self.value_text(start)))
  }
  result
}

///|
/// Read a heap type (signed LEB128 type index or abstract heap type)
fn Parser::read_heap_type(self : Parser) -> Int32 raise ParserError {
  // Heap types are encoded as signed LEB128
  // Negative values represent abstract heap types:
  //   -0x10 (0x70) = func
  //   -0x11 (0x6F) = extern
  // Positive values represent type indices
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
  if byte == 0x63 || byte == 0x64 {
    let reader = Parser(self.data)
    reader.pos = start + 1
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
