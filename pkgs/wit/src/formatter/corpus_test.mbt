// Corpus source literals copied from the sibling parser fixture snapshots.
// wasm-tools dcac6c30353afa6e851ef0bbd4ca14d8f5493731 and Component Model
// 0220da84209397d9067c19cac83dae969aa85a7b. Original licenses and manifests:
// ../parser/fixtures/ and ../parser/fixtures/wasm-tools/.

///|
test "formatter wasm-tools syntax accessors.wit" {
  let source = [
    "package foo:bar;\n\ninterface i {\n  // A getter and setter pair for the same property.\n  prop: get() -> u64;\n  prop: set(v",
    "alue: u64);\n\n  // Getters don't require a setter.\n  read-only: get() -> string;\n\n  // Setters may return a `result` with",
    " no `ok` type.\n  fallible: get() -> u32;\n  fallible: set(value: u32) -> result<_, string>;\n\n  // Neither `get` nor `set`",
    " is a keyword.\n  get: func();\n  set: func(value: u32);\n  getter: get() -> bool;\n  getter: set(value: bool);\n\n  resource ",
    "blob {\n    constructor(init: list<u8>);\n    write: func(bytes: list<u8>);\n    position: get() -> u64;\n    position: set(",
    "value: u64);\n    max-size: static get() -> u64;\n    max-size: static set(value: u64) -> result<_, string>;\n    read-only",
    ": static get() -> string;\n  }\n}\n\nworld w {\n  import prop: get() -> u64;\n  import prop: set(value: u64);\n  export other: ",
    "get() -> u64;\n  export other: set(value: u64);\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax async.wit" {
  let source = [
    "package test:%async;\n\ninterface x {\n  x: async func(x: u32) -> u64;\n  y: func();\n\n  resource z {\n    constructor();\n\n   ",
    " x: async func();\n    y: func();\n\n    static-x: static async func();\n    static-y: static func();\n  }\n}\n\nworld y {\n  imp",
    "ort x: async func();\n  import y: func();\n\n  export x: async func();\n  export y: func();\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax comments.wit" {
  let source = [
    "package foo:comments;\n\n// hello\n// world\n// why, yes\n// this is a comment\n/* this too */ /* is a comment */\n/* this /* i",
    "s /* a */ nested */ comment */\n\ninterface foo {\n  type x = u32;\n\n  type /* foo */ bar /* baz */ = //\n  stream < //\n  //\n",
    "  //\n\n\n\n\n  x\n\n  >;\n\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax complex-include/deps/bar/root.wit" {
  let source = "package foo:bar;\n\ninterface a {}\ninterface b {}\n\nworld bar-a {\n    import a;\n    import b;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax complex-include/deps/baz/root.wit" {
  let source = "package foo:baz;\n\ninterface a {}\ninterface b {}\n\nworld baz-a {\n    import a;\n    import b;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax complex-include/root.wit" {
  let source = [
    "package foo:root;\n\ninterface ai {}\ninterface bi {}\n\nworld a {\n    import ai;\n    import bi;\n}\n\nworld b {\n    include foo",
    ":bar/bar-a;\n}\n\nworld c {\n    include b;\n    include foo:bar/bar-a;\n}\n\nworld union-world {\n    include a;\n    include b;\n",
    "    include c;\n    include foo:bar/bar-a;\n    include foo:baz/baz-a;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax cross-package-resource/deps/foo/foo.wit" {
  let source = "package some:dep;\n\ninterface foo {\n  resource r;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax cross-package-resource/foo.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{r};\n\n  type t = own<r>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax diamond1/deps/dep1/types.wit" {
  let source = "package foo:dep1;\ninterface types {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax diamond1/deps/dep2/types.wit" {
  let source = "package foo:dep2;\ninterface types {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax diamond1/join.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  import foo:dep1/types;\n  import foo:dep2/types;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax disambiguate-diamond/shared1.wit" {
  let source = "interface shared1 {\n  type the-type = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax disambiguate-diamond/shared2.wit" {
  let source = "interface shared2 {\n  type the-type = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax disambiguate-diamond/world.wit" {
  let source = "package foo:diamond;\n\nworld foo {\n  import foo: interface {\n    use shared1.{the-type};\n  }\n  import bar: interface {\n    use shared2.{the-type};\n  }\n\n  import shared1;\n  import shared2;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax distinct-names.wit" {
  let source = "package foo:foo;\n\ninterface distinct-names {\n  record r { a1: u32, a2: u32, a-b1: u32, a-b2: u32 }\n  flags f { f1, f2 }\n  variant v { c1(u32), c2 }\n  enum e { e1, e2 }\n  g: func(p1: u32, p2: u32);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax empty.wit" {
  let source = "package foo:empty;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax error-context.wit" {
  let source = "package foo:error-contexts;\n\ninterface error-contexts {\n  type t1 = error-context;\n\n  foo: func(x: error-context, y: t1) -> result<_, error-context>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax feature-gates.wit" {
  let source = [
    "package a:b;\n\n@unstable(feature = not-active)\ninterface gated {\n}\n\n@unstable(feature = active)\ninterface ungated {\n  @un",
    "stable(feature = not-active)\n  gated: func();\n\n  @unstable(feature = active)\n  ungated: func();\n}\n\n@unstable(feature = a",
    "ctive)\ninterface ungated2 {\n  @unstable(feature = not-active)\n  type gated = u32;\n  @unstable(feature = not-active)\n  ty",
    "pe gated2 = gated;\n\n  @unstable(feature = not-active)\n  type gated-with-anonymous-type = option<option<gated>>;\n\n  @unst",
    "able(feature = active)\n  type ungated = u32;\n  @unstable(feature = active)\n  type ungated2 = ungated;\n}\n\n@unstable(featu",
    "re = inactive)\ninterface gated-use-target {\n  @unstable(feature = inactive)\n  type t = u32;\n}\n\n@unstable(feature = inact",
    "ive)\ninterface gated-use {\n  @unstable(feature = inactive)\n  use gated-use-target.{t};\n}\n\n@unstable(feature = active)\nin",
    "terface ungated-use-target {\n  @unstable(feature = active)\n  type t = u32;\n}\n\n@unstable(feature = active)\ninterface unga",
    "ted-use {\n  @unstable(feature = active)\n  use ungated-use-target.{t};\n}\n\n@unstable(feature = inactive)\ninterface gated-f",
    "or-world {}\n\n@unstable(feature = inactive)\nworld gated-world {\n  @unstable(feature = inactive)\n  import gated-for-world;",
    "\n  @unstable(feature = inactive)\n  export gated-for-world;\n}\n\n@unstable(feature = active)\ninterface ungated-for-world {}",
    "\n\n@unstable(feature = active)\nworld ungated-world {\n  @unstable(feature = active)\n  import ungated-for-world;\n  @unstabl",
    "e(feature = active)\n  export ungated-for-world;\n}\n\nworld mixed-world {\n  @unstable(feature = inactive)\n  import gated-fo",
    "r-world;\n  @unstable(feature = inactive)\n  export gated-for-world;\n  @unstable(feature = inactive)\n  include gated-world",
    ";\n\n  @unstable(feature = active)\n  import ungated-for-world;\n  @unstable(feature = active)\n  export ungated-for-world;\n ",
    " @unstable(feature = inactive)\n  include ungated-world;\n}\n\ninterface with-resources {\n  @unstable(feature = inactive)\n  ",
    "resource gated {\n    @unstable(feature = inactive)\n    constructor();\n\n    @unstable(feature = inactive)\n    x: static f",
    "unc();\n\n    @unstable(feature = inactive)\n    y: func();\n  }\n\n  @unstable(feature = active)\n  resource ungated {\n    @un",
    "stable(feature = active)\n    constructor();\n\n    @unstable(feature = active)\n    x: static func();\n\n    @unstable(featur",
    "e = active)\n    y: func();\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax feature-types.wit" {
  let source = "package a:b;\n\ninterface foo {\n  variant bar {\n    x,\n    y\n  }\n\n  @unstable(feature = my-feature)\n  my-unstable: func(p: bar) -> result<_, bar>;\n\n  my-stable: func(p: bar) -> result<_, bar>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/another-pkg/other-doc.wit" {
  let source = "package foo:another-pkg;\n\ninterface other-interface {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/corp/saas.wit" {
  let source = "package foo:corp;\n\ninterface saas {\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/different-pkg/the-doc.wit" {
  let source = "package foo:different-pkg;\ninterface i {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/foreign-pkg/the-doc.wit" {
  let source = "package foo:foreign-pkg;\n\ninterface the-default {\n  type some-type = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/some-pkg/some-doc.wit" {
  let source = "package foo:some-pkg;\n\ninterface the-default {\n  type from-default = string;\n}\n\ninterface some-interface {\n  type another-type = u32;\n}\n\ninterface another-interface {\n  type yet-another-type = u8;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/wasi/clocks.wit" {
  let source = "package foo:wasi;\n\ninterface clocks {\n  type timestamp = u64;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/deps/wasi/filesystem.wit" {
  let source = "package foo:wasi;\n\ninterface filesystem {\n  record stat {\n    ino: u64\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps/root.wit" {
  let source = [
    "package foo:root;\n\ninterface foo {\n  use foo:wasi/clocks.{timestamp};\n  use foo:wasi/filesystem.{stat};\n}\n\nworld my-worl",
    "d {\n  import foo:wasi/filesystem;\n  import foo:wasi/clocks;\n\n  export foo:corp/saas;\n}\n\nuse foo:wasi/filesystem as files",
    "ystem;\nuse foo:wasi/clocks as clocks;\n\nworld my-world2 {\n  import filesystem;\n  import clocks;\n  export foo;\n  export fo",
    "o:corp/saas;\n}\n\ninterface bar {\n  use filesystem.{};\n  use foo:some-pkg/the-default.{from-default};\n  use foo:some-pkg/s",
    "ome-interface.{another-type};\n  use foo:some-pkg/some-interface.{};\n  use foo:some-pkg/another-interface.{yet-another-ty",
    "pe};\n  use foo:different-pkg/i.{};\n}\n\nworld bars-world {\n  import foo:some-pkg/the-default;\n  import foo:another-pkg/oth",
    "er-interface;\n}\n\ninterface use1 {\n  use foo:foreign-pkg/the-default.{some-type};\n}\ninterface use2 {\n  use foo:foreign-pk",
    "g/the-default.{some-type};\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/another-pkg/other-doc.wit" {
  let source = "package foo:another-pkg;\n\ninterface other-interface {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/corp/saas.wit" {
  let source = "package foo:corp;\n\ninterface saas {\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/different-pkg/the-doc.wit" {
  let source = "package foo:different-pkg;\ninterface i {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/foreign-pkg/the-doc.wit" {
  let source = "package foo:foreign-pkg;\n\ninterface the-default {\n  type some-type = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/some-pkg/some-doc.wit" {
  let source = "package foo:some-pkg;\n\ninterface the-default {\n  type from-default = string;\n}\n\ninterface some-interface {\n  type another-type = u32;\n}\n\ninterface another-interface {\n  type yet-another-type = u8;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/wasi/clocks.wit" {
  let source = "package foo:wasi;\n\ninterface clocks {\n  type timestamp = u64;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/wasi/filesystem.wit" {
  let source = "package foo:wasi;\n\ninterface filesystem {\n  record stat {\n    ino: u64\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/deps/wasi/wasi.wit" {
  let source = "package foo:wasi;\n\nworld wasi {\n    import filesystem;\n    import clocks;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-deps-union/root.wit" {
  let source = [
    "package foo:root;\n\ninterface foo {\n  use foo:wasi/clocks.{timestamp};\n  use foo:wasi/filesystem.{stat};\n}\n\nworld my-worl",
    "d {\n  import foo:wasi/filesystem;\n  import foo:wasi/clocks;\n\n  export foo:corp/saas;\n}\n\nuse foo:wasi/filesystem as files",
    "ystem;\nuse foo:wasi/clocks as clocks;\n\nworld my-world2 {\n  import filesystem;\n  import clocks;\n  export foo;\n  export fo",
    "o:corp/saas;\n}\n\ninterface bar {\n  use filesystem.{};\n  use foo:some-pkg/the-default.{from-default};\n  use foo:some-pkg/s",
    "ome-interface.{another-type};\n  use foo:some-pkg/some-interface.{};\n  use foo:some-pkg/another-interface.{yet-another-ty",
    "pe};\n  use foo:different-pkg/i.{};\n}\n\nworld bars-world {\n  import foo:some-pkg/the-default;\n  import foo:another-pkg/oth",
    "er-interface;\n}\n\ninterface use1 {\n  use foo:foreign-pkg/the-default.{some-type};\n}\ninterface use2 {\n  use foo:foreign-pk",
    "g/the-default.{some-type};\n}\n\nworld unionw-world {\n  include my-world;\n  include my-world2;\n  include foo:wasi/wasi;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-interface-dep-gated.wit" {
  let source = "package a:b1;\n\nworld the-world {\n  include a:b2/the-world;\n}\n\npackage a:b2 {\n  world the-world {\n    @unstable(feature = disabled)\n    import a:b3/thing;\n  }\n}\n\npackage a:b3 {\n  @unstable(feature = disabled)\n  interface thing {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax foreign-world-dep-gated.wit" {
  let source = [
    "package a:b1;\n\nworld the-world {\n  include a:b2/the-world;\n}\n\npackage a:b2 {\n  world the-world {\n    @unstable(feature =",
    " disabled)\n    import a:b3/another-world;\n  }\n}\n\npackage a:b3 {\n  @unstable(feature = disabled)\n  world another-world {}",
    "\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax functions.wit" {
  let source = [
    "package foo:functions;\n\ninterface functions {\n  f1: func();\n  f2: func(a: u32);\n  f3: func(a: u32,);\n  f4: func() -> u32",
    ";\n  f6: func() -> tuple<u32, u32>;\n  f7: func(a: f32, b: f32) -> tuple<u32, u32>;\n  f8: func(a: option<u32>) -> result<u",
    "32, f32>;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax gated-include.wit" {
  let source = [
    "package wasmtime:test@0.1.0;\n\ninterface unknown-stability-interface {\n    resource unknown-stability-resource {\n    }\n  ",
    "  stable-func: func();\n}\n\n@unstable(feature = active)\ninterface unstable-interface {\n    @unstable(feature = active)\n   ",
    " resource unstable-resource {\n    }\n    @unstable(feature = active)\n    unstable-func: func();\n}\n\n@since(version = 0.1.0",
    ")\ninterface stable-interface {\n    @since(version = 0.1.0)\n    resource stable-resource {\n    }\n    @since(version = 0.1",
    ".0)\n    stable-func: func();\n}\n\nworld unknown-stability {\n    import unknown-stability-interface;\n}\n\nworld unstable {\n  ",
    "  @unstable(feature = active)\n    import unstable-interface;\n}\n\nworld stable{\n    @since(version = 0.1.0)\n    import sta",
    "ble-interface;\n}\n\nworld simple-include {\n    include unstable;\n    include stable;\n    include unknown-stability;\n}\n\nwor",
    "ld unstable-include-in-package \n{\n    include unstable;\n}\n\nworld dup-include-in-package {\n    include simple-include;\n  ",
    "  include unstable-include-in-package;\n}\n\nworld dup-use-package {\n    @unstable(feature = active)\n    use stable-interfa",
    "ce.{stable-resource};\n    include simple-include;\n}\n\nworld dup-use-package-ordered {\n    include simple-include;\n    @un",
    "stable(feature = active)\n    use stable-interface.{stable-resource};\n}",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax gated-use.wit" {
  let source = [
    "package wasmtime:test;\n\ninterface types {\n  @unstable(feature = inactive)\n  use wasi:dep2/stable@0.2.3.{unstable-resourc",
    "e};\n}\n\npackage wasi:dep2@0.2.3 {\n  interface stable {\n    @unstable(feature = inactive)\n    resource unstable-resource;\n",
    "  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax ignore-files-deps/deps/bar/types.wit" {
  let source = "package foo:bar;\ninterface types {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax ignore-files-deps/world.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  import foo:bar/types;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax import-export-overlap1.wit" {
  let source = "package foo:foo;\nworld foo {\n  import a: func();\n  export a: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax import-export-overlap2.wit" {
  let source = "package foo:foo;\nworld foo {\n  import a: func();\n  export a: interface {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax include-accessor-pair.wit" {
  let source = "package foo:foo;\n\n// Getters and setters must be validated after includes are processed.\n\nworld base {\n  import prop: get() -> u32;\n}\n\nworld derived {\n  import prop: set(value: u32);\n  include base;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax include-reps.wit" {
  let source = "package foo:foo;\n\ninterface a {}\ninterface b {}\n\nworld bar {\n    import a;\n    export b;\n}\n\nworld foo {\n  include bar;\n  include bar;\n  include bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax kebab-name-include-with.wit" {
  let source = "package foo:foo;\n\nworld foo { import a: func(); }\nworld bar { import a: func(); }\nworld baz {\n    include foo with { a as b }\n    include bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax kinds-of-deps/a.wit" {
  let source = "package a:a;\n\nworld a {\n  import b:b/b;\n  import c:c/c;\n  import d:d/d;\n  import e:e/e;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax kinds-of-deps/deps/b/root.wit" {
  let source = "package b:b;\n\ninterface b {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax kinds-of-deps/deps/c.wit" {
  let source = "package c:c;\n\ninterface c {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax many-names/a.wit" {
  let source = "interface x {}\nuse x as name;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax many-names/b.wit" {
  let source = "package foo:name;\n\nworld name {\n  import name: interface {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax maps.wit" {
  let source = [
    "package foo:maps;\n\ninterface maps {\n  // Basic maps\n  type string-to-u32 = map<string, u32>;\n  type u32-to-string = map<",
    "u32, string>;\n  \n  // Nested maps\n  type nested-map = map<string, map<string, u32>>;\n  \n  // Maps with complex types\n  r",
    "ecord person {\n    name: string,\n    age: u32,\n  }\n  type person-map = map<string, person>;\n  \n  // Maps with tuples, li",
    "sts, options\n  type complex-map = map<string, option<list<u32>>>;\n  \n  // Functions using maps\n  get-value: func(m: map<",
    "string, u32>, key: string) -> option<u32>;\n  set-value: func(m: map<string, u32>, key: string, value: u32) -> map<string",
    ", u32>;\n  merge-maps: func(a: map<string, u32>, b: map<string, u32>) -> map<string, u32>;\n  \n  // Map with various key t",
    "ypes\n  type int-key-map = map<u32, string>;\n  type char-key-map = map<char, string>;\n}\n\nworld maps-world {\n  import maps",
    ";\n  export maps;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax max-flags.wit" {
  let source = [
    "package foo:foo;\n\ninterface foo {\n  flags f {\n    b0,\n    b1,\n    b2,\n    b3,\n    b4,\n    b5,\n    b6,\n    b7,\n    b8,\n  ",
    "  b9,\n    b10,\n    b11,\n    b12,\n    b13,\n    b14,\n    b15,\n    b16,\n    b17,\n    b18,\n    b19,\n    b20,\n    b21,\n    b2",
    "2,\n    b23,\n    b24,\n    b25,\n    b26,\n    b27,\n    b28,\n    b29,\n    b30,\n    b31,\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-file/bar.wit" {
  let source = [
    "package foo:multi-file;\n\ninterface irrelevant-name {\n  record a-name {\n    a: u32,\n  }\n}\n\ninterface depends-on-later-ite",
    "m {\n  use depend-on-me.{x};\n}\n\ninterface depend-on-me {\n  type x = u32;\n}\n\nworld more-depends-on-later-things {\n  import",
    " later-interface;\n  export later-interface;\n}\n\ninterface later-interface {\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-file/cycle-a.wit" {
  let source = "interface cycle1 {\n  type t = u32;\n}\n\ninterface cycle3 {\n  use cycle2.{t};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-file/cycle-b.wit" {
  let source = "interface cycle2 {\n  use cycle1.{t};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-file/foo.wit" {
  let source = [
    "package foo:multi-file;\n\ninterface foo {\n  type x = u32;\n}\n\nuse foo as foo2;\n\ninterface something-else {\n  type y = u64;",
    "\n}\n\nuse depend-on-me as a-different-name;\n\ninterface bar {\n  use foo.{x};\n  use foo.{x as x2};\n  use foo2.{x as x3};\n  u",
    "se a-different-name.{x as x4};\n  use something-else.{y};\n  use something-else.{y as y2};\n  use irrelevant-name.{a-name};",
    "\n}\n\nworld the-world {\n  import a-different-name;\n\n  use a-different-name.{x};\n\n  import foo: func() -> x;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-file-multi-package/a.wit" {
  let source = [
    "package foo:main;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n ",
    "       use i1.{a};\n    }\n  }\n}\n\npackage bar:name {\n  interface i2 {\n    type b = u32;\n  }\n\n  world w2 {\n    import imp2:",
    " interface {\n        use i2.{b};\n    }\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-file-multi-package/b.wit" {
  let source = [
    "package baz:name {\n  interface i3 {\n    type a = u32;\n  }\n\n  world w3 {\n    import imp3: interface {\n        use i3.{a};",
    "\n    }\n  }\n}\n\npackage qux:name {\n  interface i4 {\n    type b = u32;\n  }\n\n  world w4 {\n    import imp4: interface {\n     ",
    "   use i4.{b};\n    }\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-deps/deps/dep.wit" {
  let source = "package foo:dep1;\n\npackage foo:dep2 {\n  interface i2 {\n    type t = string;\n  }\n}\n\ninterface i1 {\n  use foo:dep2/i2.{t};\n\n  type o = option<t>;\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-deps/root.wit" {
  let source = "package foo:root;\n\npackage foo:nest {\n  interface nesty {\n    use foo:dep1/i1.{o};\n    type l = list<o>;\n  }\n}\n\ninterface i0 {\n  use foo:dep1/i1.{o};\n  use foo:nest/nesty.{l};\n\n  type r = result<o>;\n  type r1 = result<l>;\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-gated-include.wit" {
  let source = [
    "package wasmtime:test;\n\nworld test{\n    @unstable(feature = active)\n    include wasi:unstable/imports@0.2.3; \n    includ",
    "e wasi:foo/imports@0.2.3;\n    include wasi:someother/imports@0.2.3;\n}\n\nworld test-ordered {\n    include wasi:someother/i",
    "mports@0.2.3;\n    include wasi:foo/imports@0.2.3;\n    @unstable(feature = active)\n    include wasi:unstable/imports@0.2.",
    "3; \n}\n\nworld test-no-stability {\n    include wasi:someother/imports@0.2.3;\n    include wasi:foo/imports@0.2.3;\n    inclu",
    "de wasi:unstable/imports@0.2.3; \n}\n\nworld test-only-stable {\n    include wasi:foo/imports@0.2.3;\n}\n\nworld test-only-stab",
    "le-with-feature {\n    @unstable(feature = active)\n    include wasi:foo/imports@0.2.3;\n}\n\n// in test this results in worl",
    "d with nothing\nworld test-only-stable-with-in-active-feature {\n    @unstable(feature = in-active)\n    include wasi:foo/i",
    "mports@0.2.3;\n}\n\npackage wasi:unstable@0.2.3 {\n    @unstable(feature = active)\n    world imports {\n        @unstable(fea",
    "ture = active)\n        use wasi:dep2/stable@0.2.3.{stable-resource};\n        @unstable(feature = active)\n        use was",
    "i:dep-unversioned/unversioned.{unversioned-resource};\n        @unstable(feature = active)\n        use wasi:dep-unstable/",
    "unstable.{unstable-resource};\n    }\n}\n\npackage wasi:someother@0.2.3 {\n    @since(version = 0.2.0)\n    world imports {\n  ",
    "      import someother;\n    }\n\n    @since(version = 0.2.0)\n    interface someother {\n        @since(version = 0.2.0)\n   ",
    "     resource someother-resource {\n        }\n    }\n}\n\n\n\npackage wasi:foo@0.2.3 {\n    @since(version = 0.2.0)\n    world i",
    "mports {\n        @since(version = 0.2.0)\n        include wasi:dep2/imports@0.2.3;\n        include wasi:dep-unversioned/i",
    "mports;\n        include wasi:dep-unstable/imports;\n    }\n}\n\npackage wasi:dep2@0.2.3 {\n    @since(version = 0.2.0)\n    wo",
    "rld imports {\n        @since(version = 0.2.0)\n        import stable;\n    }\n    @since(version = 0.2.0)\n    interface sta",
    "ble {\n        resource stable-resource {\n        }\n    }\n}\n\npackage wasi:dep-unversioned{\n    world imports {\n        im",
    "port unversioned;\n    }\n    interface unversioned {\n        resource unversioned-resource {\n\n        }\n    }\n}\n\npackage ",
    "wasi:dep-unstable{\n    @unstable(feature = active)\n    world imports {\n        @unstable(feature = active)\n        impor",
    "t unstable;\n    }\n    @unstable(feature = active)\n    interface unstable {\n        @unstable(feature = active)\n        r",
    "esource unstable-resource {\n\n        }\n    }\n}\n\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-shared-deps/deps/dep1/types.wit" {
  let source = "package foo:dep1;\ninterface types {\n  type type1 = string;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-shared-deps/deps/dep2/types.wit" {
  let source = "package foo:dep2;\ninterface types {\n  type type2 = string;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-shared-deps/packages.wit" {
  let source = [
    "package foo:root;\npackage foo:bar {\n  interface i0 {\n    use foo:dep1/types.{type1};\n    use foo:dep2/types.{type2};\n   ",
    " record rec0 {\n      foo: type1,\n      bar: type2\n    }\n  }\n  world w-bar {\n    import foo:dep1/types;\n    import foo:de",
    "p2/types;\n  }\n}\n\npackage foo:qux {\n  interface i1 {\n    use foo:dep1/types.{type1};\n    use foo:dep2/types.{type2};\n    ",
    "record rec1 {\n      foo: type1,\n      bar: type2\n    }\n  }\n  world w-qux {\n    import foo:dep1/types;\n    import foo:dep",
    "2/types;\n  }\n}\n\ninterface root {\n  use foo:bar/i0.{rec0};\n  use foo:qux/i1.{rec1};\n  record rec {\n    first: rec0,\n    s",
    "econd: rec1\n  }\n}\n\n\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-transitive-deps/deps/dep1/types.wit" {
  let source = "package foo:dep1;\n\ninterface types {\n  use foo:dep2/types.{a};\n  record b {\n    r: a,\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-transitive-deps/deps/dep2/types.wit" {
  let source = "package foo:dep2;\n\ninterface types {\n  use foo:nest/types.{t2};\n  record a {\n    foo: t2\n  }\n}\n\npackage foo:nest {\n  interface types {\n    type t2 = string;\n  }\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax multi-package-transitive-deps/packages.wit" {
  let source = "package foo:root;\npackage foo:bar {\n  world w-bar {\n    import foo:dep1/types;\n  }\n}\n\npackage foo:qux {\n  world w-qux {\n    import foo:dep2/types;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax name-both-resource-and-type/deps/dep/foo.wit" {
  let source = "package some:dep;\n\ninterface foo {\n  resource a;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax name-both-resource-and-type/foo.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{a};\n\n  type t1 = a;\n  type t2 = borrow<a>;\n  type t3 = borrow<t1>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax package-syntax1.wit" {
  let source = "package foo:foo;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax package-syntax3.wit" {
  let source = "package foo:bar;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax package-syntax4.wit" {
  let source = "package foo:bar@2.0.0;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax packages-multiple-nested.wit" {
  let source = [
    "package foo:root;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n ",
    "       use i1.{a};\n    }\n  }\n}\n\npackage bar:name {\n  interface i2 {\n    type b = u32;\n  }\n\n  world w2 {\n    import imp2:",
    " interface {\n        use i2.{b};\n    }\n  }\n}\n\ninterface i0 {\n  use foo:name/i1.{a};\n\n  type c = option<a>;\n}\n\nworld w0 {",
    "\n  export i0;\n  import foo:name/i1;\n}",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax packages-nested-colliding-decl-names.wit" {
  let source = [
    "package foo:root;\npackage foo:name {\n  interface i {\n    type a = u32;\n  }\n\n  world w {\n    import imp: interface {\n    ",
    "    use i.{a};\n    }\n  }\n}\n\npackage bar:name {\n  interface i {\n    type a = u32;\n  }\n\n  world w {\n    import imp: interf",
    "ace {\n        use i.{a};\n    }\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax packages-nested-internal-references.wit" {
  let source = "package foo:root;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n}\n\npackage bar:name {\n  world w1 {\n    import imp1: interface {\n      use foo:name/i1.{a};\n\n      fn: func(a: a);\n    }\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax packages-nested-with-semver.wit" {
  let source = [
    "package foo:root;\npackage foo:name@1.0.0 {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interfa",
    "ce {\n        use i1.{a};\n    }\n  }\n}\n\npackage foo:name@1.0.1 {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    ",
    "import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax packages-single-nested.wit" {
  let source = "package foo:root;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-async.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: async get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-canonical-case.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: func();\n  PROP: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-canonical-hyphens.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  max-size: func();\n  maxsize: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-canonical-pair.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  // Getters and setters must have EXACTLY the same name (not just strongly-unique).\n  max-size: get() -> u64;\n  maxsize: set(value: u64);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-canonical-resource.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    max-size: func() -> u64;\n    maxsize: get() -> u64;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-canonical-world.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo-bar: func();\n  import foobar: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-duplicate-getter.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-getter-conflicts-func.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: func();\n  prop: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-getter-no-result.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-getter-params.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get(x: u32) -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-resource-canonical-static.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    foo-bar: get() -> u64;\n    foobar: static func() -> u64;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-resource-conflicts-method.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    position: func() -> u64;\n    position: get() -> u64;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-resource-duplicate-setter.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    position: get() -> u64;\n    position: set(value: u64);\n    position: static set(value: u64);\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-resource-static-mismatch.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    position: get() -> u64;\n    position: static set(value: u64);\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-setter-bad-result.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set(value: u32) -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-setter-bad-result2.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set(value: u32) -> result<u32, string>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-setter-no-getter.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: set(value: u32);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-setter-no-params.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-setter-two-params.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set(a: u32, b: u32);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-type-conflicts-getter.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type prop = u32;\n  prop: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-world-getter-conflicts.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import prop: func();\n  import prop: get() -> u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-world-setter-no-getter.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import prop: get() -> u32;\n  export prop: set(value: u32);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/accessor-world-setter-static-mismatch.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  resource blob {\n    position: static get() -> u64;\n    position: set(value: u64);\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/alias-no-type.wit" {
  let source = "// parse-fail\npackage foo:bar;\n\ninterface foo {\n  type foo = bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/async-bad-world.wit" {
  let source = "package a:b;\n\nworld foo {\n  import x: async func();\n  import x: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/async-bad-world2.wit" {
  let source = "package a:b;\n\nworld foo {\n  import x: async func();\n  import x: interface {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/async-bad-world3.wit" {
  let source = "package a:b;\n\nworld foo {\n  import x: async func();\n  record x {\n    a: u32,\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/async-bad-world4.wit" {
  let source = "package a:b;\n\nworld a {\n  import x: async func();\n}\n\nworld b {\n  include a;\n  import x: func();\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/async-bad1.wit" {
  let source = "package test:%async;\n\ninterface x {\n  resource z {\n    async constructor();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/async-bad2.wit" {
  let source = "package test:%async;\n\ninterface x {\n  resource z {\n    x: async static func();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-deprecated1.wit" {
  let source = "package a:b;\n\n@deprecated\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-deprecated2.wit" {
  let source = "package a:b;\n\n@deprecated()\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-deprecated3.wit" {
  let source = "package a:b;\n\n@deprecated(since = 1.2.3)\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-deprecated4.wit" {
  let source = "package a:b;\n\n@deprecated(since = 1.2.3)\n@deprecated(since = 1.2.3)\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-function.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  x: func(param: nonexistent);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-function2.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  x: func() -> nonexistent;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-gate-record-field.wit" {
  let source = "package a:b;\n\ninterface foo {\n  @unstable(feature = inactive)\n  type gated = u32;\n\n  record r {\n    field-a: u32,\n    field-b: gated,\n    field-c: string,\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-gate1.wit" {
  let source = "package a:b;\n\ninterface foo {\n  @unstable(feature = not-active)\n  type gated = u32;\n\n  type foo = gated;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-gate2.wit" {
  let source = "package a:b;\n\n@unstable(feature = not-active)\nworld a {}\n\nworld b {\n  include a;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-gate3.wit" {
  let source = "package a:b;\n\n@unstable(feature = not-active)\ninterface a {\n  type a = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-gate4.wit" {
  let source = "package a:b;\n\ninterface a {\n  @unstable(feature = inactive)\n  resource a {\n    constructor();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-gate5.wit" {
  let source = "package a:b;\n\ninterface a {\n  @unstable(feature = inactive)\n  resource a {\n    @unstable(feature = inactive)\n    constructor();\n\n    x: static func();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-include1.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  include non-existence;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-include2.wit" {
  let source = "package foo:foo;\n\nworld bar {\n    include foo;\n}\n\nworld foo {\n    include bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-include3.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  include foo;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-list.wit" {
  let source = "// parse-fail\n\ninterface foo {\n  type x = list<u32\n\n  type y = u32\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-list2.wit" {
  let source = "// parse-fail\n\ninterface foo {\n  type z = list<u32,\n\n  type y = u32\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-list3.wit" {
  let source = "// parse-fail\n\ninterface foo {\n  type a = list<u32,>\n\n  type y = u32\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-list4.wit" {
  let source = "// parse-fail\n\ninterface foo {\n  type b = list<u32, u32>\n\n  type y = u32\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg1/root.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  use nonexistent.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg2/deps/bar/empty.wit" {
  let source = "package foo:bar;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg2/root.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  use foo:bar/nonexistent.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg3/deps/bar/baz.wit" {
  let source = "package foo:bar;\nworld baz {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg3/root.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  use foo:bar/baz.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg4/deps/bar/baz.wit" {
  let source = "package foo:bar;\ninterface baz {\n  a-name: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg4/root.wit" {
  let source = "package foo:foo;\ninterface foo {\n  use foo:bar/baz.{a-name};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg5/deps/bar/baz.wit" {
  let source = "package foo:bar;\ninterface baz {\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg5/root.wit" {
  let source = "package foo:foo;\ninterface foo {\n  use foo:bar/baz.{nonexistent};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg6/deps/bar/baz.wit" {
  let source = "package foo:baz;\n\ninterface bar {}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-pkg6/root.wit" {
  let source = "package foo:foo;\ninterface foo {\n  use foo:bar/baz.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource1.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  type t = borrow<u32>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource10.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  type t = own<u32>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource11.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  type t = own<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource12.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  foo: func();\n  type t = own<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource13.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  type foo = u32;\n  type t = own<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource14.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {}\n  type t = own<a>;\n  type b = own<t>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource15/deps/foo/foo.wit" {
  let source = "package some:dep;\n\ninterface foo {\n  type r = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource15/foo.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{r};\n\n  type t = own<r>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource16.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {\n    constructor() -> result<_, string>;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource17.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource b;\n  resource a {\n    constructor() -> result<b, string>;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource2.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  type t = borrow<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource3.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  foo: func();\n  type t = borrow<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource4.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  type foo = u32;\n  type t = borrow<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource5.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {}\n  type t = borrow<a>;\n  type b = borrow<t>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource6.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {\n    constructor() -> u32;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource7.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {\n    constructor();\n    constructor();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource8.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {\n    a: func();\n    a: static func();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-resource9.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource a {\n    interface foo {}\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since-on-include.wit" {
  let source = "package test:invalid@0.1.0;\n\nworld a {}\n\nworld b {\n  @since(version = 0.2.0)\n  include a;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since-on-interface.wit" {
  let source = "package test:invalid@0.1.0;\n\n@since(version = 0.2.0)\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since-on-type.wit" {
  let source = "package test:invalid@0.1.0;\n\ninterface foo {\n  @since(version = 0.2.0)\n  type t = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since-on-world-import.wit" {
  let source = "package test:invalid@0.1.0;\n\nworld w {\n  @since(version = 0.2.0)\n  import x: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since-on-world.wit" {
  let source = "package test:invalid@0.1.0;\n\n@since(version = 0.2.0)\nworld w {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since1.wit" {
  let source = "package a:b;\n\n@since\ninterface foo1 {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-since3.wit" {
  let source = "package a:b;\n\n// for now `version` must come first\n@since(feature = foo, version = 1.0.0)\ninterface foo2 {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/bad-world-type1.wit" {
  let source = "package foo:foo;\nworld a {\n  type a = u32;\n  import a: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/case-insensitive-duplicates.wit" {
  let source = "// parse-fail\n\npackage poc:demo;\n\nworld example {\n  import get-data: func() -> string;\n  export get-user: func() -> string;\n  export GET-USER: func() -> string;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/case-insensitive-function-params.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  f: func(foo: u32, FOO: u64);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/conflicting-package/a.wit" {
  let source = "package foo:a;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/conflicting-package/b.wit" {
  let source = "package foo:b;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/cycle.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = foo;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/cycle2.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  type bar = foo;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/cycle3.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  type bar = option<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/cycle4.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  record bar { x: foo }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/cycle5.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  type bar = list<foo>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/dangling-type.wit" {
  let source = "// parse-fail\n\ninterface foo {\n  type\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-enum-cases.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  enum e { a, b, B }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-flags.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  flags f { a, b, A }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-function-params.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  foo: func(foo: u32, foo: u64);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-functions.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  foo: func();\n  foo: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-interface.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {}\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-interface2/foo.wit" {
  let source = "package foo:foo;\n\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-interface2/foo2.wit" {
  let source = "package foo:foo;\n\ninterface foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-record-fields.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  record r { a: u32, b: u32, a: u32 }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-type.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = s32;\n  type foo = s32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/duplicate-variant-cases.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  variant v { a-b(u32), ab }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/empty-enum.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  enum t {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/empty-tuple.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type t = tuple<>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/empty-variant1.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  variant t {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/export-twice.wit" {
  let source = "package foo:foo;\n\ninterface foo {}\n\nworld bar {\n  export foo;\n  export foo;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/implements-conflicts-func.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface store {\n  get: func() -> option<string>;\n}\n\nworld test {\n  import primary: func();\n  import primary: store;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/implements-duplicate-label.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface store {\n  get: func() -> option<string>;\n}\n\nworld test {\n  import primary: store;\n  import primary: store;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/implements-nonexistent.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface store {\n  get: func() -> option<string>;\n}\n\nworld test {\n  import primary: nonexistent;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/implements-not-interface.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\nworld test {\n  import primary: test;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/import-and-export1.wit" {
  let source = "package foo:foo;\ninterface i1 {\n  type t = u32;\n}\ninterface i2 {\n  use i1.{t};\n}\ninterface i3 {\n  use i2.{t};\n}\n\nworld test {\n  import i1: interface {}\n\n  export i1;\n  export i3;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/import-and-export2.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  type t = u32;\n}\n\ninterface bar {\n  use foo.{t};\n}\n\nworld baz {\n  export foo;\n  import bar;\n  export anon: interface {\n    use foo.{t};\n    use bar.{t as t2};\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/import-and-export3.wit" {
  let source = [
    "package foo:foo;\n\ninterface foo {}\ninterface bar {}\n\nworld the-world {\n  import foo;\n  import bar;\n  import baz: interfa",
    "ce {\n    foo: func();\n  }\n  export foo;\n  export bar;\n  export baz2: interface {\n    foo: func();\n  }\n}\n\nworld a-differe",
    "nt-world {\n  import foo;\n}\n\ninterface i1 {\n  type t = u32;\n}\ninterface i2 {\n  use i1.{t};\n}\ninterface i3 {\n  use i2.{t};",
    "\n}\n\nworld test {\n  import i3;\n  export i1;\n  export i3;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/import-and-export4.wit" {
  let source = [
    "package foo:foo;\n\n\nworld union-world {\n  include test;\n  include a-different-world;\n  include the-world;\n}\n\ninterface fo",
    "o {}\ninterface bar {}\n\nworld the-world {\n  import foo;\n  import bar;\n  import baz: interface {\n    foo: func();\n  }\n  ex",
    "port foo;\n  export bar;\n  export baz2: interface {\n    foo: func();\n  }\n}\n\nworld a-different-world {\n  import foo;\n}\n\nin",
    "terface i1 {\n  type t = u32;\n}\ninterface i2 {\n  use i1.{t};\n}\ninterface i3 {\n  use i2.{t};\n}\n\nworld test {\n  import i3;\n",
    "  export i1;\n  export i3;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/import-and-export5.wit" {
  let source = "package foo:bar;\n\ninterface a {\n  record x {\n    a: u32,\n  }\n}\n\ninterface b {\n  use a.{x};\n}\n\nworld w {\n  export anon: interface {\n    use b.{x as x2};\n    use a.{x};\n  }\n  export a;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/import-twice.wit" {
  let source = "package foo:foo;\n\ninterface foo {}\n\nworld bar {\n  import foo;\n  import foo;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-cycle.wit" {
  let source = "package foo:foo;\n\nworld a {\n    include b;\n}\n\nworld b {\n    include a;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-foreign/deps/bar/empty.wit" {
  let source = "package foo:bar;\n\ninterface bar {}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-foreign/root.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  include foo:bar/bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-setter-no-getter.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld base {\n  import other: func();\n}\n\nworld derived {\n  import prop: set(value: u32);\n  include base;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-strongly-unique.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld base {\n  import foo-bar: func();\n}\n\nworld derived {\n  include base;\n  import foobar: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-with-id.wit" {
  let source = "package foo:foo;\n\ninterface foo {}\n\nworld a {\n    import foo;\n}\n\nworld b {\n    include a with { foo:foo/foo as foo2 }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/include-with-on-id.wit" {
  let source = "package foo:foo;\n\ninterface foo {}\n\nworld a {\n    import foo;\n}\n\nworld b {\n    include a with { foo as foo2 }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/invalid-toplevel.wit" {
  let source = "// parse-fail\n\ninterface foo {\n  abcd\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/invalid-type-reference.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  x: func();\n\n  record foo {\n    // TODO: this should have a better error message referring to `x: func()`\n    a: x\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/invalid-type-reference2.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  x: func();\n  y: func() -> x;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/kebab-name-include-not-found.wit" {
  let source = "package foo:foo;\n\nworld foo { import a: func(); }\nworld bar { import a: func(); }\nworld baz {\n    include foo with { b1 as b2 }\n    include bar with { a as b }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/kebab-name-include.wit" {
  let source = "package foo:foo;\n\nworld foo { import a: func(); }\nworld bar { import a: func(); }\nworld baz {\n    include foo;\n    include bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/keyword.wit" {
  let source = "// parse-fail\n\ninterface kw {\n  type option = u32\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/map-invalid-key.wit" {
  let source = "// Map keys must be primitive types only\npackage foo:invalid-map-key;\n\ninterface test {\n  // This should fail - tuple is not a valid map key type\n  type invalid = map<tuple<u32, string>, u32>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/missing-main-declaration-initial-main.wit" {
  let source = "interface i1 {\n  type a = u32;\n}\n\nworld w1 {\n  import imp1: interface {\n    use i1.{a};\n  }\n}\n\n\npackage foo:name {\n  interface i2 {\n    type b = u32;\n  }\n\n  world w2 {\n    import imp2: interface {\n        use i2.{b};\n    }\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/missing-main-declaration-initial-nested.wit" {
  let source = "package foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n\n\ninterface i2 {\n  type b = u32;\n}\n\nworld w2 {\n  import imp2: interface {\n    use i2.{b};\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/missing-package.wit" {
  let source = ""
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multi-file-missing-delimiter/observe.wit" {
  let source = "interface observe {\n  record bar {\n    a : string,\n  }\n  // NB: intentionally missing a delimiter at the end of the file\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multi-file-missing-delimiter/world.wit" {
  let source = "package qux:qaz@2.0.0;\n\nworld platform {\n  import observe;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multi-package-deps-share-nest/deps/dep1/types.wit" {
  let source = "package foo:dep1;\n\npackage foo:shared {\n  interface shared1 {\n    type t1 = string;\n  }\n}\n\ninterface i1 {\n  use foo:shared/shared1.{t1};\n  type o1 = option<t1>;\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multi-package-deps-share-nest/deps/dep2/types.wit" {
  let source = "package foo:dep2;\n\npackage foo:shared {\n  interface shared2 {\n    type t2 = string;\n  }\n}\n\ninterface i2 {\n  use foo:shared/shared2.{t2};\n  type o2 = option<t2>;\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multi-package-deps-share-nest/root.wit" {
  let source = "package foo:root;\n\ninterface i0 {\n  use foo:dep1/i1.{o1};\n  use foo:dep2/i2.{o2};\n\n  type v = tuple<o1, o2>;\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multiple-package-docs/a.wit" {
  let source = "/// Multiple package docs, A;\npackage foo:foo;"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multiple-package-docs/b.wit" {
  let source = "/// Multiple package docs, B\npackage foo:foo;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multiple-package-inline-cycle.wit" {
  let source = "package foo:root;\npackage foo:bar {\n  interface i {\n    use foo:qux/i.{};\n  }\n}\n\npackage foo:qux {\n  interface i {\n    use foo:bar/i.{};\n  }\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/multiple-packages-no-scope-blocks.wit" {
  let source = "package foo:name;\n\ninterface i1 {\n  type a = u32;\n}\n\npackage bar:name;\n\nworld w1 {\n  import imp1: interface {\n    use foo:name/i1.{a};\n\n    fn: func(a: a);\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/nested-packages-colliding-names.wit" {
  let source = "package foo:root;\n\npackage foo:name {}\n\npackage foo:name {}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/nested-packages-with-error.wit" {
  let source = "package foo:root;\npackage foo:name {}\n\npackage bar:name {\n  interface unused {\n    type a = u32;\n  }\n\n  world w {\n    import imp: interface {\n        use missing.{a};\n    }\n  }\n}"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/no-access-to-sibling-use/bar.wit" {
  let source = "use bar as bar-renamed;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/no-access-to-sibling-use/foo.wit" {
  let source = "package foo:foo;\n\nuse bar-renamed;\n\ninterface bar {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/non-existence-world-include/deps/bar/baz.wit" {
  let source = "package foo:baz;\n\ninterface bar {}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/non-existence-world-include/root.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  include foo:baz/non-existence;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/old-float-types.wit" {
  let source = "package foo:bar;\n\ninterface a {\n  type t1 = float32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/package-nesting-too-deep.wit" {
  let source = [
    "// parse-fail\n\npackage a:b0 {\npackage a:b1 {\npackage a:b2 {\npackage a:b3 {\npackage a:b4 {\npackage a:b5 {\npackage a:b6 {\n",
    "package a:b7 {\npackage a:b8 {\npackage a:b9 {\npackage a:b10 {\npackage a:b11 {\npackage a:b12 {\npackage a:b13 {\npackage a:b",
    "14 {\npackage a:b15 {\npackage a:b16 {\npackage a:b17 {\npackage a:b18 {\npackage a:b19 {\npackage a:b20 {\npackage a:b21 {\npac",
    "kage a:b22 {\npackage a:b23 {\npackage a:b24 {\npackage a:b25 {\npackage a:b26 {\npackage a:b27 {\npackage a:b28 {\npackage a:b",
    "29 {\npackage a:b30 {\npackage a:b31 {\npackage a:b32 {\npackage a:b33 {\npackage a:b34 {\npackage a:b35 {\npackage a:b36 {\npac",
    "kage a:b37 {\npackage a:b38 {\npackage a:b39 {\npackage a:b40 {\npackage a:b41 {\npackage a:b42 {\npackage a:b43 {\npackage a:b",
    "44 {\npackage a:b45 {\npackage a:b46 {\npackage a:b47 {\npackage a:b48 {\npackage a:b49 {\npackage a:b50 {\npackage a:b51 {\npac",
    "kage a:b52 {\npackage a:b53 {\npackage a:b54 {\npackage a:b55 {\npackage a:b56 {\npackage a:b57 {\npackage a:b58 {\npackage a:b",
    "59 {\npackage a:b60 {\npackage a:b61 {\npackage a:b62 {\npackage a:b63 {\npackage a:b64 {\npackage a:b65 {\npackage a:b66 {\npac",
    "kage a:b67 {\npackage a:b68 {\npackage a:b69 {\npackage a:b70 {\npackage a:b71 {\npackage a:b72 {\npackage a:b73 {\npackage a:b",
    "74 {\npackage a:b75 {\npackage a:b76 {\npackage a:b77 {\npackage a:b78 {\npackage a:b79 {\npackage a:b80 {\npackage a:b81 {\npac",
    "kage a:b82 {\npackage a:b83 {\npackage a:b84 {\npackage a:b85 {\npackage a:b86 {\npackage a:b87 {\npackage a:b88 {\npackage a:b",
    "89 {\npackage a:b90 {\npackage a:b91 {\npackage a:b92 {\npackage a:b93 {\npackage a:b94 {\npackage a:b95 {\npackage a:b96 {\npac",
    "kage a:b97 {\npackage a:b98 {\npackage a:b99 {\npackage a:b100 {\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n",
    "}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n",
    "}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/pkg-cycle/deps/a1/root.wit" {
  let source = "package foo:a1;\ninterface foo {\n  use foo:a1/foo.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/pkg-cycle/root.wit" {
  let source = "package foo:foo;\ninterface foo {\n  use foo:a1/foo.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/pkg-cycle2/deps/a1/root.wit" {
  let source = "package foo:a1;\ninterface foo {\n  use foo:a2/foo.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/pkg-cycle2/deps/a2/root.wit" {
  let source = "package foo:a2;\ninterface foo {\n  use foo:a1/foo.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/pkg-cycle2/root.wit" {
  let source = "package foo:root;\ninterface foo {\n  use foo:a1/foo.{};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/resource-method-named-after-resource.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource foo {\n    foo: func();\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/resources-multiple-returns-borrow.wit" {
  let source = "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: borrow<r1>) -> ();\n\n  resource r1 {\n    f1: func() -> (a: s32, handle: borrow<r1>);\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/resources-return-borrow.wit" {
  let source = "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: borrow<r1>) -> ();\n\n  resource r1 {\n    f1: func() -> borrow<r1>;\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow1.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource y;\n\n  x: func() -> borrow<y>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow2.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource y {\n    x: func() -> borrow<y>;\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow3.wit" {
  let source = "package foo:bar;\n\nworld foo {\n  resource y {\n    x: func() -> borrow<y>;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow4.wit" {
  let source = "package foo:bar;\n\nworld foo {\n  resource y;\n\n  import x: func() -> borrow<y>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow5.wit" {
  let source = "package foo:bar;\n\nworld foo {\n  resource y;\n\n  export x: func() -> borrow<y>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow6.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource y;\n\n  x: func() -> tuple<borrow<y>>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow7.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  resource y;\n\n  record y2 {\n    a: borrow<y>,\n  }\n\n  x: func() -> y2;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow8/deps/baz.wit" {
  let source = "package foo:baz;\n\ninterface i {\n  resource my-resource;\n\n  record r {\n    x: borrow<my-resource>,\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/return-borrow8/foo.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  use foo:baz/i.{r};\n\n  x: func() -> r;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/too-many-flags.wit" {
  let source = [
    "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  flags f {\n    b0,\n    b1,\n    b2,\n    b3,\n    b4,\n    b5,\n    b6,\n    ",
    "b7,\n    b8,\n    b9,\n    b10,\n    b11,\n    b12,\n    b13,\n    b14,\n    b15,\n    b16,\n    b17,\n    b18,\n    b19,\n    b20,\n ",
    "   b21,\n    b22,\n    b23,\n    b24,\n    b25,\n    b26,\n    b27,\n    b28,\n    b29,\n    b30,\n    b31,\n    b32,\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/type-and-resource-same-name/deps/dep/foo.wit" {
  let source = "package some:dep;\n\ninterface foo {\n  type a = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/type-and-resource-same-name/foo.wit" {
  let source = "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{a};\n\n  type t1 = a;\n  type t2 = borrow<a>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/type-nesting-too-deep.wit" {
  let source = [
    "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type t =\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n",
    "    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    u8\n   ",
    " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/undefined-typed.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unknown-interface.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-interface1.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-interface2.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import bar;\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-interface3.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nuse bar as foo;\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-interface4.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import some:dependency/iface;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use1.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use10/bar.wit" {
  let source = "package foo:foo;\n\ninterface bar {\n  use foo.{thing};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use10/foo.wit" {
  let source = "interface foo {\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use2.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n\ninterface bar {\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use3.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n\ninterface bar {\n  x: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use7.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n\ninterface bar {\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use8.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo: interface {\n    use foo.{i32};\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/unresolved-use9.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo: interface {\n    use bar.{i32};\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-and-include-world/deps/bar/baz.wit" {
  let source = "package foo:baz;\n\nworld bar {}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-and-include-world/root.wit" {
  let source = "package foo:foo;\n\nuse foo:baz/bar;\n\nworld foo {\n    include foo:baz/bar;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-conflict.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x, x};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-conflict2.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x};\n\n  type x = s64;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-conflict3.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x};\n\n  x: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-cycle1.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use foo.{bar};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-cycle4.wit" {
  let source = "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  use bar.{y};\n\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x};\n\n  type y = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-shadow1.wit" {
  let source = "package foo:foo;\n\nuse foo as bar;\n\ninterface foo {}\n\ninterface bar {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-world/deps/bar/baz.wit" {
  let source = "package foo:baz;\n\nworld bar {}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/use-world/root.wit" {
  let source = "package foo:foo;\n\nuse foo:baz/bar;\n\nworld foo {\n\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/very-large-column.wit" {
  let source = [
    "package demo:hellaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "aaaaaaaaaaaaaaaaworld hello {\naaaaaaaaaaaaaaaao\n  export run: fworld hello {\n run: f)\nworld hello {\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/very-nested-packages.wit" {
  let source = "package a:b;\n\npackage a:c {\n  package a:c2 {\n    package a:c3 {\n    }\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/world-interface-clash.wit" {
  let source = "package foo:foo;\ninterface foo {}\nworld foo {}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/world-same-fields2.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld a {\n  import foo: interface {}\n  import foo: interface {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/world-same-fields3.wit" {
  let source = "// parse-fail\n\npackage foo:foo;\n\nworld a {\n  export foo: interface {}\n  export foo: interface {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/world-top-level-func.wit" {
  let source = "package foo:foo;\nworld foo {\n  import foo: func();\n  import foo: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax parse-fail/world-top-level-func2.wit" {
  let source = "package foo:foo;\nworld foo {\n  import foo: func(a: b);\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax random.wit" {
  let source = [
    "package wasi:random;\n\n/// WASI Random is a random data API.\n///\n/// It is intended to be portable at least between Unix-",
    "family platforms and\n/// Windows.\ninterface random {\n    /// Return `len` cryptographically-secure random or pseudo-rand",
    "om bytes.\n    ///\n    /// This function must produce data at least as cryptographically secure and\n    /// fast as an ad",
    "equately seeded cryptographically-secure pseudo-random\n    /// number generator (CSPRNG). It must not block, from the pe",
    "rspective of\n    /// the calling program, under any circumstances, including on the first\n    /// request and on request",
    "s for numbers of bytes. The returned data must\n    /// always be unpredictable.\n    ///\n    /// This function must alway",
    "s return fresh data. Deterministic environments\n    /// must omit this function, rather than implementing it with determ",
    "inistic\n    /// data.\n    get-random-bytes: func(len: u64) -> list<u8>;\n\n    /// Return a cryptographically-secure rando",
    "m or pseudo-random `u64` value.\n    ///\n    /// This function returns the same type of data as `get-random-bytes`,\n    /",
    "// represented as a `u64`.\n    get-random-u64: func() -> u64;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax resources-empty.wit" {
  let source = "package foo:resources-empty;\n\ninterface resources-empty {\n  t1: func(a: own<r1>);\n  t2: func(a: borrow<r1>);\n\n  resource r1 {\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax resources-multiple-returns-own.wit" {
  let source = "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: own<r1>);\n\n  resource r1 {\n    f1: func() -> tuple<s32, own<r1>>;\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax resources-multiple.wit" {
  let source = [
    "package foo:resources-multiple;\n\ninterface resources-multiple {\n  t1: func(a: borrow<r1>);\n  t2: func(a: own<r1>);\n\n  re",
    "source r1 {\n    f1: func();\n    f2: func(a: u32);\n    f3: func(a: u32,);\n    f4: func() -> u32;\n    f6: func() -> tuple<",
    "u32, u32>;\n    f7: func(a: f32, b: f32) -> tuple<u32, u32>;\n    f8: func(a: option<u32>) -> result<u32, f32>;\n  }\n}\n\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax resources-return-own.wit" {
  let source = "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: own<r1>);\n\n  resource r1 {\n    f1: func() -> own<r1>;\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax resources.wit" {
  let source = [
    "package foo:bar;\n\ninterface foo {\n  resource a {\n  }\n\n  resource b {\n    constructor();\n  }\n\n  resource c {\n    construc",
    "tor(x: u32);\n  }\n\n  resource d {\n    constructor(x: u32);\n\n    a: func();\n\n    b: static func();\n  }\n\n  resource e {\n   ",
    " constructor(other: own<e>, other2: borrow<e>);\n\n    method: func(thing: own<e>, thing2: borrow<e>);\n  }\n\n  resource f {",
    "\n    constructor() -> result<f>;\n  }\n\n  resource g {\n    constructor() -> result<g, string>;\n  }\n}\n\nworld w {\n  resource",
    " a;\n\n  resource b {\n  }\n\n  resource c {\n    constructor();\n  }\n}\n\ninterface i {\n  resource a;\n\n  type t1 = a;\n  type t2 ",
    "= borrow<a>;\n  type t3 = borrow<t1>;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax resources1.wit" {
  let source = "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: borrow<r1>);\n  t2: func(a: own<r1>);\n  t3: func(a: r1);\n\n  resource r1 {\n    f1: func();\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax same-name-import-export.wit" {
  let source = "package demo:greeter;\n\nworld greeter {\n    import greet: func() -> string;\n    export greet: func() -> string;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax shared-types.wit" {
  let source = "package foo:shared-items;\n\nworld foo {\n  import foo: interface {\n    a: func() -> list<u8>;\n  }\n  export bar: interface {\n    a: func() -> tuple<list<u8>>;\n  }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax since-and-unstable.wit" {
  let source = [
    "package a:b@1.0.1;\n\n@since(version = 1.0.0)\ninterface foo1 {}\n\n@since(version = 1.0.0)\ninterface foo2 {}\n\n@since(version",
    " = 1.0.0)\ninterface foo3 {}\n\n@unstable(feature = foo2)\ninterface foo4 {}\n\n@since(version = 1.0.1)\nworld w1 {}\n\n@since(ve",
    "rsion = 1.0.0)\nworld w2 {}\n\ninterface in-an-interface {\n  @since(version = 1.0.0)\n  foo: func();\n  @since(version = 1.0.",
    "0)\n  resource r1;\n  @since(version = 1.0.0)\n  resource r2 {}\n\n  @since(version = 1.0.0)\n  type t1 = u32;\n  @since(versio",
    "n = 1.0.0)\n  record t2 { a: u32 }\n  @since(version = 1.0.0)\n  enum t3 { a }\n  @since(version = 1.0.0)\n  flags t4 { a }\n ",
    " @since(version = 1.0.0)\n  variant t5 { a }\n\n  @since(version = 1.0.0)\n  resource r3 {\n    @since(version = 1.0.0)\n    c",
    "onstructor();\n\n    @since(version = 1.0.0)\n    x1: static func();\n\n    @since(version = 1.0.0)\n    x2: func();\n  }\n}\n\nin",
    "terface z {}\n\nworld in-a-world {\n  @since(version = 1.0.0)\n  import x: func();\n  @since(version = 1.0.0)\n  export x: fun",
    "c();\n\n  @since(version = 1.0.0)\n  import y: interface {}\n  @since(version = 1.0.0)\n  export y: interface {}\n\n  @since(ve",
    "rsion = 1.0.0)\n  import z;\n  @since(version = 1.0.0)\n  export z;\n\n\n  @since(version = 1.0.0)\n  record t1 { x: u32 }\n  @s",
    "ince(version = 1.0.0)\n  enum t2 { a }\n  @since(version = 1.0.0)\n  variant t3 { a }\n  @since(version = 1.0.0)\n  flags t4 ",
    "{ a }\n  @since(version = 1.0.0)\n  type t5 = u32;\n  @since(version = 1.0.0)\n  resource t6;\n  @since(version = 1.0.0)\n  re",
    "source t7 {\n    @since(version = 1.0.0)\n    constructor();\n  }\n}\n\ninterface deprecated1 {\n  @since(version = 1.0.0)\n  @d",
    "eprecated(version = 1.0.1)\n  type t1 = u32;\n\n  @deprecated(version = 1.0.1)\n  @since(version = 1.0.0)\n  type t2 = u32;\n\n",
    "  @unstable(feature = foo)\n  @deprecated(version = 1.0.1)\n  type t3 = u32;\n\n  @deprecated(version = 1.0.1)\n  @unstable(f",
    "eature = foo)\n  type t4 = u32;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax streams-and-futures.wit" {
  let source = [
    "package foo:streams-and-futures;\n\ninterface streams-and-futures {\n  type t1 = stream<u8>;\n  type t2 = stream<stream<stri",
    "ng>>;\n  type t3 = future;\n  type t4 = future<list<u8>>;\n  type t5 = option<stream<future>>;\n  resource r1;\n  type t6 = s",
    "tream<r1>;\n  type t7 = future<result<r1>>;\n  type t8 = stream;\n\n  foo: func(x: stream<u32>, y: t6) -> future<result<list",
    "<string>, string>>;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax stress-export-elaborate.wit" {
  let source = [
    "package foo:bar;\n\ninterface i1 {\n  type t1 = u32;\n  type t2 = u32;\n  type t3 = u32;\n  type t4 = u32;\n  type t5 = u32;\n  ",
    "type t6 = u32;\n  type t7 = u32;\n  type t8 = u32;\n  type t9 = u32;\n  type t10 = u32;\n}\n\ninterface i2 {\n  use i1.{t1, t2, ",
    "t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i3 {\n  use i2.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i4 ",
    "{\n  use i3.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i5 {\n  use i4.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t1",
    "0};\n}\n\ninterface i6 {\n  use i5.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i7 {\n  use i6.{t1, t2, t3, t4, t5",
    ", t6, t7, t8, t9, t10};\n}\n\ninterface i8 {\n  use i7.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i9 {\n  use i8",
    ".{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i10 {\n  use i9.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\nwo",
    "rld foo {\n  export i10;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax type-then-eof.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  foo: func() -> string;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax types.wit" {
  let source = [
    "package foo:types;\n\ninterface types {\n  type t1 = u8;\n  type t2 = u16;\n  type t3 = u32;\n  type t4 = u64;\n  type t5 = s8;",
    "\n  type t6 = s16;\n  type t7 = s32;\n  type t8 = s64;\n  type t9a = f32;\n  type t9b = f32;\n  type t10a = f64;\n  type t10b =",
    " f64;\n  type t11 = char;\n  type t12 = list<char>;\n  type t13 = string;\n  type t14 = option<u32>;\n  type t15 = result<u32",
    ", u32>;\n  type t16 = result<_, u32>;\n  type t17 = result<u32>;\n  type t18 = result;\n  record t19 { a: u32 }\n  record t20",
    " { a: u32, }\n  record t21 { a: u32, b: u64 }\n  record t22 { a: u32, b: u64, }\n  record t23 { x: u32 }\n  record %record {",
    " a: u32 }\n  type t25 = tuple<u32>;\n  type t26 = tuple<u32,>;\n  type t27 = tuple<u32, u64>;\n  flags t28 { a, b, c }\n  fla",
    "gs t29 { a, b, c, }\n  variant t30 { a }\n  variant t31 { a, b }\n  variant t32 { a, b, }\n  variant t33 { a, b(u32), }\n  va",
    "riant t34 { a, b(option<u32>), }\n  enum t35 { a, b, c }\n  enum t36 { a, b, c, }\n  type t37 = bool;\n  type t38 = string;\n",
    "  type t39 = list<list<list<t32>>>;\n  type t40 = t44;\n  type t41 = %t44;\n  type t42 = stream<u32>;\n  type t43 = future<u",
    "32>;\n  type t44 = future;\n  type t45a = list<u32, 4>;\n  type t45b = list<list<u32, 4>, 2>;\n\n  /// type order doesn't mat",
    "ter\n  type foo = bar;\n  type bar = u32;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax union-fuzz-1.wit" {
  let source = "package foo:bar;\n\nworld xo {}\n\nworld name {}\n\nworld x {\n    include name;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax union-fuzz-2.wit" {
  let source = "package foo:bar;\n\nworld foo {\n    export foo: func() -> f32;\n}\n\n\nworld bar {\n    include foo;\n\n    record foo {\n        a: u32,\n    }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax unstable-resource.wit" {
  let source = [
    "package a:b@0.1.0;\n\ninterface foo {\n  @unstable(feature = inactive)\n  use wasi:io/error@0.1.0.{error};\n\n  @unstable(feat",
    "ure = inactive)\n  x: func(y: borrow<error>);\n}\n\npackage wasi:io@0.1.0 {\n  interface error {\n    resource error;\n  }\n}\n\n\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax use-chain.wit" {
  let source = "package foo:name;\n\ninterface foo {\n  record foo {\n    a: u32,\n  }\n}\n\nuse foo as bar;\n\ninterface name {\n  use bar.{foo};\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax use.wit" {
  let source = [
    "package foo:foo;\n\ninterface foo {\n  use bar.{the-type};\n}\n\ninterface bar {\n  type the-type = u32;\n}\n\ninterface baz {\n  u",
    "se foo.{the-type};\n  use bar.{the-type as test};\n}\n\ninterface empty {\n}\n\ninterface use-from-empty {\n  use empty.{};\n  us",
    "e empty.{};\n}\n\ninterface use-multiple {\n  use baz.{the-type, test};\n\n  some-function: func(x: the-type) -> test;\n}\n\ninte",
    "rface trailing-comma {\n  use foo.{the-type,};\n\n  record the-foo { a: the-type }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax version-syntax.wit" {
  let source = [
    "package foo:root;\npackage a:b@1.0.0 {}\npackage a:b@1.0.1 {}\npackage a:b@1.0.1-- {}\npackage a:b@1.0.1-a+a {}\npackage a:b@",
    "1.0.1-1+1 {}\npackage a:b@1.0.1-1a+1a {}\npackage a:b@1.0.0-11-a {}\npackage a:b@1.0.0-a1.1-a {}\npackage a:b@1.0.0-11ab {}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax versions/deps/a1/foo.wit" {
  let source = "package a:a@1.0.0;\n\ninterface foo {\n  type t = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax versions/deps/a2/foo.wit" {
  let source = "package a:a@2.0.0;\n\ninterface foo {\n  type t = u32;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax versions/foo.wit" {
  let source = "package foo:versions;\n\ninterface foo {\n  use a:a/foo@1.0.0.{t};\n  use a:a/foo@2.0.0.{t as t2};\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax wasi.wit" {
  let source = [
    "package wasi:filesystem;\n\ninterface wasi {\n  enum clockid {\n    /// The clock measuring real time. Time value zero corre",
    "sponds with\n    /// 1970-01-01T00:00:00Z.\n    realtime,\n    /// The store-wide monotonic clock, which is defined as a cl",
    "ock measuring\n    /// real time, whose value cannot be adjusted and which cannot have negative\n    /// clock jumps. The ",
    "epoch of this clock is undefined. The absolute time\n    /// value of this clock therefore has no meaning.\n    monotonic,",
    "\n  }\n\n  /// Timestamp in nanoseconds.\n  type timestamp = u64;\n\n  /// Error codes returned by functions.\n  /// Not all of",
    " these error codes are returned by the functions provided by this\n  /// API/ some are used in higher-level library layer",
    "s, and others are provided\n  /// merely for alignment with POSIX.\n  enum errno {\n    /// No error occurred. System call ",
    "completed successfully.\n    success,\n    /// Argument list too long.\n    toobig,\n    /// Permission denied.\n    access,\n",
    "    /// Address in use.\n    addrinuse,\n    /// Address not available.\n    addrnotavail,\n    /// Address family not suppo",
    "rted.\n    afnosupport,\n    /// Resource unavailable, or operation would block.\n    again,\n    /// Connection already in ",
    "progress.\n    already,\n    /// Bad file descriptor.\n    badf,\n    /// Bad message.\n    badmsg,\n    /// Device or resourc",
    "e busy.\n    busy,\n    /// Operation canceled.\n    canceled,\n    /// No child processes.\n    child,\n    /// Connection ab",
    "orted.\n    connaborted,\n    /// Connection refused.\n    connrefused,\n    /// Connection reset.\n    connreset,\n    /// Re",
    "source deadlock would occur.\n    deadlk,\n    /// Destination address required.\n    destaddrreq,\n    /// Mathematics argu",
    "ment out of domain of function.\n    dom,\n    /// Reserved.\n    dquot,\n    /// File exists.\n    exist,\n    /// Bad addres",
    "s.\n    fault,\n    /// File too large.\n    fbig,\n    /// Host is unreachable.\n    hostunreach,\n    /// Identifier removed",
    ".\n    idrm,\n    /// Illegal byte sequence.\n    ilseq,\n    /// Operation in progress.\n    inprogress,\n    /// Interrupted",
    " function.\n    intr,\n    /// Invalid argument.\n    inval,\n    /// I/O error.\n    io,\n    /// Socket is connected.\n    is",
    "conn,\n    /// Is a directory.\n    isdir,\n    /// Too many levels of symbolic links.\n    loop,\n    /// File descriptor va",
    "lue too large.\n    mfile,\n    /// Too many links.\n    mlink,\n    /// Message too large.\n    msgsize,\n    /// Reserved.\n ",
    "   multihop,\n    /// Filename too long.\n    nametoolong,\n    /// Network is down.\n    netdown,\n    /// Connection aborte",
    "d by network.\n    netreset,\n    /// Network unreachable.\n    netunreach,\n    /// Too many files open in system.\n    nfil",
    "e,\n    /// No buffer space available.\n    nobufs,\n    /// No such device.\n    nodev,\n    /// No such file or directory.\n",
    "    noent,\n    /// Executable file format error.\n    noexec,\n    /// No locks available.\n    nolck,\n    /// Reserved.\n  ",
    "  nolink,\n    /// Not enough space.\n    nomem,\n    /// No message of the desired type.\n    nomsg,\n    /// Protocol not a",
    "vailable.\n    noprotoopt,\n    /// No space left on device.\n    nospc,\n    /// Function not supported.\n    nosys,\n    ///",
    " The socket is not connected.\n    notconn,\n    /// Not a directory or a symbolic link to a directory.\n    notdir,\n    //",
    "/ Directory not empty.\n    notempty,\n    /// State not recoverable.\n    notrecoverable,\n    /// Not a socket.\n    notsoc",
    "k,\n    /// Not supported, or operation not supported on socket.\n    notsup,\n    /// Inappropriate I/O control operation.",
    "\n    notty,\n    /// No such device or address.\n    nxio,\n    /// Value too large to be stored in data type.\n    overflow",
    ",\n    /// Previous owner died.\n    ownerdead,\n    /// Operation not permitted.\n    perm,\n    /// Broken pipe.\n    pipe,\n",
    "    /// Protocol error.\n    proto,\n    /// Protocol not supported.\n    protonosupport,\n    /// Protocol wrong type for s",
    "ocket.\n    prototype,\n    /// Result too large.\n    range,\n    /// Read-only file system.\n    rofs,\n    /// Invalid seek",
    ".\n    spipe,\n    /// No such process.\n    srch,\n    /// Reserved.\n    stale,\n    /// Connection timed out.\n    timedout,",
    "\n    /// Text file busy.\n    txtbsy,\n    /// Cross-device link.\n    xdev,\n    /// Extension: Capabilities insufficient.\n",
    "    notcapable,\n  }\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax with-resource-as.wit" {
  let source = "package foo:foo;\n\nworld a {\n  resource r {\n    constructor();\n    m: func();\n    sm: static func();\n  }\n  import f: func(x: r) -> option<r>;\n  export g: func(x: r) -> option<r>;\n}\n\nworld b {\n  include a with { r as s }\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-diamond.wit" {
  let source = [
    "package foo:foo;\n\ninterface shared-items {\n  type foo = u32;\n}\n\ninterface i1 {\n  use shared-items.{foo};\n\n  a: func() ->",
    " foo;\n}\n\ninterface i2 {\n  use shared-items.{foo};\n\n  a: func() -> foo;\n}\n\nworld the-world {\n  import i1;\n  import i2;\n  ",
    "import a: func();\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-iface-no-collide.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  type t = u32;\n}\n\nworld bar {\n  use foo.{t};\n\n  import foo: func();\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-implicit-import1.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  type a = u32;\n}\n\nworld the-world {\n  import bar: interface {\n    use foo.{a};\n  }\n  import foo: interface {}\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-implicit-import2.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  type g = char;\n}\n\nworld w {\n  use foo.{g};\n\n  import foo: func() -> g;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-implicit-import3.wit" {
  let source = "package foo:foo;\n\ninterface foo {\n  type g = char;\n}\n\nworld w {\n  use foo.{g};\n\n  export foo: func() -> g;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-same-fields4.wit" {
  let source = "package foo:foo;\n\ninterface shared-items {\n  type a = u32;\n}\n\nworld foo {\n  import shared-items: interface {}\n  export a-name: interface {\n    use shared-items.{a};\n  }\n}\n\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-top-level-funcs.wit" {
  let source = "package foo:foo;\n\nworld foo {\n  import foo: func();\n  export foo2: func();\n\n  import bar: func(arg: list<u32>);\n  export some-name: func() -> list<option<u32>>;\n}\n"
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax world-top-level-resources.wit" {
  let source = [
    "package foo:foo;\n\ninterface types {\n  resource request {\n    foo: func();\n    bar: func(arg: list<u32>);\n  }\n\n  resource",
    " response {\n    foo: func();\n    bar: func(arg: list<u32>);\n  }\n}\n\ninterface handler {\n  use types.{request, response};\n",
    "  handle: func(some: borrow<request>) -> response;\n  handle-owned: func(some: own<request>) -> own<response>;\n}\n\nworld p",
    "roxy {\n  import handler;\n  export handler;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax worlds-union-dedup.wit" {
  let source = [
    "package foo:foo;\n\ninterface a1 { }\ninterface a2 { }\ninterface b1 { }\ninterface b2 { }\ninterface c { }\ninterface d { }\n\nw",
    "orld my-world-a {\n    import a1;\n    import b1;\n}\n\nworld my-world-b {\n    import a1;\n    import b1;\n}\n\nworld union-my-wo",
    "rld {\n    include my-world-a;\n    include my-world-b;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter wasm-tools syntax worlds-with-types.wit" {
  let source = [
    "package foo:foo;\n\nworld foo {\n  type a = u32;\n  type b = a;\n\n  export c: func(a: a) -> b;\n}\n\n\ninterface disambiguate {\n ",
    " type t = u32;\n}\n\nworld bar {\n  import disambiguate;\n\n  use disambiguate.{t};\n\n  export foo: func() -> t;\n}\n\nworld the-t",
    "est {\n  record a {\n    x: u32,\n  }\n\n  variant b {\n    c(a),\n  }\n\n  import foo: func(a: a) -> b;\n  export bar: func(a: a)",
    " -> b;\n}\n",
  ].join("")
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 0" {
  let source =
    #|package wasi:clocks;
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 1" {
  let source =
    #|package wasi:clocks@1.2.0;
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 2" {
  let source =
    #|package local:a {
    #|    interface foo {}
    #|}
    #|
    #|package local:b {
    #|    interface bar {}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 3" {
  let source =
    #|package local:demo;
    #|
    #|interface host {
    #|    log: func(msg: string);
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 4" {
  let source =
    #|package wasi:filesystem;
    #|
    #|interface types {
    #|    use wasi:clocks/wall-clock.{datetime};
    #|
    #|    record stat {
    #|      ino: u64,
    #|      size: u64,
    #|      mtime: datetime,
    #|      // ...
    #|    }
    #|
    #|    stat-file: func(path: string) -> result<stat>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 5" {
  let source =
    #|package local:demo;
    #|
    #|world my-world {
    #|    import host: interface {
    #|      log: func(param: string);
    #|    }
    #|
    #|    export run: func();
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 6" {
  let source =
    #|package local:demo;
    #|
    #|world command {
    #|    import wasi:filesystem/filesystem;
    #|    import wasi:random/random;
    #|    import wasi:clocks/monotonic-clock;
    #|    // ...
    #|
    #|    export main: func(args: list<string>);
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 7" {
  let source =
    #|package local:demo;
    #|
    #|interface out-of-line {
    #|    the-function: func();
    #|}
    #|
    #|world your-world {
    #|    import out-of-line;
    #|    // ... is roughly equivalent to ...
    #|    import out-of-line: interface {
    #|      the-function: func();
    #|    }
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 8" {
  let source =
    #|package local:demo;
    #|
    #|interface my-interface {
    #|    // ..
    #|}
    #|
    #|world command {
    #|    // generates an import of the name `local:demo/my-interface`
    #|    import my-interface;
    #|
    #|    // generates an import of the name `wasi:filesystem/types`
    #|    import wasi:filesystem/types;
    #|
    #|    // generates an import of the plain name `foo`
    #|    import foo: func();
    #|
    #|    // generates an import of the plain name `bar`
    #|    import bar: interface {
    #|      // ...
    #|    }
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 9" {
  let source =
    #|package local:demo;
    #|
    #|// definitions of a, b, c, foo, bar, baz are omitted
    #|
    #|world my-world-a {
    #|    import a;
    #|    import b;
    #|    export c;
    #|}
    #|
    #|world my-world-b {
    #|    import foo;
    #|    import bar;
    #|    export baz;
    #|}
    #|
    #|world union-my-world {
    #|    include my-world-a;
    #|    include my-world-b;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 10" {
  let source =
    #|world union-my-world {
    #|    import a;
    #|    import b;
    #|    export c;
    #|    import foo;
    #|    import bar;
    #|    export baz;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 11" {
  let source =
    #|package local:demo;
    #|
    #|world my-world-a {
    #|    import a1;
    #|    import b1;
    #|}
    #|
    #|world my-world-b {
    #|    import a1;
    #|    import b1;
    #|}
    #|
    #|world union-my-world-a {
    #|    include my-world-a;
    #|    include my-world-b;
    #|}
    #|
    #|world union-my-world-b {
    #|    import a1;
    #|    import b1;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 12" {
  let source =
    #|package local:demo;
    #|
    #|world world-one { import a: func(); }
    #|world world-two { import a: func(); }
    #|
    #|world union-my-world-a {
    #|    include world-one;
    #|    include world-two with { a as b }
    #|}
    #|
    #|world union-my-world-b {
    #|    import a: func();
    #|    import b: func();
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 13" {
  let source =
    #|package local:demo;
    #|
    #|interface store {
    #|    get: func(key: string) -> option<string>;
    #|}
    #|
    #|world base {
    #|    import cache: store;
    #|}
    #|
    #|world extended {
    #|    import cache: func();
    #|    include base with { cache as my-cache }
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 14" {
  let source =
    #|world base-a {
    #|    import cache: store;
    #|}
    #|
    #|world base-b {
    #|    import cache: store;
    #|}
    #|
    #|world conflict {
    #|    include base-a;
    #|    include base-b;  // error: plain name 'cache' conflicts
    #|}
    #|
    #|world resolved {
    #|    include base-a;
    #|    include base-b with { cache as other-cache }  // ok: renamed to avoid conflict
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 15" {
  let source =
    #|package local:demo;
    #|
    #|interface a {
    #|    foo: func();
    #|}
    #|
    #|world world-using-a {
    #|    import a;
    #|}
    #|
    #|world invalid-union-world {
    #|    include world-using-a with { a as b }  // invalid: 'a', which is short for 'local:demo/a', is an interface name
    #|}
    #|
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 16" {
  let source =
    #|package local:demo;
    #|
    #|interface types {
    #|    enum errno { /* ... */ }
    #|
    #|    type size = u32;
    #|}
    #|
    #|interface my-host-functions {
    #|    use types.{errno, size};
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 17" {
  let source =
    #|package local:demo;
    #|
    #|interface my-host-functions {
    #|    use types.{errno as my-errno};
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 20" {
  let source =
    #|package local:demo;
    #|
    #|world my-world {
    #|    import wasi:clocks/monotonic-clock;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 21" {
  let source =
    #|package local:demo;
    #|
    #|interface my-interface {
    #|    use wasi:http/types.{request, response};
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 22" {
  let source =
    #|package local:demo;
    #|
    #|interface my-interface {
    #|    use wasi:http/types@1.0.0.{request, response};
    #|}
    #|
    #|world my-world {
    #|    import wasi:http/handler@1.0.0;
    #|    export wasi:http/handler@1.0.0;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 23" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types@1.0.0;
    #|use wasi:http/handler@1.0.0;
    #|
    #|interface my-interface {
    #|    use types.{request, response};
    #|}
    #|
    #|world my-world {
    #|    import handler;
    #|    export handler;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 24" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types;   // defines the name `types`
    #|use wasi:http/handler; // defines the name `handler`
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 25" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types as http-types;
    #|use wasi:http/handler as http-handler;
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 26" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types@1.0.0 as http-types1;
    #|use wasi:http/types@2.0.0 as http-types2;
    #|
    #|// ...
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 27" {
  let source =
    #|package local:demo;
    #|
    #|interface shared {
    #|    record metadata {
    #|      // ...
    #|    }
    #|}
    #|
    #|world my-world {
    #|    import host: interface {
    #|      use shared.{metadata};
    #|
    #|      get: func() -> metadata;
    #|    }
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 28" {
  let source =
    #|interface a {
    #|    resource r;
    #|}
    #|interface b {
    #|    use a.{r};
    #|    foo: func() -> r;
    #|}
    #|
    #|world w1 {
    #|    export b;
    #|}
    #|world w2 {
    #|    import a;
    #|    export b;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 29" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    a1: func();
    #|    a2: func(x: u32);
    #|    a3: func(y: u64, z: f32);
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 30" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    a1: func() -> u32;
    #|    a2: func() -> string;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 31" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    record r {
    #|      a: u32,
    #|      b: f32
    #|    }
    #|
    #|    a1: func() -> r;
    #|    a2: func() -> tuple<u32, f32>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 32" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    // "package of named fields"
    #|    record r {
    #|      a: u32,
    #|      b: string,
    #|    }
    #|
    #|    // values of this type will be one of the specified cases
    #|    variant human {
    #|      baby,
    #|      child(u32), // optional type payload
    #|      adult,
    #|    }
    #|
    #|    // similar to `variant`, but no type payloads
    #|    enum errno {
    #|      too-big,
    #|      too-small,
    #|      too-fast,
    #|      too-slow,
    #|    }
    #|
    #|    // a bitflags type
    #|    flags permissions {
    #|      read,
    #|      write,
    #|      exec,
    #|    }
    #|
    #|    // type aliases are allowed to primitive types and additionally here are some
    #|    // examples of other types
    #|    type t1 = u32;
    #|    type t2 = tuple<u32, u64>;
    #|    type t3 = string;
    #|    type t4 = option<u32>;
    #|    type t5 = result<_, errno>;           // no "ok" type
    #|    type t6 = result<string>;             // no "err" type
    #|    type t7 = result<char, errno>;        // both types specified
    #|    type t8 = result;                     // no "ok" or "err" type
    #|    type t9 = list<string>;
    #|    type t10 = t9;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 34" {
  let source =
    #|interface fixture {
    #|%foo: func(%bar: u32);
    #|
    #|%red-green-blue: func(%r: u32, %g: u32, %b: u32);
    #|
    #|// This form also supports identifiers that would otherwise be keywords.
    #|%variant: func(%enum: s32);
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 35" {
  let source =
    #|interface foo {
    #|    a: func();
    #|
    #|    @since(version = 0.2.1)
    #|    b: func();
    #|
    #|    @since(version = 0.2.2)
    #|    c: func();
    #|
    #|    @unstable(feature = fancier-foo)
    #|    d: func();
    #|
    #|    @since(version = 0.2.0)
    #|    @deprecated(version = 0.2.2)
    #|    e: func();
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 37" {
  let source =
    #|interface i {
    #|    @since(version = 1.0.1)
    #|    type t1 = u32;
    #|
    #|    type t2 = t1; // error
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 38" {
  let source =
    #|@since(version = 1.0.2)
    #|interface i {
    #|    foo: func();  // error: no gate
    #|
    #|    @since(version = 1.0.1)
    #|    bar: func();  // also error: weaker gate
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 39" {
  let source =
    #|package examples:fgates-calc@0.1.0;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 40" {
  let source =
    #|package examples:fgates-calc@0.1.1;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|
    #|    /// By convention, feature flags should be prefixed with package name to reduce chance of collisions
    #|    ///
    #|    /// see: https://github.com/WebAssembly/WASI/blob/main/Contributing.md#filing-changes-to-existing-phase-3-proposals
    #|    @unstable(feature = fgates-calc-minus)
    #|    sub: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 41" {
  let source =
    #|package examples:fgates-calc@0.1.2;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|
    #|    @since(version = 0.1.2)
    #|    sub: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 42" {
  let source =
    #|package examples:fgates-deprecation@0.1.1;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add-one: func(x: s32) -> result<s32, calc-error>;
    #|
    #|    @since(version = 0.1.1)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 43" {
  let source =
    #|package examples:fgates-deprecation@0.1.2;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @deprecated(version = 0.1.2)
    #|    add-one: func(x: s32) -> result<s32, calc-error>;
    #|
    #|    @since(version = 0.1.1)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 44" {
  let source =
    #|package examples:fgates-deprecation@0.2.0;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.1)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 45" {
  let source =
    #|world my-component {
    #|  @external-id("https://esm.unpkg.com/slugify@1.6.6")
    #|  import slugify: func(text: string) -> string;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 46" {
  let source =
    #|world my-world {
    #|    import primary: wasi:keyvalue/store;
    #|    import secondary: wasi:keyvalue/store;
    #|    export my-handler: wasi:http/handler;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 47" {
  let source =
    #|world w {
    #|    import a:b;  // error: can't import a package
    #|    import a: b; // ok, assuming `b` names an interface in scope
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 48" {
  let source =
    #|world my-world {
    #|    @external-id("user-db-prod:region-a")
    #|    import users: wasi:keyvalue/store;
    #|
    #|    @external-id("catalog-db-prod:region-a")
    #|    import catalog: wasi:keyvalue/store;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 49" {
  let source =
    #|world fixture {
    #|include wasi:io/my-world-1 with { a as a1, b as b1 };
    #|include my-world-2;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 50" {
  let source =
    #|interface fixture {
    #|foo: func(x: u32);
    #|bar: get() -> u64;
    #|bar: set(v: u64);
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 52" {
  let source =
    #|interface my-interface {
    #|  @external-id("foo/0")
    #|  foo: func() -> string;
    #|
    #|  @external-id("DB.Bar")
    #|  resource bar {
    #|    @external-id("baz/1")
    #|    baz: func(s: string) -> string;
    #|  }
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 54" {
  let source =
    #|interface fixture {
    #|type my-awesome-u32 = u32;
    #|type my-complicated-tuple = tuple<u32, s32, string>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 55" {
  let source =
    #|interface fixture {
    #|record pair {
    #|    x: u32,
    #|    y: u32,
    #|}
    #|
    #|record person {
    #|    name: string,
    #|    age: u32,
    #|    has-lego-action-figure: bool,
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 56" {
  let source =
    #|interface fixture {
    #|flags properties {
    #|    lego,
    #|    marvel-superhero,
    #|    supervillan,
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 57" {
  let source =
    #|interface fixture {
    #|variant filter {
    #|    all,
    #|    none,
    #|    some(list<string>),
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 58" {
  let source =
    #|interface fixture {
    #|enum color {
    #|    red,
    #|    green,
    #|    blue,
    #|    yellow,
    #|    other,
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 60" {
  let source =
    #|interface fixture {
    #|resource blob {
    #|    constructor(init: list<u8>);
    #|    write: func(bytes: list<u8>);
    #|    read: func(n: u32) -> list<u8>;
    #|    merge: static func(lhs: borrow<blob>, rhs: borrow<blob>) -> blob;
    #|    position: get() -> u64; // 📡
    #|    position: set(value: u64); // 📡
    #|    max-size: static get() -> result<u64>; // 📡
    #|    max-size: static set(value: u64) -> result<_, string>; // 📡
    #|}
    #|resource blob2 {
    #|    constructor(init: list<u8>) -> result<blob2>;
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 62" {
  let source =
    #|interface fixture {
    #|type number = u32;
    #|type fallible-function-result = result<u32, string>;
    #|type headers = list<string>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 63" {
  let source =
    #|interface fixture {
    #|get-ipv4-address1: func() -> list<u8, 4>;
    #|get-ipv4-address2: func() -> tuple<u8, u8, u8, u8>;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 65" {
  let source =
    #|interface fixture {
    #|resource file {
    #|    read: func(n: u32) -> list<u8>;
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 67" {
  let source =
    #|interface fixture {
    #|type foo = bar;  // ERROR: name `bar` not defined
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 68" {
  let source =
    #|interface fixture {
    #|type foo = u32;
    #|type foo = u64;  // ERROR: name `foo` already defined
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 69" {
  let source =
    #|interface fixture {
    #|type foo = bar;
    #|
    #|record bar {
    #|    age: u32,
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 70" {
  let source =
    #|interface fixture {
    #|type foo = foo;  // ERROR: cannot refer to itself
    #|
    #|record bar1 {
    #|    a: bar2,
    #|}
    #|
    #|record bar2 {
    #|    a: bar1,    // ERROR: record cannot refer to itself
    #|}
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 71" {
  let source =
    #|package local:demo;
    #|
    #|interface types {
    #|    resource file {
    #|      read: func(off: u32, n: u32) -> list<u8>;
    #|      write: func(off: u32, bytes: list<u8>);
    #|    }
    #|}
    #|
    #|interface namespace {
    #|    use types.{file};
    #|    open: func(name: string) -> file;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 72" {
  let source =
    #|package local:demo
    #|
    #|interface foo {
    #|    use wasi:http/types.{request};
    #|    frob: func(r: request) -> request;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 73" {
  let source =
    #|package local:demo;
    #|
    #|world the-world {
    #|    export test: func();
    #|    export run: func();
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 74" {
  let source =
    #|package local:demo;
    #|
    #|world the-world {
    #|    import console;
    #|}
    #|
    #|interface console {
    #|    log: func(arg: string);
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 75" {
  let source =
    #|package local:demo;
    #|
    #|interface store {
    #|    resource bucket {
    #|        constructor(name: string);
    #|        get: func(key: string) -> option<string>;
    #|    }
    #|}
    #|
    #|world w {
    #|    @external-id("//One")
    #|    import one: store;
    #|
    #|    @external-id("//Two")
    #|    import two: store;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 76" {
  let source =
    #|package local:demo;
    #|
    #|interface types {
    #|    resource bucket {
    #|        get: func(key: string) -> option<string>;
    #|    }
    #|}
    #|
    #|interface store {
    #|    use types.{bucket};
    #|    open: func(name: string) -> bucket;
    #|}
    #|
    #|world w {
    #|    import one: store;
    #|    import two: store;
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}

///|
test "formatter pinned WIT specification example 78" {
  let source =
    #|package ns:p@1.1.0;
    #|
    #|interface i {
    #|    f: func();
    #|
    #|    @since(version = 1.1.0)
    #|    g: func();
    #|}
    #|
  let original = @parser.parse(source, features=@parser.Features::all())
  if original.is_valid() {
    let output = @formatter.format(source, features=@parser.Features::all()).unwrap()
    let parsed = @parser.parse(output, features=@parser.Features::all())
    assert_true(parsed.is_valid())
    assert_true(original.ast.equivalent(parsed.ast))
    assert_eq(comments(output), comments(source))
    assert_eq(
      @formatter.format(output, features=@parser.Features::all()),
      Ok(output),
    )
  } else {
    assert_true(
      @formatter.format(source, features=@parser.Features::all())
      is Err(InvalidSyntax(_)),
    )
  }
}
