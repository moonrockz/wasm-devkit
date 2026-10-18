///|
/// A half-open UTF-16 code-unit range. Scanner/parser output always satisfies
/// `0 <= start <= end <= source.length()`. Use Source::slice to check external ranges.
pub(all) struct Span {
  start : Int32
  end : Int32
} derive(Eq, Debug)

///|
pub fn Span::length(self : Span) -> Int32 {
  self.end - self.start
}

///|
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
pub fn Source::text(self : Source) -> String {
  self.text
}

///|
pub fn Source::span(self : Source) -> Span {
  { start: 0, end: self.text.length(), }
}

///|
pub fn Source::line_count(self : Source) -> Int32 {
  self.line_starts.length()
}

///|
/// Invalid offsets return None. EOF is a valid position, including after a final LF.
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
