# moonrockz/wit

WIT language tooling for MoonBit.

Source positions, structured diagnostics, lossless lexical analysis, typed immutable ASTs/CSTs
and recovering syntax parsing are implemented. Traversal, printing and formatting remain unimplemented.
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
| `traversal` | Explicit-stack walks, folds, reductions, events, cursors and immutable rewrites |
| `printer` | Stack-safe canonical AST-to-source emission |
| `formatter` | Stack-safe CST formatting that preserves comments and meaning |

## Validation

The lexical layer has acceptance examples, 2,400 seeded property cases per target,
exact token/span reconstruction laws and a 30,000-level nested comment stress case.
Tests also exercise malformed UTF-16 and string escapes. All run on wasm, wasm-gc, js and native.

The parser adds 67 pinned specification examples with a licensed fixture manifest,
1,900 seeded property cases, 20,000 nested types, 10,000 missing type closers and
2,000 nested packages per target. AST/CST validation checks postorder references,
unique parents, child order and span containment.

Remaining validation for the syntax frontend and later packages:

- Broader pinned upstream parser corpus coverage beyond specification examples.
- Deep nesting across traversal, printing and formatting on every target.
- Equivalent traversal event order with prune/stop behavior.
- Immutable trees and rewrites leaving original trees unchanged.
- Printer structural round trips and formatter semantic preservation/idempotence.

See root Beads epic `wasm-devkit-p5m` for implementation work.
