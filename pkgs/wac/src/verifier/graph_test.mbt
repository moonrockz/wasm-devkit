///|
fn named_type(model : @verifier.Verified, name : String) -> Int32 raise {
  for ty in model.types() {
    if ty.name == Some(name) {
      return ty.id
    }
  }
  fail("missing type " + name)
}

///|
test "nominal resources retain aliases uses constructors and receivers" {
  let source = "package example:app; interface api { resource r { constructor(x: u32); get: func() -> r; make: static func() -> r; } resource s; type handle = r; } interface consumer { use api.{handle as input}; f: func(x: borrow<input>) -> input; }"
  let model = verify(source).unwrap()
  let r = named_type(model, "r")
  let s = named_type(model, "s")
  let handle = named_type(model, "handle")
  assert_eq(model.resource_identity(r), Some(r))
  assert_eq(model.resource_identity(handle), Some(r))
  assert_eq(model.resource_identity(s), Some(s))
  assert_true(r != s)
  assert_eq(model.resource_identity(-1), None)
  assert_eq(model.resource_identity(model.types().length()), None)
  guard model.types()[named_type(model, "api")].kind
    is Interface(Some("example:app/api"), [], exports) else {
    fail("missing interface")
  }
  assert_eq(exports.map(item => item.name), [
    "r", "[constructor]r", "[method]r.get", "[static]r.make", "s", "handle",
  ])
  guard exports[1].kind is Function(ctor) &&
    model.types()[ctor].kind is Function(params, Some(result), false) else {
    fail("missing constructor")
  }
  assert_eq(params.map(p => p.name), ["x"])
  assert_eq(model.types()[result].kind, Own(r))
  guard exports[2].kind is Function(method_ty) &&
    model.types()[method_ty].kind is Function(params, Some(result), false) else {
    fail("missing method")
  }
  assert_eq(params.map(p => p.name), ["self"])
  assert_eq(model.types()[params[0].ty].kind, Borrow(r))
  assert_eq(model.types()[result].kind, Own(r))
  guard exports[3].kind is Function(static_ty) &&
    model.types()[static_ty].kind is Function([], Some(_), false) else {
    fail("static acquired receiver")
  }
  let consumer = named_type(model, "consumer")
  guard model.types()[consumer].kind is Interface(_, [used], [input, function]) else {
    fail("missing use")
  }
  assert_eq(used.name, "input")
  assert_eq(used.original_name, "handle")
  assert_eq(used.ty, handle)
  assert_eq(input.kind, Type(handle))
  guard function.kind is Function(id) &&
    model.types()[id].kind is Function([parameter], Some(result), false) else {
    fail("missing consumer function")
  }
  assert_eq(model.types()[parameter.ty].kind, Borrow(handle))
  assert_eq(model.types()[result].kind, Own(handle))
  for ty in model.types() {
    assert_eq(ty.location.source, "app.wac")
    assert_true(
      ty.location.span().unwrap().start >= 0 &&
      ty.location.span().unwrap().end <= source.length(),
    )
  }
}

///|
test "world includes retain order and rename imports before exports" {
  let model = verify(
    "package example:app@1.2.3; interface api {} world base { import api; import same: func(); export same: func(); } world app { include base with {same as changed}; export own: func(); }",
  ).unwrap()
  guard model.types()[named_type(model, "app")].kind
    is World(_, _, imports, exports) else {
    fail("missing world")
  }
  assert_eq(imports.map(item => item.name), ["example:app/api@1.2.3", "changed"])
  assert_eq(exports.map(item => item.name), ["own", "same"])
}

///|
test "world include conflict reports explicit declaration first" {
  let source = "package example:app; world base { import f: func(); } world app { include base; import f: func(x: u8); }"
  guard verify(source) is Err([error]) else {
    fail("conflicting include accepted")
  }
  assert_eq(error.code, "WAC-S004")
  assert_eq(error.related.length(), 1)
  assert_true(
    error.primary.location.span().unwrap().start <
    error.related[0].location.span().unwrap().start,
  )
  assert_true(
    error.related[0].location.span().unwrap().start >
    source.find("include").unwrap(),
  )
}

