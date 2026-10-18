# WAC parser

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.1.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/parser",
  "moonrockz/wac/span",
  "moonrockz/wac/diagnostic",
} for "test"
```

### Parse a complete WAC document

```mbt check
///|
test "README: Parse a complete WAC document" {
  let source = "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }"
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
  let source = "package demo:app; interface broken { type missing = ; } interface later {}"
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
  let source = "package demo:app; type callback = func() -> (value: u8);"
  assert_false(@parser.parse(source).is_valid())
  let features : @parser.Features = { named_results: true, }
  let parsed = @parser.parse(source, features~)
  assert_true(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
}
```

### Read a corpus with all supported extensions

```mbt check
///|
test "README: Read a corpus with all supported extensions" {
  let source = "package demo:app; type callback = func() -> (value: u8);"
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
  let source = "package demo:app; interface broken { type missing = ; }"
  let parsed = @parser.parse(source)
  let index = @span.Source::new(source)
  let errors : ReadOnlyArray[@diagnostic.Diagnostic] = parsed.diagnostics
  assert_false(errors.is_empty())
  let locations = errors.map(diagnostic => {
    let position = index.position(diagnostic.primary.span.start).unwrap()
    "example.wac:\{position.line + 1}:\{position.column + 1}: " +
    diagnostic.code
  })
  assert_true(locations[0].has_prefix("example.wac:1:"))
}
```

## API contracts

`parse(text, features=Features::default())` returns immutable AST/CST arenas and structured
diagnostics. `Parse::is_valid()` means no error diagnostics. Parsing is pure, performs no
I/O and returns errors as data. Its grammar continuations use explicit heap tasks, including
type syntax, grouped expressions and nested instantiations. Recovery keeps exact source in
the CST and continues at declaration boundaries. Invalid input never becomes a successful stub.

The baseline is [bytecodealliance/wac at the pinned revision](fixtures/README.md). Tests embed
all 163 upstream `.wac` files unchanged and compare syntax acceptance with its public Rust
`Document::parse`. The manifest records hashes and classifications. No files are skipped.
The syntax layer accepts unresolved names, duplicate definitions and semantically invalid
compositions, as the reference syntax parser does.

Supported syntax includes the required initial package directive, optional targets, WAC
interface/world/type definitions, scoped use/include, imports, let bindings, instantiation
arguments, grouped expressions, access chains and exports. Async functions, future, stream
and error-context types are included. Atomic package paths may have multiple namespace and
path components. `borrow` takes a named resource. Tuples and record/flags/enum/variant bodies
require members. Empty resource/interface/world bodies are valid. Constructors have parameters
and no results. Interface functions may name a function type; resource methods use signatures.

WAC differs from WIT in its atomic package tokens, raw string names, supported type forms,
placement of declarations and semicolons after inline interface externs and include clauses.
It has no `own`, `map`, fixed-length list, attributes, accessor signatures or nested package
blocks. See the scanner README for identifier, Unicode and string rules.

`Features.named_results`, disabled by default, enables the named-results syntax described
in upstream `LANGUAGE.md` but rejected by its pinned parser. `Features::all()` enables it.
Disabled syntax remains represented with `WAC-P005`. The reference's empty `func() ->;`
result spelling is accepted and represented as an absent result. Result placeholders `_`
represent absent slots, including `result<_>` and `result<_,_>`.

| Code | Meaning |
|------|---------|
| `WAC-P001` | Expected grammar token/member/type/expression |
| `WAC-P002` | Invalid semantic version |
| `WAC-P003` | Invalid grammar scope, package path or empty aggregate |
| `WAC-P005` | Disabled named-results extension |
| `WAC-P006` | Skipped malformed declaration |

Diagnostic and node spans count UTF-16 code units. The root covers all input; concrete
node ranges include internal/following trivia. Acceptance tests, arbitrary-input and
malformed-fragment properties, node-kind coverage, recovery checks and 20,000-level stress
tests run on wasm, wasm-gc, js and native.
