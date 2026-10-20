# Retained core parser

Sources are retained from `Milky2018/wasm_core@0.16.0`, wasmoon commit
`397eb299e696d54cbc3bdcb095a5f535a74ad317`. Every original source Git blob
matches that commit and the published package. `UPSTREAM.sha256` records the
original bytes; `LOCAL.patch` reconstructs each retained file from that baseline.
Apache-2.0 licensing and upstream third-party notices are retained.

The expression reader constructs block, loop, if and retained try-table trees
with an explicit frame stack. It rejects malformed else/end nesting and bounds
physical control depth at 256 before constructing a deeper tree. The enclosing
core framing boundary admits only its documented instruction profile.

These are internal compatibility packages for component verification. They do
not establish conformance for every upstream proposal. New acceptance, invalid
control, depth and work-limit witnesses are retained in
`tests/semantic/wac-core-control`, alongside the unchanged pinned WAC hello and
greeter components. Original upstream tests are retained. Beads tracking:
`wasm-devkit-p5m.8.2.2` and `wasm-devkit-p5m.8.2.7`.

The optional text-metadata reader retains raw reference-type spellings, explicit
recursive groups, explicit empty else arms and opcode offsets. The retained AST
collapses several non-null bottom and exception reference types, so printers use
these immutable metadata snapshots to preserve their original meaning. Ordinary
parsing still returns the same AST. Metadata and instruction walks use explicit
stacks and retain the parser's existing limits.
