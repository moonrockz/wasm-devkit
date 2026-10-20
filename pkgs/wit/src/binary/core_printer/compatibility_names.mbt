///|
/// Exact output conventions of the pinned external printers. These options
/// affect rendering only; the decompiler checks its existing input profile.
pub(all) enum Compatibility {
  WasmTools
  Wabt
} derive(Eq, Debug)

///|
priv struct Naming {
  identifier : String
  declaration : String
}

///|
pub struct Names {
  priv entries : Map[(Int32, Int32, Int32), Naming]
  priv core_encoding : Bool
  priv used_names : Map[(Int32, Int32), Map[String, Bool]]
  priv map_counts : Map[(Int32, Int32), UInt32]
  priv style : Compatibility
  priv signatures : Map[Int32, @types.FuncType]
  priv elses : Map[(Int32, Int32), Bool]
  priv hints : Map[(Int32, Int32), Bool]
  priv annotations : Map[(Int32, Int32), (String, Bytes)]
  priv named_functions : Array[Int32]
  priv mut type_values : ReadOnlyArray[@core_parser.FunctionTextTypes]
  priv local_values : Map[Int32, ReadOnlyArray[String]]
  priv instruction_values : Map[(Int32, Int32), ReadOnlyArray[String]]
  priv mut metadata_valid : Bool
}

///|
fn Names::empty(style : Compatibility, core_encoding~ : Bool = true) -> Names {
  {
    entries: Map([]),
    style,
    core_encoding,
    used_names: Map([]),
    map_counts: Map([]),
    signatures: Map([]),
    elses: Map([]),
    hints: Map([]),
    annotations: Map([]),
    named_functions: [],
    metadata_valid: true,
    type_values: [],
    local_values: Map([]),
    instruction_values: Map([]),
  }
}

///|
fn Names::core_key(self : Names, kind : Int32) -> Int32 {
  if self.core_encoding {
    return kind
  }
  match kind {
    0 => 0
    1 => 0x100
    4 => 0x110
    5 => 0x101
    6 => 0x102
    7 => 0x103
    11 => 0x104
    _ => 0x200 + kind
  }
}

///|
priv suberror MetadataError {
  MetadataError(Int32, String)
}

///|
priv struct MetadataReader {
  bytes : Bytes
  mut position : Int32
  base : Int32
}

///|
fn MetadataReader::byte(self : MetadataReader) -> Int32 raise MetadataError {
  guard self.position < self.bytes.length() else {
    raise MetadataError(self.base + self.position, "unexpected end-of-file")
  }
  let result = self.bytes[self.position].to_int()
  self.position += 1
  result
}

///|
fn MetadataReader::uint(self : MetadataReader) -> Int32 raise MetadataError {
  let mut value = 0
  for shift = 0; shift < 35; shift = shift + 7 {
    let byte = self.byte()
    if shift == 28 && byte > 15 {
      raise MetadataError(
        self.base + self.position - 1,
        "invalid var_u32: integer too large",
      )
    }
    value = value | ((byte & 127) << shift)
    if byte < 128 {
      return value
    }
  }
  raise MetadataError(
    self.base + self.position - 1,
    "invalid var_u32: integer representation too long",
  )
}

///|
fn MetadataReader::slice(
  self : MetadataReader,
  size : Int32,
) -> Bytes raise MetadataError {
  guard size >= 0 && size <= self.bytes.length() - self.position else {
    raise MetadataError(self.base + self.position, "unexpected end-of-file")
  }
  let start = self.position
  self.position += size
  self.bytes[start:self.position].to_owned()
}

///|
fn MetadataReader::string(self : MetadataReader) -> String raise MetadataError {
  let bytes = self.slice(self.uint())
  @utf8.decode(bytes) catch {
    _ =>
      raise MetadataError(
        self.base + self.position - bytes.length(),
        "invalid utf-8 sequence",
      )
  }
}

///|
fn metadata_reader(bytes : Bytes, base~ : Int32 = 0) -> MetadataReader {
  { bytes, position: 0, base, }
}

///|
fn MetadataReader::subreader(
  self : MetadataReader,
) -> MetadataReader raise MetadataError {
  let size = self.uint()
  let base = self.base + self.position
  metadata_reader(self.slice(size), base~)
}

///|
fn identifier_char(char : Char) -> Bool {
  let code = char.to_int()
  (code >= 48 && code <= 57) ||
  (code >= 65 && code <= 90) ||
  (code >= 97 && code <= 122) ||
  "!#$%&'*+-./:<=>?@\\^_`|~".contains(char.to_string())
}

