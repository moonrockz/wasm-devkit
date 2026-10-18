///|
fn unit(text : String, index : Int32) -> Int32 {
  if index >= 0 && index < text.length() {
    text.code_unit_at(index).to_int()
  } else {
    -1
  }
}

///|
fn lower(c : Int32) -> Bool {
  c >= 97 && c <= 122
}

///|
fn upper(c : Int32) -> Bool {
  c >= 65 && c <= 90
}

///|
fn digit(c : Int32) -> Bool {
  c >= 48 && c <= 57
}

///|
fn whitespace(c : Int32) -> Bool {
  c == 32 || c == 9 || c == 10 || c == 13
}

///|
fn hex(c : Int32) -> Int32? {
  if digit(c) {
    Some(c - 48)
  } else if c >= 97 && c <= 102 {
    Some(c - 97 + 10)
  } else if c >= 65 && c <= 70 {
    Some(c - 65 + 10)
  } else {
    None
  }
}

///|
/// Words have a consistent case within each hyphen-separated segment.
fn valid_identifier(text : String) -> Bool {
  let mut start = if unit(text, 0) == 37 { 1 } else { 0 }
  guard start < text.length() else { return false }
  while start < text.length() {
    let first = unit(text, start)
    let is_lower = lower(first)
    guard is_lower || upper(first) else { return false }
    let mut i = start + 1
    while i < text.length() && unit(text, i) != 45 {
      let c = unit(text, i)
      guard digit(c) || (if is_lower { lower(c) } else { upper(c) }) else {
        return false
      }
      i += 1
    }
    if i == text.length() {
      return true
    }
    start = i + 1
  }
  false
}

///|
fn keyword(text : String) -> Bool {
  match text {
    "as"
    | "async"
    | "bool"
    | "borrow"
    | "char"
    | "constructor"
    | "enum"
    | "export"
    | "f32"
    | "f64"
    | "flags"
    | "from"
    | "func"
    | "future"
    | "import"
    | "include"
    | "interface"
    | "list"
    | "map"
    | "option"
    | "own"
    | "package"
    | "record"
    | "resource"
    | "result"
    | "s16"
    | "s32"
    | "s64"
    | "s8"
    | "static"
    | "stream"
    | "string"
    | "tuple"
    | "type"
    | "u16"
    | "u32"
    | "u64"
    | "u8"
    | "use"
    | "variant"
    | "with"
    | "world" => true
    _ => false
  }
}

///|
fn forbidden(c : Int32) -> Bool {
  (c >= 0 && c < 32 && c != 9 && c != 10 && c != 13) ||
  (c >= 127 && c <= 159) ||
  (c >= 0x202a && c <= 0x202e) ||
  (c >= 0x2066 && c <= 0x2069) ||
  c == 0x149 ||
  c == 0x673 ||
  c == 0xf77 ||
  c == 0xf79 ||
  c == 0x17a3 ||
  c == 0x17a4 ||
  c == 0x17b4 ||
  c == 0x17b5
}

///|
fn report(
  diagnostics : Array[@diagnostic.Diagnostic],
  code : String,
  message : String,
  start : Int32,
  end : Int32,
  recovery~ : @diagnostic.Recovery = Continue,
) -> Unit {
  diagnostics.push(
    @diagnostic.Diagnostic::error(code, message, { start, end, }, recovery~),
  )
}

///|
/// Validate all source characters, including those inside comments and strings.
fn validate_source(
  text : String,
  diagnostics : Array[@diagnostic.Diagnostic],
) -> Unit {
  let mut i = 0
  while i < text.length() {
    let c = unit(text, i)
    if forbidden(c) {
      report(
        diagnostics,
        "WIT-L005",
        "disallowed Unicode source character",
        i,
        i + 1,
      )
    }
    if c >= 0xd800 && c <= 0xdbff {
      let next = unit(text, i + 1)
      if next >= 0xdc00 && next <= 0xdfff {
        i += 2
        continue
      }
      report(diagnostics, "WIT-L008", "unpaired UTF-16 surrogate", i, i + 1)
    } else if c >= 0xdc00 && c <= 0xdfff {
      report(diagnostics, "WIT-L008", "unpaired UTF-16 surrogate", i, i + 1)
    }
    i += 1
  }
}

