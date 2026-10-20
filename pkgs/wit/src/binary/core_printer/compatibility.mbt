///|
fn signature(
  types : Array[@types.ValueType],
  group : String,
  spellings~ : ReadOnlyArray[String] = [],
) -> String {
  if types.is_empty() {
    ""
  } else {
    " (\{group} \{types.mapi((i, type_) => spellings.get(i).unwrap_or(compatible_value_type(type_))).join(" ")})"
  }
}

///|
fn compatible_signature(
  type_ : @types.FuncType,
  text~ : @core_parser.FunctionTextTypes? = None,
) -> String {
  signature(
    type_.params,
    "param",
    spellings=text.map(t => t.params).unwrap_or([]),
  ) +
  signature(
    type_.results,
    "result",
    spellings=text.map(t => t.results).unwrap_or([]),
  )
}

///|
fn named_locals(
  types : Array[@types.ValueType],
  group : String,
  names : Names,
  func : Int32,
  start : Int32,
  kind~ : Int32 = 2,
  spellings~ : ReadOnlyArray[String] = [],
) -> String {
  let out = StringBuilder()
  let mut at = 0
  while at < types.length() {
    if names.local_declaration(kind, func, start + at) is Some(name) {
      out.write_string(
        " (\{group} \{name} \{spellings.get(at).unwrap_or(compatible_value_type(types[at]))})",
      )
      at += 1
    } else {
      let begin = at
      at += 1
      while at < types.length() &&
            names.local_declaration(kind, func, start + at) is None {
        at += 1
      }
      out.write_string(" (\{group}")
      for i in begin..<at {
        out.write_string(
          " \{spellings.get(i).unwrap_or(compatible_value_type(types[i]))}",
        )
      }
      out.write_char(')')
    }
  }
  out.to_string()
}

///|
fn compatible_function(
  mod_ : @types.Module,
  index : Int32,
  imported : Int32,
  names : Names,
) -> String raise WatPrintError {
  let local_index = index - imported
  let type_ = mod_.funcs[local_index]
  guard mod_.func_type_at(type_) is Some(sig) else {
    raise NotAFunctionType(type_)
  }
  let code = mod_.codes[local_index]
  let out = StringBuilder()
  out.write_string(
    "  (func \{names.declaration(1, index)} (type \{names.reference(4, type_)})",
  )
  out.write_string(
    named_locals(
      sig.params,
      "param",
      names,
      index,
      0,
      spellings=names.type_values.get(type_).map(t => t.params).unwrap_or([]),
    ),
  )
  out.write_string(
    signature(
      sig.results,
      "result",
      spellings=names.type_values.get(type_).map(t => t.results).unwrap_or([]),
    ),
  )
  if !code.locals.is_empty() {
    out.write_string(
      "\n   \{named_locals(code.locals, "local", names, index, sig.params.length(), spellings=names.local_values.get(index).unwrap_or([]))}",
    )
  }
  let body_text = compatible_body(code.body, names, index)
  if !body_text.is_empty() {
    out.write_char('\n')
    out.write_string(body_text)
    if names.style == WasmTools {
      out.write_string("  ")
    } else {
      // WABT closes the function on its final instruction's line.
      let body = out.to_string().trim_end(chars="\n ").to_owned()
      return body + ")\n"
    }
  }
  if body_text.is_empty() && !code.locals.is_empty() && names.style == WasmTools {
    out.write_string("\n  ")
  }
  out.write_string(")\n")
  out.to_string()
}

///|
fn compatible_table(
  type_ : @types.TableType,
  spelling~ : String = "",
) -> String {
  (if type_.is_table64 { "i64 " } else { "" }) +
  limits_to_wat(type_.limits) +
  " " +
  (if spelling.is_empty() {
    compatible_value_type(type_.elem_type)
  } else {
    spelling
  })
}

