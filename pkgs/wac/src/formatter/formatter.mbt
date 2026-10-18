///|
///
/// Keep invalid input unchanged and report formatting errors.
///
/// Example imports: `moonrockz/wac/formatter` as `@formatter`, `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "FormatError: Keep invalid input unchanged and report formatting errors" {
///   let source = "package demo:app; interface broken { type missing = ; } interface later {}"
///   match @formatter.format(source) {
///     Err(InvalidSyntax(diagnostics)) => assert_false(diagnostics.is_empty())
///     _ => fail("expected syntax diagnostics")
///   }
///   assert_eq(@parser.parse(source).cst.to_source(), source)
///   assert_eq(@formatter.format(source, indent_width=-1), Err(InvalidOptions))
/// }
/// ```
pub(all) enum FormatError {
  InvalidOptions
  InvalidTree
  InvalidSyntax(ReadOnlyArray[@diagnostic.Diagnostic])
  InvariantViolation
} derive(Eq, Debug)

///|
fn retained(
  tokens : ReadOnlyArray[@scanner.Token],
) -> Array[(@scanner.TokenKind, String)] {
  tokens
  .iter()
  .filter(t => t.kind != Whitespace && t.kind != Eof)
  .map(t => (t.kind, t.text))
  .to_array()
}

///|
fn format_parsed(
  parsed : @parser.Parse,
  indent_width : Int32,
  features : @parser.Features,
) -> Result[String, FormatError] {
  if !parsed.is_valid() {
    return Err(InvalidSyntax(parsed.diagnostics))
  }
  guard @layout.render(parsed.cst, indent_width) is Some(text) else {
    return Err(InvariantViolation)
  }
  let next = @parser.parse(text, features~)
  if !next.is_valid() ||
    !parsed.ast.equivalent(next.ast) ||
    retained(parsed.cst.tokens) != retained(next.cst.tokens) {
    return Err(InvariantViolation)
  }
  Ok(text)
}

///|
/// Normalize valid WAC layout while preserving every non-whitespace token and
/// comment verbatim. Malformed input returns diagnostics, with no partial output.
/// No input-controlled syntax traversal or layout step uses recursion.
///
/// Format source while preserving comments and meaning.
///
/// Example imports: `moonrockz/wac/formatter` as `@formatter`, `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "format: Format source while preserving comments and meaning" {
///   let source = "// keep\npackage demo:app; interface api{type byte=u8;}"
///   let formatted = @formatter.format(source).unwrap()
///   assert_true(formatted.has_prefix("// keep\n"))
///   assert_true(formatted.contains("type byte = u8;"))
///   assert_eq(@formatter.format(formatted), Ok(formatted))
///   assert_true(
///     @parser.parse(source).ast.equivalent(@parser.parse(formatted).ast),
///   )
/// }
/// ```
pub fn format(
  source : String,
  indent_width~ : Int32 = 2,
  features~ : @parser.Features = @parser.Features::default(),
) -> Result[String, FormatError] {
  if indent_width < 0 || indent_width > 8 {
    return Err(InvalidOptions)
  }
  format_parsed(@parser.parse(source, features~), indent_width, features)
}

///|
/// Hand-built concrete arenas must validate. Reparsing their immutable source
/// rebuilds grammar ownership before applying layout.
///
/// Reuse a concrete tree with the same extension profile.
///
/// Example imports: `moonrockz/wac/formatter` as `@formatter`, `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "format_cst: Reuse a concrete tree with the same extension profile" {
///   let source = "package demo:app; type callback = func() -> (value: u8);"
///   let features : @parser.Features = { named_results: true, }
///   let parsed = @parser.parse(source, features~)
///   assert_true(parsed.is_valid())
///   let formatted = @formatter.format_cst(parsed.cst, features~, indent_width=2).unwrap()
///   assert_eq(@formatter.format(formatted, features~), Ok(formatted))
///   assert_eq(parsed.cst.to_source(), source)
/// }
/// ```
pub fn format_cst(
  tree : @cst.Tree,
  indent_width~ : Int32 = 2,
  features~ : @parser.Features = @parser.Features::default(),
) -> Result[String, FormatError] {
  if indent_width < 0 || indent_width > 8 {
    return Err(InvalidOptions)
  }
  if !tree.validate() {
    return Err(InvalidTree)
  }
  format_parsed(
    @parser.parse(tree.to_source(), features~),
    indent_width,
    features,
  )
}

///|
pub extend FormatError with Eq::{equal, not_equal}

///|
pub extend FormatError with @debug.Debug::{to_repr}
