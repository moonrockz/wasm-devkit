# Pinned WAC corpus

Source: [bytecodealliance/wac](https://github.com/bytecodealliance/wac/tree/5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9/crates/wac-parser/tests), revision `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`.
All 163 `.wac` files below `crates/wac-parser/tests` are embedded unmodified in
`../upstream_test.mbt`, including exact line endings. The upstream license is retained here.
`manifest.tsv` records each original UTF-8 SHA-256 and the reference syntax classification.

The oracle calls the public Rust `wac_parser::Document::parse` at this revision for every
file. 145 are accepted and 18 rejected. No files are skipped.
Resolution and encoding failures may have valid syntax, so their directory names do not
determine their expected parser result. No package registry or resolution is involved.
These checks run without filesystem access on wasm, wasm-gc, js and native.

The default syntax follows the pinned parser, including async, future, stream and error-context.
The upstream `LANGUAGE.md` also describes named function results, which this reference parser
rejects. Our `Features.named_results` option enables that grammar extension separately; it
is disabled for corpus checks. Syntax classification does not establish semantic validity.
