# WIT CST

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wit@0.1.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/cst",
  "moonrockz/wit/parser",
} for "test"
```

### Reconstruct a concrete subtree and the complete file

```mbt check
///|
test "README: Reconstruct a concrete subtree and the complete file" {
  let source = "// leading\ninterface api {} // trailing"
  let parsed = @parser.parse(source)
  let concrete : @cst.Tree = parsed.cst
  let root = concrete.nodes.length() - 1
  assert_eq(concrete.to_source(), source)
  assert_eq(concrete.node_source(root), Some(source))
  assert_eq(concrete.node_source(-1), None)
  for id, node in concrete.nodes {
    if node.kind == Interface {
      assert_true(
        concrete.node_source(id).unwrap().contains("interface api {}"),
      )
      assert_true(node.first_token < node.last_token)
    }
  }
}
```

### Validate concrete data before navigating it

```mbt check
///|
test "README: Validate concrete data before navigating it" {
  let empty : @cst.Tree = { tokens: [], nodes: [], }
  assert_false(empty.validate())
  assert_eq(empty.node_source(0), None)
  assert_eq(empty.to_source(), "")
}
```

### Inspect diagnostics while retaining invalid input

```mbt check
///|
test "README: Inspect diagnostics while retaining invalid input" {
  let source = "interface broken { type missing = ; } interface later {}"
  let parsed = @parser.parse(source)
  assert_false(parsed.is_valid())
  assert_false(parsed.diagnostics.is_empty())
  assert_eq(parsed.cst.to_source(), source)
  assert_true(parsed.ast.validate() && parsed.cst.validate())
  assert_true(
    parsed.ast.nodes.any(node => node.data is Interface(name="later", ..)),
  )
}
```

## API contracts

`Tree` holds immutable tokens and concrete grammar nodes. Every source code unit belongs
to a token, including whitespace, comments, malformed input and text skipped during recovery.
`Tree::to_source()` reconstructs the input exactly. `node_source(index)` reconstructs a
subtree's token range or returns `None` for an invalid index/range.

Each node records a WIT AST `Kind`, a half-open UTF-16 span, a half-open raw token range
`first_token..last_token`, and immutable child indices. Nodes use a postorder arena;
AST and CST indices correspond one-to-one in parser output. A child index precedes its
parent. The final node is the file root and includes leading/trailing trivia and EOF.
Other nodes include internal and trailing trivia up to the next significant token.
Zero-width recovery nodes can have empty token ranges.

Punctuation and trivia remain in the token array between grammar children. They are not
synthetic AST children. The [WIT node table](../ast/nodes.md) documents grammar kinds.

`Tree::validate()` checks lossless token tiling, EOF, node/token range agreement, postorder
edges, unique parent ownership, ordered child ranges and containment. Reconstruction,
validation and subtree emission use loops without recursive tree descent.
