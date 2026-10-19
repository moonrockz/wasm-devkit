# Instance export annotations

These 43 original Apache-2.0 fixtures compare instance export annotations with
WAC 0.12.0 `Package::from_bytes`, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, and wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Both enable all Wasm features.
`cases.tsv` records reference and product acceptance; `SHA256SUMS` covers WAT,
compiled binaries, accepted reference models and that table.

Binary and WAT tests compare full ordered package models for accepted cases.
Coverage includes function names, modes and value shapes; nested instances;
nominal resources and captured aliases; unsigned core-module contracts; hidden
members; and aliases and re-exports after narrowing. Module comparisons preserve
import contravariance and export covariance. A separate whitebox test compares
6,000 nested instance scopes and checks cumulative work exhaustion and a mismatch
at the deepest function.

Unlike component type binders, an imported instance's resource identities are
already concrete. A newly introduced resource in an annotation does not match
that instance's resource, even when both use the same instance type. An alias of
the actual exported resource does match. The reference pairs cover both cases.

`component` and `component-missing` retain the current unsupported boundary:
component members need complete component-contract comparison and return
`WAC-B002`. Other incompatible annotations return `WAC-B003`. The WIT type-only
codec still excludes root annotations. Tracking: `wasm-devkit-p5m.8.2.2`.

Reproduce reference results with locked `wac-semantic-reference --package
test:dep CASE.wasm` and `wasm-tools validate --features all CASE.wasm`.
