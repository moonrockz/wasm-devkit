# Pinned WAC resolution corpus

This directory retains all 128 resolution groups from WAC 0.12.0, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, under
`crates/wac-parser/tests/resolution`. All 191 original source/dependency files
are unchanged; `SHA256SUMS` records their bytes and `LICENSE` retains Apache-2.0.
`cases.json` records the source, filesystem dependency root, acceptance and
failure phase. There are 14 accepted and 114 rejected groups, with no exclusions.

`pkgs/wac/src/verifier/upstream_resolution_test.mbt` embeds the input closures
and compares the accepted composition/type models with pinned
`Document::resolve`. WIT directories use WAC's wit-parser/wit-component 0.258.0
profile. Binary fixtures are embedded unchanged; WAT fixtures are compiled by
wasm-tools 1.262.0 for the pure binary-provider tests. The CLI gate also loads
the original WAT through both filesystem providers. The invalid WAT in
`fail/expected-result-named.wac` fails before resolution; its pure test checks
WAT-provider rejection rather than substituting fabricated component bytes.

The projection compares node operations, dependency keys, argument/member edges,
ordered type fields and function parameters, imports, exports and nominal
resource equivalence. It ignores allocation IDs and source positions. Implicit
imports are materialized before their first consuming instance to match the
product's explicit composition graph; reference requirements and package world
imports determine those nodes and edges. The complete export-name map is checked
with `CompositionGraph::get_export` for candidate names from the original source
and inferred exports. This also covers multiple names assigned to one node.

All 14 accepted groups also pass validating `wac compose` and
`wasm-tools validate --features all`. The latter enables the async WASIp3 types
used by the original corpus. The pinned encoder emits only the last export name
assigned to each node, even though `get_export` retains earlier names. Tests
compare that emitted-name set separately and preserve the complete resolver map
in the product model. Export ordering in encoded binaries may follow dependency
order; composition graph edges and ordered source exports remain separate data.

Every pure resolution case checks deterministic results or diagnostics. Accepted
cases additionally reverse independent provider order, format the WAC source,
check formatter idempotence and semantic preservation, and verify earlier models
remain unchanged. These tests run on wasm, wasm-gc, JavaScript and native.

The required host-reference CI job runs `scripts/test-wac-corpus.mbtx` through
`mise run test:semantics`. It verifies all input hashes, then compares actual
filesystem-provider and resolver acceptance through `wac resolve`, the pinned
Rust API oracle and the product CLI. It also composes and validates every accepted
group. Product code invokes none of these reference tools.

To inspect one reference group:

```sh
.dev/reference-target/release/wac-semantic-reference \
  tests/semantic/wac-upstream/alias.wac \
  --deps-dir tests/semantic/wac-upstream/alias \
  --export-name a --export-name a2
```

Tracking: Beads `wasm-devkit-p5m.8.2.7`. Binary/runtime provider coverage beyond
these upstream resolution inputs remains in its separately tracked fixtures.
