///|
fn laws(text : String) -> Bool {
  let result = @scanner.scan(text)
  guard result.to_source() == text && result == @scanner.scan(text) else {
    return false
  }
  let source = @span.Source::new(text)
  let mut offset = 0
  let mut eof_count = 0
  for i, token in result.tokens {
    guard token.span.start == offset &&
      source.slice(token.span) == Some(token.text) else {
      return false
    }
    if token.kind == Eof {
      eof_count += 1
      guard i == result.tokens.length() - 1 &&
        token.text == "" &&
        token.span.length() == 0 else {
        return false
      }
    } else if token.span.length() <= 0 {
      return false
    }
    offset = token.span.end
  }
  let mut last_start = 0
  for diagnostic in result.diagnostics {
    guard source.span().contains(diagnostic.primary.span) &&
      diagnostic.primary.span.start >= last_start &&
      diagnostic.primary.span.length() > 0 &&
      diagnostic.severity == @diagnostic.Error else {
      return false
    }
    last_start = diagnostic.primary.span.start
  }
  offset == text.length() && eof_count == 1
}

///|
test "law: arbitrary Unicode text is lossless, total, deterministic and span-correct" {
  @quickcheck.check(
    (text : String) => laws(text),
    count=1000,
    max_size=256,
    seed=20261018,
  )
}

///|
test "law: malformed lexical fragments tile input and retain every code unit" {
  let fragments = [
    "/*", "*/", "//", "\n", "\r", "\t", "\"", "\\", "\\u{", "\\ff", "interface",
    "%", "BadName", "foo--bar", "42", "-", "->", "_", "@", "😀", "雪", "\u202e",
    "\u0000", "{", "}", "<", ">", ":", ";", " ", "u32", "as",
  ]
  @quickcheck.check(
    (picks : Array[Byte]) => {
      let text = StringBuilder()
      for pick in picks {
        text.write_string(fragments[pick.to_int() % fragments.length()])
      }
      laws(text.to_string())
    },
    count=1000,
    max_size=256,
    seed=943464,
  )
}

///|
test "law: every UTF-16 position agrees with a linear line count" {
  @quickcheck.check(
    (picks : Array[Byte]) => {
      let pieces = ["\n", "\r\n", "\r", "😀", "雪", "a"]
      let out = StringBuilder()
      for pick in picks {
        out.write_string(pieces[pick.to_int() % pieces.length()])
      }
      let text = out.to_string()
      let source = @span.Source::new(text)
      let mut line = 0
      let mut column = 0
      for i in 0..<=text.length() {
        guard source.position(i) == Some({ line, column, }) else {
          return false
        }
        if i < text.length() && text.code_unit_at(i).to_int() == 10 {
          line += 1
          column = 0
        } else {
          column += 1
        }
      }
      source.line_count() == line + 1
    },
    count=400,
    max_size=128,
    seed=20261019,
  )
}
