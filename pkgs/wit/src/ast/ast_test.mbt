///|
test "AST snapshots retain typed children after caller arrays change" {
  let items = [0]
  let node : @ast.Node = {
    data: File(items=ReadOnlyArray::from_array(items)),
    span: { start: 0, end: 1, },
  }
  let nodes : Array[@ast.Node] = [
    { data: PrimitiveType(name="u8"), span: { start: 0, end: 1, }, },
    node,
  ]
  let tree : @ast.Tree = { nodes: ReadOnlyArray::from_array(nodes), }
  items[0] = 99
  nodes[0] = { data: NamedType(name="changed"), span: { start: 8, end: 9, }, }
  assert_true(tree.validate())
  assert_eq(tree.root(), Some(1))
  assert_eq(tree.nodes[0].data, PrimitiveType(name="u8"))
  assert_eq(tree.nodes[1].data.children(), ReadOnlyArray::from_array([0]))
}

///|
test "AST validation rejects cycles, reused children, invalid spans and detached nodes" {
  let leaf : @ast.Node = {
    data: PrimitiveType(name="u8"),
    span: { start: 0, end: 1, },
  }
  let cases : Array[Array[@ast.Node]] = [
    [],
    [{ data: OptionType(payload=0), span: { start: 0, end: 1, }, }],
    [leaf, { data: TupleType(elements=[0, 0]), span: { start: 0, end: 1, }, }],
    [leaf, { data: OptionType(payload=0), span: { start: 1, end: 2, }, }],
    [leaf, { data: PrimitiveType(name="u8"), span: { start: 0, end: 1, }, }],
  ]
  for nodes in cases {
    let tree : @ast.Tree = { nodes: ReadOnlyArray::from_array(nodes), }
    assert_false(tree.validate())
  }
}
