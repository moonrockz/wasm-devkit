// Retained from Milky2018/wasm_component@0.16.0.
// Modified by wasm-devkit: parse nested type scopes with an explicit work stack.

///|
fn Reader::read_label(self : Reader) -> String raise ComponentParseError {
  let len = self.read_leb_u32()
  let bytes = self.read_bytes(len)
  decode_utf8_validated(bytes)
}

///|
fn parse_prim_valtype(op : Int32) -> PrimValType? {
  match op {
    0x7f => Some(Bool)
    0x7e => Some(S8)
    0x7d => Some(U8)
    0x7c => Some(S16)
    0x7b => Some(U16)
    0x7a => Some(S32)
    0x79 => Some(U32)
    0x78 => Some(S64)
    0x77 => Some(U64)
    0x76 => Some(F32)
    0x75 => Some(F64)
    0x74 => Some(Char)
    0x73 => Some(String)
    0x64 => Some(ErrorContext)
    _ => None
  }
}

///|
fn parse_valtype(reader : Reader) -> ValType raise ComponentParseError {
  let v = reader.read_sleb_i32()
  if v >= 0 {
    TypeIdx(v)
  } else {
    match parse_prim_valtype_from_sleb(v) {
      Some(p) => Prim(p)
      None => raise InvalidTypeSection
    }
  }
}

///|
fn parse_paramlist(reader : Reader) -> Array[Param] raise ComponentParseError {
  let n = reader.read_leb_u32()
  let params : Array[Param] = []
  for _ in 0..<n {
    let label = reader.read_label()
    let ty = parse_valtype(reader)
    params.push(({ label, ty, } : Param))
  }
  params
}

///|
fn parse_resultlist(reader : Reader) -> ValType? raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    Some(parse_valtype(reader))
  } else if tag == 0x01 {
    let must_be_zero = reader.read_u8()
    if must_be_zero != 0x00 {
      raise InvalidTypeSection
    }
    None
  } else {
    raise InvalidTypeSection
  }
}

///|
fn parse_functype(
  reader : Reader,
  op : Int32,
) -> FuncType raise ComponentParseError {
  let is_async = op == 0x43
  let params = parse_paramlist(reader)
  let result = parse_resultlist(reader)
  { is_async, params, result, }
}

///|
fn parse_nameattributes_string(
  reader : Reader,
) -> (String, Array[NameAttribute]) raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    let len = reader.read_leb_u32()
    let bytes = reader.read_bytes(len)
    (decode_utf8_validated(bytes), [])
  } else if tag == 0x01 {
    let len = reader.read_leb_u32()
    let bytes = reader.read_bytes(len)
    (decode_utf8_validated(bytes), [])
  } else if tag == 0x02 {
    let len = reader.read_leb_u32()
    let bytes = reader.read_bytes(len)
    (decode_utf8_validated(bytes), parse_attributes(reader))
  } else {
    raise InvalidTypeSection
  }
}

///|
fn parse_typebound_for_instancedecl(
  reader : Reader,
) -> TypeBound raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    Eq(reader.read_typeidx())
  } else if tag == 0x01 {
    SubResource
  } else {
    raise InvalidTypeSection
  }
}

///|
fn parse_valuebound_for_instancedecl(
  reader : Reader,
) -> ValueBound raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    Eq(reader.read_leb_u32())
  } else if tag == 0x01 {
    Type(parse_valtype(reader))
  } else {
    raise InvalidTypeSection
  }
}

///|
fn parse_externdesc_for_instancedecl(
  reader : Reader,
) -> ExternDesc raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    let must_be_core_module = reader.read_u8()
    if must_be_core_module != 0x11 {
      raise InvalidTypeSection
    }
    CoreModuleType(reader.read_leb_u32())
  } else if tag == 0x01 {
    FuncType(reader.read_typeidx())
  } else if tag == 0x02 {
    Value(parse_valuebound_for_instancedecl(reader))
  } else if tag == 0x03 {
    Type(parse_typebound_for_instancedecl(reader))
  } else if tag == 0x04 {
    ComponentType(reader.read_typeidx())
  } else if tag == 0x05 {
    InstanceType(reader.read_typeidx())
  } else {
    raise InvalidTypeSection
  }
}

///|
fn parse_alias_kind(reader : Reader) -> Int32 raise ComponentParseError {
  // Alias kinds use the same encoding as Sort in the import/export sections:
  // 0x00 <core_sort> for core items, or a single-byte tag for component items.
  let tag = reader.read_u8()
  if tag == 0x00 {
    let core_sort = reader.read_u8()
    // Encode core sorts in a separate range to avoid collisions with 0x01..0x05.
    0x100 + core_sort
  } else {
    tag
  }
}

///|
fn skip_core_typedef(reader : Reader) -> Unit raise ComponentParseError {
  match @core_types.scan_type(reader.data, reader.pos, reader.data.length()) {
    Ok(end) => reader.pos = end
    Err(_) => raise InvalidTypeSection
  }
}

