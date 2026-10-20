///|
// wasmparser 0.262.0 bounds every component value's memory64 ABI size below
// 2^28. The portable validator does not enforce that bound, so check it here.
// Scope and alias processing uses explicit frames, including exported type slots.
priv struct Layout {
  size : Int64
  alignment : Int32
}

///|
priv enum LayoutType {
  Value(Layout)
  Instance(Int32)
  Other
}

///|
priv struct LayoutScope {
  declarations : Array[@component.ComponentDecl]
  outers : Array[Int32]
  types : Array[LayoutType]
  instances : Array[Int32]
  exports : Map[String, LayoutType]
  mut position : Int32
}

///|
fn LayoutScope::new(
  declarations : Array[@component.ComponentDecl],
  outers : Array[Int32],
) -> LayoutScope {
  {
    declarations,
    outers,
    types: [],
    instances: [],
    exports: Map([]),
    position: 0,
  }
}

///|
fn layout_error(message : String) -> Unit raise Boundary {
  raise Failure(None, "WIT-B003", message)
}

///|
fn layout_type(scope : LayoutScope, index : Int32) -> LayoutType raise Boundary {
  guard index >= 0 && index < scope.types.length() else {
    layout_error("component layout type index is outside its scope")
    return Other
  }
  scope.types[index]
}

///|
fn layout_primitive(primitive : @component.PrimValType) -> Layout {
  let size = match primitive {
    Bool | U8 | S8 => 1
    U16 | S16 => 2
    U32 | S32 | F32 | Char | ErrorContext => 4
    U64 | S64 | F64 => 8
    String => 16
  }
  { size: size.to_int64(), alignment: if size > 8 { 8 } else { size }, }
}

///|
fn layout_value(
  scope : LayoutScope,
  value : @component.ValType,
) -> Layout raise Boundary {
  match value {
    Prim(primitive) => layout_primitive(primitive)
    TypeIdx(index) =>
      match layout_type(scope, index) {
        Value(layout) => layout
        _ => {
          layout_error("non-value component type in value layout")
          { size: 0, alignment: 1, }
        }
      }
  }
}

///|
fn layout_align(size : Int64, alignment : Int32) -> Int64 {
  let alignment = alignment.to_int64()
  (size + alignment - 1) / alignment * alignment
}

///|
fn layout_checked(size : Int64, alignment : Int32) -> Layout raise Boundary {
  if size >= 268435456L {
    layout_error(
      "value type maximum in-memory size reaches the component limit of 2^28 bytes",
    )
  }
  { size, alignment, }
}

///|
fn layout_record(
  scope : LayoutScope,
  values : Array[@component.ValType],
) -> Layout raise Boundary {
  let mut size = 0L
  let mut alignment = 1
  for value in values {
    let field = layout_value(scope, value)
    size = layout_align(size, field.alignment) + field.size
    alignment = alignment.max(field.alignment)
    ignore(layout_checked(size, alignment))
  }
  layout_checked(layout_align(size, alignment), alignment)
}

///|
fn layout_variant(
  scope : LayoutScope,
  values : Array[@component.ValType?],
) -> Layout raise Boundary {
  let tag = if values.length() <= 256 {
    1
  } else if values.length() <= 65536 {
    2
  } else {
    4
  }
  let mut payload_size = 0L
  let mut payload_alignment = 1
  for value in values {
    if value is Some(value) {
      let payload = layout_value(scope, value)
      payload_size = payload_size.max(payload.size)
      payload_alignment = payload_alignment.max(payload.alignment)
    }
  }
  let alignment = payload_alignment.max(tag)
  layout_checked(
    layout_align(
      layout_align(tag.to_int64(), payload_alignment) + payload_size,
      alignment,
    ),
    alignment,
  )
}

///|
fn layout_definition(
  scope : LayoutScope,
  definition : @component.TypeDef,
) -> LayoutType raise Boundary {
  let layout = match definition {
    DefValType(primitive) => layout_primitive(primitive)
    Own(_) | Borrow(_) | Future(_) | Stream(_) => { size: 4, alignment: 4, }
    List(_) | MapType(_, _) => { size: 16, alignment: 8, }
    FixedList(element, length) => {
      if length <= 0 || length > 1073741824 {
        layout_error(
          "fixed-length list element count must be between 1 and 1073741824",
        )
      }
      let element = layout_value(scope, element)
      layout_checked(element.size * length.to_int64(), element.alignment)
    }
    Record(fields) => {
      if fields.length() > 10000 {
        layout_error("component record exceeds 10000 fields")
      }
      layout_record(scope, fields.map(field => field.ty))
    }
    Tuple(elements) => {
      if elements.length() > 10000 {
        layout_error("component tuple exceeds 10000 elements")
      }
      layout_record(scope, elements)
    }
    Variant(cases) => {
      if cases.length() > 10000 {
        layout_error("component variant exceeds 10000 cases")
      }
      layout_variant(scope, cases.map(case => case.ty))
    }
    Option(value) => layout_variant(scope, [None, Some(value)])
    Result(ok, error) => layout_variant(scope, [ok, error])
    Flags(names) => {
      let size = if names.length() <= 8 {
        1
      } else if names.length() <= 16 {
        2
      } else {
        4
      }
      { size: size.to_int64(), alignment: size, }
    }
    Enum(names) => {
      if names.length() > 10000 {
        layout_error("component enum exceeds 10000 cases")
      }
      let size = if names.length() <= 256 {
        1
      } else if names.length() <= 65536 {
        2
      } else {
        4
      }
      { size: size.to_int64(), alignment: size, }
    }
    _ => return Other
  }
  Value(layout)
}

