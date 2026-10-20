///|
priv enum CoreDeclaration {
  Definition(Bytes, Bool)
  Nested(@component.TypeDef)
  Alias(@component.Alias)
  Describe(Bool, String, @component.ExternDesc)
  Export(@component.Export)
  Module(Bytes)
  ConcreteComponent(Bytes)
  CoreInstance
  RuntimeInstance(@component.Instance)
  Canonical(@component.Canon)
  Start(@component.Start)
}

///|
priv struct CoreScope {
  parent : Int32?
  completion_sort : Int32
  declarations : Array[CoreDeclaration]
  definitions : Array[@core_types.Definition]
  slots : Map[Int32, Array[@core_types.ContractBinding]]
  exports : Map[String, @core_types.ContractBinding]
  mut position : Int32
}

///|
priv struct CoreAscription {
  actual : @core_types.Module
  expected : @core_types.Module
}

///|
fn core_error(error : @core_types.Diagnostic) -> Unit raise Boundary {
  raise Failure(
    None,
    match error.kind {
      Malformed => "WIT-B001"
      Invalid => "WIT-B003"
      Unsupported => "WIT-B002"
    },
    error.message,
  )
}

///|
fn core_sort(sort : @component.Sort) -> Int32 {
  match sort {
    Core(kind) => 0x100 + kind
    Func => 1
    Value => 2
    Type => 3
    Component => 4
    Instance => 5
  }
}

///|
fn CoreScope::bind(
  self : CoreScope,
  kind : Int32,
  value : @core_types.ContractBinding,
) -> Unit {
  match self.slots.get(kind) {
    Some(slots) => slots.push(value)
    None => self.slots[kind] = [value]
  }
}

///|
fn CoreScope::lookup(
  self : CoreScope,
  kind : Int32,
  index : Int32,
) -> @core_types.ContractBinding raise Boundary {
  guard self.slots.get(kind) is Some(slots) && slots.get(index) is Some(binding) else {
    raise Failure(
      None,
      "WIT-B003",
      "core contract binding index is out of bounds",
    )
  }
  binding
}

///|
fn CoreScope::module_type(
  self : CoreScope,
  index : Int32,
) -> @core_types.Module raise Boundary {
  guard self.definitions.get(index) is Some(Module(contract)) else {
    raise Failure(
      None,
      "WIT-B003",
      "core module reference does not name a module type",
    )
  }
  contract
}

///|
fn core_text(bytes : Bytes) -> String raise Boundary {
  @utf8.decode(bytes, ignore_bom=false) catch {
    _ => raise Failure(None, "WIT-B001", "invalid core binding name")
  }
}

///|
fn core_declarations(td : @component.TypeDef) -> Array[CoreDeclaration] {
  let declarations : Array[@component.ComponentDecl] = match td {
    ComponentType(declarations) => declarations
    InstanceType(declarations) =>
      declarations.map(declaration => {
        match declaration {
          CoreType(bytes) => @component.ComponentDecl::CoreType(bytes)
          Type(td) => Type(td)
          AliasOuter(kind, count, index) => AliasOuter(kind, count, index)
          AliasInstanceExport(kind, instance, name) =>
            AliasInstanceExport(kind, instance, name)
          Export(name, attrs, desc) => Export(name, attrs, desc)
        }
      })
    _ => []
  }
  declarations.map(declaration => {
    match declaration {
      CoreType(bytes) => Definition(bytes, false)
      Type(td) => Nested(td)
      AliasOuter(kind, count, index) =>
        Alias({ sort: core_decl_sort(kind), target: Outer(count, index), })
      AliasInstanceExport(kind, instance, name) =>
        Alias({ sort: core_decl_sort(kind), target: Export(instance, name), })
      Import(name, _, desc) => Describe(true, name, desc)
      Export(name, _, desc) => Describe(false, name, desc)
    }
  })
}

///|
fn core_decl_sort(kind : Int32) -> @component.Sort {
  match kind {
    1 => Func
    2 => Value
    3 => Type
    4 => Component
    5 => Instance
    _ => Core(kind - 0x100)
  }
}

