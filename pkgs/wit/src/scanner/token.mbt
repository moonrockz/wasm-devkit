///|
/// Keywords retain their spelling. Percent-prefixed keywords are identifiers.
/// Minus and Plus are lexical pieces for semantic versions. The parser determines
/// whether they are allowed at a particular position.
pub(all) enum TokenKind {
  Whitespace
  LineComment
  BlockComment
  Identifier
  Keyword
  Integer
  Version
  StringLiteral
  Equal
  Comma
  Colon
  Semicolon
  LParen
  RParen
  LBrace
  RBrace
  LAngle
  RAngle
  Star
  Arrow
  Slash
  Dot
  At
  Minus
  Plus
  Underscore
  Invalid
  Eof
} derive(Eq, Debug)

///|
///
/// Filter trivia without changing token locations.
///
/// Example imports: `moonrockz/wit/scanner` as `@scanner`.
///
/// ```mbt check
/// test "TokenKind::is_trivia: Filter trivia without changing token locations" {
///   let scanned = @scanner.scan("/* note */ name")
///   let significant = scanned.tokens.filter(token => {
///     !token.kind.is_trivia() && token.kind != Eof
///   })
///   assert_eq(significant.length(), 1)
///   assert_eq(significant[0].text, "name")
///   assert_eq(significant[0].span.start, 11)
///   assert_eq(scanned.to_source(), "/* note */ name")
/// }
/// ```
pub fn TokenKind::is_trivia(self : TokenKind) -> Bool {
  self is (Whitespace | LineComment | BlockComment)
}

///|
/// Raw spelling, including delimiters, percent escapes and malformed text.
/// There is exactly one zero-width EOF token, after all source-bearing tokens.
pub(all) struct Token {
  kind : TokenKind
  text : String
  span : @span.Span
} derive(Eq, Debug)

///|
/// No mutable backing collection escapes through either field.
pub(all) struct Scan {
  tokens : ReadOnlyArray[Token]
  diagnostics : ReadOnlyArray[@diagnostic.Diagnostic]
} derive(Eq, Debug)

///|
///
/// Keep comments and malformed tokens for an editor.
///
/// Example imports: `moonrockz/wit/scanner` as `@scanner`.
///
/// ```mbt check
/// test "Scan::to_source: Keep comments and malformed tokens for an editor" {
///   let source = "/* note */ ?"
///   let scanned = @scanner.scan(source)
///   assert_eq(scanned.to_source(), source)
///   assert_eq(scanned.tokens[0].kind, BlockComment)
///   assert_true(scanned.tokens.any(token => token.kind == Invalid))
///   assert_false(scanned.diagnostics.is_empty())
///   assert_eq(scanned.tokens[scanned.tokens.length() - 1].kind, Eof)
/// }
/// ```
pub fn Scan::to_source(self : Scan) -> String {
  let out = StringBuilder()
  for token in self.tokens {
    out.write_string(token.text)
  }
  out.to_string()
}

///|
pub extend TokenKind with Eq::{equal, not_equal}

///|
pub extend Token with Eq::{equal, not_equal}

///|
pub extend Scan with Eq::{equal, not_equal}

///|
pub extend TokenKind with @debug.Debug::{to_repr}

///|
pub extend Token with @debug.Debug::{to_repr}

///|
pub extend Scan with @debug.Debug::{to_repr}
