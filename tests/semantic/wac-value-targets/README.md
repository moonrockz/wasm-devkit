# Value extern target worlds

Three original Apache-2.0 cases compare WAC 0.12.0 Document::resolve, wac compose
and the native product CLI with identical dependency bytes. The matched value
imports/exports accept; the emitted component validates with wasm-tools 1.262.0.
Mismatched imported and exported value types reject in all three paths.
The WAC pin is 5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9; wasm-tools is
 e22db44da4eaf17a0e46ec55b911c7539589a3cc. All features are enabled for validation.
Accepted API tests compare the complete ordered source model. These supplement
wac-value-externs and are tracked on wasm-devkit-p5m.8.2.6.

Reproduce with the pinned wac-semantic-reference helper using input.wac and
`--dependency test:dep dep.wasm`; use `wac compose input.wac --dep test:dep=dep.wasm`
and `wasm-tools validate --features all` on the emitted binary. SHA256SUMS covers
all retained sources, exact bytes, models and diagnostic outcomes.