///|
fn append_scalar(bytes : Array[Byte], scalar : Int32) -> Unit {
  if scalar <= 0x7f {
    bytes.push(scalar.to_byte())
  } else if scalar <= 0x7ff {
    bytes.push((0xc0 + (scalar >> 6)).to_byte())
    bytes.push((0x80 + (scalar & 0x3f)).to_byte())
  } else if scalar <= 0xffff {
    bytes.push((0xe0 + (scalar >> 12)).to_byte())
    bytes.push((0x80 + ((scalar >> 6) & 0x3f)).to_byte())
    bytes.push((0x80 + (scalar & 0x3f)).to_byte())
  } else {
    bytes.push((0xf0 + (scalar >> 18)).to_byte())
    bytes.push((0x80 + ((scalar >> 12) & 0x3f)).to_byte())
    bytes.push((0x80 + ((scalar >> 6) & 0x3f)).to_byte())
    bytes.push((0x80 + (scalar & 0x3f)).to_byte())
  }
}

///|
fn append_utf8(
  bytes : Array[Byte],
  text : String,
  start : Int32,
  end : Int32,
) -> Unit {
  let mut i = start
  while i < end {
    let c = unit(text, i)
    let next = if i + 1 < end { unit(text, i + 1) } else { -1 }
    if c >= 0xd800 && c <= 0xdbff && next >= 0xdc00 && next <= 0xdfff {
      append_scalar(bytes, 0x10000 + ((c - 0xd800) << 10) + next - 0xdc00)
      i += 2
    } else {
      // validate_source already diagnosed unpaired surrogates. Avoid passing
      // invalid Char values into runtime encoders during recovery.
      append_scalar(bytes, if c >= 0xd800 && c <= 0xdfff { 0xfffd } else { c })
      i += 1
    }
  }
}

///|
/// Scan a Core WebAssembly name literal. Recover an unclosed literal at a raw
/// newline, so subsequent declarations remain visible to the parser.
fn string_literal(
  text : String,
  start : Int32,
  diagnostics : Array[@diagnostic.Diagnostic],
) -> Int32 {
  let bytes : Array[Byte] = []
  let mut i = start + 1
  let mut run_start = i
  let mut valid = true
  while i < text.length() {
    let c = unit(text, i)
    if c == 34 {
      append_utf8(bytes, text, run_start, i)
      if valid {
        ignore(@utf8.decode(Bytes::from_array(bytes))) catch {
          _ =>
            report(
              diagnostics,
              "WIT-L007",
              "string name is not valid UTF-8",
              start,
              i + 1,
            )
        }
      }
      return i + 1
    }
    if c == 10 || c == 13 {
      break
    }
    if c == 92 {
      append_utf8(bytes, text, run_start, i)
      let escape_start = i
      i += 1
      let escape = unit(text, i)
      match escape {
        116 => {
          bytes.push(9)
          i += 1
        }
        110 => {
          bytes.push(10)
          i += 1
        }
        114 => {
          bytes.push(13)
          i += 1
        }
        34 | 39 | 92 => {
          bytes.push(escape.to_byte())
          i += 1
        }
        117 if unit(text, i + 1) == 123 => {
          i += 2
          let mut scalar = 0
          let mut previous_digit = false
          let mut escape_valid = true
          while i < text.length() {
            let c = unit(text, i)
            if hex(c) is Some(value) {
              if scalar <= 0x10ffff {
                scalar = scalar * 16 + value
              }
              previous_digit = true
            } else if c == 95 {
              if !previous_digit {
                escape_valid = false
              }
              previous_digit = false
            } else {
              break
            }
            i += 1
          }
          if unit(text, i) == 125 {
            i += 1
          } else {
            escape_valid = false
          }
          if !previous_digit ||
            scalar > 0x10ffff ||
            (scalar >= 0xd800 && scalar <= 0xdfff) {
            escape_valid = false
          }
          if escape_valid {
            append_scalar(bytes, scalar)
          } else {
            valid = false
            report(
              diagnostics, "WIT-L006", "invalid Unicode string escape", escape_start,
              i,
            )
          }
        }
        _ =>
          if hex(escape) is Some(hi) && hex(unit(text, i + 1)) is Some(lo) {
            bytes.push((hi * 16 + lo).to_byte())
            i += 2
          } else {
            // Do not consume a newline: it is the recovery boundary.
            if escape >= 0 && escape != 10 && escape != 13 {
              i += 1
            }
            valid = false
            report(
              diagnostics, "WIT-L006", "invalid string escape", escape_start, i,
            )
          }
      }
      run_start = i
      continue
    }
    if c < 32 || c == 127 {
      valid = false
      report(
        diagnostics,
        "WIT-L006",
        "control character must be escaped in a string",
        i,
        i + 1,
      )
    }
    i += 1
  }
  report(
    diagnostics,
    "WIT-L004",
    "unterminated string literal",
    start,
    i,
    recovery=if i == text.length() { EndOfInput } else { Continue },
  )
  i
}

