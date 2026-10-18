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
test "WAC formatting preserves comments in composition and raw quoted names" {
  let source = "/*header*/package a:b; //pkg\nlet x=new a:lib {/*arg*/ id: (host)/*access*/.f[\"raw\\q\"],...host, ...}; //tail\nexport x...;"
  let expected =
    #|/*header*/
    #|package a:b; //pkg
    #|let x = new a:lib { /*arg*/
    #|  id: (host) /*access*/.f["raw\q"],
    #|  ...host,
    #|  ...
    #|}; //tail
    #|export x...;
    #|
  assert_eq(checked(source), expected)
}

///|
test "comment-bearing groups selectors empty blocks and inline interfaces retain meaning" {
  for
    source in [
      "package a:b; import x: interface{/*inside*/}; world w { import host: interface{}; include base with {}; }",
      "package a:b; interface i {use a:b/c.{/*first*/a,//between\nb}; type t = tuple</*x*/u8,//end\nstring>;}",
      "package a:b; let x = (/*open*/ host /*close*/)[/*name*/\"multi\nline\"/*end*/]; export x;",
      "package a:b; let x = new a:b{/*inside*/}.run[\"run\"];", "package a:b; //only trailing comment\r\n",
      "package a:b; export x as \"literal /* not a comment */ \\n\";",
    ] {
    let _ = checked(source)
  }
}

///|
test "indentation options invalid syntax and disabled extensions are explicit" {
  assert_eq(
    checked("package a:b; interface i {type t = u8;}", indent_width=4),
    "package a:b;\ninterface i {\n    type t = u8;\n}\n",
  )
  assert_eq(
    checked("package a:b; interface i {type t = u8;}", indent_width=0),
    "package a:b;\ninterface i {\ntype t = u8;\n}\n",
  )
  for
    source in [
      "", "//comment", "package a:b; let x = new a:b{", "package a:b; type t = list<;",
      "\u{feff}package a:b;",
    ] {
    assert_true(@formatter.format(source) is Err(InvalidSyntax(_)))
  }
  let extended = "package a:b; type f = func() -> (a: u8);"
  assert_true(@formatter.format(extended) is Err(InvalidSyntax(_)))
  let _ = checked(extended)
  assert_eq(@formatter.format("", indent_width=9), Err(InvalidOptions))
  assert_eq(@formatter.format("", indent_width=-1), Err(InvalidOptions))
  let tree : @cst.Tree = { tokens: [], nodes: [], }
  assert_eq(@formatter.format_cst(tree), Err(InvalidTree))
}

///|
test "law: comments between WAC tokens preserve order and idempotence" {
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let tokens = [
        "package", "a:b", ";", "let", "x", "=", "new", "a:lib", "{", "name", ":",
        "(", "host", ")", ".", "run", "[", "\"raw\\q\"", "]", ",", "...", "host",
        ",", "...", "}", ";", "export", "x", "...", ";",
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
            3 => "\n/*multi\n raw*/\n"
            _ => "\r\n"
          },
        )
      }
      let source = out.to_string()
      guard @formatter.format(source) is Ok(text) else { return false }
      @formatter.format(text) == Ok(text) &&
      comments(source) == comments(text) &&
      @parser.parse(source).ast.equivalent(@parser.parse(text).ast)
    },
    count=600,
    max_size=40,
    seed=20261028,
  )
}

///|
test "deep types groups and instantiations format without recursive descent" {
  for mode in 0..<3 {
    let out = StringBuilder()
    out.write_string(
      if mode == 0 {
        "package a:b; type t = "
      } else {
        "package a:b; let x = "
      },
    )
    for _ in 0..<16000 {
      out.write_string(
        match mode {
          0 => "option< "
          1 => "( "
          _ => "new a:b { input: "
        },
      )
    }
    out.write_string(if mode == 0 { "u8" } else { "host" })
    for _ in 0..<16000 {
      out.write_string(
        match mode {
          0 => " >"
          1 => " ).run"
          _ => " }"
        },
      )
    }
    out.write_string(";")
    let _ = checked(out.to_string(), indent_width=0)
  }
}

///|
test "all 45 printable node kinds preserve typed field structure" {
  let source =
    #|package ns:app targets ns:types/app;
    #|type pending = future<u8>;
    #|type callback = async func(p: u8) -> (r: u8);
    #|import host as "host": interface { f: callback; };
    #|interface types {
    #| use host.{a as b}; resource r; record pair {a: u8}
    #| flags flags-type {a} enum enum-type {a} variant variant-type {a(u8)}
    #| type all = tuple<list<u8>,option<u8>,result<u8,string>,borrow<r>,stream>;
    #| resource file {constructor(); f: static func() -> r;}
    #|}
    #|world app { include base with {a as b}; import host; export run: func(); }
    #|let x = new ns:lib { host, ...host, ..., "a": (host).a["b"] };
    #|export x as "x";
  let original = @parser.parse(source, features=@parser.Features::all())
  assert_true(original.is_valid())
  let kinds : Array[@ast.Kind] = []
  for node in original.ast.nodes {
    if !kinds.contains(node.data.kind()) {
      kinds.push(node.data.kind())
    }
  }
  assert_eq(kinds.length(), 45)
  let _ = checked(source)
}
