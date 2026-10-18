# WIT parser

`parse(text, features=Features::default())` returns `Parse` with an immutable typed AST,
a lossless CST and structured diagnostics. `Parse::is_valid()` means there are no error
diagnostics. Scanner errors are retained. Parsing never raises and performs no I/O.

The parser uses an explicit stack of grammar tasks and flat postorder node arenas.
Input-controlled type and package nesting does not recurse through MoonBit calls.
AST and CST node indices correspond. Read [AST node fields](../ast/nodes.md) for semantic
roles and the AST/CST package documentation for source spans and token ranges.

## Grammar profile

The baseline is [Component Model WIT.md](https://github.com/WebAssembly/component-model/blob/0220da84209397d9067c19cac83dae969aa85a7b/design/mvp/WIT.md)
at revision `0220da84209397d9067c19cac83dae969aa85a7b`.

Implemented syntax includes optional root package declarations, nested package bodies,
interfaces, worlds, resources, forward resources, constructors and fallible constructor
results, ordinary/static/async functions, named parameters, record/flags/enum/variant
members, aliases, paths, imports, exports, inline interfaces, use selectors and renaming,
world includes and include renaming, and since/unstable/deprecated attributes.

Types include scalar primitives, named types, lists, tuples, options, all result forms,
explicit own/borrow handles, futures, streams and maps. Explicit `own<name>` handles,
empty records/flags/tuples and trailing commas follow the reference parser's accepted
syntax. The reference inspected for those cases is wasm-tools commit
`dcac6c30353afa6e851ef0bbd4ca14d8f5493731`. Variants/enums require a case.
Map keys are restricted to the scalar key grammar. Semantic versions use SemVer 2.0
syntax without bounded integer conversion. Fixed list lengths are positive decimal strings.

`Features::default()` disables nested namespaces/package paths, fixed-length lists,
external IDs/named interface imports, and accessors. Set individual fields or use
`Features::all()` to enable them. Disabled syntax is still parsed and retained, with
`WIT-P005` errors. Ordinary async functions, futures, streams and maps are enabled.
Named interface imports use whitespace around `:` to distinguish a plain-name alias
from a contiguous package path, following the pinned specification's disambiguation.

Semantic resolution is separate. The parser does not load packages, resolve references,
check duplicate names/type cycles, enforce compatible feature versions, or validate resource
method/getter/setter signatures. Those checks require later semantic tooling. An AST can
therefore describe syntactically valid code with semantic errors.

## Recovery and diagnostics

An expectation can report a missing token without consuming the next declaration. Invalid
items skip to a semicolon, balanced body or declaration boundary and retain their source.
Delimited lists recover missing commas and closers. Missing types produce `Error` children.
All diagnostics use UTF-16 source spans and are sorted by source start, then code.

| Code | Meaning |
|------|---------|
| `WIT-P001` | Missing token, identifier, member or type |
| `WIT-P002` | Invalid or missing semantic version |
| `WIT-P003` | Invalid scope, path, cardinality or type grammar constraint |
| `WIT-P004` | Unknown or malformed attribute |
| `WIT-P005` | Disabled proposal syntax |
| `WIT-P006` | Unexpected item, skipped during recovery |

Invalid input always retains its exact source in the CST. Consumers must inspect diagnostics;
AST recovery nodes and missing fields are not a successful parse of the malformed syntax.

## Validation

[Fixture provenance and skips](fixtures/README.md) account for all 79 WIT fenced blocks in
the pinned specification. Sixty-seven examples run on every target, including invalid syntax.
Snippets are wrapped in their grammatical contexts; omitted pseudo-syntax is recorded explicitly.
The original Apache-2.0 license is retained alongside the manifest.

Tests exercise every documented node kind, typed fields, proposal switches, scope and SemVer
errors, recovery, collection ownership, exact CST reconstruction and structural invariants.
Per target, seeded properties cover 600 arbitrary Unicode sources, 1,000 malformed grammar
fragment sequences and 300 generated valid nested types. Stress cases include 20,000 nested
list types, 10,000 unclosed option types and 2,000 nested package bodies on wasm, wasm-gc,
js and native. Broader upstream parser corpus coverage remains on Beads `wasm-devkit-p5m.2.1`.