///|
fn core_root_declarations(
  component : @component.ComponentBinary,
) -> Array[CoreDeclaration] raise Boundary {
  let root : Array[CoreDeclaration] = []
  for section in component.sections {
    try {
      match section.id {
        4 => root.push(ConcreteComponent(section.payload))
        1 => root.push(Module(section.payload))
        2 =>
          for _ in @component.parse_core_instance_section(section.payload) {
            root.push(CoreInstance)
          }
        5 =>
          for instance in @component.parse_instance_section(section.payload) {
            root.push(RuntimeInstance(instance))
          }
        8 =>
          for declaration in @component.parse_canon_section(section.payload) {
            root.push(Canonical(declaration))
          }
        3 => root.push(Definition(section.payload, true))
        7 =>
          for td in @type_parser.parse_type_section(section.payload) {
            root.push(Nested(td))
          }
        6 =>
          for entry in @component.parse_alias_section(section.payload) {
            root.push(Alias(entry))
          }
        10 =>
          for imported in @component.parse_import_section(section.payload) {
            let name = match imported.name {
              Plain(bytes) => core_text(bytes)
              WithVersion(name, version) =>
                core_text(name) + "@" + core_text(version)
            }
            root.push(Describe(true, name, imported.desc))
          }
        11 =>
          for entry in @component.parse_export_section(section.payload) {
            root.push(Export(entry))
          }
        9 => {
          let start = @component.parse_start_section(section.payload) catch {
            error => raise Failure(None, "WIT-B001", error.to_string())
          }
          root.push(Start(start))
        }
        _ => ()
      }
    } catch {
      Failure(offset, code, message) => raise Failure(offset, code, message)
      error => raise Failure(None, "WIT-B001", error.to_string())
    }
  }
  root
}

