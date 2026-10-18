# wasm-devkit CLI

Syntax tools for WIT and WAC. The CLI parses and diagnoses source, inspects tokens and
immutable AST/CST arenas, prints canonical AST source and formats while retaining comments.
It performs no package resolution or composition evaluation.

## Install

Run version `0.1.1` without installing:

```shell
moonx moonrockz/wasm-devkit@0.1.1 --help
moonx moonrockz/wasm-devkit@0.1.1 parse example.wit
```

Install the native release with [mise's GitHub backend](https://mise.jdx.dev/dev-tools/backends/github.html):

```shell
mise use github:moonrockz/wasm-devkit@0.1.1
mise exec -- wasm-devkit --version
```

Native archives cover Linux x64, macOS arm64 and Windows x64, with SHA-256 sidecars.
The moonx executable uses Wasm and the same pinned library versions.

From this repository, `mise run cli -- --help` or
`moon run cmd/wasm-devkit --target wasm -- --help` runs the local sources.
`mise run build:cli` builds, smoke-tests and packages a native host archive under `dist/`.

## Scenarios

### Check and format a WIT interface

Save this as `hello.wit`:

```wit
// Public API
package example:greeter;
interface greeter{hello: func(name: string)->string;}
```

```shell
moonx moonrockz/wasm-devkit@0.1.1 parse hello.wit
moonx moonrockz/wasm-devkit@0.1.1 format hello.wit
```

Parsing writes `hello.wit: valid wit`. Formatting writes this source to stdout:

```wit
// Public API
package example:greeter;
interface greeter {
  hello: func(name: string) -> string;
}
```

Use `format` to retain comments. `print` regenerates canonical source from the AST.
The [WIT library recipes](../../pkgs/wit/README.mbt.md#scenario-recipes) show how to perform
these operations in MoonBit code.

### Inspect a WAC composition

Save this as `app.wac`:

```wac
package example:app;
import host: interface { log: func(message: string); };
let app = new example:service { host, ... };
export app.run as "run";
```

```shell
moonx moonrockz/wasm-devkit@0.1.1 parse app.wac
moonx moonrockz/wasm-devkit@0.1.1 ast app.wac
moonx moonrockz/wasm-devkit@0.1.1 cst app.wac
moonx moonrockz/wasm-devkit@0.1.1 tokens app.wac
```

Parsing writes `app.wac: valid wac`. The inspection commands show typed node fields,
concrete token ranges and raw token spelling. Parsing does not fetch `example:service`
or check whether the composition is semantically valid.
The [WAC library recipes](../../pkgs/wac/README.mbt.md#scenario-recipes) show how to index
imports and bindings or preserve grouping during a rewrite.

### Enforce formatting in CI and apply it locally

```shell
moonx moonrockz/wasm-devkit@0.1.1 format --check hello.wit
moonx moonrockz/wasm-devkit@0.1.1 format --write hello.wit
moonx moonrockz/wasm-devkit@0.1.1 format --check hello.wit
```

The compact input above first returns status `1` because layout differs. `--write` updates
the named file after successful formatting; the last check then returns `0`.
Malformed source returns diagnostics and leaves the file unchanged. Use `--indent 4`
when your project uses four spaces.

### Process stdin or enable proposal syntax

In a POSIX shell:

```shell
cat hello.wit | moonx moonrockz/wasm-devkit@0.1.1 format --language wit
```

In PowerShell:

```powershell
Get-Content -Raw hello.wit | moonx moonrockz/wasm-devkit@0.1.1 format --language wit
```

Stdin needs `--language` because it has no extension. `--write` needs a named file.
For documented extensions such as WIT fixed-length lists or WAC named results, pass the
same profile when parsing and formatting. Save this as `proposals.wit`:

```wit
interface arrays { type words = list<u8, 16>; }
```

```shell
moonx moonrockz/wasm-devkit@0.1.1 parse --all-features proposals.wit
moonx moonrockz/wasm-devkit@0.1.1 format --all-features proposals.wit
```

For WAC, save this as `callbacks.wac` and use `--all-features` with the `.wac` file:

```wac
package example:types;
type callback = func() -> (value: u8);
```

See the [WIT parser profile](../../pkgs/wit/src/parser/README.mbt.md) and
[WAC parser profile](../../pkgs/wac/src/parser/README.mbt.md) for the exact syntax covered.

## Command reference

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

## Semantic verification

Run `wasm-devkit verify api.wit` or `wasm-devkit verify app.wac` to check the current
local semantic profile. Stdin requires `--language wit` or `--language wac`, plus `--base PATH` for dependency resolution.
Exit status is 0 for a fully verified supported model, 1 for syntax/semantic errors
or unsupported constructs, and 2 for invalid arguments or I/O errors.

`parse` and its `check` alias retain their syntax-only behavior. Verification does
not modify source files or execute components. See the library verifier guides for
the current profile. Dependency resolution and remaining semantics are tracked in issue #5.

### Resolve a WIT package

```shell
wasm-devkit verify ./wit --language wit
wasm-devkit verify ./wit/world.wit
wasm-devkit verify ./world.wit --deps-dir ./packages
wasm-devkit verify ./world.wit --dep example:dep@1.0.0=../dep
cat ./world.wit | wasm-devkit verify --language wit --base ./wit
```

A WIT directory combines its immediate `*.wit` files. Dependencies come from the
resolution base's `deps` directory by default. Each direct subdirectory is one
package; direct `.wit` files are individual packages. Other files are ignored.
Nested dependency directories are not searched, matching the pinned WIT resolver.

The resolution base defaults to the input directory, or to a file's parent directory.
`--base` overrides it. Dependency roots and explicit mappings are relative to that
base; absolute paths are also accepted. Explicit mappings override discovered
packages with the same declared identity. A mapping must match the loaded package's
name and optional version. Version references match exactly; an unversioned reference
does not fall back to a versioned package.

WAC dependency providers and encoded WIT packages remain explicit unsupported errors
while the remaining issue #5 tasks are implemented. Source files are never rewritten.

WIT files may also contain top-level dependency package blocks after the main
package header. For example, `package example:app;` may be followed by declarations
and `package example:dep { interface api {} }`. Qualified imports resolve those
blocks without separate dependency files. The main package still needs a header;
duplicate identities and package blocks inside other blocks fail verification.
File-local aliases stay separate for each package, even within the same file.

### Verify a resource API

Save this source as `files.wit` and run `wasm-devkit verify files.wit`.

```wit
package example:files;
interface files {
  resource file {
    constructor(path: string) -> result<file, string>;
    read: async func() -> list<u8>;
    open: static func(path: string) -> file;
    position: get() -> u64;
    position: set(value: u64);
  }
}
world app { import files; }
```

Methods receive an implicit borrowed receiver, and resource-valued parameters and
results mean owned handles. A constructor's declared return must be a result with
the constructed resource as its direct success type. Changing its return to
`own<file>` keeps the syntax valid but makes `verify` exit with status 1 and
`WIT-S007` at the constructor result. Borrowed handles anywhere in a function
result also fail verification. Source files remain unchanged.

Accessors use the pinned reference grammar during `verify`. Getters require a
result and no explicit parameters. Setters require one explicit parameter, an
exact corresponding getter, and an optional result with no success type.
Changing `position: set(value: u64)` to return `u8` is syntax-valid under
`check --all-features` and fails `verify` with `WIT-S007`.

### Select and inspect WIT worlds

```shell
wasm-devkit verify ./wit --language wit --world app
wasm-devkit verify ./wit --language wit --world example:app/app@1.0.0
wasm-devkit verify ./wit --language wit --json
```

Verification checks the supplied package closure. `--world` additionally requires
an unambiguous world selection. A short name refers to the root package; a qualified
world ID may select a dependency world. A package-only selector must contain exactly
one world. Missing or ambiguous selections exit with status 1 and source-qualified
diagnostics. Omitting `--world` verifies all worlds without selecting one.

`--json` emits world keys, item kinds, named interface identities and directly
referenced resource identities. The report covers the entire verified closure.
Includes retain source provenance, expand renames and dependencies, and distinguish
fresh world-owned resources from resources imported through named interfaces.
