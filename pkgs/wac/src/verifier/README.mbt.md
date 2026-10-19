# WAC semantic verification

The `moonrockz/wac/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

Verification follows WAC 0.12.0 declaration order. It supports scalar and composite
types, records, flags, enums, variants, function types, resources, local interfaces
and worlds, `use` and delayed `include` declarations, typed imports, expression
aliases and explicit exports. Async functions, future, stream and error-context
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

Package dependency paths, component instantiation, instance access, export spreads,
targets and parser-only named results fail with `WAC-S003`. These remaining
composition and dependency operations are tracked under
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

Value nesting and expression groups use explicit work stacks. Tests exercise
3,000 nested composite types, 5,000 ordered aliases and 2,000 world includes on
wasm, wasm-gc, JavaScript and native. Duplicate type/function externs that panic
in the pinned resolver return diagnostics here; the exact oracle exclusions are
recorded in the semantic fixture guide and Beads tasks.