///|
// Namespace names and duplicate/empty-name rules follow the pinned
// wasmprinter Naming policy. WABT's binary reader sanitizes invalid bytes.
fn Names::insert(
  self : Names,
  kind : Int32,
  scope : Int32,
  index : Int32,
  name : String,
  used : Map[String, Bool],
  name_group~ : String? = None,
  map_kind~ : Int32? = None,
) -> Unit {
  if self.style == Wabt && name.is_empty() {
    return
  }
  let group = name_group.unwrap_or(
    match kind {
      0 => "module"
      1 => "func"
      2 => "local"
      3 => "label"
      4 => "type"
      5 => "table"
      6 => "memory"
      7 => "global"
      8 => "elem"
      9 => "data"
      11 => "tag"
      12 => "parameter"
      13 => "tag parameter"
      _ => "unknown"
    },
  )
  let printed_index = index.reinterpret_as_uint().to_string()
  let naming = if self.style == WasmTools {
    let synthetic = name.is_empty() ||
      name.has_prefix("#") ||
      (kind != 3 && used.contains(name))
    used[name] = true
    let quoted = "\"\{compatible_string(name, self.style)}\""
    if synthetic {
      let identifier = "$\"#\{group}\{printed_index} \{compatible_string(name, self.style)}\""
      { identifier, declaration: "\{identifier} (@name \{quoted})", }
    } else {
      let identifier = if name.iter().all(identifier_char) {
        "$" + name
      } else {
        "$" + quoted
      }
      { identifier, declaration: identifier, }
    }
  } else {
    let out = StringBuilder()
    out.write_char('$')
    let mut unique = name
    let mut suffix = 1
    while used.contains(unique) {
      unique = "\{name}.\{suffix}"
      suffix += 1
    }
    used[unique] = true
    for byte in @utf8.encode(unique) {
      let char = byte.to_int().unsafe_to_char()
      out.write_char(
        if kind == 2 || identifier_char(char) {
          char
        } else {
          '_'
        },
      )
    }
    let identifier = out.to_string()
    { identifier, declaration: identifier, }
  }
  self.entries[(map_kind.unwrap_or(kind), scope, index)] = naming
}

///|
pub fn Names::reference(
  self : Names,
  kind : Int32,
  index : Int32,
  scope~ : Int32 = 0,
) -> String {
  self.entries
  .get((kind, scope, index))
  .map(n => n.identifier)
  .unwrap_or(index.to_string())
}

///|
pub fn Names::declaration(
  self : Names,
  kind : Int32,
  index : Int32,
  scope~ : Int32 = 0,
) -> String {
  match self.entries.get((kind, scope, index)) {
    Some(n) =>
      if self.style == WasmTools {
        "\{n.declaration} (;\{index};)"
      } else {
        n.declaration
      }
    None => "(;\{index};)"
  }
}

///|
fn Names::local_declaration(
  self : Names,
  kind : Int32,
  scope : Int32,
  index : Int32,
) -> String? {
  self.entries.get((kind, scope, index)).map(n => n.declaration)
}

///|
fn Names::read_map(
  self : Names,
  reader : MetadataReader,
  kind : Int32,
  scope : Int32,
) -> Unit raise MetadataError {
  let count = reader.uint().reinterpret_as_uint()
  let key = self.core_key(kind)
  self.map_counts[(key, scope)] = self.map_counts
    .get((key, scope))
    .map(previous => if previous > count { previous } else { count })
    .unwrap_or(count)
  let used = if self.style == Wabt {
    match self.used_names.get((key, scope)) {
      Some(used) => used
      None => {
        let used = Map([])
        self.used_names[(key, scope)] = used
        used
      }
    }
  } else {
    Map([])
  }
  let mut previous : UInt32? = None
  for remaining = count; remaining > 0U; remaining = remaining - 1U {
    let index = reader.uint()
    let unsigned = index.reinterpret_as_uint()
    if self.style == Wabt &&
      (kind == 1 || kind == 2) &&
      previous is Some(last) &&
      unsigned <= last {
      raise MetadataError(
        reader.base + reader.position,
        "name indices are not increasing",
      )
    }
    previous = Some(unsigned)
    if self.style == Wabt && kind == 1 {
      self.named_functions.push(index)
    }
    let name = reader.string()
    self.insert(kind, scope, index, name, used, map_kind=Some(key))
  }
}

