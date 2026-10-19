///|
// Retain object entry order and duplicates: serde rejects duplicate struct
// fields, while metadata StringMaps deliberately keep the last duplicate key.
priv enum MetadataNode {
  Object(ReadOnlyArray[(Int32, Int32)])
  Sequence(ReadOnlyArray[Int32])
  RawText(Bytes)
  Null
  Other
}

///|
priv struct MetadataFrame {
  object : Bool
  fields : Array[(Int32, Int32)]
  elements : Array[Int32]
  mut key : Int32?
  mut state : Int32
}

///|
priv struct MetadataJson {
  nodes : ReadOnlyArray[MetadataNode]
  root : Int32
}

///|
fn metadata_string_end(
  bytes : Bytes,
  start : Int32,
) -> Int32 raise EncodedFailure {
  let mut index = start + 1
  while index < bytes.length() {
    let byte = bytes[index].to_int()
    if byte == 34 {
      return index + 1
    }
    if byte < 32 {
      raise Invalid("unescaped control byte in metadata string")
    }
    if byte == 92 {
      index += 1
      guard index < bytes.length() else {
        raise Invalid("truncated metadata escape")
      }
      let escape = bytes[index].to_int()
      if escape == 117 {
        for _ in 0..<4 {
          index += 1
          guard index < bytes.length() else {
            raise Invalid("truncated metadata Unicode escape")
          }
          let digit = bytes[index].to_int()
          guard (digit >= 48 && digit <= 57) ||
            (digit >= 65 && digit <= 70) ||
            (digit >= 97 && digit <= 102) else {
            raise Invalid("invalid metadata Unicode escape")
          }
        }
      } else if ![34, 47, 92, 98, 102, 110, 114, 116].contains(escape) {
        raise Invalid("invalid metadata escape")
      }
    }
    index += 1
  }
  raise Invalid("unterminated metadata string")
}

///|
fn metadata_number(bytes : Bytes) -> Bool {
  let mut index = 0
  if bytes.length() > 0 && bytes[0] == b'-' {
    index += 1
  }
  if index >= bytes.length() {
    return false
  }
  if bytes[index] == b'0' {
    index += 1
  } else {
    if bytes[index] < b'1' || bytes[index] > b'9' {
      return false
    }
    while index < bytes.length() && bytes[index] >= b'0' && bytes[index] <= b'9' {
      index += 1
    }
  }
  if index < bytes.length() && bytes[index] == b'.' {
    index += 1
    let start = index
    while index < bytes.length() && bytes[index] >= b'0' && bytes[index] <= b'9' {
      index += 1
    }
    if index == start {
      return false
    }
  }
  if index < bytes.length() && (bytes[index] == b'e' || bytes[index] == b'E') {
    index += 1
    if index < bytes.length() && (bytes[index] == b'+' || bytes[index] == b'-') {
      index += 1
    }
    let start = index
    while index < bytes.length() && bytes[index] >= b'0' && bytes[index] <= b'9' {
      index += 1
    }
    if index == start {
      return false
    }
  }
  index == bytes.length()
}

