# Core module export annotations

These 49 original Apache-2.0 fixtures compare core-module export annotations with
WAC 0.12.0 `Package::from_bytes`, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, and wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Both use all Wasm features.
`cases.tsv` records each reference result and product acceptance. `SHA256SUMS`
covers WAT, compiled binaries, accepted WAC models and the acceptance table.

Four-target tests compare complete ordered package models, including the actual
import contract and narrowed export contract. Binary and WAT results agree.
Coverage includes functions, tags, globals, memories and tables; unsigned 64-bit
limits, custom pages, shared flags and abstract references; import variance,
missing/extra externs, tuple import keys, aliases and concrete modules. Re-exports
retain the annotation's contract. Future declarations and wrong-sort indices
cannot satisfy an earlier annotation. Invalid annotations report `WAC-B003`.

Three reference differences are explicit:

- `table64-flag`: WAC's pinned wasmparser 0.258 accepts a table64 export where a
  table32 export is required. The WAC source type checker itself checks this flag,
  and wasm-tools 0.262 rejects the identical binary. The product rejects this
  incompatible contract. Both original bytes and the WAC accepted model remain.
- `global-ref-narrow` and `global-ref-bottom`: wasm-tools 0.262 accepts immutable
  global reference subtyping. WAC's 0.258 package loader and source type checker
  require invariant value types. The product follows the pinned WAC profile and
  rejects both. The matching global and rejecting reverse-variance controls remain.

To reproduce a case, run the locked `wac-semantic-reference --package test:dep`
on its `.wasm` file and `wasm-tools validate --features all` on the same bytes.
Tracking: `wasm-devkit-p5m.8.2.2`.
