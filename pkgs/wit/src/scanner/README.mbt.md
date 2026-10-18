# WIT scanner

`scan(text)` returns a `Scan` with `ReadOnlyArray[Token]` and
`ReadOnlyArray[Diagnostic]`. Each token holds its kind, exact raw spelling and UTF-16 span.
No mutable backing arrays escape. Keywords have kind `Keyword` and retain their spelling;
percent-prefixed keywords have kind `Identifier`.

Tokens tile the input without gaps or overlaps. Whitespace and both comment kinds are
tokens, rather than discarded trivia. Exactly one empty `Eof` follows the source-bearing
tokens. `Scan::to_source()` reconstructs the exact input, including malformed UTF-16.
`TokenKind::is_trivia()` identifies whitespace, line comments and block comments.

## Lexical profile

The baseline is [Component Model WIT.md](https://github.com/WebAssembly/component-model/blob/0220da84209397d9067c19cac83dae969aa85a7b/design/mvp/WIT.md),
revision `0220da84209397d9067c19cac83dae969aa85a7b`. Tests cover all 42 keywords in its
lexical grammar. Proposal syntax, attribute recognition, package/path assembly and
semantic-version validation belong to the future parser. `get` and `set` remain contextual
identifiers. Lexical acceptance never implies that a proposal or document is supported.

- ASCII kebab identifiers use consistently lower- or uppercase segments, optionally escaped with `%`.
- Integers are digit sequences. A digit sequence followed by a dot and another digit starts a `Version`
  candidate, consuming contiguous ASCII letters, digits, dots, hyphens and plus signs.
  This permits SemVer labels that are not WIT identifiers. The parser must validate the
  complete candidate, including leading-zero and label rules. A dot before punctuation
  or trivia remains a separate token, including the dot in `use path@1.2.3.{names}`. No bounded numeric conversion
  takes place in the scanner.
- Operators follow the pinned lexical table. `Minus`, `Plus` and `Underscore` also represent
  semantic-version pieces and the result placeholder. `->` takes precedence over `-`.
- Line comments stop before LF, retaining any preceding CR. Block comments nest using a depth counter.
- Quoted names validate Core WebAssembly escapes, Unicode scalar escapes and decoded UTF-8 bytes.
  Raw LF/CR terminates an unclosed string for recovery; subsequent declarations remain visible.
- Unicode restrictions apply everywhere, including inside comments and strings. The scanner
  rejects C0/C1 controls except HT/LF/CR, bidi overrides/isolates U+202A..U+202E and U+2066..U+2069,
  and discouraged U+0149, U+0673, U+0F77, U+0F79, U+17A3, U+17A4, U+17B4 and U+17B5.
  Unpaired UTF-16 surrogates are diagnosed and retained.

## Diagnostics

Diagnostics are ordered by source start and then code. A token can have more than one
diagnostic, for example a forbidden character inside an unterminated string.
Malformed identifiers and unknown characters have kind `Invalid`; malformed comments
and strings retain their token kind. Always inspect diagnostics before consuming a scan as valid.

| Code | Meaning |
|------|---------|
| `WIT-L001` | Unexpected character |
| `WIT-L002` | Invalid kebab-case identifier |
| `WIT-L003` | Unterminated block comment |
| `WIT-L004` | Unterminated string literal |
| `WIT-L005` | Disallowed source character |
| `WIT-L006` | Invalid string escape or unescaped string control |
| `WIT-L007` | Decoded name bytes are not UTF-8 |
| `WIT-L008` | Unpaired UTF-16 surrogate |

The scanner and reconstruction use loops without input-controlled recursion. Tests include
generated Unicode and malformed fragments, immutable collection ownership, exact span tiling,
string escape boundaries and 30,000 nested block comments on every target. Upstream syntax
corpus validation remains part of Beads task `wasm-devkit-p5m.2.1`.
