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
test "interfaces worlds and resources expose typed fields" {
  let source =
    #|package example:tooling@1.2.3-beta.1+Build;
    #|use dep:api/types@2.0.0 as external;
    #|@since(version = 1.2.0)
    #|interface types {
    #|  use external.{number as count, thing};
    #|  record pair { x: u32, y: list<option<string>>, }
    #|  flags options { read, write }
    #|  enum color { red, blue }
    #|  variant payload { empty, data(list<u8>) }
    #|  type numbers = tuple<u8, s16, u64, s64, f32, f64, char, bool>;
    #|  type table = map<string, result<_, string>>;
    #|  resource file {
    #|    constructor(path: string) -> result<file>;
    #|    read: async func(n: u32) -> future<list<u8>>;
    #|    open: static func(path: string) -> own<file>;
    #|    borrow-it: func(value: borrow<file>) -> stream;
    #|  }
    #|}
    #|world app {
    #|  use types.{pair};
    #|  include dep:api/base@1.0.0 with { old as renamed };
    #|  import host: interface { log: func(text: string); }
    #|  import dep:api/remote@1.0.0;
    #|  export run: async func(args: list<string>) -> result;
    #|  type pending = future;
    #|  type bytes = stream<u8>;
    #|}
  let result = checked(source)
  let root = result.ast.nodes[result.ast.nodes.length() - 1]
  guard root.data is File(items~) else { fail("file root") }
  assert_eq(items.length(), 4)
  guard result.ast.nodes[items[2]].data
    is Interface(name~, attributes~, items=members) else {
    fail("typed interface")
  }
  assert_eq(name, "types")
  assert_eq(attributes.length(), 1)
  assert_eq(members.length(), 8)
  guard result.ast.nodes[attributes[0]].data
    is Attribute(name=attribute, field~, value~) else {
    fail("typed attribute")
  }
  assert_eq(attribute, "since")
  assert_eq(field, "version")
  assert_eq(value, "1.2.0")
  let resources = result.ast.nodes
    .iter()
    .filter(n => n.data.kind() == Resource)
    .to_array()
  assert_eq(resources.length(), 1)
  guard resources[0].data is Resource(name=resource, methods~, has_body~, ..) else {
    fail("resource fields")
  }
  assert_eq(resource, "file")
  assert_true(has_body)
  assert_eq(methods.length(), 4)
}

///|
test "all documented WIT node kinds are exercised by concrete syntax" {
  let source =
    #|package a:b;
    #|package a:c { interface nested {} }
    #|interface all {
    #|  resource forward;
    #|  type primitive = u8;
    #|  type named = primitive;
    #|  type types = tuple<list<u8>, option<u8>, result<u8,string>, result<_,string>, future<u8>, stream<u8>, map<bool,u8>, own<forward>, borrow<forward>>;
    #|  record record-type { field: u8 }
    #|  flags flag-type { flag }
    #|  enum enum-type { first }
    #|  variant variant-type { first(u8) }
    #|  resource file { constructor(); f: func(p: u8) -> u8; }
    #|  @unstable(feature = example)
    #|  f: func();
    #|  use nested.{primitive as p};
    #|}
    #|world app { import a:b/host; export run: func(); include base; }
  let result = checked(source)
  let kinds = result.ast.nodes.map(n => n.data.kind()).iter().to_array()
  let expected : Array[@ast.Kind] = [
    File,
    Package,
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
    Import,
    Export,
    Use,
    Include,
    Attribute,
    Path,
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
    OwnType,
    BorrowType,
    FutureType,
    StreamType,
    MapType,
  ]
  for kind in expected {
    assert_true(kinds.contains(kind))
  }
  let bad = @parser.parse("nonsense;")
  assert_true(
    bad.diagnostics.any(d => {
      d.code == "WIT-P006" && d.recovery == @diagnostic.SkipToken
    }),
  )
  assert_true(bad.ast.nodes.any(n => n.data.kind() == Error))
  assert_true(bad.ast.validate())
  assert_true(bad.cst.validate())
}

