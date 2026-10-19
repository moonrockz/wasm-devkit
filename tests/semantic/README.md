# Semantic reference fixtures

These are original Apache-2.0 fixtures for the initial verifier API path.
They are a seed suite, not the complete upstream conformance gate required by issue #5.
No upstream fixture sources are copied here yet.

`manifest.tsv` records acceptance and SHA-256 over the exact input bytes. For a
directory bundle, the digest covers each sorted relative file name, a NUL separator
and its bytes, including files intentionally ignored by source discovery. Each file
is passed unchanged to the reference semantic resolver and the wasm-devkit CLI.
Directory fixtures include complete multi-file and dependency bundles. There are no
registry lookups in this suite. The wasm-devkit CLI
uses `--all-features` to admit the fixed-list grammar. The reference resolvers use
the semantic profile recorded in each manifest row.

The optional fourth manifest column is `default`, `feature=NAME` or `all`.
Comma-separated names in a `feature=` profile enable multiple named features.
The runner passes matching `--features`/`--all-features` arguments to both WIT
reference tools and `--semantic-feature`/`--all-semantic-features` to wasm-devkit.
Three-column rows retain the default semantic profile. WAC rows use only `default`.

| Language | Reference | Revision | Semantic operation |
| --- | --- | --- | --- |
| WIT | wasm-tools 1.262.0 | `e22db44da4eaf17a0e46ec55b911c7539589a3cc` | `wasm-tools component wit FILE` calls WIT package resolution |
| WAC | wac-cli 0.12.0 | `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` | `wac resolve --deps-dir tests/semantic/deps FILE` calls `Document::resolve` |

Use the official release executables or build those exact revisions with their default
release build features. The runner checks executable version output. In-profile
acceptance differences fail the runner.

```shell
mise run build:semantic-reference
mise run test:semantics -- /path/to/wasm-tools /path/to/wac
```

The WIT grammar fixture pin predates this semantic reference; these seed cases use
syntax shared by both revisions. The WAC grammar and semantic revisions are identical.
The complete source/dependency corpus, full normalized model comparison, complete binary coverage,
feature profiles and justified exclusions remain tracked in Beads
`wasm-devkit-p5m.8.1.7` and `wasm-devkit-p5m.8.2.7`.

WIT type cases establish the pinned resolver's aggregate constraints, map-key categories,
fixed-list u32 bounds and lexical representation, forward references and recursive graphs.
In particular a `string` map key succeeds while an alias to `string` fails at this pin.

Source-package fixtures compare the issue's valid runtime import, missing packages,
versions/interfaces/selectors, multi-file identities, transitive diamonds, local and
package cycles, exact version selection, mismatched headers and discovery rules.
`wit-package-no-nested-deps.wit` deliberately places a dependency below another
package's `deps` directory; both resolvers reject the unresolved transitive package.

World cases cover include renames/conflicts/cycles, file-local aliases, inline and named
interfaces, implicit dependencies, mixed import/export paths and resource freshening.
Accepted WIT fixtures also compare normalized world summaries using the test-only
[pinned Resolve API oracle](../../tools/semantic-reference/README.md). The projection
compares keys, item kinds, named interface IDs and resource identities. Full
function/type-model corpus conformance remains in the original semantic gate tasks.
The helper preserves `WorldKey` discriminants because raw upstream JSON map names
can collide with user names such as `interface-0`.

Handle fixtures compare forward resource aliases, owned/borrowed parameters,
shorthand resource values, invalid handle targets and borrowed results hidden in
aliases, records, variants, futures and streams. Include cases exercise handles
to fresh local resources and preserved resources from named interfaces.

Resource-function cases cover implicit receivers, ordinary/static/async functions,
constructor default and fallible results, direct-resource success restrictions,
strong component-name collisions, duplicate constructors and resource renaming
through world includes. Accessor cases cover free/method/static getter-setter pairs,
arity and result restrictions, exact matching, differing value types accepted by
the reference, includes supplying getters and annotation-preserving renames.

Nested-package cases cover a main header plus top-level package blocks, independent
alias scopes within one source, transitive dependencies, world/resource includes,
multi-file discovery, missing main headers, duplicate identities, cycles and
forbidden blocks inside blocks.

Stability cases compare `since` and `deprecated` annotation combinations, owning
package versions, prerelease and build ordering, source dependency annotations,
and annotated resource functions, world items, use selectors and includes.
Feature profiles exercise inactive declarations, surviving references and owners,
borrowed results, accessor validation order, use/include/package boundaries,
anonymous interning and dependency/source allocation order.

Encoded fixtures include equivalent original source, binary and WAT packages,
named composites, async functions, nominal resource aliases, inline world interfaces,
local encoded dependencies, truncated bytes, invalid component type indices,
fixed-list bounds and memory64 layout overflow including aggregate padding.
Binary fixtures were generated from the original sources with the pinned
`wasm-tools component wit --wasm` encoder. The WAT case contains the same type
sections without custom metadata, within the portable frontend's current profile.
The runner passes `.wasm` and `.wat` inputs unchanged to both reference tools and
the product CLI, and compares world/resource summaries. World-owned resource members and cross-package encoded aliases remain outside this initial
profile; their implementation remains on `wasm-devkit-p5m.8.1.5`.

Encoded resource-function fixtures compare default/fallible constructors,
ordinary/static/async methods, implicit receivers, free/method/static accessors,
transparent constructor/setter result aliases, and their invalid signatures.
Binary setters require preceding matching getters; binary getter and setter
property types must agree even where source resolution alone accepts a mismatch.
These cases retain exact bytes and use the same pinned binary validator and
Resolve API operation as the corresponding positive packages.

Metadata cases cover version 0/1 JSON, all stability variants, raw feature strings,
future stable versions, dictionary and struct duplicates, overwritten schema errors,
missing targets and aggregate members, inline import/export precedence and source
packages consuming gated binary dependencies. They include deeply nested ignored
values, ignored unpaired surrogates/invalid UTF-8 and huge numbers accepted by the
pinned serde loader. Required strings still reject invalid Unicode and UTF-8.
Library tests also compare function selection, retained declaration stability,
anonymous receiver stability and binary provenance, beyond the world projection.
