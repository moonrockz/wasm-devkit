# moonrockz/wac

WAC language tooling for MoonBit.

Source positions, structured diagnostics, a lossless scanner, typed immutable ASTs/CSTs and
a recovering parser, immutable traversal and rewrites are implemented. Printing and formatting
remain reserved.
This development module has not been published.

## Scope

Package/targets directives, WIT-style definitions supported by the WAC reference, imports, let bindings, instantiations, access expressions, spread arguments and exports.

Syntax parsing is separate from semantic resolution. Cross-file/package loading, name resolution,
registry access and composition evaluation belong in later semantic tooling.
The syntax parser must not perform I/O.

## Packages

| Package | Responsibility |
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

## Validation

- Upstream valid and invalid fixtures pinned to the reference linked in the root README.
- Exact scanner/CST reconstruction, including Unicode, comments and malformed text.
- Diagnostic recovery, progress through arbitrary input and no-panic properties.
- Deep types, groups and instantiations on every target.

Traversal tests cover canonical event order, prune/stop, cursors, immutable rewrites and
all 46 node kinds. Printer round trips and formatter laws will be added with those implementations. The [parser profile](src/parser/README.mbt.md) documents
the pinned corpus and WIT grammar differences.

See root Beads epic `wasm-devkit-p5m` for implementation work.