///|
fn compatible_memory(
  type_ : @types.MemoryType,
  style : Compatibility,
  explicit_pages~ : Bool = false,
) -> String {
  (if type_.is_memory64 { "i64 " } else { "" }) +
  limits_to_wat(type_.limits) +
  (if type_.is_shared { " shared" } else { "" }) +
  (if type_.page_size_log2 == 16 && !(style == WasmTools && explicit_pages) {
    ""
  } else if style == WasmTools {
    " (pagesize 0x\{(1 << type_.page_size_log2).to_string(radix=16)})"
  } else {
    memory_page_size_to_wat(type_)
  })
}

///|
fn compatible_global(
  type_ : @types.GlobalType,
  spelling~ : String = "",
  shared~ : Bool = false,
) -> String {
  let value = if spelling.is_empty() {
    compatible_value_type(type_.value_type)
  } else {
    spelling
  }
  if shared {
    "(shared \{if type_.mutable { "mut " } else { "" }}\{value})"
  } else if type_.mutable {
    "(mut \{value})"
  } else {
    value
  }
}

///|
fn compatible_inline(body : Array[@types.Instruction], names : Names) -> String {
  body.map(i => compatible_instruction(i, names, 0, [], 0)).join(" ")
}

///|
fn compatible_offset(body : Array[@types.Instruction], names : Names) -> String {
  if names.style == Wabt {
    return compatible_constant(body, names)
  }
  if body.length() == 1 {
    "(\{compatible_inline(body, names)})"
  } else {
    "(offset \{compatible_inline(body, names)})"
  }
}

