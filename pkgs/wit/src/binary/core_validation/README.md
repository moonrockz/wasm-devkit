# Retained core validator

Sources are retained from `Milky2018/wasm_core@0.16.0`, wasmoon commit
`397eb299e696d54cbc3bdcb095a5f535a74ad317`. Every original source Git blob
matches that commit and the published package. `UPSTREAM.sha256` records the
original bytes; `LOCAL.patch` reconstructs each retained file from that baseline.
Apache-2.0 licensing and upstream third-party notices are retained.

Expression validation uses explicit sequence, alternate-arm and exit tasks.
Labels and local initialization state retain their original scope rules.
Branch-table validation checks each target against the original operands,
including polymorphic unreachable operands, instead of checking only arity.
Diagnostic rendering uses bounded control names rather than recursive AST
formatting. The enclosing framing pass bounds type comparisons, instruction
stack effects and local-state snapshots before this validator runs.

These are internal compatibility packages for component verification. They do
not establish conformance for every upstream proposal. New acceptance, invalid
control, depth and work-limit witnesses are retained in
`tests/semantic/wac-core-control`, alongside the unchanged pinned WAC hello and
greeter components. Original upstream tests are retained. Beads tracking:
`wasm-devkit-p5m.8.2.2` and `wasm-devkit-p5m.8.2.7`.
