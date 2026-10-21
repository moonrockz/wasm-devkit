# WAC span

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wac@0.3.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wac/span",
} for "test"
```

### Map Unicode source positions

```mbt check
///|
test "README: Map Unicode source positions" {
  let source = @span.Source::new("a😀\nnext")
  assert_eq(source.text(), "a😀\nnext")
  assert_eq(source.span(), { start: 0, end: 8, })
  assert_eq(source.line_count(), 2)
  assert_eq(source.position(3), Some({ line: 0, column: 3, }))
  assert_eq(source.position(4), Some({ line: 1, column: 0, }))
  assert_eq(source.slice({ start: 1, end: 3, }), Some("😀"))
}
```

### Measure an editor range

```mbt check
///|
test "README: Measure an editor range" {
  let selection : @span.Span = { start: 1, end: 3, }
  assert_eq(selection.length(), 2)
  assert_true(selection.contains({ start: 2, end: 2, }))
  assert_false(selection.contains({ start: 0, end: 1, }))
}
```

### Handle an editor offset at EOF

```mbt check
///|
test "README: Handle an editor offset at EOF" {
  let source = @span.Source::new("line\n")
  assert_eq(source.position(5), Some({ line: 1, column: 0, }))
  assert_eq(source.position(6), None)
  assert_eq(source.position(-1), None)
  assert_eq(source.slice({ start: 3, end: 2, }), None)
}
```

### Slice checked UTF-16 selections

```mbt check
///|
test "README: Slice checked UTF-16 selections" {
  let source = @span.Source::new("a😀z")
  assert_eq(source.slice({ start: 1, end: 3, }), Some("😀"))
  assert_eq(source.slice({ start: 0, end: 5, }), None)
  // Editor ranges are not silently clamped or interpreted as UTF-8 bytes.
  assert_eq(source.slice({ start: -1, end: 1, }), None)
}
```

## API contracts

`Span` is a half-open UTF-16 code-unit range. Offsets and columns count the same units
as MoonBit's `String::length()`, across all four targets. They are not UTF-8 byte offsets
or Unicode scalar counts. An astral character such as `😀` takes two units.

`Source::new(text)` retains immutable source text and builds an immutable line index.
`position(offset)` returns a zero-based line and column or `None` outside the source.
EOF is valid. LF and CRLF end lines; bare CR does not. A final LF creates an empty final line.

`slice(span)` returns `None` for negative, reversed or out-of-bounds ranges. Valid ranges
retain the exact requested units, even when an editor range splits a surrogate pair.
Callers constructing `Span` values must supply meaningful ranges. Scanner-produced spans
always satisfy `0 <= start <= end <= source.length()`.

`Span::contains(child)` includes zero-width children at either boundary and rejects reversed
child spans. Sources expose no mutable line table.
