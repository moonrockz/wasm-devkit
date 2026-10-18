# Changelog

All notable changes to `moonrockz/wasm-devkit` are listed here, newest first.
Versions follow [Semantic Versioning](https://semver.org); while the version
is 0.x, a minor release can contain breaking changes.

<!-- git-cliff: end of header -->


## [0.1.0] - 2026-10-18

First release of independently consumable WIT and WAC tooling for MoonBit. Both languages
provide lossless scanners, recovering parsers, immutable typed ASTs/CSTs, explicit-stack
traversal and rewrites, canonical printers and comment-preserving formatters.

The `wasm-devkit` CLI accepts files or stdin for parsing, diagnostics, AST/CST/token inspection,
printing and formatter check/write modes. Run it through moonx or install native release
archives with mise on Linux x64, macOS arm64 and Windows x64.

Grammar profiles and Unicode offsets are documented. Validation includes all 321 pinned
wasm-tools WIT files, 68 Component Model examples and all 163 pinned WAC corpus files,
plus property laws and deep-input cases on wasm, wasm-gc, js and native.

### 🚀 Features

- *(wit)* Add lossless lexical analysis
- *(wit)* Add stack-safe syntax parser
- *(wit)* Match pinned syntax corpus
- *(wit)* Add immutable traversal and rewrites
- *(wit)* Add printing and formatting
- *(wac)* Add lossless syntax frontend
- *(wac)* Add immutable traversal and rewrites
- *(wac)* Add printing and formatting
- *(cli)* Expose WIT and WAC tooling

### 🐛 Bug fixes

- *(release)* Detect missing native assets

### ⚙️ Maintenance

- Bootstrap wasm-devkit workspace by @DamianReeves
