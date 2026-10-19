# WAC declarative package fixtures

These are all 50 `.wat` dependency files from `crates/wac-parser/tests/resolution`
at WAC revision `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, version 0.12.0.
The upstream Apache-2.0 license is retained in `LICENSE`. `manifest.tsv` records
the original source SHA-256, encoded binary SHA-256 and pinned result.

`wasm-tools parse` 1.262.0 encodes the sources. The test-only
`tools/semantic-reference` executable calls WAC's `Package::from_bytes` with its
pinned wasmparser 0.258.0. All 49 parseable binaries are accepted. Their exact
bytes are retained in `../../declarative_corpus_test.mbt`, which tests the
portable declarative validation boundary on all four targets.

`fail/expected-result-named/foo/bar.wat` contains invalid named result syntax and
fails WAT parsing before binary loading. Its source is retained, but it has no
binary acceptance test. This exclusion is tracked on `wasm-devkit-p5m.8.2.2` and
`.8.2.7`. A `fail/` directory refers to the enclosing WAC resolution test, not
necessarily an invalid package binary.

The original adversarial fixtures in `../../declarative_test.mbt` exercise root
component imports/exports, imported function exports, alias index spaces,
malformed metadata, every truncated prefix of a nested-instance input, and the
version-specific fixed-list layout rule. They are checked against the same
pinned package API. These checks do not establish full runtime-component or
WAC composition conformance.
