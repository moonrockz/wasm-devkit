# moonrockz/wac

WAC language tooling for MoonBit.

Source positions, structured diagnostics, a lossless scanner, typed immutable ASTs/CSTs and
a recovering parser, immutable traversal, rewrites, canonical printing and comment-preserving
formatting are implemented.
Install with `moon add moonrockz/wac@0.2.0`.

## Scenario recipes

Install the module, put the following imports in your package's `moon.pkg`, and copy a recipe
into `example_test.mbt` beside it. Run `moon test --target wasm` to execute the assertions. For application
functions, use the same package imports without `for "test"`. No example requires a package
registry, filesystem or resolver at parse time.

The import group covers all recipes on this page. Keep only the packages your code uses.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/parser",
  "moonrockz/wac/scanner",
  "moonrockz/wac/span",
  "moonrockz/wac/diagnostic",
  "moonrockz/wac/ast",
  "moonrockz/wac/cst",
  "moonrockz/wac/traversal",
  "moonrockz/wac/printer",
  "moonrockz/wac/formatter",
  "moonrockz/wac/verifier",
} for "test"
```

### Distinguish syntax, structure and resolved semantics

`Parse::is_valid()` reports syntax diagnostics. AST/CST `validate()` checks tree
structure and spans. `verifier.verify()` resolves names and checks language
contracts, returning an immutable model or diagnostics. The pure verifier does
no I/O; callers supply dependency packages explicitly.

```mbt check
test "Guide: Syntax validity does not resolve WAC names" {
  let source = "package example:app; let run = missing;"
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  assert_true(parsed.ast.validate() && parsed.cst.validate())
  assert_true(@verifier.verify(parsed, source~) is Err(_))
}
```

See the [verifier recipes](src/verifier/README.mbt.md) for resolved models,
dependencies, nominal resources and the pinned semantic profile. Complete
[CLI bundles](../../examples/verification/README.md) include their local inputs.

### Parse a composition document

Parse imports, an instantiation and an export without loading `example:service`.
Syntax validity does not establish that the referenced component exists or composes correctly.

```mbt check
test "Guide: Parse a WAC document" {
  let source = "package example:app; import host: interface { log: func(message: string); }; let app = new example:service { host, ... }; export app.run as \"run\";"
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

### Inspect a target world and composition expression structure

The target world and component packages stay as syntax references. Spreads, fill arguments,
quoted names and explicit grouping remain distinct nodes for indexing and later semantic tooling.

```mbt check
test "Guide: Inspect a target world and composition expression structure" {
  let source =
    #|package example:app targets example:types/app;
    #|interface host-api { log: func(message: string); }
    #|world app-world { import host: host-api; export run: func(); }
    #|import host as "example:host/log@1.0.0": host-api;
    #|let provider = new example:provider { host };
    #|let app = new example:service { ...provider, "log": host.log, ... };
    #|export (app)["run"] as "run";
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
  let kinds = parsed.ast.nodes.map(node => node.data.kind())
  assert_true(kinds.contains(World))
  assert_true(kinds.contains(SpreadArgument))
  assert_true(kinds.contains(FillArgument))
  assert_true(kinds.contains(Group))
  assert_true(kinds.contains(Access))
  assert_eq(kinds.filter(kind => kind == New).length(), 2)
  assert_true(parsed.ast.nodes.any(node => node.data is Access(name="run", quoted=true)))
}
```

### Report diagnostics while the user is typing

Keep the CST for exact editor text, even when `is_valid()` is false. Codes are stable;
messages can change. The source index reports zero-based UTF-16 positions; add one when
rendering human-readable line and column values.

```mbt check
test "Guide: Render diagnostics as editor line and column values" {
  let source = "package demo:app; interface broken { type missing = ; }"
  let parsed = @parser.parse(source)
  let index = @span.Source::new(source)
  let errors : ReadOnlyArray[@diagnostic.Diagnostic] = parsed.diagnostics
  assert_false(errors.is_empty())
  let locations = errors.map(diagnostic => {
    let position = index.position(diagnostic.primary.span.start).unwrap()
    "example.wac:\{position.line + 1}:\{position.column + 1}: " + diagnostic.code
  })
  assert_true(locations[0].has_prefix("example.wac:1:"))
  assert_false(parsed.is_valid())
  assert_eq(parsed.cst.to_source(), source)
}
```

### Read named fields for an import and binding index

```mbt check
test "Guide: Index WAC declarations" {
  let source = "package example:app; import host: interface {}; let app = new example:service { host }; export app.run;"
  let parsed = @parser.parse(source)
  let imports = []
  let bindings = []
  let expressions = []
  let _ = @traversal.walk(Ast(parsed.ast), event => {
    if event.phase == Enter {
      match parsed.ast.nodes[event.view.index].data {
        Import(binding~, ..) => imports.push(binding)
        Let(name~, expression~) => {
          bindings.push(name)
          expressions.push(parsed.ast.nodes[expression].data.kind())
        }
        _ => ()
      }
    }
    Continue
  }).unwrap()
  assert_eq(imports, ["host"])
  assert_eq(bindings, ["app"])
  assert_eq(expressions, [Expression])
}
```

### Refactor a type and print a new document

Use AST rewrites when the change concerns typed structure. The callback receives candidate
children with output-arena IDs, so retain those IDs when replacing a parent. `Keep` retains
rewritten children. Printing discards trivia; choose CST edits when comments must survive.

```mbt check
test "Guide: Change a type without mutating the parsed tree" {
  let parsed = @parser.parse("package demo:app; interface api { type byte = u8; }")
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
  let source = "// keep this comment\npackage demo:app; interface api { type byte = u8; }"
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

WAC named results are an opt-in extension. The pinned reference parser rejects them,
although its language document describes them. Keep the profile when formatting or applying CST edits.

```mbt check
test "Guide: Enable only the grammar extension your source needs" {
  let source = "package demo:app; type callback = func() -> (value: u8);"
  assert_false(@parser.parse(source).is_valid())
  let features : @parser.Features = { named_results: true }
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
  let source = "package demo:app; interface broken { type missing = ; } interface later {}"
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

Package/targets directives, WIT-style definitions supported by the WAC reference, imports, let bindings, instantiations, access expressions, spread arguments and exports.

Syntax parsing is separate from semantic resolution. The
[verifier](src/verifier/README.mbt.md) checks ordered local declarations and returns
immutable resource, interface and world contracts. It resolves supplied declarative
binary packages, named/inferred/spread/implicit instantiation arguments, instance member access,
export spreads and target-world checks; the CLI loads binary and portable WAT
dependencies and WIT source/encoded closures. The CLI supports explicit Warg
registries, checked caches and offline lockfiles outside the pure verifier.
The syntax parser must not perform I/O.

## Packages

| Package | Responsibility |
|---------|-------------------------|
| [span](src/span/README.mbt.md) | Source text, positions and documented Unicode offset units |
| [diagnostic](src/diagnostic/README.mbt.md) | Stable codes, severity, source labels and recovery details |
| [scanner](src/scanner/README.mbt.md) | Lossless tokens, comments and whitespace |
| [ast](src/ast/README.mbt.md) | Immutable typed nodes and child collections |
| [cst](src/cst/README.mbt.md) | Immutable lossless concrete structure, including malformed input |
| [parser](src/parser/README.mbt.md) | Recovering source-to-AST/CST parsing with diagnostics |
| [traversal](src/traversal/README.mbt.md) | Explicit-stack walks, folds, reductions, events, cursors and immutable rewrites |
| [printer](src/printer/README.mbt.md) | Stack-safe canonical AST-to-source emission |
| [formatter](src/formatter/README.mbt.md) | Stack-safe CST formatting that preserves comments and meaning |
| [verifier](src/verifier/README.mbt.md) | Pure name/type/dependency resolution and immutable semantic models |

## Validation

- Upstream valid and invalid fixtures pinned to the reference linked in the root README.
- Exact scanner/CST reconstruction, including Unicode, comments and malformed text.
- Diagnostic recovery, progress through arbitrary input and no-panic properties.
- Deep types, groups and instantiations on every target.

Traversal tests cover canonical event order, prune/stop, cursors, immutable rewrites and
all 46 node kinds. Printer round trips and formatter idempotence/token-preservation laws cover all corpus files
and deep WAC composition expressions. The [parser profile](src/parser/README.mbt.md) documents
the pinned corpus and WIT grammar differences.

See root Beads epic `wasm-devkit-p5m` for implementation work.
