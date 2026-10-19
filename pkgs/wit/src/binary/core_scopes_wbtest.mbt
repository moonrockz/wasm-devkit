///|
test "core contract scope graph retains imported instance module aliases" {
  let component = @component.parse_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x01\x50\x02\x01\x60\x00\x00\x03\x01\x66\x00\x00\x07\x10\x01\x42\x02\x02\x00\x10\x02\x01\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x07\x01\x00\x11\x00\x00\x01\x6d\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x69",
  )
  let (annotations, graph) = validate_core_definitions(component)
  assert_eq(annotations.length(), 1)
  assert_eq(graph.length(), 2)
  let root = graph.scope(0).unwrap()
  assert_eq(root.binding(3, 0), Some(Scope(1)))
  assert_eq(root.binding(5, 0), Some(Scope(1)))
  let child = graph.scope(1).unwrap()
  let contract = annotations[0].actual
  assert_eq(child.definition(0), Some(Module(contract)))
  assert_eq(child.exported("m"), Some(Module(contract)))
  assert_eq(root.binding(0x111, 0), Some(Module(contract)))
  assert_eq(root.binding(0x111, 1), Some(Module(annotations[0].expected)))
}

///|
// Both pinned loaders accept this narrowed instance export. The sidecar must
// retain its annotation before any subsequent alias resolves that new index.
test "core contract scopes retain narrowed instance annotations" {
  let component = @component.parse_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x02\x42\x02\x00\x50\x00\x04\x00\x01\x6d\x00\x11\x00\x42\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x09\x01\x00\x01\x69\x05\x00\x01\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62",
  )
  let (_, graph) = validate_core_definitions(component)
  let root = graph.scope(0).unwrap()
  assert_eq(root.binding(5, 0), Some(Scope(1)))
  assert_eq(root.binding(5, 1), Some(Scope(2)))
  assert_eq(graph.scope(1).unwrap().exported("m") is Some(Module(_)), true)
  assert_eq(graph.scope(2).unwrap().exported("m"), None)
}
