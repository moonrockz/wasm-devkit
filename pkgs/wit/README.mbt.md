# moonrockz/wit

WIT language tooling for MoonBit.

Source positions, structured diagnostics, lossless lexical analysis, typed immutable ASTs/CSTs,
recovering syntax parsing, immutable traversal, rewrites, canonical printing and comment-preserving
formatting are implemented for the documented grammar profile.
This module has not been published.

`@scanner.scan(source)` returns immutable tokens and diagnostics. `Scan::to_source()`
reconstructs the exact input. Lexical success does not imply syntactic validity.
See the scanner package for the lexical profile and diagnostic codes.

`@parser.parse(source)` returns a typed AST arena, a lossless CST arena and diagnostics.
`Parse::is_valid()` checks for errors. Parsing performs no I/O, never raises, and uses
explicit grammar continuations rather than recursive descent. See the parser package for
supported syntax, proposal switches and remaining compatibility validation.

## Scope

Package declarations, interfaces, worlds, types, functions, resources, use/include declarations and explicitly selected proposal-gated constructs.

Syntax parsing is separate from semantic resolution. Cross-file/package loading, name resolution,
registry access and binding generation belong in later semantic tooling.
The syntax parser must not perform I/O.

## Packages

| Package | Intended responsibility |
|---------|-------------------------|
| `span` | Implemented: source text, UTF-16 positions, checked slices and span containment |
| `diagnostic` | Implemented: codes, severity, immutable source labels and recovery details |
| `scanner` | Implemented: lossless tokens, comments, whitespace and lexical diagnostics |
| `ast` | Implemented: typed immutable nodes, named child fields and structural validation |
| `cst` | Implemented: lossless grammar hierarchy, token ranges and subtree reconstruction |
| `parser` | Implemented: recovering grammar parser and explicit proposal switches |
| `traversal` | Implemented: AST/CST walks, folds, reductions, events, immutable cursors and rewrites |
| `printer` | Implemented: stack-safe canonical AST emission with structural round-trip checks |
| `formatter` | Implemented: CST-aware layout preserving comment text, token order and meaning |

## Validation

The lexical layer has acceptance examples, 2,400 seeded property cases per target,
exact token/span reconstruction laws and a 30,000-level nested comment stress case.
Tests also exercise malformed UTF-16 and string escapes. All run on wasm, wasm-gc, js and native.

The parser adds 68 pinned specification examples and 321 upstream WIT files with a licensed fixture manifest,
1,900 seeded property cases, 20,000 nested types, 10,000 missing type closers and
2,000 nested packages per target. AST/CST validation checks postorder references,
unique parents, child order and span containment.

Traversal adds 800 seeded equivalence/rewrite cases per target and a 16,000-level
stress case for readers, cursors, reductions, AST rewrites and CST source edits.

Printing and formatting run all 389 pinned fixture sources, 1,000 seeded type/comment
properties, 18,000 nested type constructors and 1,200 nested package blocks per target.
Printer output preserves AST structure apart from locations and arena numbering.
Formatter output retains non-whitespace tokens and raw comments and is idempotent.
Malformed source returns diagnostics without partial formatted output.

`@printer.print(tree)` emits canonical source. `@formatter.format(source)` and
`format_cst(tree)` normalize layout using the selected parser feature profile.
Both accept `indent_width`, defaulting to two spaces, and return explicit errors.
The printer supports all implemented proposal forms; the formatter accepts the same
feature switches as parsing. Read each package for recovery and invalid-input behavior.

See root Beads epic `wasm-devkit-p5m` for implementation work.
