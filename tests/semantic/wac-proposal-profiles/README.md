# Async canonical ABI and component start

These fixtures follow the async lift/lower rules in wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc` (wasmparser
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`). The sources are original
Apache-2.0 encodings of that ABI, not byte copies of the upstream `.wast`
harness. `LICENSE` is Apache-2.0.

Accepted cases are callback lift and a component start with no result value.
`async-sync-type` puts the async canon option on a synchronous function and
returns `WAC-B003`. Callback lift uses core `(param i32) (result i32)` plus a
callback `(param i32 i32 i32) (result i32)`. Stackful lift, async lower, start
argument checks and the remaining exclusions are library tests.

The later [canonical handle/scalar GC profile](../wac-canonical-intrinsics/README.md)
admits selected intrinsics and scalar `gc`/`core-type` options. Remaining
intrinsics, GC reference shapes, concrete GC and reference types, exception
instructions still return `WAC-B002`. The
[shared-global suite](../wac-shared-globals/README.md) covers admitted concrete
scalar/vector globals and shared-flag matching.
The [core limits suite](../wac-core-limits/README.md) covers full UInt64 limits
and custom memory pages in nested declarations and concrete modules.

`composition/` is loaded by the CLI smoke test for both `.wat` and `.wasm`.
`SHA256SUMS` records every file in this directory. Verification does not
execute the modules.
