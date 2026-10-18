# Pinned wasm-tools WIT corpus

Source: [crates/wit-parser/tests/ui](https://github.com/bytecodealliance/wasm-tools/tree/dcac6c30353afa6e851ef0bbd4ca14d8f5493731/crates/wit-parser/tests/ui)
at revision `dcac6c30353afa6e851ef0bbd4ca14d8f5493731`.
The upstream Apache license and Apache license with LLVM exception are retained here.
Vendored source literals are in `../../wasm_tools_test.mbt`, so no filesystem access or
Rust toolchain is needed to run these tests on wasm, wasm-gc, js or native.

All 321 `.wit` files under `tests/ui`, including nested dependency files and the
`parse-fail` directory, are included. No WIT files are skipped or modified. String
segments are joined only to avoid compiler source-column limits. Original UTF-8 source
hashes and per-file expectations are in [manifest.json](manifest.json).
Markdown wrappers, WAT/binary decoding and directory/package resolution are outside this
pure source parser's input contract. The upstream runner also exercises those operations.

## Oracle and expectations

The upstream UI runner calls `Resolve::push_path`. It combines syntax, name resolution,
type validation, feature activation and package loading. Thus, expecting a syntax failure
for every file under `parse-fail` would incorrectly reject valid WIT syntax.

Expectations here come from the upstream syntax parser, without its resolver. For each
UTF-8 file, a local adapter calls `ast::lex::Tokenizer::new(text, 0)`, followed by
`ast::PackageFile::parse(&mut tokens)`. The adapter lives in the local reference checkout;
no upstream implementation code is copied into the MoonBit modules. To reproduce this
classification, expose this helper from the pinned `ast.rs` through `lib.rs` and call it
for each `.wit` file under `tests/ui`:

```rust
pub fn syntax_only(text: &str) -> Result<(), String> {
    let mut tokens = Tokenizer::new(text, 0).map_err(|e| format!("{e:?}"))?;
    PackageFile::parse(&mut tokens)
        .map(|_| ())
        .map_err(|e| format!("{e:?}"))
}
```

The reference accepts 294 files and rejects 27. Among the 206 files in UI failure
scenarios, 179 contain valid syntax and fail in later stages. Their per-scenario error
messages are retained in the manifest as context, not asserted as syntax diagnostics.
The manifest records positive syntax, syntax failures, resolution failures and resource limits
separately. All proposal switches are enabled in the MoonBit corpus tests.

Two reference rejections are intentionally accepted here:

| File | Reference restriction | MoonBit behavior |
|------|-----------------------|------------------|
| `parse-fail/type-nesting-too-deep.wit` | Fixed recursive type nesting limit | Explicit work stack accepts the source |
| `parse-fail/package-nesting-too-deep.wit` | Fixed recursive package nesting limit | Explicit work stack accepts the source |

The resulting expectations are 296 accepted files and 25 syntax failures. Every case
also asserts exact source reconstruction and validates both immutable arenas. These two
limit differences are overrides, not skips. Additional stress cases in `parser_test.mbt`
exercise deeper complete and incomplete syntax.

The corpus found and corrected empty selector handling, premature semantic cardinality/map-key
checks, and primitive `error-context` classification. The syntax parser deliberately leaves
those semantic checks to later tooling. Passing this pinned corpus establishes its tested
compatibility range; it does not claim equivalence for every future upstream change.