///|
fn layout_external(
  scope : LayoutScope,
  name : String,
  description : @component.ExternDesc,
  exported : Bool,
) -> Unit raise Boundary {
  match description {
    Type(bound) => {
      let kind = match bound {
        Eq(index) => layout_type(scope, index)
        SubResource => Other
      }
      scope.types.push(kind)
      if exported {
        scope.exports[name] = kind
      }
    }
    InstanceType(index) =>
      if layout_type(scope, index) is Instance(instance_scope) {
        scope.instances.push(instance_scope)
      } else {
        layout_error("instance type lacks component layout scope")
      }
    _ => ()
  }
}

///|
fn validate_layouts(component : @component.Component) -> Unit raise Boundary {
  let declarations : Array[@component.ComponentDecl] = []
  for section in component.binary.sections {
    if section.id == 7 {
      let types = @type_parser.parse_type_section(section.payload) catch {
        _ => {
          layout_error("invalid component layout type section")
          []
        }
      }
      for definition in types {
        declarations.push(Type(definition))
      }
    } else if section.id == 11 {
      let exports = @component.parse_export_section(section.payload) catch {
        _ => {
          layout_error("invalid component layout export section")
          []
        }
      }
      for item in exports {
        if item.sortidx.sort == Type {
          declarations.push(Export("", [], Type(Eq(item.sortidx.idx))))
        }
      }
    }
  }
  let scopes = [LayoutScope::new(declarations, [])]
  let work = [0]
  while !work.is_empty() {
    let scope_index = work[work.length() - 1]
    let scope = scopes[scope_index]
    if scope.position == scope.declarations.length() {
      ignore(work.pop())
      continue
    }
    let declaration = scope.declarations[scope.position]
    scope.position += 1
    match declaration {
      Type(definition) => {
        let nested : LayoutScope? = match definition {
          ComponentType(declarations) =>
            Some(LayoutScope::new(declarations, [scope_index] + scope.outers))
          InstanceType(declarations) => {
            let converted : Array[@component.ComponentDecl] = declarations.map(declaration => {
              match declaration {
                CoreType(bytes) => CoreType(bytes)
                Type(definition) => Type(definition)
                AliasOuter(kind, count, index) => AliasOuter(kind, count, index)
                AliasInstanceExport(kind, instance_index, name) =>
                  AliasInstanceExport(kind, instance_index, name)
                Export(name, attributes, description) =>
                  Export(name, attributes, description)
              }
            })
            Some(LayoutScope::new(converted, [scope_index] + scope.outers))
          }
          InstanceTypeEmpty =>
            Some(LayoutScope::new([], [scope_index] + scope.outers))
          _ => None
        }
        if nested is Some(nested) {
          let nested_index = scopes.length()
          scopes.push(nested)
          scope.types.push(
            if definition is ComponentType(_) {
              Other
            } else {
              Instance(nested_index)
            },
          )
          work.push(nested_index)
        } else {
          scope.types.push(layout_definition(scope, definition))
        }
      }
      AliasOuter(kind, count, index) =>
        if kind == 3 {
          if count == 0 {
            scope.types.push(layout_type(scope, index))
          } else if count < 0 || count > scope.outers.length() {
            layout_error("invalid outer type layout depth")
          } else {
            scope.types.push(
              layout_type(scopes[scope.outers[count - 1]], index),
            )
          }
        }
      AliasInstanceExport(kind, instance_index, name) =>
        if kind == 3 {
          if instance_index < 0 || instance_index >= scope.instances.length() {
            layout_error("invalid instance layout index")
          } else {
            match scopes[scope.instances[instance_index]].exports.get(name) {
              Some(kind) => scope.types.push(kind)
              None => layout_error("missing instance type layout export")
            }
          }
        }
      Import(name, _, description) =>
        layout_external(scope, name, description, false)
      Export(name, _, description) =>
        layout_external(scope, name, description, true)
      CoreType(_) => ()
    }
  }
}
