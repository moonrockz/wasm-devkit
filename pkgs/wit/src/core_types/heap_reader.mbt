///|
fn Reader::heap_value(self : Reader) -> HeapValue raise Failure {
  let byte = self.byte()
  match byte {
    0x7f => return Number("i32")
    0x7e => return Number("i64")
    0x7d => return Number("f32")
    0x7c => return Number("f64")
    0x7b => return Number("v128")
    _ => ()
  }
  if byte >= 0x80 {
    self.fail(Malformed, "invalid core value type prefix")
  }
  let nullable = byte != 0x64
  let prefix = byte == 0x63 || byte == 0x64
  let shared = if prefix {
    if self.position < self.end && self.bytes[self.position] == b'\x65' {
      self.position += 1
      true
    } else {
      false
    }
  } else {
    byte == 0x65
  }
  let heap = if prefix && !shared {
    let start = self.position
    let heap = self.signed(33)
    if heap < 0L && self.position - start != 1 {
      self.fail(
        Malformed,
        "abstract heap types require their single-byte encoding",
      )
    }
    if heap > 2147483647L {
      self.fail(Invalid, "core heap type index is out of bounds")
    }
    heap.to_int()
  } else {
    let abstract_byte = if shared { self.byte() } else { byte }
    abstract_byte - 128
  }
  if heap < 0 && (heap < -24 || heap > -11) {
    self.fail(Malformed, "invalid abstract core heap type")
  }
  if heap == -24 || heap == -11 {
    self.fail(
      Unsupported,
      "stack switching heap types are outside the core profile",
    )
  }
  if shared && heap >= 0 {
    self.fail(Malformed, "shared heap prefix requires an abstract heap type")
  }
  Ref(nullable, shared, heap)
}

///|
fn Reader::heap_immediate(
  self : Reader,
  nullable : Bool,
) -> HeapValue raise Failure {
  if self.position < self.end && self.bytes[self.position] == b'\x65' {
    self.position += 1
    let heap = self.byte() - 128
    if heap < -24 || heap > -11 {
      self.fail(Malformed, "invalid shared abstract heap type")
    }
    if heap == -24 || heap == -11 {
      self.fail(
        Unsupported,
        "stack switching heap types are outside the core profile",
      )
    }
    return Ref(nullable, true, heap)
  }
  let start = self.position
  let heap = self.signed(33)
  if heap > 2147483647L {
    self.fail(Invalid, "core heap type index is out of bounds")
  }
  if heap < 0L {
    if self.position - start != 1 || heap < -24L || heap > -11L {
      self.fail(Malformed, "invalid abstract heap encoding")
    }
    if heap == -24L || heap == -11L {
      self.fail(
        Unsupported,
        "stack switching heap types are outside the core profile",
      )
    }
  }
  Ref(nullable, false, heap.to_int())
}

///|
fn Reader::heap_field(self : Reader) -> HeapField raise Failure {
  let storage = if self.position < self.end &&
    self.bytes[self.position] == b'\x78' {
    self.position += 1
    Packed("i8")
  } else if self.position < self.end && self.bytes[self.position] == b'\x77' {
    self.position += 1
    Packed("i16")
  } else {
    Value(self.heap_value())
  }
  let mutable = self.byte()
  if mutable > 1 {
    self.fail(Malformed, "invalid core field mutability")
  }
  { storage, mutable: mutable == 1, }
}

///|
fn Reader::heap_subtype(
  self : Reader,
  opcode : Int32,
  group_start : Int32,
  group_size : Int32,
) -> HeapDefinition raise Failure {
  let mut opcode = opcode
  let mut final_ = true
  let mut supertype = None
  if opcode == 0x4f || opcode == 0x50 {
    final_ = opcode == 0x4f
    let count = self.count()
    if count > 1 {
      self.fail(Invalid, "core types permit at most one supertype")
    }
    if count == 1 {
      supertype = Some(self.index())
    }
    opcode = self.byte()
  }
  let shared = opcode == 0x65
  if shared {
    opcode = self.byte()
  }
  let composite : HeapComposite = match opcode {
    0x60 => {
      let params = []
      let count = self.count()
      for _ in 0..<count {
        params.push(self.heap_value())
      }
      let results = []
      let count = self.count()
      for _ in 0..<count {
        results.push(self.heap_value())
      }
      Function(
        ReadOnlyArray::from_array(params),
        ReadOnlyArray::from_array(results),
      )
    }
    0x5f => {
      let fields = []
      let count = self.count()
      for _ in 0..<count {
        fields.push(self.heap_field())
      }
      Struct(ReadOnlyArray::from_array(fields))
    }
    0x5e => Array(self.heap_field())
    _ => {
      self.fail(
        Unsupported,
        "core composite type is outside the supported profile",
      )
      Struct([])
    }
  }
  { final_, shared, supertype, group_start, group_size, composite, }
}

///|
fn Reader::heap_group(
  self : Reader,
  opcode : Int32,
  types : Array[HeapDefinition],
) -> Unit raise Failure {
  let start = types.length()
  if opcode == 0x4e {
    let count = self.count()
    for _ in 0..<count {
      types.push(self.heap_subtype(self.byte(), start, count))
    }
  } else {
    types.push(self.heap_subtype(opcode, start, 1))
  }
}

