# WIT semantic verification

The `moonrockz/wit/verifier` package checks an existing immutable syntax tree without
filesystem, network or subprocess I/O. `Parse::is_valid()` still checks syntax;
`Tree::validate()` still checks arena structure. Neither implies semantic validity.

## Current profile

The local type profile supports complete package headers, interfaces/worlds, aliases,
records, flags, enums, variants, resources, owned/borrowed handles, scalar/composite
types, constructors, getters/setters and ordinary/static methods. Free functions and methods may be
synchronous or asynchronous. WIT names may refer forward within an interface or world. Recursive type
graphs, empty aggregates/tuples, duplicate members and more than 32 flags are rejected.
Local member names and named world keys must be strongly unique. Canonicalization
folds ASCII case and removes hyphens, so `a-b`, `ab` and `AB` conflict.
Reference lookup preserves exact spelling. Package-level interface/world
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

Top-level `package name { ... }` blocks supply additional source packages in the
same file. They share one original document and AST while retaining separate
package ownership and file-local alias scopes. The main package still needs a
leading `package name;` header in at least one file. Nested identities must be
unique across blocks and supplied dependencies. Package blocks cannot contain
further package blocks, matching the pinned resolver.

`@since(version=...)` and `@deprecated(version=...)` attach immutable `Stability`
metadata to resolved declarations, functions and world items. A `since` annotation
requires a versioned package and cannot name a version newer than that package.
Comparison follows the pinned resolver's complete version ordering, including build
metadata. Deprecation requires `since` or `unstable`; its version does not remove an
item or impose a package-version bound. Duplicate annotations and conflicting
`since`/`unstable` annotations are errors. Anonymous composites inherit their
declaration's stability, or the first directly referenced type with known stability.
Named aliases retain their own annotations and can stop that inheritance. Anonymous
types with the same shape and referenced type identities share the first allocation's
stability within a package. Declared types allocate before function signatures;
dependencies allocate before their users, with source order breaking ties.

`@external-id("...")` retains an opaque UTF-8 string on `ResolvedType` and
`ResolvedFunction`. Interface imports and exports retain it on `WorldItem`;
function and type world items keep their IDs on the referenced declaration.
Renamed uses retain their own ID. Interface/world declarations and includes ignore
this annotation, matching the pinned resolver. Duplicate IDs on retained declaration
roles are errors. Empty strings and escaped Unicode remain exact, and equal IDs do
not merge resource identities. Binary and WAT `external-id` name attributes follow
the same rules; package wrapper exports have no corresponding declaration.

When inferred and supplied interfaces overlap, external IDs come from the first
selected caller input, including an absent ID. Named type bodies, function signatures and function stability also come from
that input. Named type and interface stability upgrades from unknown to known;
conflicting known annotations are errors. Anonymous type graphs retain the selected
input's metadata and nominal references, including distinct source and binary
allocations with equal shapes. Selection precedes this merge, so retained binary
types are not selected again using supplied source metadata. Named declarations
and functions keep supplied source locations; copied anonymous
types retain their originating input's location. Public graph node IDs remain
source-oriented and do not reproduce the reference arena's unused allocations.
The merged graph is checked again for borrowed results, resource targets and value positions,
constructor success types, method receivers and setter result shapes. Invalid
resource/constructor/setter remapping is rejected even where the pinned merge
currently accepts such named-type conflicts. Full model conformance remains tracked separately.

`SemanticFeatures::default()` enables no unstable features. Pass
`semantic_features={ enabled: ["preview"], all_enabled: false, }` to `verify`,
`verify_ast` or `resolve` to enable named features, or use `SemanticFeatures::all()`.
Names match exactly. `@unstable(feature=preview)` declarations disappear when disabled.
An active declaration cannot refer to an excluded declaration or lose its named
type owner. Name resolution, cycles and declaration contracts still validate before
selection. Borrowed function results validate only for active functions. Interface
accessors pair before selection; world accessors pair after selection and includes.
The immutable original syntax always retains disabled declarations.

Foreign packages must exist even for disabled paths. Their member and type lookups
can be deferred by gates. At the reference pin, a foreign member combines its path
gates, while a foreign imported type retains its first selector's annotation.
Foreign interface/world kind checks occur before selection. Source order can
therefore affect which foreign gates and anonymous type annotations take precedence.