///|
fn validate_core_definitions(
  component : @component.ComponentBinary,
) -> (ReadOnlyArray[CoreAscription], @core_types.ContractGraph) raise Boundary {
  let root = core_root_declarations(component)
  let scopes : Array[CoreScope] = [
    {
      parent: None,
      completion_sort: 3,
      declarations: root,
      definitions: [],
      slots: Map([]),
      exports: Map([]),
      position: 0,
    },
  ]
  let stack = [0]
  let ascriptions : Array[CoreAscription] = []
  let mut remaining = 1000000
  fn step(amount : Int32) -> Unit raise Boundary {
    remaining -= amount
    if remaining < 0 {
      raise Failure(
        None,
        "WIT-B002",
        "core lexical metadata exceeds the work limit",
      )
    }
  }
  while stack.last() is Some(index) {
    step(1)
    let scope = scopes[index]
    if scope.position >= scope.declarations.length() {
      ignore(stack.pop())
      if scope.parent is Some(parent) {
        scopes[parent].bind(scope.completion_sort, Scope(index))
      }
      continue
    }
    let declaration = scope.declarations[scope.position]
    scope.position += 1
    match declaration {
      ConcreteComponent(bytes) => {
        let component = @component.parse_component_binary(bytes) catch {
          error => raise Failure(None, "WIT-B001", error.to_string())
        }
        let declarations = core_root_declarations(component)
        step(declarations.length())
        let child = scopes.length()
        scopes.push({
          parent: Some(index),
          completion_sort: 4,
          declarations,
          definitions: [],
          slots: Map([]),
          exports: Map([]),
          position: 0,
        })
        stack.push(child)
      }
      CoreInstance => scope.bind(0x112, Other)
      RuntimeInstance(instance) =>
        match instance.expr {
          Instantiate(component, _) => scope.bind(5, scope.lookup(4, component))
          InlineExports(exports) => {
            let bindings : Map[String, @core_types.ContractBinding] = Map([])
            for exported in exports {
              step(1)
              bindings[exported.name] = scope.lookup(
                core_sort(exported.sortidx.sort),
                exported.sortidx.idx,
              )
            }
            let child = scopes.length()
            scopes.push({
              parent: None,
              completion_sort: 3,
              declarations: [],
              definitions: [],
              slots: Map([]),
              exports: bindings,
              position: 0,
            })
            scope.bind(5, Scope(child))
          }
        }
      Canonical(Lift(_, _, _)) => scope.bind(1, Other)
      Canonical(_) => scope.bind(0x100, Other)
      Start(start) =>
        if start.results == 1 {
          scope.bind(2, Other)
        } else if start.results != 0 {
          raise Failure(
            None,
            "WIT-B003",
            "component start result count is outside the profile",
          )
        }
      Nested(td) =>
        match td {
          ComponentType(_) | InstanceType(_) | InstanceTypeEmpty => {
            let child = scopes.length()
            let declarations = core_declarations(td)
            step(declarations.length())
            scopes.push({
              parent: Some(index),
              completion_sort: 3,
              declarations,
              definitions: [],
              slots: Map([]),
              exports: Map([]),
              position: 0,
            })
            stack.push(child)
          }
          _ => scope.bind(3, Other)
        }
      Alias(entry) => {
        let kind = core_sort(entry.sort)
        let binding = match entry.target {
          Outer(count, original) => {
            let mut owner = index
            for _ in 0..<count {
              step(1)
              guard scopes[owner].parent is Some(parent) else {
                raise Failure(
                  None,
                  "WIT-B003",
                  "core alias exceeds lexical scopes",
                )
              }
              owner = parent
            }
            if kind == 0x110 {
              guard scopes[owner].definitions.get(original) is Some(definition) else {
                raise Failure(
                  None,
                  "WIT-B003",
                  "core alias index is out of bounds",
                )
              }
              scope.definitions.push(definition)
              continue
            }
            scopes[owner].lookup(kind, original)
          }
          Export(original, name) => {
            guard scope.lookup(5, original) is Scope(owner) &&
              scopes[owner].exports.get(name) is Some(binding) else {
              raise Failure(
                None,
                "WIT-B003",
                "core instance contract export is missing",
              )
            }
            binding
          }
          CoreExport(original, _) => {
            ignore(scope.lookup(0x112, original))
            @core_types.ContractBinding::Other
          }
        }
        scope.bind(kind, binding)
      }
      Describe(importing, name, desc) => {
        let (kind, binding) = match desc {
          CoreModuleType(original) =>
            (
              0x111,
              @core_types.ContractBinding::Module(scope.module_type(original)),
            )
          InstanceType(original) => (5, scope.lookup(3, original))
          ComponentType(original) => (4, scope.lookup(3, original))
          Type(Eq(original)) => (3, scope.lookup(3, original))
          Type(SubResource) => (3, @core_types.ContractBinding::Other)
          FuncType(_) => (1, @core_types.ContractBinding::Other)
          Value(_) => (2, @core_types.ContractBinding::Other)
        }
        scope.bind(kind, binding)
        if !importing {
          scope.exports[name] = binding
        }
      }
      Export(entry) => {
        let kind = core_sort(entry.sortidx.sort)
        let actual = scope.lookup(kind, entry.sortidx.idx)
        let exported = match (actual, entry.desc) {
          (Module(actual), Some(CoreModuleType(original))) => {
            let expected = scope.module_type(original)
            ascriptions.push({ actual, expected, })
            @core_types.ContractBinding::Module(expected)
          }
          (Scope(_), Some(InstanceType(original))) if kind == 5 => {
            guard scope.lookup(3, original) is Scope(expected) else {
              raise Failure(
                None,
                "WIT-B003",
                "instance annotation does not name an instance scope",
              )
            }
            @core_types.ContractBinding::Scope(expected)
          }
          (Scope(_), Some(ComponentType(original))) if kind == 4 => {
            guard scope.lookup(3, original) is Scope(expected) else {
              raise Failure(
                None,
                "WIT-B003",
                "component annotation does not name a component scope",
              )
            }
            @core_types.ContractBinding::Scope(expected)
          }
          (_, Some(ComponentType(_))) =>
            raise Failure(
              None,
              "WIT-B003",
              "component annotation has the wrong external sort",
            )
          (_, Some(InstanceType(_))) =>
            raise Failure(
              None,
              "WIT-B003",
              "instance annotation has the wrong external sort",
            )
          (_, Some(CoreModuleType(_))) =>
            raise Failure(
              None,
              "WIT-B003",
              "core module ascription has the wrong external sort",
            )
          _ => actual
        }
        scope.bind(kind, exported)
        let name = match entry.name {
          Plain(bytes) => core_text(bytes)
          WithVersion(name, version) =>
            core_text(name) + "@" + core_text(version)
        }
        scope.exports[name] = exported
      }
      Module(bytes) =>
        match @core_types.decode_module(bytes) {
          Ok(contract) => scope.bind(0x111, Module(contract))
          Err(error) => core_error(error)
        }
      Definition(bytes, section) => {
        let outers : Array[ReadOnlyArray[@core_types.Definition]] = []
        let mut parent = scope.parent
        while parent is Some(owner) {
          step(scopes[owner].definitions.length() + 1)
          outers.push(ReadOnlyArray::from_array(scopes[owner].definitions))
          parent = scopes[owner].parent
        }
        step(scope.definitions.length() + bytes.length())
        let current = ReadOnlyArray::from_array(scope.definitions)
        let outers = ReadOnlyArray::from_array(outers)
        if section {
          match @core_types.decode_section(bytes, current~, outers~) {
            Ok(definitions) =>
              for definition in definitions {
                scope.definitions.push(definition)
              }
            Err(error) => core_error(error)
          }
        } else {
          match @core_types.decode_type(bytes, current~, outers~) {
            Ok(definition) => scope.definitions.push(definition)
            Err(error) => core_error(error)
          }
        }
      }
    }
  }
  let frozen : Array[@core_types.ContractScope] = []
  for scope in scopes {
    let bindings : Array[(Int32, ReadOnlyArray[@core_types.ContractBinding])] = []
    for sort, values in scope.slots {
      step(values.length() + 1)
      bindings.push((sort, ReadOnlyArray::from_array(values)))
    }
    let exports : Array[(String, @core_types.ContractBinding)] = []
    for name, value in scope.exports {
      step(1)
      exports.push((name, value))
    }
    step(scope.definitions.length())
    frozen.push(
      @core_types.ContractScope::new(
        ReadOnlyArray::from_array(scope.definitions),
        ReadOnlyArray::from_array(bindings),
        ReadOnlyArray::from_array(exports),
      ),
    )
  }
  (
    ReadOnlyArray::from_array(ascriptions),
    @core_types.ContractGraph::new(ReadOnlyArray::from_array(frozen)),
  )
}
