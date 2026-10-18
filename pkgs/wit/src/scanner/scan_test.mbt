///|
test "all pinned grammar keywords are reserved and percent escapes are identifiers" {
  let words = "as async bool borrow char constructor enum export f32 f64 flags from func future import include interface list map option own package record resource result s16 s32 s64 s8 static stream string tuple type u16 u32 u64 u8 use variant with world"
  for word in words.split(" ") {
    let word = word.to_owned()
    let result = @scanner.scan(word + " %" + word)
    assert_eq(result.tokens[0].kind, Keyword)
    assert_eq(result.tokens[2].kind, Identifier)
    assert_true(result.diagnostics.is_empty())
  }
  for
    spelling in [
      "my-name", "HTTP", "HTTP-request", "%interface", "a0-b1", "FOO-BAR", "a1-2-3",
      "A1-2-3", "A11-4CR0NYMS", "m1x3d-4CR0NYMS", "my-world-1",
    ] {
    assert_eq(@scanner.scan(spelling).tokens[0].kind, Identifier)
    assert_true(@scanner.scan(spelling).diagnostics.is_empty())
  }
  for spelling in ["camelCase", "foo--bar", "foo-", "%", "%42", "FOo"] {
    let result = @scanner.scan(spelling)
    assert_eq(result.tokens[0].kind, Invalid)
    assert_eq(result.diagnostics[0].code, "WIT-L002")
    assert_eq(result.to_source(), spelling)
  }
}

///|
test "operators are distinct and arrow uses longest match" {
  let cases : Array[(String, @scanner.TokenKind)] = [
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
    ("*", Star),
    ("->", Arrow),
    ("/", Slash),
    (".", Dot),
    ("@", At),
    ("-", Minus),
    ("+", Plus),
    ("_", Underscore),
  ]
  for (spelling, kind) in cases {
    let result = @scanner.scan(spelling)
    assert_eq(result.tokens[0].kind, kind)
    assert_eq(result.tokens[0].text, spelling)
    assert_eq(result.tokens[0].span.length(), spelling.length())
    assert_eq(result.tokens[1].kind, Eof)
    assert_true(result.diagnostics.is_empty())
  }
  let result = @scanner.scan("name->list<u8>")
  assert_eq(result.tokens[0].kind, Identifier)
  assert_eq(result.tokens[1].kind, Arrow)
  assert_true(result.diagnostics.is_empty())
}

///|
test "version candidates preserve SemVer labels outside the identifier grammar" {
  for
    version in ["1.0.0", "0.1.0-alphaX-1.1+Build-5", "1.2.3-0+99", "1.2.3-a--b"] {
    let source = "package example:demo@" + version + ";"
    let result = @scanner.scan(source)
    assert_true(result.diagnostics.is_empty())
    assert_true(result.tokens.any(t => t.kind == Version && t.text == version))
    assert_eq(result.to_source(), source)
  }
  for
    source in [
      "use foo:bar/baz@1.2.3.{name};", "use foo:bar/baz@1.2.3./*comment*/{name};",
    ] {
    let result = @scanner.scan(source)
    assert_true(result.diagnostics.is_empty())
    assert_true(result.tokens.any(t => t.kind == Version && t.text == "1.2.3"))
    assert_true(result.tokens.any(t => t.kind == Dot))
    assert_eq(result.to_source(), source)
  }
  // Semantic validity is deferred. The lexical candidate is retained whole.
  assert_eq(@scanner.scan("01.2.3+").tokens[0].kind, Version)
  assert_eq(@scanner.scan("42").tokens[0].kind, Integer)
}

///|
test "comments retain delimiters, CR, Unicode and nested content" {
  let text = " \t\r\n// 😀\r\n/*outer /* inner */ 雪 */interface"
  let result = @scanner.scan(text)
  assert_eq(result.to_source(), text)
  assert_eq(result.tokens[0].kind, Whitespace)
  assert_eq(result.tokens[1].text, "// 😀\r")
  assert_eq(result.tokens[1].kind, LineComment)
  assert_eq(result.tokens[3].kind, BlockComment)
  assert_eq(result.tokens[4].text, "interface")
  assert_true(result.diagnostics.is_empty())
  let bad = @scanner.scan("/* outer /* inner */")
  assert_eq(bad.diagnostics[0].code, "WIT-L003")
  assert_eq(bad.diagnostics[0].recovery, @diagnostic.EndOfInput)
  assert_eq(bad.tokens[0].kind, BlockComment)
  assert_eq(bad.to_source(), "/* outer /* inner */")
}

