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

///|
test "equivalence ignores locations and arena numbering while retaining roles" {
  let a : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="u8"), span: { start: 0, end: 1, }, },
      { data: PrimitiveType(name="string"), span: { start: 1, end: 2, }, },
      { data: TupleType(elements=[0, 1]), span: { start: 0, end: 2, }, },
    ],
  }
  let b : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="string"), span: { start: 20, end: 21, }, },
      { data: PrimitiveType(name="u8"), span: { start: 10, end: 11, }, },
      { data: TupleType(elements=[1, 0]), span: { start: 10, end: 21, }, },
    ],
  }
  assert_true(a.equivalent(b))
  let ok : @ast.Tree = {
    nodes: [
      a.nodes[0],
      { data: ResultType(ok=Some(0), error=None), span: { start: 0, end: 1, }, },
    ],
  }
  let error : @ast.Tree = {
    nodes: [
      a.nodes[0],
      { data: ResultType(ok=None, error=Some(0)), span: { start: 0, end: 1, }, },
    ],
  }
  assert_false(ok.equivalent(error))
  let empty : @ast.Tree = { nodes: [], }
  assert_false(empty.equivalent(empty))
}
