///|
priv enum CoreDeclaration {
  Definition(Bytes, Bool)
  Nested(@component.TypeDef)
  Alias(Int32, Int32)
  Require(@component.ExternDesc)
}

///|
priv struct CoreScope {
  parent : Int32?
  declarations : Array[CoreDeclaration]
  definitions : Array[@core_types.Definition]
  mut position : Int32
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
fn core_declarations(td : @component.TypeDef) -> Array[CoreDeclaration] {
  let out : Array[CoreDeclaration] = []
  match td {
    ComponentType(declarations) =>
      for declaration in declarations {
        match declaration {
          CoreType(bytes) => out.push(Definition(bytes, false))
          Type(td) => out.push(Nested(td))
          AliasOuter(0x110, count, index) => out.push(Alias(count, index))
          Import(_, _, desc) | Export(_, _, desc) => out.push(Require(desc))
          _ => ()
        }
      }
    InstanceType(declarations) =>
      for declaration in declarations {
        match declaration {
          CoreType(bytes) => out.push(Definition(bytes, false))
          Type(td) => out.push(Nested(td))
          AliasOuter(0x110, count, index) => out.push(Alias(count, index))
          Export(_, _, desc) => out.push(Require(desc))
          _ => ()
        }
      }
    _ => ()
  }
  out
}

///|
fn validate_core_definitions(
  component : @component.Component,
) -> Unit raise Boundary {
  let root : Array[CoreDeclaration] = []
  for section in component.binary.sections {
    match section.id {
      3 => root.push(Definition(section.payload, true))
      7 =>
        for
          td in (@component.parse_type_section(section.payload) catch {
            error => raise Failure(None, "WIT-B001", error.to_string())
          }) {
          root.push(Nested(td))
        }
      6 =>
        for
          entry in (@component.parse_alias_section(section.payload) catch {
            error => raise Failure(None, "WIT-B001", error.to_string())
          }) {
          if entry.sort is Core(0x10) {
            guard entry.target is Outer(count, index) else {
              raise Failure(
                None,
                "WIT-B003",
                "core type aliases must target lexical scopes",
              )
            }
            root.push(Alias(count, index))
          }
        }
      10 =>
        for
          imported in (@component.parse_import_section(section.payload) catch {
            error => raise Failure(None, "WIT-B001", error.to_string())
          }) {
          root.push(Require(imported.desc))
        }
      _ => ()
    }
  }
  let scopes : Array[CoreScope] = [
    { parent: None, declarations: root, definitions: [], position: 0, },
  ]
  let stack = [0]
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
      continue
    }
    let declaration = scope.declarations[scope.position]
    scope.position += 1
    match declaration {
      Nested(td) =>
        match td {
          ComponentType(_) | InstanceType(_) => {
            let child = scopes.length()
            let declarations = core_declarations(td)
            step(declarations.length())
            scopes.push({
              parent: Some(index),
              declarations,
              definitions: [],
              position: 0,
            })
            stack.push(child)
          }
          _ => ()
        }
      Alias(count, original) => {
        let mut owner = index
        for _ in 0..<count {
          step(1)
          guard scopes[owner].parent is Some(parent) else {
            raise Failure(None, "WIT-B003", "core alias exceeds lexical scopes")
          }
          owner = parent
        }
        guard scopes[owner].definitions.get(original) is Some(definition) else {
          raise Failure(None, "WIT-B003", "core alias index is out of bounds")
        }
        scope.definitions.push(definition)
      }
      Require(CoreModuleType(original)) => {
        guard scope.definitions.get(original) is Some(Module(_)) else {
          raise Failure(
            None,
            "WIT-B003",
            "core module reference does not name a module type",
          )
        }
      }
      Require(_) => ()
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
}