///|
/// Total, lossless lexical analysis. Error tokens retain their original spelling.
/// Diagnostics are ordered by source position, with deterministic ties.
/// This function performs no I/O and uses no input-dependent recursion.
pub fn scan(text : String) -> Scan {
  let tokens = []
  let diagnostics = []
  validate_source(text, diagnostics)
  let mut i = 0
  while i < text.length() {
    let start = i
    let c = unit(text, i)
    let kind = if whitespace(c) {
      i += 1
      while whitespace(unit(text, i)) {
        i += 1
      }
      Whitespace
    } else if c == 47 && unit(text, i + 1) == 47 {
      i += 2
      while i < text.length() && unit(text, i) != 10 {
        i += 1
      }
      LineComment
    } else if c == 47 && unit(text, i + 1) == 42 {
      i += 2
      let mut depth = 1
      while i < text.length() && depth > 0 {
        if unit(text, i) == 47 && unit(text, i + 1) == 42 {
          depth += 1
          i += 2
        } else if unit(text, i) == 42 && unit(text, i + 1) == 47 {
          depth -= 1
          i += 2
        } else {
          i += 1
        }
      }
      if depth > 0 {
        report(
          diagnostics,
          "WIT-L003",
          "unterminated block comment",
          start,
          i,
          recovery=EndOfInput,
        )
      }
      BlockComment
    } else if c == 34 {
      i = string_literal(text, start, diagnostics)
      StringLiteral
    } else if lower(c) || upper(c) || c == 37 {
      i += 1
      while lower(unit(text, i)) ||
            upper(unit(text, i)) ||
            digit(unit(text, i)) ||
            unit(text, i) == 45 {
        if unit(text, i) == 45 && unit(text, i + 1) == 62 {
          break
        }
        i += 1
      }
      let spelling = text.unsafe_substring(start~, end=i)
      if !valid_identifier(spelling) {
        report(
          diagnostics,
          "WIT-L002",
          "invalid kebab-case identifier",
          start,
          i,
          recovery=SkipToken,
        )
        Invalid
      } else if keyword(spelling) {
        Keyword
      } else {
        Identifier
      }
    } else if digit(c) {
      i += 1
      while digit(unit(text, i)) {
        i += 1
      }
      if unit(text, i) == 46 && digit(unit(text, i + 1)) {
        // Semantic versions allow mixed case, numeric and hyphenated labels
        // that are not WIT identifiers. Keep the candidate intact so the parser
        // can validate SemVer without spurious identifier diagnostics.
        while digit(unit(text, i)) ||
              lower(unit(text, i)) ||
              upper(unit(text, i)) ||
              unit(text, i) == 46 ||
              unit(text, i) == 45 ||
              unit(text, i) == 43 {
          // The dot before use-path .{names} is not part of a version.
          let next = unit(text, i + 1)
          if unit(text, i) == 46 &&
            !(digit(next) || lower(next) || upper(next) || next == 45) {
            break
          }
          i += 1
        }
        Version
      } else {
        Integer
      }
    } else if c == 45 && unit(text, i + 1) == 62 {
      i += 2
      Arrow
    } else {
      i += 1
      match c {
        61 => Equal
        44 => Comma
        58 => Colon
        59 => Semicolon
        40 => LParen
        41 => RParen
        123 => LBrace
        125 => RBrace
        60 => LAngle
        62 => RAngle
        42 => Star
        47 => Slash
        46 => Dot
        64 => At
        45 => Minus
        43 => Plus
        95 => Underscore
        _ => {
          let next = unit(text, i)
          if c >= 0xd800 && c <= 0xdbff && next >= 0xdc00 && next <= 0xdfff {
            i += 1
          }
          if !forbidden(c) && !(c >= 0xd800 && c <= 0xdfff && i == start + 1) {
            report(
              diagnostics,
              "WIT-L001",
              "unexpected source character",
              start,
              i,
              recovery=SkipToken,
            )
          }
          Invalid
        }
      }
    }
    tokens.push({
      kind,
      text: text.unsafe_substring(start~, end=i),
      span: { start, end: i, },
    })
  }
  tokens.push({ kind: Eof, text: "", span: { start: i, end: i, }, })
  diagnostics.sort_by(fn(a, b) {
    let order = a.primary.span.start.compare(b.primary.span.start)
    if order == 0 {
      a.code.compare(b.code)
    } else {
      order
    }
  })
  {
    tokens: ReadOnlyArray::from_array(tokens),
    diagnostics: ReadOnlyArray::from_array(diagnostics),
  }
}
