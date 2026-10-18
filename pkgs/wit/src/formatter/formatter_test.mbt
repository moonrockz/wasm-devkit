///|
fn comments(text : String) -> Array[String] {
  @scanner.scan(text).tokens
  .iter()
  .filter(t => t.kind == LineComment || t.kind == BlockComment)
  .map(t => t.text)
  .to_array()
}

///|
fn checked(source : String, indent_width~ : Int32 = 2) -> String raise {
  let original = @parser.parse(source, features=@parser.Features::all())
  assert_true(original.is_valid())
  let formatted = @formatter.format(
    source,
    indent_width~,
    features=@parser.Features::all(),
  ).unwrap()
  assert_eq(
    @formatter.format(
      formatted,
      indent_width~,
      features=@parser.Features::all(),
    ),
    Ok(formatted),
  )
  let parsed = @parser.parse(formatted, features=@parser.Features::all())
  assert_true(parsed.is_valid())
  assert_true(original.ast.equivalent(parsed.ast))
  assert_eq(comments(formatted), comments(source))
  if source.has_prefix("\ufeff") {
    assert_true(formatted.has_prefix("\ufeff"))
  }
  assert_eq(
    @formatter.format_cst(
      original.cst,
      indent_width~,
      features=@parser.Features::all(),
    ),
    Ok(formatted),
  )
  assert_eq(original.cst.to_source(), source)
  formatted
}

///|
test "formatter changes layout and retains trailing and leading comments" {
  let source = "/*header*/package a:b; //pkg\ninterface i{type t=list< u8 >;/*tail*/\n// next\nf:func(x:t)->result<_,string>;}"
  let expected =
    #|/*header*/
    #|package a:b; //pkg
    #|interface i {
    #|  type t = list<u8>; /*tail*/
    #|  // next
    #|  f: func(x: t) -> result<_, string>;
    #|}
    #|
  assert_eq(checked(source), expected)
}

///|
test "empty blocks and comment-bearing selectors and blocks retain meaning" {
  for
    source in [
      "interface i{} world w {import x: interface{} include y with{};}", "interface i{/*inside*/} world w {// inside\n}",
      "interface i { use x.{/*first*/a,//between\nb}; type t=tuple</*x*/u8,// end\nstring>; }",
      "interface i { type t=/*one\n two*/list< /* nested /* comment */ */ u8>; }",
      "\ufeff//header\r\ninterface i { f:func(); //tail\r\n}", "//only comment",
      "/*only\ncomment*/", "", " \n \t ",
    ] {
    let _ = checked(source)
  }
}

///|
test "qualified and named import colon layout preserves disambiguation" {
  let formatted = checked(
    "world w { import n:p/i; import a: n:p/i; import b : local; } interface local {}",
  )
  assert_true(formatted.contains("import n:p/i;"))
  assert_true(formatted.contains("import a: n:p/i;"))
  assert_true(formatted.contains("import b: local;"))
}

///|
test "indentation is configurable and malformed input is rejected without repair" {
  assert_eq(
    checked("interface i { type t=u8; }", indent_width=4),
    "interface i {\n    type t = u8;\n}\n",
  )
  assert_eq(
    checked("interface i { type t=u8; }", indent_width=0),
    "interface i {\ntype t = u8;\n}\n",
  )
  for
    source in [
      "interface i { type t = list<; }", "/*unclosed", "interface i { f: func( }",
    ] {
    assert_true(@formatter.format(source) is Err(InvalidSyntax(_)))
  }
  assert_eq(@formatter.format("", indent_width=9), Err(InvalidOptions))
  let tree : @cst.Tree = { tokens: [], nodes: [], }
  assert_eq(@formatter.format_cst(tree), Err(InvalidTree))
}

///|
test "law: comment insertion remains idempotent and preserves token order" {
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let tokens = [
        "interface", "i", "{", "type", "t", "=", "tuple", "<", "u8", ",", "list",
        "<", "string", ">", ">", ";", "}",
      ]
      let out = StringBuilder()
      for i, token in tokens {
        out.write_string(token)
        let b = choices.get(i).map(b => b.to_int()).unwrap_or(0)
        out.write_string(
          match b % 5 {
            0 => " "
            1 => " /*block*/ "
            2 => " //line\n"
            3 => "\n/*multiline\n raw*/\n"
            _ => "\r\n"
          },
        )
      }
      let source = out.to_string()
      guard @formatter.format(source) is Ok(text) else { return false }
      @formatter.format(text) == Ok(text) &&
      comments(text) == comments(source) &&
      @parser.parse(source).ast.equivalent(@parser.parse(text).ast)
    },
    count=600,
    max_size=32,
    seed=20261026,
  )
}

///|
test "deep type formatting uses explicit delimiter and grammar stacks" {
  let out = StringBuilder()
  out.write_string("interface i { type t = ")
  for _ in 0..<18000 {
    out.write_string("option< ")
  }
  out.write_string("u8")
  for _ in 0..<18000 {
    out.write_string(" >")
  }
  out.write_string("; }")
  let _ = checked(out.to_string())
}

///|
test "deep nested package block formatting is idempotent" {
  let out = StringBuilder()
  for _ in 0..<1200 {
    out.write_string("package n:p { ")
  }
  out.write_string("interface leaf {}")
  for _ in 0..<1200 {
    out.write_string(" }")
  }
  let _ = checked(out.to_string())
}

///|
test "byte-order-only input and comments around path separators remain stable" {
  for
    source in [
      "\ufeff", "\ufeff \r\n ", "interface i {use n:/*namespace*/p/i@1.2.3.{a};} world w {import label: /*target*/ n:p/i;}",
      "world w {include i with {/*rename*/a as b}//after\n;}",
    ] {
    let _ = checked(source)
  }
}
