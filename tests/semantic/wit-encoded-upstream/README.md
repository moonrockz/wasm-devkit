# Encoded WIT regression fixtures

The WAT and WIT inputs are copied unchanged from
`crates/wit-component/tests/interfaces/` in wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. The adjacent WebAssembly files were
compiled from those WAT files with that pinned wasm-tools binary. Their exact
hashes are recorded in the parent `manifest.tsv`.

The upstream Apache-2.0, Apache-2.0 WITH LLVM-exception and MIT license texts are
retained. The source snippets embedded in `encoded_foreign_test.mbt` come from
these same fixtures and pin. The adjacent `wit-encoded-overflow-index.wat` is
a derived negative case that replaces one type index with `4294967296`.

These cases cover foreign alias chains within an inferred package, named world
interface references using `implements`, map types, and wasi-http's large type
indices and foreign interface metadata. They supplement the original fixtures;
they are not the complete upstream model-conformance gate.
