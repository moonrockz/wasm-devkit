# Function export ascriptions

These 41 original Apache-2.0 fixtures compare root function-export ascriptions
with WAC 0.12.0 `Package::from_bytes`, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, and wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Both validators use all Wasm features;
wasm-tools defaults disable the fixed-length-list fixture's feature.

`cases.tsv` records each reference and product result. `SHA256SUMS` covers the
original WAT, compiled bytes and table. The MoonBit tests retain acceptance,
ordered package type/resource projections and binary/WAT equivalence on all four
targets. Coverage includes parameter names/counts, result types, async mode,
aggregate shapes and ordering, aliases, repeated exports and nominal handles.
Invalid ascriptions report `WAC-B003`.

Both pins and the product accept 20 inputs, including `instance-alias`, whose
complete signature is now retained. Direct imports and re-exports keep the
ascribed type. The follow-up [alias cases](../wac-function-alias-ascriptions/README.md)
cover scoped values and resources and record the remaining nested-instance
metadata boundary. Other root export-ascription sorts remain outside this slice.
Tracking: `wasm-devkit-p5m.8.2.2` and `.8.2.4`.
