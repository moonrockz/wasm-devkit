///|
priv enum BinaryDeclaration {
  Canonical(@component.Canon)
  RuntimeInstance(@component.Instance)
  Define(@component.TypeDef)
  CoreDefine(Bytes, Bool)
  CoreModule(Bytes)
  ConcreteComponent(Bytes)
  Alias(@component.Alias)
  Describe(Bool, String, Array[@component.NameAttribute], @component.ExternDesc)
  Export(@component.Export)
  Start(@component.Start)
}

///|
priv struct BinaryScope {
  parent : Int32?
  owner : Int32
  interface_scope : Bool
  concrete : Bool
  component_index : Int32
  declarations : Array[BinaryDeclaration]
  types : Array[Int32]
  functions : Array[Int32]
  values : Array[Int32]
  instances : Array[Int32]
  components : Array[Int32]
  modules : Array[Int32]
  core_types : Array[@core_types.Definition]
  core_ids : Array[Int32?]
  imports : Array[Extern]
  exports : Array[Extern]
  uses : Array[UsedType]
  resources : Array[Int32]
}

///|
priv struct BinaryGraph {
  location : Location
  mut remaining : Int32
  types : Array[ResolvedType]
  scopes : Array[BinaryScope]
  primitives : Map[String, Int32]
  bound_resources : Map[Int32, Array[Int32]]
  owners : Map[Int32, (Int32, String)]
  implements_names : Map[Int32, Map[String, String]]
}

///|
fn BinaryGraph::step(self : BinaryGraph) -> Unit raise BinaryFailure {
  guard self.remaining > 0 else {
    raise Unsupported("component type graph exceeds the decoding work limit")
  }
  self.remaining -= 1
}

///|
fn BinaryGraph::add(
  self : BinaryGraph,
  kind : TypeKind,
  name~ : String? = None,
) -> Int32 raise BinaryFailure {
  self.step()
  let id = self.types.length()
  self.types.push({ id, name, kind, location: self.location, })
  id
}

///|
fn binary_index(
  values : Array[Int32],
  index : Int32,
) -> Int32 raise BinaryFailure {
  guard index >= 0 && index < values.length() else {
    raise Invalid("component index is outside its declared scope")
  }
  values[index]
}

///|
fn BinaryGraph::follow(
  self : BinaryGraph,
  id : Int32,
) -> Int32 raise BinaryFailure {
  let mut id = id
  for _ in 0..<self.types.length() {
    self.step()
    guard id >= 0 && id < self.types.length() else {
      raise Invalid("component type reference is out of bounds")
    }
    match self.types[id].kind {
      Alias(next) => id = next
      _ => return id
    }
  }
  raise Invalid("cyclic component type alias")
}

///|
fn binary_kind_id(kind : ItemKind) -> Int32 {
  match kind {
    Type(id)
    | Function(id)
    | Instance(id)
    | Component(id)
    | Module(id)
    | Value(id) => id
  }
}

///|
fn binary_kind_with_id(kind : ItemKind, id : Int32) -> ItemKind {
  match kind {
    Type(_) => Type(id)
    Function(_) => Function(id)
    Instance(_) => Instance(id)
    Component(_) => Component(id)
    Module(_) => Module(id)
    Value(_) => Value(id)
  }
}

///|
fn binary_sort(kind : Int32) -> @component.Sort raise BinaryFailure {
  match kind {
    0x110 => Core(0x10)
    0x111 => Core(0x11)
    1 => Func
    2 => Value
    3 => Type
    4 => Component
    5 => Instance
    _ =>
      raise Unsupported(
        "core aliases are outside the declarative package profile",
      )
  }
}

///|
fn BinaryScope::bind(self : BinaryScope, kind : ItemKind) -> Unit {
  match kind {
    Type(id) => self.types.push(id)
    Function(id) => self.functions.push(id)
    Instance(id) => self.instances.push(id)
    Component(id) => self.components.push(id)
    Module(id) => self.modules.push(id)
    Value(id) => self.values.push(id)
  }
}

///|
fn BinaryScope::lookup(
  self : BinaryScope,
  sort : @component.Sort,
  index : Int32,
) -> ItemKind raise BinaryFailure {
  match sort {
    Type => Type(binary_index(self.types, index))
    Func => Function(binary_index(self.functions, index))
    Instance => Instance(binary_index(self.instances, index))
    Component => Component(binary_index(self.components, index))
    Value => Value(binary_index(self.values, index))
    Core(0x11) => Module(binary_index(self.modules, index))
    Core(_) =>
      raise Unsupported(
        "core items are outside the declarative package profile",
      )
  }
}

///|
fn binary_text(bytes : Bytes) -> String raise BinaryFailure {
  @utf8.decode(bytes) catch {
    _ => raise Invalid("invalid component name encoding")
  }
}

///|
fn binary_import_name(
  name : @component.ImportName,
) -> String raise BinaryFailure {
  match name {
    Plain(bytes) => binary_text(bytes)
    WithVersion(name, version) => binary_text(name) + "@" + binary_text(version)
  }
}

///|
fn binary_export_name(
  name : @component.ExportName,
) -> String raise BinaryFailure {
  match name {
    Plain(bytes) => binary_text(bytes)
    WithVersion(name, version) => binary_text(name) + "@" + binary_text(version)
  }
}

