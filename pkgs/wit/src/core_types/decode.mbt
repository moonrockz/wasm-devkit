///|
priv enum RawExternal {
  Func(Int32)
  Tag(Int32)
  Value(External)
}

///|
priv enum RawDeclaration {
  Type(Function)
  Alias(Int32, Int32)
  Import(String, String, RawExternal)
  Export(String, RawExternal)
}

///|
priv enum RawDefinition {
  Function(Function)
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
  let kind = match kind {
    Some(kind) => kind
    None => self.byte()
  }
  match kind {
    0 => Func(self.index())
    1 => {
      let element = self.value()
      guard element is Reference(_, _) else {
        self.fail(Invalid, "core table needs a reference type")
        return Value(Table(element, 0UL, None, false, false))
      }
      let flags = self.byte()
      let (initial, maximum) = self.limits(flags)
      if (flags & 2) != 0 {
        self.fail(Invalid, "shared tables need shared reference types")
      }
      Value(Table(element, initial, maximum, (flags & 4) != 0, false))
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
      let value = self.value()
      let flags = self.byte()
      if flags > 3 {
        self.fail(Malformed, "invalid core global flags")
      }
      let shared = (flags & 2) != 0
      if shared && value is Reference(_, _) {
        self.fail(Invalid, "shared globals need shared values")
      }
      Value(Global(value, (flags & 1) != 0, shared))
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
  match self.byte() {
    0x60 => Function(self.function_body())
    0x50 => {
      let declarations : Array[RawDeclaration] = []
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
              if self.byte() != 0x60 {
                self.fail(
                  Unsupported,
                  "core GC and recursive types are outside this codec",
                )
              }
              Type(self.function_body())
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
    }
    _ => {
      self.fail(
        Unsupported,
        "core GC and recursive types are outside this codec",
      )
      Function({ params: [], results: [], })
    }
  }
}

///|
fn Reader::resolve(
  self : Reader,
  definition : RawDefinition,
  current : Array[Definition],
  outers : ReadOnlyArray[ReadOnlyArray[Definition]],
) -> Definition raise Failure {
  match definition {
    Function(function) => Function(function)
    Module(declarations) => {
      let functions : Array[Function] = []
      let imports : Array[Import] = []
      let exports : Array[Export] = []
      let import_names : Map[(String, String), Bool] = Map([])
      let export_names : Map[String, Bool] = Map([])
      fn external(raw : RawExternal) -> External raise Failure {
        match raw {
          Value(value) => value
          Func(index) | Tag(index) => {
            guard functions.get(index) is Some(function) else {
              self.fail(Invalid, "core function type index is out of bounds")
              return Func({ params: [], results: [], })
            }
            if raw is Tag(_) {
              if !function.results.is_empty() {
                self.fail(Invalid, "core tag function cannot return values")
              }
              Tag(function)
            } else {
              Func(function)
            }
          }
        }
      }
      for declaration in declarations {
        match declaration {
          Type(function) => functions.push(function)
          Alias(depth, index) =>
            if depth == 0 {
              guard functions.get(index) is Some(function) else {
                self.fail(Invalid, "core local alias index is out of bounds")
                continue
              }
              functions.push(function)
            } else {
              let candidate = if depth == 1 {
                current.get(index)
              } else {
                guard outers.get(depth - 2) is Some(table) else {
                  self.fail(Invalid, "core outer alias exceeds scope")
                  continue
                }
                table.get(index)
              }
              guard candidate is Some(Function(function)) else {
                self.fail(
                  Invalid,
                  "core alias does not reference a function type",
                )
                continue
              }
              functions.push(function)
            }
          Import(module_name, name, raw) => {
            let key = (module_name, name)
            if import_names.contains(key) {
              self.fail(Invalid, "duplicate core import pair")
            }
            import_names[key] = true
            imports.push({ module_name, name, kind: external(raw), })
          }
          Export(name, raw) => {
            if export_names.contains(name) {
              self.fail(Invalid, "duplicate core export name")
            }
            export_names[name] = true
            exports.push({ name, kind: external(raw), })
          }
        }
      }
      Module({
        imports: ReadOnlyArray::from_array(imports),
        exports: ReadOnlyArray::from_array(exports),
      })
    }
  }
}

///|
/// Scan one encoded core type, returning its exclusive byte end. This checks
/// framing and value forms; lexical alias resolution belongs to decode_type.
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
  // Retain the obsolete option for source compatibility. All scopes now use
  // the same unsigned limits and custom-page profile.
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
/// Decode one core function/module type in an explicit lexical environment.
/// No files, imports or runtime instances are loaded or executed.
pub fn decode_type(
  bytes : Bytes,
  current~ : ReadOnlyArray[Definition] = [],
  outers~ : ReadOnlyArray[ReadOnlyArray[Definition]] = [],
) -> Result[Definition, Diagnostic] {
  let reader = { bytes, position: 0, end: bytes.length(), }
  try {
    let raw = reader.definition()
    if reader.position != reader.end {
      reader.fail(Malformed, "trailing core type bytes")
    }
    Ok(
      reader.resolve(
        raw,
        Array::makei(current.length(), i => current[i]),
        outers,
      ),
    )
  } catch {
    Failure(error) => Err(error)
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
    let definitions = Array::makei(current.length(), i => current[i])
    let result : Array[Definition] = []
    let count = reader.count()
    for _ in 0..<count {
      let definition = reader.resolve(reader.definition(), definitions, outers)
      definitions.push(definition)
      result.push(definition)
    }
    if reader.position != reader.end {
      reader.fail(Malformed, "trailing core section bytes")
    }
    Ok(ReadOnlyArray::from_array(result))
  } catch {
    Failure(error) => Err(error)
  }
}
