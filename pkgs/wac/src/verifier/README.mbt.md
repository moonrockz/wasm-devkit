# WAC semantic verification

The `moonrockz/wac/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

Verification follows WAC 0.12.0 declaration order. It supports scalar and composite
types, records, flags, enums, variants, function types, resources, local interfaces
and worlds, `use` and delayed `include` declarations, typed imports, expression
aliases, named/inferred/spread component arguments, instance member access and
explicit/spread exports and target-world checks. Async functions, future, stream and error-context
types follow the pinned resolver. Functions cannot return borrowed resources,
including borrows nested inside aliases or aggregates.

Interface and world bodies have separate local scopes. Their value types cannot
refer directly to root declarations. `use` selects types from an earlier root
interface, while named world imports and exports may select root function or
interface types. Resources enter their scope before their methods. Constructors
return the resource, methods receive an implicit borrowed `self`, and static
functions have no receiver. Resource aliases retain nominal identity.

The verifier accepts the pinned resolver's external-name grammar, including
resource function names and import-only URL, integrity and dependency names.
These names are checked as strings and never cause network access. Interface
version suffixes are opaque during resolution, as in the pinned resolver.

Parser-only named results fail with `WAC-S003`. Remaining
composition coverage is tracked under
[issue #5](https://github.com/moonrockz/wasm-devkit/issues/5).
A successful result covers the entire supported input. An unsupported or unresolved
construct never yields a `Verified` model.

## Examples

Put these imports in `moon.pkg` and the test below in `example_test.mbt`.

```moon.pkg
import {
  "moonrockz/wac/parser",
  "moonrockz/wac/verifier",
  "moonrockz/wit/parser" @wit_parser,
  "moonrockz/wit/verifier" @wit_verifier,
} for "test"
```

```mbt check
///|
test "verify syntax separately from semantics" {
  let source = "package example:app; import greet: func(name: string) -> string; let run = greet; export run as \"run\";"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  let model = @verifier.verify(parsed, source_id="api.wac", source~).unwrap()
  assert_eq(model.source(), "api.wac")
  assert_true(model.ast().equivalent(parsed.ast))
  let source = "package example:app; let run = greet; import greet: func();"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  guard @verifier.verify(parsed, source_id="api.wac", source~) is Err(errors) else {
    fail("unresolved name was accepted")
  }
  assert_eq(errors[0].code, "WAC-S005")
  assert_eq(errors[0].primary.location.source, "api.wac")
}
```

Instance access preserves the exported item's type and nominal resource identity.
Dotted access first checks the exact export name, then a unique qualified interface
suffix without its version. Quoted access always uses the exact string. An ambiguous
suffix fails as a missing export. Groups and aliases preserve the same behavior.

```mbt check
///|
test "access an imported instance" {
  let source = "package example:app; interface api {run: func();} import service: api; let run = (service).run; export run;"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  assert_eq(model.exports().map(item => item.name), ["api", "run"])
  assert_true(model.exports()[1].kind is Function(_))
}
```

## Contracts

```mbt check
///|
test "inspect local resource and world contracts" {
  let source = "package example:app; interface api { resource handle { constructor(); read: func() -> u8; } type alias = handle; } world app { use api.{alias}; export run: func(x: alias); }"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  assert_eq(model.exports().map(item => item.name), ["api", "app"])
  let mut resource = -1
  let mut resource_alias = -1
  for ty in model.types() {
    if ty.name == Some("handle") {
      resource = ty.id
    }
    if ty.name == Some("alias") {
      resource_alias = ty.id
    }
  }
  assert_true(resource >= 0)
  assert_eq(model.resource_identity(resource_alias), Some(resource))
  guard model.exports()[1].kind is Type(world) &&
    model.types()[world].kind
    is World(Some("example:app/app"), [used], imports, exports) else {
    fail("missing world contract")
  }
  assert_eq(used.ty, resource_alias)
  assert_eq(imports.map(item => item.name), ["alias"])
  assert_eq(exports.map(item => item.name), ["run"])
}
```

`verify` rejects syntax diagnostics before checking semantics. `verify_ast` accepts
caller-built ASTs and validates arena structure, source bounds and semantic field roles
before using them. Neither operation formats or reparses the supplied AST.

`Verified` has a private constructor. Its AST, bindings, type graph and source context are immutable.
`types()` returns an arena of `ResolvedType` values. All type references are indices
in that arena, independent of AST node IDs. `items()` records declared names and
their resolved item kinds; `declarations()` retains declaration/reference bindings.
`composition()` retains immutable definition, import, instantiation and member-access
nodes. Instantiations record the exact package key and ordered argument edges.
Each node has its resolved item kind, source location and resource bindings. Repeated access to the
same export of the same instance reuses its node; aliases and groups preserve that
identity. `composition_exports()` records ordered root export names and their node
IDs, including several names for one value. Node IDs are separate from type and AST
IDs. Access and argument edges point to earlier nodes, so the graph is acyclic.
Resource bindings map static type IDs to runtime nominal identities. Separate imports
and instantiations freshen owned resources; aliases and captured resources retain
their identities. These graph identities are separate from `resource_identity()`,
which follows aliases in the static type arena.
`imports()` and `exports()` describe root items, including automatically exported
type declarations. Interface and world types contain their own ordered externs
and `use` metadata. `resource_identity()` follows nominal aliases with a bounded
loop and returns `None` for non-resources and invalid indices.
Binding identities use the source, lexical scope and arena node. Diagnostics use
source-qualified UTF-16 half-open spans, with related locations for earlier declarations.
Ordering follows deterministic source traversal and requires no mutable global state.
`Diagnostic::render()` renders source identities and offsets without confusing dependency
locations with the root source. The CLI adds 1-based UTF-16 line/column coordinates.

Stable code families are `WAC-S001` for invalid ASTs, `WAC-S003` for unsupported
semantics, `WAC-S004` for duplicate names and `WAC-S005` for unresolved or
incorrectly typed references. `WAC-S006` reports borrowed resources in function results.
`WAC-C001` reports access on a non-instance and `WAC-C002` reports a missing
export, with related instance-type provenance. `WAC-C003` reports duplicate or unknown
arguments, `WAC-C004` missing arguments, `WAC-C005` incompatible argument types or
resource identities, and `WAC-C006` a verification work-limit boundary. `WAC-C007`
reports a spread on a non-instance or a spread that contributes no arguments. Type mismatch
diagnostics retain both expected and provided type locations. `WAC-T001` reports
a wrong-kind target or an import absent from the target, `WAC-T002` a missing
required export, and `WAC-T003` incompatible target types or resource identities.

Value nesting and expression groups use explicit work stacks. Tests exercise
3,000 nested composite types, 5,000 ordered aliases and 2,000 world includes on
wasm, wasm-gc, JavaScript and native. Duplicate type/function externs that panic
in the pinned resolver return diagnostics here; the exact oracle exclusions are
recorded in the semantic fixture guide and Beads tasks.

Binary dependency diagnostics use `Location::binary` and byte offsets. Text
locations use `Location::text` and UTF-16 spans. `Location::span()` returns `None`
for binary locations; unknown binary offsets render as `[binary]`. This avoids
interpreting dependency bytes as coordinates in the root WAC source. Binary
package inputs preserve both dependency byte locations and the requesting source span.

## Declarative component packages

`decode_component_package(bytes, source_id~)` validates and reconstructs a
declarative component into an immutable `BinaryPackage`. It performs no I/O.
The caller supplies the lookup name separately; qualified names inside the
binary describe interfaces and worlds rather than the package's lookup key.

The model retains the original bytes and a type arena. `world()` identifies the
root imports and exports; `instance()` identifies the component's export
interface. `definitions()` identifies WIT interface/world wrappers exported by
the component. Declaration order, field/case order, function parameter names,
async signatures, resource aliases and interface uses remain available.
Repeated generic instance imports freshen owned resources. Captured outer
resources preserve their identity. Nongeneric instance types retain the
reference loader's identity from their first conversion, visiting imports before
exports. Unused templates do not determine that identity.

```mbt check
///|
test "inspect a binary dependency contract" {
  // (component (import "f" (func)) (export "f" (func 0)))
  let bytes = b"\x00asm\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01f\x01\x00\x0b\x07\x01\x00\x01f\x01\x00\x00"
  let model = @verifier.decode_component_package(bytes, source_id="dep.wasm").unwrap()
  assert_eq(model.bytes(), bytes)
  guard model.types()[model.world()].kind
    is World(None, [], [imported], [exported]) else {
    fail("missing component contract")
  }
  assert_eq(imported.name, "f")
  assert_eq(exported.kind, imported.kind)
  assert_eq(imported.location.span(), None)
}
```

This profile supports component/instance types, scoped aliases, scalar and
aggregate value types, fixed lists, maps, resources, handles, functions,
imports and re-exports. It follows WAC 0.12.0's wasmparser 0.258.0 map-key rules.
`WAC-B001` reports malformed framing, `WAC-B002` an unsupported boundary,
`WAC-B003` invalid component metadata, and `WAC-B004` reconstruction failures.
All diagnostic positions count bytes. Unknown offsets remain absent.

Concrete nested components, component instantiation, async canonical
functions and other intrinsics, component start sections and component-value externs remain unsupported. Function export ascriptions validate parameter
names, async mode, structural value types and nominal resource identities, and
retain the ascribed function type. Type-equality export annotations compare
complete value shapes and nominal resource identity, including imported aliases
and re-exports. Instance-exported function aliases preserve
complete value/resource signatures and outer declaration scopes, including nested
imported instances and parent/child re-exports. Private type graphs preserve
exported composite aliases and transitive captures without changing binary indices. The pinned external parser uses obsolete value-bound
encoding. Export annotations require complete supported contracts; unsupported
forms fail explicitly rather than producing a package model. Source `verify` and CLI lookup use this same declarative boundary.

Physical type scopes are limited to 256 before the external parser runs. Graph
construction and expansion use explicit stacks with a shared one-million-step
limit. Tests cover 5,000 nominal aliases, immutable snapshots, malformed input
and deep physical scopes on all four targets. Ordered type/resource/use
projections match the pinned `wac_types::Package::from_bytes` oracle for all 49
parseable dependency fixtures and 25 supported original packages. The 32
original probes also cover invalid metadata and the export annotations and unsupported
value boundaries. The dependency fixture sources, licenses, revision
and named-result WAT exclusion live in
[`pkgs/wit/src/binary/fixtures/wac`](../../../wit/src/binary/fixtures/wac/README.md).

## Caller-supplied package dependencies

`verify` and `verify_ast` accept `dependencies: ReadOnlyArray[PackageSource]`.
Each input supplies a lookup `name`, optional exact `version`, diagnostic `source`
and immutable component `bytes`. The lookup key is independent of the identities
encoded inside the component. Unversioned requests only match unversioned inputs;
versioned requests require that exact semantic version, including build metadata.
Duplicate keys and invalid input identities are rejected deterministically.

Packages are decoded on first use and cached within one verification operation.
Unused bytes are not decoded. Imported type graphs share the verifier's immutable
arena, preserve binary provenance and retain resource identity across repeated
references to one package. Distinct lookup keys retain separate graphs. Named uses,
world includes and imports resolve package definitions and nested exports. Paths
naming the current package resolve earlier local declarations, matching the pinned
resolver even when their version suffix differs. Self instantiation is rejected.

`WAC-P001` reports invalid input keys, `WAC-P002` duplicate inputs, `WAC-P003`
missing packages, `WAC-P004` missing definitions or nested exports, and `WAC-P005`
self instantiation. Binary decode failures retain their `WAC-B` code and byte
location, with a related label on the requesting WAC path. This API does no file,
registry or network lookup. The CLI loads the supported binary profile from local
paths and WIT source closures.

Twenty-two original dependency probes compare acceptance and ordered source models
with pinned `Document::resolve`, covering version matching, lookup/embedded identity
separation, repeated resources, nested exports, uses, includes and local paths.
Contract tests cover malformed dependency provenance, unused inputs and duplicate
keys. All supported binary inputs use the declarative profile described above.

`package_requests` collects dependency keys before loading them. It uses first-use
key order and retains the last requesting path, matching the pinned resolver's
map behavior. It validates syntax and source bounds, excludes local package paths,
and rejects self instantiation even inside nested argument expressions. It does
not establish semantic validity; pass the loaded inputs to `verify` afterward.

```mbt check
///|
test "collect exact dependency keys before I/O" {
  let source = "package app:main; import i: deps:api/types@1.2.3;"
  let requests = @verifier.package_requests(@parser.parse(source), source~).unwrap()
  assert_eq(requests.length(), 1)
  assert_eq(requests[0].name, "deps:api")
  assert_eq(requests[0].version, Some("1.2.3"))
}
```


## Checked instantiation

Named arguments use exact external names or unique qualified interface suffixes.
Quoted names are exact. Inferred arguments try the instance identity, its import or
alias name, then a unique interface suffix and the local binding name. Every required
import must receive one argument. Duplicate and unknown arguments fail.

Spread arguments run after every named/inferred argument, then in their written
order. Each contributes matching exports to still-unsatisfied imports. Exact names
win; otherwise the first export on a compatible semantic-version track wins. A
nonzero major matches that major, and `0.minor.patch` matches that nonzero minor.
Prereleases and `0.0.patch` names require exact equality. Build metadata does not
change a nonzero major/minor track. Versions may be newer or older; structural
compatibility is still required. A spread that contributes nothing is an error,
including a second spread whose exports were all supplied earlier.

A final `...` fills the remaining arguments with implicit imports. Shared imports
are aggregated after all declarations, including explicit imports written later.
An exact implicit/explicit name conflict is an error. Compatible version tracks
share one import under the greatest version name; interface exports are merged in
order. Named resource aliases also import their owning interface. Resource
binders may unify across shared imports, while captured handles retain their
nominal identities. Every consumer is checked again against the final aggregate.
The published composition is topologically ordered and uses the aggregate's type
and resource identities. Aggregation uses explicit work stacks and a shared
one-million-step limit, reported as `WAC-C006`.

Function parameters, names, result types and async markers must agree. Aggregate
fields/cases retain their order. Instance arguments may provide extra exports;
component arguments may require fewer imports and provide extra exports. Nested
component imports reverse that relation. Resource equations are solved after all
arguments have been checked, so argument order does not change nominal compatibility.

```mbt check
///|
test "wire two component instances" {
  // (component (import "f" (func)) (export "f" (func 0)))
  let bytes = b"\x00asm\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01f\x01\x00\x0b\x07\x01\x00\x01f\x01\x00\x00"
  let source = "package example:app; import f: func(); let first = new deps:relay {f}; let second = new deps:relay {f: first.f}; export second.f;"
  let model = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "deps:relay", version: None, source: "relay.wasm", bytes, },
  ]).unwrap()
  assert_eq(model.composition().length(), 5)
  guard model.composition()[3].operation
    is Instantiate("deps:relay", None, [argument]) else {
    fail("missing second instantiation")
  }
  assert_eq(argument.name, "f")
  assert_eq(argument.value, 2)
  assert_eq(model.composition_exports()[0].value, 4)
  let source = "package example:app; interface api {f: func();} import runtime: api; let output = new deps:relay {...runtime}; export output...;"
  let model = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "deps:relay", version: None, source: "relay.wasm", bytes, },
  ]).unwrap()
  assert_true(
    model.composition()[3].operation is Instantiate("deps:relay", None, [_]),
  )
  let source = "package example:app; let first = new deps:relay {...}; let second = new deps:relay {f: first.f, ...}; export second.f;"
  let model = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "deps:relay", version: None, source: "relay.wasm", bytes, },
  ]).unwrap()
  assert_eq(model.imports().length(), 1)
  assert_eq(model.imports()[0].name, "f")
  assert_eq(model.composition().length(), 5)
}
```

Original probes compare acceptance, ordered types and composition edges with pinned
WAC 0.12.0 `Document::resolve`. Two crossed-resource cases expose a resolver gap:
it accepts the arguments by resource name, but validating `wac compose` rejects
both because their nominal resource identities differ. This verifier rejects both.
The exact sources and package bytes remain in `instantiation_test.mbt`; the semantic
fixture guide records the exclusion. Contract tests cover 2,000 nested instantiations,
5,000 type aliases, immutable graph collections, fresh runtime identities and
source/binary diagnostic provenance on all four targets. The binary validator's
100-level type-depth limit still applies to loaded packages. Thirty-two additional
spread probes compare the pinned resolver's argument and alias edges, version
tracks, precedence, no-effect errors and crossed nominal resources.

Export spreads visit instance members in declaration order. An earlier export
with the exact same name wins, even when its type differs. A spread that adds
nothing fails with `WAC-C007`; spreading a function, component or type also fails.
Repeated member access shares one graph value, including across renamed exports
and spreads. A later explicit export of an already exported name is an error.
Export names cannot collide with local aliases of type definitions.

## Portable WAT packages

`decode_wat_component_package` compiles component WAT and applies the same
validation and graph reconstruction as `decode_component_package`. It shares the
strict portable frontend used for encoded WIT: quoted identifiers, byte/Unicode
escapes, comments, custom/producers annotations and binary text forms retain their
meaning. Input nesting is bounded before compiler helpers run. No host process or
network service is needed on any target.

The portable text grammar is a supported subset; unsupported forms return
`WAC-B002`. Invalid text returns `WAC-B001`; binary validation/reconstruction retains
its existing codes. Diagnostics use the WAT source identity and an unknown binary
offset because compiled bytes cannot identify an original source position.
`BinaryPackage::bytes()` returns the compiled component bytes.

```mbt check
///|
test "decode a portable WAT component" {
  let model = @verifier.decode_wat_component_package("(component)").unwrap()
  assert_true(model.types()[model.world()].kind is World(None, [], [], []))
}
```

All 49 retained WAC dependency sources now compile to the same ordered type,
resource and use projections as their pinned binaries. The invalid named-result
source remains rejected. Deep text and embedded-binary inputs, custom bytes,
quoted names and deterministic diagnostic provenance have focused regression tests.

## Target worlds

A `targets` directive selects a local or dependency world after all source declarations
have resolved. Local forward world declarations and aliases are accepted. Every
composition import must be available from the target, and every target export must
be supplied by the composition. Unused target imports and extra composition exports
are allowed. Import compatibility is contravariant; export compatibility is covariant.
Nested component imports reverse the subtype direction again.

```mbt check
///|
test "check a selected target world" {
  let source = "package example:app targets example:app/api; world api {import run: func();export out: func();} import run: func();export run as out;"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  assert_eq(model.imports().map(item => item.name), ["run"])
  let source = "package example:app targets example:app/api; world api {export out: func();}"
  assert_eq(
    @verifier.verify(@parser.parse(source), source~).unwrap_err()[0].code,
    "WAC-T002",
  )
}
```

Names match exactly, including versions and build metadata, as in the pinned
`Document::resolve` source resolver. Its separate `wac_types::validate_target`
binary checker uses semver-compatible name lookup; it is a separate comparison
profile, not the policy for source directives.

Target resource checking substitutes the target's imported identities into the
composition's input parameters. Independent composition parameters may receive the
same target resource. Captured resources retain that equality through exported
functions, while exported instances introduce fresh resource binders. These checks
never change the composition graph's own nominal identities. Diagnostics identify
the composition item, target selection and target declaration, retaining binary
locations for dependency worlds. Target comparisons share a one-million-step limit.

Original probes retain local and binary target sources, ordered reference models,
component variance, version-name behavior and resource relationships. One crossed
resource export is rejected despite pinned source resolution accepting it. A
component-model subtype witness independently rejects the same resource mismatch;
the exact witness and control are recorded in the semantic fixture guide. Deep
value types, 5,000 aliases, immutable results and deterministic provenance run on
all four targets. WIT dependencies use the adapter described below.

Nested target component types bind resources per declaration scope. Comparison
tracks variance through component imports and preserves captures in function
parameters/results. Reusing a source interface for two nested instance parameters
introduces distinct resource identities; an explicit alias retains its owner's
identity. Nested source `use` declarations add their named owner imports before
comparison. Temporary scoped type copies are removed before returning the model.
The retained 49-case subtype-witness matrix distinguishes these checks from the
pinned source resolver's weaker nominal comparisons.

## WIT dependency packages

`WitPackageSource` supplies a lookup name/version, a root `PackageInput`, and a
complete WIT dependency closure. `verify(..., wit_dependencies=...)` resolves
referenced inputs lazily. Binary and WIT inputs share the exact lookup key space;
duplicate keys fail before checking the source. Embedded WIT identities remain
independent of those lookup keys. WIT diagnostics retain their original source
or byte location and add the requesting WAC location.

`resolve_wit_package` resolves a supplied closure and returns immutable WAC package
types. `adapt_wit_package` accepts an existing immutable WIT `Resolution`.
Neither function reads files or runs an encoder. `WitPackage` exposes its types,
world, instance, definitions and resource identities. It contains no fabricated
component bytes. Generic interface/world occurrences receive fresh resource
binders while foreign uses retain their captured owners. Included worlds and
interface dependencies precede their users in the package wrapper order.

```mbt check
///|
test "use a WIT source dependency from WAC" {
  let text = "package embedded:types; interface api {resource handle;take:func(h:handle);}"
  let root = @wit_verifier.PackageInput::Source({
    documents: [
      @wit_verifier.Document::from_parse(
        "types.wit",
        text,
        @wit_parser.parse(text),
      ),
    ],
  })
  let source = "package test:app; import i: lookup:types/api; export i;"
  let model = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "types.wit",
      root,
      dependencies: [],
    },
  ]).unwrap()
  assert_eq(model.imports()[0].name, "lookup:types/api")
  assert_eq(model.composition_exports()[0].name, "embedded:types/api")
}
```

The adapter follows WAC 0.12.0's WIT 0.258.0 profile. For source parsing, enable
fixed lists and external IDs/named interface imports; leave nested namespace
syntax and accessors disabled. Source accessors supplied through a broader parsed
resolution fail with `WAC-W001`. The same code reports adapter graph/work-limit
failures. Default WIT semantic features filter unstable declarations. The separate
WIT verifier follows its documented 0.262.0 profile.

The CLI accepts `--dep lookup:types=types.wit` and discovers directory packages
under `deps/lookup/types`. A discovered directory loads its direct `deps` entries
as source or supported encoded WIT dependencies. A single file does not discover
sibling dependencies. Explicit mappings require files, matching pinned WAC.
Both source and encoded inputs remain available to pure API callers.

Original inputs and pinned acceptance tables are in
[`tests/semantic/wac-wit-providers`](../../../../tests/semantic/wac-wit-providers/README.md).
Focused tests compare package and composition structure, check independent resource
binders, preserve provenance, and exercise 3,000 nested type levels.

The [pinned upstream resolution corpus](../../../../tests/semantic/wac-upstream/README.md)
retains all 128 groups and their original filesystem dependency layouts. All
14 accepted groups compare complete type/composition projections, implicit
imports, argument/member edges and the resolver export-name map. Four-target
laws check deterministic results, independent provider ordering, formatting
preservation/idempotence and returned model immutability. Host-reference CI checks
all 128 actual provider/CLI/API outcomes and validates the accepted compositions.

## Core module contracts

Declarative packages can import, export and alias core modules. `ItemKind::Module`
refers to `TypeKind::Module`, whose immutable signature retains ordered core
imports/exports, function and tag signatures, globals, tables, memory limits,
address widths, shared flags and custom page sizes. Core function/module type
indices remain separate from the component type arena. Lexical aliases preserve
those index spaces; core signatures contain no component resource identities.

Module arguments permit fewer imports and more exports than required. Core
functions/tags and global types match exactly; table elements and memory/table
flags match exactly, with minimum/maximum subtyping. Targets apply the same
rules with import variance reversed. Fill merges ordered module contracts and
rechecks every original consumer. Eight pinned TypeAggregator successes produce
incompatible module contracts; the product rejects them, backed by independent
wasm-tools subtype witnesses in `tests/semantic/wac-core-modules/fill`.

Both binary and WAT inputs support these contracts and flat concrete core module
bodies. Core instantiation and synchronous canonical lift/lower are supported.
Imported component instantiation and inline instances are supported. Concrete
component definitions, non-resource type arguments, async canonical functions
and other intrinsics, component starts and values remain outside this profile.
Concrete GC/reference types, supertypes and shared heap types remain
unsupported. Nested component/instance core declarations with limits above u32
or custom memory pages return `WAC-B002` before the pinned parser runs; root
core-type sections support full UInt64 limits. The pinned WAC encoder panics
when composing the accepted core-module instance-export cases, so independent
validator witnesses establish their subtype behavior. No public API executes a
module or component. Remaining binary/runtime scope stays tracked on
`wasm-devkit-p5m.8.2.2`.


Concrete core modules retain ordered contracts and original bytes. Function
bodies, initializers, start signatures, exports and segment metadata validate
without execution. Flat instruction preflight protects the retained parser;
structured control and unimplemented proposals return `WAC-B002`. Function-only
recursive groups without concrete references are supported. Shared concrete
globals and limits above signed Int64 remain unsupported by the retained core
parser; declarative module types still retain their complete signatures.

The validation-work estimate for each module is its byte size multiplied by the
maximum of its function-type count, body count and one, plus expanded locals.
The sum across the component must not exceed 1,000,000. This bounds the retained
validator's type comparisons and per-function contexts before validation begins.
Five pinned WAC package-loader successes contain invalid instructions; product
verification rejects them, as wasm-tools does. Original witnesses, full ordered
models and five validating compositions are retained in
`tests/semantic/wac-runtime-modules`.

Core module export annotations use the ordered lexical module/type bindings and
check complete module contracts. Imports are contravariant, exports covariant;
unsigned limits, shared flags, table width and custom page sizes are preserved.
Later reexports see the annotated contract. Comparison work is bounded across
all annotations. The 49 retained cases compare binary and WAT package models;
three version differences are recorded in `tests/semantic/wac-module-ascriptions`.

Instance export annotations compare complete function/value shapes, concrete
resource identities, nested instances/components and core-module contracts using explicit
work stacks and a cumulative budget. Extra actual members may be hidden; aliases
and re-exports preserve the annotation's contract. Fresh resource declarations
in an annotation cannot replace an existing instance's resource identity. The
47 retained binary/WAT cases in `tests/semantic/wac-instance-ascriptions` compare
complete accepted models with both pinned references. Scoped metadata is seeded
with concrete instance resource identities before comparing component members.

Imported component export annotations compare complete function/value, instance,
component and core-module contracts. Imports reverse the subtype direction;
exports preserve it. Resource binders permit directed substitution while captured
identities and alias constraints remain fixed. Re-exports preserve the narrowed
contract. The 61 cases in `tests/semantic/wac-component-ascriptions` retain full
binary/WAT model comparisons and both reference results. Component aliases from
imported instances retain complete scoped metadata through nested aliases and
narrowed re-exports, including captures of concrete instance resources.

## Core instances and canonical functions

Binary and WAT dependencies support ordered core module instantiation, inline
core instances and core export aliases. Import checks retain complete unsigned
module contracts, shared flags and reference types. Synchronous canonical
lift/lower checks flattened signatures, indirect parameters/results, memory32
and memory64, realloc and post-return options. Imported instance functions retain
their defining type graph when lowered. Original module bodies are validated;
verification never executes them.

The canonical graph walk uses explicit stacks, cached shared types and a shared
work limit. Signature prefixes stop at 17 slots while every reachable aggregate
child is checked. Core instance contract checks share a separate work limit.
The 71 package probes and twelve composition cases in
`tests/semantic/wac-canonical-functions` compare the pinned APIs and ordered
models. Two package-loader flag mismatches are retained as explicit upstream
false positives, with independent validator rejection.


Canonical `resource.new`, `resource.drop` and `resource.rep` validate resource
identity and retain complete core signatures. New/rep require local resources;
drop also accepts imported resources. Representation types may be i32 or i64,
while resource handles remain i32. Destructors must accept exactly the resource
representation and return nothing. Export aliases preserve the original local
identity. The 42 cases in `tests/semantic/wac-resource-intrinsics` compare both
pinned validators and full binary/WAT models; four emitted compositions validate.

Runtime component instances preserve supplied resource identities and freshen
exported resources independently for each instantiation. Complete argument
contracts include functions, nested instances/components and core modules.
Binary and WAT models retain named uses and abstract component templates.
Non-resource type arguments return `WAC-B002` until named-type origins survive
signature normalization. The accepted named-record and rejected anonymous-record
reference cases are retained in `tests/semantic/wac-runtime-instances`, alongside
43 package probes and six source compositions. Four emitted compositions pass
independent binary validation; two additional pinned encoder panics are recorded
separately. Public APIs perform validation without executing components.
