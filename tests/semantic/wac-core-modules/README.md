# Core module contracts

Original Apache-2.0 fixtures compare WAC 0.12.0, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, and wasm-tools 1.262.0,
commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features.
`packages.tsv` records 35 package acceptance probes. Accepted binary and WAT
models retain ordered module signatures. Cases include UTF-8 names, distinct
colon-containing import tuples, equal-shape numeric type slots, memory/table widths, full UInt64 limits, custom
pages, shared globals, tags, abstract references and lexical aliases.

`composition.tsv` records 22 source typing cases. `witness.wat` independently
checks each module subtype by instantiating a component with the supplied core
module. Those witnesses match pinned Document::resolve acceptance. The pinned
WAC encoder panics on all nine accepted composition cases at
`crates/wac-graph/src/encoding.rs:909`, with `expected only types, functions, and
instance types`. These encoder panics are explicit exclusions, not semantic
rejections. Product verification never runs the encoder.

`fill.tsv` records 22 TypeAggregator comparisons. The following eight reference
successes produce a merged module that fails an original consumer's subtype
requirement: `import-width`, `extra-import`, `memory-narrow`, `memory-wide`,
`memory-import-narrow`, `memory-import-wide`, `table-narrow`, and `tuple-imports`.
Their independent `witness.wat` files reconstruct the reference's merged module
and fail wasm-tools validation. The product revalidates consumers and rejects
these cases. Valid merged models compare exactly with the reference.

`typed-ref.wat` validates with wasm-tools but makes the pinned WAC loader panic
while converting a concrete heap type in `wac-types/src/core.rs`. The product
retains the complete concrete type graph. The independent wasmparser oracle in
[the extension suite](../wac-binary-extensions/README.md) checks these contracts.
Recursive groups, shared heap types and declared supertypes are supported.
Nested declarations and concrete modules now share the root core-type limit
profile, including full UInt64 limits and custom memory pages. The separate
[core limits suite](../wac-core-limits/README.md) gates these encodings and their
complete normalized package models.

The separate deep fixture traverses 41 component type scopes. Unit contracts
also exercise 50,000 function parameters, truncated limits, overflowing u64 LEBs
and immutable module graphs. `SHA256SUMS` covers all retained sources and tables.
Separate suites cover runtime core bodies, values and export annotations.
Concrete GC/reference types and exception instructions have additional coverage
in the extension suite.

Eight text-only cases reject duplicate type identifiers/aliases, invalid global
syntax and malformed/overflowing limits against the pinned text parser.
