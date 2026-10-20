///|
pub(all) enum BinaryKind {
  Component
  CoreModule
} derive(Eq, Debug)

///|
/// One physical binary definition. Component contracts refer to `types` in
/// the inventory. Core contracts contain their own complete signatures.
pub struct Entry {
  id : String
  parent : String?
  kind : BinaryKind
  name : String?
  export_names : ReadOnlyArray[String]
  world : Int32?
  core : @core_types.Module?
}

///|
/// An immutable preorder inventory, including the root. Graph references are
/// indices, not nested mutable trees. No WAT or I/O is needed to build it.
pub struct Inventory {
  entries : ReadOnlyArray[Entry]
  types : ReadOnlyArray[@verifier.ResolvedType]
}

///|
pub struct Diagnostic {
  source : String
  code : String
  message : String
}

///|
priv suberror Failure {
  Failure(String, String)
}

///|
fn[T] reject(message : String) -> T raise Failure {
  raise Failure("WAC-D003", message)
}

///|
priv struct Snapshot {
  entry : Entry
  bytes : Bytes
  parsed : @component.ComponentBinary?
  scope : @verifier.ComponentScope?
  pure : Bool
}

///|
priv struct Inspection {
  inventory : Inventory
  snapshots : Array[Snapshot]
  validated : @binary.ValidatedDeclarativeComponent?
}

///|
fn text(bytes : Bytes) -> String {
  @utf8.decode_lossy(bytes)
}

///|
fn external_name(name : @component.ExportName) -> String {
  match name {
    Plain(bytes) => text(bytes)
    WithVersion(name, version) => text(name) + "@" + text(version)
  }
}

///|
fn imported_name(name : @component.ImportName) -> String {
  match name {
    Plain(bytes) => text(bytes)
    WithVersion(name, version) => text(name) + "@" + text(version)
  }
}

///|
fn sort(sort : @component.Sort) -> Int32 {
  match sort {
    Core(tag) => 0x100 + tag
    Func => 1
    Value => 2
    Type => 3
    Component => 4
    Instance => 5
  }
}

///|
fn desc_sort(desc : @component.ExternDesc) -> Int32 {
  match desc {
    CoreModuleType(_) => 0x111
    FuncType(_) => 1
    Value(_) => 2
    Type(_) => 3
    ComponentType(_) => 4
    InstanceType(_) => 5
  }
}

///|
// Keep names readable, but encode bytes outside lowercase ASCII. A binary
// index and kind suffix disambiguate even equal and case-folded names.
fn slug(name : String) -> String {
  let out = StringBuilder()
  for byte in @utf8.encode(name) {
    let c = byte.to_int()
    if (c >= 97 && c <= 122) || (c >= 48 && c <= 57) {
      out.write_char(c.unsafe_to_char())
    } else {
      let hex = "0123456789abcdef"
      out.write_string("x")
      out.write_char(hex[(c >> 4) & 15].to_int().unsafe_to_char())
      out.write_char(hex[c & 15].to_int().unsafe_to_char())
    }
  }
  out.to_string()
}

///|
fn identifier(
  parent : String,
  name : String?,
  kind : String,
  index : Int32,
) -> String {
  let prefix = match name {
    Some(name) if !name.is_empty() => slug(name) + "-"
    _ => ""
  }
  parent + "/" + prefix + kind + "-n" + index.to_string()
}

///|
fn read_u32(bytes : Bytes, position : Ref[Int32]) -> Int32? {
  let mut value = 0
  let mut shift = 0
  while position.val < bytes.length() && shift < 35 {
    let byte = bytes[position.val].to_int()
    position.val += 1
    value = value | ((byte & 127) << shift)
    if byte < 128 {
      return Some(value)
    }
    shift += 7
  }
  None
}

