# Pinned semantic API oracle

The companion `wac-semantic-reference` executable calls
`wac_parser::Document::parse` and `Document::resolve`. Dependencies default to an empty map;
repeat `--dependency NAME[@VERSION] BINARY` after the WAC source path to supply exact
package keys and component bytes. Duplicate keys are rejected by the harness.
Its dependency is pinned to WAC revision
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, version 0.12.0. The lockfile retains
wasmparser, wasm-encoder and wasm-metadata 0.258.0 from that revision's lockfile.
It checks WAC acceptance independently of the `wac resolve` CLI
and emits ordered JSON type and import metadata for inspection. The `exported_nodes`
projection records each node's last export name; the pinned public graph API
does not expose its complete export-name map. Package mode below retains all
component imports and exports. The `nodes` projection retains definition, import,
instance and alias roles, package lookup keys, alias sources and instantiation
arguments. Arguments are sorted by external name; node/type IDs require
normalization before comparing implementations.

`wac-semantic-reference SOURCE --aggregate-imports [--dependency NAME BINARY]...`
passes the graph's ordered implicit and explicit import requirements to the pinned
`wac_types::TypeAggregator`. It checks exact explicit/implicit name conflicts and
returns the aggregated type arena, imports and canonical-name redirects. This
isolates import merging from the encoder, which panics on some valid resource
captures. Aggregation alone is not proof of a valid composition: the pinned
aggregator can discard nested exports required by a consumer. Keep validating
`wac compose` comparisons for final compatibility and nominal-resource checks.

`wac-semantic-reference --package NAME BINARY [VERSION]` calls the pinned
`wac_types::Package::from_bytes` API, returning the supplied package identity,
component/instance IDs, definitions and type arenas. Record fields, variant
cases, function parameters and interface/world entries use arrays to preserve
order. Core module import entries retain both module and field names. This
helper does not encode or run components. Full WAC type graph comparison remains
part of the conformance task.
Both executables are built by the command below.

`wac-semantic-reference --target TARGET_BINARY WORLD_NAME COMPONENT_BINARY`
loads both packages into one type arena and calls pinned
`wac_types::validate_target`. The selected definition must be a world. This is a
separate oracle from a WAC source directive: the standalone checker permits
compatible semantic-version name matching, while `Document::resolve` checks
target names exactly. Success prints the selected world IDs and ordered type
arenas; failure prints the checker's report and exits nonzero. It does not emit
or execute a component.

This test-only executable calls `wit_parser::Resolve::push_path` on the exact file
or directory supplied to the MoonBit verifier. It is outside `moon.work`, never
published, and never called by product code. The semantic libraries remain pure.

The dependency is `wit-parser = 0.262.0` from wasm-tools v1.262.0. Its published
`.cargo_vcs_info.json` records commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc`.
`Cargo.lock` records every dependency checksum. Build features are the crate's default
`std`, `serde`, `decoding`, plus `wat`. Semantic selection defaults to no unstable
features. After the input path, pass `--features NAME[,NAME]` or `--all-features`
to configure `Resolve::features` or `Resolve::all_features`. The runner matches these
settings to the selected wasm-devkit semantic profile.
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

Pass `--merge PATH` repeatedly to resolve additional WIT inputs independently and
merge each result using `Resolve::merge`. Feature options apply to every input.
The default `push_path` operation is unchanged. This mode checks mixed source and
encoded inputs where the pinned directory loader panics when a source package
repeats a package already inferred from encoded dependencies.

`wac-semantic-reference --encode-wit WIT_PATH OUTPUT_BINARY` uses WAC's pinned
wit-parser/wit-component 0.258.0 to load a WIT file or package directory and encode
its type wrappers. Feed those bytes to `--package` or `--dependency` to compare
WIT-backed WAC inputs with the same profile as `wac resolve`. This is separate
from the WIT oracle's 0.262.0 profile. It performs no registry lookup.

Directory inputs load their local dependency closure; a single WIT file does not
automatically load a sibling `deps` directory. The pinned WAC filesystem resolver
accepts automatically discovered WIT package directories, but rejects directories
passed through its file-only `--dep` override check. The encoder mode can encode
either input directly; filesystem-provider comparisons must also run the actual
WAC CLI to preserve that distinction.
