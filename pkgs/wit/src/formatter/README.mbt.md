# WIT formatter

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wit@0.1.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/formatter",
  "moonrockz/wit/parser",
} for "test"
```

### Format source while preserving comments and meaning

```mbt check
///|
test "README: Format source while preserving comments and meaning" {
  let source = "// keep\ninterface api{type byte=u8;}"
  let formatted = @formatter.format(source).unwrap()
  assert_true(formatted.has_prefix("// keep\n"))
  assert_true(formatted.contains("type byte = u8;"))
  assert_eq(@formatter.format(formatted), Ok(formatted))
  assert_true(
    @parser.parse(source).ast.equivalent(@parser.parse(formatted).ast),
  )
}
```

### Reuse a concrete tree with the same extension profile

```mbt check
///|
test "README: Reuse a concrete tree with the same extension profile" {
  let source = "interface api { type bytes = list<u8, 16>; }"
  let features = { ..@parser.Features::default(), fixed_lists: true, }
  let parsed = @parser.parse(source, features~)
  assert_true(parsed.is_valid())
  let formatted = @formatter.format_cst(parsed.cst, features~, indent_width=2).unwrap()
  assert_eq(@formatter.format(formatted, features~), Ok(formatted))
  assert_eq(parsed.cst.to_source(), source)
}
```

### Keep invalid input unchanged and report formatting errors

```mbt check
///|
test "README: Keep invalid input unchanged and report formatting errors" {
  let source = "interface broken { type missing = ; } interface later {}"
  match @formatter.format(source) {
    Err(InvalidSyntax(diagnostics)) => assert_false(diagnostics.is_empty())
    _ => fail("expected syntax diagnostics")
  }
  assert_eq(@parser.parse(source).cst.to_source(), source)
  assert_eq(@formatter.format(source, indent_width=-1), Err(InvalidOptions))
}
```

## API contracts

`format(source, indent_width=2, features=Features::default())` normalizes valid WIT layout.
`format_cst(tree, ...)` formats an immutable concrete arena after validating its ranges and
reparsing its source. Both return `Result[String, FormatError]` without mutating the input.
Use the same proposal feature switches as parsing, or `Features::all()` for all implemented forms.

The formatter preserves every non-whitespace token and raw comment in order. Quoted names,
versions, percent escapes, optional commas and comment contents remain unchanged. A leading
BOM is retained. Output is checked by reparsing and comparing both AST structure and retained
tokens. This protects whitespace-sensitive named interface imports and package paths.

## Layout

Indentation accepts zero through eight spaces and defaults to two. Layout uses LF outside
raw comments, a final newline for nonempty content, one declaration per line and multiline
aggregate members. Empty blocks, selectors, include rename lists, parameters and generic types
stay inline unless comments require line breaks. There is no width-based wrapping.
Whitespace-only input becomes empty, except for a retained leading BOM.

Trailing comments remain before deferred declaration line breaks. Standalone block comments
remain on their own lines. Line comments always end before the next token. Nested block
comment contents and internal line endings are preserved verbatim; CRLF line-comment endings
can therefore remain CRLF even when surrounding layout uses LF. Blank lines in ordinary
whitespace collapse. The resulting layout is idempotent with the same options.

A CST ownership pass identifies namespace/path punctuation, declaration blocks and inline
selectors. It skips child ranges, so nested types do not cause repeated scans of descendant
tokens. Rendering uses an explicit delimiter stack. Work is linear in nodes, tokens and
emitted characters. Deep block indentation naturally emits more characters than compact input.

## Invalid input

- `InvalidOptions` rejects indentation outside zero through eight.
- `InvalidTree` rejects malformed hand-built concrete arenas.
- `InvalidSyntax(diagnostics)` returns lexical/parser errors, including disabled proposal syntax.
- `InvariantViolation` rejects an internal layout result that cannot preserve tokens and AST structure.

Malformed source is not repaired. Error results contain no partial formatted source, leaving
callers free to retain the original text and report diagnostics. CST reconstruction remains
available for exact malformed-input output.

## Validation

Tests run all 389 pinned parser fixture sources. Valid cases must preserve structure, comments
and idempotence; invalid cases must return syntax diagnostics. Focused snapshots cover layout,
trailing comments, inline selectors, multiline/nested comments, named-import disambiguation,
BOM and CRLF behavior. Another 600 seeded comment-insertion cases exercise token boundaries.
Stress cases include 18,000 nested types and 1,200 nested package blocks on wasm, wasm-gc,
js and native. No fixture is skipped to avoid a printing or formatting failure.
