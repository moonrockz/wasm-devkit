# WAC semantic verification

The `moonrockz/wac/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

This first implementation supports package headers, primitive aliases, function imports, value aliases and named function exports. Declarations enter scope only after their initializer or type has been checked. Runtime function imports remain valid.
Other constructs fail with `WAC-S003` until their semantics are implemented. Dependency
resolution, aggregates, resources and semantic feature selection are still in progress
under [issue #5](https://github.com/moonrockz/wasm-devkit/issues/5).
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

`verify` rejects syntax diagnostics before checking semantics. `verify_ast` accepts
caller-built ASTs and validates arena structure, source bounds and semantic field roles
before using them. Neither operation formats or reparses the supplied AST.

`Verified` has a private constructor. Its AST, bindings and source context are immutable.
Binding identities use the source, lexical scope and arena node. Diagnostics use
source-qualified UTF-16 half-open spans, with related locations for earlier declarations.
Ordering follows deterministic source traversal and requires no mutable global state.
`Diagnostic::render()` renders source identities and offsets without confusing dependency
locations with the root source. The CLI adds 1-based UTF-16 line/column coordinates.

Stable code families are `WAC-S001` for invalid ASTs, `WAC-S003` for unsupported
semantics, `WAC-S004` for duplicate names and `WAC-S005` for unresolved or
incorrectly typed references.