///|
/// Render a validated core module inside the decompiler input profile using
/// pinned wasm-tools or WABT conventions.
/// `bytes` supplies name and custom sections that the core AST does not retain.
pub fn render_compatible(
  mod_ : @types.Module,
  bytes : Bytes,
  style : Compatibility,
  binary_offset~ : Int32 = 0,
) -> String raise WatPrintError {
  validate_module_shape(mod_)
  validate_compatibility_control(mod_)
  let metadata = @core_parser.module_text_metadata(bytes) catch {
    error => raise BinaryMetadata(error.to_string())
  }
  let (names, custom) = core_metadata(bytes, style, base=binary_offset)
  names.type_values = metadata.type_values
  let imported_functions = imported_function_count(mod_)
  for i, values in metadata.local_values {
    names.local_values[imported_functions + i] = values
  }
  for i, instructions in metadata.instruction_values {
    for (opcode, values) in instructions {
      names.instruction_values[(imported_functions + i, opcode)] = values
    }
  }
  for i in 0..<mod_.types.length() {
    if mod_.func_type_at(i) is Some(sig) {
      names.signatures[i] = sig
    }
  }
  for i, labels in metadata.function_elses {
    for label in labels {
      names.elses[(imported_function_count(mod_) + i, label)] = true
    }
  }
  names.read_hints(
    custom,
    metadata.instruction_offsets,
    imported_function_count(mod_),
  )
  for section in custom {
    validate_reference_custom(section, style)
  }
  if style == Wabt {
    validate_wabt_types(mod_, metadata)
    validate_wabt_custom(mod_, names, custom, metadata)
    validate_wabt_names(mod_, names)
    if !names.metadata_valid {
      raise BinaryMetadata("malformed name section rejected by WABT 1.0.42")
    }
  }
  let sections : Map[Int32, Array[String]] = Map([])
  let add = fn(id, text) {
    match sections.get(id) {
      Some(items) => items.push(text)
      None => sections[id] = [text]
    }
  }
  let type_text : Array[String] = []
  for i, type_ in mod_.types {
    let body = match type_.composite {
      Func(sig) =>
        if style == WasmTools {
          "(func\{named_locals(sig.params, "param", names, i, 0, kind=12, spellings=metadata.type_values[i].params)}\{signature(sig.results, "result", spellings=metadata.type_values[i].results)})"
        } else {
          "(func\{compatible_signature(sig, text=metadata.type_values.get(i))})"
        }
      _ => subtype_to_wat(type_)
    }
    let body = if type_.final_ { body } else { "(sub " + body + ")" }
    type_text.push("(type \{names.declaration(4, i)} \{body})")
  }
  let mut index = 0
  let mut group = 0
  while index < type_text.length() ||
        group < metadata.explicit_rec_groups.length() {
    if style == WasmTools &&
      group < metadata.explicit_rec_groups.length() &&
      metadata.explicit_rec_groups[group].0 == index {
      let size = metadata.explicit_rec_groups[group].1
      group += 1
      if size == 0 {
        add(1, "  (rec)\n")
      } else {
        add(1, "  (rec\n")
        for i in index..<(index + size) {
          add(1, "    " + type_text[i] + "\n")
        }
        add(1, "  )\n")
        index += size
      }
    } else {
      add(1, "  " + type_text[index] + "\n")
      index += 1
    }
  }
  let counts : Map[Int32, Int32] = Map([])
  for import_index, item in mod_.imports {
    let (kind, body) = match item.desc {
      Func(type_) => {
        let sig = if style == WasmTools {
          mod_
          .func_type_at(type_)
          .map(sig => {
            named_locals(
              sig.params,
              "param",
              names,
              counts.get(1).unwrap_or(0),
              0,
              spellings=metadata.type_values[type_].params,
            ) +
            signature(
              sig.results,
              "result",
              spellings=metadata.type_values[type_].results,
            )
          })
          .unwrap_or("")
        } else {
          ""
        }
        (1, "(type \{names.reference(4, type_)})\{sig}")
      }
      Table(type_) =>
        (
          5,
          compatible_table(type_, spelling=metadata.import_values[import_index]),
        )
      Memory(type_) =>
        (
          6,
          compatible_memory(
            type_,
            style,
            explicit_pages=metadata.explicit_memory_pages
              .get(counts.get(6).unwrap_or(0))
              .unwrap_or(false),
          ),
        )
      Global(type_) =>
        (
          7,
          compatible_global(
            type_,
            spelling=metadata.import_values[import_index],
            shared=(metadata.import_global_flags[import_index].1 & 2) != 0,
          ),
        )
      Tag(type_) => {
        let sig = mod_
          .func_type_at(type_)
          .map(sig => {
            if style == WasmTools {
              named_locals(
                sig.params,
                "param",
                names,
                counts.get(11).unwrap_or(0),
                0,
                kind=13,
                spellings=metadata.type_values[type_].params,
              )
            } else {
              signature(
                sig.params,
                "param",
                spellings=metadata.type_values[type_].params,
              )
            }
          })
          .unwrap_or("")
        (11, "(type \{names.reference(4, type_)})\{sig}")
      }
    }
    let index = counts.get(kind).unwrap_or(0)
    counts[kind] = index + 1
    let sort = match kind {
      1 => "func"
      5 => "table"
      6 => "memory"
      7 => "global"
      _ => "tag"
    }
    add(
      2,
      "  (import \"\{compatible_string(item.mod_name, style)}\" \"\{compatible_string(item.name, style)}\" (\{sort} \{names.declaration(kind, index)} \{body}))\n",
    )
  }
  let imported = counts.get(1).unwrap_or(0)
  for i in 0..<mod_.codes.length() {
    add(10, compatible_function(mod_, imported + i, imported, names))
  }
  for i, table in mod_.tables {
    let init = table.init
      .map(body => {
        " " +
        (if style == WasmTools {
          compatible_inline(body, names)
        } else {
          compatible_offset(body, names)
        })
      })
      .unwrap_or("")
    add(
      4,
      "  (table \{names.declaration(5, counts.get(5).unwrap_or(0) + i)} \{compatible_table(table.type_, spelling=metadata.table_values[i])}\{init})\n",
    )
  }
  for i, memory in mod_.memories {
    add(
      5,
      "  (memory \{names.declaration(6, counts.get(6).unwrap_or(0) + i)} \{compatible_memory(memory, style, explicit_pages=metadata.explicit_memory_pages.get(counts.get(6).unwrap_or(0) + i).unwrap_or(false))})\n",
    )
  }
  for i, global in mod_.globals {
    let init = if style == WasmTools {
      compatible_inline(global.init, names)
    } else {
      compatible_constant(global.init, names)
    }
    add(
      6,
      "  (global \{names.declaration(7, counts.get(7).unwrap_or(0) + i)} \{compatible_global(global.type_, spelling=metadata.global_values[i], shared=(metadata.global_flags[i].1 & 2) != 0)} \{init})\n",
    )
  }
  for i, tag in mod_.tags {
    let index = counts.get(11).unwrap_or(0) + i
    let sig = mod_
      .func_type_at(tag.type_idx)
      .map(sig => {
        if style == WasmTools {
          named_locals(
            sig.params,
            "param",
            names,
            index,
            0,
            kind=13,
            spellings=metadata.type_values[tag.type_idx].params,
          )
        } else {
          signature(
            sig.params,
            "param",
            spellings=metadata.type_values[tag.type_idx].params,
          )
        }
      })
      .unwrap_or("")
    add(
      13,
      "  (tag \{names.declaration(11, index)} (type \{names.reference(4, tag.type_idx)})\{sig})\n",
    )
  }
  for item in mod_.exports {
    let (sort, kind, index) = match item.desc {
      Func(i) => ("func", 1, i)
      Table(i) => ("table", 5, i)
      Memory(i) => ("memory", 6, i)
      Global(i) => ("global", 7, i)
      Tag(i) => ("tag", 11, i)
    }
    let reference = if kind == 11 && style == WasmTools {
      index.to_string()
    } else {
      names.reference(kind, index)
    }
    add(
      7,
      "  (export \"\{compatible_string(item.name, style)}\" (\{sort} \{reference}))\n",
    )
  }
  if mod_.start is Some(i) {
    add(8, "  (start \{names.reference(1, i)})\n")
  }
  for i, elem in mod_.elems {
    let out = StringBuilder()
    out.write_string("  (elem \{names.declaration(8, i)} ")
    match elem.mode {
      Passive => ()
      Declarative => out.write_string("declare ")
      Active(table, offset) => {
        if table != 0 ||
          (style == WasmTools && (metadata.element_flags[i] & 2) != 0) {
          out.write_string("(table \{names.reference(5, table)}) ")
        }
        out.write_string(compatible_offset(offset, names) + " ")
      }
    }
    if (metadata.element_flags[i] & 4) == 0 {
      out.write_string("func")
      for body in elem.init {
        if body is [RefFunc(i)] {
          out.write_string(" \{names.reference(1, i)}")
        }
      }
    } else {
      out.write_string(metadata.element_values[i])
      for body in elem.init {
        out.write_string(" " + compatible_offset(body, names))
      }
    }
    out.write_string(")\n")
    add(9, out.to_string())
  }
  for i, data in mod_.datas {
    let memory = if data.memory_idx > 0 {
      "(memory \{names.reference(6, data.memory_idx)}) "
    } else {
      ""
    }
    let offset = if data.offset.is_empty() {
      ""
    } else {
      compatible_offset(data.offset, names) + " "
    }
    add(
      11,
      "  (data \{names.declaration(9, i)} \{memory}\{offset}\"\{escape_wat_bytes(data.init)}\")\n",
    )
  }
  let out = StringBuilder()
  out.write_string("(module")
  if names.local_declaration(0, 0, 0) is Some(name) {
    out.write_string(" " + name)
  }
  if style == Wabt {
    for id in [1, 2, 10, 4, 5, 13, 6, 7, 8, 9, 11] {
      for text in sections.get(id).unwrap_or([]) {
        out.write_char('\n')
        out.write_string(text.trim_end(chars="\n").to_owned())
      }
    }
    for section in custom {
      out.write_string(
        "\n  (@custom \"\{compatible_string(section.name, style)}\" \"\{escape_wat_bytes(section.data)}\")",
      )
    }
    out.write_string(")\n")
  } else {
    // The binary stream determines custom-section placement and declaration order.
    let reader = metadata_reader(bytes)
    reader.position = 8
    let mut custom_at = 0
    try {
      while reader.position < bytes.length() {
        let id = reader.byte()
        ignore(reader.slice(reader.uint()))
        if id == 0 {
          let section = custom[custom_at]
          custom_at += 1
          if section.name == "name" ||
            section.name == "component-name" ||
            section.name == "metadata.code.branch_hint" {
            continue
          }
          out.write_string("\n" + compatible_custom(section))
        } else {
          for text in sections.get(id).unwrap_or([]) {
            out.write_char('\n')
            out.write_string(text.trim_end(chars="\n").to_owned())
          }
        }
      }
    } catch {
      MetadataError(_, _) => ()
    }
    if out.to_string().contains("\n") {
      out.write_char('\n')
    }
    out.write_string(")\n")
  }
  if style == WasmTools {
    limit_indentation(out.to_string())
  } else {
    out.to_string()
  }
}

