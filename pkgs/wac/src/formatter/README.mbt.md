# WAC formatter

`format(source, indent_width=2, features=Features::default())` normalizes valid WAC layout.
`format_cst(tree, ...)` formats an immutable concrete arena after validating its ranges and
reparsing its source. Both return `Result[String, FormatError]` without mutating the input.
Use the same syntax feature switches as parsing, or `Features::all()` for all implemented forms.

The formatter preserves every non-whitespace token and raw comment in order. Quoted names,
versions, percent escapes, optional commas and comment contents remain unchanged.  Output is checked by reparsing and comparing both AST structure and retained
tokens. This protects WAC package-token boundaries and composition expression structure.

## Layout

Indentation accepts zero through eight spaces and defaults to two. Layout uses LF outside
raw comments and string tokens, a final newline for nonempty content, one declaration per line and multiline
aggregate members and instantiation arguments. Empty blocks, selectors, include rename lists, parameters and generic types
stay inline unless comments require line breaks. There is no width-based wrapping.
A complete WAC document requires its initial package directive; empty input is invalid.

Trailing comments remain before deferred declaration line breaks. Standalone block comments
remain on their own lines. Line comments always end before the next token. Nested block
comment contents and internal line endings are preserved verbatim; CRLF line-comment endings
can therefore remain CRLF even when surrounding layout uses LF. Blank lines in ordinary
whitespace collapse. The resulting layout is idempotent with the same options.

A CST ownership pass identifies declaration and instantiation blocks and inline
selectors. It skips child ranges, so nested types do not cause repeated scans of descendant
tokens. Rendering uses an explicit delimiter stack. Work is linear in nodes, tokens and
emitted characters. Deep block indentation naturally emits more characters than compact input.

## Invalid input

- `InvalidOptions` rejects indentation outside zero through eight.
- `InvalidTree` rejects malformed hand-built concrete arenas.
- `InvalidSyntax(diagnostics)` returns lexical/parser errors, including disabled named-result syntax.
- `InvariantViolation` rejects an internal layout result that cannot preserve tokens and AST structure.

Malformed source is not repaired. Error results contain no partial formatted source, leaving
callers free to retain the original text and report diagnostics. CST reconstruction remains
available for exact malformed-input output.

## Validation

Tests run all 163 pinned parser sources. Valid cases must preserve structure, token spelling,
comments and idempotence; invalid cases must return syntax diagnostics. Snapshots cover
layout, trailing comments, inline selectors, raw/multiline names and comments around groups,
access and instantiation arguments. Another 600 seeded comment-insertion cases exercise
WAC token boundaries. All 45 printable node kinds are covered. Stress cases include 16,000
nested types, groups/access chains and instantiations on wasm, wasm-gc, js and native.
Deep instantiation stress uses zero indentation to bound emitted size. No fixture is skipped.
