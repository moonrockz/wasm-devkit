# Canonical name profile fixtures

These are original Apache-2.0 inputs. `SHA256SUMS` records exact WAT and binary
bytes compiled with wasm-tools 1.262.0, revision
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Every input is accepted by
`wac-types::Package::from_bytes` from WAC 0.12.0, revision
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, which uses wasmparser 0.258.0.

The WAC API preserves raw interface IDs, including partial versions, and ignores
version-suffix when choosing that ID. It also leaves implements versions
unchecked. WIT's wasmparser 0.262.0 rejects `pre-wrong`, `empty-implements`,
`partial-implements`, `missing`, `unicode-implements` and `empty-prefix`. The
remaining cases are accepted by both profiles. Tests assert these differences
and raw WAC IDs explicitly. This is not a full component-model corpus.

Tracked under `wasm-devkit-p5m.8.1.5` and `.8.1.7`.
