///|
priv suberror EncodedFailure {
  Unsupported(String)
  Invalid(String)
}

///|
priv enum EncodedSlot {
  Definition(@component.TypeDef)
  Named(String)
  Imported(String, String)
  Unavailable
}

///|
fn encoded_name(name : String) -> String raise EncodedFailure {
  guard identifier(name) else {
    raise Invalid("invalid WIT name `" + name + "`")
  }
  "%" + name
}

///|
fn encoded_primitive(value : @component.PrimValType) -> String {
  match value {
    Bool => "bool"
    S8 => "s8"
    U8 => "u8"
    S16 => "s16"
    U16 => "u16"
    S32 => "s32"
    U32 => "u32"
    S64 => "s64"
    U64 => "u64"
    F32 => "f32"
    F64 => "f64"
    Char => "char"
    String => "string"
    ErrorContext => "error-context"
  }
}

///|
fn encoded_slot(
  slots : Array[EncodedSlot],
  index : Int32,
) -> EncodedSlot raise EncodedFailure {
  guard index >= 0 && index < slots.length() else {
    raise Invalid("WIT type index is outside its scope")
  }
  slots[index]
}

///|
priv enum EncodedExpr {
  Value(@component.ValType)
  Definition(@component.TypeDef)
  Text(String)
  Leave(Int32)
}

///|
// This lowering is private compiler input, never an original source document.
// Explicit frames also bound expansion when a compact binary shares a DAG.
fn encoded_expression(
  slots : Array[EncodedSlot],
  value : @component.ValType,
) -> String raise EncodedFailure {
  let work : Array[EncodedExpr] = [Value(value)]
  let active : Map[Int32, Bool] = Map([])
  let out = StringBuilder()
  let mut steps = 0
  while !work.is_empty() {
    steps += 1
    guard steps <= 1000000 else {
      raise Unsupported("expanded WIT type exceeds the decoding work limit")
    }
    match work.pop().unwrap() {
      Text(text) => out.write_string(text)
      Leave(index) => active.remove(index) |> ignore
      Value(Prim(primitive)) => out.write_string(encoded_primitive(primitive))
      Value(TypeIdx(index)) =>
        match encoded_slot(slots, index) {
          Named(name) => out.write_string(encoded_name(name))
          Imported(_, _) | Unavailable =>
            raise Unsupported("type requires a named local use declaration")
          Definition(definition) => {
            guard !active.contains(index) else {
              raise Invalid("cyclic WIT type")
            }
            active[index] = true
            work.push(Leave(index))
            work.push(Definition(definition))
          }
        }
      Definition(definition) => {
        let (head, arguments, tail) : (String, Array[EncodedExpr], String) = match
          definition {
          DefValType(primitive) => (encoded_primitive(primitive), [], "")
          List(value) => ("list<", [Value(value)], ">")
          FixedList(value, length) =>
            ("list<", [Value(value), Text(", \{length}")], ">")
          MapType(key, value) =>
            ("map<", [Value(key), Text(","), Value(value)], ">")
          Tuple(values) => {
            let args = []
            for i, value in values {
              if i > 0 {
                args.push(Text(","))
              }
              args.push(Value(value))
            }
            ("tuple<", args, ">")
          }
          Option(value) => ("option<", [Value(value)], ">")
          Result(ok, error) =>
            match (ok, error) {
              (None, None) => ("result", [], "")
              (Some(value), None) => ("result<", [Value(value)], ">")
              (None, Some(value)) => ("result<_,", [Value(value)], ">")
              (Some(ok), Some(error)) =>
                ("result<", [Value(ok), Text(","), Value(error)], ">")
            }
          Future(value) | Stream(value) => {
            let name = if definition is Future(_) { "future" } else { "stream" }
            match value {
              None => (name, [], "")
              Some(value) => (name + "<", [Value(value)], ">")
            }
          }
          Own(index) | Borrow(index) => {
            let name = if definition is Own(_) { "own" } else { "borrow" }
            guard encoded_slot(slots, index) is Named(resource) else {
              raise Unsupported("unnamed resource handle")
            }
            (name + "<" + encoded_name(resource) + ">", [], "")
          }
          _ => raise Unsupported("anonymous structural or non-value WIT type")
        }
        out.write_string(head)
        work.push(Text(tail))
        for i = arguments.length() - 1; i >= 0; i = i - 1 {
          work.push(arguments[i])
        }
      }
    }
  }
  out.to_string()
}

