# Pinned WIT specification examples

Source: [design/mvp/WIT.md](https://github.com/WebAssembly/component-model/blob/0220da84209397d9067c19cac83dae969aa85a7b/design/mvp/WIT.md)
at revision `0220da84209397d9067c19cac83dae969aa85a7b`.
The upstream Apache-2.0 license is retained here. The vendored source literals live in
`../upstream_test.mbt` so all targets can test them without filesystem access.

All 79 WIT fenced blocks are accounted for below. Numbering is zero-based in document order.
Declaration snippets are wrapped in their grammatical context. The parser enables all proposal
switches for these fixtures. Semantic errors such as undefined names, duplicate definitions,
type cycles and incompatible feature gates are accepted as syntax, as the parser performs no
semantic resolution. Block 47 contains an invalid package-only import. Block 72 omits a required
package semicolon. Skipped blocks contain pseudo-syntax or combined files, rather than complete
parseable documents. The [wasm-tools corpus](wasm-tools/README.md) separately covers
all 321 WIT files at its pinned revision; these examples do not claim exhaustive grammar compatibility.

| Block | Check | Adaptation or reason |
|-------|-------|----------------------|
| 0 | Syntax acceptance | Unmodified. |
| 1 | Syntax acceptance | Unmodified. |
| 2 | Syntax acceptance | Unmodified. |
| 3 | Syntax acceptance | Unmodified. |
| 4 | Syntax acceptance | Unmodified. |
| 5 | Syntax acceptance | Unmodified. |
| 6 | Syntax acceptance | Unmodified. |
| 7 | Syntax acceptance | Unmodified. |
| 8 | Syntax acceptance | Unmodified. |
| 9 | Syntax acceptance | Unmodified. |
| 10 | Syntax acceptance | Unmodified. |
| 11 | Syntax acceptance | Unmodified. |
| 12 | Syntax acceptance | Unmodified. |
| 13 | Syntax acceptance | Unmodified. |
| 14 | Syntax acceptance | Unmodified. |
| 15 | Syntax acceptance | Unmodified. |
| 16 | Syntax acceptance | Unmodified. |
| 17 | Syntax acceptance | Unmodified. |
| 18 | Skip | Multiple pseudo-files and an ellipsis-only enum body. |
| 19 | Skip | Multiple separate files combined in one fenced block. |
| 20 | Syntax acceptance | Unmodified. |
| 21 | Syntax acceptance | Unmodified. |
| 22 | Syntax acceptance | Unmodified. |
| 23 | Syntax acceptance | Unmodified. |
| 24 | Syntax acceptance | Unmodified. |
| 25 | Syntax acceptance | Unmodified. |
| 26 | Syntax acceptance | Unmodified. |
| 27 | Syntax acceptance | Unmodified. |
| 28 | Syntax acceptance | Unmodified. |
| 29 | Syntax acceptance | Unmodified. |
| 30 | Syntax acceptance | Unmodified. |
| 31 | Syntax acceptance | Unmodified. |
| 32 | Syntax acceptance | Unmodified. |
| 33 | Skip | Contains an ellipsis-only resource body standing for omitted methods. |
| 34 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 35 | Syntax acceptance | Unmodified. |
| 36 | Skip | EBNF grammar labeled as WIT. |
| 37 | Syntax acceptance | Unmodified. |
| 38 | Syntax acceptance | Unmodified. |
| 39 | Syntax acceptance | Unmodified. |
| 40 | Syntax acceptance | Unmodified. |
| 41 | Syntax acceptance | Unmodified. |
| 42 | Syntax acceptance | Unmodified. |
| 43 | Syntax acceptance | Unmodified. |
| 44 | Syntax acceptance | Unmodified. |
| 45 | Syntax acceptance | Unmodified. |
| 46 | Syntax acceptance | Unmodified. |
| 47 | Invalid syntax | Unmodified. |
| 48 | Syntax acceptance | Unmodified. |
| 49 | Syntax acceptance | Wrapped in `world fixture { ... }`. |
| 50 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 51 | Skip | Desugared getter/setter component names, not legal WIT identifiers. |
| 52 | Syntax acceptance | Unmodified. |
| 53 | Skip | Illustrative incomplete use declarations without semicolons and with bare reserved names. |
| 54 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 55 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 56 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 57 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 58 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 59 | Skip | Illustrative function with an unnamed parameter, outside the named-parameter grammar. |
| 60 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 61 | Skip | Desugared resource component names, not legal WIT identifiers. |
| 62 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 63 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 64 | Skip | Desugared option/result variants with bare reserved names. |
| 65 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 66 | Skip | Desugared resource component names and an incomplete declaration. |
| 67 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 68 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 69 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 70 | Syntax acceptance | Wrapped in `interface fixture { ... }`. |
| 71 | Syntax acceptance | Unmodified. |
| 72 | Invalid syntax | Unmodified. |
| 73 | Syntax acceptance | Unmodified. |
| 74 | Syntax acceptance | Unmodified. |
| 75 | Syntax acceptance | Unmodified. |
| 76 | Syntax acceptance | Unmodified. |
| 77 | Skip | Examples from several separate files combined in one fenced block. |
| 78 | Syntax acceptance | Unmodified. |

The newer semantic reference's named-interface grammar accepts `import a:b;` as a
named import. The original specification example 47 remains invalid under the pinned
`Features::all()` syntax profile. `Features::reference()` selects the newer grammar
without changing this corpus's expected result.
