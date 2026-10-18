# wasm-devkit CLI

Syntax tools for WIT and WAC. The CLI parses and diagnoses source, inspects tokens and
immutable AST/CST arenas, prints canonical AST source and formats while retaining comments.
It performs no package resolution or composition evaluation.

## Install

Run version `0.1.0` without installing:

```shell
moonx moonrockz/wasm-devkit@0.1.0 --help
moonx moonrockz/wasm-devkit@0.1.0 parse example.wit
```

Install the native release with [mise's GitHub backend](https://mise.jdx.dev/dev-tools/backends/github.html):

```shell
mise use github:moonrockz/wasm-devkit@0.1.0
mise exec -- wasm-devkit --version
```

Native archives cover Linux x64, macOS arm64 and Windows x64, with SHA-256 sidecars.
The moonx executable uses Wasm and the same pinned library versions.

From this repository, `mise run cli -- --help` or
`moon run cmd/wasm-devkit --target wasm -- --help` runs the local sources.
`mise run build:cli` builds, smoke-tests and packages a native host archive under `dist/`.

## Use

```shell
wasm-devkit parse example.wit
wasm-devkit ast example.wac
wasm-devkit cst example.wit
wasm-devkit tokens example.wac
wasm-devkit print example.wac
wasm-devkit format example.wit
wasm-devkit format --check example.wit
wasm-devkit format --write example.wac
cat example.wit | wasm-devkit parse --language wit
```

One input is accepted per invocation. The CLI infers the language from `.wit` or `.wac`;
`--language wit|wac` overrides inference and is required for stdin or other extensions.
Input defaults to stdin; `-` selects stdin explicitly. Use `--` before a filename starting
with a hyphen. `--indent 0..8` controls indentation, with a default of two spaces.
`--all-features` enables the grammar extensions documented by each parser.

Diagnostics go to stderr as `file:line:column: severity CODE: message`. Lines and columns
are 1-based and count UTF-16 code units. Source files must be valid UTF-8; decoding preserves
a leading BOM for the language scanner to handle. `ast`, `cst` and `tokens` emit indexed,
flat inspection rows to stdout, including recovered structures. Typed data and raw token
text use escaped MoonBit debug notation. This inspection format may evolve.

`print` requires valid original syntax and emits canonical source from the AST, discarding
trivia. `format` retains non-whitespace token spelling and comments. Its default writes to
stdout. `--check` emits no source and fails when layout differs. `--write` requires a named
file, validates before writing and checks whether the source changed after the initial read.
It never writes malformed input. Check and write modes are mutually exclusive.

Exit status is `0` on success, `1` for syntax errors or formatting differences, and `2`
for usage, decoding, I/O or internal output failures. No partial print/format source is emitted
on errors. The unchanged CST remains available for lossless recovery through the libraries.

## Development checks

The command core runs on wasm, wasm-gc, js and native. The I/O executable supports Wasm
and native through `moonbitlang/async`. `mise run test:cli -- wasm` and
`mise run test:cli -- native` exercise real files, redirected stdin, stdout/stderr, status
codes and formatter writes. `mise run test:cli -- --binary PATH` checks a packaged executable;
`--moonx VERSION` checks the published registry package.
