// Retained type-parser error messages from the pinned dependency.

///|
pub suberror ComponentParseError {
  UnexpectedEndOfInput
  Leb128TooLarge
  InvalidTypeSection
  InvalidUtf8
  UnsupportedTypeOpcode(Int32)
}

///|
pub fn ComponentParseError::to_string(self : ComponentParseError) -> String {
  match self {
    UnexpectedEndOfInput => "unexpected end of input"
    Leb128TooLarge => "leb128 value too large"
    InvalidTypeSection => "invalid type section"
    InvalidUtf8 => "invalid utf-8"
    UnsupportedTypeOpcode(op) => "unsupported component type opcode: \{op}"
  }
}

///|
pub impl Show for ComponentParseError with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub extend ComponentParseError with Show::{output}
