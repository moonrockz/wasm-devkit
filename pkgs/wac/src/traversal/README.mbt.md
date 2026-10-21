# WAC traversal

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.3.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/traversal",
  "moonrockz/wac/parser",
  "moonrockz/wac/ast",
} for "test"
```

### Use the same source-order events for AST and CST

```mbt check
///|
test "README: Use the same source-order events for AST and CST" {
  let parsed = @parser.parse(
    "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
  )
  let ast = @traversal.events(Ast(parsed.ast)).unwrap()
  let cst = @traversal.events(Cst(parsed.cst)).unwrap()
  assert_eq(ast, cst)
  assert_eq(ast.length(), parsed.ast.nodes.length() * 2)
  assert_eq(ast[0].phase, Enter)
  assert_eq(ast[ast.length() - 1].phase, Leave)
}
```

### Stop a search and prune signatures

```mbt check
///|
test "README: Stop a search and prune signatures" {
  let parsed = @parser.parse(
    "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
  )
  let visited = []
  let report = @traversal.walk(Ast(parsed.ast), event => {
    if event.phase == Enter {
      visited.push(event.view.kind)
    }
    if event.phase == Enter && event.view.kind == Signature {
      Prune
    } else if event.phase == Leave && event.view.kind == Function {
      Stop
    } else {
      Continue
    }
  }).unwrap()
  assert_true(report.stopped)
  assert_true(visited.contains(Signature))
  assert_false(visited.contains(Parameter))
  // Stop includes its event and does not add leaves for open ancestors.
  assert_true(report.events < parsed.ast.nodes.length() * 2)
}
```

### Pause a reader and then consume its remaining events

```mbt check
///|
test "README: Pause a reader and then consume its remaining events" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  let reader = @traversal.Reader::new(Ast(parsed.ast)).unwrap()
  let first = reader.next().unwrap()
  assert_eq(first.phase, Enter)
  assert_eq(reader.report().events, 1)
  let remaining = reader.iter().to_array()
  assert_eq(remaining.length() + 1, parsed.ast.nodes.length() * 2)
  assert_eq(reader.next(), None)
  assert_false(reader.report().stopped)
}
```

### Count function declarations without double-counting leave events

```mbt check
///|
test "README: Count function declarations without double-counting leave events" {
  let parsed = @parser.parse(
    "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
  )
  let (count, report) = @traversal.fold(Ast(parsed.ast), 0, (count, event) => {
    let increment = if event.phase == Enter && event.view.kind == Function {
      1
    } else {
      0
    }
    (count + increment, Continue)
  }).unwrap()
  assert_eq(count, 2)
  assert_eq(report.events, parsed.ast.nodes.length() * 2)
}
```

### Summarize a subtree from its children upward

```mbt check
///|
test "README: Summarize a subtree from its children upward" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  let reduced = @traversal.reduce(Cst(parsed.cst), (
    _view,
    children : ReadOnlyArray[Int32],
  ) => children.fold(init=1, (total, child_count) => total + child_count)).unwrap()
  assert_eq(reduced.value, Some(parsed.cst.nodes.length()))
  let stopped = @traversal.reduce(
    Ast(parsed.ast),
    (_view, _children : ReadOnlyArray[Int32]) => 1,
    decide=_event => Stop,
  ).unwrap()
  assert_eq(stopped.value, None)
  assert_true(stopped.report.stopped)
}
```

### Navigate siblings while keeping earlier cursor positions

```mbt check
///|
test "README: Navigate siblings while keeping earlier cursor positions" {
  let parsed = @parser.parse(
    "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
  )
  let root = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
  let interface = root.child(1).unwrap()
  let first = interface.child(0).unwrap()
  let second = first.next_sibling().unwrap()
  assert_eq(first.view().kind, Function)
  assert_eq(second.previous_sibling().unwrap().view(), first.view())
  assert_eq(second.parent().unwrap().view(), interface.view())
  assert_eq(root.view().kind, File)
  assert_true(root.parent() is None)
  assert_true(first.ast_node() is Some(_))
  assert_true(first.concrete_node() is None)
  let concrete = @traversal.Cursor::root(Cst(parsed.cst)).unwrap()
  assert_true(concrete.concrete_node() is Some(_))
  assert_true(concrete.ast_node() is None)
}
```

### Read a cursor subtree with absolute depth metadata

```mbt check
///|
test "README: Read a cursor subtree with absolute depth metadata" {
  let parsed = @parser.parse(
    "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
  )
  let root = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
  let interface = root.child(1).unwrap()
  let first = interface.child(0).unwrap()
  let events = first.reader().iter().to_array()
  assert_eq(events[0].view.index, first.view().index)
  assert_eq(events[0].view.depth, 2)
  assert_eq(events[0].view.parent, Some(interface.view().index))
  assert_eq(
    first.next_preorder(control=Prune).unwrap().view(),
    first.next_sibling().unwrap().view(),
  )
  assert_true(first.next_preorder(control=Stop) is None)
}
```

### Change a type without mutating the parsed tree

```mbt check
///|
test "README: Change a type without mutating the parsed tree" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  let changed = @traversal.rewrite(parsed.ast, (_view, node) => {
    match node.data {
      PrimitiveType(name="u8") => Replace(PrimitiveType(name="u64"))
      _ => Keep
    }
  }).unwrap()
  assert_true(changed.tree.validate())
  assert_true(
    parsed.ast.nodes.any(node => node.data == PrimitiveType(name="u8")),
  )
  assert_false(
    changed.tree.nodes.any(node => node.data == PrimitiveType(name="u8")),
  )
  assert_true(
    changed.tree.nodes.any(node => node.data == PrimitiveType(name="u64")),
  )
}
```

### Compose rewrites using candidate child IDs

The replacement fragment adds a node before its parent is edited. The parent callback
uses the candidate's output child ID. Looking that ID up in the original arena would be
incorrect. Imported fragments are copied as supplied; the callback does not revisit their nodes.

```mbt check
///|
test "README: Compose rewrites using candidate child IDs" {
  let original = @parser.parse(
      "package demo:app; interface api { type wrapped = option<u8>; }",
    ).ast
  let fragment : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="bool"), span: { start: 0, end: 0, }, },
      { data: OptionType(payload=0), span: { start: 0, end: 0, }, },
    ],
  }
  let changed = @traversal.rewrite(original, (_view, candidate) => {
    match candidate.data {
      PrimitiveType(name="u8") => Subtree(fragment)
      OptionType(payload~) => Replace(ListType(element=payload))
      _ => Keep
    }
  }).unwrap()
  let expected = @parser.parse(
      "package demo:app; interface api { type wrapped = list<option<bool>>; }",
    ).ast
  assert_true(changed.tree.equivalent(expected))
  assert_true(original.nodes.any(node => node.data == PrimitiveType(name="u8")))
}
```

### Replace a leaf with a standalone immutable fragment

Imported fragments are reanchored at the replaced node. Their input spans do not
claim locations in the new source. Keep the original tree for source navigation.

```mbt check
///|
test "README: Replace a leaf with a standalone immutable fragment" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  let fragment : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="bool"), span: { start: 0, end: 0, }, },
      { data: OptionType(payload=0), span: { start: 0, end: 0, }, },
    ],
  }
  let changed = @traversal.rewrite(parsed.ast, (_view, node) => {
    if node.data == PrimitiveType(name="u8") {
      Subtree(fragment)
    } else {
      Keep
    }
  }).unwrap()
  assert_true(changed.tree.validate())
  assert_eq(changed.tree.nodes.length(), parsed.ast.nodes.length() + 1)
  assert_eq(fragment.nodes[1].span, { start: 0, end: 0, })
}
```

### Cancel a rewrite or reject an invalid replacement

```mbt check
///|
test "README: Cancel a rewrite or reject an invalid replacement" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  let cancelled = @traversal.rewrite(parsed.ast, (_view, _node) => Keep, decide=_event => {
    Stop
  }).unwrap()
  assert_true(cancelled.report.stopped)
  assert_eq(cancelled.tree, parsed.ast)
  let invalid = @traversal.rewrite(parsed.ast, (_view, _node) => {
    Replace(OptionType(payload=-1))
  })
  assert_true(invalid is Err(InvalidReplacement(_)))
}
```

### Apply an editor change while preserving surrounding comments

A node span can include following trivia. For an editor replacement, select the
precise token range when that trivia must stay unchanged.

```mbt check
///|
test "README: Apply an editor change while preserving surrounding comments" {
  let source = "// keep\npackage demo:app; interface api { type byte = u8; }"
  let parsed = @parser.parse(source)
  let byte_type = parsed.ast.nodes
    .iter()
    .find_first(node => node.data == PrimitiveType(name="u8"))
    .unwrap()
  let changed = @traversal.rewrite_cst(parsed.cst, [
    { span: byte_type.span, text: "u64", },
  ]).unwrap()
  assert_true(changed.is_valid())
  assert_true(changed.cst.to_source().contains("type byte = u64;"))
  assert_true(changed.cst.to_source().has_prefix("// keep\n"))
  assert_eq(parsed.cst.to_source(), source)
}
```

### Distinguish bad edit ranges from invalid edited syntax

```mbt check
///|
test "README: Distinguish bad edit ranges from invalid edited syntax" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  let bad_range = @traversal.rewrite_cst(parsed.cst, [
    { span: { start: -1, end: 0, }, text: "", },
  ])
  assert_true(bad_range is Err(InvalidTextEdit(0)))
  let damaged = @traversal.rewrite_cst(parsed.cst, [
    { span: { start: 0, end: 0, }, text: "?", },
  ]).unwrap()
  // Applying a valid edit succeeds even when the new document is invalid.
  assert_false(damaged.is_valid())
  assert_true(damaged.cst.to_source().has_prefix("?"))
}
```

## API contracts

`Syntax::Ast(tree)` and `Syntax::Cst(tree)` select a typed AST or lossless CST arena.
Both use the [WAC node-kind/field table](../ast/nodes.md) for grammar children.
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

The edited source is reparsed with the supplied syntax profile, producing consistent new
AST/CST arenas and diagnostics. Malformed resulting syntax is returned as parse data, retaining
its exact text. The original concrete tree and token collection remain unchanged. Parsing and
source construction use loops and explicit stacks, including for edits that split a surrogate pair.

## Validation

Tests assert a concrete source-order event trace, AST/CST correspondence, prune/stop behavior
across every style, cursor boundaries, bottom-up summaries, identity and shape-changing rewrites,
subtree imports, cancellation, malformed edits and original-tree preservation. Child remapping
exercises all 46 documented kinds. Seeded properties cover 400 traversal policies and 400 rewrite
cases per target. A 16,000-level type case and 12,000-level grouped/access and instantiation cases exercise
readers, cursors, reductions, rewrites and concrete reparsing on wasm, wasm-gc, js and native.
