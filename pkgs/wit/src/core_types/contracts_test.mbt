///|
test "core contract snapshots retain immutable indexed metadata" {
  let empty : @core_types.Module = { imports: [], exports: [], }
  let definitions : Array[@core_types.Definition] = [Module(empty)]
  let values : Array[@core_types.ContractBinding] = [Module(empty)]
  let entries : Array[(String, @core_types.ContractBinding)] = [
    ("m", Module(empty)),
  ]
  let scope = @core_types.ContractScope::new(
    ReadOnlyArray::from_array(definitions),
    [(0x111, ReadOnlyArray::from_array(values)), (3, [Scope(1)])],
    ReadOnlyArray::from_array(entries),
  )
  definitions.clear()
  values[0] = Other
  entries[0] = ("changed", Other)
  let scopes = [scope]
  let graph = @core_types.ContractGraph::new(ReadOnlyArray::from_array(scopes))
  scopes.clear()
  assert_eq(graph.length(), 1)
  let retained = graph.scope(0).unwrap()
  assert_eq(retained.definition(0), Some(Module(empty)))
  assert_eq(retained.binding(0x111, 0), Some(Module(empty)))
  assert_eq(retained.binding(3, 0), Some(Scope(1)))
  assert_eq(retained.exported("m"), Some(Module(empty)))
  assert_eq(retained.exported("changed"), None)
  assert_eq(retained.definition(-1), None)
  assert_eq(retained.binding(0x111, 1), None)
  assert_eq(retained.binding(5, 0), None)
  assert_eq(graph.scope(1) is None, true)
}

///|
test "core contract graph lookups do not walk caller scope links" {
  let scope = @core_types.ContractScope::new([], [(3, [Scope(0)])], [
    ("self", Scope(0)),
  ])
  let scopes : Array[@core_types.ContractScope] = []
  for _ in 0..<10000 {
    scopes.push(scope)
  }
  let graph = @core_types.ContractGraph::new(ReadOnlyArray::from_array(scopes))
  assert_eq(graph.length(), 10000)
  assert_eq(graph.scope(9999).unwrap().exported("self"), Some(Scope(0)))
  assert_eq(graph.scope(0).unwrap().binding(3, 0), Some(Scope(0)))
  assert_eq(graph.scope(-1) is None, true)
}
