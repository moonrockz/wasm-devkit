# wasm-devkit

A MoonBit monorepo for WebAssembly language tooling, created from the
[moonrockz/smithy](https://github.com/moonrockz/smithy) project template.

## Use the libraries

The modules work independently. Install both to run the two quickstarts below:

```shell
moon add moonrockz/wit@0.3.0
moon add moonrockz/wac@0.3.0
```

The snippets below are executable MoonBit tests. In your MoonBit package, put these imports
in `moon.pkg`, copy the `test` blocks into `example_test.mbt` beside it, and run
`moon test --target wasm`. Application functions
use the same package imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/parser" @wit_parser,
  "moonrockz/wit/formatter" @wit_formatter,
  "moonrockz/wac/parser" @wac_parser,
  "moonrockz/wac/formatter" @wac_formatter,
} for "test"
```

### Format a WIT API without losing comments

```mbt check
test "quickstart: WIT interface formatting" {
  let source = "// public API\ninterface greeter{hello: func(name: string)->string;}"
  let parsed = @wit_parser.parse(source)
  assert_true(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
  let formatted = @wit_formatter.format(source).unwrap()
  assert_eq(formatted, "// public API\ninterface greeter {\n  hello: func(name: string) -> string;\n}\n")
  assert_true(parsed.ast.equivalent(@wit_parser.parse(formatted).ast))
}
```

### Inspect and format a WAC composition

```mbt check
test "quickstart: WAC composition formatting" {
  let source = "package demo:app;let app=new demo:service {...};export app.run as \"run\";"
  let parsed = @wac_parser.parse(source)
  assert_true(parsed.is_valid())
  assert_true(parsed.ast.nodes.any(node => node.data is New(..)))
  let formatted = @wac_formatter.format(source).unwrap()
  assert_eq(formatted, "package demo:app;\nlet app = new demo:service {\n  ...\n};\nexport app.run as \"run\";\n")
  assert_eq(@wac_formatter.format(formatted), Ok(formatted))
}
```

These operations parse syntax without loading or resolving `demo:service`. Diagnostics remain
available for invalid input, and the CST always reconstructs the original text.

| What you want to do | Start here |
|--------------------|------------|
| Parse WIT, render diagnostics or index an API | [WIT scenario recipes](pkgs/wit/README.mbt.md#scenario-recipes) |
| Inspect WAC imports, bindings and composition expressions | [WAC scenario recipes](pkgs/wac/README.mbt.md#scenario-recipes) |
| Walk trees, navigate cursors or perform immutable rewrites | [WIT traversal](pkgs/wit/src/traversal/README.mbt.md#recipes), [WAC traversal](pkgs/wac/src/traversal/README.mbt.md#recipes) |
| Apply source edits while retaining comments | [WIT editor recipe](pkgs/wit/README.mbt.md#edit-one-token-and-retain-comments), [WAC editor recipe](pkgs/wac/README.mbt.md#edit-one-token-and-retain-comments) |
| Work from a terminal or check formatting in CI | [CLI scenarios](cmd/wasm-devkit/README.md#scenarios) |
| Compare core WAT by decoded structure and numeric bits | [WAT comparison](pkgs/wit/src/wat_compare/README.mbt.md), [CLI compare](cmd/wasm-devkit/README.md#compare-wat) |
| Print a core-module or component `.wasm` binary as WAT | [Decompiler guide](pkgs/wit/src/decompiler/README.mbt.md), [CLI decompile](cmd/wasm-devkit/README.md#print-a-wasm-binary-as-wat) |

## Semantic verification

`wasm-devkit verify api.wit` and `wasm-devkit verify app.wac` check the current
semantic profiles. WIT source-package dependencies also work through
`wasm-devkit verify ./wit --language wit`, with local dependency roots and explicit mappings. Encoded WIT `.wasm` and `.wat`
packages have a strict v1/v2 type-wrapper profile through the same provider paths. Syntax
acceptance remains available through `parse` and `check`.
WAC verification covers ordered local types, interfaces, worlds, resources,
uses/includes, typed imports/exports, checked named/inferred/spread/implicit instantiation arguments,
instance member access, export spreads and target-world checks. Caller-supplied binary dependencies resolve
exact package keys and nested definition paths through immutable type graphs.
The CLI loads binary, portable WAT and WIT dependencies from local paths. Pure APIs accept WIT source/encoded closures.
WAC registry lookup is opt-in through an optional authenticated Warg transport,
with checked caches, offline verification and exact-version lockfiles. Native
archives include the helper. Complete [verification bundles](examples/verification/README.md)
include local dependencies and deliberate failures. See the
[CLI registry guide](cmd/wasm-devkit/README.md#registry-packages).
See the [WIT verifier](pkgs/wit/src/verifier/README.mbt.md) and
[WAC verifier](pkgs/wac/src/verifier/README.mbt.md) for checked examples and exact scope.
Canonical verification also covers selected handle/cancellation intrinsics and
scalar `gc`/`core-type` lift/lower. The [canonical profile fixtures](tests/semantic/wac-canonical-intrinsics/README.md)
record exact supported operations and explicit exclusions.
Dependency and component verification is implemented for the documented profile.
Unsupported constructs fail explicitly. Async canonical lift/lower and component
start sections are in the profile. Concrete GC/reference types, recursive groups,
supertypes, shared heap types and modern/legacy exception instructions validate
in binary and WAT. Complete reference contracts and explicit exclusions are in
the [binary extension fixtures](tests/semantic/wac-binary-extensions/README.md). Concrete scalar and vector globals retain shared
flags in binary and WAT, including module ascriptions. Nested and concrete
core declarations retain full UInt64 limits, address-width bounds and custom
memory pages of 1 or 65536 bytes. The binary extension work is tracked in `wasm-devkit-p5m.12`.

## Status

WIT source positions, structured diagnostics, a lossless scanner, typed immutable ASTs/CSTs,
a recovering parser, immutable traversal, rewrites, canonical printing and comment-preserving
formatting are implemented.
The scanner retains trivia and malformed text, validates WebAssembly string names and Unicode
source restrictions, and handles nested comments without recursion. Property tests and a 30,000-level
comment stress test run on wasm, wasm-gc, js and native.

The WIT parser has a documented grammar
profile, 68 pinned specification examples and all 321 WIT files from a pinned upstream parser corpus.
WAC has a lossless scanner, typed immutable AST/CST and recovering parser, tested against
all 163 files in its pinned reference corpus. WAC immutable traversal, rewrites, canonical printing and comment-preserving formatting
are implemented.
The CLI under `cmd/wasm-devkit` supports both languages, files/stdin, inspection, printing
and formatter check/write modes.
`moonrockz/wit/decompiler` and `wasm-devkit decompile` print a core-module or component `.wasm`
binary as one deterministic WAT document, with core modules and nested components inline.
`moonrockz/wac/decompiler` and the CLI provide API-shape inventories, component
selection and recursive WAC/WAT splitting. See the [split guide](pkgs/wac/src/decompiler/README.mbt.md).
Opt-in compatibility modes reproduce the pinned wasm-tools 1.262.0 and WABT 1.0.42 printers.
See the [compatibility fixtures](tests/decompiler/compatibility/README.md) for exact invocations and measured boundaries. The current release version is `0.3.0`.

| Module | Path | Intended capabilities |
|--------|------|-----------------------|
| `moonrockz/wit` | [pkgs/wit](pkgs/wit) | WIT scanner, AST, lossless CST, recovering parser, immutable stack-safe traversal, printer and formatter |
| `moonrockz/wac` | [pkgs/wac](pkgs/wac) | WAC scanner, AST, lossless CST, recovering parser, immutable stack-safe traversal, printer and formatter |

Both modules reserve `span`, `diagnostic`, `scanner`, `ast`, `cst`, `parser`, `traversal`,
`printer` and `formatter` packages. Both languages implement all packages for their documented grammar profiles.
Each language is independently consumable, with typed ASTs for traversal and printing.

Add future libraries under `pkgs/`. The [CLI](cmd/wasm-devkit/README.md) lives under `cmd/`
and is packaged for moonx and native mise installation. Register new modules in `moon.work`.
Keep external reference clones in ignored local scratch space. Their histories and implementation
code are not part of the published modules.

## Setup

```shell
git clone https://github.com/moonrockz/wasm-devkit.git
cd wasm-devkit
mise trust
mise install
mise run hooks:install
mise run check
mise run test:scripts
mise run test:docs
mise run test:cli -- wasm
mise run test:cli -- native
mise run build:cli
```

MoonBit, Node.js, yamllint, lefthook, Zig and git-cliff are pinned in
[.config/mise/config.toml](.config/mise/config.toml). If the mise archive lacks the core library or moonx,
complete the same pinned installation:

```shell
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | MOON_HOME="$(mise where http:moonbit)" bash -s -- "$(mise current http:moonbit)"
```

All automation is written in cross-platform MoonBit `.mbtx` scripts.

```shell
mise run format
mise run lint
mise run validate
mise run test                 # wasm, wasm-gc, js and native
mise run test -- js native
mise run build
mise run test:scripts
mise run test:docs            # README recipes with their documented imports
mise run test:native-zig
mise run clean
```

## Documentation checks

`mise run test` executes checked API comments and package README examples.
`mise run test:docs` additionally compiles all 27 library guides using exactly their
documented imports, including the root and module READMEs outside package source directories.
Both commands run on wasm, wasm-gc, js and native by default.

Generate API reference pages for each library:

```shell
moon -C pkgs/wit doc
moon -C pkgs/wac doc
```

The generated pages are under `_build/doc`. Target a library module for documentation;
the workspace root has no source package.

## Language contracts

Scanner and CST reconstruction must preserve every source character, including comments, whitespace
and malformed input. ASTs describe language constructs without formatting trivia.
Public trees and child collections are immutable; mutable backing arrays must not escape.

Walks, folds, reductions, event readers, cursors and immutable rewrites use explicit stacks.
Printers and formatters also handle deeply nested trees without recursive tree descent.
Printers emit canonical source from ASTs. Formatters retain comments and meaning while normalizing layout.
Printing then parsing preserves AST structure apart from locations; formatting is idempotent.

Parsing returns diagnostics, retains malformed text in the CST, recovers to later constructs and never
panics. Tests cover deep inputs, losslessness, immutability, event order and round trips
alongside pinned upstream compatibility fixtures.

## References

- [WIT specification](https://github.com/WebAssembly/component-model/blob/0220da84209397d9067c19cac83dae969aa85a7b/design/mvp/WIT.md),
  Component Model commit `0220da84209397d9067c19cac83dae969aa85a7b`.
- [WAC language reference](https://github.com/bytecodealliance/wac/blob/5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9/LANGUAGE.md)
  and [reference parser](https://github.com/bytecodealliance/wac/tree/5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9/crates/wac-parser),
  commit `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`.

These pins establish an implementation baseline. Record proposal-gated WIT features and WAC grammar
differences explicitly. When vendoring upstream fixtures, retain revisions, licenses and skip records.

## Tracking

Work lives in an isolated [Beads](https://github.com/steveyegge/beads) database for this repository.
Run `bd bootstrap` in a fresh clone, then `bd ready`. Root epic: `wasm-devkit-p5m`.
The Smithy database and tasks are not reused.

## Releases

The current release is `0.3.0`. All modules share the root version.
Version `0.0.0` is reserved for unpublished development.

Run `mise run release:prepare -- X.Y.Z` on clean main. This creates a local release branch,
updates versions and prepends a changelog section. Replace its highlights placeholder before
committing, pushing and opening a release PR. After merging the reviewed PR, dispatch the Release
workflow with that version and `dry_run=true` first. Publishing requires a separate dispatch with
`dry_run=false` and the `MOONCAKES_USER_TOKEN` repository or organization secret.

The release workflow validates all four targets and task scripts, then publishes `moonrockz/wit`,
`moonrockz/wac` and `moonrockz/wasm-devkit` in dependency order. Native CLI archives are built on
Linux x64, macOS arm64 and Windows x64 for mise installation.
See [AGENTS.md](AGENTS.md) and the release-manager skill for the exact sequence.

## License

Apache-2.0. See [LICENSE](LICENSE).

Runtime component type arguments preserve named declaration origins through
substitution. Private anonymous arguments remain valid, while escaping functions
and instances require visible names. Imported instance names, explicit export
ascriptions and repeated component templates retain their reference identities.
The runtime-origin fixtures compare binary and WAT acceptance and complete
ordered models with the pinned loader; one loader projection panic is recorded
separately. Runtime value arguments and outputs retain complete substituted
contracts, exact consuming uses and escaping-type visibility. Their fixtures also
compare public composition resource contexts with the pinned reference models.
Concrete nested definitions preserve scoped contracts and generative resource
identities through explicit validation and reconstruction stacks. Both pinned
WASI HTTP production components pass binary/WAT package and composition model
comparisons, with independently validated emitted compositions.
