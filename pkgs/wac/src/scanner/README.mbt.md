# WAC scanner

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.1.1`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/scanner",
} for "test"
```

### Keep comments and malformed tokens for an editor

```mbt check
///|
test "README: Keep comments and malformed tokens for an editor" {
  let source = "/* note */ ?"
  let scanned = @scanner.scan(source)
  assert_eq(scanned.to_source(), source)
  assert_eq(scanned.tokens[0].kind, BlockComment)
  assert_true(scanned.tokens.any(token => token.kind == Invalid))
  assert_false(scanned.diagnostics.is_empty())
  assert_eq(scanned.tokens[scanned.tokens.length() - 1].kind, Eof)
}
```

### Filter trivia without changing token locations

```mbt check
///|
test "README: Filter trivia without changing token locations" {
  let scanned = @scanner.scan("/* note */ name")
  let significant = scanned.tokens.filter(token => {
    !token.kind.is_trivia() && token.kind != Eof
  })
  assert_eq(significant.length(), 1)
  assert_eq(significant[0].text, "name")
  assert_eq(significant[0].span.start, 11)
  assert_eq(scanned.to_source(), "/* note */ name")
}
```

### Inspect atomic WAC paths and raw string names

```mbt check
///|
test "README: Inspect atomic WAC paths and raw string names" {
  let source = "demo:pkg/api@1.2.3 \"raw\\q\""
  let scanned = @scanner.scan(source)
  assert_true(scanned.diagnostics.is_empty())
  assert_eq(scanned.tokens[0].kind, PackagePath)
  assert_eq(scanned.tokens[0].text, "demo:pkg/api@1.2.3")
  assert_eq(scanned.tokens[2].text, "\"raw\\q\"")
  assert_eq(scanned.to_source(), source)
}
```

## API contracts

`scan(text)` returns immutable tokens and diagnostics without raising. Every token retains
its raw spelling and half-open UTF-16 span. Concatenating tokens with `Scan::to_source()`
reconstructs exact input, including malformed tokens and unpaired surrogate units. There
is one zero-width EOF token. Whitespace, line comments and nested block comments are trivia.

The baseline is the [pinned WAC parser](../parser/fixtures/README.md). Package names and paths
are atomic tokens, including their optional version. Trivia cannot split their components.
SemVer validation belongs to parsing. A declaration such as `p: u8` needs separation
after the colon; contiguous `p:u8` is a package-name token. Each hyphen-separated identifier word starts with
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
