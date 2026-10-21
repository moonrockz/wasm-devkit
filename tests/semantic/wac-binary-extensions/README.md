# GC, references and exceptions

Original Apache-2.0 inputs for `wasm-devkit-p5m.12.4` and `.12.5`.
`LICENSE` retains the repository license. `SHA256SUMS` pins every source,
binary, acceptance row and reference snapshot.

The 140 probes use wasm-tools 1.262.0 and wasmparser 0.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Validation enables
`all,-custom-descriptors`. The custom-descriptors proposal changes cast rules
and introduces additional type forms; it remains outside the product profile.
The pinned WAC 0.12.0 loader is commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`.

Each `.wat` component exports one concrete core module. Its `.core.wat` and
`.core.wasm` files retain that module independently. `cases.json` records text
parsing, component validation, core validation, WAC loading and product
acceptance separately. No fixture executes a module or exception handler.

The accepted set includes recursive structs/arrays/functions, declared
supertypes, exact nullability, shared composite and abstract heap types,
shared tables/globals/functions, GC allocation/access/casts/conversions,
typed function references, modern `try_table` handlers and legacy
`try`/`catch`/`catch_all`/`rethrow`/`delegate`. Negative probes cover operand
types, packed fields, defaultability, mutability, indices, handler arity,
exception-reference sharedness, branch labels and local initialization.

`wasm-core-reference` independently reads and validates the original module
with pinned wasmparser, then projects every ordered import/export contract.
The 84 complete `.core.json` models retain flat recursive graphs, group
boundaries, supertypes, field storage/mutability, function identities,
nullability/sharedness, limits, page annotations and distinct import pairs.
The semantic gate compares these snapshots with fresh oracle output and the
product's complete inventory contracts. Thirteen richer model probes also compare
binary, component and compiled-WAT inventories in four-target unit tests.

The WAC loader supplies 134 complete package snapshots. It skips instruction
bodies, so its acceptance alone does not prove validity. Its four GC projection
panics and two rejections are recorded separately from wasmparser validation.
The independent core models cover contracts the loader cannot project.
The pinned text parser also lacks folded legacy `try` syntax. Equivalent flat
syntax supplies these fixture binaries; product unit tests additionally check
the folded form against the same reference-validated instructions.

Unit tests exercise malformed immediates, the 1,000,000-unit work limit,
binary control depth 256, WAT depth 64, large unreachable array counts,
shared instruction contexts and decompile/compile round trips. Catch arms
consume local-state work individually. Unsupported descriptors, continuation
instructions, atomics other than `ref.i31_shared`, and nonconstant SIMD
instructions remain explicit failures.

Run `mise run build:semantic-reference`, `mise run test`, both CLI target
suites, and `mise run test:semantics -- .dev/reference-cli/bin/wasm-tools
.dev/reference-cli/bin/wac`. The existing 128 WAC resolution bundles remain
part of that semantic gate.

For the compatibility input profile, 61 accepted modules also retain exact
wasm-tools output. The semantic gate compares both fresh reference output and
product output with those snapshots. All four targets run the same exact text
checks. The other 23 valid modules contain exception control that remains
outside the existing compatibility profile; they must reject without output.
Default printing accepts them and its round-trip checks remain independent.

All 84 default core outputs and 61 admitted compatibility outputs are also
parsed by the pinned text reader, independently validated and compared again
against complete core contracts. Shared mutable globals use the standard
`(shared mut TYPE)` spelling.

Encoding regressions compare independently generated instruction trees, including
nonzero memory indices, memory64 offsets, packed memargs, abstract struct/array
shorthands and typed select. Explicit alignment hints remain unchanged; omitted
alignment uses each instruction's natural alignment.
