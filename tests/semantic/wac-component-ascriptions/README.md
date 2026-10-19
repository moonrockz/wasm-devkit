# Component export annotations

These 54 original Apache-2.0 fixtures compare component export annotations with
WAC 0.12.0 `Package::from_bytes`, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, and wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Both enable all Wasm features.
`cases.tsv` records reference and product acceptance; `SHA256SUMS` covers WAT,
compiled binaries, accepted reference models and the table.

Accepted binary and WAT cases compare complete ordered package models. Coverage
includes function/value contracts, contravariant imports, covariant exports,
nested instances and components, core modules, nominal captures, resource
binders and alias constraints. Annotated and unannotated re-exports retain the
correct contract. Future declarations cannot satisfy earlier type references.
A whitebox test compares 6,000 nested component scopes, checks a deepest-leaf
mismatch, and exhausts a cumulative verification allowance.

Component contracts abstract over resource binders. An expected fresh exported
resource can bind a supplied captured resource; imports reverse the direction.
The comparison retains equality constraints and checks function uses after
collecting matching resource binders. It never treats different captured
resources as equal. This differs from an already-instantiated instance's concrete
resource identities; the paired positive/negative cases retain both rules.

`alias-component` remains unsupported: component aliases extracted from imported
instances do not yet carry complete scoped component metadata. It returns
`WAC-B002`; other incompatible annotations return `WAC-B003`. Component members
inside instance annotations also remain outside their current profile, tracked
by `tests/semantic/wac-instance-ascriptions`. Tracking: `wasm-devkit-p5m.8.2.2`.

Reproduce reference results with locked `wac-semantic-reference --package
test:dep CASE.wasm` and `wasm-tools validate --features all CASE.wasm`.
