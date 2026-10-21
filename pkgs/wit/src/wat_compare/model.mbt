///|
/// Text compares every UTF-16 code unit. Semantic compares validated decoded
/// core-module structure with typed numeric literals, as described in README.
pub(all) enum Mode {
  Text
  Semantic
} derive(Eq, @debug.Debug)

///|
pub(all) enum Side {
  Left
  Right
} derive(Eq, @debug.Debug)

///|
pub(all) enum ErrorKind {
  Malformed
  Invalid
  Unsupported
} derive(Eq, @debug.Debug)

///|
pub struct Diagnostic {
  side : Side
  kind : ErrorKind
  span : @span.Span?
  message : String
} derive(Eq, @debug.Debug)

///|
/// A changed canonical section/body or floating point literal. Values are
/// canonical binary bytes, or exact floating point bits, in little endian order. Spans refer to original source.
pub struct Difference {
  path : String
  left : Bytes?
  right : Bytes?
  left_span : @span.Span?
  right_span : @span.Span?
} derive(Eq, @debug.Debug)

///|
pub struct Comparison {
  differences : ReadOnlyArray[Difference]
} derive(Eq, @debug.Debug)

///|
pub fn Comparison::is_equal(self : Comparison) -> Bool {
  self.differences.is_empty()
}

///|
priv suberror Failure {
  Failure(ErrorKind, @span.Span?, String)
}

///|
priv struct Token {
  text : String
  span : @span.Span
}

///|
priv struct Field {
  kind : String
  span : @span.Span
  first : Int32
  last : Int32
}

///|
priv struct FloatLiteral {
  path : String
  bits : Bytes
  span : @span.Span
}

///|
priv struct Input {
  bytes : Bytes
  fields : Array[Field]
  floats : Array[FloatLiteral]
}

///|
pub extend Mode with Eq::{equal, not_equal}

///|
pub extend Mode with @debug.Debug::{to_repr}

///|
pub extend Side with Eq::{equal, not_equal}

///|
pub extend Side with @debug.Debug::{to_repr}

///|
pub extend ErrorKind with Eq::{equal, not_equal}

///|
pub extend ErrorKind with @debug.Debug::{to_repr}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Diagnostic with @debug.Debug::{to_repr}

///|
pub extend Difference with Eq::{equal, not_equal}

///|
pub extend Difference with @debug.Debug::{to_repr}

///|
pub extend Comparison with Eq::{equal, not_equal}

///|
pub extend Comparison with @debug.Debug::{to_repr}
