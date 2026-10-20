///|
// Parenthesis depth alone does not bound flat block/loop/if keywords. Walk
// folded lists and flat control frames together before invoking the core WAT
// parser and encoder, whose recursion is limited to this checked depth.
fn check_flat_core_module(
  items : Array[SExpr],
) -> Unit raise ComponentTextError {
  let work : Array[(Array[SExpr], Int32, Int32, Int32, Bool)] = [
    (items, 0, 0, 0, false),
  ]
  while work.pop() is Some((items, index, depth, base, byte_strings)) {
    if index >= items.length() {
      continue
    }
    match items[index] {
      Atom("block" | "loop" | "if") => {
        if depth >= 64 {
          raise Unsupported("core WAT control/expression nesting exceeds 64")
        }
        work.push((items, index + 1, depth + 1, base, byte_strings))
      }
      Atom("end") => {
        if depth <= base {
          raise Unsupported("unmatched core control end")
        }
        work.push((items, index + 1, depth - 1, base, byte_strings))
      }
      Atom("try" | "try_table") =>
        raise Unsupported(
          "core exception instructions are outside the module profile",
        )
      Atom(opcode) if opcode.has_prefix("global.atomic.") =>
        raise Unsupported(
          "core atomic global instructions are outside the module profile",
        )
      List(children) => {
        work.push((items, index + 1, depth, base, byte_strings))
        let folded = children.get(0) is Some(Atom("block" | "loop" | "if"))
        let header = children.get(0)
          is Some(Atom("func" | "param" | "result" | "local"))
        let next = if header { depth } else { depth + 1 }
        if next > 64 {
          raise Unsupported("core WAT control/expression nesting exceeds 64")
        }
        let data = children.get(0) is Some(Atom("data"))
        work.push((children, if folded { 1 } else { 0 }, next, next, data))
      }
      ByteStr(_) if !byte_strings =>
        raise ParseError("core WAT name is not UTF-8")
      _ => work.push((items, index + 1, depth, base, byte_strings))
    }
  }
}

///|
// The retained core WAT parser accepts either an imported function type use or
// an inline signature. Check redundant signatures before removing only that
// redundant spelling, preserving the referenced type and function index.
fn normalize_core_import_signatures(
  items : Array[SExpr],
  state : ComponentBuildState,
) -> Array[SExpr] raise ComponentTextError {
  let declarations : Array[SExpr] = []
  let names : Array[NamedBinding] = []
  let pending : Array[(Array[SExpr], Int32)] = [(items, 0)]
  while pending.pop() is Some((fields, index)) {
    if index >= fields.length() {
      continue
    }
    pending.push((fields, index + 1))
    if fields[index] is List(field) && field.get(0) is Some(Atom("rec")) {
      pending.push((field, 1))
    } else if fields[index] is List(field) && field.get(0) is Some(Atom("type")) {
      let name = parse_optional_identifier(field, 1)
      let start = if name is Some(_) { 2 } else { 1 }
      guard field.length() == start + 1 else {
        raise ParseError("invalid core type declaration")
      }
      core_unique_name(state, names, name, 0)
      bind_named_index(names, name, declarations.length())
      declarations.push(field[start])
    }
  }
  let out : Array[SExpr] = []
  let signatures : Map[Int32, @core_types.Definition] = Map([])
  for item in items {
    guard item is List(field) &&
      field.length() == 4 &&
      field[0] is Atom("import") &&
      field[3] is List(desc) &&
      desc.get(0) is Some(Atom("func")) else {
      out.push(item)
      continue
    }
    let start = if parse_optional_identifier(desc, 1) is Some(_) {
      2
    } else {
      1
    }
    guard desc.get(start) is Some(List(use_type)) &&
      use_type.length() == 2 &&
      use_type[0] is Atom("type") &&
      desc.length() > start + 1 else {
      out.push(item)
      continue
    }
    let index = resolve_reference(
      use_type[1],
      names,
      "core import function type",
    )
    guard declarations.get(index) is Some(List(body)) &&
      body.get(0) is Some(Atom("func")) else {
      raise Unsupported(
        "redundant core import signature requires a function type",
      )
    }
    let inline_signature : Array[SExpr] = [Atom("func")]
    for i in (start + 1)..<desc.length() {
      inline_signature.push(desc[i])
    }
    let encoded = parse_core_func_type_bytes(inline_signature, names)
    if encoded.length() > state.core_name_work {
      raise Unsupported("core import signature work limit")
    }
    state.core_name_work -= encoded.length()
    let actual = match @core_types.decode_type(encoded) {
      Ok(definition) => definition
      Err(_) => raise Unsupported("unsupported core import signature")
    }
    let expected = if signatures.get(index) is Some(definition) {
      definition
    } else {
      let encoded = parse_core_func_type_bytes(body, names)
      if encoded.length() > state.core_name_work {
        raise Unsupported("core import signature work limit")
      }
      state.core_name_work -= encoded.length()
      let definition = match @core_types.decode_type(encoded) {
        Ok(definition) => definition
        Err(_) => raise Unsupported("unsupported referenced core signature")
      }
      signatures[index] = definition
      definition
    }
    if actual != expected {
      raise ParseError(
        "core import inline signature does not match its type use",
      )
    }
    let normalized : Array[SExpr] = []
    for i in 0..<(start + 1) {
      normalized.push(desc[i])
    }
    out.push(List([field[0], field[1], field[2], List(normalized)]))
  }
  out
}
