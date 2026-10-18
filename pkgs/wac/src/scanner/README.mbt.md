# WAC scanner

`scan(text)` returns immutable tokens and diagnostics without raising. Every token retains
its raw spelling and half-open UTF-16 span. Concatenating tokens with `Scan::to_source()`
reconstructs exact input, including malformed tokens and unpaired surrogate units. There
is one zero-width EOF token. Whitespace, line comments and nested block comments are trivia.

The baseline is the [pinned WAC parser](../parser/fixtures/README.md). Package names and paths
are atomic tokens, including their optional version. Trivia cannot split their components.
SemVer validation belongs to parsing. Each hyphen-separated identifier word starts with
an ASCII letter and uses one letter case, with optional digits after that first letter.
Percent-prefixed keywords are identifiers. Unlike WIT, a word cannot begin with a digit
after a hyphen. `own`, `map`, `get` and `set` are ordinary identifiers.

String literals end at the first following quotation mark. Backslashes have no escape
meaning, and quoted names may contain newlines. This differs from WIT string names.
Unicode controls, bidi overrides, deprecated codepoints and unpaired surrogate units
produce diagnostics throughout source, including trivia and strings. A BOM is not stripped.
Unterminated strings recover at the first newline when no closing quote exists.

| Code | Meaning |
|------|---------|
| `WAC-L001` | Unexpected character |
| `WAC-L002` | Invalid identifier spelling |
| `WAC-L003` | Unterminated nested block comment |
| `WAC-L004` | Unterminated string |
| `WAC-L005` | Disallowed source character |
| `WAC-L008` | Unpaired UTF-16 surrogate |

Scanning uses loops, including nested comments. Tests check exact token ranges and arbitrary
source reconstruction on wasm, wasm-gc, js and native.
