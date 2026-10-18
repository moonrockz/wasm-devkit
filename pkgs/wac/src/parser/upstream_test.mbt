// Unmodified WAC fixtures, Apache-2.0 WITH LLVM-exception. See fixtures/.
// bytecodealliance/wac at 5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9.

///|
test "pinned WAC syntax encoding/fail/arg-merge-failure.wac" {
  let source = [
    "package test:comp;\n\nlet a = new foo:bar { ... };\nlet b = new bar:baz { ... };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/fail/implicit-arg-conflict.wac" {
  let source = [
    "package test:comp;\n\nimport foo: func();\n\nlet x = new foo:bar { ... };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/fail/import-conflict.wac" {
  let source = [
    "package test:comp;\n\nlet x = new foo:bar { ... };\n\nimport foo: func();\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/fail/unmergeable-args.wac" {
  let source = [
    "package test:comp;\n\nlet a = new bar:baz { ... };\nlet b = new foo:bar { ... };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/include-resource.wac" {
  let source = ["package test:comp;\n\nlet x = new foo:bar { ... };\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/instantiation.wac" {
  let source = [
    "package test:comp;\n\nimport i: interface {\n    foo: func();\n};\n\nimport i2: interface {\n    baz: func(",
    ");\n};\n\nimport f: func();\n\nlet baz = f;\nlet x1 = new foo:bar { ... };\nlet x2 = new foo:bar { baz: f }",
    ";\nlet x3 = new foo:bar { baz };\nlet x4 = new foo:bar { ...i2, ... };\n\nlet y1 = new bar:baz { ... };\n",
    "let y2 = new bar:baz { foo: i };\nlet y3 = new bar:baz { foo: x1 };\nlet y4 = new bar:baz { foo: x2 };",
    "\nlet y5 = new bar:baz { foo: x3 };\n\nexport x4...;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/merged-functions.wac" {
  let source = [
    "package test:comp;\n\nlet a = new foo:bar {\n    ...\n};\n\nlet b = new foo:baz {\n    ...\n};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/resources.wac" {
  let source = [
    "package test:comp;\n\nimport foo: interface {\n    resource r {\n        constructor();\n        foo: fun",
    "c();\n        bar: static func();\n    }\n\n    type r2 = r;\n\n    bar: func(r: borrow<r>, r2: borrow<r2>",
    ", r3: r, r4: r2) -> tuple<r, r2>;\n    baz: func();\n};\n\nlet x = new foo:bar { foo };\n\nexport x.foo;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/spread-semver.wac" {
  let source = [
    "package test:comp;\n\n// The plug exports `test:dep/iface@0.2.0`, but the socket imports\n// `test:dep/",
    "iface@0.2.1`; the spread should match them via semver compatibility.\nlet plug = new foo:plug { };\nle",
    "t socket = new foo:socket { ...plug };\n\nexport socket...;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax encoding/types.wac" {
  let source = [
    "package test:pkg;\n\ntype a = u8;\ntype b = s8;\ntype c = u16;\ntype d = s16;\ntype e = u32;\ntype f = s32;",
    "\ntype g = u64;\ntype h = s64;\ntype i = f32;\ntype j = f64;\ntype k = bool;\ntype l = char;\ntype m = stri",
    "ng;\n\nrecord n {\n    a: list<u8>,\n    b: tuple<s8, u16, s16>,\n    c: option<u32>,\n}\n\nvariant o {\n    ",
    "foo,\n    bar(n),\n    baz(tuple<n, n, n>),\n}\n\nflags p {\n    foo,\n    bar,\n    baz,\n}\n\nenum q {\n    a,",
    "\n    b,\n    c,\n}\n\ninterface r {\n    type a = string;\n    type b = u16;\n    type c = b;\n    resource ",
    "d {\n        constructor(a: a);\n        a: func(b: b);\n        b: static func(c: c);\n    } \n\n    f: f",
    "unc(a: a, b: b, c: c, d: d) -> tuple<c, b, d, a>;\n}\n\ninterface s {\n    use r.{a, b, c};\n\n    record ",
    "n {\n        a: list<u8>,\n        b: tuple<s8, u16, s16>,\n        c: option<u32>,\n    }\n\n    variant ",
    "o {\n        foo,\n        bar(n),\n        baz(tuple<n, n, n>),\n    }\n\n    flags p {\n        foo,\n    ",
    "    bar,\n        baz,\n    }\n\n    f: func(a: a, b: b, c: c) -> tuple<c, b, a>;\n}\n\nworld t {\n    use r",
    ".{a, b, c};\n\n    import f: func(a: a, b: b, c: c) -> tuple<c, b, a>;\n\n    record n {\n        a: list",
    "<u8>,\n        b: tuple<s8, u16, s16>,\n        c: option<u32>,\n    }\n\n    variant o {\n        foo,\n  ",
    "      bar(n),\n        baz(tuple<n, n, n>),\n    }\n\n    flags p {\n        foo,\n        bar,\n        ba",
    "z,\n    }\n    export f: func(a: a, b: b, c: c) -> tuple<n, o, p>;\n}\n\n// Test encoding of aliases\ntype",
    " a2 = a;\ntype b2 = b;\ntype c2 = c;\ntype d2 = d;\ntype e2 = e;\ntype f2 = f;\ntype g2 = g;\ntype h2 = h;\n",
    "type i2 = i;\ntype j2 = j;\ntype k2 = k;\ntype l2 = l;\ntype n2 = n;\ntype m2 = m;\ntype o2 = o;\ntype p2 =",
    " p;\ntype q2 = q;\n\n// Test encoding of aliases to inline-created defined types\ntype list-alias = list",
    "<u8>;\ntype option-alias = option<string>;\ntype result-alias = result<u32, string>;\ntype tuple-alias ",
    "= tuple<u8, u16>;\ntype nested-list-alias = list<list<u8>>;\n\n// wasip3 types: stream, future, error-c",
    "ontext\ntype stream1 = stream;\ntype stream2 = stream<u8>;\ntype stream3 = stream<list<string>>;\ntype f",
    "uture1 = future;\ntype future2 = future<u32>;\ntype future3 = future<option<string>>;\ntype ec = error-",
    "context;\n\n// async function types\ntype async-fn1 = async func() -> string;\ntype async-fn2 = async fu",
    "nc(data: list<u8>) -> stream<u8>;\ntype sync-fn = func() -> string;\n\n// interface with async function",
    "s and wasip3 types\ninterface async-iface {\n    process: async func(input: list<u8>) -> stream<u8>;\n ",
    "   get-result: async func() -> future<string>;\n    sync-op: func(x: u32) -> u32;\n    type my-stream ",
    "= stream<u32>;\n    type my-future = future<string>;\n    type my-ec = error-context;\n}\n\n// world with",
    " async imports/exports\nworld async-world {\n    import run: async func() -> string;\n    import fetch:",
    " async func(url: string) -> stream<u8>;\n    export process: async func(data: list<u8>) -> future<u32",
    ">;\n}\n\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/export.wac" {
  let source = [
    "package test:comp;\n\n/// Export an item (default name)\nexport e;\n\n/// Export an alias of an item (def",
    "ault name)\nexport e[\"foo\"];\n\n/// Export an alias of an item with a different name with string\nexport",
    " e[\"foo\"] as \"bar\";\n\n/// Export an alias of an item with a different name with identifier\nexport e[\"",
    "foo\"] as foo-bar;\n\n/// Export of an instance spread\nexport i...;\n\n/// Export of an expression spread",
    "\nexport new foo:bar { ... } ...;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/async-not-func.wac" {
  let source = ["package test:comp;\n\ntype bad = async u32;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/bad-alias.wac" {
  let source = ["package test:comp;\n\ntype u32 = x;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/duplicate-package-decl.wac" {
  let source = ["package test:comp;\npackage test:comp;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/empty-enum.wac" {
  let source = ["package test:comp;\n\nenum e {}"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/empty-flags.wac" {
  let source = ["package test:comp;\n\nflags f {}"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/empty-record.wac" {
  let source = ["package test:comp;\n\nrecord r {}"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/empty-variant.wac" {
  let source = ["package test:comp;\n\nvariant v {}"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/error-context-payload.wac" {
  let source = ["package test:comp;\n\ntype bad = error-context<u8>;\n"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/expected-multiple.wac" {
  let source = ["package test:comp;\n\ntype x = "].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/expected-two.wac" {
  let source = ["package test:comp;\n\nrecord foo {\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/future-empty-payload.wac" {
  let source = ["package test:comp;\n\ntype bad = future<>;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/future-missing-close.wac" {
  let source = ["package test:comp;\n\ntype bad = future<string;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/invalid-path-semver.wac" {
  let source = ["package foo:bar;\n\nimport i: foo:bar/baz@1;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/invalid-semver.wac" {
  let source = ["package foo:bar@1;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/missing-package-decl.wac" {
  let source = ["import f: func();\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/missing-semi.wac" {
  let source = ["package test:comp;\n\ntype x = u32"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/stream-empty-payload.wac" {
  let source = ["package test:comp;\n\ntype bad = stream<>;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/fail/stream-missing-close.wac" {
  let source = ["package test:comp;\n\ntype bad = stream<u8;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != false {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/import.wac" {
  let source = [
    "package test:comp;\n\n/// Import by func type\nimport a: func();\n\n/// Import by ident\nimport b: x;\n\n///",
    " Import by package path\nimport c: foo:bar/baz;\n\n/// Import by func type with kebab name string\nimpor",
    "t d as \"hello-world\": func(name: string);\n\n/// Import by inline interface\nimport e: interface {\n    ",
    "x: func();\n};\n\n/// Import by package path with version\nimport f: foo:bar/baz@1.0.0;\n\n/// Import by f",
    "unc type with kebab name identifier\nimport g as hello-world: func(name: string);\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/let.wac" {
  let source = [
    "package test:comp;\n\n/// Instantiate without args\nlet a = new foo:bar {};\n\n/// Instantiation with imp",
    "ort-propagation.\nlet b = new foo:bar@1.0.0 { ... };\n\n/// Instantiation with arguments\nlet c = new fo",
    "o:bar@2.0.0 { a, b, \"c\": c, };\n\n/// Instantiation with arguments and import-propagation.\nlet d = new",
    " foo:bar@3.0.0 { a, \"b\": (new foo:bar { }), c: c, ... };\n\n/// Nested expression\nlet e = (b);\n\n/// Ac",
    "cess expression\nlet f = e[\"b-c\"].c.d[\"foo:bar/baz\"].e;\n\n/// Mix of instantiation arguments\nlet h = n",
    "ew f:bar { inferred, ...a, b: c, ...d, ... };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/resource.wac" {
  let source = [
    "package test:comp;\n\ninterface foo {\n    /// Resource without methods\n    resource r1;\n\n    /// Resou",
    "rce with only constructor\n    resource r2 {\n        /// Constructor\n        constructor();\n    }\n\n  ",
    "  /// Resource with constructor, instance method, and static method\n    resource r3 {\n        /// Co",
    "nstructor\n        constructor(a: u32);\n        /// Method\n        a: func(b: u32);\n        /// Stati",
    "c method\n        b: static func(c: u32);\n    }\n}\n\nworld bar {\n    /// Resource without methods\n    r",
    "esource r1;\n\n    /// Resource with only constructor\n    resource r2 {\n        /// Constructor\n      ",
    "  constructor();\n    }\n\n    /// Resource with constructor, instance method, and static method\n    re",
    "source r3 {\n        /// Constructor\n        constructor(a: u32);\n        /// Method\n        a: func(",
    "b: u32);\n        /// Static method\n        b: static func(c: u32);\n    }\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/type-alias.wac" {
  let source = [
    "package test:comp;\n\n/// u8\ntype a = u8;\n/// s8\ntype b = s8;\n/// u16\ntype c = u16;\n/// s16\ntype d = s",
    "16;\n/// u32\ntype e = u32;\n/// s32\ntype f = s32;\n/// u64\ntype g = u64;\n/// s64\ntype h = s64;\n/// f32\n",
    "type i = f32;\n/// f64\ntype j = f64;\n/// bool\ntype k = bool;\n/// char\ntype l = char;\n/// string\ntype ",
    "m = string;\n/// tuple<u8, s8>\ntype n = tuple<u8, s8>;\n/// list<tuple<u8>>\ntype o = list<tuple<u8>>;\n",
    "/// option<string>\ntype p = option<string>;\n/// result\ntype q = result;\n/// result<u8>\ntype r = resu",
    "lt<u8>;\n/// result<_, s8>\ntype s = result<_, s8>;\n/// result<u8, string>\ntype t = result<u8, string>",
    ";\n/// borrow<x>\ntype u = borrow<x>;\n/// x\ntype v = x;\n/// keyword\ntype %type = v;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/types.wac" {
  let source = [
    "package test:comp;\n\n/// Defining an interface\ninterface i {\n    /// Defining a resource\n    resource",
    " res {\n        constructor();\n    }\n\n    /// Type alias a\n    type a = func();\n    /// Record type\n ",
    "   record r {\n        x: u32\n    }\n    /// Export func\n    x: func();\n    /// Export func of type a\n",
    "    y: a;\n}\n\n/// Defining a second interface\ninterface i2 {\n    /// Use type r from i\n    use i.{r};",
    "\n\n    /// Use type r from i with alias z\n    use i.{r as z};\n}\n\n/// Defining a world\nworld w1 {\n    ",
    "/// Use type r from foo:bar/i\n    use foo:bar/i.{r};\n\n    /// Import a function\n    import a: func()",
    ";\n    /// Import an interface\n    import i;\n    /// Import by name with type `c`\n    import c: c;\n\n ",
    "   /// Export an inline interface\n    export d: interface {\n        x: func();\n    };\n    /// Export",
    " an interface\n    export i2;\n    /// Export by name with type `f`\n    export f: f;\n}\n\n/// Defining a",
    " second world\nworld w2 {\n    /// Include the first world\n    include w1;\n\n    /// Include a world by",
    " path\n    include foo:bar/baz;\n}\n\n/// Defining a variant\nvariant v {\n    a(x),\n    b(string),\n    c(",
    "u32),\n    d,\n}\n\n/// Defining a record\nrecord r {\n    x: u32,\n    y: string,\n    z: v,\n}\n\n/// Definin",
    "g flags\nflags f {\n    a,\n    b,\n    c,\n}\n\n/// Defining an enum\nenum e {\n    a,\n    b,\n    c,\n}\n\n/// ",
    "Type aliases\ntype t = e;\ntype t2 = string;\ntype t3 = func(a: u32, b: r) -> u32;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax parser/use.wac" {
  let source = [
    "package test:comp;\n\ninterface my-handler {\n    use wasi:http/types@0.2.0.{incoming-request, response",
    "-outparam};\n    handle: func(request: incoming-request, response-out: response-outparam);\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/alias.wac" {
  let source = [
    "package test:comp@1.0.0;\n\ntype a = u32;\n\ntype b = string;\n\ntype c = func();\n\nexport a as \"a2\";\nexpor",
    "t b as \"b2\";\nexport c as \"c2\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/duplicate-world-item.wac" {
  let source = [
    "package test:comp@2.0.0;\n\nworld w {\n    import x: func();\n    export x: func();\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/borrow-in-func-result.wac" {
  let source = [
    "package test:comp;\n\ninterface foo {\n    resource x;\n    type a = borrow<x>;\n    f: func() -> result<",
    "a>;\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-enum-case.wac" {
  let source = [
    "package test:comp;\n\nenum e {\n    a,\n    b,\n    c,\n    b,\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-export.wac" {
  let source = [
    "package test:comp;\n\nimport foo: func();\n\nexport foo as \"foo\";\nexport foo as foo;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-flag.wac" {
  let source = [
    "package test:comp;\n\nflags f {\n    a,\n    b,\n    c,\n    d,\n    a,\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-func-param.wac" {
  let source = ["package test:comp;\n\ntype f = func(x: u32, x: string);"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-import.wac" {
  let source = [
    "package test:comp;\n\nimport foo as \"foo\": func();\nimport bar as foo: func();\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-inst-args.wac" {
  let source = [
    "package test:comp;\n\nimport bar: func();\n\nlet x = new foo:bar { foo: bar, foo: bar };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-interface-export.wac" {
  let source = [
    "package test:comp;\n\ninterface x {\n    x: func();\n    x: func();\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-name-in-include.wac" {
  let source = [
    "package test:comp;\n\nworld w1 {\n\n}\n\nworld w2 {\n    include w1 with { a as b, a as c};\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-record-field.wac" {
  let source = [
    "package test:comp;\n\ntype x = string;\n\nrecord r {\n    a: s8,\n    b: u8,\n    c: x,\n    b: string,\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-resource-constructor-param.wac" {
  let source = [
    "package test:comp;\n\ninterface foo {\n    resource x {\n        constructor(a: u32, a: string);\n    }\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-resource-constructor.wac" {
  let source = [
    "package test:comp;\n\ninterface foo {\n    resource x {\n        constructor();\n        constructor(x: u",
    "32);\n    }\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-resource-method.wac" {
  let source = [
    "package test:comp;\n\nworld foo {\n    resource x {\n        x: func();\n        x: static func();\n    }\n",
    "}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-use-in-interface.wac" {
  let source = [
    "package foo:bar;\n\ninterface i {\n    type x = u32;\n}\n\ninterface i2 {\n    x: func();\n    use i.{x};\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-use-in-world.wac" {
  let source = [
    "package foo:bar;\n\ninterface i {\n    type x = u32;\n}\n\nworld w {\n    import x: func();\n    use i.{x};\n",
    "}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-variant-case.wac" {
  let source = [
    "package test:comp;\n\ntype x = string;\n\nvariant x {\n    a(x),\n    b,\n    a,\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-world-export.wac" {
  let source = [
    "package test:comp;\n\nworld w {\n    export x: func();\n    export x: func();\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/duplicate-world-import.wac" {
  let source = [
    "package test:comp;\n\nworld w {\n    import x: func();\n    import x: func();\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/expected-result-named.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/expected-result-scalar.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func();\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-conflict-alias.wac" {
  let source = [
    "package test:comp;\n\nimport f as \"x\": func();\n\ntype x = u32;\n\nexport f;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-conflict-interface.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\n\ninterface foo {\n\n}\n\nexport f as \"foo\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-conflict-type.wac" {
  let source = [
    "package test:comp;\n\nimport f as \"x\": func();\n\nrecord x {\n    a: u32\n}\n\nexport f as \"x\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-conflict-world.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\n\nworld foo {\n\n}\n\nexport f as \"foo\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-dep-name.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\nexport f as \"locked-dep=<foo:bar>\";",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-duplicate-name.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\nexport f as \"x\";\nexport f as \"x\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-hash-name.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\nexport f as \"integrity=<sha256-e3b0c44298fc1c149afbf4c8996fb92",
    "427ae41e4649b934ca495991b7852b855>\";",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-invalid-name.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\nexport f as \"INVALID!\";",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-needs-with.wac" {
  let source = ["package test:comp;\n\nlet i = new foo:bar {};\nexport i;\n"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/export-url-name.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\nexport f as \"url=<https://example.com/foo>\";",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/fill-not-last.wac" {
  let source = ["package test:comp;\n\nlet x = new foo:bar { ..., a };\n"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/func-results-not-present.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func();\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/func-results-present.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/import-duplicate-name.wac" {
  let source = [
    "package test:comp;\n\nimport x as \"foo\": func();\nimport y as \"foo\": interface {};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/import-id-span.wac" {
  let source = [
    "package test:comp;\n\nimport env-foo: wasi:cli/environment;\n\nimport env-bar: wasi:cli/environment;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/import-invalid-name.wac" {
  let source = [
    "package test:comp;\n\nimport x as \"NOT-VALID-NAME!\": func();\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/inaccessible.wac" {
  let source = ["package test:comp;\n\nimport f: func();\n\nlet x = f.foo;\n"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-alias.wac" {
  let source = ["package test:comp;\n\ninterface a {\n\n}\n\ntype x = a;"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-borrow.wac" {
  let source = ["package test:comp;\n\ntype x = u32;\n\ntype y = borrow<x>;"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-func-type-ref.wac" {
  let source = [
    "package test:comp;\n\ninterface i {\n    type x = u32;\n\n    x: x;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-use-alias.wac" {
  let source = [
    "package test:comp;\n\ninterface a {\n    type a = u32;\n}\n\ninterface b {\n    type b = u32;\n    use a.{a ",
    "as b};\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-use.wac" {
  let source = [
    "package test:comp;\n\ntype x = u32;\n\ninterface a {\n    use x.{a};\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-value-type.wac" {
  let source = [
    "package test:comp;\n\ninterface i {\n\n}\n\ntype x = func(i: i);",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-world-export.wac" {
  let source = [
    "package test:comp;\n\ntype x = u32;\n\nworld w {\n    import x: x;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-world-import.wac" {
  let source = [
    "package test:comp;\n\ntype x = u32;\n\nworld w {\n    import x: x;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-world-include.wac" {
  let source = [
    "package test:comp;\n\ntype x = func();\n\nworld w {\n    include x;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-world-interface-export.wac" {
  let source = [
    "package test:comp;\n\ntype x = u32;\n\nworld w {\n    export x;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/invalid-world-interface-import.wac" {
  let source = [
    "package test:comp;\n\ntype x = u32;\n\nworld w {\n    import x;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-async.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-enum-cases.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    enum e {\n        a,\n        c,\n        b,\n    }\n};\n\nle",
    "t i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-enum-count.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    enum e {\n        a,\n        b,\n        c,\n        d,\n ",
    "   }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-err-result-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> result<_, string>;\n};\n\nlet i = new foo:ba",
    "r { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-flags-count.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    flags f {\n        a,\n        b,\n        c,\n        d,\n",
    "    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-flags.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    flags f {\n        a,\n        c,\n        b,\n    }\n};\n\nl",
    "et i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-func-param-name.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func(b: u32);\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-func-param-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: string);\n};\n\nlet i = new fo",
    "o:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-func-params.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func();\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-func-scalar-result.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-kind.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    type x = u32;\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-list-element.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func(l: list<string>);\n};\n\nlet i = new foo:bar { x ",
    "};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-ok-result-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> result<string>;\n};\n\nlet i = new foo:bar {",
    " x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-option.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func(o: option<u8>);\n};\n\nlet i = new foo:bar { x };",
    "\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-record-field-count.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    record r {\n        a: u8,\n        b: u16,\n        c: u",
    "32,\n        d: u64,\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-record-field-name.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    record r {\n        a: u8,\n        c: u16,\n        b: u",
    "32,\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-record-field-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    record r {\n        a: u8,\n        b: string,\n        c",
    ": u32,\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-resource-types.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    resource x;\n    resource y;\n    f: func(x: y);\n};\n\nlet",
    " i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-tuple-size.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    type t = tuple<u8, string, tuple<u32>, u16>;\n};\n\nlet i",
    " = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-tuple-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    type t = tuple<u8, string, tuple<string>>;\n};\n\nlet i =",
    " new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-variant-case-count.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        b(u16),\n        c(tuple",
    "<string, u16>),\n        d,\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-variant-case-name.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        c(u16),\n        b(tuple",
    "<string, u16>),\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/mismatched-variant-case-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        b(u16),\n        c(tuple",
    "<string, string>),\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-access-export.wac" {
  let source = [
    "package test:comp;\n\nimport i: interface {\n\n};\n\nlet x = i.foo;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-constructor.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: r);\n};\n\nlet i = new foo:bar",
    " { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-err-result-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> result;\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-inst-arg.wac" {
  let source = ["package test:comp;\n\nlet x = new foo:bar {};\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-interface-export.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-method.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: r);\n};\n\nlet i = new foo:bar",
    " { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-ok-result-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> result<_>;\n};\n\nlet i = new foo:bar { x };",
    "\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-package-definition.wac" {
  let source = [
    "package test:comp;\n\ninterface i {\n    use foo:bar/nonexistent.{a};\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-static-method.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: r);\n};\n\nlet i = new foo:bar",
    " { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-target-export.wac" {
  let source = ["package test:comp targets foo:bar/baz;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-type-in-use.wac" {
  let source = [
    "package test:comp;\n\ninterface a {\n\n}\n\ninterface b {\n    use a.{x};\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/missing-world-include-name.wac" {
  let source = [
    "package test:comp;\n\nworld w1 {\n\n}\n\nworld w2 {\n    include w1 with { a as b };\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/no-err-result-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> result<_, string>;\n};\n\nlet i = new foo:ba",
    "r { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/no-import.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {};\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/no-ok-result-type.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    f: func() -> result<string>;\n};\n\nlet i = new foo:bar {",
    " x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/non-instance-spread.wac" {
  let source = [
    "package test:comp;\n\nimport f: func();\n\nlet x = new foo:bar { ...f };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/package-invalid-wasm.wac" {
  let source = ["package test:comp;\n\nimport foo: foo:bar/qux;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/package-not-component.wac" {
  let source = ["package test:comp;\n\nimport foo: foo:bar/qux;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/package-not-wasm.wac" {
  let source = ["package test:comp;\n\nimport foo: foo:bar/qux;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/redefined-name.wac" {
  let source = ["package test:comp;\n\ntype x = u32;\ntype x = string;"].join(
    "",
  )
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/self-instantiation.wac" {
  let source = ["package foo:bar;\n\nlet i = new foo:bar {};\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/spread-export-no-effect.wac" {
  let source = [
    "package test:comp;\n\nimport i: interface {};\n\nexport i...;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/spread-instantiation-no-match.wac" {
  let source = [
    "package test:comp;\n\nimport i: interface {\n};\n\nlet x = new foo:bar { ...i };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-export-mismatch.wac" {
  let source = [
    "package test:comp targets test:comp/world;\n\nworld %world {\n    import foo: interface {\n        foo: ",
    "func(x: u32);\n    };\n    export foo: interface {\n        foo: func(x: string);\n    };\n}\n\nimport foo:",
    " interface {\n    foo: func(x: u32);\n};\nexport foo;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-extraneous-import.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: func();\n}\n\nimport bar: func();",
    "\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-import-mismatch-resource.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        resource x",
    " {\n            constructor();\n        }\n    };\n}\n\nimport foo2 as foo: interface {\n    resource y {\n ",
    "       constructor();\n    }\n};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-import-mismatch.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: func();\n}\n\nimport foo2 as foo:",
    " interface {\n\n};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-import-param-name-mismatch.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        foo: func(",
    "a: string);\n    };\n}\n\nimport foo2 as foo: interface {\n    foo: func(x: u32);\n};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-import-param-type-mismatch.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        foo: func(",
    "a: u32);\n    };\n}\n\nimport foo2 as foo: interface {\n    foo: func(a: string);\n};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-import-unexpected-method.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        resource x",
    " {\n            constructor();\n        }\n    };\n}\n\nimport foo2 as foo: interface {\n    resource x {\n ",
    "       constructor();\n        f: func(a: u32);\n    }\n};\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/target-is-not-a-world.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\ninterface foo {   \n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/targets-interface-use.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\ninterface indirect-dependency {\n    variant my-variant {\n ",
    "       foo,\n        // Extra variant that the instance does not have\n        bar\n    }\n}\n\ninterface ",
    "direct-dependency {\n    use indirect-dependency.{my-variant};\n    \n    fun: func() -> my-variant;\n}\n",
    "\nworld foo {   \n    import direct-dependency;\n}\n\n\nlet i = new foo:bar { ... };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/targets-world-use.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\ninterface indirect-dependency {\n    // The resource is act",
    "ually named \"other-resource\" in the instance\n    resource my-resource {}\n}\n\nworld foo {   \n    use i",
    "ndirect-dependency.{my-resource};\n    import my-func: func() -> my-resource;\n}\n\nlet i = new foo:bar ",
    "{ ... };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/type-decl-conflict.wac" {
  let source = [
    "package test:comp;\n\nimport foo: func();\nexport foo as i;\n\ninterface i {\n\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/undefined-name.wac" {
  let source = ["package test:comp;\n\ntype x = x;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/unknown-package.wac" {
  let source = ["package test:comp;\n\nimport foo: bar:baz/qux;"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/unknown-target-path.wac" {
  let source = ["package test:comp targets foo:bar/baz;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/unknown-targets-path.wac" {
  let source = ["package test:comp targets test:comp/foo;\n"].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/variant-case-typed.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        b,\n        c(tuple<stri",
    "ng, u16>),\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/variant-case-untyped.wac" {
  let source = [
    "package test:comp;\n\nimport x: interface {\n    variant v {\n        a(string),\n        b(u16),\n       ",
    " c(tuple<string, u16>),\n    }\n};\n\nlet i = new foo:bar { x };\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/windows-file.wac" {
  let source = [
    "package foo:bar;\r\n\r\nimport x: func();\r\nimport x: func();\r\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/world-include-conflict.wac" {
  let source = [
    "package test:comp;\n\nworld w1 {\n    export a: func();\n}\n\nworld w2 {\n    include w1;\n    export a: int",
    "erface {\n\n    };\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/fail/world-include-with-conflict.wac" {
  let source = [
    "package test:comp;\n\nworld w1 {\n    export a: func();\n}\n\nworld w2 {\n    include w1 with { a as x };\n ",
    "   export x: interface {\n\n    };\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/import.wac" {
  let source = [
    "package test:comp@0.0.1-beta;\n\n/// Import by func type\nimport a: func();\n\n/// Import by ident\ntype x",
    " = func();\nimport b: x;\n\n/// Import by package path\n//import c: foo:bar/baz;\n\n/// Import by func typ",
    "e with kebab name \nimport d as \"hello-world\": func(name: string);\n\n/// Import by inline interface\nim",
    "port e: interface {\n    x: func();\n};\n\n/// Import by package path with version\nimport f: foo:bar/baz",
    ";\n\nexport d;\nexport e as \"e\";\nexport f;",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/let-statements.wac" {
  let source = [
    "package test:comp@1.0.0;\n\nimport streams: wasi:io/streams;\n\nlet i = new foo:bar { streams, baz: new ",
    "foo:bar { streams, ... }.baz };\n\nexport i.baz;\nexport i as \"i\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/no-imports.wac" {
  let source = [
    "package test:comp@0.3.0;\n\nlet i = new foo:bar {};\n\nexport i as \"i\";\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/package-import.wac" {
  let source = [
    "package test:comp@1.0.0;\n\nimport i: foo:bar/i;\n\nexport i;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/package-use-item.wac" {
  let source = [
    "package test:comp@0.0.1;\n\ninterface i {\n    use foo:bar/baz.{a, b, c};\n}\n\nworld w {\n    use foo:bar/",
    "qux.{x, y, z};\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/package-world-include.wac" {
  let source = [
    "package test:comp@1.2.3-prerelease;\n\nworld w {\n    include foo:bar/baz;\n}",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/package-world-item.wac" {
  let source = [
    "package test:comp;\n\nworld w {\n    import foo:bar/baz;\n    export bar:baz/qux;\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/resource.wac" {
  let source = [
    "package test:comp;\n\ninterface foo {\n    resource x;\n    type f = func(x: borrow<x>);\n    f2: f;\n\n   ",
    " type x2 = x;\n    f3: func(x: x, x2: x2, x3: borrow<x>, x4: borrow<x2>);\n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/targets-empty-world.wac" {
  let source = [
    "package test:comp targets test:comp/foo;\n\nworld foo {   \n}\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/targets-world.wac" {
  let source = [
    "package test:comp targets test:comp/world;\n\nworld %world {\n    import f: func();\n    export i: inter",
    "face {\n        f: func();\n    };\n}\n\nimport f: func();\n\nexport new foo:bar { f } as i;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/types.wac" {
  let source = [
    "package test:comp;\n\n/// Defining an interface\ninterface i {\n    /// Type alias a\n    type a = func()",
    ";\n    /// Record type\n    record r {\n        x: u32\n    }\n    /// Export func\n    x: func();\n    ///",
    " Export func of type a\n    y: a;\n}\n\n/// Defining a second interface\ninterface i2 {\n    /// Use type ",
    "r from i\n    use i.{r};\n\n    /// Use type r from i as z\n    use i.{r as z};\n}\n\ntype c = func();\ntype",
    " f = c;\n\n/// Defining a world\nworld w1 {\n    /// Use type r from foo:bar/i\n    use foo:bar/i.{r};\n\n ",
    "   /// Import a function\n    import a: func();\n    /// Import an interface\n    import i;\n    /// Imp",
    "ort by name with type `c`\n    import c: c;\n\n    /// Export an inline interface\n    export d: interfa",
    "ce {\n        x: func();\n    };\n    /// Export an interface\n    export i2;\n    /// Export by name wit",
    "h type `f`\n    export f: f;\n}\n\n/// Defining a second world\nworld w2 {\n    /// Include the first worl",
    "d\n    include w1;\n\n    /// Include a world by path\n    include foo:bar/baz;\n\n    /// Defining a reso",
    "urce\n\n    resource res {\n        constructor();\n    }\n}\n\ntype x = u32;\n\n/// Defining a variant\nvaria",
    "nt v {\n    a(x),\n    b(string),\n    c(u32),\n    d,\n}\n\n/// Defining a record\nrecord r {\n    x: u32,\n ",
    "   y: string,\n    z: v,\n}\n\n/// Defining flags\nflags %flags {\n    a,\n    b,\n    c,\n}\n\n/// Defining an",
    " enum\nenum e {\n    a,\n    b,\n    c,\n}\n\n/// Type aliases\ntype t = e;\ntype t2 = string;\ntype t3 = func",
    "(a: u32, b: r) -> u32;\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WAC syntax resolution/wasip3-types.wac" {
  let source = [
    "package test:comp;\n\n// wasip3 value types: stream, future, error-context\ntype stream1 = stream;\ntype",
    " stream2 = stream<u32>;\ntype stream3 = stream<list<string>>;\n\ntype future1 = future;\ntype future2 = ",
    "future<u32>;\ntype future3 = future<option<string>>;\n\ntype ec = error-context;\n\n// async function typ",
    "es\ntype async-fn = async func() -> string;\ntype async-fn-with-stream = async func(data: list<u8>) ->",
    " stream<u8>;\ntype sync-fn = func() -> string;\n\n/// Interface mixing async and sync functions and was",
    "ip3 types\ninterface async-iface {\n    process: async func(input: list<u8>) -> stream<u8>;\n    get-re",
    "sult: async func() -> future<string>;\n    sync-op: func(x: u32) -> u32;\n    type my-stream = stream<",
    "u32>;\n    type my-future = future<string>;\n    type my-ec = error-context;\n}\n\n/// World with async i",
    "mports and exports\nworld async-world {\n    import run: async func() -> string;\n    import fetch: asy",
    "nc func(url: string) -> stream<u8>;\n    export process: async func(data: list<u8>) -> future<u32>;\n}",
    "\n",
  ].join("")
  let result = @parser.parse(source)
  if result.is_valid() != true {
    fail(@debug.to_string(result.diagnostics.clamped_view(end=4)))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}
