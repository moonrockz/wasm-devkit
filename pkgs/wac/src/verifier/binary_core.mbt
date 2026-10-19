///|
fn BinaryGraph::core_definition(
  self : BinaryGraph,
  scope_id : Int32,
  bytes : Bytes,
  section : Bool,
) -> Unit raise BinaryFailure {
  let scope = self.scopes[scope_id]
  let outers : Array[ReadOnlyArray[@core_types.Definition]] = []
  let mut parent = scope.parent
  while parent is Some(id) {
    self.step()
    let outer = self.scopes[id]
    for _ in outer.core_types {
      self.step()
    }
    outers.push(ReadOnlyArray::from_array(outer.core_types))
    parent = outer.parent
  }
  for _ in scope.core_types {
    self.step()
  }
  for _ in bytes {
    self.step()
  }
  let current = ReadOnlyArray::from_array(scope.core_types)
  let outers = ReadOnlyArray::from_array(outers)
  let decoded = if section {
    @core_types.decode_section(bytes, current~, outers~)
  } else {
    @core_types.decode_type(bytes, current~, outers~).map(value => {
      ReadOnlyArray::from_array([value])
    })
  }
  let definitions = match decoded {
    Ok(values) => values
    Err(error) => raise Invalid(error.message)
  }
  for definition in definitions {
    scope.core_types.push(definition)
    scope.core_ids.push(
      match definition {
        Module(core) => Some(self.add(Module(core)))
        Function(_) => None
      },
    )
  }
}
