# WAC AST

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
