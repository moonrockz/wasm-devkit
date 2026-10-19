# Complete verification examples

Run these commands from the repository root with `wasm-devkit` on PATH. Each
bundle contains all its local dependencies. The source CLI equivalent is
`mise run cli -- verify ...`. Verification checks types and dependencies without
executing components or changing source files.

## WIT resources, use and include

```shell
wasm-devkit verify examples/verification/wit --language wit --world app
wasm-devkit verify examples/verification/wit/app.wit --dep example:files@1.0.0=deps/files
cat examples/verification/wit/app.wit | wasm-devkit verify - --language wit --base examples/verification/wit
```

`wit/deps/files/files.wit` defines versioned package `example:files@1.0.0`, its
`file` resource and `host` world. `wit/app.wit` uses the resource in a returned
owned handle and includes the dependency world. Success exits 0 and prints, for
example, `examples/verification/wit: verified wit`. Add `--json` to inspect the
resolved world keys and interface/resource identities.

```shell
wasm-devkit verify examples/verification/invalid.wit --deps-dir wit/deps
```

This syntax-valid source returns a borrowed handle and exits 1:

```text
examples/verification/invalid.wit:6:9: error WIT-S007: a function result cannot contain a borrowed handle
examples/verification/invalid.wit:6:19: borrowed handle occurs here
```

## WAC wiring, spreads, implicit imports and targets

```shell
wasm-devkit verify examples/verification/wac/app.wac
wasm-devkit verify examples/verification/wac/implicit.wac --dep example:relay=deps/example/relay.wat
cat examples/verification/wac/app.wac | wasm-devkit verify - --language wac --base examples/verification/wac
```

`wac/app.wac` imports a WIT interface, passes its function to a versioned component
contract, spreads that instance's exports into another instance, and verifies the
final export against a WIT target world. The WIT target and both component
contracts are included under `wac/deps/example`. `implicit.wac` uses final-position
Fill to infer the relay's missing function import. Both exit 0.

Versioned and unversioned relay contracts use separate lookup names here because
a directory takes precedence over a neighboring `.wat` file in WAC's local
provider. `--dep` overrides only unversioned package keys.

```shell
wasm-devkit verify examples/verification/wac/invalid.wac
wasm-devkit verify examples/verification/wac/target-invalid.wac
```

The first exits 1 because it supplies `u16` where the component expects `u32`:

```text
examples/verification/wac/invalid.wac:4:33: error WAC-C005: function parameter `value`: expected `u32`, found `u16`
examples/verification/wac/deps/example/relay.wat:[binary]: expected type declared here
```

The second exits 1 with `WAC-T002` because the target requires an export named
`run`. Its related declaration points to `wac/deps/example/types/api.wit`.
Text line/column labels are one-based UTF-16 coordinates. A WAT dependency's
`[binary]` label does not claim that a compiled byte offset identifies original
text. A missing explicit mapping or unreadable file exits 2.

## Registry and offline verification

The [controlled registry suite](../../tests/registry/README.md) supplies a local
Warg server, published packages and every dependency. It needs no public account:

```shell
mise run build:registry-reference
mise run test:registry -- native
mise run test:registry -- wasm
```

It verifies cold downloads, warm/offline cache loads, pinned lockfiles and
invalid cached content. See the [CLI guide](../../cmd/wasm-devkit/README.md#registry-packages)
for user-facing registry commands and cache/lock policy. Native archives include
the authenticated network helper; pure libraries and offline runs do not need it.

These local bundles run in `scripts/test-cli.mbtx` on source wasm/native builds,
packaged executables, and the published moonx/mise installation checks. Library
API examples use checked `mbt check` fences in the verifier guides and run on all
four targets through `mise run test:docs`.
