///|
priv enum RawExternal {
  Func(Int32)
  Tag(Int32)
  Table(HeapValue, UInt64, UInt64?, Bool, Bool)
  Global(HeapValue, Bool, Bool)
  Value(External)
}

///|
priv enum RawDeclaration {
  Type(Array[HeapDefinition])
  Alias(Int32, Int32)
  Import(String, String, RawExternal)
  Export(String, RawExternal)
}

///|
priv enum RawDefinition {
  Group(Array[HeapDefinition])
  Module(Array[RawDeclaration])
}

///|
fn Reader::limits(
  self : Reader,
  flags : Int32,
) -> (UInt64, UInt64?) raise Failure {
  if flags > 7 {
    self.fail(Malformed, "invalid core limits flags")
  }
  let width = if (flags & 4) != 0 { 64 } else { 32 }
  let initial = self.unsigned(width)
  let maximum = if (flags & 1) != 0 { Some(self.unsigned(width)) } else { None }
  if maximum is Some(maximum) && maximum < initial {
    self.fail(Invalid, "core minimum exceeds maximum")
  }
  (initial, maximum)
}

///|
fn Reader::external(
  self : Reader,
  kind~ : Int32? = None,
) -> RawExternal raise Failure {
  let kind = kind.unwrap_or_else(() => self.byte())
  match kind {
    0 => Func(self.index())
    1 => {
      let element = self.heap_value()
      if element is Number(_) {
        self.fail(Invalid, "core table needs a reference type")
      }
      let flags = self.byte()
      let (initial, maximum) = self.limits(flags)
      Table(element, initial, maximum, (flags & 4) != 0, (flags & 2) != 0)
    }
    2 => {
      let flags = self.byte()
      if flags > 15 {
        self.fail(Malformed, "invalid core memory flags")
      }
      let (initial, maximum) = self.limits(flags & 7)
      let page = if (flags & 8) != 0 { Some(self.index()) } else { None }
      let log2 = page.unwrap_or(16)
      if log2 != 0 && log2 != 16 {
        self.fail(Invalid, "invalid custom memory page size")
      }
      let memory64 = (flags & 4) != 0
      let maximum_pages = if memory64 && log2 == 0 {
        18446744073709551615UL
      } else {
        1UL << ((if memory64 { 64 } else { 32 }) - log2)
      }
      if initial > maximum_pages ||
        (maximum is Some(maximum) && maximum > maximum_pages) {
        self.fail(Invalid, "core memory exceeds addressable size")
      }
      let shared = (flags & 2) != 0
      if shared && maximum is None {
        self.fail(Invalid, "shared memory requires a maximum")
      }
      Value(Memory(initial, maximum, memory64, shared, page))
    }
    3 => {
      let value = self.heap_value()
      let flags = self.byte()
      if flags > 3 {
        self.fail(Malformed, "invalid core global flags")
      }
      Global(value, (flags & 1) != 0, (flags & 2) != 0)
    }
    4 => {
      if self.byte() != 0 {
        self.fail(Malformed, "invalid core tag attribute")
      }
      Tag(self.index())
    }
    _ => {
      self.fail(Malformed, "invalid core external kind")
      Func(0)
    }
  }
}

///|
fn Reader::definition(self : Reader) -> RawDefinition raise Failure {
  let opcode = self.byte()
  if opcode == 0x50 {
    let declarations = []
    let count = self.count()
    for _ in 0..<count {
      declarations.push(
        match self.byte() {
          0 => {
            let module_name = self.name()
            let name = self.name()
            Import(module_name, name, self.external())
          }
          1 => {
            let types = []
            self.heap_group(self.byte(), types)
            Type(types)
          }
          2 => {
            if self.byte() != 0x10 || self.byte() != 1 {
              self.fail(Malformed, "invalid core module type alias")
            }
            Alias(self.index(), self.index())
          }
          3 => {
            let name = self.name()
            Export(name, self.external())
          }
          _ => {
            self.fail(Malformed, "invalid core module declaration")
            Alias(0, 0)
          }
        },
      )
    }
    Module(declarations)
  } else {
    let types = []
    let opcode = if opcode == 0 {
      if self.byte() != 0x50 {
        self.fail(Malformed, "invalid top-level non-final subtype prefix")
      }
      0x50
    } else {
      opcode
    }
    self.heap_group(opcode, types)
    Group(types)
  }
}

