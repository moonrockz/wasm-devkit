// Pinned wasm-tools e22db44da4eaf17a0e46ec55b911c7539589a3cc.
// Original inputs and reference status: tests/semantic/wit-upstream-ui/.

///|
test "upstream semantic accessors.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "accessors.wit", "package foo:bar;\n\ninterface i {\n  // A getter and setter pair for the same property.\n  prop: get() -> u64;\n  prop: set(value: u64);\n\n  // Getters don't require a setter.\n  read-only: get() -> string;\n\n  // Setters may return a `result` with no `ok` type.\n  fallible: get() -> u32;\n  fallible: set(value: u32) -> result<_, string>;\n\n  // Neither `get` nor `set` is a keyword.\n  get: func();\n  set: func(value: u32);\n  getter: get() -> bool;\n  getter: set(value: bool);\n\n  resource blob {\n    constructor(init: list<u8>);\n    write: func(bytes: list<u8>);\n    position: get() -> u64;\n    position: set(value: u64);\n    max-size: static get() -> u64;\n    max-size: static set(value: u64) -> result<_, string>;\n    read-only: static get() -> string;\n  }\n}\n\nworld w {\n  import prop: get() -> u64;\n  import prop: set(value: u64);\n  export other: get() -> u64;\n  export other: set(value: u64);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar", "interfaces", "1", "interface", "foo:bar/i", "",
    "unknown", "1", "blob", "", "unknown", "resource", "0", "16", "[constructor]blob",
    "", "unknown", "constructor", "plain", "false", "resource", "0", "1", "init",
    "list", "scalar", "u8", "some", "own", "0", "[get]fallible", "", "unknown", "freestanding",
    "get", "false", "0", "some", "scalar", "u32", "[get]getter", "", "unknown", "freestanding",
    "get", "false", "0", "some", "scalar", "bool", "[get]prop", "", "unknown", "freestanding",
    "get", "false", "0", "some", "scalar", "u64", "[get]read-only", "", "unknown",
    "freestanding", "get", "false", "0", "some", "scalar", "string", "[method][get]blob.position",
    "", "unknown", "method", "get", "false", "resource", "0", "1", "self", "borrow",
    "0", "some", "scalar", "u64", "[method][set]blob.position", "", "unknown", "method",
    "set", "false", "resource", "0", "2", "self", "borrow", "0", "value", "scalar",
    "u64", "none", "[method]blob.write", "", "unknown", "method", "plain", "false",
    "resource", "0", "2", "self", "borrow", "0", "bytes", "list", "scalar", "u8",
    "none", "[set]fallible", "", "unknown", "freestanding", "set", "false", "1",
    "value", "scalar", "u32", "some", "result", "none", "some", "scalar", "string",
    "[set]getter", "", "unknown", "freestanding", "set", "false", "1", "value", "scalar",
    "bool", "none", "[set]prop", "", "unknown", "freestanding", "set", "false", "1",
    "value", "scalar", "u64", "none", "[static][get]blob.max-size", "", "unknown",
    "static", "get", "false", "resource", "0", "0", "some", "scalar", "u64", "[static][get]blob.read-only",
    "", "unknown", "static", "get", "false", "resource", "0", "0", "some", "scalar",
    "string", "[static][set]blob.max-size", "", "unknown", "static", "set", "false",
    "resource", "0", "1", "value", "scalar", "u64", "some", "result", "none", "some",
    "scalar", "string", "get", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "set", "", "unknown", "freestanding", "plain", "false", "1", "value",
    "scalar", "u32", "none", "worlds", "1", "world", "foo:bar/w", "", "unknown",
    "imports", "2", "[get]prop", "false", "function", "[get]prop", "", "unknown",
    "freestanding", "get", "false", "0", "some", "scalar", "u64", "[set]prop", "false",
    "function", "[set]prop", "", "unknown", "freestanding", "set", "false", "1",
    "value", "scalar", "u64", "none", "exports", "2", "[get]other", "false", "function",
    "[get]other", "", "unknown", "freestanding", "get", "false", "0", "some", "scalar",
    "u64", "[set]other", "false", "function", "[set]other", "", "unknown", "freestanding",
    "set", "false", "1", "value", "scalar", "u64", "none",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic async.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "async.wit", "package test:%async;\n\ninterface x {\n  x: async func(x: u32) -> u64;\n  y: func();\n\n  resource z {\n    constructor();\n\n    x: async func();\n    y: func();\n\n    static-x: static async func();\n    static-y: static func();\n  }\n}\n\nworld y {\n  import x: async func();\n  import y: func();\n\n  export x: async func();\n  export y: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "test:async", "interfaces", "1", "interface", "test:async/x",
    "", "unknown", "1", "z", "", "unknown", "resource", "0", "7", "[constructor]z",
    "", "unknown", "constructor", "plain", "false", "resource", "0", "0", "some",
    "own", "0", "[method]z.x", "", "unknown", "method", "plain", "true", "resource",
    "0", "1", "self", "borrow", "0", "none", "[method]z.y", "", "unknown", "method",
    "plain", "false", "resource", "0", "1", "self", "borrow", "0", "none", "[static]z.static-x",
    "", "unknown", "static", "plain", "true", "resource", "0", "0", "none", "[static]z.static-y",
    "", "unknown", "static", "plain", "false", "resource", "0", "0", "none", "x",
    "", "unknown", "freestanding", "plain", "true", "1", "x", "scalar", "u32", "some",
    "scalar", "u64", "y", "", "unknown", "freestanding", "plain", "false", "0", "none",
    "worlds", "1", "world", "test:async/y", "", "unknown", "imports", "2", "x", "false",
    "function", "x", "", "unknown", "freestanding", "plain", "true", "0", "none",
    "y", "false", "function", "y", "", "unknown", "freestanding", "plain", "false",
    "0", "none", "exports", "2", "x", "false", "function", "x", "", "unknown", "freestanding",
    "plain", "true", "0", "none", "y", "false", "function", "y", "", "unknown", "freestanding",
    "plain", "false", "0", "none",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic comments.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "comments.wit", "package foo:comments;\n\n// hello\n// world\n// why, yes\n// this is a comment\n/* this too */ /* is a comment */\n/* this /* is /* a */ nested */ comment */\n\ninterface foo {\n  type x = u32;\n\n  type /* foo */ bar /* baz */ = //\n  stream < //\n  //\n  //\n\n\n\n\n  x\n\n  >;\n\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:comments", "interfaces", "1", "interface", "foo:comments/foo",
    "", "unknown", "2", "bar", "", "unknown", "stream", "some", "scalar", "u32",
    "x", "", "unknown", "scalar", "u32", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic complex-include" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "complex-include/root.wit", "package foo:root;\n\ninterface ai {}\ninterface bi {}\n\nworld a {\n    import ai;\n    import bi;\n}\n\nworld b {\n    include foo:bar/bar-a;\n}\n\nworld c {\n    include b;\n    include foo:bar/bar-a;\n}\n\nworld union-world {\n    include a;\n    include b;\n    include c;\n    include foo:bar/bar-a;\n    include foo:baz/baz-a;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "complex-include/deps/bar/root.wit", "package foo:bar;\n\ninterface a {}\ninterface b {}\n\nworld bar-a {\n    import a;\n    import b;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "complex-include/deps/baz/root.wit", "package foo:baz;\n\ninterface a {}\ninterface b {}\n\nworld baz-a {\n    import a;\n    import b;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "foo:bar", "foo:baz", "foo:root", "interfaces", "6", "interface",
    "foo:bar/a", "", "unknown", "0", "0", "interface", "foo:bar/b", "", "unknown",
    "0", "0", "interface", "foo:baz/a", "", "unknown", "0", "0", "interface", "foo:baz/b",
    "", "unknown", "0", "0", "interface", "foo:root/ai", "", "unknown", "0", "0",
    "interface", "foo:root/bi", "", "unknown", "0", "0", "worlds", "6", "world",
    "foo:bar/bar-a", "", "unknown", "imports", "2", "foo:bar/a", "true", "interface",
    "", "unknown", "interface", "foo:bar/a", "", "unknown", "0", "0", "foo:bar/b",
    "true", "interface", "", "unknown", "interface", "foo:bar/b", "", "unknown",
    "0", "0", "exports", "0", "world", "foo:baz/baz-a", "", "unknown", "imports",
    "2", "foo:baz/a", "true", "interface", "", "unknown", "interface", "foo:baz/a",
    "", "unknown", "0", "0", "foo:baz/b", "true", "interface", "", "unknown", "interface",
    "foo:baz/b", "", "unknown", "0", "0", "exports", "0", "world", "foo:root/a",
    "", "unknown", "imports", "2", "foo:root/ai", "true", "interface", "", "unknown",
    "interface", "foo:root/ai", "", "unknown", "0", "0", "foo:root/bi", "true", "interface",
    "", "unknown", "interface", "foo:root/bi", "", "unknown", "0", "0", "exports",
    "0", "world", "foo:root/b", "", "unknown", "imports", "2", "foo:bar/a", "true",
    "interface", "", "unknown", "interface", "foo:bar/a", "", "unknown", "0", "0",
    "foo:bar/b", "true", "interface", "", "unknown", "interface", "foo:bar/b", "",
    "unknown", "0", "0", "exports", "0", "world", "foo:root/c", "", "unknown", "imports",
    "2", "foo:bar/a", "true", "interface", "", "unknown", "interface", "foo:bar/a",
    "", "unknown", "0", "0", "foo:bar/b", "true", "interface", "", "unknown", "interface",
    "foo:bar/b", "", "unknown", "0", "0", "exports", "0", "world", "foo:root/union-world",
    "", "unknown", "imports", "6", "foo:bar/a", "true", "interface", "", "unknown",
    "interface", "foo:bar/a", "", "unknown", "0", "0", "foo:bar/b", "true", "interface",
    "", "unknown", "interface", "foo:bar/b", "", "unknown", "0", "0", "foo:baz/a",
    "true", "interface", "", "unknown", "interface", "foo:baz/a", "", "unknown",
    "0", "0", "foo:baz/b", "true", "interface", "", "unknown", "interface", "foo:baz/b",
    "", "unknown", "0", "0", "foo:root/ai", "true", "interface", "", "unknown", "interface",
    "foo:root/ai", "", "unknown", "0", "0", "foo:root/bi", "true", "interface", "",
    "unknown", "interface", "foo:root/bi", "", "unknown", "0", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic cross-package-resource" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "cross-package-resource/foo.wit", "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{r};\n\n  type t = own<r>;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "cross-package-resource/deps/foo/foo.wit", "package some:dep;\n\ninterface foo {\n  resource r;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "2", "foo:bar", "some:dep", "interfaces", "2", "interface", "foo:bar/foo",
    "", "unknown", "2", "r", "", "unknown", "resource", "0", "t", "", "unknown",
    "own", "0", "0", "interface", "some:dep/foo", "", "unknown", "1", "r", "", "unknown",
    "resource", "0", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic diamond1" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "diamond1/join.wit", "package foo:foo;\n\nworld foo {\n  import foo:dep1/types;\n  import foo:dep2/types;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "diamond1/deps/dep1/types.wit", "package foo:dep1;\ninterface types {}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "diamond1/deps/dep2/types.wit", "package foo:dep2;\ninterface types {}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "foo:dep1", "foo:dep2", "foo:foo", "interfaces", "2", "interface",
    "foo:dep1/types", "", "unknown", "0", "0", "interface", "foo:dep2/types", "",
    "unknown", "0", "0", "worlds", "1", "world", "foo:foo/foo", "", "unknown", "imports",
    "2", "foo:dep1/types", "true", "interface", "", "unknown", "interface", "foo:dep1/types",
    "", "unknown", "0", "0", "foo:dep2/types", "true", "interface", "", "unknown",
    "interface", "foo:dep2/types", "", "unknown", "0", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic disambiguate-diamond" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "disambiguate-diamond/shared1.wit", "interface shared1 {\n  type the-type = u32;\n}\n",
        ),
        section_document(
          "disambiguate-diamond/shared2.wit", "interface shared2 {\n  type the-type = u32;\n}\n",
        ),
        section_document(
          "disambiguate-diamond/world.wit", "package foo:diamond;\n\nworld foo {\n  import foo: interface {\n    use shared1.{the-type};\n  }\n  import bar: interface {\n    use shared2.{the-type};\n  }\n\n  import shared1;\n  import shared2;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:diamond", "interfaces", "2", "interface", "foo:diamond/shared1",
    "", "unknown", "1", "the-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:diamond/shared2", "", "unknown", "1", "the-type", "", "unknown", "scalar",
    "u32", "0", "worlds", "1", "world", "foo:diamond/foo", "", "unknown", "imports",
    "4", "bar", "false", "interface", "", "unknown", "interface", "", "", "unknown",
    "1", "the-type", "", "unknown", "scalar", "u32", "0", "foo", "false", "interface",
    "", "unknown", "interface", "", "", "unknown", "1", "the-type", "", "unknown",
    "scalar", "u32", "0", "foo:diamond/shared1", "true", "interface", "", "unknown",
    "interface", "foo:diamond/shared1", "", "unknown", "1", "the-type", "", "unknown",
    "scalar", "u32", "0", "foo:diamond/shared2", "true", "interface", "", "unknown",
    "interface", "foo:diamond/shared2", "", "unknown", "1", "the-type", "", "unknown",
    "scalar", "u32", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic distinct-names.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "distinct-names.wit", "package foo:foo;\n\ninterface distinct-names {\n  record r { a1: u32, a2: u32, a-b1: u32, a-b2: u32 }\n  flags f { f1, f2 }\n  variant v { c1(u32), c2 }\n  enum e { e1, e2 }\n  g: func(p1: u32, p2: u32);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/distinct-names",
    "", "unknown", "4", "e", "", "unknown", "enum", "2", "e1", "e2", "f", "", "unknown",
    "flags", "2", "f1", "f2", "r", "", "unknown", "record", "4", "a1", "scalar",
    "u32", "a2", "scalar", "u32", "a-b1", "scalar", "u32", "a-b2", "scalar", "u32",
    "v", "", "unknown", "variant", "2", "c1", "some", "scalar", "u32", "c2", "none",
    "1", "g", "", "unknown", "freestanding", "plain", "false", "2", "p1", "scalar",
    "u32", "p2", "scalar", "u32", "none", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic empty.wit" {
  let result = corpus_resolve(
    Source({
      documents: [section_document("empty.wit", "package foo:empty;\n")],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:empty", "interfaces", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic error-context.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "error-context.wit", "package foo:error-contexts;\n\ninterface error-contexts {\n  type t1 = error-context;\n\n  foo: func(x: error-context, y: t1) -> result<_, error-context>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:error-contexts", "interfaces", "1", "interface", "foo:error-contexts/error-contexts",
    "", "unknown", "1", "t1", "", "unknown", "scalar", "error-context", "1", "foo",
    "", "unknown", "freestanding", "plain", "false", "2", "x", "scalar", "error-context",
    "y", "scalar", "error-context", "some", "result", "none", "some", "scalar", "error-context",
    "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic feature-gates.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "feature-gates.wit", "package a:b;\n\n@unstable(feature = not-active)\ninterface gated {\n}\n\n@unstable(feature = active)\ninterface ungated {\n  @unstable(feature = not-active)\n  gated: func();\n\n  @unstable(feature = active)\n  ungated: func();\n}\n\n@unstable(feature = active)\ninterface ungated2 {\n  @unstable(feature = not-active)\n  type gated = u32;\n  @unstable(feature = not-active)\n  type gated2 = gated;\n\n  @unstable(feature = not-active)\n  type gated-with-anonymous-type = option<option<gated>>;\n\n  @unstable(feature = active)\n  type ungated = u32;\n  @unstable(feature = active)\n  type ungated2 = ungated;\n}\n\n@unstable(feature = inactive)\ninterface gated-use-target {\n  @unstable(feature = inactive)\n  type t = u32;\n}\n\n@unstable(feature = inactive)\ninterface gated-use {\n  @unstable(feature = inactive)\n  use gated-use-target.{t};\n}\n\n@unstable(feature = active)\ninterface ungated-use-target {\n  @unstable(feature = active)\n  type t = u32;\n}\n\n@unstable(feature = active)\ninterface ungated-use {\n  @unstable(feature = active)\n  use ungated-use-target.{t};\n}\n\n@unstable(feature = inactive)\ninterface gated-for-world {}\n\n@unstable(feature = inactive)\nworld gated-world {\n  @unstable(feature = inactive)\n  import gated-for-world;\n  @unstable(feature = inactive)\n  export gated-for-world;\n}\n\n@unstable(feature = active)\ninterface ungated-for-world {}\n\n@unstable(feature = active)\nworld ungated-world {\n  @unstable(feature = active)\n  import ungated-for-world;\n  @unstable(feature = active)\n  export ungated-for-world;\n}\n\nworld mixed-world {\n  @unstable(feature = inactive)\n  import gated-for-world;\n  @unstable(feature = inactive)\n  export gated-for-world;\n  @unstable(feature = inactive)\n  include gated-world;\n\n  @unstable(feature = active)\n  import ungated-for-world;\n  @unstable(feature = active)\n  export ungated-for-world;\n  @unstable(feature = inactive)\n  include ungated-world;\n}\n\ninterface with-resources {\n  @unstable(feature = inactive)\n  resource gated {\n    @unstable(feature = inactive)\n    constructor();\n\n    @unstable(feature = inactive)\n    x: static func();\n\n    @unstable(feature = inactive)\n    y: func();\n  }\n\n  @unstable(feature = active)\n  resource ungated {\n    @unstable(feature = active)\n    constructor();\n\n    @unstable(feature = active)\n    x: static func();\n\n    @unstable(feature = active)\n    y: func();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "a:b", "interfaces", "6", "interface", "a:b/ungated", "", "unstable",
    "active", "", "0", "1", "ungated", "", "unstable", "active", "", "freestanding",
    "plain", "false", "0", "none", "interface", "a:b/ungated-for-world", "", "unstable",
    "active", "", "0", "0", "interface", "a:b/ungated-use", "", "unstable", "active",
    "", "1", "t", "", "unstable", "active", "", "scalar", "u32", "0", "interface",
    "a:b/ungated-use-target", "", "unstable", "active", "", "1", "t", "", "unstable",
    "active", "", "scalar", "u32", "0", "interface", "a:b/ungated2", "", "unstable",
    "active", "", "2", "ungated", "", "unstable", "active", "", "scalar", "u32",
    "ungated2", "", "unstable", "active", "", "scalar", "u32", "0", "interface",
    "a:b/with-resources", "", "unknown", "1", "ungated", "", "unstable", "active",
    "", "resource", "0", "3", "[constructor]ungated", "", "unstable", "active", "",
    "constructor", "plain", "false", "resource", "0", "0", "some", "own", "0", "[method]ungated.y",
    "", "unstable", "active", "", "method", "plain", "false", "resource", "0", "1",
    "self", "borrow", "0", "none", "[static]ungated.x", "", "unstable", "active",
    "", "static", "plain", "false", "resource", "0", "0", "none", "worlds", "2",
    "world", "a:b/mixed-world", "", "unknown", "imports", "1", "a:b/ungated-for-world",
    "true", "interface", "", "unstable", "active", "", "interface", "a:b/ungated-for-world",
    "", "unstable", "active", "", "0", "0", "exports", "1", "a:b/ungated-for-world",
    "true", "interface", "", "unstable", "active", "", "interface", "a:b/ungated-for-world",
    "", "unstable", "active", "", "0", "0", "world", "a:b/ungated-world", "", "unstable",
    "active", "", "imports", "1", "a:b/ungated-for-world", "true", "interface", "",
    "unstable", "active", "", "interface", "a:b/ungated-for-world", "", "unstable",
    "active", "", "0", "0", "exports", "1", "a:b/ungated-for-world", "true", "interface",
    "", "unstable", "active", "", "interface", "a:b/ungated-for-world", "", "unstable",
    "active", "", "0", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic feature-types.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "feature-types.wit", "package a:b;\n\ninterface foo {\n  variant bar {\n    x,\n    y\n  }\n\n  @unstable(feature = my-feature)\n  my-unstable: func(p: bar) -> result<_, bar>;\n\n  my-stable: func(p: bar) -> result<_, bar>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "a:b", "interfaces", "1", "interface", "a:b/foo", "", "unknown",
    "1", "bar", "", "unknown", "variant", "2", "x", "none", "y", "none", "1", "my-stable",
    "", "unknown", "freestanding", "plain", "false", "1", "p", "variant", "2", "x",
    "none", "y", "none", "some", "result", "none", "some", "variant", "2", "x", "none",
    "y", "none", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic foreign-deps" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "foreign-deps/root.wit", "package foo:root;\n\ninterface foo {\n  use foo:wasi/clocks.{timestamp};\n  use foo:wasi/filesystem.{stat};\n}\n\nworld my-world {\n  import foo:wasi/filesystem;\n  import foo:wasi/clocks;\n\n  export foo:corp/saas;\n}\n\nuse foo:wasi/filesystem as filesystem;\nuse foo:wasi/clocks as clocks;\n\nworld my-world2 {\n  import filesystem;\n  import clocks;\n  export foo;\n  export foo:corp/saas;\n}\n\ninterface bar {\n  use filesystem.{};\n  use foo:some-pkg/the-default.{from-default};\n  use foo:some-pkg/some-interface.{another-type};\n  use foo:some-pkg/some-interface.{};\n  use foo:some-pkg/another-interface.{yet-another-type};\n  use foo:different-pkg/i.{};\n}\n\nworld bars-world {\n  import foo:some-pkg/the-default;\n  import foo:another-pkg/other-interface;\n}\n\ninterface use1 {\n  use foo:foreign-pkg/the-default.{some-type};\n}\ninterface use2 {\n  use foo:foreign-pkg/the-default.{some-type};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "foreign-deps/deps/another-pkg/other-doc.wit", "package foo:another-pkg;\n\ninterface other-interface {}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps/deps/corp/saas.wit", "package foo:corp;\n\ninterface saas {\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps/deps/different-pkg/the-doc.wit", "package foo:different-pkg;\ninterface i {}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps/deps/foreign-pkg/the-doc.wit", "package foo:foreign-pkg;\n\ninterface the-default {\n  type some-type = u32;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps/deps/some-pkg/some-doc.wit", "package foo:some-pkg;\n\ninterface the-default {\n  type from-default = string;\n}\n\ninterface some-interface {\n  type another-type = u32;\n}\n\ninterface another-interface {\n  type yet-another-type = u8;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps/deps/wasi/clocks.wit", "package foo:wasi;\n\ninterface clocks {\n  type timestamp = u64;\n}\n",
          ),
          section_document(
            "foreign-deps/deps/wasi/filesystem.wit", "package foo:wasi;\n\ninterface filesystem {\n  record stat {\n    ino: u64\n  }\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "7", "foo:another-pkg", "foo:corp", "foo:different-pkg", "foo:foreign-pkg",
    "foo:root", "foo:some-pkg", "foo:wasi", "interfaces", "13", "interface", "foo:another-pkg/other-interface",
    "", "unknown", "0", "0", "interface", "foo:corp/saas", "", "unknown", "0", "0",
    "interface", "foo:different-pkg/i", "", "unknown", "0", "0", "interface", "foo:foreign-pkg/the-default",
    "", "unknown", "1", "some-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:root/bar", "", "unknown", "3", "another-type", "", "unknown", "scalar",
    "u32", "from-default", "", "unknown", "scalar", "string", "yet-another-type",
    "", "unknown", "scalar", "u8", "0", "interface", "foo:root/foo", "", "unknown",
    "2", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "timestamp",
    "", "unknown", "scalar", "u64", "0", "interface", "foo:root/use1", "", "unknown",
    "1", "some-type", "", "unknown", "scalar", "u32", "0", "interface", "foo:root/use2",
    "", "unknown", "1", "some-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:some-pkg/another-interface", "", "unknown", "1", "yet-another-type", "",
    "unknown", "scalar", "u8", "0", "interface", "foo:some-pkg/some-interface", "",
    "unknown", "1", "another-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:some-pkg/the-default", "", "unknown", "1", "from-default", "", "unknown",
    "scalar", "string", "0", "interface", "foo:wasi/clocks", "", "unknown", "1",
    "timestamp", "", "unknown", "scalar", "u64", "0", "interface", "foo:wasi/filesystem",
    "", "unknown", "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64",
    "0", "worlds", "3", "world", "foo:root/bars-world", "", "unknown", "imports",
    "2", "foo:another-pkg/other-interface", "true", "interface", "", "unknown", "interface",
    "foo:another-pkg/other-interface", "", "unknown", "0", "0", "foo:some-pkg/the-default",
    "true", "interface", "", "unknown", "interface", "foo:some-pkg/the-default",
    "", "unknown", "1", "from-default", "", "unknown", "scalar", "string", "0", "exports",
    "0", "world", "foo:root/my-world", "", "unknown", "imports", "2", "foo:wasi/clocks",
    "true", "interface", "", "unknown", "interface", "foo:wasi/clocks", "", "unknown",
    "1", "timestamp", "", "unknown", "scalar", "u64", "0", "foo:wasi/filesystem",
    "true", "interface", "", "unknown", "interface", "foo:wasi/filesystem", "", "unknown",
    "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "0", "exports",
    "1", "foo:corp/saas", "true", "interface", "", "unknown", "interface", "foo:corp/saas",
    "", "unknown", "0", "0", "world", "foo:root/my-world2", "", "unknown", "imports",
    "2", "foo:wasi/clocks", "true", "interface", "", "unknown", "interface", "foo:wasi/clocks",
    "", "unknown", "1", "timestamp", "", "unknown", "scalar", "u64", "0", "foo:wasi/filesystem",
    "true", "interface", "", "unknown", "interface", "foo:wasi/filesystem", "", "unknown",
    "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "0", "exports",
    "2", "foo:corp/saas", "true", "interface", "", "unknown", "interface", "foo:corp/saas",
    "", "unknown", "0", "0", "foo:root/foo", "true", "interface", "", "unknown",
    "interface", "foo:root/foo", "", "unknown", "2", "stat", "", "unknown", "record",
    "1", "ino", "scalar", "u64", "timestamp", "", "unknown", "scalar", "u64", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic foreign-deps-union" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "foreign-deps-union/root.wit", "package foo:root;\n\ninterface foo {\n  use foo:wasi/clocks.{timestamp};\n  use foo:wasi/filesystem.{stat};\n}\n\nworld my-world {\n  import foo:wasi/filesystem;\n  import foo:wasi/clocks;\n\n  export foo:corp/saas;\n}\n\nuse foo:wasi/filesystem as filesystem;\nuse foo:wasi/clocks as clocks;\n\nworld my-world2 {\n  import filesystem;\n  import clocks;\n  export foo;\n  export foo:corp/saas;\n}\n\ninterface bar {\n  use filesystem.{};\n  use foo:some-pkg/the-default.{from-default};\n  use foo:some-pkg/some-interface.{another-type};\n  use foo:some-pkg/some-interface.{};\n  use foo:some-pkg/another-interface.{yet-another-type};\n  use foo:different-pkg/i.{};\n}\n\nworld bars-world {\n  import foo:some-pkg/the-default;\n  import foo:another-pkg/other-interface;\n}\n\ninterface use1 {\n  use foo:foreign-pkg/the-default.{some-type};\n}\ninterface use2 {\n  use foo:foreign-pkg/the-default.{some-type};\n}\n\nworld unionw-world {\n  include my-world;\n  include my-world2;\n  include foo:wasi/wasi;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "foreign-deps-union/deps/another-pkg/other-doc.wit", "package foo:another-pkg;\n\ninterface other-interface {}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps-union/deps/corp/saas.wit", "package foo:corp;\n\ninterface saas {\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps-union/deps/different-pkg/the-doc.wit", "package foo:different-pkg;\ninterface i {}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps-union/deps/foreign-pkg/the-doc.wit", "package foo:foreign-pkg;\n\ninterface the-default {\n  type some-type = u32;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps-union/deps/some-pkg/some-doc.wit", "package foo:some-pkg;\n\ninterface the-default {\n  type from-default = string;\n}\n\ninterface some-interface {\n  type another-type = u32;\n}\n\ninterface another-interface {\n  type yet-another-type = u8;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "foreign-deps-union/deps/wasi/clocks.wit", "package foo:wasi;\n\ninterface clocks {\n  type timestamp = u64;\n}\n",
          ),
          section_document(
            "foreign-deps-union/deps/wasi/filesystem.wit", "package foo:wasi;\n\ninterface filesystem {\n  record stat {\n    ino: u64\n  }\n}\n",
          ),
          section_document(
            "foreign-deps-union/deps/wasi/wasi.wit", "package foo:wasi;\n\nworld wasi {\n    import filesystem;\n    import clocks;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "7", "foo:another-pkg", "foo:corp", "foo:different-pkg", "foo:foreign-pkg",
    "foo:root", "foo:some-pkg", "foo:wasi", "interfaces", "13", "interface", "foo:another-pkg/other-interface",
    "", "unknown", "0", "0", "interface", "foo:corp/saas", "", "unknown", "0", "0",
    "interface", "foo:different-pkg/i", "", "unknown", "0", "0", "interface", "foo:foreign-pkg/the-default",
    "", "unknown", "1", "some-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:root/bar", "", "unknown", "3", "another-type", "", "unknown", "scalar",
    "u32", "from-default", "", "unknown", "scalar", "string", "yet-another-type",
    "", "unknown", "scalar", "u8", "0", "interface", "foo:root/foo", "", "unknown",
    "2", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "timestamp",
    "", "unknown", "scalar", "u64", "0", "interface", "foo:root/use1", "", "unknown",
    "1", "some-type", "", "unknown", "scalar", "u32", "0", "interface", "foo:root/use2",
    "", "unknown", "1", "some-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:some-pkg/another-interface", "", "unknown", "1", "yet-another-type", "",
    "unknown", "scalar", "u8", "0", "interface", "foo:some-pkg/some-interface", "",
    "unknown", "1", "another-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:some-pkg/the-default", "", "unknown", "1", "from-default", "", "unknown",
    "scalar", "string", "0", "interface", "foo:wasi/clocks", "", "unknown", "1",
    "timestamp", "", "unknown", "scalar", "u64", "0", "interface", "foo:wasi/filesystem",
    "", "unknown", "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64",
    "0", "worlds", "5", "world", "foo:root/bars-world", "", "unknown", "imports",
    "2", "foo:another-pkg/other-interface", "true", "interface", "", "unknown", "interface",
    "foo:another-pkg/other-interface", "", "unknown", "0", "0", "foo:some-pkg/the-default",
    "true", "interface", "", "unknown", "interface", "foo:some-pkg/the-default",
    "", "unknown", "1", "from-default", "", "unknown", "scalar", "string", "0", "exports",
    "0", "world", "foo:root/my-world", "", "unknown", "imports", "2", "foo:wasi/clocks",
    "true", "interface", "", "unknown", "interface", "foo:wasi/clocks", "", "unknown",
    "1", "timestamp", "", "unknown", "scalar", "u64", "0", "foo:wasi/filesystem",
    "true", "interface", "", "unknown", "interface", "foo:wasi/filesystem", "", "unknown",
    "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "0", "exports",
    "1", "foo:corp/saas", "true", "interface", "", "unknown", "interface", "foo:corp/saas",
    "", "unknown", "0", "0", "world", "foo:root/my-world2", "", "unknown", "imports",
    "2", "foo:wasi/clocks", "true", "interface", "", "unknown", "interface", "foo:wasi/clocks",
    "", "unknown", "1", "timestamp", "", "unknown", "scalar", "u64", "0", "foo:wasi/filesystem",
    "true", "interface", "", "unknown", "interface", "foo:wasi/filesystem", "", "unknown",
    "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "0", "exports",
    "2", "foo:corp/saas", "true", "interface", "", "unknown", "interface", "foo:corp/saas",
    "", "unknown", "0", "0", "foo:root/foo", "true", "interface", "", "unknown",
    "interface", "foo:root/foo", "", "unknown", "2", "stat", "", "unknown", "record",
    "1", "ino", "scalar", "u64", "timestamp", "", "unknown", "scalar", "u64", "0",
    "world", "foo:root/unionw-world", "", "unknown", "imports", "2", "foo:wasi/clocks",
    "true", "interface", "", "unknown", "interface", "foo:wasi/clocks", "", "unknown",
    "1", "timestamp", "", "unknown", "scalar", "u64", "0", "foo:wasi/filesystem",
    "true", "interface", "", "unknown", "interface", "foo:wasi/filesystem", "", "unknown",
    "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "0", "exports",
    "2", "foo:corp/saas", "true", "interface", "", "unknown", "interface", "foo:corp/saas",
    "", "unknown", "0", "0", "foo:root/foo", "true", "interface", "", "unknown",
    "interface", "foo:root/foo", "", "unknown", "2", "stat", "", "unknown", "record",
    "1", "ino", "scalar", "u64", "timestamp", "", "unknown", "scalar", "u64", "0",
    "world", "foo:wasi/wasi", "", "unknown", "imports", "2", "foo:wasi/clocks", "true",
    "interface", "", "unknown", "interface", "foo:wasi/clocks", "", "unknown", "1",
    "timestamp", "", "unknown", "scalar", "u64", "0", "foo:wasi/filesystem", "true",
    "interface", "", "unknown", "interface", "foo:wasi/filesystem", "", "unknown",
    "1", "stat", "", "unknown", "record", "1", "ino", "scalar", "u64", "0", "exports",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic foreign-interface-dep-gated.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "foreign-interface-dep-gated.wit", "package a:b1;\n\nworld the-world {\n  include a:b2/the-world;\n}\n\npackage a:b2 {\n  world the-world {\n    @unstable(feature = disabled)\n    import a:b3/thing;\n  }\n}\n\npackage a:b3 {\n  @unstable(feature = disabled)\n  interface thing {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "a:b1", "a:b2", "a:b3", "interfaces", "0", "worlds", "2", "world",
    "a:b1/the-world", "", "unknown", "imports", "0", "exports", "0", "world", "a:b2/the-world",
    "", "unknown", "imports", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic foreign-world-dep-gated.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "foreign-world-dep-gated.wit", "package a:b1;\n\nworld the-world {\n  include a:b2/the-world;\n}\n\npackage a:b2 {\n  world the-world {\n    @unstable(feature = disabled)\n    import a:b3/another-world;\n  }\n}\n\npackage a:b3 {\n  @unstable(feature = disabled)\n  world another-world {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "a:b1", "a:b2", "a:b3", "interfaces", "0", "worlds", "2", "world",
    "a:b1/the-world", "", "unknown", "imports", "0", "exports", "0", "world", "a:b2/the-world",
    "", "unknown", "imports", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic functions.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "functions.wit", "package foo:functions;\n\ninterface functions {\n  f1: func();\n  f2: func(a: u32);\n  f3: func(a: u32,);\n  f4: func() -> u32;\n  f6: func() -> tuple<u32, u32>;\n  f7: func(a: f32, b: f32) -> tuple<u32, u32>;\n  f8: func(a: option<u32>) -> result<u32, f32>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:functions", "interfaces", "1", "interface", "foo:functions/functions",
    "", "unknown", "0", "7", "f1", "", "unknown", "freestanding", "plain", "false",
    "0", "none", "f2", "", "unknown", "freestanding", "plain", "false", "1", "a",
    "scalar", "u32", "none", "f3", "", "unknown", "freestanding", "plain", "false",
    "1", "a", "scalar", "u32", "none", "f4", "", "unknown", "freestanding", "plain",
    "false", "0", "some", "scalar", "u32", "f6", "", "unknown", "freestanding", "plain",
    "false", "0", "some", "tuple", "2", "scalar", "u32", "scalar", "u32", "f7", "",
    "unknown", "freestanding", "plain", "false", "2", "a", "scalar", "f32", "b",
    "scalar", "f32", "some", "tuple", "2", "scalar", "u32", "scalar", "u32", "f8",
    "", "unknown", "freestanding", "plain", "false", "1", "a", "option", "scalar",
    "u32", "some", "result", "some", "scalar", "u32", "some", "scalar", "f32", "worlds",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic gated-include.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "gated-include.wit", "package wasmtime:test@0.1.0;\n\ninterface unknown-stability-interface {\n    resource unknown-stability-resource {\n    }\n    stable-func: func();\n}\n\n@unstable(feature = active)\ninterface unstable-interface {\n    @unstable(feature = active)\n    resource unstable-resource {\n    }\n    @unstable(feature = active)\n    unstable-func: func();\n}\n\n@since(version = 0.1.0)\ninterface stable-interface {\n    @since(version = 0.1.0)\n    resource stable-resource {\n    }\n    @since(version = 0.1.0)\n    stable-func: func();\n}\n\nworld unknown-stability {\n    import unknown-stability-interface;\n}\n\nworld unstable {\n    @unstable(feature = active)\n    import unstable-interface;\n}\n\nworld stable{\n    @since(version = 0.1.0)\n    import stable-interface;\n}\n\nworld simple-include {\n    include unstable;\n    include stable;\n    include unknown-stability;\n}\n\nworld unstable-include-in-package \n{\n    include unstable;\n}\n\nworld dup-include-in-package {\n    include simple-include;\n    include unstable-include-in-package;\n}\n\nworld dup-use-package {\n    @unstable(feature = active)\n    use stable-interface.{stable-resource};\n    include simple-include;\n}\n\nworld dup-use-package-ordered {\n    include simple-include;\n    @unstable(feature = active)\n    use stable-interface.{stable-resource};\n}",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "wasmtime:test@0.1.0", "interfaces", "3", "interface", "wasmtime:test/stable-interface@0.1.0",
    "", "stable", "0.1.0", "", "1", "stable-resource", "", "stable", "0.1.0", "",
    "resource", "0", "1", "stable-func", "", "stable", "0.1.0", "", "freestanding",
    "plain", "false", "0", "none", "interface", "wasmtime:test/unknown-stability-interface@0.1.0",
    "", "unknown", "1", "unknown-stability-resource", "", "unknown", "resource",
    "1", "1", "stable-func", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "interface", "wasmtime:test/unstable-interface@0.1.0", "", "unstable",
    "active", "", "1", "unstable-resource", "", "unstable", "active", "", "resource",
    "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding", "plain",
    "false", "0", "none", "worlds", "8", "world", "wasmtime:test/dup-include-in-package@0.1.0",
    "", "unknown", "imports", "3", "wasmtime:test/stable-interface@0.1.0", "true",
    "interface", "", "stable", "0.1.0", "", "interface", "wasmtime:test/stable-interface@0.1.0",
    "", "stable", "0.1.0", "", "1", "stable-resource", "", "stable", "0.1.0", "",
    "resource", "0", "1", "stable-func", "", "stable", "0.1.0", "", "freestanding",
    "plain", "false", "0", "none", "wasmtime:test/unknown-stability-interface@0.1.0",
    "true", "interface", "", "unknown", "interface", "wasmtime:test/unknown-stability-interface@0.1.0",
    "", "unknown", "1", "unknown-stability-resource", "", "unknown", "resource",
    "1", "1", "stable-func", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "wasmtime:test/unstable-interface@0.1.0", "true", "interface", "", "unstable",
    "active", "", "interface", "wasmtime:test/unstable-interface@0.1.0", "", "unstable",
    "active", "", "1", "unstable-resource", "", "unstable", "active", "", "resource",
    "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding", "plain",
    "false", "0", "none", "exports", "0", "world", "wasmtime:test/dup-use-package-ordered@0.1.0",
    "", "unknown", "imports", "4", "stable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "0", "wasmtime:test/stable-interface@0.1.0", "true",
    "interface", "", "stable", "0.1.0", "", "interface", "wasmtime:test/stable-interface@0.1.0",
    "", "stable", "0.1.0", "", "1", "stable-resource", "", "stable", "0.1.0", "",
    "resource", "0", "1", "stable-func", "", "stable", "0.1.0", "", "freestanding",
    "plain", "false", "0", "none", "wasmtime:test/unknown-stability-interface@0.1.0",
    "true", "interface", "", "unknown", "interface", "wasmtime:test/unknown-stability-interface@0.1.0",
    "", "unknown", "1", "unknown-stability-resource", "", "unknown", "resource",
    "1", "1", "stable-func", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "wasmtime:test/unstable-interface@0.1.0", "true", "interface", "", "unstable",
    "active", "", "interface", "wasmtime:test/unstable-interface@0.1.0", "", "unstable",
    "active", "", "1", "unstable-resource", "", "unstable", "active", "", "resource",
    "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding", "plain",
    "false", "0", "none", "exports", "0", "world", "wasmtime:test/dup-use-package@0.1.0",
    "", "unknown", "imports", "4", "stable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "0", "wasmtime:test/stable-interface@0.1.0", "true",
    "interface", "", "stable", "0.1.0", "", "interface", "wasmtime:test/stable-interface@0.1.0",
    "", "stable", "0.1.0", "", "1", "stable-resource", "", "stable", "0.1.0", "",
    "resource", "0", "1", "stable-func", "", "stable", "0.1.0", "", "freestanding",
    "plain", "false", "0", "none", "wasmtime:test/unknown-stability-interface@0.1.0",
    "true", "interface", "", "unknown", "interface", "wasmtime:test/unknown-stability-interface@0.1.0",
    "", "unknown", "1", "unknown-stability-resource", "", "unknown", "resource",
    "1", "1", "stable-func", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "wasmtime:test/unstable-interface@0.1.0", "true", "interface", "", "unstable",
    "active", "", "interface", "wasmtime:test/unstable-interface@0.1.0", "", "unstable",
    "active", "", "1", "unstable-resource", "", "unstable", "active", "", "resource",
    "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding", "plain",
    "false", "0", "none", "exports", "0", "world", "wasmtime:test/simple-include@0.1.0",
    "", "unknown", "imports", "3", "wasmtime:test/stable-interface@0.1.0", "true",
    "interface", "", "stable", "0.1.0", "", "interface", "wasmtime:test/stable-interface@0.1.0",
    "", "stable", "0.1.0", "", "1", "stable-resource", "", "stable", "0.1.0", "",
    "resource", "0", "1", "stable-func", "", "stable", "0.1.0", "", "freestanding",
    "plain", "false", "0", "none", "wasmtime:test/unknown-stability-interface@0.1.0",
    "true", "interface", "", "unknown", "interface", "wasmtime:test/unknown-stability-interface@0.1.0",
    "", "unknown", "1", "unknown-stability-resource", "", "unknown", "resource",
    "1", "1", "stable-func", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "wasmtime:test/unstable-interface@0.1.0", "true", "interface", "", "unstable",
    "active", "", "interface", "wasmtime:test/unstable-interface@0.1.0", "", "unstable",
    "active", "", "1", "unstable-resource", "", "unstable", "active", "", "resource",
    "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding", "plain",
    "false", "0", "none", "exports", "0", "world", "wasmtime:test/stable@0.1.0",
    "", "unknown", "imports", "1", "wasmtime:test/stable-interface@0.1.0", "true",
    "interface", "", "stable", "0.1.0", "", "interface", "wasmtime:test/stable-interface@0.1.0",
    "", "stable", "0.1.0", "", "1", "stable-resource", "", "stable", "0.1.0", "",
    "resource", "0", "1", "stable-func", "", "stable", "0.1.0", "", "freestanding",
    "plain", "false", "0", "none", "exports", "0", "world", "wasmtime:test/unknown-stability@0.1.0",
    "", "unknown", "imports", "1", "wasmtime:test/unknown-stability-interface@0.1.0",
    "true", "interface", "", "unknown", "interface", "wasmtime:test/unknown-stability-interface@0.1.0",
    "", "unknown", "1", "unknown-stability-resource", "", "unknown", "resource",
    "1", "1", "stable-func", "", "unknown", "freestanding", "plain", "false", "0",
    "none", "exports", "0", "world", "wasmtime:test/unstable-include-in-package@0.1.0",
    "", "unknown", "imports", "1", "wasmtime:test/unstable-interface@0.1.0", "true",
    "interface", "", "unstable", "active", "", "interface", "wasmtime:test/unstable-interface@0.1.0",
    "", "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding",
    "plain", "false", "0", "none", "exports", "0", "world", "wasmtime:test/unstable@0.1.0",
    "", "unknown", "imports", "1", "wasmtime:test/unstable-interface@0.1.0", "true",
    "interface", "", "unstable", "active", "", "interface", "wasmtime:test/unstable-interface@0.1.0",
    "", "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "2", "1", "unstable-func", "", "unstable", "active", "", "freestanding",
    "plain", "false", "0", "none", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic gated-use.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "gated-use.wit", "package wasmtime:test;\n\ninterface types {\n  @unstable(feature = inactive)\n  use wasi:dep2/stable@0.2.3.{unstable-resource};\n}\n\npackage wasi:dep2@0.2.3 {\n  interface stable {\n    @unstable(feature = inactive)\n    resource unstable-resource;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "2", "wasi:dep2@0.2.3", "wasmtime:test", "interfaces", "2", "interface",
    "wasi:dep2/stable@0.2.3", "", "unknown", "0", "0", "interface", "wasmtime:test/types",
    "", "unknown", "0", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic ignore-files-deps" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "ignore-files-deps/world.wit", "package foo:foo;\n\nworld foo {\n  import foo:bar/types;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "ignore-files-deps/deps/bar/types.wit", "package foo:bar;\ninterface types {}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "2", "foo:bar", "foo:foo", "interfaces", "1", "interface", "foo:bar/types",
    "", "unknown", "0", "0", "worlds", "1", "world", "foo:foo/foo", "", "unknown",
    "imports", "1", "foo:bar/types", "true", "interface", "", "unknown", "interface",
    "foo:bar/types", "", "unknown", "0", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic import-export-overlap1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "import-export-overlap1.wit", "package foo:foo;\nworld foo {\n  import a: func();\n  export a: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "1", "world", "foo:foo/foo",
    "", "unknown", "imports", "1", "a", "false", "function", "a", "", "unknown",
    "freestanding", "plain", "false", "0", "none", "exports", "1", "a", "false",
    "function", "a", "", "unknown", "freestanding", "plain", "false", "0", "none",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic import-export-overlap2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "import-export-overlap2.wit", "package foo:foo;\nworld foo {\n  import a: func();\n  export a: interface {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "1", "world", "foo:foo/foo",
    "", "unknown", "imports", "1", "a", "false", "function", "a", "", "unknown",
    "freestanding", "plain", "false", "0", "none", "exports", "1", "a", "false",
    "interface", "", "unknown", "interface", "", "", "unknown", "0", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic include-accessor-pair.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "include-accessor-pair.wit", "package foo:foo;\n\n// Getters and setters must be validated after includes are processed.\n\nworld base {\n  import prop: get() -> u32;\n}\n\nworld derived {\n  import prop: set(value: u32);\n  include base;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "2", "world", "foo:foo/base",
    "", "unknown", "imports", "1", "[get]prop", "false", "function", "[get]prop",
    "", "unknown", "freestanding", "get", "false", "0", "some", "scalar", "u32",
    "exports", "0", "world", "foo:foo/derived", "", "unknown", "imports", "2", "[get]prop",
    "false", "function", "[get]prop", "", "unknown", "freestanding", "get", "false",
    "0", "some", "scalar", "u32", "[set]prop", "false", "function", "[set]prop",
    "", "unknown", "freestanding", "set", "false", "1", "value", "scalar", "u32",
    "none", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic include-reps.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "include-reps.wit", "package foo:foo;\n\ninterface a {}\ninterface b {}\n\nworld bar {\n    import a;\n    export b;\n}\n\nworld foo {\n  include bar;\n  include bar;\n  include bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "2", "interface", "foo:foo/a", "",
    "unknown", "0", "0", "interface", "foo:foo/b", "", "unknown", "0", "0", "worlds",
    "2", "world", "foo:foo/bar", "", "unknown", "imports", "1", "foo:foo/a", "true",
    "interface", "", "unknown", "interface", "foo:foo/a", "", "unknown", "0", "0",
    "exports", "1", "foo:foo/b", "true", "interface", "", "unknown", "interface",
    "foo:foo/b", "", "unknown", "0", "0", "world", "foo:foo/foo", "", "unknown",
    "imports", "1", "foo:foo/a", "true", "interface", "", "unknown", "interface",
    "foo:foo/a", "", "unknown", "0", "0", "exports", "1", "foo:foo/b", "true", "interface",
    "", "unknown", "interface", "foo:foo/b", "", "unknown", "0", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic kebab-name-include-with.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "kebab-name-include-with.wit", "package foo:foo;\n\nworld foo { import a: func(); }\nworld bar { import a: func(); }\nworld baz {\n    include foo with { a as b }\n    include bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "3", "world", "foo:foo/bar",
    "", "unknown", "imports", "1", "a", "false", "function", "a", "", "unknown",
    "freestanding", "plain", "false", "0", "none", "exports", "0", "world", "foo:foo/baz",
    "", "unknown", "imports", "2", "a", "false", "function", "a", "", "unknown",
    "freestanding", "plain", "false", "0", "none", "b", "false", "function", "b",
    "", "unknown", "freestanding", "plain", "false", "0", "none", "exports", "0",
    "world", "foo:foo/foo", "", "unknown", "imports", "1", "a", "false", "function",
    "a", "", "unknown", "freestanding", "plain", "false", "0", "none", "exports",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic kinds-of-deps" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "kinds-of-deps/a.wit", "package a:a;\n\nworld a {\n  import b:b/b;\n  import c:c/c;\n  import d:d/d;\n  import e:e/e;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "kinds-of-deps/deps/b/root.wit", "package b:b;\n\ninterface b {}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "kinds-of-deps/deps/c.wit", "package c:c;\n\ninterface c {}\n",
          ),
        ],
      }),
      Encoded(
        @verifier.decode_wat_package(
          "(component\n  (type $d (component\n    (export \"d:d/d\" (instance))\n  ))\n  (export \"d\" (type $d))\n)\n",
          source_id="kinds-of-deps/deps/d.wat",
        ).unwrap(),
      ),
      Encoded(
        @verifier.decode_package(
          b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x01\x41\x02\x01\x42\x00\x04\x01\x05\x65\x3a\x65\x2f\x65\x05\x00\x0b\x07\x01\x00\x01\x65\x03\x00\x00",
          source_id="kinds-of-deps/deps/e.wasm",
        ).unwrap(),
      ),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "5", "a:a", "b:b", "c:c", "d:d", "e:e", "interfaces", "4", "interface",
    "b:b/b", "", "unknown", "0", "0", "interface", "c:c/c", "", "unknown", "0", "0",
    "interface", "d:d/d", "", "unknown", "0", "0", "interface", "e:e/e", "", "unknown",
    "0", "0", "worlds", "1", "world", "a:a/a", "", "unknown", "imports", "4", "b:b/b",
    "true", "interface", "", "unknown", "interface", "b:b/b", "", "unknown", "0",
    "0", "c:c/c", "true", "interface", "", "unknown", "interface", "c:c/c", "", "unknown",
    "0", "0", "d:d/d", "true", "interface", "", "unknown", "interface", "d:d/d",
    "", "unknown", "0", "0", "e:e/e", "true", "interface", "", "unknown", "interface",
    "e:e/e", "", "unknown", "0", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic many-names" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document("many-names/a.wit", "interface x {}\nuse x as name;\n"),
        section_document(
          "many-names/b.wit", "package foo:name;\n\nworld name {\n  import name: interface {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:name", "interfaces", "1", "interface", "foo:name/x", "",
    "unknown", "0", "0", "worlds", "1", "world", "foo:name/name", "", "unknown",
    "imports", "1", "name", "false", "interface", "", "unknown", "interface", "",
    "", "unknown", "0", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic maps.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "maps.wit", "package foo:maps;\n\ninterface maps {\n  // Basic maps\n  type string-to-u32 = map<string, u32>;\n  type u32-to-string = map<u32, string>;\n  \n  // Nested maps\n  type nested-map = map<string, map<string, u32>>;\n  \n  // Maps with complex types\n  record person {\n    name: string,\n    age: u32,\n  }\n  type person-map = map<string, person>;\n  \n  // Maps with tuples, lists, options\n  type complex-map = map<string, option<list<u32>>>;\n  \n  // Functions using maps\n  get-value: func(m: map<string, u32>, key: string) -> option<u32>;\n  set-value: func(m: map<string, u32>, key: string, value: u32) -> map<string, u32>;\n  merge-maps: func(a: map<string, u32>, b: map<string, u32>) -> map<string, u32>;\n  \n  // Map with various key types\n  type int-key-map = map<u32, string>;\n  type char-key-map = map<char, string>;\n}\n\nworld maps-world {\n  import maps;\n  export maps;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:maps", "interfaces", "1", "interface", "foo:maps/maps",
    "", "unknown", "8", "char-key-map", "", "unknown", "map", "scalar", "char", "scalar",
    "string", "complex-map", "", "unknown", "map", "scalar", "string", "option",
    "list", "scalar", "u32", "int-key-map", "", "unknown", "map", "scalar", "u32",
    "scalar", "string", "nested-map", "", "unknown", "map", "scalar", "string", "map",
    "scalar", "string", "scalar", "u32", "person", "", "unknown", "record", "2",
    "name", "scalar", "string", "age", "scalar", "u32", "person-map", "", "unknown",
    "map", "scalar", "string", "record", "2", "name", "scalar", "string", "age",
    "scalar", "u32", "string-to-u32", "", "unknown", "map", "scalar", "string", "scalar",
    "u32", "u32-to-string", "", "unknown", "map", "scalar", "u32", "scalar", "string",
    "3", "get-value", "", "unknown", "freestanding", "plain", "false", "2", "m",
    "map", "scalar", "string", "scalar", "u32", "key", "scalar", "string", "some",
    "option", "scalar", "u32", "merge-maps", "", "unknown", "freestanding", "plain",
    "false", "2", "a", "map", "scalar", "string", "scalar", "u32", "b", "map", "scalar",
    "string", "scalar", "u32", "some", "map", "scalar", "string", "scalar", "u32",
    "set-value", "", "unknown", "freestanding", "plain", "false", "3", "m", "map",
    "scalar", "string", "scalar", "u32", "key", "scalar", "string", "value", "scalar",
    "u32", "some", "map", "scalar", "string", "scalar", "u32", "worlds", "1", "world",
    "foo:maps/maps-world", "", "unknown", "imports", "1", "foo:maps/maps", "true",
    "interface", "", "unknown", "interface", "foo:maps/maps", "", "unknown", "8",
    "char-key-map", "", "unknown", "map", "scalar", "char", "scalar", "string", "complex-map",
    "", "unknown", "map", "scalar", "string", "option", "list", "scalar", "u32",
    "int-key-map", "", "unknown", "map", "scalar", "u32", "scalar", "string", "nested-map",
    "", "unknown", "map", "scalar", "string", "map", "scalar", "string", "scalar",
    "u32", "person", "", "unknown", "record", "2", "name", "scalar", "string", "age",
    "scalar", "u32", "person-map", "", "unknown", "map", "scalar", "string", "record",
    "2", "name", "scalar", "string", "age", "scalar", "u32", "string-to-u32", "",
    "unknown", "map", "scalar", "string", "scalar", "u32", "u32-to-string", "", "unknown",
    "map", "scalar", "u32", "scalar", "string", "3", "get-value", "", "unknown",
    "freestanding", "plain", "false", "2", "m", "map", "scalar", "string", "scalar",
    "u32", "key", "scalar", "string", "some", "option", "scalar", "u32", "merge-maps",
    "", "unknown", "freestanding", "plain", "false", "2", "a", "map", "scalar", "string",
    "scalar", "u32", "b", "map", "scalar", "string", "scalar", "u32", "some", "map",
    "scalar", "string", "scalar", "u32", "set-value", "", "unknown", "freestanding",
    "plain", "false", "3", "m", "map", "scalar", "string", "scalar", "u32", "key",
    "scalar", "string", "value", "scalar", "u32", "some", "map", "scalar", "string",
    "scalar", "u32", "exports", "1", "foo:maps/maps", "true", "interface", "", "unknown",
    "interface", "foo:maps/maps", "", "unknown", "8", "char-key-map", "", "unknown",
    "map", "scalar", "char", "scalar", "string", "complex-map", "", "unknown", "map",
    "scalar", "string", "option", "list", "scalar", "u32", "int-key-map", "", "unknown",
    "map", "scalar", "u32", "scalar", "string", "nested-map", "", "unknown", "map",
    "scalar", "string", "map", "scalar", "string", "scalar", "u32", "person", "",
    "unknown", "record", "2", "name", "scalar", "string", "age", "scalar", "u32",
    "person-map", "", "unknown", "map", "scalar", "string", "record", "2", "name",
    "scalar", "string", "age", "scalar", "u32", "string-to-u32", "", "unknown", "map",
    "scalar", "string", "scalar", "u32", "u32-to-string", "", "unknown", "map", "scalar",
    "u32", "scalar", "string", "3", "get-value", "", "unknown", "freestanding", "plain",
    "false", "2", "m", "map", "scalar", "string", "scalar", "u32", "key", "scalar",
    "string", "some", "option", "scalar", "u32", "merge-maps", "", "unknown", "freestanding",
    "plain", "false", "2", "a", "map", "scalar", "string", "scalar", "u32", "b",
    "map", "scalar", "string", "scalar", "u32", "some", "map", "scalar", "string",
    "scalar", "u32", "set-value", "", "unknown", "freestanding", "plain", "false",
    "3", "m", "map", "scalar", "string", "scalar", "u32", "key", "scalar", "string",
    "value", "scalar", "u32", "some", "map", "scalar", "string", "scalar", "u32",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic max-flags.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "max-flags.wit", "package foo:foo;\n\ninterface foo {\n  flags f {\n    b0,\n    b1,\n    b2,\n    b3,\n    b4,\n    b5,\n    b6,\n    b7,\n    b8,\n    b9,\n    b10,\n    b11,\n    b12,\n    b13,\n    b14,\n    b15,\n    b16,\n    b17,\n    b18,\n    b19,\n    b20,\n    b21,\n    b22,\n    b23,\n    b24,\n    b25,\n    b26,\n    b27,\n    b28,\n    b29,\n    b30,\n    b31,\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/foo", "",
    "unknown", "1", "f", "", "unknown", "flags", "32", "b0", "b1", "b2", "b3", "b4",
    "b5", "b6", "b7", "b8", "b9", "b10", "b11", "b12", "b13", "b14", "b15", "b16",
    "b17", "b18", "b19", "b20", "b21", "b22", "b23", "b24", "b25", "b26", "b27",
    "b28", "b29", "b30", "b31", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic multi-file" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "multi-file/bar.wit", "package foo:multi-file;\n\ninterface irrelevant-name {\n  record a-name {\n    a: u32,\n  }\n}\n\ninterface depends-on-later-item {\n  use depend-on-me.{x};\n}\n\ninterface depend-on-me {\n  type x = u32;\n}\n\nworld more-depends-on-later-things {\n  import later-interface;\n  export later-interface;\n}\n\ninterface later-interface {\n}\n",
        ),
        section_document(
          "multi-file/cycle-a.wit", "interface cycle1 {\n  type t = u32;\n}\n\ninterface cycle3 {\n  use cycle2.{t};\n}\n",
        ),
        section_document(
          "multi-file/cycle-b.wit", "interface cycle2 {\n  use cycle1.{t};\n}\n",
        ),
        section_document(
          "multi-file/foo.wit", "package foo:multi-file;\n\ninterface foo {\n  type x = u32;\n}\n\nuse foo as foo2;\n\ninterface something-else {\n  type y = u64;\n}\n\nuse depend-on-me as a-different-name;\n\ninterface bar {\n  use foo.{x};\n  use foo.{x as x2};\n  use foo2.{x as x3};\n  use a-different-name.{x as x4};\n  use something-else.{y};\n  use something-else.{y as y2};\n  use irrelevant-name.{a-name};\n}\n\nworld the-world {\n  import a-different-name;\n\n  use a-different-name.{x};\n\n  import foo: func() -> x;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:multi-file", "interfaces", "10", "interface", "foo:multi-file/bar",
    "", "unknown", "7", "a-name", "", "unknown", "record", "1", "a", "scalar", "u32",
    "x", "", "unknown", "scalar", "u32", "x2", "", "unknown", "scalar", "u32", "x3",
    "", "unknown", "scalar", "u32", "x4", "", "unknown", "scalar", "u32", "y", "",
    "unknown", "scalar", "u64", "y2", "", "unknown", "scalar", "u64", "0", "interface",
    "foo:multi-file/cycle1", "", "unknown", "1", "t", "", "unknown", "scalar", "u32",
    "0", "interface", "foo:multi-file/cycle2", "", "unknown", "1", "t", "", "unknown",
    "scalar", "u32", "0", "interface", "foo:multi-file/cycle3", "", "unknown", "1",
    "t", "", "unknown", "scalar", "u32", "0", "interface", "foo:multi-file/depend-on-me",
    "", "unknown", "1", "x", "", "unknown", "scalar", "u32", "0", "interface", "foo:multi-file/depends-on-later-item",
    "", "unknown", "1", "x", "", "unknown", "scalar", "u32", "0", "interface", "foo:multi-file/foo",
    "", "unknown", "1", "x", "", "unknown", "scalar", "u32", "0", "interface", "foo:multi-file/irrelevant-name",
    "", "unknown", "1", "a-name", "", "unknown", "record", "1", "a", "scalar", "u32",
    "0", "interface", "foo:multi-file/later-interface", "", "unknown", "0", "0",
    "interface", "foo:multi-file/something-else", "", "unknown", "1", "y", "", "unknown",
    "scalar", "u64", "0", "worlds", "2", "world", "foo:multi-file/more-depends-on-later-things",
    "", "unknown", "imports", "1", "foo:multi-file/later-interface", "true", "interface",
    "", "unknown", "interface", "foo:multi-file/later-interface", "", "unknown",
    "0", "0", "exports", "1", "foo:multi-file/later-interface", "true", "interface",
    "", "unknown", "interface", "foo:multi-file/later-interface", "", "unknown",
    "0", "0", "world", "foo:multi-file/the-world", "", "unknown", "imports", "3",
    "foo", "false", "function", "foo", "", "unknown", "freestanding", "plain", "false",
    "0", "some", "scalar", "u32", "foo:multi-file/depend-on-me", "true", "interface",
    "", "unknown", "interface", "foo:multi-file/depend-on-me", "", "unknown", "1",
    "x", "", "unknown", "scalar", "u32", "0", "x", "false", "type", "", "unknown",
    "scalar", "u32", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic multi-file-multi-package" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "multi-file-multi-package/a.wit", "package foo:main;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n\npackage bar:name {\n  interface i2 {\n    type b = u32;\n  }\n\n  world w2 {\n    import imp2: interface {\n        use i2.{b};\n    }\n  }\n}\n",
        ),
        section_document(
          "multi-file-multi-package/b.wit", "package baz:name {\n  interface i3 {\n    type a = u32;\n  }\n\n  world w3 {\n    import imp3: interface {\n        use i3.{a};\n    }\n  }\n}\n\npackage qux:name {\n  interface i4 {\n    type b = u32;\n  }\n\n  world w4 {\n    import imp4: interface {\n        use i4.{b};\n    }\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "5", "bar:name", "baz:name", "foo:main", "foo:name", "qux:name",
    "interfaces", "4", "interface", "bar:name/i2", "", "unknown", "1", "b", "", "unknown",
    "scalar", "u32", "0", "interface", "baz:name/i3", "", "unknown", "1", "a", "",
    "unknown", "scalar", "u32", "0", "interface", "foo:name/i1", "", "unknown", "1",
    "a", "", "unknown", "scalar", "u32", "0", "interface", "qux:name/i4", "", "unknown",
    "1", "b", "", "unknown", "scalar", "u32", "0", "worlds", "4", "world", "bar:name/w2",
    "", "unknown", "imports", "2", "bar:name/i2", "true", "interface", "", "unknown",
    "interface", "bar:name/i2", "", "unknown", "1", "b", "", "unknown", "scalar",
    "u32", "0", "imp2", "false", "interface", "", "unknown", "interface", "", "",
    "unknown", "1", "b", "", "unknown", "scalar", "u32", "0", "exports", "0", "world",
    "baz:name/w3", "", "unknown", "imports", "2", "baz:name/i3", "true", "interface",
    "", "unknown", "interface", "baz:name/i3", "", "unknown", "1", "a", "", "unknown",
    "scalar", "u32", "0", "imp3", "false", "interface", "", "unknown", "interface",
    "", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "exports",
    "0", "world", "foo:name/w1", "", "unknown", "imports", "2", "foo:name/i1", "true",
    "interface", "", "unknown", "interface", "foo:name/i1", "", "unknown", "1", "a",
    "", "unknown", "scalar", "u32", "0", "imp1", "false", "interface", "", "unknown",
    "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0",
    "exports", "0", "world", "qux:name/w4", "", "unknown", "imports", "2", "imp4",
    "false", "interface", "", "unknown", "interface", "", "", "unknown", "1", "b",
    "", "unknown", "scalar", "u32", "0", "qux:name/i4", "true", "interface", "",
    "unknown", "interface", "qux:name/i4", "", "unknown", "1", "b", "", "unknown",
    "scalar", "u32", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic multi-package-deps" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "multi-package-deps/root.wit", "package foo:root;\n\npackage foo:nest {\n  interface nesty {\n    use foo:dep1/i1.{o};\n    type l = list<o>;\n  }\n}\n\ninterface i0 {\n  use foo:dep1/i1.{o};\n  use foo:nest/nesty.{l};\n\n  type r = result<o>;\n  type r1 = result<l>;\n}",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "multi-package-deps/deps/dep.wit", "package foo:dep1;\n\npackage foo:dep2 {\n  interface i2 {\n    type t = string;\n  }\n}\n\ninterface i1 {\n  use foo:dep2/i2.{t};\n\n  type o = option<t>;\n}",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "4", "foo:dep1", "foo:dep2", "foo:nest", "foo:root", "interfaces",
    "4", "interface", "foo:dep1/i1", "", "unknown", "2", "o", "", "unknown", "option",
    "scalar", "string", "t", "", "unknown", "scalar", "string", "0", "interface",
    "foo:dep2/i2", "", "unknown", "1", "t", "", "unknown", "scalar", "string", "0",
    "interface", "foo:nest/nesty", "", "unknown", "2", "l", "", "unknown", "list",
    "option", "scalar", "string", "o", "", "unknown", "option", "scalar", "string",
    "0", "interface", "foo:root/i0", "", "unknown", "4", "l", "", "unknown", "list",
    "option", "scalar", "string", "o", "", "unknown", "option", "scalar", "string",
    "r", "", "unknown", "result", "some", "option", "scalar", "string", "none", "r1",
    "", "unknown", "result", "some", "list", "option", "scalar", "string", "none",
    "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic multi-package-gated-include.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "multi-package-gated-include.wit", "package wasmtime:test;\n\nworld test{\n    @unstable(feature = active)\n    include wasi:unstable/imports@0.2.3; \n    include wasi:foo/imports@0.2.3;\n    include wasi:someother/imports@0.2.3;\n}\n\nworld test-ordered {\n    include wasi:someother/imports@0.2.3;\n    include wasi:foo/imports@0.2.3;\n    @unstable(feature = active)\n    include wasi:unstable/imports@0.2.3; \n}\n\nworld test-no-stability {\n    include wasi:someother/imports@0.2.3;\n    include wasi:foo/imports@0.2.3;\n    include wasi:unstable/imports@0.2.3; \n}\n\nworld test-only-stable {\n    include wasi:foo/imports@0.2.3;\n}\n\nworld test-only-stable-with-feature {\n    @unstable(feature = active)\n    include wasi:foo/imports@0.2.3;\n}\n\n// in test this results in world with nothing\nworld test-only-stable-with-in-active-feature {\n    @unstable(feature = in-active)\n    include wasi:foo/imports@0.2.3;\n}\n\npackage wasi:unstable@0.2.3 {\n    @unstable(feature = active)\n    world imports {\n        @unstable(feature = active)\n        use wasi:dep2/stable@0.2.3.{stable-resource};\n        @unstable(feature = active)\n        use wasi:dep-unversioned/unversioned.{unversioned-resource};\n        @unstable(feature = active)\n        use wasi:dep-unstable/unstable.{unstable-resource};\n    }\n}\n\npackage wasi:someother@0.2.3 {\n    @since(version = 0.2.0)\n    world imports {\n        import someother;\n    }\n\n    @since(version = 0.2.0)\n    interface someother {\n        @since(version = 0.2.0)\n        resource someother-resource {\n        }\n    }\n}\n\n\n\npackage wasi:foo@0.2.3 {\n    @since(version = 0.2.0)\n    world imports {\n        @since(version = 0.2.0)\n        include wasi:dep2/imports@0.2.3;\n        include wasi:dep-unversioned/imports;\n        include wasi:dep-unstable/imports;\n    }\n}\n\npackage wasi:dep2@0.2.3 {\n    @since(version = 0.2.0)\n    world imports {\n        @since(version = 0.2.0)\n        import stable;\n    }\n    @since(version = 0.2.0)\n    interface stable {\n        resource stable-resource {\n        }\n    }\n}\n\npackage wasi:dep-unversioned{\n    world imports {\n        import unversioned;\n    }\n    interface unversioned {\n        resource unversioned-resource {\n\n        }\n    }\n}\n\npackage wasi:dep-unstable{\n    @unstable(feature = active)\n    world imports {\n        @unstable(feature = active)\n        import unstable;\n    }\n    @unstable(feature = active)\n    interface unstable {\n        @unstable(feature = active)\n        resource unstable-resource {\n\n        }\n    }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "7", "wasi:dep-unstable", "wasi:dep-unversioned", "wasi:dep2@0.2.3",
    "wasi:foo@0.2.3", "wasi:someother@0.2.3", "wasi:unstable@0.2.3", "wasmtime:test",
    "interfaces", "4", "interface", "wasi:dep-unstable/unstable", "", "unstable",
    "active", "", "1", "unstable-resource", "", "unstable", "active", "", "resource",
    "0", "0", "interface", "wasi:dep-unversioned/unversioned", "", "unknown", "1",
    "unversioned-resource", "", "unknown", "resource", "1", "0", "interface", "wasi:dep2/stable@0.2.3",
    "", "stable", "0.2.0", "", "1", "stable-resource", "", "unknown", "resource",
    "2", "0", "interface", "wasi:someother/someother@0.2.3", "", "stable", "0.2.0",
    "", "1", "someother-resource", "", "stable", "0.2.0", "", "resource", "3", "0",
    "worlds", "12", "world", "wasi:dep-unstable/imports", "", "unstable", "active",
    "", "imports", "1", "wasi:dep-unstable/unstable", "true", "interface", "", "unstable",
    "active", "", "interface", "wasi:dep-unstable/unstable", "", "unstable", "active",
    "", "1", "unstable-resource", "", "unstable", "active", "", "resource", "0",
    "0", "exports", "0", "world", "wasi:dep-unversioned/imports", "", "unknown",
    "imports", "1", "wasi:dep-unversioned/unversioned", "true", "interface", "",
    "unknown", "interface", "wasi:dep-unversioned/unversioned", "", "unknown", "1",
    "unversioned-resource", "", "unknown", "resource", "1", "0", "exports", "0",
    "world", "wasi:dep2/imports@0.2.3", "", "stable", "0.2.0", "", "imports", "1",
    "wasi:dep2/stable@0.2.3", "true", "interface", "", "stable", "0.2.0", "", "interface",
    "wasi:dep2/stable@0.2.3", "", "stable", "0.2.0", "", "1", "stable-resource",
    "", "unknown", "resource", "2", "0", "exports", "0", "world", "wasi:foo/imports@0.2.3",
    "", "stable", "0.2.0", "", "imports", "3", "wasi:dep-unstable/unstable", "true",
    "interface", "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable",
    "", "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unknown", "interface", "wasi:dep-unversioned/unversioned", "", "unknown",
    "1", "unversioned-resource", "", "unknown", "resource", "1", "0", "wasi:dep2/stable@0.2.3",
    "true", "interface", "", "unknown", "interface", "wasi:dep2/stable@0.2.3", "",
    "stable", "0.2.0", "", "1", "stable-resource", "", "unknown", "resource", "2",
    "0", "exports", "0", "world", "wasi:someother/imports@0.2.3", "", "stable", "0.2.0",
    "", "imports", "1", "wasi:someother/someother@0.2.3", "true", "interface", "",
    "unknown", "interface", "wasi:someother/someother@0.2.3", "", "stable", "0.2.0",
    "", "1", "someother-resource", "", "stable", "0.2.0", "", "resource", "3", "0",
    "exports", "0", "world", "wasi:unstable/imports@0.2.3", "", "unstable", "active",
    "", "imports", "6", "stable-resource", "false", "type", "", "unstable", "active",
    "", "resource", "2", "unstable-resource", "false", "type", "", "unstable", "active",
    "", "resource", "0", "unversioned-resource", "false", "type", "", "unstable",
    "active", "", "resource", "1", "wasi:dep-unstable/unstable", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable", "",
    "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unversioned/unversioned",
    "", "unknown", "1", "unversioned-resource", "", "unknown", "resource", "1", "0",
    "wasi:dep2/stable@0.2.3", "true", "interface", "", "unstable", "active", "",
    "interface", "wasi:dep2/stable@0.2.3", "", "stable", "0.2.0", "", "1", "stable-resource",
    "", "unknown", "resource", "2", "0", "exports", "0", "world", "wasmtime:test/test",
    "", "unknown", "imports", "7", "stable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "2", "unstable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "0", "unversioned-resource", "false", "type", "", "unstable",
    "active", "", "resource", "1", "wasi:dep-unstable/unstable", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable", "",
    "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unversioned/unversioned",
    "", "unknown", "1", "unversioned-resource", "", "unknown", "resource", "1", "0",
    "wasi:dep2/stable@0.2.3", "true", "interface", "", "unstable", "active", "",
    "interface", "wasi:dep2/stable@0.2.3", "", "stable", "0.2.0", "", "1", "stable-resource",
    "", "unknown", "resource", "2", "0", "wasi:someother/someother@0.2.3", "true",
    "interface", "", "unknown", "interface", "wasi:someother/someother@0.2.3", "",
    "stable", "0.2.0", "", "1", "someother-resource", "", "stable", "0.2.0", "",
    "resource", "3", "0", "exports", "0", "world", "wasmtime:test/test-no-stability",
    "", "unknown", "imports", "7", "stable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "2", "unstable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "0", "unversioned-resource", "false", "type", "", "unstable",
    "active", "", "resource", "1", "wasi:dep-unstable/unstable", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable", "",
    "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unversioned/unversioned",
    "", "unknown", "1", "unversioned-resource", "", "unknown", "resource", "1", "0",
    "wasi:dep2/stable@0.2.3", "true", "interface", "", "unstable", "active", "",
    "interface", "wasi:dep2/stable@0.2.3", "", "stable", "0.2.0", "", "1", "stable-resource",
    "", "unknown", "resource", "2", "0", "wasi:someother/someother@0.2.3", "true",
    "interface", "", "unknown", "interface", "wasi:someother/someother@0.2.3", "",
    "stable", "0.2.0", "", "1", "someother-resource", "", "stable", "0.2.0", "",
    "resource", "3", "0", "exports", "0", "world", "wasmtime:test/test-only-stable",
    "", "unknown", "imports", "3", "wasi:dep-unstable/unstable", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable", "",
    "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unknown", "interface", "wasi:dep-unversioned/unversioned", "", "unknown",
    "1", "unversioned-resource", "", "unknown", "resource", "1", "0", "wasi:dep2/stable@0.2.3",
    "true", "interface", "", "unknown", "interface", "wasi:dep2/stable@0.2.3", "",
    "stable", "0.2.0", "", "1", "stable-resource", "", "unknown", "resource", "2",
    "0", "exports", "0", "world", "wasmtime:test/test-only-stable-with-feature",
    "", "unknown", "imports", "3", "wasi:dep-unstable/unstable", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable", "",
    "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unknown", "interface", "wasi:dep-unversioned/unversioned", "", "unknown",
    "1", "unversioned-resource", "", "unknown", "resource", "1", "0", "wasi:dep2/stable@0.2.3",
    "true", "interface", "", "unknown", "interface", "wasi:dep2/stable@0.2.3", "",
    "stable", "0.2.0", "", "1", "stable-resource", "", "unknown", "resource", "2",
    "0", "exports", "0", "world", "wasmtime:test/test-only-stable-with-in-active-feature",
    "", "unknown", "imports", "0", "exports", "0", "world", "wasmtime:test/test-ordered",
    "", "unknown", "imports", "7", "stable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "2", "unstable-resource", "false", "type", "", "unstable",
    "active", "", "resource", "0", "unversioned-resource", "false", "type", "", "unstable",
    "active", "", "resource", "1", "wasi:dep-unstable/unstable", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unstable/unstable", "",
    "unstable", "active", "", "1", "unstable-resource", "", "unstable", "active",
    "", "resource", "0", "0", "wasi:dep-unversioned/unversioned", "true", "interface",
    "", "unstable", "active", "", "interface", "wasi:dep-unversioned/unversioned",
    "", "unknown", "1", "unversioned-resource", "", "unknown", "resource", "1", "0",
    "wasi:dep2/stable@0.2.3", "true", "interface", "", "unstable", "active", "",
    "interface", "wasi:dep2/stable@0.2.3", "", "stable", "0.2.0", "", "1", "stable-resource",
    "", "unknown", "resource", "2", "0", "wasi:someother/someother@0.2.3", "true",
    "interface", "", "unknown", "interface", "wasi:someother/someother@0.2.3", "",
    "stable", "0.2.0", "", "1", "someother-resource", "", "stable", "0.2.0", "",
    "resource", "3", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic multi-package-shared-deps" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "multi-package-shared-deps/packages.wit", "package foo:root;\npackage foo:bar {\n  interface i0 {\n    use foo:dep1/types.{type1};\n    use foo:dep2/types.{type2};\n    record rec0 {\n      foo: type1,\n      bar: type2\n    }\n  }\n  world w-bar {\n    import foo:dep1/types;\n    import foo:dep2/types;\n  }\n}\n\npackage foo:qux {\n  interface i1 {\n    use foo:dep1/types.{type1};\n    use foo:dep2/types.{type2};\n    record rec1 {\n      foo: type1,\n      bar: type2\n    }\n  }\n  world w-qux {\n    import foo:dep1/types;\n    import foo:dep2/types;\n  }\n}\n\ninterface root {\n  use foo:bar/i0.{rec0};\n  use foo:qux/i1.{rec1};\n  record rec {\n    first: rec0,\n    second: rec1\n  }\n}\n\n\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "multi-package-shared-deps/deps/dep1/types.wit", "package foo:dep1;\ninterface types {\n  type type1 = string;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "multi-package-shared-deps/deps/dep2/types.wit", "package foo:dep2;\ninterface types {\n  type type2 = string;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "5", "foo:bar", "foo:dep1", "foo:dep2", "foo:qux", "foo:root", "interfaces",
    "5", "interface", "foo:bar/i0", "", "unknown", "3", "rec0", "", "unknown", "record",
    "2", "foo", "scalar", "string", "bar", "scalar", "string", "type1", "", "unknown",
    "scalar", "string", "type2", "", "unknown", "scalar", "string", "0", "interface",
    "foo:dep1/types", "", "unknown", "1", "type1", "", "unknown", "scalar", "string",
    "0", "interface", "foo:dep2/types", "", "unknown", "1", "type2", "", "unknown",
    "scalar", "string", "0", "interface", "foo:qux/i1", "", "unknown", "3", "rec1",
    "", "unknown", "record", "2", "foo", "scalar", "string", "bar", "scalar", "string",
    "type1", "", "unknown", "scalar", "string", "type2", "", "unknown", "scalar",
    "string", "0", "interface", "foo:root/root", "", "unknown", "3", "rec", "", "unknown",
    "record", "2", "first", "record", "2", "foo", "scalar", "string", "bar", "scalar",
    "string", "second", "record", "2", "foo", "scalar", "string", "bar", "scalar",
    "string", "rec0", "", "unknown", "record", "2", "foo", "scalar", "string", "bar",
    "scalar", "string", "rec1", "", "unknown", "record", "2", "foo", "scalar", "string",
    "bar", "scalar", "string", "0", "worlds", "2", "world", "foo:bar/w-bar", "",
    "unknown", "imports", "2", "foo:dep1/types", "true", "interface", "", "unknown",
    "interface", "foo:dep1/types", "", "unknown", "1", "type1", "", "unknown", "scalar",
    "string", "0", "foo:dep2/types", "true", "interface", "", "unknown", "interface",
    "foo:dep2/types", "", "unknown", "1", "type2", "", "unknown", "scalar", "string",
    "0", "exports", "0", "world", "foo:qux/w-qux", "", "unknown", "imports", "2",
    "foo:dep1/types", "true", "interface", "", "unknown", "interface", "foo:dep1/types",
    "", "unknown", "1", "type1", "", "unknown", "scalar", "string", "0", "foo:dep2/types",
    "true", "interface", "", "unknown", "interface", "foo:dep2/types", "", "unknown",
    "1", "type2", "", "unknown", "scalar", "string", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic multi-package-transitive-deps" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "multi-package-transitive-deps/packages.wit", "package foo:root;\npackage foo:bar {\n  world w-bar {\n    import foo:dep1/types;\n  }\n}\n\npackage foo:qux {\n  world w-qux {\n    import foo:dep2/types;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "multi-package-transitive-deps/deps/dep1/types.wit", "package foo:dep1;\n\ninterface types {\n  use foo:dep2/types.{a};\n  record b {\n    r: a,\n  }\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "multi-package-transitive-deps/deps/dep2/types.wit", "package foo:dep2;\n\ninterface types {\n  use foo:nest/types.{t2};\n  record a {\n    foo: t2\n  }\n}\n\npackage foo:nest {\n  interface types {\n    type t2 = string;\n  }\n}",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "6", "foo:bar", "foo:dep1", "foo:dep2", "foo:nest", "foo:qux", "foo:root",
    "interfaces", "3", "interface", "foo:dep1/types", "", "unknown", "2", "a", "",
    "unknown", "record", "1", "foo", "scalar", "string", "b", "", "unknown", "record",
    "1", "r", "record", "1", "foo", "scalar", "string", "0", "interface", "foo:dep2/types",
    "", "unknown", "2", "a", "", "unknown", "record", "1", "foo", "scalar", "string",
    "t2", "", "unknown", "scalar", "string", "0", "interface", "foo:nest/types",
    "", "unknown", "1", "t2", "", "unknown", "scalar", "string", "0", "worlds", "2",
    "world", "foo:bar/w-bar", "", "unknown", "imports", "3", "foo:dep1/types", "true",
    "interface", "", "unknown", "interface", "foo:dep1/types", "", "unknown", "2",
    "a", "", "unknown", "record", "1", "foo", "scalar", "string", "b", "", "unknown",
    "record", "1", "r", "record", "1", "foo", "scalar", "string", "0", "foo:dep2/types",
    "true", "interface", "", "unknown", "interface", "foo:dep2/types", "", "unknown",
    "2", "a", "", "unknown", "record", "1", "foo", "scalar", "string", "t2", "",
    "unknown", "scalar", "string", "0", "foo:nest/types", "true", "interface", "",
    "unknown", "interface", "foo:nest/types", "", "unknown", "1", "t2", "", "unknown",
    "scalar", "string", "0", "exports", "0", "world", "foo:qux/w-qux", "", "unknown",
    "imports", "2", "foo:dep2/types", "true", "interface", "", "unknown", "interface",
    "foo:dep2/types", "", "unknown", "2", "a", "", "unknown", "record", "1", "foo",
    "scalar", "string", "t2", "", "unknown", "scalar", "string", "0", "foo:nest/types",
    "true", "interface", "", "unknown", "interface", "foo:nest/types", "", "unknown",
    "1", "t2", "", "unknown", "scalar", "string", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic name-both-resource-and-type" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "name-both-resource-and-type/foo.wit", "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{a};\n\n  type t1 = a;\n  type t2 = borrow<a>;\n  type t3 = borrow<t1>;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "name-both-resource-and-type/deps/dep/foo.wit", "package some:dep;\n\ninterface foo {\n  resource a;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "2", "foo:bar", "some:dep", "interfaces", "2", "interface", "foo:bar/foo",
    "", "unknown", "4", "a", "", "unknown", "resource", "0", "t1", "", "unknown",
    "resource", "0", "t2", "", "unknown", "borrow", "0", "t3", "", "unknown", "borrow",
    "0", "0", "interface", "some:dep/foo", "", "unknown", "1", "a", "", "unknown",
    "resource", "0", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic package-syntax1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [section_document("package-syntax1.wit", "package foo:foo;\n")],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic package-syntax3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [section_document("package-syntax3.wit", "package foo:bar;\n")],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar", "interfaces", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic package-syntax4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document("package-syntax4.wit", "package foo:bar@2.0.0;\n"),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar@2.0.0", "interfaces", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic packages-multiple-nested.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "packages-multiple-nested.wit", "package foo:root;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n\npackage bar:name {\n  interface i2 {\n    type b = u32;\n  }\n\n  world w2 {\n    import imp2: interface {\n        use i2.{b};\n    }\n  }\n}\n\ninterface i0 {\n  use foo:name/i1.{a};\n\n  type c = option<a>;\n}\n\nworld w0 {\n  export i0;\n  import foo:name/i1;\n}",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "bar:name", "foo:name", "foo:root", "interfaces", "3", "interface",
    "bar:name/i2", "", "unknown", "1", "b", "", "unknown", "scalar", "u32", "0",
    "interface", "foo:name/i1", "", "unknown", "1", "a", "", "unknown", "scalar",
    "u32", "0", "interface", "foo:root/i0", "", "unknown", "2", "a", "", "unknown",
    "scalar", "u32", "c", "", "unknown", "option", "scalar", "u32", "0", "worlds",
    "3", "world", "bar:name/w2", "", "unknown", "imports", "2", "bar:name/i2", "true",
    "interface", "", "unknown", "interface", "bar:name/i2", "", "unknown", "1", "b",
    "", "unknown", "scalar", "u32", "0", "imp2", "false", "interface", "", "unknown",
    "interface", "", "", "unknown", "1", "b", "", "unknown", "scalar", "u32", "0",
    "exports", "0", "world", "foo:name/w1", "", "unknown", "imports", "2", "foo:name/i1",
    "true", "interface", "", "unknown", "interface", "foo:name/i1", "", "unknown",
    "1", "a", "", "unknown", "scalar", "u32", "0", "imp1", "false", "interface",
    "", "unknown", "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar",
    "u32", "0", "exports", "0", "world", "foo:root/w0", "", "unknown", "imports",
    "1", "foo:name/i1", "true", "interface", "", "unknown", "interface", "foo:name/i1",
    "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "exports", "1",
    "foo:root/i0", "true", "interface", "", "unknown", "interface", "foo:root/i0",
    "", "unknown", "2", "a", "", "unknown", "scalar", "u32", "c", "", "unknown",
    "option", "scalar", "u32", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic packages-nested-colliding-decl-names.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "packages-nested-colliding-decl-names.wit", "package foo:root;\npackage foo:name {\n  interface i {\n    type a = u32;\n  }\n\n  world w {\n    import imp: interface {\n        use i.{a};\n    }\n  }\n}\n\npackage bar:name {\n  interface i {\n    type a = u32;\n  }\n\n  world w {\n    import imp: interface {\n        use i.{a};\n    }\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "bar:name", "foo:name", "foo:root", "interfaces", "2", "interface",
    "bar:name/i", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:name/i", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "worlds",
    "2", "world", "bar:name/w", "", "unknown", "imports", "2", "bar:name/i", "true",
    "interface", "", "unknown", "interface", "bar:name/i", "", "unknown", "1", "a",
    "", "unknown", "scalar", "u32", "0", "imp", "false", "interface", "", "unknown",
    "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0",
    "exports", "0", "world", "foo:name/w", "", "unknown", "imports", "2", "foo:name/i",
    "true", "interface", "", "unknown", "interface", "foo:name/i", "", "unknown",
    "1", "a", "", "unknown", "scalar", "u32", "0", "imp", "false", "interface", "",
    "unknown", "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar",
    "u32", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic packages-nested-internal-references.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "packages-nested-internal-references.wit", "package foo:root;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n}\n\npackage bar:name {\n  world w1 {\n    import imp1: interface {\n      use foo:name/i1.{a};\n\n      fn: func(a: a);\n    }\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "bar:name", "foo:name", "foo:root", "interfaces", "1", "interface",
    "foo:name/i1", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0",
    "worlds", "1", "world", "bar:name/w1", "", "unknown", "imports", "2", "foo:name/i1",
    "true", "interface", "", "unknown", "interface", "foo:name/i1", "", "unknown",
    "1", "a", "", "unknown", "scalar", "u32", "0", "imp1", "false", "interface",
    "", "unknown", "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar",
    "u32", "1", "fn", "", "unknown", "freestanding", "plain", "false", "1", "a",
    "scalar", "u32", "none", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic packages-nested-with-semver.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "packages-nested-with-semver.wit", "package foo:root;\npackage foo:name@1.0.0 {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n\npackage foo:name@1.0.1 {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "foo:name@1.0.0", "foo:name@1.0.1", "foo:root", "interfaces",
    "2", "interface", "foo:name/i1@1.0.0", "", "unknown", "1", "a", "", "unknown",
    "scalar", "u32", "0", "interface", "foo:name/i1@1.0.1", "", "unknown", "1", "a",
    "", "unknown", "scalar", "u32", "0", "worlds", "2", "world", "foo:name/w1@1.0.0",
    "", "unknown", "imports", "2", "foo:name/i1@1.0.0", "true", "interface", "",
    "unknown", "interface", "foo:name/i1@1.0.0", "", "unknown", "1", "a", "", "unknown",
    "scalar", "u32", "0", "imp1", "false", "interface", "", "unknown", "interface",
    "", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "exports",
    "0", "world", "foo:name/w1@1.0.1", "", "unknown", "imports", "2", "foo:name/i1@1.0.1",
    "true", "interface", "", "unknown", "interface", "foo:name/i1@1.0.1", "", "unknown",
    "1", "a", "", "unknown", "scalar", "u32", "0", "imp1", "false", "interface",
    "", "unknown", "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar",
    "u32", "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic packages-single-nested.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "packages-single-nested.wit", "package foo:root;\npackage foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "2", "foo:name", "foo:root", "interfaces", "1", "interface", "foo:name/i1",
    "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "worlds", "1",
    "world", "foo:name/w1", "", "unknown", "imports", "2", "foo:name/i1", "true",
    "interface", "", "unknown", "interface", "foo:name/i1", "", "unknown", "1", "a",
    "", "unknown", "scalar", "u32", "0", "imp1", "false", "interface", "", "unknown",
    "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0",
    "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic random.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "random.wit", "package wasi:random;\n\n/// WASI Random is a random data API.\n///\n/// It is intended to be portable at least between Unix-family platforms and\n/// Windows.\ninterface random {\n    /// Return `len` cryptographically-secure random or pseudo-random bytes.\n    ///\n    /// This function must produce data at least as cryptographically secure and\n    /// fast as an adequately seeded cryptographically-secure pseudo-random\n    /// number generator (CSPRNG). It must not block, from the perspective of\n    /// the calling program, under any circumstances, including on the first\n    /// request and on requests for numbers of bytes. The returned data must\n    /// always be unpredictable.\n    ///\n    /// This function must always return fresh data. Deterministic environments\n    /// must omit this function, rather than implementing it with deterministic\n    /// data.\n    get-random-bytes: func(len: u64) -> list<u8>;\n\n    /// Return a cryptographically-secure random or pseudo-random `u64` value.\n    ///\n    /// This function returns the same type of data as `get-random-bytes`,\n    /// represented as a `u64`.\n    get-random-u64: func() -> u64;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "wasi:random", "interfaces", "1", "interface", "wasi:random/random",
    "", "unknown", "0", "2", "get-random-bytes", "", "unknown", "freestanding", "plain",
    "false", "1", "len", "scalar", "u64", "some", "list", "scalar", "u8", "get-random-u64",
    "", "unknown", "freestanding", "plain", "false", "0", "some", "scalar", "u64",
    "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic resources-empty.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "resources-empty.wit", "package foo:resources-empty;\n\ninterface resources-empty {\n  t1: func(a: own<r1>);\n  t2: func(a: borrow<r1>);\n\n  resource r1 {\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:resources-empty", "interfaces", "1", "interface", "foo:resources-empty/resources-empty",
    "", "unknown", "1", "r1", "", "unknown", "resource", "0", "2", "t1", "", "unknown",
    "freestanding", "plain", "false", "1", "a", "own", "0", "none", "t2", "", "unknown",
    "freestanding", "plain", "false", "1", "a", "borrow", "0", "none", "worlds",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic resources-multiple-returns-own.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "resources-multiple-returns-own.wit", "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: own<r1>);\n\n  resource r1 {\n    f1: func() -> tuple<s32, own<r1>>;\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:resources1", "interfaces", "1", "interface", "foo:resources1/resources1",
    "", "unknown", "1", "r1", "", "unknown", "resource", "0", "2", "[method]r1.f1",
    "", "unknown", "method", "plain", "false", "resource", "0", "1", "self", "borrow",
    "0", "some", "tuple", "2", "scalar", "s32", "own", "0", "t1", "", "unknown",
    "freestanding", "plain", "false", "1", "a", "own", "0", "none", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic resources-multiple.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "resources-multiple.wit", "package foo:resources-multiple;\n\ninterface resources-multiple {\n  t1: func(a: borrow<r1>);\n  t2: func(a: own<r1>);\n\n  resource r1 {\n    f1: func();\n    f2: func(a: u32);\n    f3: func(a: u32,);\n    f4: func() -> u32;\n    f6: func() -> tuple<u32, u32>;\n    f7: func(a: f32, b: f32) -> tuple<u32, u32>;\n    f8: func(a: option<u32>) -> result<u32, f32>;\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:resources-multiple", "interfaces", "1", "interface", "foo:resources-multiple/resources-multiple",
    "", "unknown", "1", "r1", "", "unknown", "resource", "0", "9", "[method]r1.f1",
    "", "unknown", "method", "plain", "false", "resource", "0", "1", "self", "borrow",
    "0", "none", "[method]r1.f2", "", "unknown", "method", "plain", "false", "resource",
    "0", "2", "self", "borrow", "0", "a", "scalar", "u32", "none", "[method]r1.f3",
    "", "unknown", "method", "plain", "false", "resource", "0", "2", "self", "borrow",
    "0", "a", "scalar", "u32", "none", "[method]r1.f4", "", "unknown", "method",
    "plain", "false", "resource", "0", "1", "self", "borrow", "0", "some", "scalar",
    "u32", "[method]r1.f6", "", "unknown", "method", "plain", "false", "resource",
    "0", "1", "self", "borrow", "0", "some", "tuple", "2", "scalar", "u32", "scalar",
    "u32", "[method]r1.f7", "", "unknown", "method", "plain", "false", "resource",
    "0", "3", "self", "borrow", "0", "a", "scalar", "f32", "b", "scalar", "f32",
    "some", "tuple", "2", "scalar", "u32", "scalar", "u32", "[method]r1.f8", "",
    "unknown", "method", "plain", "false", "resource", "0", "2", "self", "borrow",
    "0", "a", "option", "scalar", "u32", "some", "result", "some", "scalar", "u32",
    "some", "scalar", "f32", "t1", "", "unknown", "freestanding", "plain", "false",
    "1", "a", "borrow", "0", "none", "t2", "", "unknown", "freestanding", "plain",
    "false", "1", "a", "own", "0", "none", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic resources-return-own.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "resources-return-own.wit", "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: own<r1>);\n\n  resource r1 {\n    f1: func() -> own<r1>;\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:resources1", "interfaces", "1", "interface", "foo:resources1/resources1",
    "", "unknown", "1", "r1", "", "unknown", "resource", "0", "2", "[method]r1.f1",
    "", "unknown", "method", "plain", "false", "resource", "0", "1", "self", "borrow",
    "0", "some", "own", "0", "t1", "", "unknown", "freestanding", "plain", "false",
    "1", "a", "own", "0", "none", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic resources.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "resources.wit", "package foo:bar;\n\ninterface foo {\n  resource a {\n  }\n\n  resource b {\n    constructor();\n  }\n\n  resource c {\n    constructor(x: u32);\n  }\n\n  resource d {\n    constructor(x: u32);\n\n    a: func();\n\n    b: static func();\n  }\n\n  resource e {\n    constructor(other: own<e>, other2: borrow<e>);\n\n    method: func(thing: own<e>, thing2: borrow<e>);\n  }\n\n  resource f {\n    constructor() -> result<f>;\n  }\n\n  resource g {\n    constructor() -> result<g, string>;\n  }\n}\n\nworld w {\n  resource a;\n\n  resource b {\n  }\n\n  resource c {\n    constructor();\n  }\n}\n\ninterface i {\n  resource a;\n\n  type t1 = a;\n  type t2 = borrow<a>;\n  type t3 = borrow<t1>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar", "interfaces", "2", "interface", "foo:bar/foo", "",
    "unknown", "7", "a", "", "unknown", "resource", "0", "b", "", "unknown", "resource",
    "1", "c", "", "unknown", "resource", "2", "d", "", "unknown", "resource", "3",
    "e", "", "unknown", "resource", "4", "f", "", "unknown", "resource", "5", "g",
    "", "unknown", "resource", "6", "9", "[constructor]b", "", "unknown", "constructor",
    "plain", "false", "resource", "1", "0", "some", "own", "1", "[constructor]c",
    "", "unknown", "constructor", "plain", "false", "resource", "2", "1", "x", "scalar",
    "u32", "some", "own", "2", "[constructor]d", "", "unknown", "constructor", "plain",
    "false", "resource", "3", "1", "x", "scalar", "u32", "some", "own", "3", "[constructor]e",
    "", "unknown", "constructor", "plain", "false", "resource", "4", "2", "other",
    "own", "4", "other2", "borrow", "4", "some", "own", "4", "[constructor]f", "",
    "unknown", "constructor", "plain", "false", "resource", "5", "0", "some", "result",
    "some", "own", "5", "none", "[constructor]g", "", "unknown", "constructor", "plain",
    "false", "resource", "6", "0", "some", "result", "some", "own", "6", "some",
    "scalar", "string", "[method]d.a", "", "unknown", "method", "plain", "false",
    "resource", "3", "1", "self", "borrow", "3", "none", "[method]e.method", "",
    "unknown", "method", "plain", "false", "resource", "4", "3", "self", "borrow",
    "4", "thing", "own", "4", "thing2", "borrow", "4", "none", "[static]d.b", "",
    "unknown", "static", "plain", "false", "resource", "3", "0", "none", "interface",
    "foo:bar/i", "", "unknown", "4", "a", "", "unknown", "resource", "7", "t1", "",
    "unknown", "resource", "7", "t2", "", "unknown", "borrow", "7", "t3", "", "unknown",
    "borrow", "7", "0", "worlds", "1", "world", "foo:bar/w", "", "unknown", "imports",
    "4", "[constructor]c", "false", "function", "[constructor]c", "", "unknown",
    "constructor", "plain", "false", "resource", "8", "0", "some", "own", "8", "a",
    "false", "type", "", "unknown", "resource", "9", "b", "false", "type", "", "unknown",
    "resource", "10", "c", "false", "type", "", "unknown", "resource", "8", "exports",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic resources1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "resources1.wit", "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: borrow<r1>);\n  t2: func(a: own<r1>);\n  t3: func(a: r1);\n\n  resource r1 {\n    f1: func();\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:resources1", "interfaces", "1", "interface", "foo:resources1/resources1",
    "", "unknown", "1", "r1", "", "unknown", "resource", "0", "4", "[method]r1.f1",
    "", "unknown", "method", "plain", "false", "resource", "0", "1", "self", "borrow",
    "0", "none", "t1", "", "unknown", "freestanding", "plain", "false", "1", "a",
    "borrow", "0", "none", "t2", "", "unknown", "freestanding", "plain", "false",
    "1", "a", "own", "0", "none", "t3", "", "unknown", "freestanding", "plain", "false",
    "1", "a", "own", "0", "none", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic same-name-import-export.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "same-name-import-export.wit", "package demo:greeter;\n\nworld greeter {\n    import greet: func() -> string;\n    export greet: func() -> string;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "demo:greeter", "interfaces", "0", "worlds", "1", "world", "demo:greeter/greeter",
    "", "unknown", "imports", "1", "greet", "false", "function", "greet", "", "unknown",
    "freestanding", "plain", "false", "0", "some", "scalar", "string", "exports",
    "1", "greet", "false", "function", "greet", "", "unknown", "freestanding", "plain",
    "false", "0", "some", "scalar", "string",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic shared-types.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "shared-types.wit", "package foo:shared-items;\n\nworld foo {\n  import foo: interface {\n    a: func() -> list<u8>;\n  }\n  export bar: interface {\n    a: func() -> tuple<list<u8>>;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:shared-items", "interfaces", "0", "worlds", "1", "world",
    "foo:shared-items/foo", "", "unknown", "imports", "1", "foo", "false", "interface",
    "", "unknown", "interface", "", "", "unknown", "0", "1", "a", "", "unknown",
    "freestanding", "plain", "false", "0", "some", "list", "scalar", "u8", "exports",
    "1", "bar", "false", "interface", "", "unknown", "interface", "", "", "unknown",
    "0", "1", "a", "", "unknown", "freestanding", "plain", "false", "0", "some",
    "tuple", "1", "list", "scalar", "u8",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic simple-wasm-text.wat" {
  let result = corpus_resolve(
    Encoded(
      @verifier.decode_wat_package(
        "(component\n  (type $x (component\n    (export \"a:b/x\" (instance))\n  ))\n  (export \"x\" (type $x))\n)\n",
        source_id="simple-wasm-text.wat",
      ).unwrap(),
    ),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "a:b", "interfaces", "1", "interface", "a:b/x", "", "unknown",
    "0", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic since-and-unstable.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "since-and-unstable.wit", "package a:b@1.0.1;\n\n@since(version = 1.0.0)\ninterface foo1 {}\n\n@since(version = 1.0.0)\ninterface foo2 {}\n\n@since(version = 1.0.0)\ninterface foo3 {}\n\n@unstable(feature = foo2)\ninterface foo4 {}\n\n@since(version = 1.0.1)\nworld w1 {}\n\n@since(version = 1.0.0)\nworld w2 {}\n\ninterface in-an-interface {\n  @since(version = 1.0.0)\n  foo: func();\n  @since(version = 1.0.0)\n  resource r1;\n  @since(version = 1.0.0)\n  resource r2 {}\n\n  @since(version = 1.0.0)\n  type t1 = u32;\n  @since(version = 1.0.0)\n  record t2 { a: u32 }\n  @since(version = 1.0.0)\n  enum t3 { a }\n  @since(version = 1.0.0)\n  flags t4 { a }\n  @since(version = 1.0.0)\n  variant t5 { a }\n\n  @since(version = 1.0.0)\n  resource r3 {\n    @since(version = 1.0.0)\n    constructor();\n\n    @since(version = 1.0.0)\n    x1: static func();\n\n    @since(version = 1.0.0)\n    x2: func();\n  }\n}\n\ninterface z {}\n\nworld in-a-world {\n  @since(version = 1.0.0)\n  import x: func();\n  @since(version = 1.0.0)\n  export x: func();\n\n  @since(version = 1.0.0)\n  import y: interface {}\n  @since(version = 1.0.0)\n  export y: interface {}\n\n  @since(version = 1.0.0)\n  import z;\n  @since(version = 1.0.0)\n  export z;\n\n\n  @since(version = 1.0.0)\n  record t1 { x: u32 }\n  @since(version = 1.0.0)\n  enum t2 { a }\n  @since(version = 1.0.0)\n  variant t3 { a }\n  @since(version = 1.0.0)\n  flags t4 { a }\n  @since(version = 1.0.0)\n  type t5 = u32;\n  @since(version = 1.0.0)\n  resource t6;\n  @since(version = 1.0.0)\n  resource t7 {\n    @since(version = 1.0.0)\n    constructor();\n  }\n}\n\ninterface deprecated1 {\n  @since(version = 1.0.0)\n  @deprecated(version = 1.0.1)\n  type t1 = u32;\n\n  @deprecated(version = 1.0.1)\n  @since(version = 1.0.0)\n  type t2 = u32;\n\n  @unstable(feature = foo)\n  @deprecated(version = 1.0.1)\n  type t3 = u32;\n\n  @deprecated(version = 1.0.1)\n  @unstable(feature = foo)\n  type t4 = u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "a:b@1.0.1", "interfaces", "6", "interface", "a:b/deprecated1@1.0.1",
    "", "unknown", "2", "t1", "", "stable", "1.0.0", "1.0.1", "scalar", "u32", "t2",
    "", "stable", "1.0.0", "1.0.1", "scalar", "u32", "0", "interface", "a:b/foo1@1.0.1",
    "", "stable", "1.0.0", "", "0", "0", "interface", "a:b/foo2@1.0.1", "", "stable",
    "1.0.0", "", "0", "0", "interface", "a:b/foo3@1.0.1", "", "stable", "1.0.0",
    "", "0", "0", "interface", "a:b/in-an-interface@1.0.1", "", "unknown", "8", "r1",
    "", "stable", "1.0.0", "", "resource", "0", "r2", "", "stable", "1.0.0", "",
    "resource", "1", "r3", "", "stable", "1.0.0", "", "resource", "2", "t1", "",
    "stable", "1.0.0", "", "scalar", "u32", "t2", "", "stable", "1.0.0", "", "record",
    "1", "a", "scalar", "u32", "t3", "", "stable", "1.0.0", "", "enum", "1", "a",
    "t4", "", "stable", "1.0.0", "", "flags", "1", "a", "t5", "", "stable", "1.0.0",
    "", "variant", "1", "a", "none", "4", "[constructor]r3", "", "stable", "1.0.0",
    "", "constructor", "plain", "false", "resource", "2", "0", "some", "own", "2",
    "[method]r3.x2", "", "stable", "1.0.0", "", "method", "plain", "false", "resource",
    "2", "1", "self", "borrow", "2", "none", "[static]r3.x1", "", "stable", "1.0.0",
    "", "static", "plain", "false", "resource", "2", "0", "none", "foo", "", "stable",
    "1.0.0", "", "freestanding", "plain", "false", "0", "none", "interface", "a:b/z@1.0.1",
    "", "unknown", "0", "0", "worlds", "3", "world", "a:b/in-a-world@1.0.1", "",
    "unknown", "imports", "11", "[constructor]t7", "false", "function", "[constructor]t7",
    "", "stable", "1.0.0", "", "constructor", "plain", "false", "resource", "3",
    "0", "some", "own", "3", "a:b/z@1.0.1", "true", "interface", "", "stable", "1.0.0",
    "", "interface", "a:b/z@1.0.1", "", "unknown", "0", "0", "t1", "false", "type",
    "", "stable", "1.0.0", "", "record", "1", "x", "scalar", "u32", "t2", "false",
    "type", "", "stable", "1.0.0", "", "enum", "1", "a", "t3", "false", "type", "",
    "stable", "1.0.0", "", "variant", "1", "a", "none", "t4", "false", "type", "",
    "stable", "1.0.0", "", "flags", "1", "a", "t5", "false", "type", "", "stable",
    "1.0.0", "", "scalar", "u32", "t6", "false", "type", "", "stable", "1.0.0", "",
    "resource", "4", "t7", "false", "type", "", "stable", "1.0.0", "", "resource",
    "3", "x", "false", "function", "x", "", "stable", "1.0.0", "", "freestanding",
    "plain", "false", "0", "none", "y", "false", "interface", "", "stable", "1.0.0",
    "", "interface", "", "", "stable", "1.0.0", "", "0", "0", "exports", "3", "a:b/z@1.0.1",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "a:b/z@1.0.1", "",
    "unknown", "0", "0", "x", "false", "function", "x", "", "stable", "1.0.0", "",
    "freestanding", "plain", "false", "0", "none", "y", "false", "interface", "",
    "stable", "1.0.0", "", "interface", "", "", "stable", "1.0.0", "", "0", "0",
    "world", "a:b/w1@1.0.1", "", "stable", "1.0.1", "", "imports", "0", "exports",
    "0", "world", "a:b/w2@1.0.1", "", "stable", "1.0.0", "", "imports", "0", "exports",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic streams-and-futures.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "streams-and-futures.wit", "package foo:streams-and-futures;\n\ninterface streams-and-futures {\n  type t1 = stream<u8>;\n  type t2 = stream<stream<string>>;\n  type t3 = future;\n  type t4 = future<list<u8>>;\n  type t5 = option<stream<future>>;\n  resource r1;\n  type t6 = stream<r1>;\n  type t7 = future<result<r1>>;\n  type t8 = stream;\n\n  foo: func(x: stream<u32>, y: t6) -> future<result<list<string>, string>>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:streams-and-futures", "interfaces", "1", "interface", "foo:streams-and-futures/streams-and-futures",
    "", "unknown", "9", "r1", "", "unknown", "resource", "0", "t1", "", "unknown",
    "stream", "some", "scalar", "u8", "t2", "", "unknown", "stream", "some", "stream",
    "some", "scalar", "string", "t3", "", "unknown", "future", "none", "t4", "",
    "unknown", "future", "some", "list", "scalar", "u8", "t5", "", "unknown", "option",
    "stream", "some", "future", "none", "t6", "", "unknown", "stream", "some", "own",
    "0", "t7", "", "unknown", "future", "some", "result", "some", "own", "0", "none",
    "t8", "", "unknown", "stream", "none", "1", "foo", "", "unknown", "freestanding",
    "plain", "false", "2", "x", "stream", "some", "scalar", "u32", "y", "stream",
    "some", "own", "0", "some", "future", "some", "result", "some", "list", "scalar",
    "string", "some", "scalar", "string", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic stress-export-elaborate.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "stress-export-elaborate.wit", "package foo:bar;\n\ninterface i1 {\n  type t1 = u32;\n  type t2 = u32;\n  type t3 = u32;\n  type t4 = u32;\n  type t5 = u32;\n  type t6 = u32;\n  type t7 = u32;\n  type t8 = u32;\n  type t9 = u32;\n  type t10 = u32;\n}\n\ninterface i2 {\n  use i1.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i3 {\n  use i2.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i4 {\n  use i3.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i5 {\n  use i4.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i6 {\n  use i5.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i7 {\n  use i6.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i8 {\n  use i7.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i9 {\n  use i8.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\ninterface i10 {\n  use i9.{t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};\n}\n\nworld foo {\n  export i10;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar", "interfaces", "10", "interface", "foo:bar/i1", "",
    "unknown", "10", "t1", "", "unknown", "scalar", "u32", "t10", "", "unknown",
    "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar",
    "u32", "t4", "", "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32",
    "t6", "", "unknown", "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8",
    "", "unknown", "scalar", "u32", "t9", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:bar/i10", "", "unknown", "10", "t1", "", "unknown", "scalar", "u32", "t10",
    "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "t3", "",
    "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32", "t5", "", "unknown",
    "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7", "", "unknown", "scalar",
    "u32", "t8", "", "unknown", "scalar", "u32", "t9", "", "unknown", "scalar", "u32",
    "0", "interface", "foo:bar/i2", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "interface", "foo:bar/i3", "", "unknown", "10",
    "t1", "", "unknown", "scalar", "u32", "t10", "", "unknown", "scalar", "u32",
    "t2", "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar", "u32", "t4",
    "", "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32", "t6", "",
    "unknown", "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8", "", "unknown",
    "scalar", "u32", "t9", "", "unknown", "scalar", "u32", "0", "interface", "foo:bar/i4",
    "", "unknown", "10", "t1", "", "unknown", "scalar", "u32", "t10", "", "unknown",
    "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar",
    "u32", "t4", "", "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32",
    "t6", "", "unknown", "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8",
    "", "unknown", "scalar", "u32", "t9", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:bar/i5", "", "unknown", "10", "t1", "", "unknown", "scalar", "u32", "t10",
    "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "t3", "",
    "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32", "t5", "", "unknown",
    "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7", "", "unknown", "scalar",
    "u32", "t8", "", "unknown", "scalar", "u32", "t9", "", "unknown", "scalar", "u32",
    "0", "interface", "foo:bar/i6", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "interface", "foo:bar/i7", "", "unknown", "10",
    "t1", "", "unknown", "scalar", "u32", "t10", "", "unknown", "scalar", "u32",
    "t2", "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar", "u32", "t4",
    "", "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32", "t6", "",
    "unknown", "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8", "", "unknown",
    "scalar", "u32", "t9", "", "unknown", "scalar", "u32", "0", "interface", "foo:bar/i8",
    "", "unknown", "10", "t1", "", "unknown", "scalar", "u32", "t10", "", "unknown",
    "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar",
    "u32", "t4", "", "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32",
    "t6", "", "unknown", "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8",
    "", "unknown", "scalar", "u32", "t9", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:bar/i9", "", "unknown", "10", "t1", "", "unknown", "scalar", "u32", "t10",
    "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "t3", "",
    "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32", "t5", "", "unknown",
    "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7", "", "unknown", "scalar",
    "u32", "t8", "", "unknown", "scalar", "u32", "t9", "", "unknown", "scalar", "u32",
    "0", "worlds", "1", "world", "foo:bar/foo", "", "unknown", "imports", "9", "foo:bar/i1",
    "true", "interface", "", "unknown", "interface", "foo:bar/i1", "", "unknown",
    "10", "t1", "", "unknown", "scalar", "u32", "t10", "", "unknown", "scalar", "u32",
    "t2", "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar", "u32", "t4",
    "", "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32", "t6", "",
    "unknown", "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8", "", "unknown",
    "scalar", "u32", "t9", "", "unknown", "scalar", "u32", "0", "foo:bar/i2", "true",
    "interface", "", "unknown", "interface", "foo:bar/i2", "", "unknown", "10", "t1",
    "", "unknown", "scalar", "u32", "t10", "", "unknown", "scalar", "u32", "t2",
    "", "unknown", "scalar", "u32", "t3", "", "unknown", "scalar", "u32", "t4", "",
    "unknown", "scalar", "u32", "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown",
    "scalar", "u32", "t7", "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar",
    "u32", "t9", "", "unknown", "scalar", "u32", "0", "foo:bar/i3", "true", "interface",
    "", "unknown", "interface", "foo:bar/i3", "", "unknown", "10", "t1", "", "unknown",
    "scalar", "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown",
    "scalar", "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar",
    "u32", "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32",
    "t7", "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9",
    "", "unknown", "scalar", "u32", "0", "foo:bar/i4", "true", "interface", "", "unknown",
    "interface", "foo:bar/i4", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "foo:bar/i5", "true", "interface", "", "unknown",
    "interface", "foo:bar/i5", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "foo:bar/i6", "true", "interface", "", "unknown",
    "interface", "foo:bar/i6", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "foo:bar/i7", "true", "interface", "", "unknown",
    "interface", "foo:bar/i7", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "foo:bar/i8", "true", "interface", "", "unknown",
    "interface", "foo:bar/i8", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "foo:bar/i9", "true", "interface", "", "unknown",
    "interface", "foo:bar/i9", "", "unknown", "10", "t1", "", "unknown", "scalar",
    "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar", "u32",
    "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32", "t7",
    "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9", "",
    "unknown", "scalar", "u32", "0", "exports", "1", "foo:bar/i10", "true", "interface",
    "", "unknown", "interface", "foo:bar/i10", "", "unknown", "10", "t1", "", "unknown",
    "scalar", "u32", "t10", "", "unknown", "scalar", "u32", "t2", "", "unknown",
    "scalar", "u32", "t3", "", "unknown", "scalar", "u32", "t4", "", "unknown", "scalar",
    "u32", "t5", "", "unknown", "scalar", "u32", "t6", "", "unknown", "scalar", "u32",
    "t7", "", "unknown", "scalar", "u32", "t8", "", "unknown", "scalar", "u32", "t9",
    "", "unknown", "scalar", "u32", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic type-then-eof.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "type-then-eof.wit", "package foo:foo;\n\ninterface foo {\n  foo: func() -> string;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/foo", "",
    "unknown", "0", "1", "foo", "", "unknown", "freestanding", "plain", "false",
    "0", "some", "scalar", "string", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic types.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "types.wit", "package foo:types;\n\ninterface types {\n  type t1 = u8;\n  type t2 = u16;\n  type t3 = u32;\n  type t4 = u64;\n  type t5 = s8;\n  type t6 = s16;\n  type t7 = s32;\n  type t8 = s64;\n  type t9a = f32;\n  type t9b = f32;\n  type t10a = f64;\n  type t10b = f64;\n  type t11 = char;\n  type t12 = list<char>;\n  type t13 = string;\n  type t14 = option<u32>;\n  type t15 = result<u32, u32>;\n  type t16 = result<_, u32>;\n  type t17 = result<u32>;\n  type t18 = result;\n  record t19 { a: u32 }\n  record t20 { a: u32, }\n  record t21 { a: u32, b: u64 }\n  record t22 { a: u32, b: u64, }\n  record t23 { x: u32 }\n  record %record { a: u32 }\n  type t25 = tuple<u32>;\n  type t26 = tuple<u32,>;\n  type t27 = tuple<u32, u64>;\n  flags t28 { a, b, c }\n  flags t29 { a, b, c, }\n  variant t30 { a }\n  variant t31 { a, b }\n  variant t32 { a, b, }\n  variant t33 { a, b(u32), }\n  variant t34 { a, b(option<u32>), }\n  enum t35 { a, b, c }\n  enum t36 { a, b, c, }\n  type t37 = bool;\n  type t38 = string;\n  type t39 = list<list<list<t32>>>;\n  type t40 = t44;\n  type t41 = %t44;\n  type t42 = stream<u32>;\n  type t43 = future<u32>;\n  type t44 = future;\n  type t45a = list<u32, 4>;\n  type t45b = list<list<u32, 4>, 2>;\n\n  /// type order doesn't matter\n  type foo = bar;\n  type bar = u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:types", "interfaces", "1", "interface", "foo:types/types",
    "", "unknown", "50", "bar", "", "unknown", "scalar", "u32", "foo", "", "unknown",
    "scalar", "u32", "record", "", "unknown", "record", "1", "a", "scalar", "u32",
    "t1", "", "unknown", "scalar", "u8", "t10a", "", "unknown", "scalar", "f64",
    "t10b", "", "unknown", "scalar", "f64", "t11", "", "unknown", "scalar", "char",
    "t12", "", "unknown", "list", "scalar", "char", "t13", "", "unknown", "scalar",
    "string", "t14", "", "unknown", "option", "scalar", "u32", "t15", "", "unknown",
    "result", "some", "scalar", "u32", "some", "scalar", "u32", "t16", "", "unknown",
    "result", "none", "some", "scalar", "u32", "t17", "", "unknown", "result", "some",
    "scalar", "u32", "none", "t18", "", "unknown", "result", "none", "none", "t19",
    "", "unknown", "record", "1", "a", "scalar", "u32", "t2", "", "unknown", "scalar",
    "u16", "t20", "", "unknown", "record", "1", "a", "scalar", "u32", "t21", "",
    "unknown", "record", "2", "a", "scalar", "u32", "b", "scalar", "u64", "t22",
    "", "unknown", "record", "2", "a", "scalar", "u32", "b", "scalar", "u64", "t23",
    "", "unknown", "record", "1", "x", "scalar", "u32", "t25", "", "unknown", "tuple",
    "1", "scalar", "u32", "t26", "", "unknown", "tuple", "1", "scalar", "u32", "t27",
    "", "unknown", "tuple", "2", "scalar", "u32", "scalar", "u64", "t28", "", "unknown",
    "flags", "3", "a", "b", "c", "t29", "", "unknown", "flags", "3", "a", "b", "c",
    "t3", "", "unknown", "scalar", "u32", "t30", "", "unknown", "variant", "1", "a",
    "none", "t31", "", "unknown", "variant", "2", "a", "none", "b", "none", "t32",
    "", "unknown", "variant", "2", "a", "none", "b", "none", "t33", "", "unknown",
    "variant", "2", "a", "none", "b", "some", "scalar", "u32", "t34", "", "unknown",
    "variant", "2", "a", "none", "b", "some", "option", "scalar", "u32", "t35", "",
    "unknown", "enum", "3", "a", "b", "c", "t36", "", "unknown", "enum", "3", "a",
    "b", "c", "t37", "", "unknown", "scalar", "bool", "t38", "", "unknown", "scalar",
    "string", "t39", "", "unknown", "list", "list", "list", "variant", "2", "a",
    "none", "b", "none", "t4", "", "unknown", "scalar", "u64", "t40", "", "unknown",
    "future", "none", "t41", "", "unknown", "future", "none", "t42", "", "unknown",
    "stream", "some", "scalar", "u32", "t43", "", "unknown", "future", "some", "scalar",
    "u32", "t44", "", "unknown", "future", "none", "t45a", "", "unknown", "fixed-list",
    "4", "scalar", "u32", "t45b", "", "unknown", "fixed-list", "2", "fixed-list",
    "4", "scalar", "u32", "t5", "", "unknown", "scalar", "s8", "t6", "", "unknown",
    "scalar", "s16", "t7", "", "unknown", "scalar", "s32", "t8", "", "unknown", "scalar",
    "s64", "t9a", "", "unknown", "scalar", "f32", "t9b", "", "unknown", "scalar",
    "f32", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic union-fuzz-1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "union-fuzz-1.wit", "package foo:bar;\n\nworld xo {}\n\nworld name {}\n\nworld x {\n    include name;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar", "interfaces", "0", "worlds", "3", "world", "foo:bar/name",
    "", "unknown", "imports", "0", "exports", "0", "world", "foo:bar/x", "", "unknown",
    "imports", "0", "exports", "0", "world", "foo:bar/xo", "", "unknown", "imports",
    "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic union-fuzz-2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "union-fuzz-2.wit", "package foo:bar;\n\nworld foo {\n    export foo: func() -> f32;\n}\n\n\nworld bar {\n    include foo;\n\n    record foo {\n        a: u32,\n    }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:bar", "interfaces", "0", "worlds", "2", "world", "foo:bar/bar",
    "", "unknown", "imports", "1", "foo", "false", "type", "", "unknown", "record",
    "1", "a", "scalar", "u32", "exports", "1", "foo", "false", "function", "foo",
    "", "unknown", "freestanding", "plain", "false", "0", "some", "scalar", "f32",
    "world", "foo:bar/foo", "", "unknown", "imports", "0", "exports", "1", "foo",
    "false", "function", "foo", "", "unknown", "freestanding", "plain", "false",
    "0", "some", "scalar", "f32",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic unstable-resource.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "unstable-resource.wit", "package a:b@0.1.0;\n\ninterface foo {\n  @unstable(feature = inactive)\n  use wasi:io/error@0.1.0.{error};\n\n  @unstable(feature = inactive)\n  x: func(y: borrow<error>);\n}\n\npackage wasi:io@0.1.0 {\n  interface error {\n    resource error;\n  }\n}\n\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "2", "a:b@0.1.0", "wasi:io@0.1.0", "interfaces", "2", "interface",
    "a:b/foo@0.1.0", "", "unknown", "0", "0", "interface", "wasi:io/error@0.1.0",
    "", "unknown", "1", "error", "", "unknown", "resource", "0", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic use-chain.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "use-chain.wit", "package foo:name;\n\ninterface foo {\n  record foo {\n    a: u32,\n  }\n}\n\nuse foo as bar;\n\ninterface name {\n  use bar.{foo};\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:name", "interfaces", "2", "interface", "foo:name/foo",
    "", "unknown", "1", "foo", "", "unknown", "record", "1", "a", "scalar", "u32",
    "0", "interface", "foo:name/name", "", "unknown", "1", "foo", "", "unknown",
    "record", "1", "a", "scalar", "u32", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic use.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "use.wit", "package foo:foo;\n\ninterface foo {\n  use bar.{the-type};\n}\n\ninterface bar {\n  type the-type = u32;\n}\n\ninterface baz {\n  use foo.{the-type};\n  use bar.{the-type as test};\n}\n\ninterface empty {\n}\n\ninterface use-from-empty {\n  use empty.{};\n  use empty.{};\n}\n\ninterface use-multiple {\n  use baz.{the-type, test};\n\n  some-function: func(x: the-type) -> test;\n}\n\ninterface trailing-comma {\n  use foo.{the-type,};\n\n  record the-foo { a: the-type }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "7", "interface", "foo:foo/bar", "",
    "unknown", "1", "the-type", "", "unknown", "scalar", "u32", "0", "interface",
    "foo:foo/baz", "", "unknown", "2", "test", "", "unknown", "scalar", "u32", "the-type",
    "", "unknown", "scalar", "u32", "0", "interface", "foo:foo/empty", "", "unknown",
    "0", "0", "interface", "foo:foo/foo", "", "unknown", "1", "the-type", "", "unknown",
    "scalar", "u32", "0", "interface", "foo:foo/trailing-comma", "", "unknown", "2",
    "the-foo", "", "unknown", "record", "1", "a", "scalar", "u32", "the-type", "",
    "unknown", "scalar", "u32", "0", "interface", "foo:foo/use-from-empty", "", "unknown",
    "0", "0", "interface", "foo:foo/use-multiple", "", "unknown", "2", "test", "",
    "unknown", "scalar", "u32", "the-type", "", "unknown", "scalar", "u32", "1",
    "some-function", "", "unknown", "freestanding", "plain", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "u32", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic version-syntax.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "version-syntax.wit", "package foo:root;\npackage a:b@1.0.0 {}\npackage a:b@1.0.1 {}\npackage a:b@1.0.1-- {}\npackage a:b@1.0.1-a+a {}\npackage a:b@1.0.1-1+1 {}\npackage a:b@1.0.1-1a+1a {}\npackage a:b@1.0.0-11-a {}\npackage a:b@1.0.0-a1.1-a {}\npackage a:b@1.0.0-11ab {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "10", "a:b@1.0.0", "a:b@1.0.0-11-a", "a:b@1.0.0-11ab", "a:b@1.0.0-a1.1-a",
    "a:b@1.0.1", "a:b@1.0.1--", "a:b@1.0.1-1+1", "a:b@1.0.1-1a+1a", "a:b@1.0.1-a+a",
    "foo:root", "interfaces", "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic versions" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "versions/foo.wit", "package foo:versions;\n\ninterface foo {\n  use a:a/foo@1.0.0.{t};\n  use a:a/foo@2.0.0.{t as t2};\n}\n\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "versions/deps/a1/foo.wit", "package a:a@1.0.0;\n\ninterface foo {\n  type t = u32;\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "versions/deps/a2/foo.wit", "package a:a@2.0.0;\n\ninterface foo {\n  type t = u32;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "3", "a:a@1.0.0", "a:a@2.0.0", "foo:versions", "interfaces", "3",
    "interface", "a:a/foo@1.0.0", "", "unknown", "1", "t", "", "unknown", "scalar",
    "u32", "0", "interface", "a:a/foo@2.0.0", "", "unknown", "1", "t", "", "unknown",
    "scalar", "u32", "0", "interface", "foo:versions/foo", "", "unknown", "2", "t",
    "", "unknown", "scalar", "u32", "t2", "", "unknown", "scalar", "u32", "0", "worlds",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic wasi.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "wasi.wit",
          "package wasi:filesystem;\n\ninterface wasi {\n  enum clockid {\n    /// The clock measuring real time. Time value zero corresponds with\n    /// 1970-01-01T00:00:00Z.\n    realtime,\n    /// The store-wide monotonic clock, which is defined as a clock measuring\n    /// real time, whose value cannot be adjusted and which cannot have negative\n    /// clock jumps. The epoch of this clock is undefined. The absolute time\n    /// value of this clock therefore has no meaning.\n    monotonic,\n  }\n\n  /// Timestamp in nanoseconds.\n  type timestamp = u64;\n\n  /// Error codes returned by functions.\n  /// Not all of these error codes are returned by the functions provided by this\n  /// API/ some are used in higher-level library layers, and others are provided\n  /// merely for alignment with POSIX.\n  enum errno {\n    /// No error occurred. System call completed successfully.\n    success,\n    /// Argument list too long.\n    toobig,\n    /// Permission denied.\n    access,\n    /// Address in use.\n    addrinuse,\n    /// Address not available.\n    addrnotavail,\n    /// Address family not supported.\n    afnosupport,\n    /// Resource unavailable, or operation would block.\n    again,\n    /// Connection already in progress.\n    already,\n    /// Bad file descriptor.\n    badf,\n    /// Bad message.\n    badmsg,\n    /// Device or resource busy.\n    busy,\n    /// Operation canceled.\n    canceled,\n    /// No child processes.\n    child,\n    /// Connection aborted.\n    connaborted,\n    /// Connection refused.\n    connrefused,\n    /// Connection reset.\n    connreset,\n    /// Resource deadlock would occur.\n    deadlk,\n    /// Destination address required.\n    destaddrreq,\n    /// Mathematics argument out of domain of function.\n    dom,\n    /// Reserved.\n    dquot,\n    /// File exists.\n    exist,\n    /// Bad address.\n    fault,\n    /// File too large.\n    fbig,\n    /// Host is unreachable.\n    hostunreach,\n    /// Identifier removed.\n    idrm,\n    /// Illegal byte sequence.\n    ilseq,\n    /// Operation in progress.\n    inprogress,\n    /// Interrupted function.\n    intr,\n    /// Invalid argument.\n    inval,\n    /// I/O error.\n    io,\n    /// Socket is connected.\n    isconn,\n    /// Is a directory.\n    isdir,\n    /// Too many levels of symbolic links.\n    loop,\n    /// File descriptor value too large.\n    mfile,\n    /// Too many links.\n    mlink,\n    /// Message too large.\n    msgsize,\n    /// Reserved.\n    multihop,\n    /// Filename too long.\n    nametoolong,\n    /// Network is down.\n    netdown,\n    /// Connection aborted by network.\n    netreset,\n    /// Network unreachable.\n    netunreach,\n    /// Too many files open in system.\n    nfile,\n    /// No buffer space available.\n    nobufs,\n    /// No such device.\n    nodev,\n    /// No such file or directory.\n    noent,\n    /// Executable file format error.\n    noexec,\n    /// No locks available.\n    nolck,\n    /// Reserved.\n    nolink,\n    /// Not enough space.\n    nomem,\n    /// No message of the desired type.\n    nomsg,\n    /// Protocol not available.\n    noprotoopt,\n    /// No space left on device.\n    nospc,\n    /// Function not supported.\n    nosys,\n    /// The socket is not connected.\n    notconn,\n    /// Not a directory or a symbolic link to a directory.\n    notdir,\n    /// Directory not empty.\n    notempty,\n    /// State not recoverable.\n    notrecoverable,\n    /// Not a socket.\n    notsock,\n    /// Not supported, or operation not supported on socket.\n    notsup,\n    /// Inappropriate I/O control operation.\n    notty,\n    /// No such device or address.\n    nxio,\n    /// Value too large to be stored in data type.\n    overflow,\n    /// Previous owner died.\n    ownerdead,\n    /// Operation not permitted.\n    perm,\n    /// Broken pipe.\n    pipe,\n    /// Protocol error.\n    proto,\n    /// Protocol not supported.\n    protonosupport,\n    /// Protocol wrong type for socket.\n    prototype,\n    /// Result too large.\n    range,\n    /// Read-only file system.\n    rofs,\n    /// Invalid seek.\n    spipe,\n    /// No such process.\n  " +
          "  srch,\n    /// Reserved.\n    stale,\n    /// Connection timed out.\n    timedout,\n    /// Text file busy.\n    txtbsy,\n    /// Cross-device link.\n    xdev,\n    /// Extension: Capabilities insufficient.\n    notcapable,\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "wasi:filesystem", "interfaces", "1", "interface", "wasi:filesystem/wasi",
    "", "unknown", "3", "clockid", "", "unknown", "enum", "2", "realtime", "monotonic",
    "errno", "", "unknown", "enum", "77", "success", "toobig", "access", "addrinuse",
    "addrnotavail", "afnosupport", "again", "already", "badf", "badmsg", "busy",
    "canceled", "child", "connaborted", "connrefused", "connreset", "deadlk", "destaddrreq",
    "dom", "dquot", "exist", "fault", "fbig", "hostunreach", "idrm", "ilseq", "inprogress",
    "intr", "inval", "io", "isconn", "isdir", "loop", "mfile", "mlink", "msgsize",
    "multihop", "nametoolong", "netdown", "netreset", "netunreach", "nfile", "nobufs",
    "nodev", "noent", "noexec", "nolck", "nolink", "nomem", "nomsg", "noprotoopt",
    "nospc", "nosys", "notconn", "notdir", "notempty", "notrecoverable", "notsock",
    "notsup", "notty", "nxio", "overflow", "ownerdead", "perm", "pipe", "proto",
    "protonosupport", "prototype", "range", "rofs", "spipe", "srch", "stale", "timedout",
    "txtbsy", "xdev", "notcapable", "timestamp", "", "unknown", "scalar", "u64",
    "0", "worlds", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic with-resource-as.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "with-resource-as.wit", "package foo:foo;\n\nworld a {\n  resource r {\n    constructor();\n    m: func();\n    sm: static func();\n  }\n  import f: func(x: r) -> option<r>;\n  export g: func(x: r) -> option<r>;\n}\n\nworld b {\n  include a with { r as s }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "2", "world", "foo:foo/a",
    "", "unknown", "imports", "5", "[constructor]r", "false", "function", "[constructor]r",
    "", "unknown", "constructor", "plain", "false", "resource", "0", "0", "some",
    "own", "0", "[method]r.m", "false", "function", "[method]r.m", "", "unknown",
    "method", "plain", "false", "resource", "0", "1", "self", "borrow", "0", "none",
    "[static]r.sm", "false", "function", "[static]r.sm", "", "unknown", "static",
    "plain", "false", "resource", "0", "0", "none", "f", "false", "function", "f",
    "", "unknown", "freestanding", "plain", "false", "1", "x", "own", "0", "some",
    "option", "own", "0", "r", "false", "type", "", "unknown", "resource", "0", "exports",
    "1", "g", "false", "function", "g", "", "unknown", "freestanding", "plain", "false",
    "1", "x", "own", "0", "some", "option", "own", "0", "world", "foo:foo/b", "",
    "unknown", "imports", "5", "[constructor]s", "false", "function", "[constructor]s",
    "", "unknown", "constructor", "plain", "false", "resource", "1", "0", "some",
    "own", "1", "[method]s.m", "false", "function", "[method]s.m", "", "unknown",
    "method", "plain", "false", "resource", "1", "1", "self", "borrow", "1", "none",
    "[static]s.sm", "false", "function", "[static]s.sm", "", "unknown", "static",
    "plain", "false", "resource", "1", "0", "none", "f", "false", "function", "f",
    "", "unknown", "freestanding", "plain", "false", "1", "x", "own", "1", "some",
    "option", "own", "1", "s", "false", "type", "", "unknown", "resource", "1", "exports",
    "1", "g", "false", "function", "g", "", "unknown", "freestanding", "plain", "false",
    "1", "x", "own", "1", "some", "option", "own", "1",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-diamond.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-diamond.wit", "package foo:foo;\n\ninterface shared-items {\n  type foo = u32;\n}\n\ninterface i1 {\n  use shared-items.{foo};\n\n  a: func() -> foo;\n}\n\ninterface i2 {\n  use shared-items.{foo};\n\n  a: func() -> foo;\n}\n\nworld the-world {\n  import i1;\n  import i2;\n  import a: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "3", "interface", "foo:foo/i1", "",
    "unknown", "1", "foo", "", "unknown", "scalar", "u32", "1", "a", "", "unknown",
    "freestanding", "plain", "false", "0", "some", "scalar", "u32", "interface",
    "foo:foo/i2", "", "unknown", "1", "foo", "", "unknown", "scalar", "u32", "1",
    "a", "", "unknown", "freestanding", "plain", "false", "0", "some", "scalar",
    "u32", "interface", "foo:foo/shared-items", "", "unknown", "1", "foo", "", "unknown",
    "scalar", "u32", "0", "worlds", "1", "world", "foo:foo/the-world", "", "unknown",
    "imports", "4", "a", "false", "function", "a", "", "unknown", "freestanding",
    "plain", "false", "0", "none", "foo:foo/i1", "true", "interface", "", "unknown",
    "interface", "foo:foo/i1", "", "unknown", "1", "foo", "", "unknown", "scalar",
    "u32", "1", "a", "", "unknown", "freestanding", "plain", "false", "0", "some",
    "scalar", "u32", "foo:foo/i2", "true", "interface", "", "unknown", "interface",
    "foo:foo/i2", "", "unknown", "1", "foo", "", "unknown", "scalar", "u32", "1",
    "a", "", "unknown", "freestanding", "plain", "false", "0", "some", "scalar",
    "u32", "foo:foo/shared-items", "true", "interface", "", "unknown", "interface",
    "foo:foo/shared-items", "", "unknown", "1", "foo", "", "unknown", "scalar", "u32",
    "0", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-iface-no-collide.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-iface-no-collide.wit", "package foo:foo;\n\ninterface foo {\n  type t = u32;\n}\n\nworld bar {\n  use foo.{t};\n\n  import foo: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/foo", "",
    "unknown", "1", "t", "", "unknown", "scalar", "u32", "0", "worlds", "1", "world",
    "foo:foo/bar", "", "unknown", "imports", "3", "foo", "false", "function", "foo",
    "", "unknown", "freestanding", "plain", "false", "0", "none", "foo:foo/foo",
    "true", "interface", "", "unknown", "interface", "foo:foo/foo", "", "unknown",
    "1", "t", "", "unknown", "scalar", "u32", "0", "t", "false", "type", "", "unknown",
    "scalar", "u32", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-implicit-import1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-implicit-import1.wit", "package foo:foo;\n\ninterface foo {\n  type a = u32;\n}\n\nworld the-world {\n  import bar: interface {\n    use foo.{a};\n  }\n  import foo: interface {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/foo", "",
    "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "worlds", "1", "world",
    "foo:foo/the-world", "", "unknown", "imports", "3", "bar", "false", "interface",
    "", "unknown", "interface", "", "", "unknown", "1", "a", "", "unknown", "scalar",
    "u32", "0", "foo", "false", "interface", "", "unknown", "interface", "", "",
    "unknown", "0", "0", "foo:foo/foo", "true", "interface", "", "unknown", "interface",
    "foo:foo/foo", "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0",
    "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-implicit-import2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-implicit-import2.wit", "package foo:foo;\n\ninterface foo {\n  type g = char;\n}\n\nworld w {\n  use foo.{g};\n\n  import foo: func() -> g;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/foo", "",
    "unknown", "1", "g", "", "unknown", "scalar", "char", "0", "worlds", "1", "world",
    "foo:foo/w", "", "unknown", "imports", "3", "foo", "false", "function", "foo",
    "", "unknown", "freestanding", "plain", "false", "0", "some", "scalar", "char",
    "foo:foo/foo", "true", "interface", "", "unknown", "interface", "foo:foo/foo",
    "", "unknown", "1", "g", "", "unknown", "scalar", "char", "0", "g", "false",
    "type", "", "unknown", "scalar", "char", "exports", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-implicit-import3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-implicit-import3.wit", "package foo:foo;\n\ninterface foo {\n  type g = char;\n}\n\nworld w {\n  use foo.{g};\n\n  export foo: func() -> g;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/foo", "",
    "unknown", "1", "g", "", "unknown", "scalar", "char", "0", "worlds", "1", "world",
    "foo:foo/w", "", "unknown", "imports", "2", "foo:foo/foo", "true", "interface",
    "", "unknown", "interface", "foo:foo/foo", "", "unknown", "1", "g", "", "unknown",
    "scalar", "char", "0", "g", "false", "type", "", "unknown", "scalar", "char",
    "exports", "1", "foo", "false", "function", "foo", "", "unknown", "freestanding",
    "plain", "false", "0", "some", "scalar", "char",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-same-fields4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-same-fields4.wit", "package foo:foo;\n\ninterface shared-items {\n  type a = u32;\n}\n\nworld foo {\n  import shared-items: interface {}\n  export a-name: interface {\n    use shared-items.{a};\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/shared-items",
    "", "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "worlds", "1",
    "world", "foo:foo/foo", "", "unknown", "imports", "2", "foo:foo/shared-items",
    "true", "interface", "", "unknown", "interface", "foo:foo/shared-items", "",
    "unknown", "1", "a", "", "unknown", "scalar", "u32", "0", "shared-items", "false",
    "interface", "", "unknown", "interface", "", "", "unknown", "0", "0", "exports",
    "1", "a-name", "false", "interface", "", "unknown", "interface", "", "", "unknown",
    "1", "a", "", "unknown", "scalar", "u32", "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-top-level-funcs.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-top-level-funcs.wit", "package foo:foo;\n\nworld foo {\n  import foo: func();\n  export foo2: func();\n\n  import bar: func(arg: list<u32>);\n  export some-name: func() -> list<option<u32>>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "0", "worlds", "1", "world", "foo:foo/foo",
    "", "unknown", "imports", "2", "bar", "false", "function", "bar", "", "unknown",
    "freestanding", "plain", "false", "1", "arg", "list", "scalar", "u32", "none",
    "foo", "false", "function", "foo", "", "unknown", "freestanding", "plain", "false",
    "0", "none", "exports", "2", "foo2", "false", "function", "foo2", "", "unknown",
    "freestanding", "plain", "false", "0", "none", "some-name", "false", "function",
    "some-name", "", "unknown", "freestanding", "plain", "false", "0", "some", "list",
    "option", "scalar", "u32",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic world-top-level-resources.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "world-top-level-resources.wit", "package foo:foo;\n\ninterface types {\n  resource request {\n    foo: func();\n    bar: func(arg: list<u32>);\n  }\n\n  resource response {\n    foo: func();\n    bar: func(arg: list<u32>);\n  }\n}\n\ninterface handler {\n  use types.{request, response};\n  handle: func(some: borrow<request>) -> response;\n  handle-owned: func(some: own<request>) -> own<response>;\n}\n\nworld proxy {\n  import handler;\n  export handler;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "2", "interface", "foo:foo/handler",
    "", "unknown", "2", "request", "", "unknown", "resource", "0", "response", "",
    "unknown", "resource", "1", "2", "handle", "", "unknown", "freestanding", "plain",
    "false", "1", "some", "borrow", "0", "some", "own", "1", "handle-owned", "",
    "unknown", "freestanding", "plain", "false", "1", "some", "own", "0", "some",
    "own", "1", "interface", "foo:foo/types", "", "unknown", "2", "request", "",
    "unknown", "resource", "0", "response", "", "unknown", "resource", "1", "4",
    "[method]request.bar", "", "unknown", "method", "plain", "false", "resource",
    "0", "2", "self", "borrow", "0", "arg", "list", "scalar", "u32", "none", "[method]request.foo",
    "", "unknown", "method", "plain", "false", "resource", "0", "1", "self", "borrow",
    "0", "none", "[method]response.bar", "", "unknown", "method", "plain", "false",
    "resource", "1", "2", "self", "borrow", "1", "arg", "list", "scalar", "u32",
    "none", "[method]response.foo", "", "unknown", "method", "plain", "false", "resource",
    "1", "1", "self", "borrow", "1", "none", "worlds", "1", "world", "foo:foo/proxy",
    "", "unknown", "imports", "2", "foo:foo/handler", "true", "interface", "", "unknown",
    "interface", "foo:foo/handler", "", "unknown", "2", "request", "", "unknown",
    "resource", "0", "response", "", "unknown", "resource", "1", "2", "handle", "",
    "unknown", "freestanding", "plain", "false", "1", "some", "borrow", "0", "some",
    "own", "1", "handle-owned", "", "unknown", "freestanding", "plain", "false",
    "1", "some", "own", "0", "some", "own", "1", "foo:foo/types", "true", "interface",
    "", "unknown", "interface", "foo:foo/types", "", "unknown", "2", "request", "",
    "unknown", "resource", "0", "response", "", "unknown", "resource", "1", "4",
    "[method]request.bar", "", "unknown", "method", "plain", "false", "resource",
    "0", "2", "self", "borrow", "0", "arg", "list", "scalar", "u32", "none", "[method]request.foo",
    "", "unknown", "method", "plain", "false", "resource", "0", "1", "self", "borrow",
    "0", "none", "[method]response.bar", "", "unknown", "method", "plain", "false",
    "resource", "1", "2", "self", "borrow", "1", "arg", "list", "scalar", "u32",
    "none", "[method]response.foo", "", "unknown", "method", "plain", "false", "resource",
    "1", "1", "self", "borrow", "1", "none", "exports", "1", "foo:foo/handler", "true",
    "interface", "", "unknown", "interface", "foo:foo/handler", "", "unknown", "2",
    "request", "", "unknown", "resource", "0", "response", "", "unknown", "resource",
    "1", "2", "handle", "", "unknown", "freestanding", "plain", "false", "1", "some",
    "borrow", "0", "some", "own", "1", "handle-owned", "", "unknown", "freestanding",
    "plain", "false", "1", "some", "own", "0", "some", "own", "1",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic worlds-union-dedup.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "worlds-union-dedup.wit", "package foo:foo;\n\ninterface a1 { }\ninterface a2 { }\ninterface b1 { }\ninterface b2 { }\ninterface c { }\ninterface d { }\n\nworld my-world-a {\n    import a1;\n    import b1;\n}\n\nworld my-world-b {\n    import a1;\n    import b1;\n}\n\nworld union-my-world {\n    include my-world-a;\n    include my-world-b;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "6", "interface", "foo:foo/a1", "",
    "unknown", "0", "0", "interface", "foo:foo/a2", "", "unknown", "0", "0", "interface",
    "foo:foo/b1", "", "unknown", "0", "0", "interface", "foo:foo/b2", "", "unknown",
    "0", "0", "interface", "foo:foo/c", "", "unknown", "0", "0", "interface", "foo:foo/d",
    "", "unknown", "0", "0", "worlds", "3", "world", "foo:foo/my-world-a", "", "unknown",
    "imports", "2", "foo:foo/a1", "true", "interface", "", "unknown", "interface",
    "foo:foo/a1", "", "unknown", "0", "0", "foo:foo/b1", "true", "interface", "",
    "unknown", "interface", "foo:foo/b1", "", "unknown", "0", "0", "exports", "0",
    "world", "foo:foo/my-world-b", "", "unknown", "imports", "2", "foo:foo/a1", "true",
    "interface", "", "unknown", "interface", "foo:foo/a1", "", "unknown", "0", "0",
    "foo:foo/b1", "true", "interface", "", "unknown", "interface", "foo:foo/b1",
    "", "unknown", "0", "0", "exports", "0", "world", "foo:foo/union-my-world", "",
    "unknown", "imports", "2", "foo:foo/a1", "true", "interface", "", "unknown",
    "interface", "foo:foo/a1", "", "unknown", "0", "0", "foo:foo/b1", "true", "interface",
    "", "unknown", "interface", "foo:foo/b1", "", "unknown", "0", "0", "exports",
    "0",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic worlds-with-types.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "worlds-with-types.wit", "package foo:foo;\n\nworld foo {\n  type a = u32;\n  type b = a;\n\n  export c: func(a: a) -> b;\n}\n\n\ninterface disambiguate {\n  type t = u32;\n}\n\nworld bar {\n  import disambiguate;\n\n  use disambiguate.{t};\n\n  export foo: func() -> t;\n}\n\nworld the-test {\n  record a {\n    x: u32,\n  }\n\n  variant b {\n    c(a),\n  }\n\n  import foo: func(a: a) -> b;\n  export bar: func(a: a) -> b;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  let actual = model_projection(result.unwrap())
  let expected : Array[String] = [
    "packages", "1", "foo:foo", "interfaces", "1", "interface", "foo:foo/disambiguate",
    "", "unknown", "1", "t", "", "unknown", "scalar", "u32", "0", "worlds", "3",
    "world", "foo:foo/bar", "", "unknown", "imports", "2", "foo:foo/disambiguate",
    "true", "interface", "", "unknown", "interface", "foo:foo/disambiguate", "",
    "unknown", "1", "t", "", "unknown", "scalar", "u32", "0", "t", "false", "type",
    "", "unknown", "scalar", "u32", "exports", "1", "foo", "false", "function", "foo",
    "", "unknown", "freestanding", "plain", "false", "0", "some", "scalar", "u32",
    "world", "foo:foo/foo", "", "unknown", "imports", "2", "a", "false", "type",
    "", "unknown", "scalar", "u32", "b", "false", "type", "", "unknown", "scalar",
    "u32", "exports", "1", "c", "false", "function", "c", "", "unknown", "freestanding",
    "plain", "false", "1", "a", "scalar", "u32", "some", "scalar", "u32", "world",
    "foo:foo/the-test", "", "unknown", "imports", "3", "a", "false", "type", "",
    "unknown", "record", "1", "x", "scalar", "u32", "b", "false", "type", "", "unknown",
    "variant", "1", "c", "some", "record", "1", "x", "scalar", "u32", "foo", "false",
    "function", "foo", "", "unknown", "freestanding", "plain", "false", "1", "a",
    "record", "1", "x", "scalar", "u32", "some", "variant", "1", "c", "some", "record",
    "1", "x", "scalar", "u32", "exports", "1", "bar", "false", "function", "bar",
    "", "unknown", "freestanding", "plain", "false", "1", "a", "record", "1", "x",
    "scalar", "u32", "some", "variant", "1", "c", "some", "record", "1", "x", "scalar",
    "u32",
  ]
  assert_eq(actual, expected)
}

///|
test "upstream semantic parse-fail/accessor-async.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-async.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: async get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-canonical-case.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-canonical-case.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: func();\n  PROP: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-canonical-hyphens.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-canonical-hyphens.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  max-size: func();\n  maxsize: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-canonical-pair.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-canonical-pair.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  // Getters and setters must have EXACTLY the same name (not just strongly-unique).\n  max-size: get() -> u64;\n  maxsize: set(value: u64);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-canonical-resource.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-canonical-resource.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    max-size: func() -> u64;\n    maxsize: get() -> u64;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-canonical-world.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-canonical-world.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo-bar: func();\n  import foobar: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-duplicate-getter.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-duplicate-getter.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-getter-conflicts-func.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-getter-conflicts-func.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: func();\n  prop: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-getter-no-result.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-getter-no-result.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-getter-params.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-getter-params.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get(x: u32) -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-resource-canonical-static.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-resource-canonical-static.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    foo-bar: get() -> u64;\n    foobar: static func() -> u64;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-resource-conflicts-method.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-resource-conflicts-method.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    position: func() -> u64;\n    position: get() -> u64;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-resource-duplicate-setter.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-resource-duplicate-setter.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    position: get() -> u64;\n    position: set(value: u64);\n    position: static set(value: u64);\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-resource-static-mismatch.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-resource-static-mismatch.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource blob {\n    position: get() -> u64;\n    position: static set(value: u64);\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-setter-bad-result.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-setter-bad-result.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set(value: u32) -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-setter-bad-result2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-setter-bad-result2.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set(value: u32) -> result<u32, string>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-setter-no-getter.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-setter-no-getter.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: set(value: u32);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-setter-no-params.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-setter-no-params.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-setter-two-params.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-setter-two-params.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  prop: get() -> u32;\n  prop: set(a: u32, b: u32);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-type-conflicts-getter.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-type-conflicts-getter.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type prop = u32;\n  prop: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-world-getter-conflicts.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-world-getter-conflicts.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import prop: func();\n  import prop: get() -> u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-world-setter-no-getter.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-world-setter-no-getter.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import prop: get() -> u32;\n  export prop: set(value: u32);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/accessor-world-setter-static-mismatch.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/accessor-world-setter-static-mismatch.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  resource blob {\n    position: static get() -> u64;\n    position: set(value: u64);\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/alias-no-type.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/alias-no-type.wit", "// parse-fail\npackage foo:bar;\n\ninterface foo {\n  type foo = bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/async-bad-world.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/async-bad-world.wit", "package a:b;\n\nworld foo {\n  import x: async func();\n  import x: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/async-bad-world2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/async-bad-world2.wit", "package a:b;\n\nworld foo {\n  import x: async func();\n  import x: interface {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/async-bad-world3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/async-bad-world3.wit", "package a:b;\n\nworld foo {\n  import x: async func();\n  record x {\n    a: u32,\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/async-bad-world4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/async-bad-world4.wit", "package a:b;\n\nworld a {\n  import x: async func();\n}\n\nworld b {\n  include a;\n  import x: func();\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/async-bad1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/async-bad1.wit", "package test:%async;\n\ninterface x {\n  resource z {\n    async constructor();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/async-bad2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/async-bad2.wit", "package test:%async;\n\ninterface x {\n  resource z {\n    x: async static func();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-deprecated1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-deprecated1.wit", "package a:b;\n\n@deprecated\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-deprecated2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-deprecated2.wit", "package a:b;\n\n@deprecated()\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-deprecated3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-deprecated3.wit", "package a:b;\n\n@deprecated(since = 1.2.3)\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-deprecated4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-deprecated4.wit", "package a:b;\n\n@deprecated(since = 1.2.3)\n@deprecated(since = 1.2.3)\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-function.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-function.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  x: func(param: nonexistent);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-function2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-function2.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  x: func() -> nonexistent;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-gate-record-field.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-gate-record-field.wit", "package a:b;\n\ninterface foo {\n  @unstable(feature = inactive)\n  type gated = u32;\n\n  record r {\n    field-a: u32,\n    field-b: gated,\n    field-c: string,\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-gate1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-gate1.wit", "package a:b;\n\ninterface foo {\n  @unstable(feature = not-active)\n  type gated = u32;\n\n  type foo = gated;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-gate2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-gate2.wit", "package a:b;\n\n@unstable(feature = not-active)\nworld a {}\n\nworld b {\n  include a;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-gate3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-gate3.wit", "package a:b;\n\n@unstable(feature = not-active)\ninterface a {\n  type a = u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-gate4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-gate4.wit", "package a:b;\n\ninterface a {\n  @unstable(feature = inactive)\n  resource a {\n    constructor();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-gate5.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-gate5.wit", "package a:b;\n\ninterface a {\n  @unstable(feature = inactive)\n  resource a {\n    @unstable(feature = inactive)\n    constructor();\n\n    x: static func();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-include1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-include1.wit", "package foo:foo;\n\nworld foo {\n  include non-existence;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-include2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-include2.wit", "package foo:foo;\n\nworld bar {\n    include foo;\n}\n\nworld foo {\n    include bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-include3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-include3.wit", "package foo:foo;\n\nworld foo {\n  include foo;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-list.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-list.wit", "// parse-fail\n\ninterface foo {\n  type x = list<u32\n\n  type y = u32\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-list2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-list2.wit", "// parse-fail\n\ninterface foo {\n  type z = list<u32,\n\n  type y = u32\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-list3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-list3.wit", "// parse-fail\n\ninterface foo {\n  type a = list<u32,>\n\n  type y = u32\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-list4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-list4.wit", "// parse-fail\n\ninterface foo {\n  type b = list<u32, u32>\n\n  type y = u32\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-pkg1" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-pkg1/root.wit", "package foo:foo;\n\ninterface foo {\n  use nonexistent.{};\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-pkg2" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-pkg2/root.wit", "package foo:foo;\n\ninterface foo {\n  use foo:bar/nonexistent.{};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/bad-pkg2/deps/bar/empty.wit", "package foo:bar;\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-pkg3" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-pkg3/root.wit", "package foo:foo;\n\ninterface foo {\n  use foo:bar/baz.{};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/bad-pkg3/deps/bar/baz.wit", "package foo:bar;\nworld baz {}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-pkg4" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-pkg4/root.wit", "package foo:foo;\ninterface foo {\n  use foo:bar/baz.{a-name};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/bad-pkg4/deps/bar/baz.wit", "package foo:bar;\ninterface baz {\n  a-name: func();\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-pkg5" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-pkg5/root.wit", "package foo:foo;\ninterface foo {\n  use foo:bar/baz.{nonexistent};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/bad-pkg5/deps/bar/baz.wit", "package foo:bar;\ninterface baz {\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-pkg6" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-pkg6/root.wit", "package foo:foo;\ninterface foo {\n  use foo:bar/baz.{};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/bad-pkg6/deps/bar/baz.wit", "package foo:baz;\n\ninterface bar {}\n\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource1.wit", "package foo:bar;\n\ninterface foo {\n  type t = borrow<u32>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource10.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource10.wit", "package foo:bar;\n\ninterface foo {\n  type t = own<u32>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource11.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource11.wit", "package foo:bar;\n\ninterface foo {\n  type t = own<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource12.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource12.wit", "package foo:bar;\n\ninterface foo {\n  foo: func();\n  type t = own<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource13.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource13.wit", "package foo:bar;\n\ninterface foo {\n  type foo = u32;\n  type t = own<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource14.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource14.wit", "package foo:bar;\n\ninterface foo {\n  resource a {}\n  type t = own<a>;\n  type b = own<t>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource15" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource15/foo.wit", "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{r};\n\n  type t = own<r>;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/bad-resource15/deps/foo/foo.wit", "package some:dep;\n\ninterface foo {\n  type r = u32;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource16.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource16.wit", "package foo:bar;\n\ninterface foo {\n  resource a {\n    constructor() -> result<_, string>;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource17.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource17.wit", "package foo:bar;\n\ninterface foo {\n  resource b;\n  resource a {\n    constructor() -> result<b, string>;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource2.wit", "package foo:bar;\n\ninterface foo {\n  type t = borrow<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource3.wit", "package foo:bar;\n\ninterface foo {\n  foo: func();\n  type t = borrow<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource4.wit", "package foo:bar;\n\ninterface foo {\n  type foo = u32;\n  type t = borrow<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource5.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource5.wit", "package foo:bar;\n\ninterface foo {\n  resource a {}\n  type t = borrow<a>;\n  type b = borrow<t>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource6.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource6.wit", "package foo:bar;\n\ninterface foo {\n  resource a {\n    constructor() -> u32;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource7.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource7.wit", "package foo:bar;\n\ninterface foo {\n  resource a {\n    constructor();\n    constructor();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource8.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource8.wit", "package foo:bar;\n\ninterface foo {\n  resource a {\n    a: func();\n    a: static func();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-resource9.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-resource9.wit", "package foo:bar;\n\ninterface foo {\n  resource a {\n    interface foo {}\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since-on-include.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since-on-include.wit", "package test:invalid@0.1.0;\n\nworld a {}\n\nworld b {\n  @since(version = 0.2.0)\n  include a;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since-on-interface.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since-on-interface.wit", "package test:invalid@0.1.0;\n\n@since(version = 0.2.0)\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since-on-type.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since-on-type.wit", "package test:invalid@0.1.0;\n\ninterface foo {\n  @since(version = 0.2.0)\n  type t = u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since-on-world-import.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since-on-world-import.wit", "package test:invalid@0.1.0;\n\nworld w {\n  @since(version = 0.2.0)\n  import x: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since-on-world.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since-on-world.wit", "package test:invalid@0.1.0;\n\n@since(version = 0.2.0)\nworld w {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since1.wit", "package a:b;\n\n@since\ninterface foo1 {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-since3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-since3.wit", "package a:b;\n\n// for now `version` must come first\n@since(feature = foo, version = 1.0.0)\ninterface foo2 {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/bad-world-type1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/bad-world-type1.wit", "package foo:foo;\nworld a {\n  type a = u32;\n  import a: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/case-insensitive-duplicates.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/case-insensitive-duplicates.wit", "// parse-fail\n\npackage poc:demo;\n\nworld example {\n  import get-data: func() -> string;\n  export get-user: func() -> string;\n  export GET-USER: func() -> string;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/case-insensitive-function-params.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/case-insensitive-function-params.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  f: func(foo: u32, FOO: u64);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/conflicting-package" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/conflicting-package/a.wit", "package foo:a;\n",
        ),
        section_document(
          "parse-fail/conflicting-package/b.wit", "package foo:b;\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/cycle.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/cycle.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = foo;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/cycle2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/cycle2.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  type bar = foo;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/cycle3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/cycle3.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  type bar = option<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/cycle4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/cycle4.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  record bar { x: foo }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/cycle5.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/cycle5.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n  type bar = list<foo>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/dangling-type.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/dangling-type.wit", "// parse-fail\n\ninterface foo {\n  type\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-enum-cases.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-enum-cases.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  enum e { a, b, B }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-flags.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-flags.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  flags f { a, b, A }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-function-params.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-function-params.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  foo: func(foo: u32, foo: u64);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-functions.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-functions.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  foo: func();\n  foo: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-interface.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-interface.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {}\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-interface2" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-interface2/foo.wit", "package foo:foo;\n\ninterface foo {}\n",
        ),
        section_document(
          "parse-fail/duplicate-interface2/foo2.wit", "package foo:foo;\n\ninterface foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-record-fields.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-record-fields.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  record r { a: u32, b: u32, a: u32 }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-type.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-type.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = s32;\n  type foo = s32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/duplicate-variant-cases.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/duplicate-variant-cases.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  variant v { a-b(u32), ab }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/empty-enum.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/empty-enum.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  enum t {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/empty-tuple.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/empty-tuple.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type t = tuple<>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/empty-variant1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/empty-variant1.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  variant t {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/export-twice.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/export-twice.wit", "package foo:foo;\n\ninterface foo {}\n\nworld bar {\n  export foo;\n  export foo;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/implements-conflicts-func.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/implements-conflicts-func.wit", "// parse-fail\npackage foo:foo;\n\ninterface store {\n  get: func() -> option<string>;\n}\n\nworld test {\n  import primary: func();\n  import primary: store;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/implements-duplicate-label.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/implements-duplicate-label.wit", "// parse-fail\npackage foo:foo;\n\ninterface store {\n  get: func() -> option<string>;\n}\n\nworld test {\n  import primary: store;\n  import primary: store;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/implements-nonexistent.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/implements-nonexistent.wit", "// parse-fail\npackage foo:foo;\n\ninterface store {\n  get: func() -> option<string>;\n}\n\nworld test {\n  import primary: nonexistent;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/implements-not-interface.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/implements-not-interface.wit", "// parse-fail\npackage foo:foo;\n\nworld test {\n  import primary: test;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/import-and-export1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/import-and-export1.wit", "package foo:foo;\ninterface i1 {\n  type t = u32;\n}\ninterface i2 {\n  use i1.{t};\n}\ninterface i3 {\n  use i2.{t};\n}\n\nworld test {\n  import i1: interface {}\n\n  export i1;\n  export i3;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/import-and-export2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/import-and-export2.wit", "package foo:foo;\n\ninterface foo {\n  type t = u32;\n}\n\ninterface bar {\n  use foo.{t};\n}\n\nworld baz {\n  export foo;\n  import bar;\n  export anon: interface {\n    use foo.{t};\n    use bar.{t as t2};\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/import-and-export3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/import-and-export3.wit", "package foo:foo;\n\ninterface foo {}\ninterface bar {}\n\nworld the-world {\n  import foo;\n  import bar;\n  import baz: interface {\n    foo: func();\n  }\n  export foo;\n  export bar;\n  export baz2: interface {\n    foo: func();\n  }\n}\n\nworld a-different-world {\n  import foo;\n}\n\ninterface i1 {\n  type t = u32;\n}\ninterface i2 {\n  use i1.{t};\n}\ninterface i3 {\n  use i2.{t};\n}\n\nworld test {\n  import i3;\n  export i1;\n  export i3;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/import-and-export4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/import-and-export4.wit", "package foo:foo;\n\n\nworld union-world {\n  include test;\n  include a-different-world;\n  include the-world;\n}\n\ninterface foo {}\ninterface bar {}\n\nworld the-world {\n  import foo;\n  import bar;\n  import baz: interface {\n    foo: func();\n  }\n  export foo;\n  export bar;\n  export baz2: interface {\n    foo: func();\n  }\n}\n\nworld a-different-world {\n  import foo;\n}\n\ninterface i1 {\n  type t = u32;\n}\ninterface i2 {\n  use i1.{t};\n}\ninterface i3 {\n  use i2.{t};\n}\n\nworld test {\n  import i3;\n  export i1;\n  export i3;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/import-and-export5.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/import-and-export5.wit", "package foo:bar;\n\ninterface a {\n  record x {\n    a: u32,\n  }\n}\n\ninterface b {\n  use a.{x};\n}\n\nworld w {\n  export anon: interface {\n    use b.{x as x2};\n    use a.{x};\n  }\n  export a;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/import-twice.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/import-twice.wit", "package foo:foo;\n\ninterface foo {}\n\nworld bar {\n  import foo;\n  import foo;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/include-cycle.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/include-cycle.wit", "package foo:foo;\n\nworld a {\n    include b;\n}\n\nworld b {\n    include a;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/include-foreign" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/include-foreign/root.wit", "package foo:foo;\n\nworld foo {\n  include foo:bar/bar;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/include-foreign/deps/bar/empty.wit", "package foo:bar;\n\ninterface bar {}",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/include-setter-no-getter.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/include-setter-no-getter.wit", "// parse-fail\n\npackage foo:foo;\n\nworld base {\n  import other: func();\n}\n\nworld derived {\n  import prop: set(value: u32);\n  include base;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/include-strongly-unique.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/include-strongly-unique.wit", "// parse-fail\n\npackage foo:foo;\n\nworld base {\n  import foo-bar: func();\n}\n\nworld derived {\n  include base;\n  import foobar: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/include-with-id.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/include-with-id.wit", "package foo:foo;\n\ninterface foo {}\n\nworld a {\n    import foo;\n}\n\nworld b {\n    include a with { foo:foo/foo as foo2 }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/include-with-on-id.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/include-with-on-id.wit", "package foo:foo;\n\ninterface foo {}\n\nworld a {\n    import foo;\n}\n\nworld b {\n    include a with { foo as foo2 }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/invalid-toplevel.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/invalid-toplevel.wit", "// parse-fail\n\ninterface foo {\n  abcd\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/invalid-type-reference.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/invalid-type-reference.wit", "package foo:foo;\n\ninterface foo {\n  x: func();\n\n  record foo {\n    // TODO: this should have a better error message referring to `x: func()`\n    a: x\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/invalid-type-reference2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/invalid-type-reference2.wit", "package foo:foo;\n\ninterface foo {\n  x: func();\n  y: func() -> x;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/kebab-name-include-not-found.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/kebab-name-include-not-found.wit", "package foo:foo;\n\nworld foo { import a: func(); }\nworld bar { import a: func(); }\nworld baz {\n    include foo with { b1 as b2 }\n    include bar with { a as b }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/kebab-name-include.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/kebab-name-include.wit", "package foo:foo;\n\nworld foo { import a: func(); }\nworld bar { import a: func(); }\nworld baz {\n    include foo;\n    include bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/keyword.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/keyword.wit", "// parse-fail\n\ninterface kw {\n  type option = u32\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/map-invalid-key.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/map-invalid-key.wit", "// Map keys must be primitive types only\npackage foo:invalid-map-key;\n\ninterface test {\n  // This should fail - tuple is not a valid map key type\n  type invalid = map<tuple<u32, string>, u32>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/missing-main-declaration-initial-main.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/missing-main-declaration-initial-main.wit", "interface i1 {\n  type a = u32;\n}\n\nworld w1 {\n  import imp1: interface {\n    use i1.{a};\n  }\n}\n\n\npackage foo:name {\n  interface i2 {\n    type b = u32;\n  }\n\n  world w2 {\n    import imp2: interface {\n        use i2.{b};\n    }\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/missing-main-declaration-initial-nested.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/missing-main-declaration-initial-nested.wit", "package foo:name {\n  interface i1 {\n    type a = u32;\n  }\n\n  world w1 {\n    import imp1: interface {\n        use i1.{a};\n    }\n  }\n}\n\n\ninterface i2 {\n  type b = u32;\n}\n\nworld w2 {\n  import imp2: interface {\n    use i2.{b};\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/missing-package.wit" {
  let result = corpus_resolve(
    Source({
      documents: [section_document("parse-fail/missing-package.wit", "")],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/multi-file-missing-delimiter" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/multi-file-missing-delimiter/observe.wit", "interface observe {\n  record bar {\n    a : string,\n  }\n  // NB: intentionally missing a delimiter at the end of the file\n",
        ),
        section_document(
          "parse-fail/multi-file-missing-delimiter/world.wit", "package qux:qaz@2.0.0;\n\nworld platform {\n  import observe;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/multi-package-deps-share-nest" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/multi-package-deps-share-nest/root.wit", "package foo:root;\n\ninterface i0 {\n  use foo:dep1/i1.{o1};\n  use foo:dep2/i2.{o2};\n\n  type v = tuple<o1, o2>;\n}",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/multi-package-deps-share-nest/deps/dep1/types.wit", "package foo:dep1;\n\npackage foo:shared {\n  interface shared1 {\n    type t1 = string;\n  }\n}\n\ninterface i1 {\n  use foo:shared/shared1.{t1};\n  type o1 = option<t1>;\n}",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "parse-fail/multi-package-deps-share-nest/deps/dep2/types.wit", "package foo:dep2;\n\npackage foo:shared {\n  interface shared2 {\n    type t2 = string;\n  }\n}\n\ninterface i2 {\n  use foo:shared/shared2.{t2};\n  type o2 = option<t2>;\n}",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/multiple-package-docs" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/multiple-package-docs/a.wit", "/// Multiple package docs, A;\npackage foo:foo;",
        ),
        section_document(
          "parse-fail/multiple-package-docs/b.wit", "/// Multiple package docs, B\npackage foo:foo;\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/multiple-package-inline-cycle.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/multiple-package-inline-cycle.wit", "package foo:root;\npackage foo:bar {\n  interface i {\n    use foo:qux/i.{};\n  }\n}\n\npackage foo:qux {\n  interface i {\n    use foo:bar/i.{};\n  }\n}",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/multiple-packages-no-scope-blocks.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/multiple-packages-no-scope-blocks.wit", "package foo:name;\n\ninterface i1 {\n  type a = u32;\n}\n\npackage bar:name;\n\nworld w1 {\n  import imp1: interface {\n    use foo:name/i1.{a};\n\n    fn: func(a: a);\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/nested-packages-colliding-names.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/nested-packages-colliding-names.wit", "package foo:root;\n\npackage foo:name {}\n\npackage foo:name {}",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/nested-packages-with-error.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/nested-packages-with-error.wit", "package foo:root;\npackage foo:name {}\n\npackage bar:name {\n  interface unused {\n    type a = u32;\n  }\n\n  world w {\n    import imp: interface {\n        use missing.{a};\n    }\n  }\n}",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/no-access-to-sibling-use" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/no-access-to-sibling-use/bar.wit", "use bar as bar-renamed;\n",
        ),
        section_document(
          "parse-fail/no-access-to-sibling-use/foo.wit", "package foo:foo;\n\nuse bar-renamed;\n\ninterface bar {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/non-existence-world-include" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/non-existence-world-include/root.wit", "package foo:foo;\n\nworld foo {\n  include foo:baz/non-existence;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/non-existence-world-include/deps/bar/baz.wit", "package foo:baz;\n\ninterface bar {}\n\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/old-float-types.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/old-float-types.wit", "package foo:bar;\n\ninterface a {\n  type t1 = float32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/package-nesting-too-deep.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/package-nesting-too-deep.wit", "// parse-fail\n\npackage a:b0 {\npackage a:b1 {\npackage a:b2 {\npackage a:b3 {\npackage a:b4 {\npackage a:b5 {\npackage a:b6 {\npackage a:b7 {\npackage a:b8 {\npackage a:b9 {\npackage a:b10 {\npackage a:b11 {\npackage a:b12 {\npackage a:b13 {\npackage a:b14 {\npackage a:b15 {\npackage a:b16 {\npackage a:b17 {\npackage a:b18 {\npackage a:b19 {\npackage a:b20 {\npackage a:b21 {\npackage a:b22 {\npackage a:b23 {\npackage a:b24 {\npackage a:b25 {\npackage a:b26 {\npackage a:b27 {\npackage a:b28 {\npackage a:b29 {\npackage a:b30 {\npackage a:b31 {\npackage a:b32 {\npackage a:b33 {\npackage a:b34 {\npackage a:b35 {\npackage a:b36 {\npackage a:b37 {\npackage a:b38 {\npackage a:b39 {\npackage a:b40 {\npackage a:b41 {\npackage a:b42 {\npackage a:b43 {\npackage a:b44 {\npackage a:b45 {\npackage a:b46 {\npackage a:b47 {\npackage a:b48 {\npackage a:b49 {\npackage a:b50 {\npackage a:b51 {\npackage a:b52 {\npackage a:b53 {\npackage a:b54 {\npackage a:b55 {\npackage a:b56 {\npackage a:b57 {\npackage a:b58 {\npackage a:b59 {\npackage a:b60 {\npackage a:b61 {\npackage a:b62 {\npackage a:b63 {\npackage a:b64 {\npackage a:b65 {\npackage a:b66 {\npackage a:b67 {\npackage a:b68 {\npackage a:b69 {\npackage a:b70 {\npackage a:b71 {\npackage a:b72 {\npackage a:b73 {\npackage a:b74 {\npackage a:b75 {\npackage a:b76 {\npackage a:b77 {\npackage a:b78 {\npackage a:b79 {\npackage a:b80 {\npackage a:b81 {\npackage a:b82 {\npackage a:b83 {\npackage a:b84 {\npackage a:b85 {\npackage a:b86 {\npackage a:b87 {\npackage a:b88 {\npackage a:b89 {\npackage a:b90 {\npackage a:b91 {\npackage a:b92 {\npackage a:b93 {\npackage a:b94 {\npackage a:b95 {\npackage a:b96 {\npackage a:b97 {\npackage a:b98 {\npackage a:b99 {\npackage a:b100 {\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/pkg-cycle" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/pkg-cycle/root.wit", "package foo:foo;\ninterface foo {\n  use foo:a1/foo.{};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/pkg-cycle/deps/a1/root.wit", "package foo:a1;\ninterface foo {\n  use foo:a1/foo.{};\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/pkg-cycle2" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/pkg-cycle2/root.wit", "package foo:root;\ninterface foo {\n  use foo:a1/foo.{};\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/pkg-cycle2/deps/a1/root.wit", "package foo:a1;\ninterface foo {\n  use foo:a2/foo.{};\n}\n",
          ),
        ],
      }),
      Source({
        documents: [
          section_document(
            "parse-fail/pkg-cycle2/deps/a2/root.wit", "package foo:a2;\ninterface foo {\n  use foo:a1/foo.{};\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/resource-method-named-after-resource.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/resource-method-named-after-resource.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  resource foo {\n    foo: func();\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/resources-multiple-returns-borrow.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/resources-multiple-returns-borrow.wit", "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: borrow<r1>) -> ();\n\n  resource r1 {\n    f1: func() -> (a: s32, handle: borrow<r1>);\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/resources-return-borrow.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/resources-return-borrow.wit", "package foo:resources1;\n\ninterface resources1 {\n  t1: func(a: borrow<r1>) -> ();\n\n  resource r1 {\n    f1: func() -> borrow<r1>;\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow1.wit", "package foo:bar;\n\ninterface foo {\n  resource y;\n\n  x: func() -> borrow<y>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow2.wit", "package foo:bar;\n\ninterface foo {\n  resource y {\n    x: func() -> borrow<y>;\n  }\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow3.wit", "package foo:bar;\n\nworld foo {\n  resource y {\n    x: func() -> borrow<y>;\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow4.wit", "package foo:bar;\n\nworld foo {\n  resource y;\n\n  import x: func() -> borrow<y>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow5.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow5.wit", "package foo:bar;\n\nworld foo {\n  resource y;\n\n  export x: func() -> borrow<y>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow6.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow6.wit", "package foo:bar;\n\ninterface foo {\n  resource y;\n\n  x: func() -> tuple<borrow<y>>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow7.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow7.wit", "package foo:bar;\n\ninterface foo {\n  resource y;\n\n  record y2 {\n    a: borrow<y>,\n  }\n\n  x: func() -> y2;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/return-borrow8" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/return-borrow8/foo.wit", "package foo:bar;\n\ninterface foo {\n  use foo:baz/i.{r};\n\n  x: func() -> r;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/return-borrow8/deps/baz.wit", "package foo:baz;\n\ninterface i {\n  resource my-resource;\n\n  record r {\n    x: borrow<my-resource>,\n  }\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/too-many-flags.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/too-many-flags.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  flags f {\n    b0,\n    b1,\n    b2,\n    b3,\n    b4,\n    b5,\n    b6,\n    b7,\n    b8,\n    b9,\n    b10,\n    b11,\n    b12,\n    b13,\n    b14,\n    b15,\n    b16,\n    b17,\n    b18,\n    b19,\n    b20,\n    b21,\n    b22,\n    b23,\n    b24,\n    b25,\n    b26,\n    b27,\n    b28,\n    b29,\n    b30,\n    b31,\n    b32,\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/type-and-resource-same-name" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/type-and-resource-same-name/foo.wit", "package foo:bar;\n\ninterface foo {\n  use some:dep/foo.{a};\n\n  type t1 = a;\n  type t2 = borrow<a>;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/type-and-resource-same-name/deps/dep/foo.wit", "package some:dep;\n\ninterface foo {\n  type a = u32;\n}\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/type-nesting-too-deep.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/type-nesting-too-deep.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type t =\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    list<\n    u8\n    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), true)
}

///|
test "upstream semantic parse-fail/undefined-typed.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/undefined-typed.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  type foo = bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unknown-interface.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unknown-interface.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import bar;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-interface1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-interface1.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-interface2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-interface2.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import bar;\n}\n\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-interface3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-interface3.wit", "// parse-fail\n\npackage foo:foo;\n\nuse bar as foo;\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-interface4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-interface4.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import some:dependency/iface;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use1.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use10" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use10/bar.wit", "package foo:foo;\n\ninterface bar {\n  use foo.{thing};\n}\n",
        ),
        section_document(
          "parse-fail/unresolved-use10/foo.wit", "interface foo {\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use2.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n\ninterface bar {\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use3.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n\ninterface bar {\n  x: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use7.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use7.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use bar.{x};\n}\n\ninterface bar {\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use8.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use8.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo: interface {\n    use foo.{i32};\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/unresolved-use9.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/unresolved-use9.wit", "// parse-fail\n\npackage foo:foo;\n\nworld foo {\n  import foo: interface {\n    use bar.{i32};\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-and-include-world" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-and-include-world/root.wit", "package foo:foo;\n\nuse foo:baz/bar;\n\nworld foo {\n    include foo:baz/bar;\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/use-and-include-world/deps/bar/baz.wit", "package foo:baz;\n\nworld bar {}\n\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-conflict.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-conflict.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x, x};\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-conflict2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-conflict2.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x};\n\n  type x = s64;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-conflict3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-conflict3.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x};\n\n  x: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-cycle1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-cycle1.wit", "// parse-fail\n\npackage foo:foo;\n\ninterface foo {\n  use foo.{bar};\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-cycle4.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-cycle4.wit", "// parse-fail\npackage foo:foo;\n\ninterface foo {\n  use bar.{y};\n\n  type x = u32;\n}\n\ninterface bar {\n  use foo.{x};\n\n  type y = u32;\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-shadow1.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-shadow1.wit", "package foo:foo;\n\nuse foo as bar;\n\ninterface foo {}\n\ninterface bar {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/use-world" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/use-world/root.wit", "package foo:foo;\n\nuse foo:baz/bar;\n\nworld foo {\n\n}\n",
        ),
      ],
    }),
    dependencies=[
      Source({
        documents: [
          section_document(
            "parse-fail/use-world/deps/bar/baz.wit", "package foo:baz;\n\nworld bar {}\n\n",
          ),
        ],
      }),
    ],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/very-large-column.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/very-large-column.wit",
          "package demo:hellaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaworld hello {\naaaaaaaaaaaaaaaao\n  export run: fworld hello {\n run: f)\nworld hello {\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/very-nested-packages.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/very-nested-packages.wit", "package a:b;\n\npackage a:c {\n  package a:c2 {\n    package a:c3 {\n    }\n  }\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/world-interface-clash.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/world-interface-clash.wit", "package foo:foo;\ninterface foo {}\nworld foo {}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/world-same-fields2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/world-same-fields2.wit", "// parse-fail\n\npackage foo:foo;\n\nworld a {\n  import foo: interface {}\n  import foo: interface {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/world-same-fields3.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/world-same-fields3.wit", "// parse-fail\n\npackage foo:foo;\n\nworld a {\n  export foo: interface {}\n  export foo: interface {}\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/world-top-level-func.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/world-top-level-func.wit", "package foo:foo;\nworld foo {\n  import foo: func();\n  import foo: func();\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}

///|
test "upstream semantic parse-fail/world-top-level-func2.wit" {
  let result = corpus_resolve(
    Source({
      documents: [
        section_document(
          "parse-fail/world-top-level-func2.wit", "package foo:foo;\nworld foo {\n  import foo: func(a: b);\n}\n",
        ),
      ],
    }),
    dependencies=[],
    semantic_features={ enabled: ["active"], all_enabled: false, },
  )
  assert_eq(result is Ok(_), false)
}