///|
// Byte-oriented explicit frames match serde's IgnoredAny behavior: ignored
// stability extensions need not materialize numbers or decode string values.
fn metadata_json(bytes : Bytes) -> MetadataJson raise EncodedFailure {
  let nodes : Array[MetadataNode] = []
  let frames : Array[MetadataFrame] = []
  let mut root = -1
  let append = fn(node : MetadataNode) {
    let id = nodes.length()
    nodes.push(node)
    if frames.is_empty() {
      root = id
    } else {
      let frame = frames[frames.length() - 1]
      if frame.object {
        frame.fields.push((frame.key.unwrap(), id))
        frame.key = None
        frame.state = 3
      } else {
        frame.elements.push(id)
        frame.state = 1
      }
    }
  }
  let close = fn() {
    let frame = frames.pop().unwrap()
    append(
      if frame.object {
        Object(ReadOnlyArray::from_array(frame.fields))
      } else {
        Sequence(ReadOnlyArray::from_array(frame.elements))
      },
    )
  }
  let mut index = 0
  while index < bytes.length() {
    let byte = bytes[index].to_int()
    if [9, 10, 13, 32].contains(byte) {
      index += 1
      continue
    }
    if frames.is_empty() {
      guard root < 0 else { raise Invalid("trailing metadata JSON") }
    } else {
      let frame = frames[frames.length() - 1]
      if frame.object {
        if frame.state == 0 || frame.state == 4 {
          if byte == 125 && frame.state == 0 {
            close()
            index += 1
            continue
          }
          guard byte == 34 else {
            raise Invalid("metadata object needs a string key")
          }
          let end = metadata_string_end(bytes, index)
          frame.key = Some(nodes.length())
          nodes.push(RawText(bytes[index:end].to_owned()))
          frame.state = 1
          index = end
          continue
        } else if frame.state == 1 {
          guard byte == 58 else { raise Invalid("metadata key needs a colon") }
          frame.state = 2
          index += 1
          continue
        } else if frame.state == 3 {
          if byte == 125 {
            close()
            index += 1
            continue
          }
          guard byte == 44 else {
            raise Invalid("metadata object needs a comma")
          }
          frame.state = 4
          index += 1
          continue
        }
      } else if frame.state == 1 {
        if byte == 93 {
          close()
          index += 1
          continue
        }
        guard byte == 44 else { raise Invalid("metadata array needs a comma") }
        frame.state = 2
        index += 1
        continue
      } else if frame.state == 0 && byte == 93 {
        close()
        index += 1
        continue
      }
    }
    match byte {
      123 | 91 => {
        frames.push({
          object: byte == 123,
          fields: [],
          elements: [],
          key: None,
          state: 0,
        })
        index += 1
      }
      34 => {
        let end = metadata_string_end(bytes, index)
        append(RawText(bytes[index:end].to_owned()))
        index = end
      }
      _ => {
        let start = index
        while index < bytes.length() &&
              ![9, 10, 13, 32, 44, 125, 93].contains(bytes[index].to_int()) {
          index += 1
        }
        let value = bytes[start:index].to_owned()
        guard value == b"null" ||
          value == b"true" ||
          value == b"false" ||
          metadata_number(value) else {
          raise Invalid("invalid metadata JSON value")
        }
        append(if value == b"null" { Null } else { Other })
      }
    }
  }
  guard frames.is_empty() && root >= 0 else {
    raise Invalid("truncated metadata JSON")
  }
  { nodes: ReadOnlyArray::from_array(nodes), root, }
}

///|
fn MetadataJson::fields(
  self : MetadataJson,
  id : Int32,
  allowed : ReadOnlyArray[String],
  ignore_unknown~ : Bool = false,
  allow_sequence~ : Bool = true,
) -> Map[String, Int32] raise EncodedFailure {
  if allow_sequence && self.nodes[id] is Sequence(values) {
    guard values.length() <= allowed.length() else {
      raise Invalid("metadata struct sequence has extra elements")
    }
    let fields : Map[String, Int32] = Map([])
    for i, value in values {
      fields[allowed[i]] = value
    }
    return fields
  }
  guard self.nodes[id] is Object(entries) else {
    raise Invalid("metadata entry must be an object")
  }
  let fields : Map[String, Int32] = Map([])
  for (name, value) in entries {
    let name = self.string(name)
    if !allowed.contains(name) {
      if ignore_unknown {
        continue
      }
      raise Invalid("unknown metadata field `" + name + "`")
    }
    guard !fields.contains(name) else {
      raise Invalid("duplicate metadata field `" + name + "`")
    }
    fields[name] = value
  }
  fields
}

///|
fn MetadataJson::dictionary(
  self : MetadataJson,
  id : Int32,
) -> ReadOnlyArray[(String, Int32)] raise EncodedFailure {
  guard self.nodes[id] is Object(entries) else {
    raise Invalid("metadata dictionary must be an object")
  }
  let order = []
  let values : Map[String, Int32] = Map([])
  for (name, value) in entries {
    let name = self.string(name)
    if !values.contains(name) {
      order.push(name)
    }
    values[name] = value
  }
  ReadOnlyArray::from_array(order.map(name => (name, values[name])))
}

