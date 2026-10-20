# wasm-devkit CLI

Syntax tools for WIT and WAC. The CLI parses and diagnoses source, inspects tokens and
immutable AST/CST arenas, prints canonical AST source and formats while retaining comments.
It performs no package resolution or composition evaluation.
`decompile` prints a core-module or component `.wasm` binary as one WAT document.

## Install

Run version `0.2.0` without installing:

```shell
moonx moonrockz/wasm-devkit@0.2.0 --help
moonx moonrockz/wasm-devkit@0.2.0 parse example.wit
```

Install the native release with [mise's GitHub backend](https://mise.jdx.dev/dev-tools/backends/github.html):

```shell
mise use github:moonrockz/wasm-devkit@0.2.0
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
moonx moonrockz/wasm-devkit@0.2.0 parse hello.wit
moonx moonrockz/wasm-devkit@0.2.0 format hello.wit
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
moonx moonrockz/wasm-devkit@0.2.0 parse app.wac
moonx moonrockz/wasm-devkit@0.2.0 ast app.wac
moonx moonrockz/wasm-devkit@0.2.0 cst app.wac
moonx moonrockz/wasm-devkit@0.2.0 tokens app.wac
```

Parsing writes `app.wac: valid wac`. The inspection commands show typed node fields,
concrete token ranges and raw token spelling. Parsing does not fetch `example:service`
or check whether the composition is semantically valid.
The [WAC library recipes](../../pkgs/wac/README.mbt.md#scenario-recipes) show how to index
imports and bindings or preserve grouping during a rewrite.

### Enforce formatting in CI and apply it locally

```shell
moonx moonrockz/wasm-devkit@0.2.0 format --check hello.wit
moonx moonrockz/wasm-devkit@0.2.0 format --write hello.wit
moonx moonrockz/wasm-devkit@0.2.0 format --check hello.wit
```

The compact input above first returns status `1` because layout differs. `--write` updates
the named file after successful formatting; the last check then returns `0`.
Malformed source returns diagnostics and leaves the file unchanged. Use `--indent 4`
when your project uses four spaces.

### Process stdin or enable proposal syntax

In a POSIX shell:

```shell
cat hello.wit | moonx moonrockz/wasm-devkit@0.2.0 format --language wit
```

In PowerShell:

```powershell
Get-Content -Raw hello.wit | moonx moonrockz/wasm-devkit@0.2.0 format --language wit
```

Stdin needs `--language` because it has no extension. `--write` needs a named file.
For documented extensions such as WIT fixed-length lists or WAC named results, pass the
same profile when parsing and formatting. Save this as `proposals.wit`:

```wit
interface arrays { type words = list<u8, 16>; }
```

```shell
moonx moonrockz/wasm-devkit@0.2.0 parse --all-features proposals.wit
moonx moonrockz/wasm-devkit@0.2.0 format --all-features proposals.wit
```

For WAC, save this as `callbacks.wac` and use `--all-features` with the `.wac` file:

```wac
package example:types;
type callback = func() -> (value: u8);
```

See the [WIT parser profile](../../pkgs/wit/src/parser/README.mbt.md) and
[WAC parser profile](../../pkgs/wac/src/parser/README.mbt.md) for the exact syntax covered.

### Print a Wasm binary as WAT

Release `0.2.0` does not include this command. Run it from local sources with
`mise run cli -- decompile ...` until the next release.

```shell
wasm-devkit decompile module.wasm
wasm-devkit decompile component.wasm --output component.wat
cat module.wasm | wasm-devkit decompile -o module.wat
wasm-devkit decompile component.wasm --compatibility wasm-tools
wasm-devkit decompile module.wasm --compatibility wabt
```

For a module that exports one empty function `run`, stdout receives:

```wat
(module
  (type (;0;) (func))
  (export "run" (func 0))
  (func (;0;) (type 0)
  )
)
```

`decompile` reads one binary from a file or stdin. It writes the document to stdout,
or to the `--output`/`-o` file. The output path must differ from the input path. If the
output file already holds the input's bytes, the command exits with status 2 and does not write it.
The command never executes the binary and accepts no `--language` or formatting options.

The binary preamble selects the profile. A core module must be flat and inside the
profile that component verification uses. GC types, threads, exceptions, SIMD
instructions other than `v128.const`, shared globals and f32 signaling NaN constants
fail explicitly. Custom sections of core modules are omitted, and one
`;; custom section omitted: "NAME"` line names each.

A component must be inside the declarative component profile that verification uses.
Encoded WIT packages and runtime components both print. Sections print in binary order:
core modules print inline as `(core module (;N;) ...)`, nested components as
`(component (;N;) ...)`, and component custom sections as `(@custom "NAME" "BYTES")`.
The printed text compiles back through the same component text path, so `verify` on
the printed `.wat` of an encoded WIT package gives the same model as `verify` on the
binary. Values of type `error-context` are outside the profile.

Diagnostics go to stderr as `FILE:[byte N]: error CODE: message`, or `FILE:[binary]` when the
retained parser or validator supplies no offset. A failure prints no document and does not
create or change the output file. The default text uses index comments without identifiers.

`--compatibility wasm-tools` targets the default `wasm-tools 1.262.0 print`
invocation for core modules and components. `--compatibility wabt` targets
`WABT 1.0.42 wasm2wat --enable-all` with default debug-name behavior for core
modules. It rejects components and explicit recursive type groups. Both options
retain the existing input profile. Names, metadata, layout and literal spelling
follow the selected pin. Only newlines outside strings and a terminal newline
normalize in the compatibility comparisons. The [fixture guide](../../tests/decompiler/compatibility/README.md)
records the exact pins and measured reference/readback boundaries. Use the
matching pinned text tool to read compatibility output.

Compatibility cannot combine with `--split`, `--select` or `--select-none`.
Inventory is independent of printing style. Inventory, component selection and
recursive splitting are described below. See the
[decompiler guide](../../pkgs/wit/src/decompiler/README.mbt.md).

## Inventory and split component documents

```shell
wasm-devkit inventory app.wasm
wasm-devkit inventory app.wasm --json --output inventory.json
wasm-devkit decompile app.wasm --split app-documents
wasm-devkit verify app-documents/root.wac
wasm-devkit decompile app.wasm --split selected --select root/component-n0
wasm-devkit decompile app.wasm --split empty --select-none
```

Inventory includes every physical component and core module, stable path IDs,
optional binary/export names and complete public signatures. `--json` writes a
versioned flat type graph. Files and stdin work for both commands.

Split boundaries are components. Pure compositions become WAC and resolve local
WAC/WAT dependencies recursively. Components with core content stay WAT, with
core modules inline. Generated signature and operation adapters use ordinary WAC
package keys under `deps/split/`. Captured lexical values become explicit imports
that the containing WAC supplies. Every complete split is checked before output.

`--select` accepts exact inventory component IDs and can repeat. Omitting selection
converts all; `--select-none` creates no files. Unknown IDs and core-module IDs
fail without output. A subset omits unselected bodies and may require callers to
supply the omitted dependencies before verifying its WAC documents.

`--split` requires a new destination directory. Files are staged beside it and
published by one rename after success. Existing directories, invalid inputs,
unknown selectors and write failures leave the destination unchanged. `--output`
and `--split` cannot be combined. See the [library split guide](../../pkgs/wac/src/decompiler/README.mbt.md)
for identities, closure imports, adapter documents and supported profiles.

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
wasm-devkit decompile module.wasm --output module.wat
wasm-devkit decompile component.wasm
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

Exit status is `0` on success, `1` for syntax errors, formatting differences or `decompile`
input outside its profile, and `2` for usage, decoding, I/O or internal output failures. No partial print/format source is emitted
on errors. The unchanged CST remains available for lossless recovery through the libraries.

## Development checks

The command core runs on wasm, wasm-gc, js and native. The I/O executable supports Wasm
and native through `moonbitlang/async`. `mise run test:cli -- wasm` and
`mise run test:cli -- native` exercise real files, redirected stdin, stdout/stderr, status
codes and formatter writes. `mise run test:cli -- --binary PATH` checks a packaged executable;
`--moonx VERSION` checks the published registry package.

## Semantic verification

Run `wasm-devkit verify api.wit` or `wasm-devkit verify app.wac` to check the current
semantic profile. Stdin requires `--language wit` or `--language wac`, plus `--base PATH` for dependency resolution.
Exit status is 0 for a fully verified supported model, 1 for syntax/semantic errors
or unsupported constructs, and 2 for invalid arguments or I/O errors. Text labels
use UTF-16 line/column coordinates; encoded provider labels use byte offsets or
`[binary]` when no precise position is available.

`parse` and its `check` alias retain their syntax-only behavior. Verification does
not modify source files or execute components. See the library verifier guides for
the current profile. Dependency resolution and remaining semantics are tracked in issue #5.

WIT semantic features use `--semantic-feature NAME`, repeated for multiple names,
or `--all-semantic-features`. Disabled `@unstable` declarations are omitted; active
references to excluded declarations fail with `WIT-S013`. Names match exactly.
`--all-features` continues to control grammar extensions. Package versions come
from package headers and exact dependency paths. `@since` requires a package version
at least as new as its annotation; `@deprecated` preserves the declaration.

```shell
wasm-devkit verify api.wit --semantic-feature preview
wasm-devkit verify ./wit --language wit --all-semantic-features
```

The complete [verification bundles](../../examples/verification/README.md) include
every dependency for WIT resources/use/include and WAC wiring/spreads/targets,
with runnable valid and invalid cases. The CLI smoke suite checks these bundles
on wasm, native and installed moonx/mise paths.

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
package; direct `.wit`, `.wasm` and `.wat` files are individual packages. Other files are ignored.
Nested dependency directories are not searched, matching the pinned WIT resolver.

The resolution base defaults to the input directory, or to a file's parent directory.
`--base` overrides it. Dependency roots and explicit mappings are relative to that
base; absolute paths are also accepted. Explicit mappings override discovered
packages with the same declared identity. A mapping must match the loaded package's
name and optional version. Version references match exactly; an unversioned reference
does not fall back to a versioned package.

`verify package.wasm` and `verify package.wat` select WIT automatically. Encoded
inputs also work through `deps` discovery and `--dep` mappings. The current strict
v1/v2 profile supports named value types, resources and their function/accessor
contracts, freestanding functions and
world function/instance imports and exports, scoped aliases, inferred foreign
interfaces and cross-package nominal identities. See the
[encoded profile](../../pkgs/wit/src/verifier/README.mbt.md#current-profile) for
exact wrapper and declaration rules. Binary metadata
versions 0/1 retain stability and validate referenced items. Interface functions
follow semantic feature selection; binary types, worlds and world items remain
present under their own binary-loader rules. Use `--semantic-feature=VALUE` for
raw binary feature names that are empty or begin with `-`.
WAT accepts root `@custom` metadata and `@producers` annotations, quoted
identifiers, byte/Unicode escapes and component binary strings.
Unsupported forms return a diagnostic and exit 1. Missing files and provider I/O
failures return exit 2. WAC local binary dependencies use the separate layout below.
Source and encoded inputs are never rewritten.

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

### WAC local component dependencies

WAC `verify` loads caller-named binary component packages for imports, `use`,
world includes and nested definition paths. The package name used for lookup is
independent of the interface IDs encoded in the component.

```shell
wasm-devkit verify ./app.wac --dep lookup:dep=./component.wasm
wasm-devkit verify ./app.wac --deps-dir ./components
```

Paths are relative to `--base`, or the input file's directory by default. For
`lookup:dep`, automatic lookup tries `deps/lookup/dep`; if that is a directory it
is selected. Otherwise `.wat` takes precedence over `.wasm`. A versioned request
uses `deps/lookup/dep/1.2.3.wasm` (or `.wat`), preserving the full version string.
Explicit `--dep lookup:dep=PATH` mappings override only unversioned requests, as
in WAC 0.12.0. Repeated mappings use the last value. Unrequested mappings are not
read. The library API instead rejects duplicate supplied package keys.

The WAC dependency profile accepts validated component types from binary, WAT
and WIT inputs. A WIT directory loads its local `deps` closure; pure API callers
can supply source or encoded closures directly. `.wat` dependencies use the
portable component text frontend and then the same binary validator. Source
instantiation, member access, argument/export spreads, implicit imports and
target-world checks use resolved package types. See the
[WAC verifier guide](../../pkgs/wac/src/verifier/README.mbt.md) for the exact
binary profile and remaining runtime forms.

An unknown automatically discovered package is a semantic error (exit 1).
A missing explicit mapping or a file read failure is an I/O error (exit 2).
Invalid or unsupported components return exit 1, with dependency provenance and a
related requesting WAC location. WAT diagnostics use an unknown binary offset,
never compiled byte positions presented as original text coordinates. `WAC-P006` identifies dependency
read failures. Registry access requires the explicit options below. Verification
never executes a component.


## Registry packages

Registry access is opt-in for WAC verification. Local lookup runs first using the
rules above; a missing automatically discovered package may then be fetched.
Missing or invalid explicit mappings and invalid local packages never fall back
to a registry. Pure WIT/WAC APIs perform no network or cache I/O. WIT consumers
can pass downloaded encoded package bytes through the WIT provider API directly.

Native release archives include `wasm-devkit-warg` beside `wasm-devkit`; mise
adds both to PATH. Moonx users can install the native archive for the helper, or
build it from this repository with `mise run build:warg-provider`. A source build
uses Rust 1.94.1 and writes `.dev/warg-target/release/wasm-devkit-warg`, with `.exe`
on Windows. Put it on PATH or use `--warg-provider PATH`. Local, warm-cache and
offline runs do not need this executable. Windows source builds use rustup to
install the same pinned Rust toolchain.

```shell
wasm-devkit verify app.wac --registry https://registry.example.org --lockfile app.lock.json
wasm-devkit verify app.wac --registry https://registry.example.org --lockfile app.lock.json --offline
wasm-devkit verify app.wac --registry https://registry.example.org --lockfile app.lock.json --refresh
```

`--registry` accepts an HTTP(S) URL without embedded credentials, query or
fragment. No registry is inferred. `--registry-config PATH` selects an explicit
Warg client configuration for authentication and namespace mappings; no ambient
configuration is loaded and interactive prompts are disabled. Warg 0.9.0 verifies
registry logs, signatures and proofs. Exact requested versions include build
metadata; an unversioned request selects the latest non-yanked stable release.
The lookup identity comes from the authenticated registry record, independent of
any name embedded in the component.

By default, a checked cache entry takes priority over the network. `--refresh`
fetches updated registry metadata and bytes; `--offline` permits only local data
and checked cache entries. These flags cannot be combined. Unlike upstream WAC's
automatic registry update, the default preserves cached selections until an
explicit refresh. An offline cached release may therefore remain usable after a
registry yank. Semantic comparisons concern identical resolved bytes, not remote
availability or freshness.

`--cache-dir PATH` overrides the cache location. Otherwise the CLI uses
`XDG_CACHE_HOME/wasm-devkit`, `LOCALAPPDATA/wasm-devkit`, or
`HOME/.cache/wasm-devkit`, in that order. Entry keys include the exact registry URL,
package name and requested version. Treat spelling and trailing slash changes as
new registry identities. SHA-256 content addresses are verified on every load;
the verifier receives the same byte snapshot that passed that check. Invalid
cached or downloaded component data still fails semantic verification. Corrupt
cache metadata/content fails explicitly; `--refresh` can repair it from the
registry. Cache writes replace complete files atomically.

`--lockfile PATH` creates a schema-1 JSON file only after successful verification.
Each registry entry records its requested key, resolved exact version, requested
and resolved registry, and SHA-256 content digest. An existing lockfile requires
every registry request to be present and pins that release even during refresh.
It is never rewritten automatically. To select new versions, use a new lockfile
path or deliberately remove the old file and refresh. A temporary `PATH.lock`
directory prevents simultaneous lockfile writers and is removed after normal
success or failure. After an interrupted process, remove a stale guard only when
no verifier is using it.

Lockfiles cover registry inputs. Explicit and discovered local packages still
take priority and are not hashed into this registry lockfile. For reproducible
mixed inputs, preserve those files alongside the lockfile. All relative paths,
including cache, lockfile, configuration and explicit provider paths, use the
resolution base. A provider name without a path is searched on PATH.

Missing registry packages, unknown versions and offline cache misses report
`WAC-R001` and exit 1. Cache/lock identity or integrity failures use `WAC-R002` and
exit 2. Registry transport/protocol failures use `WAC-R003` and exit 2. Filesystem
setup errors also exit 2. Errors at a package request retain its WAC source
location; invalid component data retains both dependency and request provenance.

Two exact versions of one package are supported independently. The pinned WAC
registry resolver drops one such request; the retained
[registry comparison](../../tests/registry/README.md) documents that upstream
exception. The test suite uses a controlled loopback registry and runs without
public credentials on native and wasm CLI targets.