///|
test "proposal switches diagnose disabled syntax and retain it" {
  let source =
    #|package ns:nested:example/child;
    #|@external-id("arbitrary/外部")
    #|interface api {
    #|  type bytes = list<u8, 16>;
    #|  resource file { position: get() -> u64; position: set(v: u64); }
    #|}
    #|world app { import custom: api; }
  let disabled = @parser.parse(source)
  assert_false(disabled.is_valid())
  assert_eq(disabled.diagnostics.filter(d => d.code == "WIT-P005").length(), 6)
  assert_true(disabled.ast.validate())
  assert_true(disabled.cst.validate())
  let enabled = checked(source, features=@parser.Features::all())
  assert_eq(enabled.ast, disabled.ast)
}

///|
test "syntax failures retain text and recover subsequent declarations" {
  for
    source in [
      "interface bad { type broken = list<; good: func(); } interface later {}",
      "interface bad { record broken { x: } type good = u8; } world later {}", "interface bad { f: func(a: , b: u8); g: func(); } interface later {}",
      "interface bad { ???; type good = u8; } interface later {}", "@unknown(field = value) interface later {}",
      "interface bad { type t = tuple<u8, >; } } interface later {}", "interface bad { f: func( } interface later {}",
    ] {
    let result = @parser.parse(source)
    assert_false(result.is_valid())
    assert_true(result.ast.validate())
    assert_true(result.cst.validate())
    assert_eq(result.cst.to_source(), source)
    assert_true(
      result.ast.nodes.any(n => {
        match n.data {
          Interface(name="later", ..) | World(name="later", ..) => true
          _ => false
        }
      }),
    )
  }
}

///|
test "grammar constraints reject invalid documents" {
  for
    source in [
      "use local/path;", "package x:y {} package a:b;", "package x:y { package a:b; }",
      "@since(version=1.0.0) package a:b;", "type top = u8;", "interface a { world nested {} }",
      "world a { f: func(); }", "interface a { resource r { type nested = u8; } }",
      "package no-namespace;", "interface a {} package late:name;", "package a:b; package a:b;",
      "use package:only;", "use local@1.2.3;", "use a:b/x@01.2.3;", "use a:b/x@1.2.3-01;",
      "use a:b/x@1.2.3+;", "interface a { type t = borrow<list<u8>>; }", "interface a { type t = option<>; }",
      "interface a { type t = result<_,_>; }", "interface a { f: static func(); }",
      "interface a { f: async get() -> u8; }", "interface a { use thing; }",
    ] {
    let result = @parser.parse(source, features=@parser.Features::all())
    assert_false(result.is_valid())
    assert_true(result.ast.validate())
    assert_true(result.cst.validate())
    assert_eq(result.cst.to_source(), source)
  }
}

///|
test "deep type syntax uses heap continuations and flat immutable arenas" {
  let out = StringBuilder()
  out.write_string("interface deep { type t = ")
  for _ in 0..<20000 {
    out.write_string("list<")
  }
  out.write_string("u8")
  for _ in 0..<20000 {
    out.write_string(">")
  }
  out.write_string("; }")
  let source = out.to_string()
  let result = checked(source)
  assert_eq(result.ast.nodes.length(), 20004)
}

///|
test "law: parsing arbitrary source is total, lossless and structurally valid" {
  @quickcheck.check(
    (source : String) => {
      let result = @parser.parse(source)
      result.ast.validate() &&
      result.cst.validate() &&
      result.cst.to_source() == source
    },
    count=600,
    max_size=128,
    seed=20261020,
  )
}

