# WIT AST

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
