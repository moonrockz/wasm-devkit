# Pinned semantic API oracle

This test-only executable calls `wit_parser::Resolve::push_path` on the exact file
or directory supplied to the MoonBit verifier. It is outside `moon.work`, never
published, and never called by product code. The semantic libraries remain pure.

The dependency is `wit-parser = 0.262.0` from wasm-tools v1.262.0. Its published
`.cargo_vcs_info.json` records commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc`.
`Cargo.lock` records every dependency checksum. Build features are the crate's default
`std`, `serde`, `decoding`, plus `wat`. No optional semantic features are selected.
Rust 1.94.1 is pinned through `SEMANTIC_REFERENCE_RUST_VERSION` in mise configuration.

```shell
mise run build:semantic-reference
mise run test:semantics -- /path/to/wasm-tools-1.262.0 /path/to/wac-0.12.0
```

The executable is under ignored `.dev/reference-target/release`. Builds use `--locked`.
The upstream libraries are dependencies, not vendored implementation code. Their
licenses remain available in the downloaded crates and upstream repository.

`Resolve` JSON includes arena IDs and uses keys such as `interface-0`. Those strings
can also be valid user names. The helper adds structured world entries containing
the actual `WorldKey` enum variant and item, including colliding map entries. The
MoonBit runner normalizes those variants to package-qualified interface/world IDs
and compares world keys, kinds and resource identities. Function/type bodies
remain outside this projection and are covered by the separate full conformance gates.