Encoded package loading has a strict v1/v2 type-wrapper profile. Use
`decode_package` for bytes or `decode_wat_package` for component WAT, then pass
`PackageInput::Encoded` to `resolve_packages`. Source packages use
`PackageInput::Source`. These operations perform no I/O. Supported encoded
interfaces contain exported named scalar/composite types, records, flags, enums,
variants, resources, constructors, ordinary/static/async methods, getters/setters
and freestanding functions. Worlds contain function or
instance imports/exports and named type imports. Qualified instances bind to an
already declared local interface or infer a foreign interface by its qualified
package name and version. An instance with an ordinary name becomes an inline
interface unless an `implements` attribute binds that label to a named interface.
Multiple labels preserve the same interface and resource identities. Component type indices include aliases introduced by type exports.

V1 uses its outer package identity, including empty packages and multiple members.
V2 derives member names from qualified inner exports. Wrapper instance imports,
instance-export type aliases and lexical outer aliases preserve named alias edges
and nominal resource identities. World aliases to interface types lower to WIT use
declarations, including implicit interface dependencies. Direct imported type
references in function signatures bind to the original interface declarations
without adding use aliases or world type imports. Their implicit interface
imports and resource identities survive supplied dependency merging and feature
selection. A local projection may contain a subset
of its interface. The authoritative local member determines its identity and type;
the pinned loader checks aggregate structure but ignores primitive, flag, enum,
handle and resource leaf differences and existing function signatures. Missing projected members are errors.

Foreign projections union their referenced type and function members across
wrappers and worlds. Transitive foreign uses preserve nominal resource and named
alias identities. Reusing an instance type freshens its declared resources while
retaining outer aliases. Inferred package blocks remain private; they do not
appear in `sources()`. Supplied source documents and their original node origins
remain intact when inferred members are added to the closure.

Overlapping inferred and supplied interfaces union their members. At the pinned
`Resolve::merge` API, shared named types map by name without definition comparison;
shared functions must agree on kind, parameter names/count, primitive types and
result presence. Named/composite type IDs are not structurally compared during
this merge. This differs from aggregate checks within one encoded input.

Worlds support owned resources, resource aliases, imported constructors/methods,
static functions and accessors. Resource metadata retains world type/function
stability under the binary selection rules.
The profile rejects forward local interface inference, resource functions attached
to resource aliases, anonymous structural types, name attributes other than `implements` and `external-id`, and export ascriptions.
The tested forward-local projections panic in the pinned decoder; product
regressions require a diagnostic.
Overlapping inferred packages validate each encoded input against its own inferred
closure, and source inputs against their reachable dependencies before inferred
additions to source-owned packages. Selection then precedes member merging. A
disabled declaration cannot hide an invalid source reference or win a name
collision. Original source documents and binary provenance are retained.
Independent validation and selection share a one-million-node budget across
input views and dependency scans.
Private scope/type graphs use explicit stacks and a one-million-step work budget.
Scope scans, alias links, projection matching and per-interface type-slot tables
consume that budget. Large collections of otherwise unrelated interfaces or worlds can reach
this limit. Inferred closure merging has a separate one-million-step budget for
arena size, member scans and signature comparisons. Public models and provenance
retain the same immutable contracts.
`package-docs` metadata versions 0 and 1 retain release/feature/deprecation
annotations and validate docs, member names and item kinds. Imported alias types
in interfaces and worlds retain their own metadata, including renamed uses. Unknown schema fields,
duplicate struct fields and missing targets are errors. Dictionary duplicates keep
the last value after every value has passed schema validation. Metadata structs
also accept the reference loader's ordered JSON array forms. Dictionaries remain
objects, and function metadata remains a string, null or object. Original docs remain
available in `binaries()`; the semantic model exposes stability rather than a docs API.

Binary metadata follows the pinned loader's own selection rules. Types,
interfaces, worlds and world items stay present regardless of their unstable
annotations. Unstable interface functions, including inline interface functions,
are selected by `semantic_features`; world functions remain present. Binary
stable annotations can exceed the package version, and binary feature strings
need not be source identifiers. Anonymous binary types and implicit receivers
retain unknown stability. Source annotations keep the source rules above.
Metadata parsing uses explicit byte/object frames, including ignored extension
values and deeply nested JSON; it never turns an ignored number into a float.

