///|
fn roundtrip(source : String, indent_width~ : Int32 = 2) -> String raise {
  let original = @parser.parse(source, features=@parser.Features::all())
  assert_true(original.is_valid())
  let printed = @printer.print(original.ast, indent_width~).unwrap()
  let parsed = @parser.parse(printed, features=@parser.Features::all())
  assert_true(parsed.is_valid())
  assert_true(original.ast.equivalent(parsed.ast))
  assert_eq(@printer.print(parsed.ast, indent_width~).unwrap(), printed)
  printed
}

///|
test "canonical WAC declarations and composition layout" {
  let source = "package a:b;interface i{record pair{x: u8,y: list<option<string>>} f: func(p: pair)->result<_,string>;}world w{import i;export run: func();}let x=new a:lib {arg: (host).f[\"run\"],...host,...};export x...;"
  let expected =
    #|package a:b;
    #|interface i {
    #|  record pair {
    #|    x: u8,
    #|    y: list<option<string>>
    #|  }
    #|  f: func(p: pair) -> result<_, string>;
    #|}
    #|world w {
    #|  import i;
    #|  export run: func();
    #|}
    #|let x = new a:lib {
    #|  arg: (host).f["run"],
    #|  ...host,
    #|  ...
    #|};
    #|export x...;
    #|
  assert_eq(roundtrip(source), expected)
}

///|
test "raw quoted names percent identifiers and path keys retain spelling" {
  let _ = roundtrip(
    "package %a:%type; import %import as \"raw\\n\": interface {}; let %let = new %a:%type { %new: (%import)[\"raw\\n\"] }; export %let.%func as %as;",
  )
  let _ = roundtrip(
    "package a:b; import x as \"multi\nline\": func(); export (x) as \"雪😀\";",
  )
}

///|
test "invalid arenas recovery nodes and unrepresentable strings return errors" {
  let empty : @ast.Tree = { nodes: [], }
  assert_eq(@printer.print(empty), Err(InvalidTree))
  let primitive : @ast.Tree = {
    nodes: [{ data: PrimitiveType(name="u8"), span: { start: 0, end: 0, }, }],
  }
  assert_eq(@printer.print(primitive), Err(InvalidRoot))
  assert_true(
    @printer.print(@parser.parse("package a:b; ???;").ast)
    is Err(RecoveryNode(_)),
  )
  let original = @parser.parse("package a:b; export x as \"good\";")
  let nodes = original.ast.nodes.map(n => {
    match n.data {
      Name(..) => { ..n, data: Name(value="cannot\"quote", quoted=true), }
      _ => n
    }
  })
  let invalid : @ast.Tree = { nodes, }
  assert_true(invalid.validate())
  assert_eq(@printer.print(invalid), Err(Unrepresentable))
  assert_eq(@printer.print(original.ast, indent_width=9), Err(InvalidOptions))
  assert_eq(@printer.print(original.ast, indent_width=-1), Err(InvalidOptions))
}

///|
test "law: generated expression nesting and access chains preserve AST precedence" {
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let out = StringBuilder()
      out.write_string("package a:b; let x = ")
      for b in choices {
        out.write_string(
          if b.to_int() % 2 == 0 {
            "("
          } else {
            "new a:b { input: "
          },
        )
      }
      out.write_string("host")
      for b in choices.rev_iter() {
        out.write_string(
          if b.to_int() % 2 == 0 {
            ").run[\"raw\\q\"]"
          } else {
            "}.run"
          },
        )
      }
      out.write_string("; export x...;")
      let original = @parser.parse(out.to_string())
      guard original.is_valid() else { return false }
      let width = choices.length() % 3
      guard @printer.print(original.ast, indent_width=width) is Ok(text) else {
        return false
      }
      let next = @parser.parse(text)
      next.is_valid() &&
      original.ast.equivalent(next.ast) &&
      @printer.print(next.ast, indent_width=width) == Ok(text)
    },
    count=400,
    max_size=64,
    seed=20261027,
  )
}

///|
test "deep type group and instantiation printing uses heap commands" {
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
          0 => "option<"
          1 => "("
          _ => "new a:b { input: "
        },
      )
    }
    out.write_string(if mode == 0 { "u8" } else { "host" })
    for _ in 0..<16000 {
      out.write_string(
        match mode {
          0 => ">"
          1 => ").run"
          _ => "}"
        },
      )
    }
    out.write_string(";")
    let _ = roundtrip(out.to_string(), indent_width=0)
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
  let _ = roundtrip(source)
}
