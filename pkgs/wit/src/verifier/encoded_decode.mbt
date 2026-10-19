///|
priv suberror EncodedFailure {
  Unsupported(String)
  Invalid(String)
}

///|
priv enum EncodedSlot {
  Definition(@component.TypeDef)
  Named(String)
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
fn encoded_interface(
  definition : @component.TypeDef,
) -> String raise EncodedFailure {
  let declarations = match definition {
    InstanceType(declarations) => declarations
    InstanceTypeEmpty => []
    _ => raise Invalid("WIT interface is not an instance type")
  }
  let slots : Array[EncodedSlot] = []
  let items : Array[EncodedInterfaceItem] = []
  let resources : Map[String, Array[String]] = Map([])
  for declaration in declarations {
    match declaration {
      Type(definition) => slots.push(Definition(definition))
      Export(name, attributes, description) => {
        guard attributes.is_empty() else {
          raise Unsupported("interface export name attributes")
        }
        match description {
          Type(Eq(index)) => {
            items.push(ItemText(encoded_type(slots, name, index)))
            slots.push(Named(name))
          }
          Type(SubResource) => {
            guard !resources.contains(name) else {
              raise Invalid("duplicate resource name")
            }
            resources[name] = []
            items.push(Resource(name))
            slots.push(Named(name))
          }
          FuncType(index) => {
            let (resource, text) = encoded_function(slots, name, index)
            match resource {
              None => items.push(ItemText(text))
              Some(resource) =>
                match resources.get(resource) {
                  Some(methods) => methods.push(text)
                  None =>
                    raise Invalid("resource function names an unknown resource")
                }
            }
          }
          _ => raise Unsupported("non-WIT interface export")
        }
      }
      _ => raise Unsupported("interface type aliases or core declarations")
    }
  }
  let out = StringBuilder()
  for item in items {
    match item {
      ItemText(text) => out.write_string(text)
      Resource(name) => {
        out.write_string("resource " + encoded_name(name) + "{")
        for text in resources[name] {
          out.write_string(text)
        }
        out.write_string("}")
      }
    }
  }
  out.to_string()
}

///|
fn encoded_definition(
  slots : Array[@component.TypeDef],
  index : Int32,
) -> @component.TypeDef raise EncodedFailure {
  guard index >= 0 && index < slots.length() else {
    raise Invalid("component type index is outside its scope")
  }
  slots[index]
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
fn encoded_world(
  definition : @component.TypeDef,
  identity : PackageIdentity,
  interfaces : Map[String, String],
) -> String raise EncodedFailure {
  guard definition is ComponentType(declarations) else {
    raise Invalid("WIT world is not a component type")
  }
  let slots : Array[@component.TypeDef] = []
  let out = StringBuilder()
  for declaration in declarations {
    match declaration {
      Type(definition) => slots.push(definition)
      Import(name, attributes, description)
      | Export(name, attributes, description) => {
        guard attributes.is_empty() else {
          raise Unsupported("world name attributes")
        }
        out.write_string(
          if declaration is Import(_, _, _) {
            "import "
          } else {
            "export "
          },
        )
        match description {
          InstanceType(index) => {
            let body = encoded_interface(encoded_definition(slots, index))
            if name.contains("/") {
              let (owner, member_name) = encoded_qualified(name)
              guard owner == identity &&
                interfaces.get(member_name) == Some(body) else {
                raise Unsupported(
                  "world interface requires foreign or nonidentical interface reconstruction",
                )
              }
              out.write_string(encoded_name(member_name) + ";")
            } else {
              out.write_string(encoded_name(name) + ":interface{" + body + "}")
            }
          }
          FuncType(index) => {
            let type_slots = slots.map(definition => {
              EncodedSlot::Definition(definition)
            })
            let (resource, text) = encoded_function(type_slots, name, index)
            guard resource is None else {
              raise Unsupported("world-owned resource functions")
            }
            out.write_string(text)
          }
          _ => raise Unsupported("world item other than a function or instance")
        }
      }
      _ => raise Unsupported("world type alias or core declaration")
    }
  }
  out.to_string()
}

///|
// The first supported package profile is the v2 type-wrapper encoding. Every
// export is consumed; unsupported identities, metadata and edges fail closed.
fn lower_encoded(
  component : @component.Component,
) -> String raise EncodedFailure {
  let slots : Array[@component.TypeDef] = []
  let members : Array[(String, String, @component.TypeDef)] = []
  let mut metadata_seen = false
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
          guard !metadata_seen else {
            raise Invalid("duplicate package-docs section")
          }
          metadata_seen = true
          guard index < bytes.length() && bytes[index] == b'\x01' else {
            raise Unsupported("package-docs metadata version")
          }
          let text = @utf8.decode(
            bytes[index + 1:].to_owned(),
            ignore_bom=false,
          ) catch {
            _ => raise Invalid("invalid package-docs UTF-8")
          }
          guard text
            .replace(old=" ", new="")
            .replace(old="\n", new="")
            .replace(old="\r", new="")
            .replace(old="\t", new="") ==
            "{}" else {
            raise Unsupported("nonempty package-docs metadata")
          }
        }
      }
      7 => {
        let definitions = @component.parse_type_section(section.payload) catch {
          _ => raise Invalid("invalid component type section")
        }
        slots.append(definitions)
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
          let definition = encoded_definition(slots, item.sortidx.idx)
          guard definition is ComponentType(declarations) else {
            raise Invalid("package member lacks a component type wrapper")
          }
          let nested : Array[@component.TypeDef] = []
          let mut exported = false
          for declaration in declarations {
            match declaration {
              Type(definition) => nested.push(definition)
              Export(full_name, attributes, description) => {
                guard !exported && attributes.is_empty() else {
                  raise Unsupported(
                    "wrapper must have exactly one unannotated export",
                  )
                }
                exported = true
                match description {
                  InstanceType(index) =>
                    members.push(
                      (name, full_name, encoded_definition(nested, index)),
                    )
                  ComponentType(index) =>
                    members.push(
                      (name, full_name, encoded_definition(nested, index)),
                    )
                  _ =>
                    raise Invalid("wrapper export is not an interface or world")
                }
              }
              _ => raise Unsupported("wrapper imports or aliases")
            }
          }
          guard exported else {
            raise Invalid("empty WIT package member wrapper")
          }
          // Root type exports introduce a new alias in the component type space.
          slots.push(definition)
        }
      }
      _ => raise Unsupported("non-type package section")
    }
  }
  guard !members.is_empty() else {
    raise Invalid("component contains no WIT package exports")
  }
  let (identity, _) = encoded_qualified(members[0].1)
  let interfaces : Map[String, String] = Map([])
  let names : Map[String, Bool] = Map([])
  for (name, full_name, definition) in members {
    let (owner, member_name) = encoded_qualified(full_name)
    guard identity == owner && name == member_name && !names.contains(name) else {
      raise Invalid("conflicting WIT package member identity")
    }
    names[name] = true
    if definition is InstanceType(_) || definition is InstanceTypeEmpty {
      interfaces[name] = encoded_interface(definition)
    }
  }
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
  for (name, _, definition) in members {
    if interfaces.get(name) is Some(body) {
      out.write_string("interface " + encoded_name(name) + "{" + body + "}")
    } else {
      out.write_string(
        "world " +
        encoded_name(name) +
        "{" +
        encoded_world(definition, identity, interfaces) +
        "}",
      )
    }
  }
  out.to_string()
}