///|
fn read_name(bytes : Bytes, position : Ref[Int32]) -> String? {
  guard read_u32(bytes, position) is Some(size) &&
    size >= 0 &&
    size <= bytes.length() - position.val else {
    return None
  }
  let name = text(bytes[position.val:position.val + size].to_owned())
  position.val += size
  Some(name)
}

///|
// Custom name metadata is optional. Malformed name payloads have no effect on
// validation or IDs; never index them without checking their local bounds.
fn binary_name(bytes : Bytes, component : Bool) -> String? {
  let position = Ref(8)
  while position.val < bytes.length() {
    let id = bytes[position.val].to_int()
    position.val += 1
    guard read_u32(bytes, position) is Some(size) &&
      size >= 0 &&
      size <= bytes.length() - position.val else {
      return None
    }
    let end = position.val + size
    if id == 0 {
      let payload = bytes[position.val:end].to_owned()
      let p = Ref(0)
      if read_name(payload, p) ==
        Some(if component { "component-name" } else { "name" }) {
        while p.val < payload.length() {
          let sub = payload[p.val].to_int()
          p.val += 1
          guard read_u32(payload, p) is Some(length) &&
            length >= 0 &&
            length <= payload.length() - p.val else {
            break
          }
          if sub == 0 {
            let body = payload[p.val:p.val + length].to_owned()
            return read_name(body, Ref(0))
          }
          p.val += length
        }
      }
    }
    position.val = end
  }
  None
}

///|
fn core_contract(bytes : Bytes) -> @core_types.Module raise Failure {
  let metadata = match @core_types.inspect_module(bytes) {
    Ok(metadata) => metadata
    Err(error) => raise Failure("WAC-D001", error.message)
  }
  let module_ = @core_parser.parse_module(bytes) catch {
    error => raise Failure("WAC-D001", error.to_string())
  }
  @core_validation.validate_module(module_) catch {
    error =>
      raise Failure("WAC-D002", @core_validation.format_validation_error(error))
  }
  metadata.contract
}

