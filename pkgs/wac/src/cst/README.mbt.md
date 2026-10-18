# WAC CST

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
