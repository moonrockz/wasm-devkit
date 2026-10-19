// Original wasm-devkit free-resource audit for imported contracts.

///|
fn import_local_resources(
  local_types : Array[Bool],
  resources : Array[Int32?],
  budget : Int32,
) -> (Map[Int32, Bool], Int32) raise ComponentValidationError {
  if local_types.length() > budget {
    raise SectionParseError(
      10, "import contract exceeds the verification work limit",
    )
  }
  let locals : Map[Int32, Bool] = Map([])
  for index, is_local in local_types {
    if is_local && resources.get(index) is Some(Some(id)) {
      locals[id] = true
    }
  }
  (locals, budget - local_types.length())
}

///|
// Metadata tables include unused outer definitions. Inspect only members and
// their reachable value graphs: an unused local resource is not a capture.
// Fresh abstract binders have distinct identities and are valid in imports.
fn check_import_resources(
  metadata : ScopedContractMetadata?,
  locals : Map[Int32, Bool],
  budget : Int32,
) -> Int32 raise ComponentValidationError {
  if locals.is_empty() {
    return budget
  }
  guard metadata is Some(metadata) else {
    raise SectionParseError(
      10, "import resource captures require complete scoped contracts",
    )
  }
  let mut remaining = budget
  fn charge() -> Unit raise ComponentValidationError {
    if remaining <= 0 {
      raise SectionParseError(
        10, "import contract exceeds the verification work limit",
      )
    }
    remaining -= 1
  }
  fn resource(id : Int32?) -> Unit raise ComponentValidationError {
    charge()
    if id is Some(id) && locals.contains(id) {
      raise SectionParseError(10, "local resource type found in imports")
    }
  }
  let nodes = [0]
  let seen_nodes : Map[Int32, Bool] = Map([])
  let types : Array[Int32] = []
  let seen_types : Map[Int32, Bool] = Map([])
  fn value(ty : @component.ValType) -> Unit raise ComponentValidationError {
    charge()
    if ty is TypeIdx(index) {
      types.push(index)
    }
  }
  while nodes.pop() is Some(index) {
    charge()
    if seen_nodes.contains(index) {
      continue
    }
    seen_nodes[index] = true
    guard metadata.nodes.get(index) is Some(node) else {
      raise SectionParseError(10, "incomplete imported contract")
    }
    for items in [node.imports, node.exports] {
      for name, sort in items.sorts {
        charge()
        match sort {
          Type => {
            guard items.types.get(name) is Some(index) else {
              raise SectionParseError(10, "incomplete imported type")
            }
            types.push(index)
          }
          Func => {
            guard items.functions.get(name) is Some(signature) &&
              signature.complete is Some(complete) else {
              raise SectionParseError(10, "incomplete imported function")
            }
            // Complete signatures retain only reachable definitions.
            for id in complete.resources {
              resource(id)
            }
          }
          Instance | Component => {
            guard items.children.get(name) is Some(child) else {
              raise SectionParseError(10, "incomplete imported child contract")
            }
            nodes.push(child)
          }
          Core(0x11) => ()
          _ => raise SectionParseError(10, "incomplete imported contract")
        }
      }
    }
  }
  while types.pop() is Some(index) {
    charge()
    if seen_types.contains(index) {
      continue
    }
    seen_types[index] = true
    guard metadata.types.get(index) is Some(Some(td)) else {
      raise SectionParseError(10, "incomplete imported value type")
    }
    resource(metadata.resources.get(index).bind(id => id))
    match td {
      DefValType(_) | Flags(_) | Enum(_) | ResourceType(_, _, _, _) => ()
      List(v) | FixedList(v, _) | Option(v) => value(v)
      MapType(k, v) => {
        value(k)
        value(v)
      }
      Tuple(values) =>
        for v in values {
          value(v)
        }
      Record(fields) =>
        for field in fields {
          value(field.ty)
        }
      Variant(cases) =>
        for item in cases {
          if item.ty is Some(v) {
            value(v)
          }
        }
      Result(ok, err) => {
        if ok is Some(v) {
          value(v)
        }
        if err is Some(v) {
          value(v)
        }
      }
      Future(v) | Stream(v) => if v is Some(v) { value(v) }
      Own(id) | Borrow(id) => value(TypeIdx(id))
      _ => raise SectionParseError(10, "incomplete imported value type")
    }
  }
  remaining
}