///|
/// Resolve concrete sharedness after an entire group has been read, including
/// forward references to its later members. The returned graph has no mutable
/// backing arrays exposed through the public contract.
fn Reader::complete_heap_graph(
  self : Reader,
  types : Array[HeapDefinition],
) -> ReadOnlyArray[HeapDefinition] raise Failure {
  fn value(v : HeapValue, owner : Int32) -> HeapValue raise Failure {
    match v {
      Number(_) => v
      Ref(nullable, _, index) if index >= 0 => {
        guard types.get(index) is Some(target) else {
          self.fail(Invalid, "core reference type index is out of bounds")
          return v
        }
        let node = types[owner]
        if index >= node.group_start + node.group_size {
          self.fail(
            Invalid,
            "core type forward reference escapes its recursive group",
          )
        }
        Ref(nullable, target.shared, index)
      }
      _ => v
    }
  }
  fn field(f : HeapField, owner : Int32) -> HeapField raise Failure {
    {
      ..f,
      storage: match f.storage {
        Packed(_) => f.storage
        Value(v) => Value(value(v, owner))
      },
    }
  }
  let result = []
  let depths = Array::make(types.length(), 0)
  for index, node in types {
    if node.supertype is Some(parent) {
      if parent < 0 || parent >= index {
        self.fail(Invalid, "core supertype must precede its subtype")
      }
      depths[index] = depths[parent] + 1
      if depths[index] > 63 {
        self.fail(Invalid, "core subtype depth exceeds 63")
      }
    }
    let composite : HeapComposite = match node.composite {
      Function(params, results) => {
        let ps = []
        let rs = []
        for v in params {
          ps.push(value(v, index))
        }
        for v in results {
          rs.push(value(v, index))
        }
        Function(ReadOnlyArray::from_array(ps), ReadOnlyArray::from_array(rs))
      }
      Struct(fields) => {
        let fs = []
        for f in fields {
          fs.push(field(f, index))
        }
        Struct(ReadOnlyArray::from_array(fs))
      }
      Array(f) => Array(field(f, index))
    }
    result.push({ ..node, composite, })
  }
  ReadOnlyArray::from_array(result)
}

///|
fn Reader::contract_value(
  self : Reader,
  value : HeapValue,
  types : ReadOnlyArray[HeapDefinition],
) -> Value raise Failure {
  match value {
    Number(name) => Scalar(name)
    Ref(nullable, shared, heap) if heap < 0 => {
      let name = @model.heap_name(heap)
      if shared {
        SharedReference(nullable, name)
      } else {
        Reference(nullable, name)
      }
    }
    Ref(nullable, _, index) => {
      if types.get(index) is None {
        self.fail(Invalid, "core reference type index is out of bounds")
      }
      Concrete(nullable, { types, index, })
    }
  }
}

///|
fn Reader::function_external(
  self : Reader,
  index : Int32,
  tag : Bool,
  types : ReadOnlyArray[HeapDefinition],
) -> External raise Failure {
  guard types.get(index) is Some(node) &&
    node.composite is Function(params, results) else {
    self.fail(Invalid, "core function type index must name a function")
    return Func({ params: [], results: [], })
  }
  if tag && !results.is_empty() {
    self.fail(Invalid, "core tag cannot return values")
  }
  let ps = []
  let rs = []
  let mut typed = node.shared ||
    !node.final_ ||
    node.supertype is Some(_) ||
    node.group_size != 1
  for value in params {
    let value = self.contract_value(value, types)
    if value is Concrete(_, _) {
      typed = true
    }
    ps.push(value)
  }
  for value in results {
    let value = self.contract_value(value, types)
    if value is Concrete(_, _) {
      typed = true
    }
    rs.push(value)
  }
  if typed {
    let identity = { types, index, }
    if tag {
      TypedTag(identity)
    } else {
      TypedFunc(identity)
    }
  } else {
    let function = {
      params: ReadOnlyArray::from_array(ps),
      results: ReadOnlyArray::from_array(rs),
    }
    if tag {
      Tag(function)
    } else {
      Func(function)
    }
  }
}

///|
/// Frame one heap group and return its end and expanded type-index count.
/// Lexical resolution and semantic validation belong to the decode operations.
pub fn scan_heap_group(
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
    let types = []
    reader.heap_group(reader.byte(), types)
    Ok((reader.position, types.length()))
  } catch {
    Failure(error) => Err(error)
  }
}

///|
/// Frame one value type without assigning a concrete reference to a graph.
pub fn scan_value(
  bytes : Bytes,
  start : Int32,
  end : Int32,
) -> Result[(Int32, HeapValue), Diagnostic] {
  if start < 0 || end < start || end > bytes.length() {
    return Err({
      offset: start,
      kind: Malformed,
      message: "invalid core byte range",
    })
  }
  let reader : Reader = { bytes, position: start, end, }
  try {
    let value = reader.heap_value()
    Ok((reader.position, value))
  } catch {
    Failure(error) => Err(error)
  }
}