///|
fn Reader::resolve(
  self : Reader,
  definition : RawDefinition,
  scope : HeapScope,
  outers : ReadOnlyArray[ReadOnlyArray[Definition]],
) -> ReadOnlyArray[Definition] raise Failure {
  match definition {
    Group(types) => scope.add_group(types)
    Module(declarations) => {
      let module_scope = HeapScope::new(self, scope.budget)
      let imports = []
      let exports = []
      let import_names = Map([])
      let export_names = Map([])
      for declaration in declarations {
        self.heap_charge(scope.budget, 1)
        match declaration {
          Type(types) => ignore(module_scope.add_group(types))
          Alias(depth, index) => {
            let source = if depth == 0 {
              module_scope.definitions.get(index)
            } else if depth == 1 {
              scope.definitions.get(index)
            } else {
              guard outers.get(depth - 2) is Some(outer) else {
                self.fail(Invalid, "core outer alias exceeds scope")
                continue
              }
              outer.get(index)
            }
            guard source is Some(source) && !(source is Module(_)) else {
              self.fail(Invalid, "core alias does not reference a heap type")
              continue
            }
            module_scope.import_definition(source)
          }
          Import(module_name, name, raw) => {
            if import_names.contains((module_name, name)) {
              self.fail(Invalid, "duplicate core import pair")
            }
            import_names[(module_name, name)] = true
            imports.push({
              module_name,
              name,
              kind: module_scope.external(raw),
            })
          }
          Export(name, raw) => {
            if export_names.contains(name) {
              self.fail(Invalid, "duplicate core export name")
            }
            export_names[name] = true
            exports.push({ name, kind: module_scope.external(raw), })
          }
        }
      }
      let definition = Definition::Module({
        imports: ReadOnlyArray::from_array(imports),
        exports: ReadOnlyArray::from_array(exports),
      })
      scope.import_definition(definition)
      [definition]
    }
  }
}

///|
/// Frame one encoded core type. Recursive groups are one encoded declaration
/// and can introduce several indices; `decode_declarations` returns every one.
pub fn scan_type(
  bytes : Bytes,
  start : Int32,
  end : Int32,
  legacy_nested~ : Bool = false,
) -> Result[Int32, Diagnostic] {
  if start < 0 || end < start || end > bytes.length() {
    return Err({
      offset: start,
      kind: Malformed,
      message: "invalid core byte range",
    })
  }
  ignore(legacy_nested)
  let reader = { bytes, position: start, end, }
  try {
    ignore(reader.definition())
    Ok(reader.position)
  } catch {
    Failure(error) => Err(error)
  }
}

///|
/// Decode one encoded declaration, expanding recursive groups into their
/// lexical core type indices. No operation loads or executes dependencies.
pub fn decode_declarations(
  bytes : Bytes,
  current~ : ReadOnlyArray[Definition] = [],
  outers~ : ReadOnlyArray[ReadOnlyArray[Definition]] = [],
) -> Result[ReadOnlyArray[Definition], Diagnostic] {
  let reader = { bytes, position: 0, end: bytes.length(), }
  try {
    let scope = HeapScope::new(reader, { remaining: 1000000, })
    for definition in current {
      scope.import_definition(definition)
    }
    let result = reader.resolve(reader.definition(), scope, outers)
    if reader.position != reader.end {
      reader.fail(Malformed, "trailing core type bytes")
    }
    Ok(result)
  } catch {
    Failure(error) => Err(error)
  }
}

///|
/// Decode a declaration that introduces exactly one type index. Use
/// `decode_declarations` when a recursive group may introduce several indices.
pub fn decode_type(
  bytes : Bytes,
  current~ : ReadOnlyArray[Definition] = [],
  outers~ : ReadOnlyArray[ReadOnlyArray[Definition]] = [],
) -> Result[Definition, Diagnostic] {
  match decode_declarations(bytes, current~, outers~) {
    Err(error) => Err(error)
    Ok(definitions) =>
      if definitions.length() == 1 {
        Ok(definitions[0])
      } else {
        Err({
          offset: 0,
          kind: Invalid,
          message: "core declaration introduces multiple indices; use decode_declarations",
        })
      }
  }
}

///|
pub fn decode_section(
  bytes : Bytes,
  current~ : ReadOnlyArray[Definition] = [],
  outers~ : ReadOnlyArray[ReadOnlyArray[Definition]] = [],
) -> Result[ReadOnlyArray[Definition], Diagnostic] {
  let reader = { bytes, position: 0, end: bytes.length(), }
  try {
    let scope = HeapScope::new(reader, { remaining: 1000000, })
    for definition in current {
      scope.import_definition(definition)
    }
    let result = []
    let count = reader.count()
    for _ in 0..<count {
      let definitions = reader.resolve(reader.definition(), scope, outers)
      for definition in definitions {
        result.push(definition)
      }
    }
    if reader.position != reader.end {
      reader.fail(Malformed, "trailing core section bytes")
    }
    Ok(ReadOnlyArray::from_array(result))
  } catch {
    Failure(error) => Err(error)
  }
}

///|
/// Frame one component core declaration and report every index it introduces.
pub fn scan_declaration(
  bytes : Bytes,
  start : Int32,
  end : Int32,
) -> Result[(Int32, Int32), Diagnostic] {
  if start < 0 || end < start || end > bytes.length() {
    return Err({
      offset: start,
      kind: Malformed,
      message: "invalid core byte range",
    })
  }
  let reader : Reader = { bytes, position: start, end, }
  try {
    let definition = reader.definition()
    Ok(
      (
        reader.position,
        match definition {
          Group(types) => types.length()
          Module(_) => 1
        },
      ),
    )
  } catch {
    Failure(error) => Err(error)
  }
}
