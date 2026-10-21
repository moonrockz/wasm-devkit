# WAC AST

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.3.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/ast",
  "moonrockz/wac/parser",
} for "test"
```

### Inspect typed fields instead of reparsing source text

```mbt check
///|
test "README: Inspect typed fields instead of reparsing source text" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  assert_true(parsed.is_valid())
  let tree : @ast.Tree = parsed.ast
  let mut alias_count = 0
  for node in tree.nodes {
    if node.data is Alias(name~, ty~) {
      alias_count += 1
      assert_eq(name, "byte")
      assert_eq(tree.nodes[ty].data, PrimitiveType(name="u8"))
      assert_true(node.span.contains(tree.nodes[ty].span))
    }
  }
  assert_eq(alias_count, 1)
}
```

### Inspect direct children and their typed role

Child IDs belong to one arena. `map_children` remaps direct references; use
`traversal.rewrite` to replace nodes throughout a complete tree.

```mbt check
///|
test "README: Inspect direct children and their typed role" {
  let data : @ast.Data = OptionType(payload=3)
  assert_eq(data.kind(), OptionType)
  assert_eq(data.children(), [3])
  let remapped = data.map_children(id => id + 10)
  assert_eq(remapped, OptionType(payload=13))
  assert_eq(data.children(), [3])
}
```

### Build an immutable replacement fragment

```mbt check
///|
test "README: Build an immutable replacement fragment" {
  let nodes : Array[@ast.Node] = [
    { data: PrimitiveType(name="u8"), span: { start: 0, end: 2, }, },
    { data: OptionType(payload=0), span: { start: 0, end: 4, }, },
  ]
  let tree : @ast.Tree = { nodes: ReadOnlyArray::from_array(nodes), }
  nodes[0] = { data: PrimitiveType(name="bool"), span: { start: 0, end: 2, }, }
  assert_true(tree.validate())
  assert_eq(tree.root(), Some(1))
  assert_eq(tree.nodes[0].data, PrimitiveType(name="u8"))
  let empty : @ast.Tree = { nodes: [], }
  assert_eq(empty.root(), None)
  assert_false(empty.validate())
}
```

### Reject an arena with an unowned node

```mbt check
///|
test "README: Reject an arena with an unowned node" {
  let tree : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="u8"), span: { start: 0, end: 2, }, },
      { data: PrimitiveType(name="u16"), span: { start: 0, end: 3, }, },
    ],
  }
  // Node 0 is not a child of the final root node.
  assert_false(tree.validate())
}
```

### Compare trees across formatting changes

```mbt check
///|
test "README: Compare trees across formatting changes" {
  let compact = @parser.parse(
      "package demo:app; interface api { type byte = u8; }",
    ).ast
  let spaced = @parser.parse(
      "package demo:app; interface api {  type byte = u8;  }",
    ).ast
  assert_true(compact.equivalent(spaced))
  let changed = @parser.parse(
      "package demo:app; interface api { type byte = u64; }",
    ).ast
  assert_false(compact.equivalent(changed))
}
```

## API contracts

`Tree` is an immutable postorder arena of typed `Node { data, span }` values.
The root is the last node. `Data` has named fields for each construct; child references
are integer indices into the same arena. Every child precedes its parent. `ReadOnlyArray`
fields do not expose mutable backing storage. [nodes.md](nodes.md) is the node-kind and
field table shared with the CST, with concrete syntax coverage in parser tests.

`Data::kind()`, `children()` and `map_children()` provide exhaustive field-aware operations.
`Tree::validate()` checks ranges, backward edges, unique ownership, containment and source
child order. It validates structure rather than language semantics. `Tree::equivalent()`
compares typed structure while ignoring spans and arena index numbering, using a heap stack.

Locations use half-open UTF-16 spans. Identifiers omit their initial percent escape, except
`Path` components, which retain package/local key spelling. Quoted `Name` and `Access` values
omit quotation delimiters and retain raw backslashes. Their `quoted` fields preserve the
spelling distinction used by WAC name inference. Groups remain explicit nodes. `Error`
retains malformed/recovered structure. Comments and whitespace belong to the CST.

The syntax model is independent of WIT. It does not resolve names, fetch packages or
instantiate compositions. The parser README defines its pinned grammar profile.
