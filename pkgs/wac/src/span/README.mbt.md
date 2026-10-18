# WAC span

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