///|
test "law: malformed grammar fragments never lose text or produce invalid edges" {
  let pieces = [
    "interface", "world", "resource", "package", "type", "record", "flags", "enum",
    "variant", "f", "func", "constructor", "async", "use", "include", "import", "export",
    "as", "with", "@since", "version", "@unstable", "feature", "1.2.3", "list", "tuple",
    "option", "result", "future", "borrow", "stream", "map", "u8", "_", "{", "}",
    "(", ")", "<", ">", ";", ":", ",", "=", ".", "->", "???", "/* bad",
  ]
  @quickcheck.check(
    (bytes : Array[Byte]) => {
      let out = StringBuilder()
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
    count=1000,
    max_size=128,
    seed=20261021,
  )
}

///|
test "empty records flags and tuples retain their syntax" {
  let _ = checked(
    "interface empty { record r {} flags f {} type t = tuple<>; }",
  )
}

///|
test "nested package bodies use the same explicit work stack" {
  let out = StringBuilder()
  for _ in 0..<2000 {
    out.write_string("package nested:pkg { ")
  }
  out.write_string("interface leaf {}")
  for _ in 0..<2000 {
    out.write_string(" }")
  }
  let _ = checked(out.to_string())
}

///|
test "law: generated nested valid type syntax is accepted" {
  let opens = [
    "list<", "option<", "tuple<u8,", "result<", "map<string,", "future<", "stream<",
  ]
  let closes = [">", ">", ">", ",string>", ">", ">", ">"]
  @quickcheck.check(
    (bytes : Array[Byte]) => {
      let out = StringBuilder()
      out.write_string("interface generated { type t = ")
      for b in bytes {
        out.write_string(opens[b.to_int() % opens.length()])
      }
      out.write_string("u8")
      for b in bytes.rev_iter() {
        out.write_string(closes[b.to_int() % closes.length()])
      }
      out.write_string("; }")
      let source = out.to_string()
      let parsed = @parser.parse(source)
      parsed.is_valid() &&
      parsed.ast.validate() &&
      parsed.cst.validate() &&
      parsed.cst.to_source() == source
    },
    count=300,
    max_size=80,
    seed=20261022,
  )
}

///|
test "deep incomplete syntax reports missing closers without stack overflow" {
  let out = StringBuilder()
  out.write_string("interface deep { type t = ")
  for _ in 0..<10000 {
    out.write_string("option<")
  }
  out.write_string("u8")
  let source = out.to_string()
  let parsed = @parser.parse(source)
  assert_false(parsed.is_valid())
  assert_eq(parsed.diagnostics.length(), 10002)
  assert_true(parsed.ast.validate())
  assert_true(parsed.cst.validate())
  assert_eq(parsed.cst.to_source(), source)
}

///|
test "lexical errors and malformed UTF-16 survive syntax recovery" {
  let emoji = "😀"
  for
    half in [
      emoji.unsafe_substring(start=0, end=1),
      emoji.unsafe_substring(start=1, end=2),
    ] {
    let source = "interface bad { type t = " + half + "; } interface later {}"
    let result = @parser.parse(source)
    assert_false(result.is_valid())
    assert_true(result.diagnostics.any(d => d.code == "WIT-L008"))
    assert_true(result.ast.validate())
    assert_true(result.cst.validate())
    assert_eq(result.cst.to_source(), source)
    assert_true(
      result.ast.nodes.any(n => {
        match n.data {
          Interface(name="later", ..) => true
          _ => false
        }
      }),
    )
  }
}

///|
test "syntactically valid semantic failures remain typed syntax" {
  let _ = checked(
    "interface a { enum e {} variant v {} type t = map<tuple<u8>,u8>; use missing.{}; } world w { include missing with {} }",
  )
}

///|
test "error-context is a primitive and its percent escape is a name" {
  let parsed = checked(
    "interface a { type t = error-context; type n = %error-context; }",
  )
  assert_true(
    parsed.ast.nodes.any(n => n.data == PrimitiveType(name="error-context")),
  )
  assert_true(
    parsed.ast.nodes.any(n => n.data == NamedType(name="error-context")),
  )
}

///|
test "fixed-length integer spellings remain lossless for later validation" {
  for length in ["0", "0001", "4294967295", "4294967296"] {
    let parsed = checked(
      "interface a { type t = list<u8," + length + ">; }",
      features=@parser.Features::all(),
    )
    assert_true(
      parsed.ast.nodes.any(n => {
        match n.data {
          ListType(length=Some(actual), ..) => actual == length
          _ => false
        }
      }),
    )
  }
}

///|
test "a leading byte-order mark is trivia rather than a syntax error" {
  let source = "\ufeffpackage a:b; interface x {}"
  let parsed = checked(source)
  assert_eq(parsed.cst.tokens[0].kind, Whitespace)
  assert_eq(parsed.cst.tokens[0].text, "\ufeff")
  assert_false(@parser.parse(" \ufeffinterface x {}").is_valid())
}

///|
test "named local interface paths are independent of whitespace" {
  for
    source in [
      "package example:app; interface api {} world app { import a:api; export b:api; }",
      "package example:app; interface api {} world app { import a: api; export b: api; }",
    ] {
    let parsed = @parser.parse(source, features=@parser.Features::reference())
    assert_true(parsed.is_valid())
    assert_true(parsed.ast.nodes.any(n => n.data is Import(name=Some("a"), ..)))
    assert_true(parsed.ast.nodes.any(n => n.data is Export(name=Some("b"), ..)))
  }
}
