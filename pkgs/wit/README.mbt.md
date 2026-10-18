# moonrockz/wit

WIT language tooling for MoonBit.

Source positions, structured diagnostics and lossless lexical analysis are implemented.
ASTs, CSTs, parsing, traversal, printing and formatting remain unimplemented.
This module has not been published.

`@scanner.scan(source)` returns immutable tokens and diagnostics. `Scan::to_source()`
reconstructs the exact input. Lexical success does not imply syntactic validity.
See the scanner package for the lexical profile and diagnostic codes.

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
| `ast` | Immutable typed nodes and child collections |
| `cst` | Immutable lossless concrete structure, including malformed input |
| `parser` | Recovering source-to-AST/CST parsing with diagnostics |
| `traversal` | Explicit-stack walks, folds, reductions, events, cursors and immutable rewrites |
| `printer` | Stack-safe canonical AST-to-source emission |
| `formatter` | Stack-safe CST formatting that preserves comments and meaning |

## Validation

The lexical layer has acceptance examples, 2,400 seeded property cases per target,
exact token/span reconstruction laws and a 30,000-level nested comment stress case.
Tests also exercise malformed UTF-16 and string escapes. All run on wasm, wasm-gc, js and native.

Remaining validation for the syntax frontend and later packages:

- Upstream valid and invalid fixtures pinned to the reference linked in the root README.
- Exact scanner/CST reconstruction, including Unicode, comments and malformed text.
- Diagnostic recovery, progress through arbitrary input and no-panic properties.
- Deep nesting across parsing, traversal, printing and formatting on every target.
- Equivalent traversal event order with prune/stop behavior.
- Immutable trees and rewrites leaving original trees unchanged.
- Printer structural round trips and formatter semantic preservation/idempotence.

See root Beads epic `wasm-devkit-p5m` for implementation work.