///|
fn bytes_sub(bytes : Bytes, start : Int32, end : Int32) -> Bytes {
  let out : Array[Byte] = []
  for i in start..<end {
    out.push(bytes[i])
  }
  Bytes::from_array(out)
}

///|
fn parse_instancedecl(
  reader : Reader,
) -> InstanceDecl raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    let start = reader.pos
    skip_core_typedef(reader)
    let end = reader.pos
    CoreType(bytes_sub(reader.data, start, end))
  } else if tag == 0x02 {
    // aliasdecl ::= 0x02 kind:<externkind> target:<aliastarget> ...
    let kind = parse_alias_kind(reader)
    let target = reader.read_u8()
    if target == 0x00 {
      // InstanceExport { instance_index, name }
      let instance_idx = reader.read_leb_u32()
      // Alias targets use the plain `name` string encoding (length + bytes),
      // not the export-name string encoding used by import/export decls.
      let name = reader.read_label()
      AliasInstanceExport(kind, instance_idx, name)
    } else if target == 0x02 {
      // Outer { count, index }
      let count = reader.read_leb_u32()
      let idx = reader.read_leb_u32()
      AliasOuter(kind, count, idx)
    } else {
      raise InvalidTypeSection
    }
  } else if tag == 0x04 {
    let (name, attributes) = parse_nameattributes_string(reader)
    let desc = parse_externdesc_for_instancedecl(reader)
    Export(name, attributes, desc)
  } else {
    raise UnsupportedTypeOpcode(tag)
  }
}

///|
fn parse_componentdecl(
  reader : Reader,
) -> ComponentDecl raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    let start = reader.pos
    skip_core_typedef(reader)
    let end = reader.pos
    CoreType(bytes_sub(reader.data, start, end))
  } else if tag == 0x02 {
    // aliasdecl ::= 0x02 kind:<externkind> target:<aliastarget> ...
    let kind = parse_alias_kind(reader)
    let target = reader.read_u8()
    if target == 0x00 {
      // InstanceExport { instance_index, name }
      let instance_idx = reader.read_leb_u32()
      let name = reader.read_label()
      AliasInstanceExport(kind, instance_idx, name)
    } else if target == 0x02 {
      // Outer { count, index }
      let count = reader.read_leb_u32()
      let idx = reader.read_leb_u32()
      AliasOuter(kind, count, idx)
    } else {
      raise InvalidTypeSection
    }
  } else if tag == 0x03 {
    let (name, attributes) = parse_nameattributes_string(reader)
    let desc = parse_externdesc_for_instancedecl(reader)
    Import(name, attributes, desc)
  } else if tag == 0x04 {
    let (name, attributes) = parse_nameattributes_string(reader)
    let desc = parse_externdesc_for_instancedecl(reader)
    Export(name, attributes, desc)
  } else {
    raise UnsupportedTypeOpcode(tag)
  }
}