///|
fn compatible_custom(section : CustomSection) -> String {
  let style = WasmTools
  let place = match section.after {
    0 => "before first"
    1 => "after type"
    2 => "after import"
    3 => "after func"
    4 => "after table"
    5 => "after memory"
    6 => "after global"
    7 => "after export"
    8 => "after start"
    9 => "after elem"
    10 => "after code"
    11 => "after data"
    13 => "after tag"
    _ => "after data count"
  }
  let placement = if section.after < 0 { "" } else { " (\{place})" }
  let raw = "  (@custom \"\{compatible_string(section.name, style)}\"\{placement} \"\{escape_wat_bytes(section.data)}\")"
  let failure = fn(offset : Int32, message : String) -> String {
    let message = "failed to parse custom section `\{section.name}`: \{message} (at offset 0x\{offset.to_string(radix=16)})"
    message
    .split("\n")
    .map(line => "  ;; " + line.to_owned() + "\n")
    .to_array()
    .join("") +
    raw
  }
  if section.name == "dylink.0" {
    return match compatible_dylink(section.data, base=section.offset) {
      Ok(text) => text
      Err((offset, message)) => failure(offset, message)
    }
  }
  if section.name == "producers" {
    let reader = metadata_reader(section.data, base=section.offset)
    let fields = reader.uint().reinterpret_as_uint() catch {
        MetadataError(_, _) => return raw
      }
    let out = StringBuilder()
    out.write_string("  (@producers")
    try {
      for remaining = fields; remaining > 0U; remaining = remaining - 1U {
        let start = reader.base + reader.position
        let field = reader.string()
        if !["language", "processed-by", "sdk"].contains(field) {
          raise MetadataError(start, "invalid producers field name: `\{field}`")
        }
        let values = reader.uint().reinterpret_as_uint()
        for remaining = values; remaining > 0U; remaining = remaining - 1U {
          let name = reader.string()
          let version = reader.string()
          out.write_string(
            "\n    (\{field} \"\{compatible_string(name, WasmTools)}\" \"\{compatible_string(version, WasmTools)}\")",
          )
        }
      }
      if out.to_string().contains("\n") {
        out.write_string("\n  ")
      }
      out.write_char(')')
      return out.to_string()
    } catch {
      MetadataError(offset, message) => return failure(offset, message)
    }
  }
  raw
}

///|
/// wasm-tools limits the number of printed indentation levels to 50. The
/// emitter escapes all literal newlines, so line prefixes here are layout.
pub fn limit_indentation(text : String) -> String {
  text
  .split("\n")
  .map(line => {
    let content = line.trim_start(chars=" ")
    let spaces = line.length() - content.length()
    if spaces > 100 {
      "  ".repeat(50) + content.to_owned()
    } else {
      line.to_owned()
    }
  })
  .to_array()
  .join("\n")
}

///|
fn compatible_value_type(type_ : @types.ValueType) -> String {
  match type_ {
    RefNullEq => "eqref"
    RefNullI31 => "i31ref"
    _ => value_type_to_wat(type_)
  }
}
