# WIT CST

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
