///|
/// A half-open UTF-16 code-unit range. Scanner/parser output always satisfies
/// `0 <= start <= end <= source.length()`. Use Source::slice to check external ranges.
///
/// Measure an editor range.
///
/// Example imports: `moonrockz/wit/span` as `@span`.
///
/// ```mbt check
/// test "Span: Measure an editor range" {
///   let selection : @span.Span = { start: 1, end: 3, }
///   assert_eq(selection.length(), 2)
///   assert_true(selection.contains({ start: 2, end: 2, }))
///   assert_false(selection.contains({ start: 0, end: 1, }))
/// }
/// ```
pub(all) struct Span {
  start : Int32
  end : Int32
} derive(Eq, Debug)

///|
/// Return `end - start` in UTF-16 code units. Validate external ranges with `Source::slice`.
pub fn Span::length(self : Span) -> Int32 {
  self.end - self.start
}

///|
/// Test containment, including zero-width selections at either boundary. Reversed children are rejected.
pub fn Span::contains(self : Span, other : Span) -> Bool {
  self.start <= other.start && other.start <= other.end && other.end <= self.end
}

///|
/// Zero-based line and UTF-16 column, suitable for editor protocols.
pub(all) struct Position {
  line : Int32
  column : Int32
} derive(Eq, Debug)

///|
/// Immutable source text with an indexed line table. LF and CRLF end lines;
/// a bare CR does not. Offsets and columns count UTF-16 code units, not bytes.
pub struct Source {
  priv text : String
  priv line_starts : ReadOnlyArray[Int32]
}

///|
///
/// Map Unicode source positions.
///
/// Example imports: `moonrockz/wit/span` as `@span`.
///
/// ```mbt check
/// test "Source::new: Map Unicode source positions" {
///   let source = @span.Source::new("a😀\nnext")
///   assert_eq(source.text(), "a😀\nnext")
///   assert_eq(source.span(), { start: 0, end: 8, })
///   assert_eq(source.line_count(), 2)
///   assert_eq(source.position(3), Some({ line: 0, column: 3, }))
///   assert_eq(source.position(4), Some({ line: 1, column: 0, }))
///   assert_eq(source.slice({ start: 1, end: 3, }), Some("😀"))
/// }
/// ```
pub fn Source::new(text : String) -> Source {
  let starts = [0]
  for i in 0..<text.length() {
    if text.code_unit_at(i).to_int() == 10 {
      starts.push(i + 1)
    }
  }
  { text, line_starts: ReadOnlyArray::from_array(starts), }
}

///|
/// Return the original immutable text. See `Source::new` for a position-and-slice example.
pub fn Source::text(self : Source) -> String {
  self.text
}

///|
/// Return the complete half-open range, including the valid EOF offset.
pub fn Source::span(self : Source) -> Span {
  { start: 0, end: self.text.length(), }
}

///|
/// Count indexed lines. Empty input has one line; a final LF starts an empty last line.
pub fn Source::line_count(self : Source) -> Int32 {
  self.line_starts.length()
}

///|
/// Invalid offsets return None. EOF is a valid position, including after a final LF.
///
/// Handle an editor offset at EOF.
///
/// Example imports: `moonrockz/wit/span` as `@span`.
///
/// ```mbt check
/// test "Source::position: Handle an editor offset at EOF" {
///   let source = @span.Source::new("line\n")
///   assert_eq(source.position(5), Some({ line: 1, column: 0, }))
///   assert_eq(source.position(6), None)
///   assert_eq(source.position(-1), None)
///   assert_eq(source.slice({ start: 3, end: 2, }), None)
/// }
/// ```
pub fn Source::position(self : Source, offset : Int32) -> Position? {
  guard offset >= 0 && offset <= self.text.length() else { return None }
  let mut lo = 0
  let mut hi = self.line_starts.length()
  while lo + 1 < hi {
    let mid = lo + (hi - lo) / 2
    if self.line_starts[mid] <= offset {
      lo = mid
    } else {
      hi = mid
    }
  }
  Some({ line: lo, column: offset - self.line_starts[lo], })
}

///|
/// Does not clamp invalid ranges or interpret offsets as byte indices.
///
/// Slice checked UTF-16 selections.
///
/// Example imports: `moonrockz/wit/span` as `@span`.
///
/// ```mbt check
/// test "Source::slice: Slice checked UTF-16 selections" {
///   let source = @span.Source::new("a😀z")
///   assert_eq(source.slice({ start: 1, end: 3, }), Some("😀"))
///   assert_eq(source.slice({ start: 0, end: 5, }), None)
///   // Editor ranges are not silently clamped or interpreted as UTF-8 bytes.
///   assert_eq(source.slice({ start: -1, end: 1, }), None)
/// }
/// ```
pub fn Source::slice(self : Source, span : Span) -> String? {
  guard span.start >= 0 &&
    span.start <= span.end &&
    span.end <= self.text.length() else {
    return None
  }
  // Bounds are checked above. StringView slicing would move endpoints
  // inside surrogate pairs, changing the requested UTF-16 editor range.
  Some(self.text.unsafe_substring(start=span.start, end=span.end))
}

///|
pub extend Span with Eq::{equal, not_equal}

///|
pub extend Position with Eq::{equal, not_equal}

///|
pub extend Span with @debug.Debug::{to_repr}

///|
pub extend Position with @debug.Debug::{to_repr}
