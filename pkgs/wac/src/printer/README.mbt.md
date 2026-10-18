# WAC printer

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.1.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/printer",
  "moonrockz/wac/parser",
  "moonrockz/wac/ast",
} for "test"
```

### Emit canonical source and check a structural round trip

```mbt check
///|
test "README: Emit canonical source and check a structural round trip" {
  let parsed = @parser.parse(
    "package demo:app; interface api { type byte = u8; }",
  )
  assert_true(parsed.is_valid())
  let printed = @printer.print(parsed.ast, indent_width=4).unwrap()
  let again = @parser.parse(printed)
  assert_true(again.is_valid())
  assert_true(parsed.ast.equivalent(again.ast))
  assert_eq(@printer.print(again.ast, indent_width=4), Ok(printed))
  assert_true(printed.contains("    type byte = u8;"))
}
```

### Reject a fragment or invalid printer options

```mbt check
///|
test "README: Reject a fragment or invalid printer options" {
  let fragment : @ast.Tree = {
    nodes: [{ data: PrimitiveType(name="u8"), span: { start: 0, end: 2, }, }],
  }
  assert_true(fragment.validate())
  assert_eq(@printer.print(fragment), Err(InvalidRoot))
  assert_eq(@printer.print(fragment, indent_width=9), Err(InvalidOptions))
  let empty : @ast.Tree = { nodes: [], }
  assert_eq(@printer.print(empty), Err(InvalidTree))
}
```

## API contracts

`print(tree, indent_width=2)` returns canonical WAC source for a complete file AST.
It returns `Result[String, PrintError]` and never returns partial output.
All syntax descent uses an explicit command stack. The printer supports every
implemented WAC node, including typed composition expressions and named-result extensions.

Printing emits valid source and checks that parsing it preserves the typed AST,
ignoring source locations and arena numbering. `Tree::equivalent(other)` implements
that comparison with an explicit pair stack. Named field roles, optional/list shapes,
function flags, names and scalar metadata still participate in equality.

## Canonical layout

Output uses LF line endings, a final newline for nonempty files, one declaration per
line and block indentation. Empty blocks stay inline. Records, flags, enums and variants
put members on separate lines. Use selectors, include renames, parameters and generic
types remain inline. There is no width-based wrapping. `indent_width` accepts zero through
eight spaces. Printing the same AST with the same options is deterministic.

Reserved identifiers receive `%` escapes. Namespace/package colons stay tight, while
field and named-import colons receive a following space. Raw quoted names retain their
backslashes and quoted/identifier distinction. Groups and access chains remain explicit.
Optional trailing commas, empty include rename lists, absent result placeholders and
empty-arrow result spellings normalize from AST fields. Package path component spellings
are retained, including percent escapes.

The AST omits trivia, so use the formatter to retain comments from concrete source.
ASTs also omit proposal activation state. Printed source is checked with all implemented
features enabled; callers can apply a narrower parser profile when needed.

## Invalid input

| Error | Meaning |
|-------|---------|
| `InvalidTree` | Arena references, ownership, spans or child order are invalid |
| `InvalidRoot` | The root is not a complete file |
| `InvalidOptions` | Indentation is outside zero through eight |
| `RecoveryNode(index)` | A retained error node cannot be printed as valid WAC |
| `Unrepresentable` | The typed fields cannot round-trip through supported WAC syntax |

A recovered AST without error nodes can still be representable, for example after a
missing delimiter. Callers requiring valid original source must inspect `Parse::is_valid()`
before printing. Semantic resolution remains separate from syntax printing.

## Validation

Every printable node kind is covered, with explicit rejection of recovery nodes.
Tests run all 163 pinned WAC files from the parser's licensed snapshots. Any successful
print must reparse to equivalent structure and print identically again. Tests include all
45 printable kinds, 400 seeded mixed composition cases, reserved and raw names, invalid
hand-built trees and 16,000 nested types, groups/access chains and instantiations on wasm,
wasm-gc, js and native. Deep composition stress uses zero indentation to keep emitted size
linear; block indentation otherwise naturally emits more characters than compact input.
