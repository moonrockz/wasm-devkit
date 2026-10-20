///|
// The retained WAT AST has no shared-global field. Normalize only the type
// spelling, then restore the flags in the encoded original initializer bytes.
fn normalize_concrete_globals(
  items : Array[SExpr],
) -> (Array[SExpr], Array[Bool], Map[String, Int32]) raise ComponentTextError {
  let out : Array[SExpr] = []
  let imports : Array[Bool] = []
  let definitions : Array[Bool] = []
  let exports : Array[(String, Int32, Bool)] = []
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
    guard desc.get(0) is Some(Atom("global")) else {
      out.push(item)
      continue
    }
    let normalized = desc.copy()
    let mut start = if parse_optional_identifier(desc, 1) is Some(_) {
      2
    } else {
      1
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
    let mut shared = false
    if desc.get(start) is Some(List(flags)) &&
      flags.get(0) is Some(Atom("shared")) {
      shared = true
      normalized[start] = match flags {
        [Atom("shared"), value] => value
        [Atom("shared"), Atom("mut"), value] => List([Atom("mut"), value])
        _ => raise ParseError("invalid shared global type")
      }
    }
    let is_import = imported || inline_import
    let index = if is_import { imports.length() } else { definitions.length() }
    for value in desc {
      if value is List(annotation) && annotation is [Atom("export"), name] {
        exports.push(
          (parse_name_text(name, "core global export"), index, is_import),
        )
      }
    }
    if is_import {
      imports.push(shared)
    } else {
      definitions.push(shared)
    }
    out.push(
      if imported {
        List([field[0], field[1], field[2], List(normalized)])
      } else {
        List(normalized)
      },
    )
  }
  let export_indices : Map[String, Int32] = Map([])
  for (name, index, imported) in exports {
    export_indices[name] = index + (if imported { 0 } else { imports.length() })
  }
  imports.append(definitions)
  (out, imports, export_indices)
}

///|
fn restore_concrete_global_flags(
  bytes : Bytes,
  shared : Array[Bool],
) -> Bytes raise ComponentTextError {
  if !shared.any(value => value) {
    return bytes
  }
  // Bound the metadata parser and retain explicit proposal exclusions before
  // reading its legacy AST. Final validation checks the restored bytes.
  if @core_types.inspect_module(bytes)
    is Err({ kind: Unsupported, message, .. }) {
    raise Unsupported(message)
  }
  let metadata = @core_parser.module_text_metadata(bytes) catch {
    e => raise ParseError("encoded core global metadata: \{e}")
  }
  let flags : Array[(Int32, Int32)] = []
  for pair in metadata.import_global_flags {
    if pair.0 >= 0 {
      flags.push(pair)
    }
  }
  for pair in metadata.global_flags {
    flags.push(pair)
  }
  guard flags.length() == shared.length() else {
    raise ParseError("encoded global index mismatch")
  }
  let out = bytes.to_array()
  for i, pair in flags {
    if shared[i] {
      out[pair.0] = (pair.1 | 2).to_byte()
    }
  }
  Bytes::from_array(out)
}
