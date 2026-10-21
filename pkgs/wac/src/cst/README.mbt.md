# WAC CST

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.3.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/cst",
  "moonrockz/wac/parser",
} for "test"
```

### Reconstruct a concrete subtree and the complete file

```mbt check
///|
test "README: Reconstruct a concrete subtree and the complete file" {
  let source = "// leading\npackage demo:app; interface api {} // trailing"
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
  let source = "package demo:app; interface broken { type missing = ; } interface later {}"
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

`Tree` holds immutable raw tokens and a postorder arena of concrete grammar nodes.
Each node has a `Kind`, UTF-16 source span, half-open token range and immutable child IDs.
AST and CST node indices correspond one-to-one in a parser result.

`to_source()` reconstructs all input, including malformed text and leading/trailing trivia.
`node_source(id)` reconstructs a node range or returns `None` for an invalid range.
Nodes own internal and following trivia up to the next significant token; the root
includes all tokens and EOF. Sibling ranges do not overlap. Syntax punctuation can
belong directly to a parent rather than a child.

`validate()` checks contiguous token ownership, EOF, node ranges, postorder edges,
unique parents, containment and source child order. It uses loops over the arenas.
The [AST node table](../ast/nodes.md) documents grammar kinds.
