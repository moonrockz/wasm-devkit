///|
fn checked(
  source : String,
  features~ : @parser.Features = @parser.Features::default(),
) -> @parser.Parse raise {
  let result = @parser.parse(source, features~)
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
  assert_eq(result.cst.to_source(), source)
  result
}

///|
test "composition expressions preserve arguments access spelling and grouping" {
  let source =
    #|package ns:app@1.2.3 targets ns:types/app;
    #|import host as "ns:host/log@1.0.0": interface { log: func(message: string); };
    #|let args = new ns:lib@1.0.0 { host, ...host, ..., "named/arg": (host).log["x"], id: host };
    #|export args...;
    #|export (args).run as "run";
  let result = checked(source)
  assert_true(result.ast.nodes.any(n => n.data.kind() == @ast.New))
  assert_true(result.ast.nodes.any(n => n.data.kind() == @ast.FillArgument))
  assert_true(result.ast.nodes.any(n => n.data.kind() == @ast.SpreadArgument))
  assert_true(result.ast.nodes.any(n => n.data.kind() == @ast.NamedArgument))
}

///|
test "WAC type declarations resources worlds and scoped selectors" {
  let source =
    #|package ns:types;
    #|type callback = async func(v: u8) -> result<_,string>;
    #|interface types {
    #| use ns:other/types.{t as other, value};
    #| resource forward;
    #| record pair {x: u8, y: list<option<string>>,}
    #| flags flags-type {a,b,}
    #| enum enum-type {a,b,}
    #| variant variant-type {none,some(u8),}
    #| type all = tuple<u8,s8,u16,s16,u32,s32,u64,s64,f32,f64,bool,char,string,other,borrow<forward>,future,stream<u8>,error-context>;
    #| resource file { constructor(path: string); read: func() -> list<u8>; open: static async func() -> file; }
    #| f: callback;
    #|}
    #|world app {
    #| use types.{pair}; include ns:base/world with {old as renamed,};
    #| import ns:host/log; import host: interface {f: async func();};
    #| export types; export run: func() -> result<u8,_>;
    #| resource handle;
    #|}
  let _ = checked(source)
}

///|
test "named results are an explicit grammar extension" {
  let source = "package a:b; type f = func() -> (a: u8, b: string);"
  assert_false(@parser.parse(source).is_valid())
  let result = checked(source, features=@parser.Features::all())
  assert_true(result.ast.nodes.any(n => n.data.kind() == @ast.NamedResults))
}

///|
test "WIT-only syntax and composition semantic checks have explicit boundaries" {
  for
    source in [
      "interface i {}", "package a:b; resource r;", "package a:b; use c;", "package a:b; world w { import h: interface {} }",
      "package a:b; interface i {resource r {constructor() -> r;}}", "package a:b; type t = tuple<>;",
      "package a:b; type t = list<u8,4>;", "package a:b; type t = own<r>;", "package a:b; let x = new a:b/c {};",
      "package a : b;", "package a:b; interface i {use a:b/c /* space */ .{x};} export x as y...;",
    ] {
    assert_false(@parser.parse(source).is_valid())
  }
  // Duplicate names and unresolved references are semantic concerns.
  let _ = checked(
    "package a:b; let x = absent; let x = new missing:pkg { ..., x }; export x;",
  )
}

