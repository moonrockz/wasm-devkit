///|
test "WAC identifiers differ from WIT digit-start segments" {
  for
    name in [
      "my-name", "HTTP-request", "a0-b1", "%func", "own", "map", "get", "set",
    ] {
    let result = @scanner.scan(name)
    assert_eq(result.tokens[0].kind, Identifier)
    assert_true(result.diagnostics.is_empty())
  }
  for
    name in [
      "camelCase", "foo--bar", "foo-", "%", "%42", "FOo", "a1-2-3", "my-world-1",
    ] {
    let result = @scanner.scan(name)
    assert_eq(result.tokens[0].kind, Invalid)
    assert_eq(result.to_source(), name)
    assert_false(result.diagnostics.is_empty())
  }
}

///|
test "WAC package names and paths are atomic tokens" {
  for name in ["a:b", "%a:%type", "ns:nested:pkg@1.2.3-beta.1+Build"] {
    let result = @scanner.scan(name)
    assert_eq(result.tokens[0].kind, PackageName)
    assert_eq(result.tokens[0].text, name)
    assert_true(result.diagnostics.is_empty())
  }
  for name in ["a:b/c", "a:b/c/d@1.2.3", "ns:nested:%type/%interface"] {
    let result = @scanner.scan(name)
    assert_eq(result.tokens[0].kind, PackagePath)
    assert_eq(result.tokens[0].text, name)
    assert_true(result.diagnostics.is_empty())
  }
  let split = @scanner.scan("a /*c*/ : b")
  assert_false(split.tokens.any(t => t.kind == PackageName))
  let selector = @scanner.scan("a:b/c@1.2.3.{item}")
  assert_eq(selector.tokens[0].text, "a:b/c@1.2.3")
  assert_eq(selector.tokens[1].kind, Dot)
}

///|
test "WAC strings are raw and may span lines" {
  for source in ["\"a\\q\\n\"", "\"雪😀\"", "\"first\nsecond\""] {
    let result = @scanner.scan(source)
    assert_eq(result.tokens[0].kind, StringLiteral)
    assert_eq(result.tokens[0].text, source)
    assert_true(result.diagnostics.is_empty())
    assert_eq(result.to_source(), source)
  }
  // A backslash does not escape the next quotation mark.
  let result = @scanner.scan("\"a\\\" b")
  assert_eq(result.tokens[0].text, "\"a\\\"")
  assert_eq(result.tokens[2].text, "b")
}

///|
test "nested comments malformed literals and invalid Unicode remain lossless" {
  for
    source in [
      " /* a /* b */ c */ //😀\r\n", "/* incomplete", "\"incomplete\nlet x = y;",
      "\u{202e}", "\u{feff}", "\u{0}",
    ] {
    assert_eq(@scanner.scan(source).to_source(), source)
  }
  let emoji = "😀"
  for
    half in [
      emoji.unsafe_substring(start=0, end=1),
      emoji.unsafe_substring(start=1, end=2),
    ] {
    let result = @scanner.scan(half)
    assert_eq(result.to_source(), half)
    assert_eq(result.diagnostics[0].code, "WAC-L008")
  }
}

///|
test "law: arbitrary UTF-16 input has contiguous tokens and exact reconstruction" {
  @quickcheck.check(
    (source : String) => {
      let result = @scanner.scan(source)
      let mut offset = 0
      let mut valid = true
      for token in result.tokens {
        valid = valid &&
          token.span.start == offset &&
          token.span.length() == token.text.length()
        offset = token.span.end
      }
      valid &&
      offset == source.length() &&
      result.to_source() == source &&
      result.tokens[result.tokens.length() - 1].kind == Eof
    },
    count=600,
    max_size=128,
    seed=20261024,
  )
}

///|
test "all WAC keywords and punctuation have their documented token kinds" {
  let words = "import with type tuple list option result borrow resource variant record flags enum func static constructor u8 s8 u16 s16 u32 s32 u64 s64 f32 f64 char bool string interface world export new let use include as package targets async stream future error-context"
  for word in words.split(" ") {
    let result = @scanner.scan(word.to_owned() + " %" + word.to_owned())
    assert_eq(result.tokens[0].kind, Keyword)
    assert_eq(result.tokens[2].kind, Identifier)
    assert_true(result.diagnostics.is_empty())
  }
  let punctuation : Array[(String, @scanner.TokenKind)] = [
    ("=", Equal),
    (",", Comma),
    (":", Colon),
    (";", Semicolon),
    ("(", LParen),
    (")", RParen),
    ("{", LBrace),
    ("}", RBrace),
    ("<", LAngle),
    (">", RAngle),
    ("[", LBracket),
    ("]", RBracket),
    ("...", Ellipsis),
    ("->", Arrow),
    ("/", Slash),
    (".", Dot),
    ("@", At),
    ("_", Underscore),
  ]
  for (text, kind) in punctuation {
    let result = @scanner.scan(text)
    assert_eq(result.tokens[0].kind, kind)
    assert_eq(result.tokens[0].text, text)
    assert_eq(result.tokens[1].kind, Eof)
    assert_true(result.diagnostics.is_empty())
  }
}

///|
test "deep nested comments use an explicit depth counter" {
  let out = StringBuilder()
  for _ in 0..<30000 {
    out.write_string("/*")
  }
  out.write_string("😀")
  for _ in 0..<30000 {
    out.write_string("*/")
  }
  let source = out.to_string()
  let result = @scanner.scan(source)
  assert_true(result.diagnostics.is_empty())
  assert_eq(result.tokens[0].kind, BlockComment)
  assert_eq(result.to_source(), source)
}