///|
fn MetadataJson::string(
  self : MetadataJson,
  id : Int32,
) -> String raise EncodedFailure {
  guard self.nodes[id] is RawText(bytes) else {
    raise Invalid("metadata value must be a string")
  }
  let text = @utf8.decode(bytes, ignore_bom=false) catch {
    _ => raise Invalid("invalid metadata UTF-8 string")
  }
  let value = @json.parse(text) catch {
    _ => raise Invalid("invalid metadata Unicode string")
  }
  guard value is String(value) else {
    raise Invalid("metadata value must be a string")
  }
  value
}

///|
fn MetadataJson::optional_string(
  self : MetadataJson,
  field : Int32?,
) -> String? raise EncodedFailure {
  match field {
    None => None
    Some(id) =>
      if self.nodes[id] is Null {
        None
      } else {
        Some(self.string(id))
      }
  }
}

///|
fn MetadataJson::stability(
  self : MetadataJson,
  field : Int32?,
) -> Stability raise EncodedFailure {
  guard field is Some(id) else { return Unknown }
  if self.nodes[id] is RawText(_) {
    guard self.string(id) == "unknown" else {
      raise Invalid("invalid stability variant")
    }
    return Unknown
  }
  guard self.nodes[id] is Object(entries) && entries.length() == 1 else {
    raise Invalid("invalid stability metadata")
  }
  let (kind, value) = entries[0]
  let kind = self.string(kind)
  if kind == "unknown" {
    guard self.nodes[value] is Null else {
      raise Invalid("unknown stability must be a unit value")
    }
    return Unknown
  }
  guard kind == "stable" || kind == "unstable" else {
    raise Invalid("unknown stability variant")
  }
  // Unlike the metadata structs, Stability's serde fields allow unknown keys.
  let allowed : ReadOnlyArray[String] = if kind == "stable" {
    ["since", "deprecated"]
  } else {
    ["feature", "deprecated"]
  }
  let fields = self.fields(value, allowed, ignore_unknown=true)
  let required = if kind == "stable" { "since" } else { "feature" }
  guard fields.get(required) is Some(required) else {
    raise Invalid("missing stability field")
  }
  let value = self.string(required)
  let deprecated = self.optional_string(fields.get("deprecated"))
  if kind == "stable" && !semantic_version(value) {
    raise Invalid("invalid stability version")
  }
  if deprecated is Some(version) && !semantic_version(version) {
    raise Invalid("invalid deprecation version")
  }
  if kind == "stable" {
    Stable(value, deprecated)
  } else {
    Unstable(value, deprecated)
  }
}

///|
priv enum MetadataAction {
  Package(Int32)
  Interface(Int32, Int32)
  World(Int32, Int32)
  Type(Int32, Int32)
  Function(Int32, Int32)
  InterfaceItem(Int32, Int32, Int32)
  ItemStability(Int32, Stability)
}

///|
fn metadata_function_nodes(
  tree : @ast.Tree,
  items : ReadOnlyArray[Int32],
) -> Map[String, Int32] {
  let result : Map[String, Int32] = Map([])
  for id in items {
    match tree.nodes[id].data {
      Function(name~, signature~, ..) =>
        result[signature_name(tree, signature, name)] = id
      Resource(methods~, ..) =>
        for member_id in methods {
          if resource_function_name(tree, id, member_id) is Some(name) {
            result[name] = member_id
          }
        }
      _ => ()
    }
  }
  result
}

///|
fn metadata_types(
  tree : @ast.Tree,
  items : ReadOnlyArray[Int32],
) -> Map[String, Int32] {
  let result : Map[String, Int32] = Map([])
  for id in items {
    if type_declaration(tree.nodes[id].data) &&
      declaration(tree.nodes[id].data) is Some(name) {
      result[name] = id
    }
    if tree.nodes[id].data is Use(names~, ..) {
      for selector in names {
        if tree.nodes[selector].data is Rename(name~, renamed~) {
          result[renamed.unwrap_or(name)] = selector
        }
      }
    }
  }
  result
}

