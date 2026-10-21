///|
fn push_core_heap_encoding(
  payload : ByteBuf,
  expr : SExpr,
  names : Array[NamedBinding],
) -> Unit raise ComponentTextError {
  if expr is List(shared) && shared is [Atom("shared"), heap] {
    let code = parse_core_heap_type_sleb(heap, names)
    if code >= 0 || code == -24 || code == -11 {
      raise ParseError(
        "shared heap syntax requires a supported abstract heap type",
      )
    }
    payload.push_u8(0x65)
    payload.push_sleb_i32(code)
  } else {
    payload.push_sleb_i32(parse_core_heap_type_sleb(expr, names))
  }
}

///|
fn push_core_storage(
  payload : ByteBuf,
  expr : SExpr,
  names : Array[NamedBinding],
) -> Unit raise ComponentTextError {
  match expr {
    Atom("i8") => payload.push_u8(0x78)
    Atom("i16") => payload.push_u8(0x77)
    _ => push_core_valtype_encoding(payload, expr, names)
  }
}

///|
fn push_core_field(
  payload : ByteBuf,
  expr : SExpr,
  names : Array[NamedBinding],
) -> Unit raise ComponentTextError {
  if expr is List(mut_) && mut_.get(0) is Some(Atom("mut")) {
    if mut_.length() != 2 {
      raise ParseError("mutable core field requires one storage type")
    }
    push_core_storage(payload, mut_[1], names)
    payload.push_u8(1)
  } else {
    push_core_storage(payload, expr, names)
    payload.push_u8(0)
  }
}

///|
// Subtype and shared wrappers have fixed grammar depth. Reference graph edges
// are indices; none of these routines descends through a referenced type.
fn parse_core_heap_type_bytes(
  body : Array[SExpr],
  names : Array[NamedBinding],
  top : Bool,
) -> Bytes raise ComponentTextError {
  let payload = ByteBuf::ByteBuf()
  let mut body = body
  if body.get(0) is Some(Atom("sub")) {
    let mut position = 1
    let final_ = body.get(position) is Some(Atom("final"))
    if final_ {
      position += 1
    }
    let parent = if body.get(position) is Some(Atom(_)) {
      let parent = resolve_reference(body[position], names, "core supertype")
      position += 1
      Some(parent)
    } else {
      None
    }
    if position + 1 != body.length() {
      raise ParseError(
        "core subtype requires at most one supertype and one composite body",
      )
    }
    guard body.get(position) is Some(List(composite)) else {
      raise ParseError("core subtype requires a composite body")
    }
    if !final_ && top {
      payload.push_u8(0)
    }
    payload.push_u8(if final_ { 0x4f } else { 0x50 })
    payload.push_uleb_u32(if parent is Some(_) { 1 } else { 0 })
    if parent is Some(parent) {
      payload.push_uleb_u32(parent)
    }
    body = composite
  }
  if body.get(0) is Some(Atom("shared")) {
    guard body is [Atom("shared"), List(composite)] else {
      raise ParseError("shared core type requires one composite body")
    }
    payload.push_u8(0x65)
    body = composite
  }
  match body.get(0) {
    Some(Atom("func")) =>
      payload.push_bytes(parse_core_func_type_bytes(body, names))
    Some(Atom("struct")) => {
      let fields = ByteBuf::ByteBuf()
      let mut count = 0
      for i in 1..<body.length() {
        guard body[i] is List(field) && field.get(0) is Some(Atom("field")) else {
          raise ParseError("struct type requires field declarations")
        }
        let start = if parse_optional_identifier(field, 1) is Some(_) {
          2
        } else {
          1
        }
        for j in start..<field.length() {
          push_core_field(fields, field[j], names)
          count += 1
        }
      }
      payload.push_u8(0x5f)
      payload.push_uleb_u32(count)
      payload.push_bytes(fields.to_bytes())
    }
    Some(Atom("array")) => {
      if body.length() != 2 {
        raise ParseError("array type requires one field type")
      }
      payload.push_u8(0x5e)
      push_core_field(payload, body[1], names)
    }
    _ => raise Unsupported("unsupported composite core type")
  }
  payload.to_bytes()
}

///|
fn parse_core_rec_bytes(
  fields : Array[SExpr],
  start : Int32,
  base : Int32,
  names : Array[NamedBinding],
  state : ComponentBuildState,
  shadow_start~ : Int32 = 0,
) -> (Bytes, Int32) raise ComponentTextError {
  let bodies : Array[Array[SExpr]] = []
  for i in start..<fields.length() {
    guard fields[i] is List(field) && field.get(0) is Some(Atom("type")) else {
      raise ParseError("recursive core group requires type declarations")
    }
    let name = parse_optional_identifier(field, 1)
    let body_at = if name is Some(_) { 2 } else { 1 }
    if body_at + 1 != field.length() {
      raise ParseError("recursive type declaration requires one body")
    }
    guard field.get(body_at) is Some(List(body)) else {
      raise ParseError("recursive core type requires a composite body")
    }
    core_unique_name(state, names, name, shadow_start)
    bind_named_index(names, name, base + bodies.length())
    bodies.push(body)
  }
  let payload = ByteBuf::ByteBuf()
  payload.push_u8(0x4e)
  payload.push_uleb_u32(bodies.length())
  for body in bodies {
    payload.push_bytes(parse_core_heap_type_bytes(body, names, false))
  }
  (payload.to_bytes(), bodies.length())
}

///|
fn parse_core_rec_field(
  field : Array[SExpr],
  state : ComponentBuildState,
) -> Unit raise ComponentTextError {
  let idx = state.next_core_type_idx
  let (bytes, count) = parse_core_rec_bytes(
    field,
    2,
    idx,
    state.core_type_names,
    state,
  )
  state.next_core_type_idx += count
  state.core_types.push({ idx, bytes, })
  push_ordered_section(state, 3, bytes)
}
