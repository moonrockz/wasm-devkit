# Registry and cache acceptance

These original fixtures are published into an isolated Warg 0.9.0 loopback
registry by `tools/registry-reference`. No public registry or private credentials
are used. `cases.json` records expected product and pinned WAC outcomes;
`packages.json` records exact releases, content sources and yanks. `SHA256SUMS`
fixes every fixture input.

The suite compares exact versions, build metadata, latest stable selection,
explicit prereleases, yanked/missing/unknown/no-release cases, authenticated
invalid component data, encoded WIT and mixed registry/local transitive WIT
packages. Accepted registry bytes must match both WAC-selected digests and the
fixture's authenticated publish records. Warm and offline runs use a nonexistent
provider path to prove that they do not contact the network. Refresh enforces
existing lock identities. Tampered cache bytes, metadata identities, malformed
metadata and lock digests fail. Lock guards reject competing writers. Failed
verification creates no lockfile. Explicit local overrides take priority only
for unversioned requests. After the server stops, offline verification succeeds
and refresh reports transport failure.

## Pinned upstream multi-version defect

WAC 0.12.0 at `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` collects registry
requests into a map keyed only by `PackageName` in
`crates/wac-resolver/src/registry.rs`. Two versions of one name collapse to one
entry; its download loop then pairs that entry with an original key by index.
The retained `two-versions` case fails upstream with `unknown package test:api`.
The product resolves both exact keys independently and verifies the composition.
Independent single-version cases match WAC; both selected digests also match
authenticated publish records. This is the suite's only acceptance exception.

`mise run test:registry -- native` and `-- wasm` exercise the actual CLI and
network companion. Pure digest/identity/lockfile tests also run on wasm, wasm-gc,
js and native with the normal workspace tests. Network/cache code remains
outside both language verifiers.
