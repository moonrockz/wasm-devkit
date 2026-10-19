# Controlled registry reference

This test-only executable starts a Warg 0.9.0 server on a random loopback port,
publishes the retained fixture manifest, and calls the actual WAC 0.12.0
`RegistryPackageResolver` at revision
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`. With a dependency directory it first
calls that revision's `FileSystemPackageResolver` with WIT/WAT support, then
resolves the remaining keys through the registry. The lockfile also retains wasmparser, wasm-encoder and wasm-metadata 0.258.0
and wast 258.0.0 from that revision. Final acceptance comes from
`Document::resolve`; selected bytes are reported as SHA-256 digests.

`mise run build:registry-reference` builds both this executable and the product
transport with Rust 1.94.1. `mise run test:registry -- native` and `-- wasm` run
the controlled comparison. No credentials or public registry are required. The
server is stopped and temporary state removed after each run.

`serve ROOT MANIFEST` writes `ROOT/running.json` after publishing and stops when
`ROOT/stop` appears. `resolve CONFIG SOURCE [DEPS]` resolves and verifies a source.
The fixed operator/publisher keys are public test keys copied from the pinned
WAC `crates/wac-resolver/tests/support/mod.rs`; its Apache-2.0 license is retained
as LICENSE-WAC. They are used only by the temporary loopback fixture.

The server deliberately has no component content policy. Authenticated invalid
bytes must still fail product semantic verification, including offline cache
loads. Test cases and the exact upstream multi-version defect are documented in
[tests/registry](../../tests/registry/README.md).
