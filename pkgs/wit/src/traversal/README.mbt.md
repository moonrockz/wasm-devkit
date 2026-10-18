# WIT traversal

`Syntax::Ast(tree)` and `Syntax::Cst(tree)` select a typed AST or lossless CST arena.
Both use the [WIT node-kind/field table](../ast/nodes.md) for grammar children.
`View` is immutable node metadata: source arena index, kind, UTF-16 span, absolute depth
and parent index. CST traversal visits grammar nodes; punctuation and trivia remain in
its immutable token array and node token ranges.

All operations validate manually constructed arenas before invoking callbacks. Invalid
input returns `None` for traversal/navigation or `Err(InvalidTree)` for rewriting.
Navigation builds immutable child, parent, sibling-slot and depth tables in linear space.
Readers use an explicit work stack. Neither traversal, navigation nor rewriting descends
recursively through input-controlled syntax nesting.

## Events and control

There is one event kernel for `Reader`, `events`, `walk`, `fold`, `reduce` and cursor
readers. Every complete visit emits `Enter`, children in field order, then `Leave`.
The decision callback runs exactly once per emitted event.

| Decision | On Enter | On Leave |
|----------|----------|----------|
| `Continue` | Visit children, then emit Leave | Continue to the next event |
| `Prune` | Skip descendants, then emit this node's Leave | Continue to the next event |
| `Stop` | Include this event and stop immediately | Include this event and stop immediately |

Stop emits no synthetic leaves for open ancestors. Event prefixes can therefore be
unbalanced after stopping. Every style applies the same decisions at the same point.
`Report` records the emitted event count and whether a callback stopped the stream.

- `Reader::new(syntax, decide=...)` creates a lazy reader. `next()` advances it;
  `iter()` consumes the same private state. `report()` describes consumption so far.
- `events(syntax, decide=...)` collects an immutable event array.
- `walk(syntax, visit)` calls an event visitor returning `Control`.
- `fold(syntax, initial, step)` calls `step(accumulator, event)` for every event and
  returns the final accumulator and report. The step returns its next accumulator and control.
- `reduce(syntax, combine, decide=...)` combines a node with immutable child summaries
  on Leave. A pruned node has no child summaries. Its result contains an optional root
  summary and report. An early stop can leave no complete root summary.

Use the same initial callback state when comparing stateful policies across readers.
An iterator consumer can pause consumption without requesting `Stop` and resume later.

## Immutable cursors

`Cursor::root(syntax)` returns an immutable position. `child(slot)`, `parent()`,
`next_sibling()` and `previous_sibling()` return new positions or `None` at boundaries.
They share navigation tables and move in constant time without copying ancestry paths.
Earlier cursor values remain unchanged. `view()`, `ast_node()` and `concrete_node()`
expose immutable values; the latter two return `None` for the other syntax representation.

`next_preorder(control=Continue)` provides node-only preorder navigation, with prune/stop
applied to the current node. `reader(decide=...)` provides canonical enter/leave events
for the cursor's subtree. Depth and parent metadata remain absolute in the source tree.

## Immutable AST rewrites

`rewrite(tree, edit, decide=...)` visits the AST bottom-up. Its callback receives source
`View` metadata and a candidate node whose children already refer to rewritten output IDs.
The callback can return:

- `Keep` to retain the candidate, including rewritten children.
- `Replace(data)` to replace its typed data while keeping the source span. Child references
  must use valid rewritten output IDs, normally taken from the candidate's named fields.
- `Subtree(tree)` to import a standalone immutable tree. Its root receives the replaced
  node's span; other imported nodes receive zero-width spans at that source start. Generated
  locations preserve containment and child order without pretending to refer to old text.

Pruned descendants are copied unchanged; the pruned root remains editable. Stop returns
the original tree. Earlier edit callbacks may already have run, so caller-owned side effects
are not undone. The original AST is never mutated, including on invalid edits or cancellation.

A final explicit reachability pass removes dropped nodes and remaps references. Invalid
references, shared children, cycles, span containment or child-order violations return
`InvalidReplacement`. Successful results contain a validated immutable tree and the event
report. `Data::map_children` remaps only direct references while preserving typed field shapes.

## Immutable CST source edits

`rewrite_cst(tree, edits, features=...)` applies ordered, nonoverlapping `TextEdit` values.
Spans count UTF-16 units. Equal-position insertions retain collection order. Invalid ranges
return `InvalidTextEdit`; invalid input arenas return `InvalidTree`.

The edited source is reparsed with the supplied proposal profile, producing consistent new
AST/CST arenas and diagnostics. Malformed resulting syntax is returned as parse data, retaining
its exact text. The original concrete tree and token collection remain unchanged. Parsing and
source construction use loops and explicit stacks, including for edits that split a surrogate pair.

## Validation

Tests assert a concrete source-order event trace, AST/CST correspondence, prune/stop behavior
across every style, cursor boundaries, bottom-up summaries, identity and shape-changing rewrites,
subtree imports, cancellation, malformed edits and original-tree preservation. Child remapping
exercises all 35 documented kinds. Seeded properties cover 400 traversal policies and 400 rewrite
cases per target. A 16,000-level type case exercises readers, cursors, reductions, rewrites and
concrete reparsing on wasm, wasm-gc, js and native.
