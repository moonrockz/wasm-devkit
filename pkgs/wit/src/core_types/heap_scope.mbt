///|
priv struct HeapScope {
  reader : Reader
  budget : CompatibilityBudget
  types : Array[HeapDefinition]
  indices : Array[Int32?]
  definitions : Array[Definition]
}

///|
fn HeapScope::new(reader : Reader, budget : CompatibilityBudget) -> HeapScope {
  { reader, budget, types: [], indices: [], definitions: [], }
}

///|
fn Reader::heap_charge(
  self : Reader,
  budget : CompatibilityBudget,
  count : Int32,
) -> Unit raise Failure {
  budget.charge(count) catch {
    CompatibilityFailure(_) =>
      self.fail(Unsupported, "core type graph work exceeds 1000000")
  }
}

///|
fn Reader::mapped_index(
  self : Reader,
  index : Int32,
  mapping : Array[Int32?]?,
) -> Int32 raise Failure {
  match mapping {
    None => index
    Some(mapping) => {
      guard mapping.get(index) is Some(Some(index)) else {
        self.fail(Invalid, "core type index does not name a heap type")
        return 0
      }
      index
    }
  }
}

///|
fn Reader::resolve_external(
  self : Reader,
  raw : RawExternal,
  graph : ReadOnlyArray[HeapDefinition],
  mapping : Array[Int32?]?,
) -> External raise Failure {
  fn value(raw : HeapValue) -> Value raise Failure {
    let raw = match raw {
      Ref(nullable, shared, index) if index >= 0 =>
        Ref(nullable, shared, self.mapped_index(index, mapping))
      _ => raw
    }
    self.contract_value(raw, graph)
  }
  match raw {
    Value(external) => external
    Func(index) =>
      self.function_external(self.mapped_index(index, mapping), false, graph)
    Tag(index) =>
      self.function_external(self.mapped_index(index, mapping), true, graph)
    Table(raw, min, max, index64, shared) => {
      let element = value(raw)
      if shared && !is_shared_value(element) {
        self.fail(Invalid, "shared tables need shared reference types")
      }
      Table(element, min, max, index64, shared)
    }
    Global(raw, mutable, shared) => {
      let value = value(raw)
      if shared && !is_shared_value(value) {
        self.fail(Invalid, "shared globals need shared values")
      }
      Global(value, mutable, shared)
    }
  }
}

///|
fn HeapScope::external(
  self : HeapScope,
  raw : RawExternal,
) -> External raise Failure {
  self.reader.heap_charge(self.budget, self.types.length())
  self.reader.resolve_external(
    raw,
    ReadOnlyArray::from_array(self.types),
    Some(self.indices),
  )
}

///|
fn HeapScope::charge_node(
  self : HeapScope,
  node : HeapDefinition,
) -> Unit raise Failure {
  self.reader.heap_charge(self.budget, 1)
  match node.composite {
    Function(params, results) => {
      self.reader.heap_charge(self.budget, params.length())
      self.reader.heap_charge(self.budget, results.length())
    }
    Struct(fields) => self.reader.heap_charge(self.budget, fields.length())
    Array(_) => self.reader.heap_charge(self.budget, 1)
  }
}

///|
fn shift_heap_node(node : HeapDefinition, offset : Int32) -> HeapDefinition {
  fn value(v : HeapValue) -> HeapValue {
    match v {
      Ref(n, s, i) if i >= 0 => Ref(n, s, i + offset)
      _ => v
    }
  }
  fn field(f : HeapField) -> HeapField {
    {
      ..f,
      storage: match f.storage {
        Value(v) => Value(value(v))
        _ => f.storage
      },
    }
  }
  let composite : HeapComposite = match node.composite {
    Function(ps, rs) => Function(ps.map(value), rs.map(value))
    Struct(fs) => Struct(fs.map(field))
    Array(f) => Array(field(f))
  }
  {
    ..node,
    group_start: node.group_start + offset,
    supertype: node.supertype.map(i => i + offset),
    composite,
  }
}

///|
fn HeapScope::import_identity(
  self : HeapScope,
  identity : TypeIdentity,
) -> Int32 raise Failure {
  if identity.index < 0 || identity.index >= identity.types.length() {
    self.reader.fail(Invalid, "invalid aliased concrete core type")
  }
  let mut prefix = identity.types.length() <= self.types.length()
  for i, node in identity.types {
    self.charge_node(node)
    if prefix && self.types[i] != node {
      prefix = false
    }
  }
  if prefix {
    return identity.index
  }
  let offset = self.types.length()
  for node in identity.types {
    self.types.push(shift_heap_node(node, offset))
  }
  identity.index + offset
}

