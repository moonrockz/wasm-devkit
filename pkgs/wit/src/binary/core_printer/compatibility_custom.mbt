///|
fn dylink_flags(flags : Int32) -> String {
  let out = StringBuilder()
  let mut flags = flags
  for
    (bit, name) in [
      (1, "binding-weak"),
      (2, "binding-local"),
      (4, "visibility-hidden"),
      (16, "undefined"),
      (32, "exported"),
      (64, "explicit-name"),
      (128, "no-strip"),
      (256, "tls"),
      (512, "absolute"),
    ] {
    if (flags & bit) != 0 {
      out.write_string(" " + name)
      flags = flags & bit.lnot()
    }
  }
  if flags != 0 {
    out.write_string(" 0x" + flags.reinterpret_as_uint().to_string(radix=16))
  }
  out.to_string()
}

///|
fn compatible_dylink(
  bytes : Bytes,
  base~ : Int32 = 0,
) -> Result[String, (Int32, String)] {
  let reader = metadata_reader(bytes, base~)
  let out = StringBuilder()
  out.write_string("  (@dylink.0")
  let quoted = fn(reader : MetadataReader) -> String raise MetadataError {
    "\"" + compatible_string(reader.string(), WasmTools) + "\""
  }
  try {
    while reader.position < bytes.length() {
      let id = reader.byte()
      let sub = reader.subreader()
      match id {
        1 => {
          let memory = sub.uint()
          let memory_align = sub.uint()
          let table = sub.uint()
          let table_align = sub.uint()
          out.write_string("\n    (mem-info")
          if memory > 0 || memory_align > 0 {
            out.write_string(" (memory \{memory} \{memory_align})")
          }
          if table > 0 || table_align > 0 {
            out.write_string(" (table \{table} \{table_align})")
          }
          out.write_char(')')
        }
        2 | 5 => {
          out.write_string(
            "\n    (" + (if id == 2 { "needed" } else { "runtime-path" }),
          )
          let count = sub.uint().reinterpret_as_uint()
          for remaining = count; remaining > 0U; remaining = remaining - 1U {
            out.write_string(" " + quoted(sub))
          }
          out.write_char(')')
        }
        3 | 4 => {
          let count = sub.uint().reinterpret_as_uint()
          for remaining = count; remaining > 0U; remaining = remaining - 1U {
            out.write_string(
              "\n    (" +
              (if id == 3 { "export-info " } else { "import-info " }),
            )
            out.write_string(quoted(sub))
            if id == 4 {
              out.write_string(" " + quoted(sub))
            }
            out.write_string(dylink_flags(sub.uint()) + ")")
          }
        }
        6 => out.write_string("\n    (target-arch " + quoted(sub) + ")")
        _ =>
          return Err(
            (sub.base, "don't know how to print dylink.0 subsection id \{id}"),
          )
      }
    }
  } catch {
    MetadataError(offset, message) => return Err((offset, message))
  }
  if out.to_string().contains("\n") {
    out.write_string("\n  ")
  }
  out.write_char(')')
  Ok(out.to_string())
}

///|
fn validate_reference_custom(
  section : CustomSection,
  style : Compatibility,
) -> Unit raise WatPrintError {
  if section.name != "dylink.0" {
    return
  }
  if compatible_dylink(section.data, base=section.offset) is Err((_, message)) &&
    message.has_prefix("don't know how to print") &&
    style == WasmTools {
    raise ReferenceUnsupported("wasm-tools 1.262.0 " + message)
  }
}