///|
fn Names::read(self : Names, bytes : Bytes) -> Unit {
  let reader = metadata_reader(bytes)
  let mut previous_kind : UInt32? = None
  try {
    while reader.position < bytes.length() {
      let kind = if self.style == Wabt { reader.uint() } else { reader.byte() }
      if self.style == Wabt &&
        previous_kind is Some(last) &&
        kind.reinterpret_as_uint() <= last {
        raise MetadataError(
          reader.base + reader.position,
          "name subsections are not increasing",
        )
      }
      previous_kind = Some(kind.reinterpret_as_uint())
      let payload = reader.subreader()
      if self.style == Wabt &&
        (kind == 3 || kind >= 12 || payload.bytes.is_empty()) {
        continue
      }
      match kind {
        0 => {
          let name = payload.string()
          if payload.position != payload.bytes.length() {
            raise MetadataError(
              payload.base + payload.position,
              "trailing data at the end of a name",
            )
          }
          self.insert(0, 0, 0, name, Map([]))
        }
        2 | 3 | 12 | 13 => {
          let count = payload.uint().reinterpret_as_uint()
          let mut previous : UInt32? = None
          for remaining = count; remaining > 0U; remaining = remaining - 1U {
            let scope = payload.uint()
            if self.style == Wabt &&
              previous is Some(last) &&
              scope.reinterpret_as_uint() <= last {
              raise MetadataError(
                payload.base + payload.position,
                "local-name function indices are not increasing",
              )
            }
            previous = Some(scope.reinterpret_as_uint())
            self.read_map(payload, kind, scope)
          }
        }
        1 | 4 | 5 | 6 | 7 | 8 | 9 | 11 => self.read_map(payload, kind, 0)
        _ => ()
      }
      if self.style == Wabt &&
        [0, 1, 2].contains(kind) &&
        payload.position != payload.bytes.length() {
        raise MetadataError(
          payload.base + payload.position,
          "unfinished name subsection",
        )
      }
    }
  } catch {
    MetadataError(_, _) => self.metadata_valid = false
  }
}

///|
priv struct CustomSection {
  name : String
  data : Bytes
  after : Int32
  offset : Int32
}

///|
fn core_metadata(
  bytes : Bytes,
  style : Compatibility,
  base~ : Int32 = 0,
) -> (Names, Array[CustomSection]) {
  let names = Names::empty(style)
  let sections : Array[CustomSection] = []
  let reader = metadata_reader(bytes, base~)
  reader.position = 8
  let mut after = 0
  let mut saw_debug_names = false
  try {
    while reader.position < bytes.length() {
      let id = reader.byte()
      let payload = reader.slice(reader.uint())
      if id == 0 {
        let custom = metadata_reader(
          payload,
          base=reader.base + reader.position - payload.length(),
        )
        let name = custom.string()
        let data = payload[custom.position:].to_owned()
        if name == "name" {
          if style == WasmTools {
            names.read(data)
          }
          saw_debug_names = true
        }
        if name == "component-name" && style == WasmTools {
          names.read_component(data)
        }
        sections.push({
          name,
          data,
          after,
          offset: custom.base + custom.position,
        })
      } else if id == 8 {
        if style == Wabt && saw_debug_names {
          names.metadata_valid = false
        }
        after = id
      } else {
        if style == Wabt && saw_debug_names {
          names.metadata_valid = false
        }
        if id != 12 && metadata_reader(payload).uint() != 0 {
          after = id
        }
      }
    }
  } catch {
    MetadataError(_, _) => ()
  }
  (names, sections)
}

///|
pub extend Compatibility with Eq::{equal, not_equal}

///|
pub extend Compatibility with @debug.Debug::{to_repr}

///|
fn compatible_string(text : String, style : Compatibility) -> String {
  if style == Wabt {
    return escape_wat_string(text)
  }
  let out = StringBuilder()
  for char in text {
    let code = char.to_int()
    if code >= 0x20 && code < 0x7f && char != '\"' && char != '\\' {
      out.write_char(char)
    } else {
      out.write_string("\\u{\{code.to_string(radix=16)}}")
    }
  }
  out.to_string()
}

///|
/// The component's own name, without a numeric index comment.
pub fn Names::root_name(self : Names) -> String? {
  self.local_declaration(0, 0, 0)
}

///|
/// Read debug identifiers from a component-name section. The returned map has
/// private storage and exposes only immutable string lookups. Unknown or
/// malformed name subsections follow the pinned printer's best-effort policy.
pub fn component_names(bytes : Bytes) -> Names {
  let names = Names::empty(WasmTools, core_encoding=false)
  let (_, custom) = core_metadata(bytes, WasmTools)
  for section in custom {
    if section.name == "name" {
      names.read(section.data)
    }
    if section.name == "component-name" {
      names.read_component(section.data)
    }
  }
  names
}