///|
fn binary_declarations(
  definition : @component.TypeDef,
) -> Array[BinaryDeclaration] raise BinaryFailure {
  let declarations : Array[@component.ComponentDecl] = match definition {
    ComponentType(declarations) => declarations
    InstanceType(declarations) =>
      declarations.map(decl => {
        match decl {
          Type(value) => @component.ComponentDecl::Type(value)
          CoreType(bytes) => CoreType(bytes)
          AliasOuter(kind, count, index) => AliasOuter(kind, count, index)
          AliasInstanceExport(kind, instance, name) =>
            AliasInstanceExport(kind, instance, name)
          Export(name, attrs, desc) => Export(name, attrs, desc)
        }
      })
    InstanceTypeEmpty => []
    _ => raise Invalid("expected a component or instance type")
  }
  let result = []
  for decl in declarations {
    result.push(
      match decl {
        Type(value) => BinaryDeclaration::Define(value)
        AliasOuter(kind, count, index) =>
          Alias({ sort: binary_sort(kind), target: Outer(count, index), })
        AliasInstanceExport(kind, instance, name) =>
          Alias({ sort: binary_sort(kind), target: Export(instance, name), })
        Import(name, attrs, desc) => Describe(true, name, attrs, desc)
        Export(name, attrs, desc) => Describe(false, name, attrs, desc)
        CoreType(bytes) => CoreDefine(bytes, false)
      },
    )
  }
  result
}

///|
fn BinaryGraph::scope(
  self : BinaryGraph,
  parent : Int32?,
  declarations : Array[BinaryDeclaration],
  interface_scope : Bool,
  concrete~ : Bool = false,
) -> Int32 raise BinaryFailure {
  let owner = self.add(
    if interface_scope {
      Interface(None, [], [])
    } else {
      World(None, [], [], [])
    },
  )
  let id = self.scopes.length()
  self.scopes.push({
    parent,
    owner,
    interface_scope,
    concrete,
    component_index: match parent {
      Some(parent) => self.scopes[parent].components.length()
      None => 0
    },
    declarations,
    types: [],
    functions: [],
    values: [],
    instances: [],
    components: [],
    modules: [],
    core_types: [],
    core_ids: [],
    imports: [],
    exports: [],
    uses: [],
    resources: [],
  })
  id
}

///|
fn BinaryGraph::primitive(
  self : BinaryGraph,
  value : @component.PrimValType,
) -> Int32 raise BinaryFailure {
  let name = match value {
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
  match self.primitives.get(name) {
    Some(id) => id
    None => {
      let id = self.add(Scalar(name))
      self.primitives[name] = id
      id
    }
  }
}

///|
fn BinaryGraph::value(
  self : BinaryGraph,
  scope : BinaryScope,
  value : @component.ValType,
) -> Int32 raise BinaryFailure {
  match value {
    Prim(value) => self.primitive(value)
    TypeIdx(index) => binary_index(scope.types, index)
  }
}

///|
fn BinaryGraph::optional_value(
  self : BinaryGraph,
  scope : BinaryScope,
  value : @component.ValType?,
) -> Int32? raise BinaryFailure {
  match value {
    None => None
    Some(value) => Some(self.value(scope, value))
  }
}

///|
fn BinaryGraph::definition(
  self : BinaryGraph,
  scope : BinaryScope,
  definition : @component.TypeDef,
) -> Int32 raise BinaryFailure {
  let kind : TypeKind = match definition {
    DefValType(primitive) => Alias(self.primitive(primitive))
    List(value) => List(self.value(scope, value))
    FixedList(value, length) => FixedList(self.value(scope, value), length)
    MapType(key, value) => Map(self.value(scope, key), self.value(scope, value))
    Tuple(values) => {
      let types = []
      for value in values {
        types.push(self.value(scope, value))
      }
      Tuple(ReadOnlyArray::from_array(types))
    }
    Option(value) => Option(self.value(scope, value))
    Result(ok, error) =>
      Result(self.optional_value(scope, ok), self.optional_value(scope, error))
    Future(value) => Future(self.optional_value(scope, value))
    Stream(value) => Stream(self.optional_value(scope, value))
    Own(index) => Own(binary_index(scope.types, index))
    Borrow(index) => Borrow(binary_index(scope.types, index))
    Record(fields) => {
      let members = []
      for field in fields {
        members.push({
          name: field.label,
          ty: self.value(scope, field.ty),
          location: self.location,
        })
      }
      Record(ReadOnlyArray::from_array(members))
    }
    Variant(cases) => {
      let members = []
      for case in cases {
        members.push({
          name: case.label,
          payload: self.optional_value(scope, case.ty),
          location: self.location,
        })
      }
      Variant(ReadOnlyArray::from_array(members))
    }
    Flags(names) => Flags(ReadOnlyArray::from_array(names.copy()))
    Enum(names) => Enum(ReadOnlyArray::from_array(names.copy()))
    FuncType(function) => {
      let params = []
      for param in function.params {
        params.push({
          name: param.label,
          ty: self.value(scope, param.ty),
          location: self.location,
        })
      }
      Function(
        ReadOnlyArray::from_array(params),
        self.optional_value(scope, function.result),
        function.is_async,
      )
    }
    ResourceType(_, _, _, _) => Resource(None)
    _ => raise Invalid("compound type was not scheduled as a scope")
  }
  let id = self.add(kind)
  if kind is Resource(None) {
    scope.resources.push(id)
  }
  id
}
