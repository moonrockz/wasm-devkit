# Semantic reference fixtures

These are original Apache-2.0 fixtures for the initial verifier API path.
They are a seed suite, not the complete upstream conformance gate required by issue #5.
No upstream fixture sources are copied here yet.

`wac-ordered/` adds 107 original cases covering ordered scopes, aggregate and
function contracts, nominal resources, uses, world includes, typed imports and
external names. Each is checked against both `wac resolve` and the pinned
`Document::resolve` API. WAC resource and world graph assertions also run as
MoonBit library tests on all four targets.

Two WAC 0.12.0 resolver panics are excluded from differential acceptance and
covered by ordinary product rejection tests. These exact sources are recorded
on `wasm-devkit-p5m.8.2.1` and `wasm-devkit-p5m.8.2.7`:

```wac
package example:app;world app{import t: func();type t=u8;}
package example:app;interface api{f: func();type f=u8;}
```

Each is a separate input. The reference exits 101 at the duplicate extern
assertion in `item_type_decl`; wasm-devkit returns `WAC-S004`. Neither case is
treated as a successful reference resolution.

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
`wasm-tools component wit --wasm` encoder. WAT cases include custom metadata and producers annotations.
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

Sequence-form metadata cases compare serde struct arrays for packages, interfaces,
worlds, types and stable/unstable payloads, including omitted default fields.
Extra elements, array dictionaries, array function metadata and array enum tags
remain invalid. The same exact bytes run through the pinned Resolve API and CLI.

Original v1 fixtures cover outer identity normalization, empty packages, worlds,
function metadata and invalid root exports. WAT fixtures cover raw custom bytes,
producer groups, quoted names, binary strings and strict lexical rejection.
These fixtures use this repository's Apache-2.0 license and the reference pins above.
The v2 duplicate-member case is intentionally excluded from the differential
manifest: wit-parser 0.262.0 panics at decoding.rs:799 (`prev.is_none()`) instead
of returning an error. The product regression requires an ordinary diagnostic.
Tracked exclusions: `wasm-devkit-p5m.8.1.5` and `wasm-devkit-p5m.8.1.7`.

Local encoded alias fixtures cover wrapper imports, instance-export aliases,
lexical outer aliases including count zero, renamed and multi-hop type/resource
aliases, partial interface projections, world type imports and implicit imports.
Source/binary/WAT pairs compare named type and function graph edges in library
tests, including distinct resources with identical declarations and aggregate
anonymous types. Invalid indices, missing members, aggregate field order and
resource receiver names are pinned negative cases. A 1,500-link named alias chain
also runs on all four library targets. The original fixtures use Apache-2.0.

A second explicit oracle exclusion covers importing a later local interface before
its root export. wit-parser 0.262.0 panics while merging its inferred package at
decoding.rs:1567. The product rejects forward inference without panicking, tested
in `encoded_alias_test.mbt`; this case is outside the normal 0/1 reference manifest.
The exclusion remains tracked under `wasm-devkit-p5m.8.1.5` and `.8.1.7`.

Version 0/1 alias metadata fixtures also compare renamed interface uses and world
uses. Their own type stability survives binary feature selection and keeps binary
provenance, including unstable aliases and future stable world type annotations.

Foreign encoded fixtures cover unioned and transitive inferred interfaces,
renamed world uses, aggregates, accessors, metadata, reserved names and fresh
resources when an instance type is reused. Original source/WAT/binary triples
use Apache-2.0 and the same pinned encoder. Library comparisons cover named type
and function edges plus reachable anonymous types; unused lowering intermediates
are excluded. This is not the complete upstream model-conformance gate.

Binary dependency directories exercise compatible partial unions and function
kind/parameter/result mismatches. Mixed source/binary directories that repeat an
inferred package are an explicit oracle exclusion: wit-parser 0.262.0 panics at
resolve/mod.rs:3521, attempting to re-add the package. Direct mixed-input behavior
is checked with the test oracle's `--merge PATH` mode instead. The directory panic
is tracked under `wasm-devkit-p5m.8.1.5` and `.8.1.7`, outside the normal manifest.
Feature-disabled overlapping views currently fail closed in product regressions;
per-input selection before merging remains on the encoded dependency task.
