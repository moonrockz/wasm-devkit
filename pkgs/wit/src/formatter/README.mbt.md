# WIT formatter

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
