# WIT semantic verification

The `moonrockz/wit/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

The local type profile supports complete package headers, interfaces/worlds, aliases,
records, flags, enums, variants, opaque resources, scalar/composite types and synchronous free interface
functions. WIT names may refer forward within an interface or world. Recursive type
graphs, empty aggregates/tuples, duplicate members and more than 32 flags are rejected.
Fixed lists use decimal u32 lengths, including zero. Enable their grammar through
`@parser.Features::all()` or CLI `--all-features`. Maps require direct bool, integer,
char or string scalar keys. At the pinned reference revision, aliases to those scalars
are rejected as map keys. Futures, streams and error-context types follow that same pin.

Resource methods, handles, use/include, world imports/exports, package dependencies,
attributes and other unsupported constructs fail with `WIT-S003` until their
semantics are implemented under [issue #5](https://github.com/moonrockz/wasm-devkit/issues/5).
A successful result covers the entire supported input. An unsupported or unresolved
construct never yields a `Verified` model.

## Examples

Put these imports in `moon.pkg` and the test below in `example_test.mbt`.

```moon.pkg
import {
  "moonrockz/wit/parser",
  "moonrockz/wit/verifier",
} for "test"
```

```mbt check
///|
test "verify syntax separately from semantics" {
  let source = "package example:app; interface api { type a = b; type b = u8; }"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  let model = @verifier.verify(parsed, source_id="api.wit", source~).unwrap()
  assert_eq(model.source(), "api.wit")
  assert_true(model.ast().equivalent(parsed.ast))
  let source = "package example:app; interface api { type item = missing; }"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  guard @verifier.verify(parsed, source_id="api.wit", source~) is Err(errors) else {
    fail("unresolved name was accepted")
  }
  assert_eq(errors[0].code, "WIT-S005")
  assert_eq(errors[0].primary.location.source, "api.wit")
}
```

## Contracts

`verify` rejects syntax diagnostics before checking semantics. `verify_ast` accepts
caller-built ASTs and validates arena structure, source bounds and semantic field roles
before using them. Neither operation formats or reparses the supplied AST.

`Verified` has a private constructor. Its AST, bindings and source context are immutable.
`identity()` exposes the package name. Binding identities use the source, lexical
scope and arena node. `types()` exposes a fully resolved immutable type graph;
each local type edge names an entry's `id`, with source-qualified provenance.
The graph includes aliases and anonymous composites without reparsing source. Diagnostics use
source-qualified UTF-16 half-open spans, with related locations for earlier declarations.
Ordering follows deterministic source traversal and requires no mutable global state.
`Diagnostic::render()` renders source identities and offsets without confusing dependency
locations with the root source. The CLI adds 1-based UTF-16 line/column coordinates.

Stable code families are `WIT-S001` for invalid ASTs, `WIT-S002` for missing package identity, `WIT-S003` for unsupported
semantics, `WIT-S004` for duplicate names and `WIT-S005` for unresolved or
incorrectly typed references. `WIT-S006` reports type cycles, `WIT-S007` reports invalid aggregate/composite contracts and `WIT-S008` distinguishes a non-type declaration used as a type.

## Inspect resolved types

The imports above also cover this example.

```mbt check
///|
test "inspect resolved type edges" {
  let source = "package example:app; interface api { record item { value: scalar } type scalar = u32; }"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  assert_eq(model.identity().name, "app")
  let types = model.types()
  assert_true(types.any(t => t.kind is Record(_)))
  for ty in types {
    if ty.kind is Alias(target) {
      assert_true(types.any(t => t.id == target))
    }
  }
}
```
