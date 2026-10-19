# Optional Warg transport

`wasm-devkit-warg` supplies authenticated registry bytes to the MoonBit CLI. It
uses `warg-client` 0.9.0, the client pinned by WAC 0.12.0. Cargo.lock fixes every
transitive dependency; the Warg crypto, protocol, protobuf and transparency
crates retain the upstream 0.9.0 versions. The companion does no component type checking. MoonBit
checks the returned identity and SHA-256 digest, then passes those exact bytes
through the normal WAC package decoder and verifier.

Build from the repository with `mise run build:warg-provider`, which uses Rust
1.94.1. The executable is `.dev/warg-target/release/wasm-devkit-warg`, with `.exe`
on Windows. Put it on PATH or pass its path through `--warg-provider`. Rust is
needed only to build this optional companion. Pure libraries, local packages and
warm or offline cache verification do not launch it.

The product version follows the root `moon.mod` through `scripts/versions.mbtx`.
Native release archives bundle the companion alongside the CLI. It is also
buildable from source and is not a crates.io package. Windows source builds use
rustup for the same pinned toolchain. See the [CLI registry guide](../../cmd/wasm-devkit/README.md#registry-packages)
for cache and lockfile policy.

## Protocol 1

`--version` prints the product version, protocol and pinned client version.
`fetch REQUEST_JSON` accepts one JSON argument with `schema: 1`, an explicit
HTTP(S) `registry`, package `name`, optional exact `version`, isolated Warg
`storage`, output file `output`, and optional client `config` path. No ambient
client configuration is loaded. An explicit configuration can provide namespace
mappings and client authentication settings; interaction is disabled. HTTP is
supported for loopback fixture registries, while public registries should use HTTPS.

The client verifies registry logs, signatures, consistency/inclusion proofs and
content digests. It updates the requested package log before selecting a release.
Exact versions, including build metadata, use `download_exact`; an absent version
uses the latest non-yanked stable release. The release identity is the registry
record and lookup key. A component does not need to embed that package name.

Success writes the downloaded bytes to `output` and prints one JSON object with
schema, requested registry, resolved registry, name, version and digest. Failure
prints `{schema:1,error:{code,message}}` and exits 1. Error codes distinguish
missing packages/versions, empty release sets, invalid registry data, transport,
configuration, identity, storage and protocol failures. Each fetch has a
120-second timeout. User-facing exit statuses and source locations are applied
by MoonBit. Credentials are never part of the protocol response or lockfile.
