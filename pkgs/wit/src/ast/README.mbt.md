# WIT AST

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wit@0.1.1`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/ast",
  "moonrockz/wit/parser",
} for "test"
```

### Inspect typed fields instead of reparsing source text

```mbt check
///|
test "README: Inspect typed fields instead of reparsing source text" {
  let parsed = @parser.parse("interface api { type byte = u8; }")
  assert_true(parsed.is_valid())
  let tree : @ast.Tree = parsed.ast
  let mut alias_count = 0
  for node in tree.nodes {
    if node.data is Alias(name~, ty~, ..) {
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
  let compact = @parser.parse("interface api { type byte = u8; }").ast
  let spaced = @parser.parse("interface api {  type byte = u8;  }").ast
  assert_true(compact.equivalent(spaced))
  let changed = @parser.parse("interface api { type byte = u64; }").ast
  assert_false(compact.equivalent(changed))
}
```

## API contracts

`Data` is a typed enum with named fields for each WIT construct. `Node` adds a UTF-16
source span. `Tree::nodes` is a `ReadOnlyArray[Node]`; every child reference is a zero-based
index into that arena, preceding its parent. The final node is the root. `Tree::root()`
returns its index or `None` for a manually constructed empty arena.

[Node fields](nodes.md) is the language's node-kind/field table. `Data::kind()` gives the
discriminant; `Data::children()` returns immutable child indices in source field order.
Parser acceptance tests exercise every kind, including recovery nodes.
`Data::map_children(replace)` remaps only direct references while preserving named fields,
list lengths, optional shapes and scalar metadata. Traversal tests check every kind
against `children()` and identity mapping.

Names omit the identifier's leading `%`; case is retained. `Path` separates namespaces,
slash-delimited segments and an optional checked semantic version. `Attribute::value`
contains a feature identifier, a version, or the raw quoted WebAssembly name literal for
`external-id`. Function signatures distinguish ordinary functions, getters and setters.

ASTs omit formatting trivia. Spans are half-open UTF-16 ranges and can include trailing
trivia up to the next significant token. Missing syntax can produce zero-width `Error`
children, empty names and diagnostics. `Error::recovered` retains annotated malformed items.
A child in any semantic role can be an `Error` node after recovery.

`Tree::validate()` checks structural invariants with loops: valid span ranges, postorder
edges, exactly one parent per non-root node, containment and nonoverlapping child order.
It does not perform name resolution or check whether a manually constructed AST is legal WIT.
Public constructors accept immutable collections. Use `ReadOnlyArray::from_array` to copy
mutable builder arrays. No recursive node references or mutable backing arrays are exposed.

`Tree::equivalent(other)` compares valid tree structure while ignoring source spans and
arena numbering. An explicit pair stack follows corresponding typed child roles. Scalar
metadata, list lengths and optional-field shapes remain significant. Invalid trees return false.