WAT supports root `@custom` and `@producers` annotations, quoted identifiers,
byte/Unicode string escapes and the component `binary` form. Custom payload bytes
are preserved, including non-UTF-8 data; custom names and producer strings require
UTF-8. Package metadata applies identically to WAT and binary inputs. Type syntax
uses a [retained portable frontend](../component_text/README.md) from
`Milky2018/wasm_component@0.16.0`, patched for map syntax and signed value-type
indices. Physical WAT
nesting is limited to 256 before that frontend runs. Expanded value types have a one-million-step decoding limit.
Binary resource signatures retain their encoded nominal identities and implicit
receivers. Constructors return an owned handle or a result containing that handle;
aliases are transparent to the binary constructor and setter result contracts.
Source declarations retain their own alias restrictions. Encoded setters require
a preceding getter with an exactly matching property type; a getter's result
success type is its property type. Source setter ordering and type rules remain
those described above.

The component validator is retained from `Milky2018/wasm_component@0.16.0`
with a [licensed compatibility patch](../binary/validation/README.md) for modern
accessor names and instance resource/signature validation.
These limitations remain under [issue #5](https://github.com/moonrockz/wasm-devkit/issues/5).
Other unsupported source attributes still fail under `WIT-S003`.
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

## Encoded dependencies

```mbt check
///|
test "resolve an encoded dependency without publishing generated source" {
  let wat = "(component (type (component (type (instance (type u32) (export \"id\" (type (eq 0))))) (export \"example:dep/api\" (instance (type 0))))) (export \"api\" (type 0)))"
  let encoded = @verifier.decode_wat_package(wat, source_id="dep.wat").unwrap()
  let text = "package example:app;interface api{use example:dep/api.{id};}"
  let source = @verifier.SourcePackage::{
    documents: [
      @verifier.Document::from_parse("app.wit", text, @parser.parse(text)),
    ],
  }
  let model = @verifier.resolve_packages(Source(source), dependencies=[
    Encoded(encoded),
  ]).unwrap()
  assert_eq(model.sources().length(), 1)
  assert_eq(model.sources()[0].id, "app.wit")
  assert_eq(model.binaries()[0].source(), "dep.wat")
  assert_true(
    model
    .types()
    .any(ty => {
      ty.name == Some("id") && ty.location.position == BinaryOffset(None)
    }),
  )
}
```

`Resolution::sources()` contains only caller-supplied original text and ASTs.
`binaries()` retains immutable encoded inputs; for WAT, `bytes()` returns compiled
bytes. The decoder's private lowering is never returned as original syntax.
Encoded origins have `node=None` and byte-based locations with no invented span.
WAT errors never report offsets in compiled bytes as positions in the WAT text.
`WIT-B001` reports malformed binary framing, `WIT-B002` unsupported forms,
`WIT-B003` component validation errors, and `WIT-B004` invalid WIT package shape.
Semantic errors discovered during closure resolution retain their `WIT-S` codes.

## Contracts

`verify` rejects syntax diagnostics before checking semantics. `verify_ast` accepts
caller-built ASTs and validates arena structure, source bounds and semantic field roles
before using them. Neither operation formats or reparses the supplied AST.

`Verified` has a private constructor. Its AST, bindings and source context are immutable.
`identity()` exposes the package name. Binding identities use the source, lexical
scope and arena node. `types()` exposes a fully resolved immutable type graph;
each type edge names an entry's closure-local `id`, with source-qualified provenance.
The graph includes aliases and anonymous composites without reparsing source. Diagnostics use
source-qualified locations, with related locations for earlier declarations.
`Location.position` distinguishes `SourceSpan`, measured in UTF-16 code units,
from `BinaryOffset`, measured in bytes. A binary offset can be unavailable.
`Location::span()` returns a span only for text locations. Diagnostics sort by
source identity, position kind, offsets and code. Resolution uses no mutable global state.
`Diagnostic::render()` renders source identities and offsets without confusing dependency
locations with the root source. The CLI adds 1-based UTF-16 line/column coordinates.
Binary labels use `[byte N]` or `[binary]` and never pass through a text line table.

```mbt check
///|
test "binary diagnostics retain their position units" {
  let diagnostic = @verifier.Diagnostic::from_binary({
    source: "dep.wasm",
    offset: Some(17),
    code: "WIT-B001",
    message: "truncated encoding",
  })
  assert_eq(diagnostic.primary.location.position, BinaryOffset(Some(17)))
  assert_eq(diagnostic.primary.location.span(), None)
  assert_true(diagnostic.render().contains("dep.wasm:[byte 17]"))
}
```

Stable code families are `WIT-S001` for invalid ASTs, `WIT-S002` for missing package identity, `WIT-S003` for unsupported
semantics, `WIT-S004` for duplicate names and `WIT-S005` for unresolved or
incorrectly typed references. `WIT-S006` reports type cycles, `WIT-S007` reports invalid aggregate/composite, handle and function contracts, and `WIT-S008` distinguishes a non-type declaration used as a type.
`WIT-S013` reports invalid stability annotations and unreleased or unversioned
`since` gates, with the original annotation and package locations. It also reports
active references to excluded declarations, with their source locations.

```mbt check
///|
test "inspect semantic release annotations" {
  let source = "package example:app@2.0.0;interface api{@since(version=1.0.0)@deprecated(version=2.0.0)run:func();}"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  assert_eq(model.functions()[0].stability, Stable("1.0.0", Some("2.0.0")))
  let unversioned = source.replace(old="@2.0.0;", new=";")
  assert_true(
    @verifier.verify(@parser.parse(unversioned), source=unversioned) is Err(_),
  )
}
```

```mbt check
///|
test "select semantic features independently of grammar" {
  let source = "package example:app;interface api{@unstable(feature=preview)resource r;open:func()->r;}"
  let parsed = @parser.parse(source)
  assert_true(@verifier.verify(parsed, source~) is Err(_))
  let profile : @verifier.SemanticFeatures = {
    enabled: ["preview"],
    all_enabled: false,
  }
  let model = @verifier.verify(parsed, source~, semantic_features=profile).unwrap()
  assert_eq(model.functions()[0].name, "open")
  assert_eq(model.ast(), parsed.ast)
}
```

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

## Resource handles

`Own(resource)` and `Borrow(resource)` refer to the canonical nominal resource ID.
Plain typedef aliases preserve their resource identity and may name handle targets.
In value positions, a resource or an alias to a resource means an owned handle.
An alias to an owned/borrowed handle cannot itself be a handle target.
Borrowed handles may occur inside parameters and unused type declarations. A function
result cannot contain a borrowed handle, even through aliases, aggregates, futures
or streams. Such a result reports `WIT-S007` and labels the borrowed type's source.

```mbt check
///|
test "inspect nominal owned and borrowed handles" {
  let source = "package example:app;interface api{resource file;type alias=file;read:func(input:borrow<alias>)->file;}"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  let types = model.types()
  let resource = types.filter(t => t.kind is Resource)[0].id
  let function = model.functions()[0]
  assert_true(
    types.any(t => t.id == function.params[0].ty && t.kind == Borrow(resource)),
  )
  assert_true(
    types.any(t => Some(t.id) == function.result && t.kind == Own(resource)),
  )
}
```

Handle resolution, borrow analysis and include copying use explicit work stacks.
An included world or anonymous interface receives fresh local resource IDs, and
its handles point to those fresh IDs. Handles to resources from named interfaces
retain their original nominal target.

`ResolvedFunction::kind` distinguishes freestanding functions, methods, static
functions and constructors. Resource-associated kinds carry their nominal resource
ID. `asynchronous` records the signature's async marker. Method parameters include
the leading `self: borrow<R>` receiver; an explicit parameter canonically named
`self` conflicts with that receiver. Static functions have no implicit receiver.
Mangled names follow the reference's `[method]R.name`, `[static]R.name` and
`[constructor]R` forms. Strong-name checks drop method/static annotations and
collapse `R.R` to the resource name, so a resource cannot define a method with
its own canonical name.

Constructors implicitly return `own<R>`. A declared return must directly name a
result type whose success type directly names `R`, including `own<R>`. Aliases
of `R` cannot replace that direct success type. One typedef whose definition is
a result is allowed as the return; further typedef aliases are not. Borrowed
handles in the error type still violate the function-result rule.

```mbt check
///|
test "verify a resource API with fallible construction and an async method" {
  let source = "package example:app;interface files{resource file{constructor(path:string)->result<file,string>;read:async func()->list<u8>;open:static func(path:string)->file;}}"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  let resource = model.types().filter(t => t.kind is Resource)[0].id
  let functions = model.interfaces()[0].functions
  assert_eq(functions[0].kind, Constructor(resource))
  assert_eq(functions[1].kind, Method(resource))
  assert_eq(functions[1].params[0].name, "self")
  assert_true(functions[1].asynchronous)
  assert_eq(functions[2].kind, Static(resource))
}
```

World resource definitions implicitly import their associated functions. Includes
freshen the resource, constructor/method kinds and receiver/result handles together.
An include-with resource rename also updates its associated mangled function names.

## Getters and setters

`Features::reference()` admits the accessor grammar. `ResolvedFunction.flavor`
distinguishes `Plain`, `Getter` and `Setter` independently of the function's
resource kind. Getters have no explicit parameters and require a result. Setters
have one explicit parameter and may return nothing or a direct result type with
no success type. A typedef defined as that result type is allowed; further aliases
are not. Accessors cannot be asynchronous. Method accessors retain their implicit
borrowed receiver, and function results still cannot contain borrowed handles.

Each setter requires the exact corresponding getter name in the same interface
or world import/export scope. Case, hyphens and method/static kind must match.
World pairing is checked after include expansion, so an included getter can
satisfy a local setter. Getter and setter value types may differ at the pinned
reference revision. Include-with property renames update both mangled names;
resource renames preserve the method/static and accessor annotations.

```mbt check
///|
test "verify and inspect an included getter and setter pair" {
  let source = "package example:app;world base{import size:get()->u64;}world app{import length:set(value:u64);include base with{size as length}}"
  let parsed = @parser.parse(source, features=@parser.Features::reference())
  let model = @verifier.verify(parsed, source~).unwrap()
  let world = model.select_world(name=Some("app")).unwrap()
  assert_eq(world.imports[0].name, "[get]length")
  assert_eq(world.imports[1].name, "[set]length")
  assert_true(
    model.functions().any(f => f.name == "[set]length" && f.flavor is Setter),
  )
}
```

Interface function lists and world item lists move setters that precede their
getter to follow it, matching the reference ordering. Setters already after their
getter keep their position relative to unrelated declarations.

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
original arena index. The index is optional; source documents retain `Some(index)`.
Encoded providers can have no original syntax node or textual span. Successful identities and diagnostics are independent of
source/dependency discovery order. Explicit work stacks handle type, interface and
package cycles; related labels explain dependency chains, including syntax failures
in a dependency whose package header can still be recovered.

`WIT-S009` reports an unresolved package identity. `WIT-S011` reports conflicting
package metadata or duplicate supplied identities. Missing interface/type selectors
use `WIT-S005`; wrong declaration kinds use `WIT-S008`.

## Package blocks in one source

```mbt check
///|
test "resolve a dependency package block without copying its source" {
  let source = "package example:app;world app{import example:dep/api;}package example:dep{interface api{resource item;load:func()->item;}}"
  let document = @verifier.Document::from_parse(
    "bundle.wit",
    source,
    @parser.parse(source),
  )
  let model = @verifier.resolve({ documents: [document], }).unwrap()
  assert_eq(model.root().key(), "example:app")
  assert_eq(model.identities().length(), 2)
  assert_eq(model.sources().length(), 1)
  assert_eq(model.sources()[0].ast, document.ast)
  assert_eq(model.select_world().unwrap().imports[0].name, "example:dep/api")
}
```

Qualified paths may refer forward to a package block or follow transitive imports
between blocks. A block may also remain unreferenced; verification still checks
its declarations. Diagnostic dependency chains distinguish package regions in the
same source, preserving their original UTF-16 locations.

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

Encoded instance names accept canonical `version-suffix` attributes. WIT expands
the suffix before binding package/interface identities, including `implements`
names and supplied source dependencies. Resource identities, metadata and caller
provenance survive this expansion. The shared WAC binary loader retains raw IDs
to match its older pinned Package API.

## Upstream semantic corpus

The verifier tests retain all 261 test groups from wit-parser at wasm-tools
1.262.0, commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with semantic feature
`active` enabled. All 78 accepted groups compare resolved package, interface,
world, function and type contracts, including stability metadata and nominal
resource identity, on all four targets. The original directory layouts and
encoded dependencies are retained. Encoding those inputs adds 67 full encoded
model comparisons and 11 explicit empty-root package rejections. Both corpora
check deterministic repeated results and input ordering; formatting preserves
accepted source models. The CLI gate checks 260 matching groups.
The remaining group exceeds upstream's source parser depth limit and is accepted
under this library's documented stack-safe nesting extension. See the
[corpus manifest and normalization contract](../../../../tests/semantic/wit-upstream-ui/README.md).

Empty `use interface.{}` declarations resolve their target and participate in
cycle checks without importing its types or adding a runtime world import.
Package headers in multiple files may agree, but only one may carry documentation.
Implicit imports inherit the requesting item's stability. Including a world
merges named interface stability; stable version annotations are cleared when
the included world comes from another package. Conflicting known annotations
within a package produce `WIT-S013`.