///|
fn encoded_type(
  slots : Array[EncodedSlot],
  name : String,
  index : Int32,
) -> String raise EncodedFailure {
  let label = encoded_name(name)
  match encoded_slot(slots, index) {
    Named(previous) => "type " + label + "=" + encoded_name(previous) + ";"
    Imported(owner, original) =>
      "use " +
      encoded_name(owner) +
      ".{" +
      encoded_name(original) +
      (if original == name { "" } else { " as " + label }) +
      "};"
    Unavailable =>
      raise Unsupported("unnamed resource or scope used as a value type")
    Definition(definition) =>
      match definition {
        Record(fields) => {
          let out = StringBuilder()
          out.write_string("record " + label + "{")
          for field in fields {
            out.write_string(
              encoded_name(field.label) +
              ":" +
              encoded_expression(slots, field.ty) +
              ",",
            )
          }
          out.write_string("}")
          out.to_string()
        }
        Flags(names) | Enum(names) => {
          let out = StringBuilder()
          out.write_string(
            (if definition is Flags(_) { "flags " } else { "enum " }) +
            label +
            "{",
          )
          for name in names {
            out.write_string(encoded_name(name) + ",")
          }
          out.write_string("}")
          out.to_string()
        }
        Variant(cases) => {
          let out = StringBuilder()
          out.write_string("variant " + label + "{")
          for case in cases {
            out.write_string(encoded_name(case.label))
            if case.ty is Some(value) {
              out.write_string("(" + encoded_expression(slots, value) + ")")
            }
            out.write_string(",")
          }
          out.write_string("}")
          out.to_string()
        }
        _ =>
          "type " +
          label +
          "=" +
          encoded_expression(slots, TypeIdx(index)) +
          ";"
      }
  }
}

///|
fn encoded_function(
  slots : Array[EncodedSlot],
  name : String,
  index : Int32,
) -> (String?, String) raise EncodedFailure {
  guard encoded_slot(slots, index) is Definition(FuncType(function)) else {
    raise Invalid("WIT function export does not reference a function type")
  }
  let is_constructor = name.has_prefix("[constructor]")
  let is_method = name.has_prefix("[method]")
  let is_static = name.has_prefix("[static]")
  let rest = if is_constructor {
    name[13:].to_owned()
  } else if is_method || is_static {
    name[8:].to_owned()
  } else {
    name
  }
  let getter = rest.has_prefix("[get]")
  let setter = rest.has_prefix("[set]")
  let rest = if getter || setter { rest[5:].to_owned() } else { rest }
  let (resource, local_name) : (String?, String) = if is_constructor {
    (Some(rest), "")
  } else if is_method || is_static {
    let parts = rest.split(".").to_array()
    guard parts.length() == 2 else {
      raise Invalid("invalid resource function name")
    }
    (Some(parts[0].to_owned()), parts[1].to_owned())
  } else {
    (None, rest)
  }
  if resource is Some(name) {
    ignore(encoded_name(name))
  }
  let out = StringBuilder()
  if is_constructor {
    guard !function.is_async && !getter && !setter else {
      raise Invalid("invalid constructor flavor")
    }
    out.write_string("constructor")
  } else {
    out.write_string(encoded_name(local_name) + ":")
    if is_static {
      out.write_string("static ")
    }
    if function.is_async {
      out.write_string("async ")
    }
    out.write_string(
      if getter {
        "get"
      } else if setter {
        "set"
      } else {
        "func"
      },
    )
  }
  out.write_string("(")
  let first = if is_method { 1 } else { 0 }
  if is_method &&
    (function.params.is_empty() || function.params[0].label != "self") {
    raise Invalid("resource method is missing its self parameter")
  }
  // The component naming rule uses the most recently exported resource name.
  // A nominally equal resource alias cannot keep an older method receiver name.
  if is_method &&
    function.params[0].ty is TypeIdx(handle) &&
    encoded_slot(slots, handle) is Definition(Borrow(target)) &&
    encoded_slot(slots, target) is Named(receiver) &&
    resource != Some(receiver) {
    raise Invalid("method receiver uses a different exported resource name")
  }
  for i in first..<function.params.length() {
    if i > first {
      out.write_string(",")
    }
    let parameter = function.params[i]
    out.write_string(
      encoded_name(parameter.label) +
      ":" +
      encoded_expression(slots, parameter.ty),
    )
  }
  out.write_string(")")
  if function.result is Some(result) {
    out.write_string("->" + encoded_expression(slots, result))
  }
  out.write_string(";")
  (resource, out.to_string())
}