///|
test "imports promote type kinds and infer instance identities" {
  let model = verify(
    "package example:app; interface api {} world app {} type f = func(); type v = u8; import a: api; import b: a; import c: app; import d: c; import e: f; import value: v; export a;",
  ).unwrap()
  assert_eq(model.imports().map(item => item.name), [
    "a", "example:app/api", "c", "example:app/app", "e", "value",
  ])
  assert_eq(model.imports()[0].kind, Instance(named_type(model, "api")))
  assert_eq(model.imports()[1].kind, model.imports()[0].kind)
  assert_eq(model.imports()[2].kind, Component(named_type(model, "app")))
  assert_eq(model.imports()[4].kind, Function(named_type(model, "f")))
  assert_eq(model.imports()[5].kind, Type(named_type(model, "v")))
  assert_eq(model.exports().map(item => item.name), [
    "api", "app", "f", "v", "example:app/api",
  ])
}

///|
test "verified graphs are immutable and deterministic" {
  let source = "package example:app; record rec { value: u32 } interface api { resource r; f: func(x: r); } world app { import api; }"
  let first = verify(source).unwrap()
  let second = verify(source).unwrap()
  assert_eq(first.types(), second.types())
  assert_eq(first.items(), second.items())
  assert_eq(first.imports(), second.imports())
  assert_eq(first.exports(), second.exports())
  let copy = first.types().map(ty => { ..ty, name: Some("changed"), })
  assert_eq(copy[0].name, Some("changed"))
  assert_true(first.types()[0].name != Some("changed"))
  guard first.types()[named_type(first, "api")].kind is Interface(_, _, exports) else {
    fail("missing interface")
  }
  let copy = exports.map(item => { ..item, name: "changed", })
  assert_eq(copy[0].name, "changed")
  assert_eq(exports[0].name, "r")
}

///|
test "deep composites borrowed results and world include chains are iterative" {
  for borrowed in [false, true] {
    let source = StringBuilder()
    source.write_string(
      "package example:app; interface api { resource r; type t = ",
    )
    for _ in 0..<3000 {
      source.write_string("list<")
    }
    source.write_string(if borrowed { "borrow<r>" } else { "u8" })
    for _ in 0..<3000 {
      source.write_string(">")
    }
    source.write_string("; f: func() -> t; }")
    assert_eq(verify(source.to_string()) is Ok(_), !borrowed)
  }
  let source = StringBuilder()
  source.write_string(
    "package example:app; interface api {} world w0 { import api; }",
  )
  for i in 1..<2000 {
    source.write_string("world w\{i} { include w\{i-1}; }")
  }
  let model = verify(source.to_string()).unwrap()
  guard model.types()[named_type(model, "w1999")].kind
    is World(_, _, [item], []) else {
    fail("include lost item")
  }
  assert_eq(item.name, "example:app/api")
}

///|
test "borrow result restrictions cover aliases and aggregate payloads" {
  for
    declaration in [
      "type t = tuple<u8, option<borrow<r>>>;", "type a = borrow<r>; type t = result<u8, a>;",
      "record t { x: future<borrow<r>> }", "variant t { empty, some(stream<borrow<r>>) }",
    ] {
    let source = "package example:app; interface api { resource r; " +
      declaration +
      " f: func() -> t; }"
    guard verify(source) is Err([error]) else {
      fail("borrow escaped through " + declaration)
    }
    assert_eq(error.code, "WAC-S006")
  }
}

///|
test "named results stay explicitly outside the pinned semantic profile" {
  let source = "package example:app; import f: func() -> (x: u8);"
  let parsed = @parser.parse(source, features=@parser.Features::all())
  assert_true(parsed.is_valid())
  guard @verifier.verify(parsed, source~) is Err([error]) else {
    fail("named results accepted")
  }
  assert_eq(error.code, "WAC-S003")
}

///|
test "import-only names cannot be inferred as exports" {
  assert_true(
    verify(
      "package example:app; import f as \"url=<https://example.com>\": func(); export f;",
    )
    is Err(_),
  )
}

///|
test "binary and text diagnostic positions remain distinct" {
  let source = @verifier.Location::text("root.wac", { start: 2, end: 5, })
  let binary = @verifier.Location::binary("dep.wasm", offset=Some(7))
  let unknown = @verifier.Location::binary("unknown.wasm")
  assert_eq(source.span(), Some({ start: 2, end: 5, }))
  assert_eq(binary.span(), None)
  assert_eq(unknown.span(), None)
  let diagnostic : @verifier.Diagnostic = {
    code: "WAC-B001",
    message: "invalid package",
    primary: { location: binary, message: "invalid package", },
    related: [
      { location: source, message: "requested here", },
      { location: unknown, message: "another dependency", },
    ],
  }
  assert_eq(
    diagnostic.render(),
    "dep.wasm:[byte 7]: error WAC-B001: invalid package\nroot.wac:[2,5): requested here\nunknown.wasm:[binary]: another dependency\n",
  )
}