///|
fn inspect(bytes : Bytes, source : String) -> Inspection raise Failure {
  if @component.sniff_binary_kind(bytes) != Some(Component) {
    let core = core_contract(bytes)
    let entry : Entry = {
      id: "root",
      parent: None,
      kind: CoreModule,
      name: binary_name(bytes, false),
      export_names: [],
      world: None,
      core: Some(core),
    }
    return {
      validated: None,
      inventory: { entries: [entry], types: [], },
      snapshots: [{ entry, bytes, parsed: None, scope: None, pure: false, }],
    }
  }
  let model = match
    @verifier.decode_component_package(bytes, source_id=source) {
    Ok(model) => model
    Err(errors) => raise Failure("WAC-D001", errors[0].message)
  }
  let validated = @binary.validate_declarative_component(bytes).unwrap()
  let scopes : Map[Int32, @verifier.ComponentScope] = Map([])
  for scope in model.components() {
    scopes[scope.world] = scope
  }
  let root = scopes[model.world()]
  let snapshots : Array[Snapshot] = []
  let pending : Array[
    (
      Bytes,
      Bytes,
      @verifier.ComponentScope?,
      String,
      String?,
      ReadOnlyArray[String],
    ),
  ] = [(bytes, validated.parser_bytes(), Some(root), "root", None, [])]
  while pending.pop()
        is Some((raw, parser_bytes, scope, id, parent, export_names)) {
    guard scope is Some(scope) else {
      let entry : Entry = {
        id,
        parent,
        kind: CoreModule,
        name: binary_name(raw, false),
        export_names,
        world: None,
        core: Some(core_contract(raw)),
      }
      snapshots.push({
        entry,
        bytes: raw,
        parsed: None,
        scope: None,
        pure: false,
      })
      continue
    }
    let parsed = @component.parse_component_binary(parser_bytes) catch {
      error => raise Failure("WAC-D001", error.to_string())
    }
    let original = @component.parse_component_binary(raw) catch {
      error => raise Failure("WAC-D001", error.to_string())
    }
    let entry : Entry = {
      id,
      parent,
      kind: Component,
      name: binary_name(raw, true),
      export_names,
      world: Some(scope.world),
      core: None,
    }
    let children : Array[(Bytes, Bytes, Int32, Int32)] = []
    let exported : Map[(Int32, Int32), Array[String]] = Map([])
    let counts : Map[Int32, Int32] = Map([])
    let take = fn(key : Int32) {
      let n = counts.get(key).unwrap_or(0)
      counts[key] = n + 1
      n
    }
    let mut pure = true
    for i, section in parsed.sections {
      match section.id {
        0 => ()
        1 => {
          pure = false
          children.push(
            (original.sections[i].payload, section.payload, 0x111, take(0x111)),
          )
        }
        4 =>
          children.push(
            (original.sections[i].payload, section.payload, 4, take(4)),
          )
        6 => {
          let aliases = @component.parse_alias_section(section.payload) catch {
            error => raise Failure("WAC-D001", error.to_string())
          }
          for entry in aliases {
            if entry.sort is Core(_) {
              pure = false
            }
            ignore(take(sort(entry.sort)))
          }
        }
        10 => {
          let imports = @component.parse_import_section(section.payload) catch {
            error => raise Failure("WAC-D001", error.to_string())
          }
          for imported in imports {
            ignore(take(desc_sort(imported.desc)))
          }
        }
        11 => {
          let exports = @component.parse_export_section(section.payload) catch {
            error => raise Failure("WAC-D001", error.to_string())
          }
          for item in exports {
            let key = (sort(item.sortidx.sort), item.sortidx.idx)
            let names = exported.get(key).unwrap_or([])
            names.push(external_name(item.name))
            exported[key] = names
            // Exports bind a new index as well as naming their target.
            let next = take(key.0)
            exported[(key.0, next)] = names
          }
        }
        7 => {
          let definitions = @type_parser.parse_type_section(section.payload) catch {
            error => raise Failure("WAC-D001", error.to_string())
          }
          if definitions.any(definition => definition is ResourceType(_)) {
            pure = false
          }
        }
        2 | 3 | 8 | 9 => pure = false
        _ => ()
      }
    }
    snapshots.push({
      entry,
      bytes: raw,
      parsed: Some(parsed),
      scope: Some(scope),
      pure,
    })
    // A single explicit stack preserves physical preorder, including modules.
    for i = children.length() - 1; i >= 0; i = i - 1 {
      let (raw, parser_bytes, kind, index) = children[i]
      let names = ReadOnlyArray::from_array(
        exported.get((kind, index)).unwrap_or([]).copy(),
      )
      let name = match names.get(0) {
        Some(name) => Some(name)
        None => binary_name(raw, kind == 4)
      }
      let child_id = identifier(
        id,
        name,
        if kind == 4 {
          "component"
        } else {
          "module"
        },
        index,
      )
      if kind == 4 {
        guard scopes.get(scope.components[index]) is Some(child) else {
          reject("nested component scope is missing")
        }
        pending.push(
          (raw, parser_bytes, Some(child), child_id, Some(id), names),
        )
      } else {
        pending.push((raw, parser_bytes, None, child_id, Some(id), names))
      }
    }
  }
  {
    inventory: {
      entries: ReadOnlyArray::from_array(snapshots.map(s => s.entry)),
      types: model.types(),
    },
    snapshots,
    validated: Some(validated),
  }
}

///|
/// Inspect a validated binary without printing WAT, executing it or doing I/O.
pub fn inventory(
  bytes : Bytes,
  source_id~ : String = "<wasm>",
) -> Result[Inventory, ReadOnlyArray[Diagnostic]] {
  Ok(inspect(bytes, source_id).inventory) catch {
    Failure(code, message) => Err([{ source: source_id, code, message, }])
  }
}

///|
pub extend BinaryKind with Eq::{equal, not_equal}

///|
pub extend BinaryKind with @debug.Debug::{to_repr}
