# Semantic reference fixtures

Most fixtures are original Apache-2.0 examples for the verifier API.
They are a seed suite, not the complete upstream conformance gate required by issue #5.
`wit-encoded-upstream/` retains four encoded WIT regression fixtures and two
source inputs from the pinned wasm-tools revision, with upstream licenses and
exact hashes. Their README records provenance.

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
Feature-selected function and resource-method overlaps have directory fixtures
for default, explicit and all-feature profiles. Their binary inputs were encoded
with all features enabled so selection occurs during loading. Library tests also
cover mixed source/binary/WAT inputs, original provenance, disabled source
reference errors and deep source types before selection and compaction.

World-resource triples cover owned and aliased resources, distinct resources in
one or several worlds, constructors/methods, async/static functions, accessors
and metadata. The source metadata case requires all features, while its encoded
world functions and resource remain present with default features. Their graph comparison qualifies package/interface/world ownership
and checks function kind, flavor and async flags. Negative binaries export
methods/constructors of imported resources. The pinned decoder panics at
`decoding.rs:1209` for a world method attached to a resource alias; product tests
require a diagnostic, and this case stays outside the normal manifest under
`wasm-devkit-p5m.8.1.5` and `.8.1.7`. These original fixtures use Apache-2.0.

The original `wit-encoded-handle-*` cases compare imported resource aliases with
exported aliases through type equality, current-scope outer aliases, instance
aliases, maps and fixed-length lists. The included-world case also compares the
source, binary and WAT resource/type graphs.

The original Apache-2.0 `wit-encoded-direct-*` fixtures cover direct imported
instance type references without named use aliases, including own/borrow handles,
named values, distinct resources, generated-name collisions and interface
functions. Each WAT fixture was compiled with the pinned wasm-tools and accepted
by pinned Resolve. Product tests compare canonical function types against source
WIT, check that no extra aliases or world type imports appear, and exercise
supplied dependency provenance, caller order, metadata and feature selection.
The source equivalents require explicit use aliases; their extra declarations
are not claimed to be identical to the encoded model.

The original Apache-2.0 `wit-encoded-index-*` WAT fixtures compare unsigned
index spellings against wasm-tools 1.262.0 and wit-parser 0.262.0. Accepted forms
include leading plus, hexadecimal and digit separators. Negative cases cover
negative signs, uppercase radix prefixes, misplaced separators and overflow.
The syntactically valid but out-of-bounds `0x80000000` case is rejected by Resolve;
the retained compiler rejects indices beyond its signed 32-bit storage range.
Accepted spellings compile to the same bytes and resolved model as decimal zero.

The original Apache-2.0 `wit-external-id-*` cases compare source, binary and WAT
external-ID acceptance against the pinned tools. Verifier tests separately compare
IDs projected from pinned Resolve models for types, functions, resource methods,
renamed uses and world interface items. They check ignored container annotations,
empty strings, Unicode escapes, duplicate rejection, wrapper attributes, caller-order
merging and independently disabled members. These projections do not establish
complete model parity; full inferred/supplied model conformance remains tracked on
`wasm-devkit-p5m.8.1.5` and `.8.1.7`.

WAC instantiation probes in `pkgs/wac/src/verifier/instantiation_test.mbt` retain
original WAT, exact compiled package bytes and source text beside their pinned
ordered-model expectations. Two original cases are intentionally excluded from
`Document::resolve` acceptance parity: `resource-crossed` and
`same-interface-crossed`. Both supply `handle` from instance `a` and `take` from
instance `b`, where each instance declares its own `handle` resource and `take`
accepts that resource. The first uses distinct interface declarations; the second
imports the same interface twice. WAC 0.12.0 resolution accepts both, but its
validating `wac compose` rejects them with `resource types are not the same` at
byte offsets `0x156` and `0xec` respectively. The matching `a.handle` / `a.take`
controls compose successfully. Product tests require `WAC-C005` for both crossed
cases, preserving nominal identities independently of equal resource names.
Tracking: `wasm-devkit-p5m.8.2.4` and `wasm-devkit-p5m.8.2.7`.

The same 66 instantiation inputs also agree with `wac resolve`. A separate compose
sweep exposes five encoder failures already present when the `new` expression is
removed: `resource-type-alias` panics at `wac-graph/src/encoding.rs:702`, and the
matching record/variant/flags/enum cases fail because their root function import
uses a root-defined named value type. These are encoder limitations, not argument
compatibility exclusions. Their source-resolution tests retain the pinned
`Document::resolve` result; this verifier does not promise component emission.

The 32 original `spreads_test.mbt` probes retain package WAT/bytes and compare
acceptance, ordered source types, composition nodes and argument edges with both
pinned resolution entry points. Coverage includes explicit-first precedence,
ordered partial spreads, exact-name precedence, symmetric semver tracks,
prereleases, build metadata, zero-major versions, no-effect errors and type
compatibility. Its crossed-resource case is the same nominal exception as the
explicit-argument cases: resolution accepts it but validating composition rejects
it. The product rejects it with `WAC-C005`.

The original Apache-2.0 `wit-merge-stability-*` fixtures pin independently selected
source/binary merge behavior through the oracle's `--merge PATH` mode. Library tests
compare both input orders, function and reachable anonymous-type stability, named
body precedence, nominal resources, copied origins, feature-disabled members and a
50-level anonymous chain. Unknown named type/interface stability upgrades to known;
functions retain first-input stability. Unused reference arena allocations and raw
anonymous node IDs are outside this projection.

