# wasm-devkit

A MoonBit monorepo for WebAssembly language tooling, created from the
[moonrockz/smithy](https://github.com/moonrockz/smithy) project template.

## Status

WIT source positions, structured diagnostics, a lossless scanner, typed immutable ASTs/CSTs
and a recovering parser are implemented.
The scanner retains trivia and malformed text, validates WebAssembly string names and Unicode
source restrictions, and handles nested comments without recursion. Property tests and a 30,000-level
comment stress test run on wasm, wasm-gc, js and native.

WIT traversal, printing and formatting are still pending. The parser has a documented grammar
profile, 68 pinned specification examples and all 321 WIT files from a pinned upstream parser corpus.
WAC remains a scaffold exposing only its development version. No CLI is available yet,
and nothing has been published to mooncakes.io.

| Module | Path | Intended capabilities |
|--------|------|-----------------------|
| `moonrockz/wit` | [pkgs/wit](pkgs/wit) | WIT scanner, AST, lossless CST, recovering parser, immutable stack-safe traversal, printer and formatter |
| `moonrockz/wac` | [pkgs/wac](pkgs/wac) | WAC scanner, AST, lossless CST, recovering parser, immutable stack-safe traversal, printer and formatter |

Both modules reserve `span`, `diagnostic`, `scanner`, `ast`, `cst`, `parser`, `traversal`,
`printer` and `formatter` packages. WIT implements the first six; traversal, printer and formatter remain reserved.
Each language will be independently consumable. WAC also gets an AST for typed traversal and printing.

Add future libraries under `pkgs/`. The planned CLI will live under `cmd/` and support
moonx and mise installation. Register new modules in `moon.work`.
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
mise run test:native-zig
mise run clean
```

## Language contracts

Scanner and CST reconstruction must preserve every source character, including comments, whitespace
and malformed input. ASTs describe language constructs without formatting trivia.
Public trees and child collections are immutable; mutable backing arrays must not escape.

Walks, folds, reductions, event readers, cursors and immutable rewrites use explicit stacks.
Printers and formatters also handle deeply nested trees without recursive tree descent.
Printers emit canonical source from ASTs. Formatters retain comments and meaning while normalizing layout.
Printing then parsing preserves AST structure apart from locations; formatting is idempotent.

Parsing returns diagnostics, retains malformed text in the CST, recovers to later constructs and never
panics. Implementations will test deep inputs, losslessness, immutability, event order and round trips
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

Version `0.0.0` marks the unpublished scaffold. All modules share the root version.
The first release will be `0.1.0`, after both languages and the CLI are ready.

Run `mise run release:prepare -- X.Y.Z` on clean main. This creates a local release branch,
updates versions and prepends a changelog section. Replace its highlights placeholder before
committing, pushing and opening a release PR. After merging the reviewed PR, dispatch the Release
workflow with that version and `dry_run=true` first. Publishing requires a separate dispatch with
`dry_run=false` and the `MOONCAKES_USER_TOKEN` repository or organization secret.

The library workflow validates all four targets and task scripts, publishes only `moonrockz/wit`
and `moonrockz/wac`, then creates the GitHub release. There are no inherited CLI assets.
See [AGENTS.md](AGENTS.md) and the release-manager skill for the exact sequence.

## License

Apache-2.0. See [LICENSE](LICENSE).
