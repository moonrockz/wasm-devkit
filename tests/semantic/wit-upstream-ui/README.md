# Pinned WIT semantic corpus

These are all 261 input groups selected by `crates/wit-parser/tests/all.rs`
at wasm-tools commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc`, release 1.262.0.
The 332 original input files, including files ignored by directory loading, are
unchanged. `SHA256SUMS` records their bytes. Upstream MIT and Apache licenses
are retained here.

`cases.json` records reference acceptance with only semantic feature `active`
enabled. There are 78 accepted groups. The pure verifier tests in
`pkgs/wit/src/verifier/upstream_ui_test.mbt` embed the same input closures and
compare all 78 accepted public models with the pinned Rust reference.
`model_projection_test.mbt` normalizes package and declaration names, type
structure, parameter and field order, function kind and asyncness, world keys,
stability and external-ID metadata, and nominal resource equivalence. Arena
indices, documentation text, source coordinates and unreachable anonymous nodes
are representation details and are excluded. Projection uses an explicit stack. Every group checks deterministic results;
accepted groups also check reversed source/dependency order, formatting-preserved
models, formatter idempotence and unchanged previously returned models.
[Encoded variants](../wit-upstream-encoded/README.md) exercise the binary loader
against the same pinned reference.

The CLI reference gate covers 260 groups using `feature=active` in the parent
manifest, including original directory layouts and encoded dependencies. The
one explicit exception is `parse-fail/type-nesting-too-deep.wit`: the reference
rejects 101 nested list types at its parser depth limit, while wasm-devkit
accepts them with its documented stack-safe parser. The pure verifier test
asserts acceptance of that exact input. This existing grammar extension is
tracked on Beads `wasm-devkit-p5m.8.1.7`; it is not counted as reference agreement.

Run `mise run test:semantics` with the pinned reference tools installed to check
CLI acceptance and world summaries. Run `mise run check` for the embedded full
model and acceptance comparisons on wasm, wasm-gc, JavaScript and native.
The Rust oracle prints the full model with:

```sh
.dev/reference-target/release/wasm-devkit-semantic-reference INPUT --features active
```
