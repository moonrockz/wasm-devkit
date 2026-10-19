# Component value externs

Original Apache-2.0 fixtures compare WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` and wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features enabled.
Package results retain exact WAT, bytes, reference models and diagnostics.
Accepted binary and WAT inputs compare complete ordered public models.

The 45 package cases cover imports, exports, instance aliases, annotations,
structural values, named record visibility, nested/outer type scopes, nominal
resources, unused and repeated uses, wide type indices and concrete core bodies.
WAC's wasmparser 0.258 profile permits borrowed value exports; wasmparser 0.262
rejects them. The product follows the WAC pin for these package inputs. Type-only
WIT package decoding continues to reject component value externs.

Seventeen source compositions retain `Document::resolve` output and `wac compose`
results. Five compose successfully and their emitted binaries validate with
wasm-tools. The resolver accepts five unused/repeated-value cases that its encoder
rejects. Product verification rejects these with `WAC-C010`; success must imply a
complete valid composition. The remaining seven cases reject in both paths.
The four distinct encoder gaps are unused accessed values, duplicate root exports,
repeated instantiation arguments and shared implicit values. The Unicode duplicate
case also checks source-location handling. These discrepancies are tracked under
`wasm-devkit-p5m.8.2.4` and `wasm-devkit-p5m.8.2.7`.

Reproduction uses the repository's pinned Rust reference helper:

```sh
wasm-tools parse packages/reexport.wat -o packages/reexport.wasm
wac-semantic-reference --package test:dep packages/reexport.wasm
wac-semantic-reference composition/fill/input.wac --dependency test:dep composition/fill/dep.wasm
wac compose composition/fill/input.wac --dep test:dep=composition/fill/dep.wasm -o composed.wasm
wasm-tools validate --features all composed.wasm
```

`packages/cases.json` records both package reference outcomes.
`composition/results.json` records resolver, encoder and independent validation
outcomes. `SHA256SUMS` covers every retained fixture. Runtime-produced component
values remain excluded until their instantiation and naming evidence is complete,
tracked on `wasm-devkit-p5m.8.2.2` and `wasm-devkit-p5m.8.2.4`.
