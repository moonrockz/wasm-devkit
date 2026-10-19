# Changelog

All notable changes to `moonrockz/wasm-devkit` are listed here, newest first.
Versions follow [Semantic Versioning](https://semver.org); while the version
is 0.x, a minor release can contain breaking changes.

<!-- git-cliff: end of header -->


## [0.2.0] - 2026-10-19

This release adds semantic verification for WIT packages and WAC compositions through
pure MoonBit library APIs and the `wasm-devkit verify` CLI. Syntax parsing and AST/CST
structure checks keep their existing meanings. Verified models are immutable and retain
source-qualified diagnostics and resolved dependency/type information.

WIT verification covers package closures, versions, names, type graphs, resources,
functions, uses/includes and worlds. WAC verification covers ordered declarations,
component arguments, nominal resource compatibility, inference, spreads, shared implicit
imports, exports and target worlds. Binary and WAT dependencies support validated core
modules, nested components, canonical operations, runtime instances and values within
the documented profiles. Verification never executes components.

The CLI accepts local source/encoded dependencies, explicit mappings and stdin resolution
bases. Optional authenticated Warg lookup adds checked caches, offline verification and
exact-version locks. Native archives include the registry transport helper. Complete
positive and negative bundles and checked library examples document the workflows.

Conformance checks use pinned wasm-tools and WAC references, compare complete resolved
models, and retain explicit upstream discrepancies. All 128 WAC resolution groups run
through CLI/API/provider checks; accepted compositions also pass independent binary
validation. Tests cover wasm, wasm-gc, JavaScript, native and Windows, including deep
inputs, resource identities, determinism and immutable results. See the verifier guides
for supported features, limits, diagnostics and reference reproduction commands.

### 🚀 Features

- Add semantic verifier APIs and CLI by @DamianReeves
- *(wit)* Verify local type graphs by @DamianReeves
- *(wit)* Resolve source package dependencies by @DamianReeves
- *(wit)* Verify world includes and aliases by @DamianReeves
- *(wit)* Verify nominal resource handles by @DamianReeves
- *(wit)* Verify resource function contracts by @DamianReeves
- *(wit)* Verify accessor contracts by @DamianReeves
- *(wit)* Resolve nested package blocks by @DamianReeves
- *(wit)* Verify release annotations by @DamianReeves
- *(wit)* Select semantic feature profiles by @DamianReeves
- *(wit)* Validate encoded type components by @DamianReeves
- *(wit)* Distinguish binary provenance by @DamianReeves
- *(wit)* Load encoded package dependencies by @DamianReeves
- *(wit)* Decode encoded resource functions by @DamianReeves
- *(wit)* Resolve encoded package metadata by @DamianReeves
- *(wit)* Decode v1 packages and WAT metadata by @DamianReeves
- *(wit)* Resolve scoped encoded type aliases by @DamianReeves
- *(wac)* Verify ordered declaration contracts by @DamianReeves
- *(wit)* Infer encoded foreign interfaces by @DamianReeves
- *(binary)* Validate declarative components by @DamianReeves
- *(wit)* Select inputs before inferred merges by @DamianReeves
- *(wit)* Decode world-owned resources by @DamianReeves
- *(wac)* Decode declarative component packages by @DamianReeves
- *(wac)* Resolve supplied package definitions by @DamianReeves
- *(cli)* Load WAC binary dependencies by @DamianReeves
- *(wac)* Load portable WAT dependencies by @DamianReeves
- *(wit)* Bind direct foreign type references by @DamianReeves
- *(wac)* Resolve instance member access by @DamianReeves
- *(wac)* Expose immutable composition graphs by @DamianReeves
- *(wit)* Retain external IDs across inputs by @DamianReeves
- *(wac)* Check component instantiation by @DamianReeves
- *(wac)* Resolve ordered spread arguments by @DamianReeves
- *(wac)* Resolve ordered export spreads by @DamianReeves
- *(wac)* Check composition target worlds by @DamianReeves
- *(wac)* Aggregate implicit imports by @DamianReeves
- *(wac)* Resolve WIT package dependencies by @DamianReeves
- *(wac)* Validate function export ascriptions by @DamianReeves
- *(wac)* Retain aliased function signatures by @DamianReeves
- *(wac)* Retain hierarchical alias metadata by @DamianReeves
- *(wac)* Support core module contracts by @DamianReeves
- *(cli)* Resolve checked Warg registry packages by @DamianReeves
- *(cli)* Bundle registry helper and examples by @DamianReeves
- *(wac)* Validate flat core module bodies by @DamianReeves
- *(wac)* Check type export annotations by @DamianReeves
- *(wac)* Check core module annotations by @DamianReeves
- *(wit)* Retain immutable core scope metadata by @DamianReeves
- *(wit)* Forward scoped core contracts by @DamianReeves
- *(wac)* Check instance export annotations by @DamianReeves
- *(wac)* Check component export annotations by @DamianReeves
- *(wac)* Validate synchronous canonical functions by @DamianReeves
- *(wac)* Preserve scoped component aliases by @DamianReeves
- *(wac)* Validate resource intrinsics by @DamianReeves
- *(wac)* Validate runtime component instances by @DamianReeves
- *(wac)* Validate component value externs by @DamianReeves
- *(wac)* Preserve runtime named type origins by @DamianReeves
- *(wac)* Validate runtime component values by @DamianReeves
- *(wac)* Validate structured core modules by @DamianReeves
- *(wac)* Validate nested components by @DamianReeves

### 🐛 Bug fixes

- *(wit)* Enforce strong member name uniqueness by @DamianReeves
- *(wit)* Canonicalize hyphens in member names by @DamianReeves
- *(wit)* Accept metadata struct sequences by @DamianReeves
- *(binary)* Respect pinned validation profiles by @DamianReeves
- *(wit)* Decode accepted encoded fixtures by @DamianReeves
- *(wit)* Preserve imported resource visibility by @DamianReeves
- *(wit)* Accept WAT unsigned index spellings by @DamianReeves
- *(wit)* Preserve selected merge type graphs by @DamianReeves
- *(wit)* Support canonical version suffixes by @DamianReeves
- *(wac)* Scope target resource binders by @DamianReeves
- *(ci)* Preserve registry fixture bytes by @DamianReeves
- *(ci)* Clean long registry fixture paths by @DamianReeves
- *(wac)* Reject local resource import captures by @DamianReeves
- *(cli)* Honor WIT verification grammar flags by @DamianReeves
- *(test)* Use WIT reference grammar in oracle by @DamianReeves

### 🚜 Refactoring

- *(wit)* Separate semantics from source by @DamianReeves
- *(wac)* Share core contract comparisons by @DamianReeves

### 📚 Documentation

- Clarify runtime component profile by @DamianReeves
- Align component runtime profiles by @DamianReeves
- Finalize verification profile status by @DamianReeves

### 🧪 Testing

- *(docs)* Check binary guide imports by @DamianReeves
- *(wac)* Expose composition graph reference data by @DamianReeves
- *(wac)* Expose implicit import aggregation by @DamianReeves
- *(wac)* Expose pinned WIT package encoding by @DamianReeves
- *(wit)* Gate upstream semantic models by @DamianReeves
- *(wit)* Verify encoded corpus and laws by @DamianReeves
- *(wac)* Gate upstream resolution corpus by @DamianReeves
- *(wac)* Check value target compatibility by @DamianReeves

**Full changelog**: https://github.com/moonrockz/wasm-devkit/compare/v0.1.1...v0.2.0



## [0.1.1] - 2026-10-18

This patch release adds scenario-based documentation for both libraries: 86 executable
API-comment examples and 98 README recipes with complete imports. The guides cover parsing,
Unicode spans and diagnostics, lossless tokens and trees, traversal, immutable rewrites,
printing and comment-preserving formatting, including invalid-input behavior and feature profiles.

The CLI guide includes complete WIT and WAC inputs, stdin usage and formatter check/write
workflows. README recipes now run in CI on wasm, wasm-gc, JavaScript and native. Library
behavior and public signatures are unchanged.

### 📚 Documentation

- Add tested WIT and WAC usage recipes by @DamianReeves

**Full changelog**: https://github.com/moonrockz/wasm-devkit/compare/v0.1.0...v0.1.1

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
