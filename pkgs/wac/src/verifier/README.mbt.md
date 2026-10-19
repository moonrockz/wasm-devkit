# WAC semantic verification

The `moonrockz/wac/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

Verification follows WAC 0.12.0 declaration order. It supports scalar and composite
types, records, flags, enums, variants, function types, resources, local interfaces
and worlds, `use` and delayed `include` declarations, typed imports, expression
aliases, instance member access and explicit exports. Async functions, future, stream and error-context
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

Component instantiation, export spreads,
targets and parser-only named results fail with `WAC-S003`. These remaining
composition operations are tracked under
[issue #5](https://github.com/moonrockz/wasm-devkit/issues/5).
A successful result covers the entire supported input. An unsupported or unresolved
construct never yields a `Verified` model.

## Examples

Put these imports in `moon.pkg` and the test below in `example_test.mbt`.

```moon.pkg
import {
  "moonrockz/wac/parser",
  "moonrockz/wac/verifier",
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
`composition()` retains immutable definition, import and member-access nodes.
Each node has its resolved item kind and source location. Repeated access to the
same export of the same instance reuses its node; aliases and groups preserve that
identity. `composition_exports()` records ordered root export names and their node
IDs, including several names for one value. Node IDs are separate from type and AST
IDs. Access edges point to earlier nodes, so the current profile is acyclic.
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
export, with related instance-type provenance.

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

Core modules/types, concrete nested components, instantiation, canonical
functions, start sections, component-value externs and root export ascriptions
remain unsupported. The pinned external parser uses obsolete value-bound
encoding, and the retained validator does not yet check all export ascriptions.
Both valid and invalid examples of those forms fail explicitly rather than
producing a package model. This API does not yet connect binary dependencies to
source `verify` or CLI lookup.

Physical type scopes are limited to 256 before the external parser runs. Graph
construction and expansion use explicit stacks with a shared one-million-step
limit. Tests cover 5,000 nominal aliases, immutable snapshots, malformed input
and deep physical scopes on all four targets. Ordered type/resource/use
projections match the pinned `wac_types::Package::from_bytes` oracle for all 49
parseable dependency fixtures and 25 supported original packages. The 32
original probes also cover invalid metadata and the accepted-but-unsupported
value/ascription boundaries. The dependency fixture sources, licenses, revision
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
paths; WIT dependency adapters and component instantiation remain unfinished.

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