///|
fn metadata_target(
  name : String,
  targets : Map[String, Int32],
) -> Int32 raise EncodedFailure {
  guard targets.get(name) is Some(id) else {
    raise Invalid("metadata refers to missing item `" + name + "`")
  }
  id
}

///|
fn metadata_attach(
  tree : @ast.Tree,
  values : Map[Int32, Stability],
  id : Int32,
  value : Stability,
) -> Unit {
  values[id] = value
  match tree.nodes[id].data {
    Function(signature~, ..) => values[signature] = value
    Import(target~, ..) | Export(target~, ..) =>
      if tree.nodes[target].data is Signature(..) {
        values[target] = value
      }
    _ => ()
  }
}

///|
fn metadata_world_entries(
  tree : @ast.Tree,
  items : ReadOnlyArray[Int32],
  imported : Bool,
  functions : Bool,
  identity : PackageIdentity,
) -> Map[String, Int32] {
  let result : Map[String, Int32] = Map([])
  for id in items {
    let (name, target) = match tree.nodes[id].data {
      Import(name~, target~, ..) if imported => (name, target)
      Export(name~, target~, ..) if !imported => (name, target)
      _ => continue
    }
    if functions {
      if name is Some(name) && tree.nodes[target].data is Signature(..) {
        result[signature_name(tree, target, name)] = id
      }
    } else if !(tree.nodes[target].data is Signature(..)) {
      if name is Some(name) {
        result[name] = id
      } else if tree.nodes[target].data is Path(segments~, ..) &&
        segments.length() == 1 {
        result[qualified_item(identity, segments[0])] = id
      }
    }
  }
  result
}