///|
priv enum EncodedInterfaceItem {
  ItemText(String)
  Resource(String)
}

///|
fn encoded_qualified(
  name : String,
) -> (PackageIdentity, String) raise EncodedFailure {
  let pieces = name.split("/").to_array()
  guard pieces.length() == 2 else {
    raise Invalid("expected fully qualified WIT package member")
  }
  let package_parts = pieces[0].split(":").to_array()
  let member_parts = pieces[1].split("@").to_array()
  guard package_parts.length() == 2 &&
    member_parts.length() <= 2 &&
    identifier(package_parts[0].to_owned()) &&
    identifier(package_parts[1].to_owned()) &&
    identifier(member_parts[0].to_owned()) else {
    raise Invalid("invalid WIT package identity")
  }
  let version = if member_parts.length() == 2 {
    Some(member_parts[1].to_owned())
  } else {
    None
  }
  if version is Some(version) && !semantic_version(version) {
    raise Invalid("invalid WIT package version")
  }
  (
    {
      namespace_name: package_parts[0].to_owned(),
      name: package_parts[1].to_owned(),
      version,
    },
    member_parts[0].to_owned(),
  )
}

///|
// Consume v1 package wrappers and v2 member wrappers. Root export names identify
// the encoding; v2 member names come from each wrapper's qualified inner export.
fn lower_encoded(
  component : @component.Component,
) -> (String, Bytes?) raise EncodedFailure {
  let declarations : Array[@component.ComponentDecl] = []
  let mut metadata : Bytes? = None
  for section in component.binary.sections {
    match section.id {
      0 => {
        let bytes = section.payload
        let mut index = 0
        let mut length = 0
        let mut shift = 0
        while index < bytes.length() {
          let byte = bytes[index].to_int()
          index += 1
          length = length | ((byte & 127) << shift)
          if byte < 128 {
            break
          }
          shift += 7
        }
        let name = @utf8.decode(
          bytes[index:index + length].to_owned(),
          ignore_bom=false,
        ) catch {
          _ => raise Invalid("invalid custom section name")
        }
        index += length
        if name == "package-docs" {
          guard metadata is None else {
            raise Invalid("duplicate package-docs section")
          }
          guard index < bytes.length() &&
            (bytes[index] == b'\x00' || bytes[index] == b'\x01') else {
            raise Unsupported("package-docs metadata version")
          }
          metadata = Some(bytes[index + 1:].to_owned())
        }
      }
      7 => {
        let definitions = @component.parse_type_section(section.payload) catch {
          _ => raise Invalid("invalid component type section")
        }
        for definition in definitions {
          declarations.push(Type(definition))
        }
      }
      11 => {
        let exports = @component.parse_export_section(section.payload) catch {
          _ => raise Invalid("invalid component export section")
        }
        for item in exports {
          guard item.attributes.is_empty() &&
            item.desc is None &&
            item.sortidx.sort == Type else {
            raise Unsupported(
              "package export attributes, ascription or non-type sort",
            )
          }
          let name = match item.name {
            Plain(bytes) =>
              @utf8.decode(bytes, ignore_bom=false) catch {
                _ => raise Invalid("invalid package export name")
              }
            _ => raise Unsupported("versioned package export name")
          }
          declarations.push(Export(name, [], Type(Eq(item.sortidx.idx))))
        }
      }
      _ => raise Unsupported("non-type package section")
    }
  }
  let graph = encoded_graph(ComponentType(declarations))
  let roots = graph.scopes[0].items
  guard !roots.is_empty() else {
    raise Invalid("component contains no WIT package exports")
  }
  let mut identity : PackageIdentity? = None
  let mut v1 = false
  let members : Array[(String, String, Int32, Bool)] = []
  let wrappers : Map[Int32, Int32] = Map([])
  let member_order : Map[Int32, Int32] = Map([])
  for i, root in roots {
    guard root is TypeItem(name, id, false) else {
      raise Invalid("invalid package root export")
    }
    if i == 0 {
      if name.contains("/") {
        let (owner, member_name) = encoded_qualified(name)
        guard member_name == "wit" else {
          raise Invalid("unrecognized WIT package export name")
        }
        identity = Some(owner)
        v1 = true
      } else {
        guard identifier(name) else {
          raise Invalid("expected a bare v2 package export name")
        }
      }
    } else if v1 {
      raise Invalid("v1 package requires exactly one root export")
    }
    guard graph.nodes[id] is Link(target) &&
      graph.nodes[target] is Scope(wrapper) else {
      raise Invalid("package member lacks a component type wrapper")
    }
    guard !graph.scopes[wrapper].interface_scope else {
      raise Invalid("package wrapper is not a component type")
    }
    wrappers[wrapper] = if v1 { -1 } else { members.length() }
    let mut exported = 0
    for item in graph.scopes[wrapper].items {
      match item {
        InstanceItem(full, scope, false) | WorldItem(full, scope) => {
          exported += 1
          guard v1 || exported == 1 else {
            raise Unsupported("v2 wrapper must export exactly one member")
          }
          let (owner, member_name) = encoded_qualified(full)
          if identity is None {
            identity = Some(owner)
          }
          guard v1 || identity == Some(owner) else {
            raise Invalid("conflicting WIT package member identity")
          }
          guard !member_order.contains(scope) else {
            raise Invalid(
              "one encoded scope cannot define multiple package members",
            )
          }
          member_order[scope] = members.length()
          members.push((member_name, full, scope, item is WorldItem(_, _)))
        }
        InstanceItem(_, _, true) => ()
        _ => raise Unsupported("non-interface wrapper import or export")
      }
    }
    guard v1 || exported == 1 else {
      raise Invalid("empty WIT package member wrapper")
    }
  }
  guard identity is Some(identity) else {
    raise Invalid("missing encoded package identity")
  }
  let interfaces : Map[String, Int32] = Map([])
  let interface_names : Map[String, String] = Map([])
  let names : Map[String, Bool] = Map([])
  let owners : Map[Int32, (String, String)] = Map([])
  for (name, full, scope, world) in members {
    guard !names.contains(name) else {
      raise Invalid("conflicting WIT package member identity")
    }
    names[name] = true
    if !world {
      interfaces[full] = scope
      interface_names[full] = name
      for item in graph.scopes[scope].items {
        if item is TypeItem(member_name, id, _) {
          owners[id] = (name, member_name)
        }
      }
    }
  }
  encoded_graph_imports(graph, interfaces, wrappers, member_order)
  let out = StringBuilder()
  out.write_string(
    "package " +
    encoded_name(identity.namespace_name) +
    ":" +
    encoded_name(identity.name),
  )
  if identity.version is Some(version) {
    out.write_string("@" + version)
  }
  out.write_string(";")
  for (name, _, scope, world) in members {
    let body = if world {
      encoded_graph_world(graph, scope, owners, interface_names)
    } else {
      encoded_graph_interface(graph, scope, owners)
    }
    out.write_string(
      (if world { "world " } else { "interface " }) +
      encoded_name(name) +
      "{" +
      body +
      "}",
    )
  }
  (out.to_string(), metadata)
}
