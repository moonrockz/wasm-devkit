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