///|
fn metadata_read(
  bytes : Bytes,
  input : SourcePackage,
) -> Map[Int32, Stability] raise EncodedFailure {
  let json = metadata_json(bytes)
  metadata_schema(json)
  let tree = input.documents[0].ast
  let identity = input.identity().unwrap()
  let interfaces : Map[String, Int32] = Map([])
  let worlds : Map[String, Int32] = Map([])
  for id in section_items(tree.nodes[tree.nodes.length() - 1].data) {
    match tree.nodes[id].data {
      @ast.Interface(name~, ..) => interfaces[name] = id
      @ast.World(name~, ..) => worlds[name] = id
      _ => ()
    }
  }
  let values : Map[Int32, Stability] = Map([])
  let actions : Array[MetadataAction] = [Package(json.root)]
  while actions.pop() is Some(action) {
    match action {
      Package(meta) => {
        let fields = json.fields(meta, ["docs", "worlds", "interfaces"])
        ignore(json.optional_string(fields.get("docs")))
        // Stack order preserves upstream world injection before interface injection.
        for (field, is_interface) in [("interfaces", true), ("worlds", false)] {
          if fields.get(field) is Some(entries) {
            let entries = json.dictionary(entries)
            for i = entries.length() - 1; i >= 0; i = i - 1 {
              let (name, meta) = entries[i]
              actions.push(
                if is_interface {
                  Interface(metadata_target(name, interfaces), meta)
                } else {
                  World(metadata_target(name, worlds), meta)
                },
              )
            }
          }
        }
      }
      Interface(id, meta) => {
        let fields = json.fields(meta, ["docs", "stability", "funcs", "types"])
        ignore(json.optional_string(fields.get("docs")))
        metadata_attach(
          tree,
          values,
          id,
          json.stability(fields.get("stability")),
        )
        guard tree.nodes[id].data is @ast.Interface(items~, ..) else {
          raise Invalid("interface metadata target has wrong kind")
        }
        for (field, is_function) in [("funcs", true), ("types", false)] {
          if fields.get(field) is Some(entries) {
            let targets = if is_function {
              metadata_function_nodes(tree, items)
            } else {
              metadata_types(tree, items)
            }
            let entries = json.dictionary(entries)
            for i = entries.length() - 1; i >= 0; i = i - 1 {
              let (name, meta) = entries[i]
              let target = metadata_target(name, targets)
              actions.push(
                if is_function {
                  Function(target, meta)
                } else {
                  Type(target, meta)
                },
              )
            }
          }
        }
      }
      Function(id, meta) =>
        match json.nodes[meta] {
          RawText(_) => ignore(json.string(meta)) // v0 doc-only form does not replace stability.
          Null => ()
          _ => {
            let fields = json.fields(
              meta,
              ["docs", "stability"],
              allow_sequence=false,
            )
            ignore(json.optional_string(fields.get("docs")))
            metadata_attach(
              tree,
              values,
              id,
              json.stability(fields.get("stability")),
            )
          }
        }
      Type(id, meta) => {
        let fields = json.fields(meta, ["docs", "stability", "items"])
        ignore(json.optional_string(fields.get("docs")))
        metadata_attach(
          tree,
          values,
          id,
          json.stability(fields.get("stability")),
        )
        if fields.get("items") is Some(entries) {
          let entries = json.dictionary(entries)
          if !entries.is_empty() {
            let children = match tree.nodes[id].data {
              Record(fields~, ..) => fields
              Variant(cases~, ..) | Flags(cases~, ..) | Enum(cases~, ..) =>
                cases
              _ => raise Invalid("metadata items require an aggregate type")
            }
            let names : Map[String, Bool] = Map([])
            for child in children {
              match tree.nodes[child].data {
                Field(name~, ..) | Case(name~, ..) => names[name] = true
                _ => ()
              }
            }
            for (name, value) in entries {
              guard names.contains(name) else {
                raise Invalid("metadata refers to missing aggregate item")
              }
              ignore(json.string(value))
            }
          }
        }
      }
      InterfaceItem(item, target, meta) => {
        let fields = json.fields(meta, ["docs", "stability", "funcs", "types"])
        metadata_attach(
          tree,
          values,
          item,
          json.stability(fields.get("stability")),
        )
        actions.push(Interface(target, meta))
      }
      ItemStability(item, value) => metadata_attach(tree, values, item, value)
      World(id, meta) => {
        let fields = json.fields(meta, [
          "docs", "stability", "interfaces", "types", "funcs", "interface_exports",
          "func_exports", "interface_import_stability", "interface_export_stability",
          "interface_import_docs", "interface_export_docs",
        ])
        ignore(json.optional_string(fields.get("docs")))
        metadata_attach(
          tree,
          values,
          id,
          json.stability(fields.get("stability")),
        )
        guard tree.nodes[id].data is @ast.World(items~, ..) else {
          raise Invalid("world metadata target has wrong kind")
        }
        let queued : Array[MetadataAction] = []
        for
          (field, only_export) in [
            ("interfaces", false),
            ("interface_exports", true),
          ] {
          if fields.get(field) is Some(entries) {
            let imports = metadata_world_entries(
              tree, items, true, false, identity,
            )
            let exports = metadata_world_entries(
              tree, items, false, false, identity,
            )
            for (name, meta) in json.dictionary(entries) {
              let target = if !only_export && imports.contains(name) {
                imports[name]
              } else {
                metadata_target(name, exports)
              }
              let target_id = match tree.nodes[target].data {
                Import(target~, ..) | Export(target~, ..) => target
                _ => raise Invalid("invalid interface metadata target")
              }
              guard tree.nodes[target_id].data is @ast.Interface(..) else {
                raise Invalid(
                  "inline interface metadata requires a named world item",
                )
              }
              queued.push(InterfaceItem(target, target_id, meta))
            }
          }
        }
        if fields.get("types") is Some(entries) {
          let targets = metadata_types(tree, items)
          for (name, meta) in json.dictionary(entries) {
            queued.push(Type(metadata_target(name, targets), meta))
          }
        }
        for
          (field, imported, docs) in [
            ("interface_import_stability", true, false),
            ("interface_export_stability", false, false),
            ("interface_import_docs", true, true),
            ("interface_export_docs", false, true),
          ] {
          if fields.get(field) is Some(entries) {
            let targets = metadata_world_entries(
              tree, items, imported, false, identity,
            )
            for (name, meta) in json.dictionary(entries) {
              let target = metadata_target(name, targets)
              if docs {
                ignore(json.string(meta))
              } else {
                queued.push(ItemStability(target, json.stability(Some(meta))))
              }
            }
          }
        }
        for (field, only_export) in [("funcs", false), ("func_exports", true)] {
          if fields.get(field) is Some(entries) {
            let imports = metadata_world_entries(
              tree, items, true, true, identity,
            )
            let exports = metadata_world_entries(
              tree, items, false, true, identity,
            )
            for (name, meta) in json.dictionary(entries) {
              let target = if !only_export && imports.contains(name) {
                imports[name]
              } else {
                metadata_target(name, exports)
              }
              queued.push(Function(target, meta))
            }
          }
        }
        for i = queued.length() - 1; i >= 0; i = i - 1 {
          actions.push(queued[i])
        }
      }
    }
  }
  values
}