///|
fn HeapScope::import_definition(
  self : HeapScope,
  definition : Definition,
) -> Unit raise Failure {
  self.reader.heap_charge(self.budget, 1)
  let index = match definition {
    Module(_) => None
    Heap(identity) => Some(self.import_identity(identity))
    Function(function) => {
      fn value(v : Value) -> HeapValue raise Failure {
        self.reader.heap_charge(self.budget, 1)
        match v {
          Scalar(name) => Number(name)
          Concrete(nullable, identity) => {
            let root = self.import_identity(identity)
            Ref(nullable, self.types[root].shared, root)
          }
          _ => {
            guard abstract_reference(v) is Some((n, s, h)) else {
              self.reader.fail(Invalid, "invalid abstract core value")
              return Number("")
            }
            Ref(n, s, h)
          }
        }
      }
      let ps = []
      let rs = []
      for v in function.params {
        ps.push(value(v))
      }
      for v in function.results {
        rs.push(value(v))
      }
      let index = self.types.length()
      self.types.push({
        final_: true,
        shared: false,
        supertype: None,
        group_start: index,
        group_size: 1,
        composite: Function(
          ReadOnlyArray::from_array(ps),
          ReadOnlyArray::from_array(rs),
        ),
      })
      Some(index)
    }
  }
  self.indices.push(index)
  self.definitions.push(definition)
}

///|
fn HeapScope::add_group(
  self : HeapScope,
  raw : Array[HeapDefinition],
) -> ReadOnlyArray[Definition] raise Failure {
  let start = self.types.length()
  for i in 0..<raw.length() {
    self.indices.push(Some(start + i))
  }
  fn value(v : HeapValue) -> HeapValue raise Failure {
    match v {
      Ref(n, s, i) if i >= 0 =>
        Ref(n, s, self.reader.mapped_index(i, Some(self.indices)))
      _ => v
    }
  }
  fn field(f : HeapField) -> HeapField raise Failure {
    {
      ..f,
      storage: match f.storage {
        Value(v) => Value(value(v))
        _ => f.storage
      },
    }
  }
  for node in raw {
    self.charge_node(node)
    let composite : HeapComposite = match node.composite {
      Function(ps, rs) => {
        let params = []
        let results = []
        for v in ps {
          params.push(value(v))
        }
        for v in rs {
          results.push(value(v))
        }
        Function(
          ReadOnlyArray::from_array(params),
          ReadOnlyArray::from_array(results),
        )
      }
      Struct(fs) => {
        let fields = []
        for f in fs {
          fields.push(field(f))
        }
        Struct(ReadOnlyArray::from_array(fields))
      }
      Array(f) => Array(field(f))
    }
    let supertype = match node.supertype {
      Some(i) => Some(self.reader.mapped_index(i, Some(self.indices)))
      None => None
    }
    self.types.push({
      ..node,
      group_start: start,
      group_size: raw.length(),
      supertype,
      composite,
    })
  }
  for node in self.types {
    self.charge_node(node)
  }
  let graph = self.reader.complete_heap_graph(self.types)
  let identity : TypeIdentity = { types: graph, index: start, }
  if raw.is_empty() {
    return []
  }
  // Check the declared subtype rules with the same bounded, nonrecursive
  // engine used for concrete module validation.
  let lowered = lower_identity(identity, self.budget) catch {
    CompatibilityFailure(_) => {
      self.reader.fail(Unsupported, "core type graph work exceeds 1000000")
      None
    }
  }
  guard lowered is Some((types, groups)) else {
    self.reader.fail(Invalid, "invalid core type graph")
    return []
  }
  let context = @model.SubtypingContext::same_module(types, rec_groups=groups)
  context.restrict_work_limit(self.budget.remaining)
  for i in start..<graph.length() {
    let node = graph[i]
    self.types[i] = node
    if node.shared {
      let values : Array[HeapValue] = match node.composite {
        Function(ps, rs) => ps.iter().to_array() + rs.iter().to_array()
        Struct(fs) =>
          fs
          .iter()
          .filter_map(f => {
            match f.storage {
              Value(v) => Some(v)
              _ => None
            }
          })
          .to_array()
        Array(f) =>
          match f.storage {
            Value(v) => [v]
            _ => []
          }
      }
      for v in values {
        if v is Ref(_, false, _) {
          self.reader.fail(
            Invalid,
            "shared composite types require shared references",
          )
        }
      }
    }
    if node.supertype is Some(parent) &&
      !context.validate_declared_subtype(i, parent) {
      if context.work_exhausted() {
        self.reader.fail(Unsupported, "core type graph work exceeds 1000000")
      }
      self.reader.fail(Invalid, "invalid declared core subtype")
    }
  }
  self.budget.remaining = context.remaining_work()
  let result = []
  for i in start..<graph.length() {
    let node = graph[i]
    let definition = if node.composite is Function(_, _) {
      match self.reader.function_external(i, false, graph) {
        Func(function) => Definition::Function(function)
        _ => Heap({ types: graph, index: i, })
      }
    } else {
      Heap({ types: graph, index: i, })
    }
    self.definitions.push(definition)
    result.push(definition)
  }
  ReadOnlyArray::from_array(result)
}