One mixed-input combination is an explicit reference exclusion, tracked on
`wasm-devkit-p5m.8.1.5` and `.8.1.7`. Merging
`wit-merge-stability-resource-body.wasm` first, then
`wit-merge-stability-resource-source.wit`, succeeds in wit-parser 0.262.0 at pinned
wasm-tools revision `e22db44da4eaf17a0e46ec55b911c7539589a3cc`, but produces a borrow
handle targeting scalar `u32`. `Resolve::merge` leaves named type compatibility
unchecked in `MergeMap::build_type_id`. The product rejects the combined model with
`WIT-B004`; the reverse order remains valid. Each input independently is a valid
manifest case. This exclusion does not establish full mixed-model conformance.

The related `constructor-result` and `setter-result` mixed pairs are also excluded:
first-input named body replacement can make a later constructor return another
resource, or replace a setter's result-without-success by `u32`. The pinned merge
accepts both; the product rechecks these semantic laws and rejects them. The
`resource-static-source` variant checks resource ownership without a handle in the
signature. The `borrow-result` pair differs: both implementations reject the
binary-first merge because the remapped result contains a borrowed handle through
an aggregate. All reverse orders and standalone files remain valid.

The `bare-resource` mixed pair is another accepted-reference exclusion: replacing
a supplied scalar alias by the earlier inferred resource leaves a bare resource
in function/aggregate value positions. The product rejects these values unless
an own/borrow handle wraps the resource. Standalone inputs and source-first merge
remain valid.

The 28 original `export_spreads_test.mbt` probes compare pinned WAC 0.12.0
`Document::resolve` and `wac resolve` acceptance, ordered composition types and
alias edges. They retain their source and the qualified-interface package's
WAT/bytes. Coverage includes earlier exports, conflicting types behind skipped
names, cached aliases, local type-definition aliases, resource contexts, exact
versioned names and nested instances. Export names are also checked independently,
because the public reference graph exposes only the last export name per node.

Sixteen of the seventeen accepted export cases also pass validating `wac compose`.
The resource-constructor case fails the pin's encoder at offset `0xca` with
`resource used in function does not have a name in this context`. Replacing its
spread with explicit exports of `handle`, `[constructor]handle`,
`[method]handle.take` and `handles` reproduces the same failure. This is an encoder
limitation, not a spread-resolution exclusion. The exact case remains accepted by
the verifier. Tracking: Beads `wasm-devkit-p5m.8.2.6`.

The original Apache-2.0 `wit-version-suffix-*` cases compare canonical major,
minor, patch and prerelease/build splits with wit-parser 0.262.0 at wasm-tools
revision `e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Invalid splits, partial versions,
leading zeroes and u64 overflow remain rejected. Library tests also compare
resource graphs, stability and both caller orders when an inferred dependency
uses a suffix but the supplied source uses the full version. WAC's separate
0.258 behavior is recorded under `pkgs/wit/src/binary/fixtures/version-suffix`.
These cases do not establish complete mixed-model conformance.

The 42 original `targets_test.mbt` probes compare target-world selection and
acceptance with pinned WAC 0.12.0 `Document::resolve` and `wac resolve`. Accepted
cases retain ordered source-model projections. Binary inputs retain original WAT
and bytes. Coverage includes forward/aliased local worlds, dependency keys,
import contravariance, export covariance, nested component variance, exact
versioned names, unused target imports, export spreads and resource identities.
Every source is also checked without its target constraint. The 26 local cases
that agree with reference resolution also run unchanged through the hashed CLI
fixture manifest under `wac-targets/`.

The optional oracle's `--target PACKAGE WORLD COMPONENT` mode separately calls
`wac_types::validate_target`. Its semver-compatible lookup accepts the tested
same-major and build-only name differences that source target resolution rejects.
These profiles are deliberately compared separately; source verification follows
exact-name lookup. All 15 binary probes have valid unconstrained compositions.

One source target case is an explicit nominal reference exclusion. Both source
resolution and validating `wac compose` accept `resource-crossed-export`, but
composition emission does not preserve the selected target constraint. The
independent component subtype witness in
[`wac-target-witnesses`](wac-target-witnesses/README.md) rejects the crossed
resource relationship. Its matching-resource control validates. The product
rejects the crossed case with `WAC-T003`, while accepting repeated instance
binders and aliased target input resources. Exact witnesses and the contravariant
alias control are retained beside that README.

The accepted `resource-implicit-use` source panics in pinned `wac compose` at
`wac-graph/src/encoding.rs:702`. Removing its target directive reproduces the
same panic. Resolution acceptance remains the oracle for this encoder limitation;
it is not excluded from target-resolution comparisons. These findings are tracked
on Beads `wasm-devkit-p5m.8.2.6`.

The original [WAC Fill cases](wac-fill/README.md) retain dependency bytes, WAT,
source, hashes and separate resolve/aggregation/validating-compose outcomes.
Library tests compare ordered aggregate models and binary/WAT equivalence; graph
contracts cover 3,000 chained instantiations and captured resource identity.
Reference panic and post-aggregation rejection cases are listed explicitly.

The target witness directory also retains 49 nested-resource cases with a hashed
acceptance table. They cover alternating component variance, imported/exported
function captures and source-world implicit resource owners. Source resolution
and independent binary subtype validation are recorded separately; the product
follows the latter where nominal checks differ. See the
[witness notes](wac-target-witnesses/README.md) for exact pins and exclusions.

The [function-ascription fixtures](wac-function-ascriptions/README.md) retain 41
original binary/WAT inputs compared with pinned WAC package loading and
wasm-tools with all features. Accepted package projections preserve the ascribed
signature and nominal resource graph. The one supported-by-reference but
unsupported instance-function alias case is recorded separately.
