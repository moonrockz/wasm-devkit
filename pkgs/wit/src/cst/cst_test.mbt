///|
test "concrete token ranges reconstruct subtrees and validate ownership" {
  let tokens = @scanner.scan("name /*comment*/").tokens
  let nodes : Array[@cst.Node] = [
    {
      kind: NamedType,
      span: { start: 0, end: 16, },
      first_token: 0,
      last_token: 3,
      children: [],
    },
    {
      kind: File,
      span: { start: 0, end: 16, },
      first_token: 0,
      last_token: 4,
      children: [0],
    },
  ]
  let tree : @cst.Tree = { tokens, nodes: ReadOnlyArray::from_array(nodes), }
  assert_true(tree.validate())
  assert_eq(tree.node_source(0), Some("name /*comment*/"))
  assert_eq(tree.node_source(1), Some(tree.to_source()))
  assert_eq(tree.node_source(-1), None)
  assert_eq(tree.node_source(2), None)
  nodes[0] = { ..nodes[0], first_token: -1, }
  assert_true(tree.validate())
  let invalid : @cst.Tree = { tokens, nodes: ReadOnlyArray::from_array(nodes), }
  assert_false(invalid.validate())
  assert_eq(invalid.node_source(0), None)
}