///|
test "recovery retains later declarations and exact malformed source" {
  let source = "package a:b; ???; let good = x; interface later { type t = list<; } export good;"
  let result = @parser.parse(source)
  assert_false(result.is_valid())
  assert_true(result.ast.nodes.any(n => n.data is Let(name="good", ..)))
  assert_true(result.ast.nodes.any(n => n.data is Interface(name="later", ..)))
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "law: arbitrary input parsing is total lossless and structurally valid" {
  @quickcheck.check(
    (source : String) => {
      let result = @parser.parse(source)
      result.ast.validate() &&
      result.cst.validate() &&
      result.cst.to_source() == source
    },
    count=600,
    max_size=128,
    seed=20261025,
  )
}

///|
test "law: malformed grammar fragments preserve valid arena edges" {
  let pieces = [
    "package", "a:b", "a:b/c@1.0.0", "targets", "interface", "world", "resource",
    "type", "record", "flags", "enum", "variant", "f", "func", "constructor", "async",
    "use", "include", "import", "export", "as", "with", "let", "new", "...", "x",
    "\"raw\"", "list", "tuple", "option", "result", "future", "borrow", "stream",
    "u8", "_", "{", "}", "(", ")", "<", ">", "[", "]", ";", ":", ",", "=", ".", "->",
    "???", "/* bad",
  ]
  @quickcheck.check(
    (bytes : Array[Byte]) => {
      let out = StringBuilder()
      out.write_string("package a:b; ")
      for b in bytes {
        out.write_string(pieces[b.to_int() % pieces.length()])
        out.write_string(" ")
      }
      let source = out.to_string()
      let result = @parser.parse(source)
      result.ast.validate() &&
      result.cst.validate() &&
      result.cst.to_source() == source
    },
    count=1200,
    max_size=128,
    seed=20261026,
  )
}

///|
test "deep types groups and nested instantiations use heap tasks" {
  for mode in 0..<3 {
    let out = StringBuilder()
    out.write_string(
      if mode == 0 {
        "package a:b; type t = "
      } else {
        "package a:b; let x = "
      },
    )
    for _ in 0..<20000 {
      out.write_string(
        match mode {
          0 => "list<"
          1 => "("
          _ => "new a:b { arg: "
        },
      )
    }
    out.write_string(if mode == 0 { "u8" } else { "x" })
    for _ in 0..<20000 {
      out.write_string(
        match mode {
          0 => ">"
          1 => ")"
          _ => "}"
        },
      )
    }
    out.write_string(";")
    let _ = checked(out.to_string())
  }
}

///|
test "incomplete deep syntax reports errors without stack overflow" {
  let out = StringBuilder()
  out.write_string("package a:b; type t = ")
  for _ in 0..<10000 {
    out.write_string("option<")
  }
  out.write_string("u8")
  let source = out.to_string()
  let result = @parser.parse(source)
  assert_false(result.is_valid())
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "node-kind table is covered by concrete WAC syntax" {
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
  let result = checked(source, features=@parser.Features::all())
  let kinds = result.ast.nodes.map(n => n.data.kind()).iter().to_array()
  let expected : Array[@ast.Kind] = [
    File,
    Package,
    Path,
    Interface,
    World,
    Resource,
    Alias,
    Record,
    Flags,
    Enum,
    Variant,
    Function,
    Constructor,
    Signature,
    NamedResults,
    Import,
    WorldImport,
    WorldExport,
    Use,
    Include,
    Rename,
    Field,
    Case,
    Parameter,
    PrimitiveType,
    NamedType,
    ListType,
    TupleType,
    OptionType,
    ResultType,
    BorrowType,
    FutureType,
    StreamType,
    Let,
    Export,
    Name,
    Expression,
    Reference,
    Group,
    New,
    InferredArgument,
    SpreadArgument,
    NamedArgument,
    FillArgument,
    Access,
  ]
  for kind in expected {
    assert_true(kinds.contains(kind))
  }
  let bad = @parser.parse("package a:b; ???;")
  assert_true(bad.ast.nodes.any(n => n.data.kind() == Error))
  assert_true(bad.ast.validate())
  assert_true(bad.cst.validate())
}

///|
test "reference empty-arrow and result placeholders retain their syntax" {
  for
    ty in [
      "result", "result<_>", "result<_,_>", "result<u8,_>", "result<_,string>",
    ] {
    let _ = checked("package a:b; type t = " + ty + ";")
  }
  let _ = checked("package a:b; type f = func() ->;")
}
