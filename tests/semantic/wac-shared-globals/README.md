# Shared concrete globals

Original Apache-2.0 inputs for `wasm-devkit-p5m.12.3`. `LICENSE` retains the
repository license. `SHA256SUMS` pins every input and reference snapshot.

The 39 probes use wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features, and WAC 0.12.0,
commit `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`.
`cases.json` records reference text parsing, binary validation, package loading
and product acceptance separately. Binary-form WAT preserves malformed bytes;
reference parsing rejects those encodings before producing a binary.

Concrete globals support i32, i64, f32, f64 and v128 with both shared flags and
both mutabilities. Imports, inline imports, mixed imported/defined index spaces,
extended constant initializers, ordinary global.get/global.set, nested concrete
components, module ascription and core instantiation retain complete contracts.
Matching shared flags accept; either mismatch rejects. Ordinary globals retain
the same contract. No additional instructions enter the verification profile.

The pinned WAC loader skips function bodies and some concrete module matching.
It accepts both shared-flag mismatches in ascriptions and instantiation, plus
`immutable-set` and `bad-body`. wasm-tools rejects these original binaries, as
does the product. Both references accept `exception` and `atomic`, which remain
explicit product exclusions. Concrete GC/shared heap references also remain
unsupported. Malformed flags, missing bytes and invalid initializers reject.
These exclusions and reference differences are recorded on the Beads task.

`shared_globals_profile_test.mbt` checks complete ordered normalized models from
the pinned snapshots for binary, WAT and re-decoded product bytes on wasm,
wasm-gc, js and native. Original binary bytes remain identical. Models preserve
sharedness, scalar/vector types, mutability and import/export identity.
`shared_globals_bounds_test.mbt` checks a randomized contract round-trip law,
binary component/control depth 256, WAT control depth 64, the existing
1,000,000-unit validation budget and shared-flag preservation through default
and wasm-tools-compatible printing. WABT compatibility explicitly rejects
shared globals. Validation uses explicit work stacks, performs no hidden I/O
and never executes a module or component.

Run `mise run test`, `mise run test:cli -- wasm`, `mise run test:cli -- native`
and `mise run test:semantics -- .dev/reference-cli/bin/wasm-tools
.dev/reference-cli/bin/wac`. The semantic gate rechecks hashes, reference
acceptance, complete pinned models and both dependency providers. It retains
all 128 pinned WAC resolution bundles. Build references with
`mise run build:semantic-tools` first.
