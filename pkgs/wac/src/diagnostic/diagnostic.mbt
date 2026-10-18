///|
pub(all) enum Severity {
  Error
  Warning
} derive(Eq, Debug)

///|
pub(all) struct Label {
  span : @span.Span
  message : String
} derive(Eq, Debug)

///|
/// What the frontend did after reporting a diagnostic.
pub(all) enum Recovery {
  Continue
  SkipToken
  EndOfInput
} derive(Eq, Debug)

///|
/// Diagnostic codes are stable strings, independent of rendered messages.
/// All labels use UTF-16 offsets in the input source.
pub(all) struct Diagnostic {
  code : String
  severity : Severity
  message : String
  primary : Label
  related : ReadOnlyArray[Label]
  recovery : Recovery
} derive(Eq, Debug)

///|
pub fn Diagnostic::error(
  code : String,
  message : String,
  span : @span.Span,
  recovery~ : Recovery = Continue,
) -> Diagnostic {
  {
    code,
    severity: Error,
    message,
    primary: { span, message, },
    related: [],
    recovery,
  }
}

///|
pub extend Severity with Eq::{equal, not_equal}

///|
pub extend Label with Eq::{equal, not_equal}

///|
pub extend Recovery with Eq::{equal, not_equal}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Severity with @debug.Debug::{to_repr}

///|
pub extend Label with @debug.Debug::{to_repr}

///|
pub extend Recovery with @debug.Debug::{to_repr}

///|
pub extend Diagnostic with @debug.Debug::{to_repr}
