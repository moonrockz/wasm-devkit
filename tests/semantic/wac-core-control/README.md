# Structured core validation

The 31 binary cases and 13 additional WAT cases cover block/loop/if parameters,
results, branches, mixed folded/flat syntax, malformed control framing, exact
raw/Unicode data bytes, invalid UTF-8 names and redundant imported function signatures. Accepted API
cases compare the complete ordered package models with WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`. Byte inputs are retained unchanged.
`wasm-tools` 1.262.0 at `e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all
features enabled, independently checks every executable body.

`cases.json` records the reference outcomes and exclusions. The pinned
`Package::from_bytes` skips core function-body validation, including malformed
instruction framing. Its accepted results for invalid bodies are explicit oracle
false positives. The product follows `wasm-tools` rejection for those bodies.
`branch-table-wrong-type` also reproduces an upstream core-validator bug: checking
target arity alone accepted operands incompatible with an alternate target.
`branch-table-polymorphic` remains valid with unreachable operands.

Binary depth 256 accepts, while depth 257 returns `WAC-B002`. WAT has a stricter
64-level combined control/expression limit before the upstream text parser and
encoder run. Tests check accepted depth 64, rejected depth 65, mixed flat/folded
controls and excessive folded numeric expressions on all targets. The local-state cost cases
have identical control depth and different local counts; only the over-budget
case returns `WAC-B002` in binary. Their 256-level WAT spellings hit the text
depth limit. These are documented profile limits, not invalid Wasm.
The work allowance remains 1,000,000 and is shared across component modules.
The core-types README documents the conservative cost formula.

`production/hello/dep.wasm` and `production/greeter/dep.wasm` are the original
`examples/deps/example/hello.wasm` and `greeter.wasm` files from that WAC revision.
Their SHA-256 hashes are respectively
`df4f0569b53444181e85b62da636886370e07347184e419c4f614fdb3cd7585d` and
`f1daf5eef8c61ee87db715fcc46c3f71bf539b473a90264ec7b936c5bb0b68e3`.
The retained WAT is the pinned `wasm-tools print` output. Binary and WAT package and
Document resolution tests compare full ordered models on all four targets.
Native and wasm CLI smoke tests check both dependency formats.
Both retained composed outputs independently validate. No module is executed.

Reproduce package models with the pinned `wac-semantic-reference --package
test:dep dep.wasm` helper; resolve `input.wac --dependency test:dep dep.wasm`.
Compose with `wac compose input.wac --dep test:dep=dep.wasm` and validate the
result using `wasm-tools validate --features all`. WAT type-use mismatches reject
in `wasm-tools parse` before a binary is produced. Result JSON preserves the
exact status and diagnostic output of each probe.

Original cases and the upstream WAC binaries are Apache-2.0; the license is
retained. `SHA256SUMS` covers the fixtures and reference evidence. The retained
core parser/validator have independent original hashes, licenses and
reconstructable patches under `pkgs/wit/src/binary/`. Tracking remains on
`wasm-devkit-p5m.8.2.2` and `wasm-devkit-p5m.8.2.7`; GC, concrete references and modern/legacy exceptions have additional coverage
in [the extension suite](../wac-binary-extensions/README.md). Other unsupported
instruction proposals remain explicit boundaries.
