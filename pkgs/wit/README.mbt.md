# moonrockz/wit

WIT language tooling for MoonBit.

Source positions, structured diagnostics, lossless lexical analysis, typed immutable ASTs/CSTs,
recovering syntax parsing, immutable traversal, rewrites, canonical printing and comment-preserving
formatting are implemented for the documented grammar profile.
Install with `moon add moonrockz/wit@0.2.0`.

`@scanner.scan(source)` returns immutable tokens and diagnostics. `Scan::to_source()`
reconstructs the exact input. Lexical success does not imply syntactic validity.
See the scanner package for the lexical profile and diagnostic codes.

`@parser.parse(source)` returns a typed AST arena, a lossless CST arena and diagnostics.
`Parse::is_valid()` checks for errors. Parsing performs no I/O, never raises, and uses
explicit grammar continuations rather than recursive descent. See the parser package for
supported syntax, proposal switches and remaining compatibility validation.

## Scenario recipes

Install the module, put the following imports in your package's `moon.pkg`, and copy a recipe
into `example_test.mbt` beside it. Run `moon test --target wasm` to execute the assertions. For application
functions, use the same package imports without `for "test"`. No example requires a package
registry, filesystem or resolver at parse time.

The import group covers all recipes on this page. Keep only the packages your code uses.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/parser",
  "moonrockz/wit/scanner",
  "moonrockz/wit/span",
  "moonrockz/wit/diagnostic",
  "moonrockz/wit/ast",
  "moonrockz/wit/cst",
  "moonrockz/wit/traversal",
  "moonrockz/wit/printer",
  "moonrockz/wit/formatter",
  "moonrockz/wit/verifier",
} for "test"
```

### Distinguish syntax, structure and resolved semantics

`Parse::is_valid()` reports syntax diagnostics. AST/CST `validate()` checks tree
structure and spans. `verifier.verify()` resolves names and checks language
contracts, returning an immutable model or diagnostics. The pure verifier does
no I/O; callers supply dependency packages explicitly.

```mbt check
test "Guide: Syntax validity does not resolve WIT names" {
  let source = "package example:app; interface api { type broken = missing; }"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  assert_true(parsed.ast.validate() && parsed.cst.validate())
  assert_true(@verifier.verify(parsed, source~) is Err(_))
}
```

See the [verifier recipes](src/verifier/README.mbt.md) for resolved models,
dependencies, nominal resources and the pinned semantic profile. Complete
[CLI bundles](../../examples/verification/README.md) include their local inputs.

### Parse a service interface

Use a WIT interface as input to an editor, API indexer or generator.

```mbt check
test "Guide: Parse a WIT document" {
  let source = "package example:greeter; interface greeter { hello: func(name: string) -> string; }"
  let scanned = @scanner.scan(source)
  assert_true(scanned.diagnostics.is_empty())
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  let syntax : @ast.Tree = parsed.ast
  let concrete : @cst.Tree = parsed.cst
  assert_true(syntax.validate() && concrete.validate())
  assert_eq(concrete.to_source(), source)
  let canonical = @printer.print(syntax).unwrap()
  assert_true(syntax.equivalent(@parser.parse(canonical).ast))
}
```

### Inspect a resource-based API and its world

A file API combines shared record data, a resource constructor and method, an owned
resource result and a world export. Read typed fields to find the declarations your tool needs.

```mbt check
test "Guide: Inspect a resource-based API and its world" {
  let source =
    #|package example:files;
    #|interface files {
    #|  record metadata { size: u64 }
    #|  resource file {
    #|    constructor(path: string);
    #|    stat: func() -> metadata;
    #|  }
    #|  open: func(path: string) -> result<own<file>, string>;
    #|}
    #|world app { export files; }
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
  let resources = parsed.ast.nodes.filter(node => node.data.kind() == Resource)
  assert_eq(resources.length(), 1)
  guard resources[0].data is Resource(name~, methods~, has_body~, ..) else {
    fail("expected typed resource data")
  }
  assert_eq(name, "file")
  assert_true(has_body)
  assert_eq(methods.length(), 2)
  assert_true(parsed.ast.nodes.any(node => node.data.kind() == World))
  assert_true(parsed.ast.nodes.any(node => node.data.kind() == Record))
}
```

### Report diagnostics while the user is typing

Keep the CST for exact editor text, even when `is_valid()` is false. Codes are stable;
messages can change. The source index reports zero-based UTF-16 positions; add one when
rendering human-readable line and column values.

```mbt check
test "Guide: Render diagnostics as editor line and column values" {
  let source = "interface broken { type missing = ; }"
  let parsed = @parser.parse(source)
  let index = @span.Source::new(source)
  let errors : ReadOnlyArray[@diagnostic.Diagnostic] = parsed.diagnostics
  assert_false(errors.is_empty())
  let locations = errors.map(diagnostic => {
    let position = index.position(diagnostic.primary.span.start).unwrap()
    "example.wit:\{position.line + 1}:\{position.column + 1}: " + diagnostic.code
  })
  assert_true(locations[0].has_prefix("example.wit:1:"))
  assert_false(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
}
```

### Read named fields for an API index

```mbt check
test "Guide: Index WIT declarations" {
  let parsed = @parser.parse("interface api { read: func() -> u8; write: func(value: u8); }")
  let names = []
  let report = @traversal.walk(Ast(parsed.ast), event => {
    if event.phase == Enter && event.view.kind == Function {
      if parsed.ast.nodes[event.view.index].data is Function(name~, ..) {
        names.push(name)
      }
      // Names are enough for this index; skip signature descendants.
      Prune
    } else { Continue }
  }).unwrap()
  assert_eq(names, ["read", "write"])
  assert_false(report.stopped)
}
```

### Refactor a type and print a new document

Use AST rewrites when the change concerns typed structure. The callback receives candidate
children with output-arena IDs, so retain those IDs when replacing a parent. `Keep` retains
rewritten children. Printing discards trivia; choose CST edits when comments must survive.

```mbt check
test "Guide: Change a type without mutating the parsed tree" {
  let parsed = @parser.parse("interface api { type byte = u8; }")
  let changed = @traversal.rewrite(parsed.ast, (_view, node) => {
    match node.data {
      PrimitiveType(name="u8") => Replace(PrimitiveType(name="u64"))
      _ => Keep
    }
  }).unwrap()
  assert_true(changed.tree.validate())
  assert_true(parsed.ast.nodes.any(node => node.data == PrimitiveType(name="u8")))
  assert_false(changed.tree.nodes.any(node => node.data == PrimitiveType(name="u8")))
  assert_true(changed.tree.nodes.any(node => node.data == PrimitiveType(name="u64")))
  let printed = @printer.print(changed.tree).unwrap()
  assert_true(printed.contains("type byte = u64;"))
  assert_true(changed.tree.equivalent(@parser.parse(printed).ast))
}
```

### Edit one token and retain comments

Node spans may include following trivia. For a precise rename or type replacement, use
the matching token span from the same parse. Edits must be ordered and nonoverlapping.

```mbt check
test "Guide: Edit a token and format the result" {
  let source = "// keep this comment\ninterface api { type byte = u8; }"
  let parsed = @parser.parse(source)
  let token = parsed.cst.tokens.iter().find_first(token => token.text == "u8").unwrap()
  let changed = @traversal.rewrite_cst(parsed.cst, [{ span: token.span, text: "u64" }]).unwrap()
  assert_true(changed.is_valid())
  assert_eq(changed.cst.to_source(), source.replace(old="u8", new="u64"))
  assert_eq(parsed.cst.to_source(), source)
  let formatted = @formatter.format_cst(changed.cst).unwrap()
  assert_true(formatted.has_prefix("// keep this comment\n"))
  assert_eq(@formatter.format(formatted), Ok(formatted))
}
```

### Select a grammar profile

WIT proposals are independent switches. Enable the forms present in your source rather
than treating `Features::all()` as proof of semantic validity.

```mbt check
test "Guide: Enable only the grammar extension your source needs" {
  let source = "interface api { type bytes = list<u8, 16>; }"
  assert_false(@parser.parse(source).is_valid())
  let features = { ..@parser.Features::default(), fixed_lists: true }
  let parsed = @parser.parse(source, features~)
  assert_true(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
  let formatted = @formatter.format_cst(parsed.cst, features~).unwrap()
  assert_true(@parser.parse(formatted, features~).is_valid())
}
```

### Handle output errors without changing user input

The formatter returns no partial source for invalid syntax. Keep the original editor
buffer or file, show diagnostics, and retry after the syntax is corrected.

```mbt check
test "Guide: Keep invalid input unchanged and report formatting errors" {
  let source = "interface broken { type missing = ; } interface later {}"
  match @formatter.format(source) {
    Err(InvalidSyntax(diagnostics)) => assert_false(diagnostics.is_empty())
    _ => fail("expected syntax diagnostics")
  }
  assert_eq(@parser.parse(source).cst.to_source(), source)
  assert_eq(@formatter.format(source, indent_width=-1), Err(InvalidOptions))
}
```

### More recipes by task

| Task | Guide |
|------|-------|
| Editor offsets, Unicode and safe slices | [span recipes](src/span/README.mbt.md#recipes) |
| Diagnostic severity, recovery and related labels | [diagnostic recipes](src/diagnostic/README.mbt.md#recipes) |
| Highlighting, comments and malformed tokens | [scanner recipes](src/scanner/README.mbt.md#recipes) |
| Typed node fields, arenas and structural equality | [ast recipes](src/ast/README.mbt.md#recipes) |
| Exact source and concrete subtree ranges | [cst recipes](src/cst/README.mbt.md#recipes) |
| Recovery, feature profiles and source diagnostics | [parser recipes](src/parser/README.mbt.md#recipes) |
| Readers, prune/stop, cursors, folds, reductions and rewrites | [traversal recipes](src/traversal/README.mbt.md#recipes) |
| Canonical source and printer errors | [printer recipes](src/printer/README.mbt.md#recipes) |
| Comment retention, indentation and formatting errors | [formatter recipes](src/formatter/README.mbt.md#recipes) |

All `mbt check` blocks are executable tests. `mise run test:docs` also checks these
README recipes with exactly the imports shown, on wasm, wasm-gc, js and native.

## Scope

Package declarations, interfaces, worlds, types, functions, resources, use/include declarations and explicitly selected proposal-gated constructs.

The [verifier](src/verifier/README.mbt.md) resolves multi-file source and encoded
package closures, names, type contracts and world includes. Caller-supplied
providers and the CLI perform filesystem/registry operations outside the pure
verifier. The syntax parser performs no I/O. Binding generation is outside this module.

## Packages

| Package | Intended responsibility |
|---------|-------------------------|
| [span](src/span/README.mbt.md) | Implemented: source text, UTF-16 positions, checked slices and span containment |
| [diagnostic](src/diagnostic/README.mbt.md) | Implemented: codes, severity, immutable source labels and recovery details |
| [scanner](src/scanner/README.mbt.md) | Implemented: lossless tokens, comments, whitespace and lexical diagnostics |
| [ast](src/ast/README.mbt.md) | Implemented: typed immutable nodes, named child fields and structural validation |
| [cst](src/cst/README.mbt.md) | Implemented: lossless grammar hierarchy, token ranges and subtree reconstruction |
| [parser](src/parser/README.mbt.md) | Implemented: recovering grammar parser and explicit proposal switches |
| [traversal](src/traversal/README.mbt.md) | Implemented: AST/CST walks, folds, reductions, events, immutable cursors and rewrites |
| [printer](src/printer/README.mbt.md) | Implemented: stack-safe canonical AST emission with structural round-trip checks |
| [formatter](src/formatter/README.mbt.md) | Implemented: CST-aware layout preserving comment text, token order and meaning |
| [verifier](src/verifier/README.mbt.md) | Pure name/type/dependency resolution and immutable semantic models |

## Validation

The lexical layer has acceptance examples, 2,400 seeded property cases per target,
exact token/span reconstruction laws and a 30,000-level nested comment stress case.
Tests also exercise malformed UTF-16 and string escapes. All run on wasm, wasm-gc, js and native.

The parser adds 68 pinned specification examples and 321 upstream WIT files with a licensed fixture manifest,
1,900 seeded property cases, 20,000 nested types, 10,000 missing type closers and
2,000 nested packages per target. AST/CST validation checks postorder references,
unique parents, child order and span containment.

Traversal adds 800 seeded equivalence/rewrite cases per target and a 16,000-level
stress case for readers, cursors, reductions, AST rewrites and CST source edits.

Printing and formatting run all 389 pinned fixture sources, 1,000 seeded type/comment
properties, 18,000 nested type constructors and 1,200 nested package blocks per target.
Printer output preserves AST structure apart from locations and arena numbering.
Formatter output retains non-whitespace tokens and raw comments and is idempotent.
Malformed source returns diagnostics without partial formatted output.

`@printer.print(tree)` emits canonical source. `@formatter.format(source)` and
`format_cst(tree)` normalize layout using the selected parser feature profile.
Both accept `indent_width`, defaulting to two spaces, and return explicit errors.
The printer supports all implemented proposal forms; the formatter accepts the same
feature switches as parsing. Read each package for recovery and invalid-input behavior.

See root Beads epic `wasm-devkit-p5m` for implementation work.
