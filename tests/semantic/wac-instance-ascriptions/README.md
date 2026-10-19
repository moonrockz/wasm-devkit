# Instance export annotations

These 47 original Apache-2.0 fixtures compare instance export annotations with
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

Component members use the same complete scoped contract comparison as root
component annotations, including fresh resource binders and captured identities.
Concrete instance resources seed the scoped metadata so comparisons preserve
their existing identities. Incompatible annotations return `WAC-B003`. The WIT
type-only codec still excludes root annotations. Tracking: `wasm-devkit-p5m.8.2.2`.

Reproduce reference results with locked `wac-semantic-reference --package
test:dep CASE.wasm` and `wasm-tools validate --features all CASE.wasm`.
