# Canonical handles, cancellation and scalar GC ABI

These original Apache-2.0 fixtures use wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc` and WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`. The WAC loader pins wasmparser
0.258.0. Every reference runs with all component features enabled. `LICENSE`
retains the fixture license; `SHA256SUMS` covers all inputs and results.

`cases.json` retains 92 package probes, with 41 accepted by the product. Each
WAT source has its exact wasm-tools binary, reference status and diagnostic.
Successful reference loads have complete ordered JSON models. Accepted product
models compare normalized world, instance and definition graphs, including
function parameters, async mode, payload types and resource identities, against
independently projected reference results in `*.projection.json`. All library
comparisons run on wasm, wasm-gc, js and native. The reference gate reparses WAT,
checks exact bytes, reruns both validators, compares complete reference JSON and
checks CLI provider acceptance for both forms. All 128 pinned WAC resolution
bundles remain in the same semantic gate.

The chosen intrinsic set is:

| Intrinsic | Core parameters | Core results |
| --- | --- | --- |
| `task.cancel`, `backpressure.inc`, `backpressure.dec` | none | none |
| `subtask.drop`, `waitable-set.drop`, `error-context.drop` | i32 | none |
| `subtask.cancel` | i32 | i32 |
| `waitable-set.new` | none | i32 |
| `waitable-set.wait`, `waitable-set.poll` | i32, address | i32 |
| `waitable.join` | i32, i32 | none |
| `stream.new`, `future.new` | none | i64 |
| `stream/future.drop-readable`, `stream/future.drop-writable` | i32 | none |
| `stream/future.cancel-read`, `stream/future.cancel-write` | i32 | i32 |

Cancellation intrinsics admit both values of their async flag. Wait/poll require
an existing unshared memory; its width determines the address parameter. Stream
and future operations require the matching declared type at that exact index.
Private payload graphs remain validated by the existing type validator. The
intrinsic itself never traverses or executes the payload.

`gc` lift and `gc (core-type ...)` lower support numeric and boolean primitives,
char, named enums and flags. GC arguments each occupy one core slot, including
functions with more than 16 arguments. Lower requires an earlier core function
type with the exact parameter/result contract; aliases and nested lexical scopes
retain that contract. Lift infers its core type from its function and rejects an
explicit `core-type`. `core-type` without `gc`, duplicate options, wrong kinds,
future indices and signature mismatches reject. Async still requires an async
component function type. Without the async option, flat canonical lowering keeps
the synchronous ABI; GC uses its declared scalar ABI in either mode, matching
the pinned implementations.

The remaining intrinsics, including `task.return`, context slots, thread helpers,
stream/future read/write/forward, and error-context new/debug-message, return
`WAC-B002` and no model. GC aggregate, string, resource and other reference
shapes also remain outside this scalar profile. Valid examples of these
exclusions are retained, so unsupported rejection is distinct from invalidity.
The scalar GC codec does not admit concrete GC types covered by the separate
`wasm-devkit-p5m.12.4` task.

The legacy cancellable byte on wait/poll remains outside the chosen set.
wasmparser 0.258 accepts it; 0.262 rejects it after component-model#716. The
product returns `WAC-B002` for byte 1 and `WAC-B001` for bytes above 1. Library
tests exhaust all 256 flag values, truncate immediate encodings and check binary
depth 256 and WAT parenthesis depth 256. Core WAT expression/control depth stays
64. Canonical shape work and core contract work each share their existing
1,000,000-unit budget across nested frames. Tests exercise cumulative exhaustion,
20 scalar GC arguments and 6,000-level payload graphs without recursive walks.

`composition/` records six source compositions. Four accepted inputs have pinned
resolver JSON and complete models of their emitted binaries, independently
validated by wasm-tools. A wrong GC signature rejects in both references and the
product. The valid `task.return` composition remains explicitly unsupported by
the product. CLI smoke exercises all six with both dependency encodings. The
product performs no hidden I/O and never executes a module or component.
