# moonrockz/wit

WIT language tooling for MoonBit.

**Scaffold only.** Only `version()` is implemented. The packages below reserve boundaries;
they do not provide language tooling yet, and this module has not been published.

## Scope

Package declarations, interfaces, worlds, types, functions, resources, use/include declarations and explicitly selected proposal-gated constructs.

Syntax parsing is separate from semantic resolution. Cross-file/package loading, name resolution,
registry access and binding generation belong in later semantic tooling.
The syntax parser must not perform I/O.

## Packages

| Package | Intended responsibility |
|---------|-------------------------|
| `span` | Source text, positions and documented Unicode offset units |
| `diagnostic` | Stable codes, severity, source labels and recovery details |
| `scanner` | Lossless tokens, comments and whitespace |
| `ast` | Immutable typed nodes and child collections |
| `cst` | Immutable lossless concrete structure, including malformed input |
| `parser` | Recovering source-to-AST/CST parsing with diagnostics |
| `traversal` | Explicit-stack walks, folds, reductions, events, cursors and immutable rewrites |
| `printer` | Stack-safe canonical AST-to-source emission |
| `formatter` | Stack-safe CST formatting that preserves comments and meaning |

## Validation to implement

- Upstream valid and invalid fixtures pinned to the reference linked in the root README.
- Exact scanner/CST reconstruction, including Unicode, comments and malformed text.
- Diagnostic recovery, progress through arbitrary input and no-panic properties.
- Deep nesting across parsing, traversal, printing and formatting on every target.
- Equivalent traversal event order with prune/stop behavior.
- Immutable trees and rewrites leaving original trees unchanged.
- Printer structural round trips and formatter semantic preservation/idempotence.

See root Beads epic `wasm-devkit-p5m` for implementation work.
