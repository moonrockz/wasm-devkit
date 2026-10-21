///|
pub using @core_printer {type Compatibility}

///|
/// One named WAT document. Text is complete and ends with a newline.
pub struct WatDocument {
  name : String
  text : String
} derive(Eq, Debug)

///|
/// Ordered named WAT documents printed from one binary. Core-module printing
/// returns exactly one document, named `root`.
pub struct WatDocuments {
  documents : ReadOnlyArray[WatDocument]
} derive(Eq, Debug)

///|
/// Return the first document. Every successful result contains one.
pub fn WatDocuments::root(self : WatDocuments) -> WatDocument {
  self.documents[0]
}

///|
/// A print failure. Offsets count bytes from the start of the binary.
pub(all) struct Diagnostic {
  source : String
  offset : Int32?
  code : String
  message : String
} derive(Eq, Debug)

///|
fn problem(
  source : String,
  offset : Int32?,
  code : String,
  message : String,
) -> Result[WatDocuments, ReadOnlyArray[Diagnostic]] {
  // Dependency messages can end with a newline; renderers add their own.
  let message = message.trim_end(chars="\n").to_owned()
  Err([{ source, offset, code, message, }])
}

///|
// Custom sections carry no module structure. Read their names so the document
// states each omission. The profile check has already validated this framing.
fn custom_section_names(bytes : Bytes) -> Array[String] {
  let names : Array[String] = []
  let mut position = 8
  let read = fn() -> Int32? {
    let mut value = 0
    let mut shift = 0
    while position < bytes.length() && shift < 35 {
      let byte = bytes[position].to_int()
      position += 1
      value = value | ((byte & 0x7f) << shift)
      if (byte & 0x80) == 0 {
        return Some(value)
      }
      shift += 7
    }
    None
  }
  while position < bytes.length() {
    let id = bytes[position].to_int()
    position += 1
    guard read() is Some(length) else { break }
    let end = position + length
    if id == 0 && read() is Some(size) && position + size <= end {
      names.push(@utf8.decode_lossy(bytes[position:position + size]))
    }
    position = end
  }
  names
}

///|
// Line comments end at a newline, so escape control characters, quotes and
// backslashes. Other characters stay readable.
fn comment_name(name : String) -> String {
  let out = StringBuilder()
  for char in name {
    let code = char.to_int()
    if code < 0x20 || code == 0x7f || char == '"' || char == '\\' {
      let hex = "0123456789abcdef"
      out.write_char('\\')
      out.write_char(hex[(code >> 4) & 0xf].to_int().unsafe_to_char())
      out.write_char(hex[code & 0xf].to_int().unsafe_to_char())
    } else {
      out.write_char(char)
    }
  }
  out.to_string()
}

///|
// A print failure inside a nested operation. The public operations convert it
// to exactly one diagnostic.
priv suberror PrintFailure {
  PrintFailure(Int32?, String, String)
}

///|
fn at(base : Int32?, offset : Int32) -> Int32? {
  base.map(base => base + offset)
}

///|
// Check and render one core module. `base` is the module's offset in the
// printed binary, or `None` when nested offsets are not exact.
fn render_core_module(
  bytes : Bytes,
  base : Int32?,
  compatibility~ : Compatibility? = None,
) -> String raise PrintFailure {
  match @core_types.signaling_f32_constants(bytes) {
    Ok([]) => ()
    // JavaScript quiets these payloads, so no target prints them.
    Ok(offsets) =>
      raise PrintFailure(
        at(base, offsets[0]),
        "WIT-D003",
        "f32 signaling NaN constants are outside the core-module print profile",
      )
    Err(error) =>
      raise PrintFailure(
        at(base, error.offset),
        match error.kind {
          Malformed => "WIT-D001"
          Invalid => "WIT-D002"
          Unsupported => "WIT-D003"
        },
        error.message,
      )
  }
  let module_ = @core_parser.parse_module(bytes) catch {
    error => raise PrintFailure(None, "WIT-D001", error.to_string())
  }
  @core_validation.validate_module(module_) catch {
    @core_validation.TypeWorkLimit =>
      raise PrintFailure(
        base, "WIT-D003", "core type comparison work exceeds 1000000",
      )
    error =>
      raise PrintFailure(
        None,
        "WIT-D002",
        @core_validation.format_validation_error(error),
      )
  }
  let body = try {
    match compatibility {
      Some(style) =>
        @core_printer.render_compatible(
          module_,
          bytes,
          style,
          binary_offset=base.unwrap_or(0),
        )
      None => {
        let metadata = @core_parser.module_text_metadata(bytes) catch {
          error => raise PrintFailure(None, "WIT-D001", error.to_string())
        }
        @core_printer.render(module_, metadata=Some(metadata))
      }
    }
  } catch {
    PrintFailure(offset, code, message) =>
      raise PrintFailure(offset, code, message)
    @core_printer.ReferenceUnsupported(message) =>
      raise PrintFailure(base, "WIT-D003", message)
    @core_printer.BinaryMetadata(message) =>
      raise PrintFailure(base, "WIT-D001", message)
    error => raise PrintFailure(None, "WIT-D004", error.to_string())
  }
  let text = StringBuilder()
  if compatibility is Some(_) {
    return body
  }
  for name in custom_section_names(bytes) {
    text.write_string(";; custom section omitted: \"\{comment_name(name)}\"\n")
  }
  text.write_string(body)
  text.to_string()
}

///|
fn is_component_header(bytes : Bytes) -> Bool {
  bytes.length() >= 8 &&
  bytes[0:4] == b"\x00asm".exact_view() &&
  bytes[4:8] == b"\x0d\x00\x01\x00".exact_view()
}

///|
/// Print a flat core-module binary as one deterministic WAT document.
///
/// The binary must satisfy the core-module profile shared with component
/// verification: framing and limits from `@core_types.inspect_module`, then
/// the retained core parser and validator. Components, f32 signaling NaN
/// constants and other binaries outside that profile fail explicitly. Custom
/// sections are omitted, and a leading comment names each one.
/// No operation performs I/O or executes the binary.
pub fn print_core_module(
  bytes : Bytes,
  source_id~ : String = "<wasm>",
  compatibility~ : Compatibility? = None,
) -> Result[WatDocuments, ReadOnlyArray[Diagnostic]] {
  if is_component_header(bytes) {
    return problem(
      source_id,
      Some(4),
      "WIT-D003",
      "component binaries are outside the core-module print profile",
    )
  }
  let text = render_core_module(bytes, Some(0), compatibility~) catch {
    PrintFailure(offset, code, message) =>
      return problem(source_id, offset, code, message)
  }
  Ok({ documents: [{ name: "root", text, }], })
}

///|
/// Print a component or core-module binary as one deterministic WAT document.
///
/// A component preamble selects `print_component`. Every other input uses
/// `print_core_module`, which reports binaries that are not core modules.
pub fn print_binary(
  bytes : Bytes,
  source_id~ : String = "<wasm>",
  compatibility~ : Compatibility? = None,
) -> Result[WatDocuments, ReadOnlyArray[Diagnostic]] {
  if is_component_header(bytes) {
    print_component(bytes, source_id~, compatibility~)
  } else {
    print_core_module(bytes, source_id~, compatibility~)
  }
}

///|
pub extend WatDocument with Eq::{equal, not_equal}

///|
pub extend WatDocument with @debug.Debug::{to_repr}

///|
pub extend WatDocuments with Eq::{equal, not_equal}

///|
pub extend WatDocuments with @debug.Debug::{to_repr}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Diagnostic with @debug.Debug::{to_repr}