///|
fn parse_leaf_typedef(reader : Reader) -> TypeDef raise ComponentParseError {
  let op = reader.read_u8()
  match op {
    0x40 | 0x43 => FuncType(parse_functype(reader, op))
    0x65 => {
      // futuretype ::= 0x65 t?:<opt valtype>
      let tag = reader.read_u8()
      if tag == 0x00 {
        Future(None)
      } else if tag == 0x01 {
        Future(Some(parse_valtype(reader)))
      } else {
        raise InvalidTypeSection
      }
    }
    0x66 => {
      // streamtype ::= 0x66 t?:<opt valtype>
      let tag = reader.read_u8()
      if tag == 0x00 {
        Stream(None)
      } else if tag == 0x01 {
        Stream(Some(parse_valtype(reader)))
      } else {
        raise InvalidTypeSection
      }
    }
    0x68 => Borrow(reader.read_typeidx())
    0x69 => Own(reader.read_typeidx())
    0x6a => {
      let has_ok = reader.read_u8()
      let ok = if has_ok == 0x00 {
        None
      } else if has_ok == 0x01 {
        Some(parse_valtype(reader))
      } else {
        raise InvalidTypeSection
      }
      let has_err = reader.read_u8()
      let err = if has_err == 0x00 {
        None
      } else if has_err == 0x01 {
        Some(parse_valtype(reader))
      } else {
        raise InvalidTypeSection
      }
      Result(ok, err)
    }
    0x6b => Option(parse_valtype(reader))
    0x6d => {
      let n = reader.read_leb_u32()
      let cases : Array[String] = []
      for _ in 0..<n {
        cases.push(reader.read_label())
      }
      Enum(cases)
    }
    0x6e => {
      let n = reader.read_leb_u32()
      let cases : Array[String] = []
      for _ in 0..<n {
        cases.push(reader.read_label())
      }
      Flags(cases)
    }
    0x6f => {
      let n = reader.read_leb_u32()
      let tys : Array[ValType] = []
      for _ in 0..<n {
        tys.push(parse_valtype(reader))
      }
      Tuple(tys)
    }
    0x70 => List(parse_valtype(reader))
    0x67 => {
      let ty = parse_valtype(reader)
      let len = reader.read_leb_u32()
      FixedList(ty, len)
    }
    0x63 => MapType(parse_valtype(reader), parse_valtype(reader))
    0x71 => {
      let n = reader.read_leb_u32()
      let cases : Array[VariantCase] = []
      for _ in 0..<n {
        let label = reader.read_label()
        let has_ty = reader.read_u8()
        let ty = if has_ty == 0x00 {
          None
        } else if has_ty == 0x01 {
          Some(parse_valtype(reader))
        } else {
          raise InvalidTypeSection
        }
        let has_refines = reader.read_u8()
        let refines = if has_refines == 0x00 {
          None
        } else if has_refines == 0x01 {
          Some(reader.read_leb_u32())
        } else {
          raise InvalidTypeSection
        }
        cases.push(({ label, ty, refines, } : VariantCase))
      }
      Variant(cases)
    }
    0x72 => {
      let n = reader.read_leb_u32()
      let fields : Array[RecordField] = []
      for _ in 0..<n {
        let label = reader.read_label()
        let ty = parse_valtype(reader)
        fields.push(({ label, ty, } : RecordField))
      }
      Record(fields)
    }
    0x3f => {
      // resourcetype ::= 0x3f rep:<corevaltype> dtor:<opt u32>
      let rep = reader.read_u8()
      let has_dtor = reader.read_u8()
      let dtor = if has_dtor == 0x00 {
        None
      } else if has_dtor == 0x01 {
        Some(reader.read_leb_u32())
      } else {
        raise InvalidTypeSection
      }
      ResourceType(-1, rep, dtor, GuestDefined)
    }
    _ =>
      match parse_prim_valtype(op) {
        Some(p) => DefValType(p)
        None => raise UnsupportedTypeOpcode(op)
      }
  }
}

///|
priv enum TypeWork {
  ReadType(Array[TypeDef])
  ComponentDecls(Int32, Array[ComponentDecl])
  InstanceDecls(Int32, Array[InstanceDecl])
  ComponentChild(Array[ComponentDecl], Array[TypeDef])
  InstanceChild(Array[InstanceDecl], Array[TypeDef])
}

///|
pub fn parse_type_section(
  payload : Bytes,
) -> Array[TypeDef] raise ComponentParseError {
  let reader = Reader::Reader(payload)
  let n = reader.read_count()
  let types : Array[TypeDef] = []
  let work : Array[TypeWork] = []
  for _ in 0..<n {
    work.push(ReadType(types))
  }
  while work.pop() is Some(task) {
    match task {
      ReadType(out) => {
        let op = reader.read_u8()
        if op == 0x41 {
          let decls : Array[ComponentDecl] = []
          out.push(ComponentType(decls))
          work.push(ComponentDecls(reader.read_count(), decls))
        } else if op == 0x42 {
          let n = reader.read_count()
          if n == 0 {
            out.push(InstanceTypeEmpty)
          } else {
            let decls : Array[InstanceDecl] = []
            out.push(InstanceType(decls))
            work.push(InstanceDecls(n, decls))
          }
        } else {
          reader.pos -= 1
          out.push(parse_leaf_typedef(reader))
        }
      }
      ComponentDecls(n, out) =>
        if n > 0 {
          work.push(ComponentDecls(n - 1, out))
          let tag = reader.read_u8()
          if tag == 1 {
            let child = []
            work.push(ComponentChild(out, child))
            work.push(ReadType(child))
          } else {
            reader.pos -= 1
            out.push(parse_componentdecl(reader))
          }
        }
      InstanceDecls(n, out) =>
        if n > 0 {
          work.push(InstanceDecls(n - 1, out))
          let tag = reader.read_u8()
          if tag == 1 {
            let child = []
            work.push(InstanceChild(out, child))
            work.push(ReadType(child))
          } else {
            reader.pos -= 1
            out.push(parse_instancedecl(reader))
          }
        }
      ComponentChild(out, child) => out.push(Type(child[0]))
      InstanceChild(out, child) => out.push(Type(child[0]))
    }
  }
  if !reader.is_eof() {
    raise InvalidTypeSection
  }
  types
}

///|
fn parse_prim_valtype_from_sleb(v : Int32) -> PrimValType? {
  match v {
    -1 => Some(Bool)
    -2 => Some(S8)
    -3 => Some(U8)
    -4 => Some(S16)
    -5 => Some(U16)
    -6 => Some(S32)
    -7 => Some(U32)
    -8 => Some(S64)
    -9 => Some(U64)
    -10 => Some(F32)
    -11 => Some(F64)
    -12 => Some(Char)
    -13 => Some(String)
    -28 => Some(ErrorContext)
    _ => None
  }
}
