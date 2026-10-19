# Concrete nested components

The 36 original Apache-2.0 package fixtures compare WAC 0.12.0 commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` with wasm-tools 1.262.0 commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. `cases.json` records both results.
Accepted loader cases compare complete ordered binary and WAT package models.
The probes cover declaration order, outer type/component/core-module aliases,
concrete child exports and annotations, ordinary named origins, direct and nested
resource generativity, imported captures, value consumption and nested descriptor
length rebuilding. Invalid child bodies are checked even when unused.

`imported-resource` is an explicit pinned Package loader projection panic:
wasm-tools accepts two instantiations that reexport the same imported resource,
while WAC panics in `crates/wac-types/src/package.rs`. The exact diagnostic is
retained under `wasm-devkit-p5m.8.2.2`; it is excluded from loader model comparison.
The product accepts this independently validated input without conflating fresh
resources. It is not counted as loader agreement.

`production/http-0.2.0` and `production/http-0.2.3` contain unchanged pinned WAC
`crates/wac-types/tests/dummy_wasi_http@VERSION.wasm` fixtures, printed WAT and
Package models. Their source license is the retained Apache-2.0 license. The
306-byte adapter extracted from the 0.2.0 fixture and its 317-byte enclosing
component are in `minimal`; original audit results document the former profile
rejection, now covered by an acceptance regression. Both complete production
binary/WAT package models match the pinned loader.

Sixteen source compositions compare complete ordered models using public runtime
resource contexts. Thirteen accept and produce independently validated binaries;
three reject invalid dependencies. Both production HTTP components are included.
Every operation remains non-executing.

`hidden-outer-resource` rejects a composite alias whose complete metadata captures
an imported resource across a concrete boundary. Both references reject it; the
retained pre-fix regression log records the product false acceptance. Its
resource-free control accepts. The fix checks the normalized graph, including
private alias metadata, under the cumulative work budget.

Generated tests also cover 256 nested binary components, 256 WAT parenthesis
levels, rejection above those limits, truncated child headers/sections, and the
16,777,216-byte cumulative compatibility-copy limit. The latter applies when
modern value descriptors need adaptation for the retained parser; custom/core
payload bytes remain unchanged. Shared validation budgets span all concrete
frames. Explicit stacks handle child validation, core-contract lookup, WAC graph
construction and text compilation.

`SHA256SUMS` covers fixtures, diagnostics, reference results, manifests and license.
