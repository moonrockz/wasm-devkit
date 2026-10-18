# WIT parser

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wit@0.1.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/parser",
  "moonrockz/wit/span",
  "moonrockz/wit/diagnostic",
} for "test"
```

### Parse a complete WIT document

```mbt check
///|
test "README: Parse a complete WIT document" {
  let source = "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  assert_true(parsed.diagnostics.is_empty())
  assert_true(parsed.ast.validate())
  assert_true(parsed.cst.validate())
  assert_eq(parsed.cst.to_source(), source)
  assert_eq(parsed.ast.nodes.length(), parsed.cst.nodes.length())
}
```

### Inspect diagnostics while retaining invalid input

```mbt check
///|
test "README: Inspect diagnostics while retaining invalid input" {
  let source = "interface broken { type missing = ; } interface later {}"
  let parsed = @parser.parse(source)
  assert_false(parsed.is_valid())
  assert_false(parsed.diagnostics.is_empty())
  assert_eq(parsed.cst.to_source(), source)
  assert_true(parsed.ast.validate() && parsed.cst.validate())
  assert_true(
    parsed.ast.nodes.any(node => node.data is Interface(name="later", ..)),
  )
}
```

### Enable only the grammar extension your source needs

```mbt check
///|
test "README: Enable only the grammar extension your source needs" {
  let source = "interface api { type bytes = list<u8, 16>; }"
  assert_false(@parser.parse(source).is_valid())
  let features = { ..@parser.Features::default(), fixed_lists: true, }
  let parsed = @parser.parse(source, features~)
  assert_true(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
}
```

### Read a corpus with all supported extensions

```mbt check
///|
test "README: Read a corpus with all supported extensions" {
  let source = "interface api { type bytes = list<u8, 16>; }"
  let parsed = @parser.parse(source, features=@parser.Features::all())
  assert_true(parsed.is_valid())
  // The feature profile is a parsing choice, not a semantic resolver.
  assert_true(parsed.ast.validate())
}
```

### Render diagnostics as editor line and column values

```mbt check
///|
test "README: Render diagnostics as editor line and column values" {
  let source = "interface broken { type missing = ; }"
  let parsed = @parser.parse(source)
  let index = @span.Source::new(source)
  let errors : ReadOnlyArray[@diagnostic.Diagnostic] = parsed.diagnostics
  assert_false(errors.is_empty())
  let locations = errors.map(diagnostic => {
    let position = index.position(diagnostic.primary.span.start).unwrap()
    "example.wit:\{position.line + 1}:\{position.column + 1}: " +
    diagnostic.code
  })
  assert_true(locations[0].has_prefix("example.wit:1:"))
}
```

## API contracts

`parse(text, features=Features::default())` returns `Parse` with an immutable typed AST,
a lossless CST and structured diagnostics. `Parse::is_valid()` means there are no error
diagnostics. Scanner errors are retained. Parsing never raises and performs no I/O.

The parser uses an explicit stack of grammar tasks and flat postorder node arenas.
Input-controlled type and package nesting does not recurse through MoonBit calls.
AST and CST node indices correspond. Read [AST node fields](../ast/nodes.md) for semantic
roles and the AST/CST package documentation for source spans and token ranges.

## Grammar profile

The baseline is [Component Model WIT.md](https://github.com/WebAssembly/component-model/blob/0220da84209397d9067c19cac83dae969aa85a7b/design/mvp/WIT.md)
at revision `0220da84209397d9067c19cac83dae969aa85a7b`.

Implemented syntax includes optional root package declarations, nested package bodies,
interfaces, worlds, resources, forward resources, constructors and fallible constructor
results, ordinary/static/async functions, named parameters, record/flags/enum/variant
members, aliases, paths, imports, exports, inline interfaces, use selectors and renaming,
world includes and include renaming, and since/unstable/deprecated attributes.

Types include scalar primitives, named types, lists, tuples, options, all result forms,
explicit own/borrow handles, futures, streams, error-context primitives and maps.
Explicit `own<name>` handles,
empty records/flags/tuples and trailing commas follow the reference parser's accepted
syntax. The pinned reference is wasm-tools commit
`dcac6c30353afa6e851ef0bbd4ca14d8f5493731`. Empty variants, enums, use selectors and
include rename lists are also retained as syntax. Semantic versions use SemVer 2.0
syntax without bounded integer conversion. Fixed-list integer spellings are preserved
as strings, including zero and leading zeros; their numeric domain is validated later.

`Features::default()` disables nested namespaces/package paths, fixed-length lists,
external IDs/named interface imports, and accessors. Set individual fields or use
`Features::all()` to enable them. Disabled syntax is still parsed and retained, with
`WIT-P005` errors. Ordinary async functions, futures, streams and maps are enabled.
Named interface imports use whitespace around `:` to distinguish a plain-name alias
from a contiguous package path, following the pinned specification's disambiguation.

Semantic resolution is separate. The parser does not load packages, resolve references,
check duplicate names/type cycles, enforce compatible feature versions, check aggregate
cardinality or map-key validity, or validate resource method/getter/setter signatures.
Those checks require later semantic tooling. An AST can
therefore describe syntactically valid code with semantic errors.

## Recovery and diagnostics

An expectation can report a missing token without consuming the next declaration. Invalid
items skip to a semicolon, balanced body or declaration boundary and retain their source.
Delimited lists recover missing commas and closers. Missing types produce `Error` children.
All diagnostics use UTF-16 source spans and are sorted by source start, then code.

| Code | Meaning |
|------|---------|
| `WIT-P001` | Missing token, identifier, member or type |
| `WIT-P002` | Invalid or missing semantic version |
| `WIT-P003` | Invalid scope, path or type grammar constraint |
| `WIT-P004` | Unknown or malformed attribute |
| `WIT-P005` | Disabled proposal syntax |
| `WIT-P006` | Unexpected item, skipped during recovery |

Invalid input always retains its exact source in the CST. Consumers must inspect diagnostics;
AST recovery nodes and missing fields are not a successful parse of the malformed syntax.

## Validation

[Fixture provenance and skips](fixtures/README.md) account for all 79 WIT fenced blocks in
the pinned specification. Sixty-eight examples run on every target, including invalid syntax.
Snippets are wrapped in their grammatical contexts; omitted pseudo-syntax is recorded explicitly.
The original Apache-2.0 license is retained alongside the manifest.

Tests exercise every documented node kind, typed fields, proposal switches, scope and SemVer
errors, recovery, collection ownership, exact CST reconstruction and structural invariants.
Per target, seeded properties cover 600 arbitrary Unicode sources, 1,000 malformed grammar
fragment sequences and 300 generated valid nested types. Stress cases include 20,000 nested
list types, 10,000 unclosed option types and 2,000 nested package bodies on wasm, wasm-gc,
js and native.

The [wasm-tools corpus](fixtures/wasm-tools/README.md) embeds all 321 upstream WIT files
without source adaptations or skips. Expectations come from its syntax-only parser, rather
than package resolution. All source hashes, classifications and two deliberate nesting-limit
differences are recorded in the manifest. Every case checks acceptance, structural invariants
and exact reconstruction on all four targets.

The implementation preserves a leading BOM as trivia. Differences outside the corpus are
explicit: bare CR is whitespace as in the WIT specification; malformed strings recover at
newlines; semantic version and fixed-list integer spellings are not restricted to the
reference's machine-integer widths. Proposal paths, optional semicolons after include renames
and strict Core WebAssembly Unicode-escape separators follow the documented WIT profile.