///|
fn Names::read_component(self : Names, bytes : Bytes) -> Unit {
  let reader = metadata_reader(bytes)
  try {
    while reader.position < reader.bytes.length() {
      let id = reader.byte()
      let sub = reader.subreader()
      if id == 0 {
        let name = sub.string()
        if sub.position != sub.bytes.length() {
          raise MetadataError(
            sub.base + sub.position,
            "trailing data at the end of a name",
          )
        }
        self.insert(0, 0, 0, name, Map([]), name_group=Some("component"))
      } else if id == 1 {
        let sort = sub.byte()
        let key = if sort == 0 { 0x100 + sub.byte() } else { sort }
        let name_group = match key {
          1 => "func"
          2 => "value"
          3 => "type"
          4 => "component"
          5 => "instance"
          0x100 => "core-func"
          0x101 => "core-table"
          0x102 => "core-memory"
          0x103 => "core-global"
          0x104 => "core-tag"
          0x110 => "core-type"
          0x111 => "core-module"
          0x112 => "core-instance"
          _ => continue
        }
        let count = sub.uint().reinterpret_as_uint()
        let used = Map([])
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          let index = sub.uint()
          let store = if self.core_encoding {
            match key {
              0x100 => 1
              0x110 => 4
              0x101 => 5
              0x102 => 6
              0x103 => 7
              0x104 => 11
              _ => 0x200 + key
            }
          } else {
            key
          }
          self.insert(
            key,
            0,
            index,
            sub.string(),
            used,
            name_group=Some(name_group),
            map_kind=Some(store),
          )
        }
      }
    }
  } catch {
    MetadataError(_, _) => ()
  }
}

///|
/// Escape the contents of a UTF-8 WAT name under the pinned printer's rules.
pub fn compatibility_string(text : String, style : Compatibility) -> String {
  compatible_string(text, style)
}

///|
fn Names::read_hints(
  self : Names,
  sections : Array[CustomSection],
  offsets : ReadOnlyArray[ReadOnlyArray[Int32]],
  imported : Int32,
) -> Unit {
  if self.style != WasmTools {
    return
  }
  for section in sections {
    if section.name != "metadata.code.branch_hint" {
      continue
    }
    self.hints.clear()
    let reader = metadata_reader(section.data)
    let functions : Array[(Int32, Array[(Int32, Bool)])] = []
    try {
      let count = reader.uint().reinterpret_as_uint()
      for remaining = count; remaining > 0U; remaining = remaining - 1U {
        let func = reader.uint()
        let hints = []
        let count = reader.uint().reinterpret_as_uint()
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          let offset = reader.uint()
          if reader.byte() != 1 {
            raise MetadataError(
              reader.base + reader.position,
              "invalid branch hint",
            )
          }
          let taken = reader.byte()
          if taken > 1 {
            raise MetadataError(
              reader.base + reader.position,
              "invalid branch hint",
            )
          }
          hints.push((offset, taken == 1))
        }
        functions.push((func, hints))
      }
    } catch {
      MetadataError(_, _) => ()
    }
    let mut at = 0
    for local_index, positions in offsets {
      let func = imported + local_index
      if at >= functions.length() || functions[at].0 != func {
        continue
      }
      let hints = functions[at].1
      at += 1
      let mut hint = 0
      for ordinal, position in positions {
        if hint < hints.length() && hints[hint].0 == position {
          self.hints[(func, ordinal)] = hints[hint].1
          hint += 1
        }
      }
    }
  }
}

///|
/// Render a component-level custom section under wasm-tools conventions.
/// Name and branch-hint sections are represented elsewhere and return None.
pub fn component_custom_section(
  payload : Bytes,
  binary_offset~ : Int32 = 0,
) -> String? raise WatPrintError {
  let reader = metadata_reader(payload, base=binary_offset)
  let name = reader.string() catch { MetadataError(_, _) => return None }
  if name == "name" ||
    name == "component-name" ||
    name == "metadata.code.branch_hint" {
    return None
  }
  let data = payload[reader.position:].to_owned()
  let section = {
    name,
    data,
    after: -1,
    offset: reader.base + reader.position,
  }
  validate_reference_custom(section, WasmTools)
  let text = compatible_custom(section)
  Some(text.split("\n").map(line => line[2:].to_owned()).to_array().join("\n"))
}