///|
priv enum MetadataSchema {
  PackageSchema
  WorldSchema
  InterfaceSchema
  TypeSchema
  FunctionSchema
  StabilitySchema
  StringSchema
}

///|
// Deserialize every dictionary value before applying last-key-wins injection.
// An overwritten value can still contain a schema error, as in serde IndexMap.
fn metadata_schema(json : MetadataJson) -> Unit raise EncodedFailure {
  let pending : Array[(MetadataSchema, Int32)] = [(PackageSchema, json.root)]
  let dictionary = fn(
    field : Int32?,
    schema : MetadataSchema,
  ) raise EncodedFailure {
    if field is Some(id) {
      guard json.nodes[id] is Object(entries) else {
        raise Invalid("metadata dictionary must be an object")
      }
      for (name, value) in entries {
        ignore(json.string(name))
        pending.push((schema, value))
      }
    }
  }
  while pending.pop() is Some((schema, id)) {
    match schema {
      StringSchema => ignore(json.string(id))
      StabilitySchema => ignore(json.stability(Some(id)))
      FunctionSchema if json.nodes[id] is RawText(_) => ignore(json.string(id))
      FunctionSchema if json.nodes[id] is Null => ()
      _ => {
        let allowed : ReadOnlyArray[String] = match schema {
          PackageSchema => ["docs", "worlds", "interfaces"]
          WorldSchema =>
            [
              "docs", "stability", "interfaces", "types", "funcs", "interface_exports",
              "func_exports", "interface_import_stability", "interface_export_stability",
              "interface_import_docs", "interface_export_docs",
            ]
          InterfaceSchema => ["docs", "stability", "funcs", "types"]
          TypeSchema => ["docs", "stability", "items"]
          FunctionSchema => ["docs", "stability"]
          _ => []
        }
        let fields = json.fields(
          id,
          allowed,
          allow_sequence=!(schema is FunctionSchema),
        )
        ignore(json.optional_string(fields.get("docs")))
        if !(schema is PackageSchema) {
          ignore(json.stability(fields.get("stability")))
        }
        match schema {
          PackageSchema => {
            dictionary(fields.get("worlds"), WorldSchema)
            dictionary(fields.get("interfaces"), InterfaceSchema)
          }
          WorldSchema => {
            for name in ["interfaces", "interface_exports"] {
              dictionary(fields.get(name), InterfaceSchema)
            }
            dictionary(fields.get("types"), TypeSchema)
            for name in ["funcs", "func_exports"] {
              dictionary(fields.get(name), FunctionSchema)
            }
            for
              name in [
                "interface_import_stability", "interface_export_stability",
              ] {
              dictionary(fields.get(name), StabilitySchema)
            }
            for name in ["interface_import_docs", "interface_export_docs"] {
              dictionary(fields.get(name), StringSchema)
            }
          }
          InterfaceSchema => {
            dictionary(fields.get("types"), TypeSchema)
            dictionary(fields.get("funcs"), FunctionSchema)
          }
          TypeSchema => dictionary(fields.get("items"), StringSchema)
          _ => ()
        }
      }
    }
  }
}
