# Type export ascriptions

These 39 original Apache-2.0 fixtures compare root type-export annotations with
WAC 0.12.0 `Package::from_bytes`, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, and wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Both use all Wasm features.
The two references agree on every case. `cases.tsv` records acceptance and
`SHA256SUMS` covers original WAT, compiled bytes, accepted reference models and
the acceptance table.

Four-target tests compare complete ordered type graphs and nominal resource
relationships for binary and WAT inputs. The cases cover scalar and aggregate
equality, field/case ordering, optional payloads, fixed lengths, imported and
local resource identity, own/borrow handles, instance-exported aliases and
re-exports. Invalid annotations report `WAC-B003`. A fresh `sub resource`
annotation is incompatible even when the actual export is a resource; both pins
reject it. White-box tests compare 6,000-level type graphs with an explicit
work stack and verify the shared work limit.

Instance, component and core-module export annotations remain separate work.
Tracking: `wasm-devkit-p5m.8.2.2`.
