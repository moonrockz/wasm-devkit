///|
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
