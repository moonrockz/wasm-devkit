# WIT semantic verification

The `moonrockz/wit/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

The local type profile supports complete package headers, interfaces/worlds, aliases,
records, flags, enums, variants, opaque resources, scalar/composite types and synchronous free interface
functions. WIT names may refer forward within an interface or world. Recursive type
graphs, empty aggregates/tuples, duplicate members and more than 32 flags are rejected.
Local member names and named world keys must be strongly unique, so `a` and `A`
conflict. Reference lookup remains case-sensitive. Package-level interface/world
names and file aliases retain their distinct casing.
Fixed lists use decimal u32 lengths, including zero. Use `@parser.Features::reference()`
when supplying parsed models for the pinned semantic profile. CLI verification uses
that grammar profile; syntax commands retain their existing default/all profiles. Maps require direct bool, integer,
char or string scalar keys. At the pinned reference revision, aliases to those scalars
are rejected as map keys. Futures, streams and error-context types follow that same pin.

Source packages may span multiple files. Interface type `use` selectors and renames
resolve through supplied local or external packages, including transitive and diamond
dependencies. Version-qualified paths match exact package identities. An unversioned
reference does not select a versioned package. Worlds support local/external aliases,
inline interfaces, function/interface imports and exports, and include-with renames.
Their transitive interface dependencies remain runtime imports and require no component
implementation.

Resource methods, handles, encoded packages and attributes still fail explicitly
under `WIT-S003`. Their implementation
continues under [issue #5](https://github.com/moonrockz/wasm-devkit/issues/5).
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
each type edge names an entry's closure-local `id`, with source-qualified provenance.
The graph includes aliases and anonymous composites without reparsing source. Diagnostics use
source-qualified UTF-16 half-open spans, with related locations for earlier declarations.
Diagnostics sort by source identity, UTF-16 span and code. Resolution uses no mutable global state.
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

## Resolve a supplied package closure

`Document::from_parse` accepts existing parser results. Callers can also construct
`Document` values from existing ASTs and syntax diagnostics. The resolver validates
all supplied files and packages, including dependencies that are not referenced by
the root. Providers decide which sources to supply. Filesystem and registry adapters
belong outside this package.

```mbt check
///|
test "resolve a package without implementing its runtime import" {
  let root_text = "package example:app@1.0.0; world app { import example:dep/api@1.0.0; }"
  let dep_text = "package example:dep@1.0.0; interface api { greet: func(name: string) -> string; }"
  let root : @verifier.SourcePackage = {
    documents: [
      @verifier.Document::from_parse(
        "world.wit",
        root_text,
        @parser.parse(root_text),
      ),
    ],
  }
  let dep : @verifier.SourcePackage = {
    documents: [
      @verifier.Document::from_parse(
        "deps/api.wit",
        dep_text,
        @parser.parse(dep_text),
      ),
    ],
  }
  let model = @verifier.resolve(root, dependencies=[dep]).unwrap()
  assert_eq(model.root().name, "app")
  assert_eq(model.worlds()[0].imports[0].name, "example:dep/api@1.0.0")
  assert_eq(model.sources()[0].ast, root.documents[0].ast)
}
```

Every source keeps its original text and AST. `Resolution::origin(id)` maps a
closure-local node/type identity back to its source-qualified UTF-16 location and
original arena index. Successful identities and diagnostics are independent of
source/dependency discovery order. Explicit work stacks handle type, interface and
package cycles; related labels explain dependency chains, including syntax failures
in a dependency whose package header can still be recovered.

`WIT-S009` reports an unresolved package identity. `WIT-S011` reports conflicting
package metadata or duplicate supplied identities. Missing interface/type selectors
use `WIT-S005`; wrong declaration kinds use `WIT-S008`.

## Select and inspect a world

Top-level `use` aliases remain file-local and refer to direct package declarations.
They can name a declaration defined later; they cannot name another alias. Interface
IDs retain their original canonical identity. Includes clone world-owned types and
anonymous interfaces. Their owned resources receive fresh nominal identities while
keeping the original source location. Aliases to resources imported from named
interfaces continue to reference those external resources.

```mbt check
///|
test "include a world and inspect its runtime imports" {
  let source = "package example:app; interface api { type t=u8; } world base { import api; export run:func(); } world app { include base with {run as execute} }"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  let world = model.select_world(name=Some("app")).unwrap()
  assert_eq(world.imports[0].name, "example:app/api")
  assert_eq(world.exports[0].name, "execute")
  assert_true(
    model.select_world() is Err(errors) && errors[0].code == "WIT-S010",
  )
  assert_eq(model.interfaces()[0].types[0].name, "t")
}
```

`select_world()` requires exactly one root-package world. A short name selects a
root world. `example:app/app@1.0.0` selects a qualified world across the supplied
closure; a package identity selects its sole world or reports ambiguity. Verification
without selection checks every supplied world and never chooses one implicitly.
`WIT-S010` reports ambiguous selection with candidate locations. `WIT-S012` reports
incompatible imported/exported interface dependency paths.

`world_summary()` returns JSON containing world import/export keys, item kinds,
named interface IDs and resource identities. It omits arena
indices, source locations and function/type bodies. Use `interfaces()`, `functions()`
and `types()` for that checked metadata. Each type's `scope` identifies its interface
or world, including fresh include instances. No tree walk or include expansion uses
recursive descent.

`Features::reference()` resolves the grammar ambiguity between named interface paths
and the older nested-namespace extension. Named paths in this profile are independent
of whitespace. The older `Features::default()` and `Features::all()` profiles retain
their pinned specification behavior, including the package-import example in that corpus.
