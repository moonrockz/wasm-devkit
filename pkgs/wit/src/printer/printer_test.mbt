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
test "canonical declarations and type layout" {
  let source = "package a:b;interface i{record pair{x:u8,y:list<option<string>>} f:func(p:pair)->result<_,string>;}world w{import i;export run:func();}"
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
    #|
  assert_eq(roundtrip(source), expected)
}

///|
test "all scalar names escape reserved words without changing structure" {
  let _ = roundtrip(
    "interface %interface { type %type = u8; f: func(%async: %type) -> %error-context; } world w { import %interface; }",
  )
  let _ = roundtrip(
    "@unstable(feature=%interface) interface i { type t = error-context; }",
  )
}

///|
test "proposal syntax inline interfaces constructors and named paths round trip" {
  let source =
    #|package n:nested:p/child@1.0.0;
    #|interface i {
    #|  resource r { constructor(p:string) -> result<r>; position: get() -> u64; position: set(v:u64); make: static async func() -> own<r>; }
    #|  type t = tuple<list<u8,0001>,future,stream<u8>,map<string,u8>,borrow<r>>;
    #|}
    #|world w { @external-id("a\u{123f}") import x: n:nested:p/child/i; export host: interface { f:func(); } include other with { a as b }; }
  let _ = roundtrip(source)
}

///|
test "invalid arenas recovery nodes and incompatible data return errors" {
  let empty : @ast.Tree = { nodes: [], }
  assert_eq(@printer.print(empty), Err(InvalidTree))
  let primitive : @ast.Tree = {
    nodes: [{ data: PrimitiveType(name="u8"), span: { start: 0, end: 0, }, }],
  }
  assert_eq(@printer.print(primitive), Err(InvalidRoot))
  let bad = @parser.parse("???;")
  assert_true(@printer.print(bad.ast) is Err(RecoveryNode(_)))
  let invalid : @ast.Tree = {
    nodes: [
      {
        data: PrimitiveType(name="not-a-primitive"),
        span: { start: 0, end: 0, },
      },
      {
        data: Alias(name="t", attributes=[], ty=0),
        span: { start: 0, end: 0, },
      },
      {
        data: Interface(name="i", attributes=[], items=[1]),
        span: { start: 0, end: 0, },
      },
      { data: File(items=[2]), span: { start: 0, end: 0, }, },
    ],
  }
  assert_true(invalid.validate())
  assert_eq(@printer.print(invalid), Err(Unrepresentable))
  let good = @parser.parse("interface i {}").ast
  assert_eq(@printer.print(good, indent_width=-1), Err(InvalidOptions))
  assert_eq(@printer.print(good, indent_width=9), Err(InvalidOptions))
}

///|
test "law: generated nested types print deterministically and preserve ASTs" {
  let opens = [
    "list<", "option<", "tuple<u8,", "result<", "map<string,", "future<", "stream<",
  ]
  let closes = [">", ">", ">", ",string>", ">", ">", ">"]
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let out = StringBuilder()
      out.write_string("interface i { type t = ")
      for b in choices {
        out.write_string(opens[b.to_int() % opens.length()])
      }
      out.write_string("u8")
      for b in choices.rev_iter() {
        out.write_string(closes[b.to_int() % closes.length()])
      }
      out.write_string("; }")
      let original = @parser.parse(out.to_string())
      guard @printer.print(original.ast) is Ok(text) else { return false }
      let parsed = @parser.parse(text)
      parsed.is_valid() &&
      original.ast.equivalent(parsed.ast) &&
      @printer.print(parsed.ast) == Ok(text)
    },
    count=400,
    max_size=96,
    seed=20261025,
  )
}

///|
test "deep type printing never descends recursively" {
  let out = StringBuilder()
  out.write_string("interface i { type t = ")
  for _ in 0..<18000 {
    out.write_string("list<")
  }
  out.write_string("u8")
  for _ in 0..<18000 {
    out.write_string(">")
  }
  out.write_string("; }")
  let _ = roundtrip(out.to_string())
}

///|
test "every printable node kind is covered by structural round trips" {
  let source =
    #|package a:b;
    #|package a:c { interface other {} }
    #|@since(version=1.0.0)
    #|interface all {
    #|  resource r { constructor(p:u8) -> result<r>; f: static async func(x:borrow<r>) -> own<r>; }
    #|  record rec { field:u8 }
    #|  flags fl { flag }
    #|  enum en { first }
    #|  variant va { first(u8) }
    #|  type t = tuple<list<u8,4>,option<u8>,result<u8,string>,result<_,string>,future<u8>,stream<u8>,map<bool,u8>,r>;
    #|  use x.{a as b};
    #|}
    #|world w { import a:b/x; export run:func(); include y with { old as renamed }; }
  let tree = @parser.parse(source, features=@parser.Features::all()).ast
  let kinds : Array[@ast.Kind] = []
  for node in tree.nodes {
    if !kinds.contains(node.data.kind()) {
      kinds.push(node.data.kind())
    }
  }
  assert_eq(kinds.length(), 34)
  let _ = roundtrip(source)
}

///|
test "deep block indentation is stack safe" {
  let out = StringBuilder()
  for _ in 0..<1200 {
    out.write_string("package n:p { ")
  }
  out.write_string("interface leaf {}")
  for _ in 0..<1200 {
    out.write_string(" }")
  }
  let _ = roundtrip(out.to_string())
}
