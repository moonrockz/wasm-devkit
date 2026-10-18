///|
/// Classify a diagnostic independently of its code. A warning does not make `Parse::is_valid` false.
pub(all) enum Severity {
  Error
  Warning
} derive(Eq, Debug)

///|
/// Associate a message with a UTF-16 source range. Related labels can point to earlier declarations.
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
///
/// Connect a duplicate declaration to its original.
///
/// Example imports: `moonrockz/wit/diagnostic` as `@diagnostic`, `moonrockz/wit/span` as `@span`.
///
/// ```mbt check
/// test "Diagnostic: Connect a duplicate declaration to its original" {
///   let primary : @span.Span = { start: 10, end: 14, }
///   let base = @diagnostic.Diagnostic::error(
///     "APP-DUPLICATE", "duplicate name", primary,
///   )
///   let diagnostic : @diagnostic.Diagnostic = {
///     ..base,
///     severity: Warning,
///     related: [{ span: { start: 0, end: 4, }, message: "first declared here", }],
///   }
///   assert_eq(diagnostic.related.length(), 1)
///   assert_eq(diagnostic.related[0].message, "first declared here")
///   assert_true(base.related.is_empty())
/// }
/// ```
pub(all) struct Diagnostic {
  code : String
  severity : Severity
  message : String
  primary : Label
  related : ReadOnlyArray[Label]
  recovery : Recovery
} derive(Eq, Debug)

///|
///
/// Attach an application diagnostic to source.
///
/// Example imports: `moonrockz/wit/diagnostic` as `@diagnostic`, `moonrockz/wit/span` as `@span`.
///
/// ```mbt check
/// test "Diagnostic::error: Attach an application diagnostic to source" {
///   let span : @span.Span = { start: 0, end: 4, }
///   let diagnostic = @diagnostic.Diagnostic::error(
///     "APP-001",
///     "unknown import",
///     span,
///     recovery=SkipToken,
///   )
///   assert_eq(diagnostic.code, "APP-001")
///   assert_eq(diagnostic.severity, Error)
///   assert_eq(diagnostic.primary.span, span)
///   assert_eq(diagnostic.recovery, SkipToken)
/// }
/// ```
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
