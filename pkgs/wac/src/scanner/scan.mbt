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
        "WAC-L005",
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
      report(diagnostics, "WAC-L008", "unpaired UTF-16 surrogate", i, i + 1)
    } else if c >= 0xdc00 && c <= 0xdfff {
      report(diagnostics, "WAC-L008", "unpaired UTF-16 surrogate", i, i + 1)
    }
    i += 1
  }
}

///|
fn word_end(text : String, start : Int32) -> Int32 {
  let mut at = start
  if unit(text, at) == 37 {
    at += 1
  }
  while lower(unit(text, at)) ||
        upper(unit(text, at)) ||
        digit(unit(text, at)) ||
        unit(text, at) == 45 {
    at += 1
  }
  at
}

///|
fn valid_identifier(text : String) -> Bool {
  let mut start = if unit(text, 0) == 37 { 1 } else { 0 }
  while start < text.length() {
    let first = unit(text, start)
    guard lower(first) || upper(first) else { return false }
    let is_lower = lower(first)
    let mut at = start + 1
    while at < text.length() && unit(text, at) != 45 {
      let c = unit(text, at)
      guard digit(c) || (if is_lower { lower(c) } else { upper(c) }) else {
        return false
      }
      at += 1
    }
    if at == text.length() {
      return true
    }
    start = at + 1
  }
  false
}

///|
fn keyword(text : String) -> Bool {
  match text {
    "import"
    | "with"
    | "type"
    | "tuple"
    | "list"
    | "option"
    | "result"
    | "borrow"
    | "resource"
    | "variant"
    | "record"
    | "flags"
    | "enum"
    | "func"
    | "static"
    | "constructor"
    | "u8"
    | "s8"
    | "u16"
    | "s16"
    | "u32"
    | "s32"
    | "u64"
    | "s64"
    | "f32"
    | "f64"
    | "char"
    | "bool"
    | "string"
    | "interface"
    | "world"
    | "export"
    | "new"
    | "let"
    | "use"
    | "include"
    | "as"
    | "package"
    | "targets"
    | "async"
    | "stream"
    | "future"
    | "error-context" => true
    _ => false
  }
}

///|
fn version_char(c : Int32) -> Bool {
  digit(c) || lower(c) || upper(c) || c == 45 || c == 43
}

///|
fn package_end(text : String, first_end : Int32) -> (Int32, Bool) {
  let mut at = first_end
  let mut names = 0
  while unit(text, at) == 58 {
    let end = word_end(text, at + 1)
    if end <= at + 1 ||
      !valid_identifier(text.unsafe_substring(start=at + 1, end~)) {
      break
    }
    names += 1
    at = end
  }
  if names == 0 {
    return (first_end, false)
  }
  let mut path = false
  while unit(text, at) == 47 {
    let end = word_end(text, at + 1)
    if end <= at + 1 ||
      !valid_identifier(text.unsafe_substring(start=at + 1, end~)) {
      break
    }
    path = true
    at = end
  }
  if unit(text, at) == 64 && digit(unit(text, at + 1)) {
    at += 1
    while digit(unit(text, at)) {
      at += 1
    }
    while unit(text, at) == 46 && version_char(unit(text, at + 1)) {
      at += 1
      while version_char(unit(text, at)) {
        at += 1
      }
    }
  }
  (at, path)
}

///|
pub fn scan(text : String) -> Scan {
  let tokens = []
  let diagnostics = []
  validate_source(text, diagnostics)
  let mut at = 0
  while at < text.length() {
    let start = at
    let c = unit(text, at)
    let kind = if whitespace(c) || c == 12 {
      at += 1
      while whitespace(unit(text, at)) || unit(text, at) == 12 {
        at += 1
      }
      Whitespace
    } else if c == 47 && unit(text, at + 1) == 47 {
      at += 2
      while at < text.length() && unit(text, at) != 10 {
        at += 1
      }
      LineComment
    } else if c == 47 && unit(text, at + 1) == 42 {
      at += 2
      let mut depth = 1
      while at < text.length() && depth > 0 {
        if unit(text, at) == 47 && unit(text, at + 1) == 42 {
          depth += 1
          at += 2
        } else if unit(text, at) == 42 && unit(text, at + 1) == 47 {
          depth -= 1
          at += 2
        } else {
          at += 1
        }
      }
      if depth > 0 {
        report(
          diagnostics,
          "WAC-L003",
          "unterminated block comment",
          start,
          at,
          recovery=EndOfInput,
        )
      }
      BlockComment
    } else if c == 34 {
      at += 1
      let mut newline = None
      while at < text.length() && unit(text, at) != 34 {
        if newline is None && (unit(text, at) == 10 || unit(text, at) == 13) {
          newline = Some(at)
        }
        at += 1
      }
      if at < text.length() {
        at += 1
      } else {
        at = newline.unwrap_or(at)
        report(
          diagnostics,
          "WAC-L004",
          "unterminated string",
          start,
          at,
          recovery=if at == text.length() { EndOfInput } else { Continue },
        )
      }
      StringLiteral
    } else if lower(c) || upper(c) || c == 37 {
      at = word_end(text, start)
      let spelling = text.unsafe_substring(start~, end=at)
      if !valid_identifier(spelling) {
        report(
          diagnostics,
          "WAC-L002",
          "invalid kebab-case identifier",
          start,
          at,
          recovery=SkipToken,
        )
        Invalid
      } else {
        let (end, path) = package_end(text, at)
        if end > at {
          at = end
          if path {
            PackagePath
          } else {
            PackageName
          }
        } else if keyword(spelling) {
          Keyword
        } else {
          Identifier
        }
      }
    } else if c == 45 && unit(text, at + 1) == 62 {
      at += 2
      Arrow
    } else if c == 46 && unit(text, at + 1) == 46 && unit(text, at + 2) == 46 {
      at += 3
      Ellipsis
    } else {
      at += 1
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
        91 => LBracket
        93 => RBracket
        47 => Slash
        46 => Dot
        64 => At
        95 => Underscore
        _ => {
          let next = unit(text, at)
          if c >= 0xd800 && c <= 0xdbff && next >= 0xdc00 && next <= 0xdfff {
            at += 1
          }
          if !forbidden(c) && !(c >= 0xd800 && c <= 0xdfff && at == start + 1) {
            report(
              diagnostics,
              "WAC-L001",
              "unexpected source character",
              start,
              at,
              recovery=SkipToken,
            )
          }
          Invalid
        }
      }
    }
    tokens.push({
      kind,
      text: text.unsafe_substring(start~, end=at),
      span: { start, end: at, },
    })
  }
  tokens.push({ kind: Eof, text: "", span: { start: at, end: at, }, })
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