///|
test "Core WebAssembly name escapes and UTF-8 byte sequences" {
  for
    text in [
      "\"\"", "\"☃︎😀\"", "\"\\7f\"", "\"\\u{7fff}\"", "\"\\u{1_f600}\"", "\"\\t\\n\\r\\\"\\'\\\\\"",
      "\"\\e2\\98\\83\"", "\"\\u{00000000000061}\"", "\"\\u{7f}\\u{80}\\u{7ff}\\u{800}\\u{ffff}\\u{10000}\\u{10ffff}\"",
    ] {
    let result = @scanner.scan(text)
    assert_eq(result.tokens[0].kind, StringLiteral)
    assert_eq(result.to_source(), text)
    assert_true(result.diagnostics.is_empty())
  }
  for
    text in [
      "\"\\q\"", "\"\\u{}\"", "\"\\u{_1}\"", "\"\\u{1_}\"", "\"\\u{1__2}\"", "\"\\u{d800}\"",
      "\"\\u{110000}\"", "\"\\u{fffffffffffffffff}\"", "\"\t\"", "\"\\a\"",
    ] {
    let result = @scanner.scan(text)
    assert_eq(result.diagnostics[0].code, "WIT-L006")
    assert_eq(result.to_source(), text)
  }
  for text in ["\"\\ff\"", "\"\\c0\\80\"", "\"\\ed\\a0\\80\"", "\"\\e2x\""] {
    assert_eq(@scanner.scan(text).diagnostics[0].code, "WIT-L007")
  }
}

///|
test "unterminated strings recover before subsequent declarations" {
  for
    text in [
      "\"bad\ninterface ok {}", "\"bad\\\ninterface ok {}", "\"bad\rinterface ok {}",
    ] {
    let result = @scanner.scan(text)
    assert_eq(result.to_source(), text)
    assert_true(result.diagnostics.any(d => d.code == "WIT-L004"))
    assert_true(
      result.tokens.any(t => t.kind == Keyword && t.text == "interface"),
    )
  }
  for text in ["\"", "\"text\\", "\"\\u{123"] {
    let result = @scanner.scan(text)
    assert_eq(result.to_source(), text)
    assert_true(
      result.diagnostics.any(d => {
        d.code == "WIT-L004" && d.recovery == @diagnostic.EndOfInput
      }),
    )
  }
}

///|
test "forbidden codepoints are diagnosed even inside trivia" {
  for
    c in [
      0, 11, 12, 127, 159, 0x202a, 0x202e, 0x2066, 0x2069, 0x149, 0x673, 0xf77, 0xf79,
      0x17a3, 0x17a4, 0x17b4, 0x17b5,
    ] {
    for (prefix, suffix) in [("", ""), ("/*", "*/"), ("//", "\n"), ("\"", "\"")] {
      let text = prefix + c.unsafe_to_char().to_string() + suffix
      let result = @scanner.scan(text)
      assert_true(result.diagnostics.any(d => d.code == "WIT-L005"))
      assert_eq(result.to_source(), text)
    }
  }
  let result = @scanner.scan("// 😀\n😀")
  assert_eq(result.diagnostics.length(), 1)
  assert_eq(result.diagnostics[0].primary.span, { start: 6, end: 8, })
  assert_eq(result.diagnostics[0].code, "WIT-L001")
}

///|
test "scan collections own snapshots of caller data" {
  let original = @scanner.scan("interface example {}")
  let tokens = original.tokens.iter().to_array()
  let diagnostics : Array[@diagnostic.Diagnostic] = []
  let owned : @scanner.Scan = {
    tokens: ReadOnlyArray::from_array(tokens),
    diagnostics: ReadOnlyArray::from_array(diagnostics),
  }
  tokens[0] = { kind: Invalid, text: "broken", span: { start: 0, end: 6, }, }
  diagnostics.push(
    @diagnostic.Diagnostic::error("test", "test", { start: 0, end: 0, }),
  )
  assert_eq(owned.to_source(), "interface example {}")
  assert_true(owned.diagnostics.is_empty())
  assert_eq(original.to_source(), owned.to_source())
}

///|
test "nested block comments use constant call stack space" {
  let text = StringBuilder()
  for _ in 0..<30000 {
    text.write_string("/*")
  }
  text.write_string("😀")
  for _ in 0..<30000 {
    text.write_string("*/")
  }
  let text = text.to_string()
  let result = @scanner.scan(text)
  assert_eq(result.tokens.length(), 2)
  assert_eq(result.tokens[0].kind, BlockComment)
  assert_true(result.diagnostics.is_empty())
  assert_eq(result.to_source(), text)
}

///|
test "unpaired UTF-16 surrogates remain lossless and are diagnosed" {
  let emoji = "😀"
  for
    half in [
      emoji.unsafe_substring(start=0, end=1),
      emoji.unsafe_substring(start=1, end=2),
    ] {
    for (before, after) in [("", ""), ("//", "\n"), ("/*", "*/"), ("\"", "\"")] {
      let text = before + half + after
      let result = @scanner.scan(text)
      assert_eq(result.to_source(), text)
      assert_true(result.diagnostics.any(d => d.code == "WIT-L008"))
    }
  }
}

///|
test "reference error-context keyword and percent escape are distinct" {
  let tokens = @scanner.scan("error-context %error-context").tokens
  assert_eq(tokens[0].kind, Keyword)
  assert_eq(tokens[2].kind, Identifier)
}
