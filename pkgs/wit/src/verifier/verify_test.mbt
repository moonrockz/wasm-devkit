///|
fn verify(
  source : String,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(
    @parser.parse(source, features=@parser.Features::reference()),
    source_id="api.wit",
    source~,
  )
}

///|
test "syntax validity does not imply semantic validity" {
  let source = "package example:invalid; interface api { type item = missing; get: func() -> item; }"
  assert_true(@parser.parse(source).is_valid())
  guard verify(source) is Err(errors) else { fail("expected semantic failure") }
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].code, "WIT-S005")
  assert_eq(errors[0].primary.location.source, "api.wit")
}

///|
test "WIT forward aliases and functions produce immutable resolved bindings" {
  let source = "package example:app; interface api { type a = b; type b = u8; run: func(value: a) -> b; }"
  guard verify(source) is Ok(model) else {
    fail("valid forward references rejected")
  }
  assert_eq(model.source(), "api.wit")
  assert_eq(model.identity().namespace_name, "example")
  assert_eq(model.identity().name, "app")
  assert_eq(model.text(), source)
  assert_true(model.ast().equivalent(@parser.parse(source).ast))
  assert_eq(model.declarations().filter(b => b.node != b.target).length(), 3)
  let copy = model
    .declarations()
    .map(binding => { ..binding, name: "changed", })
  assert_eq(copy[0].name, "changed")
  assert_eq(model.declarations()[0].name, "a")
}

///|
test "duplicates link their original declaration and Unicode offsets are UTF16" {
  let source = "// 😀\npackage example:app; interface api { type a = u8; type a = u16; }"
  guard verify(source) is Err(errors) else { fail("duplicate accepted") }
  assert_eq(errors[0].code, "WIT-S004")
  assert_eq(errors[0].related.length(), 1)
  assert_eq(errors[0].related[0].location.source, "api.wit")
  assert_eq(errors[0].primary.location.span().unwrap().start, 56)
  assert_true(errors[0].render().contains("api.wit:[56,"))
  assert_true(verify(source) is Err(again) && again == errors)
}

///|
test "cyclic aliases non-types and duplicate parameters cannot verify" {
  for
    source in [
      "package example:app; interface api { type a = b; type b = a; }", "package example:app; interface api { type a = run; run: func(); }",
      "package example:app; interface api { run: func(a: u8, a: u8); }",
    ] {
    assert_true(@parser.parse(source).is_valid())
    assert_true(verify(source) is Err(_))
  }
}

///|
test "unsupported semantics syntax recovery and malformed ASTs fail closed" {
  for
    source in [
      "package example:app; interface api { @since(version = 1.0.0) resource r; }",
      "world app {}", "package example:app; interface api { type a = ; }",
    ] {
    assert_true(verify(source) is Err(_))
  }
  let span : @span.Span = { start: 0, end: 0, }
  let malformed : @ast.Tree = { nodes: [{ data: File(items=[999]), span, }], }
  assert_true(@verifier.verify_ast(malformed, source="") is Err(_))
  let wrong_role : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="u8"), span, },
      { data: File(items=[0]), span, },
    ],
  }
  assert_true(wrong_role.validate())
  assert_true(@verifier.verify_ast(wrong_role, source="") is Err(_))
  let out_of_bounds = @parser.parse("package example:app; interface api {}").ast
  assert_true(@verifier.verify_ast(out_of_bounds, source="") is Err(_))
}

///|
test "long alias chains and cycles use bounded explicit work stacks" {
  let source = StringBuilder()
  source.write_string("package example:app; interface api {")
  for i in 0..<5000 {
    source.write_string("type a\{i} = a\{i+1};")
  }
  source.write_string("type a5000 = u8;}")
  assert_true(verify(source.to_string()) is Ok(_))
  let cyclic = source
    .to_string()
    .replace(old="type a5000 = u8;", new="type a5000 = a0;")
  assert_true(verify(cyclic) is Err(_))
}

///|
test "complete verification requires exactly one leading package header" {
  for
    source in [
      "interface api {}", "package a:b; package a:b; interface api {}", "interface api {} package a:b;",
    ] {
    assert_true(verify(source) is Err(_))
  }
}

///|
test "aggregate types resolve forward references into an immutable type graph" {
  let source = "package example:app; interface api { record item { value: scalar, other: option<scalar> } type scalar = u32; flags mode { read, write } enum color { red, blue } variant value { number(item), none } type output = result<tuple<item, color>, string>; }"
  guard verify(source) is Ok(model) else {
    fail("valid aggregate graph rejected")
  }
  let types = model.types()
  assert_true(types.any(t => t.kind is Record(_)))
  assert_true(types.any(t => t.kind is Variant(_)))
  assert_true(types.any(t => t.kind is Flags(_)))
  assert_true(types.any(t => t.kind is Enum(_)))
  let ids = types.map(t => t.id)
  for ty in types {
    assert_eq(ty.location.source, "api.wit")
    match ty.kind {
      Alias(target) => assert_true(ids.contains(target))
      Record(fields) =>
        for field in fields {
          assert_true(ids.contains(field.ty))
        }
      _ => ()
    }
  }
  let changed = types.map(t => { ..t, name: Some("changed"), })
  assert_eq(changed[0].name, Some("changed"))
  assert_false(model.types()[0].name == Some("changed"))
  assert_true(
    verify(
      "package example:app; world app { type a = b; type b = u8; record rec { f: a } }",
    )
    is Ok(_),
  )
}

///|
test "aggregate invariants and cycles reject syntax valid models" {
  for
    body in [
      "record r {}", "flags f {}", "enum e {}", "variant v {}", "type t = tuple<>;",
      "record r { a: u8, a: u16 }", "flags f { a, a }", "enum e { a, a }", "variant v { a, a(u8) }",
      "type t = list<t>;", "record r { next: option<r> }", "variant v { again(v) }",
      "type a = list<b>; record b { value: result<a> }",
    ] {
    let source = "package example:app; interface api { " + body + " }"
    assert_true(@parser.parse(source).is_valid())
    assert_true(verify(source) is Err(_))
  }
  guard verify("package example:app; interface api { record r { child: r } }")
    is Err(errors) else {
    fail("cycle accepted")
  }
  assert_eq(errors[0].code, "WIT-S006")
  assert_false(errors[0].related.is_empty())
  let flags = StringBuilder()
  flags.write_string("package example:app; interface api { flags f {")
  for i in 0..<33 {
    flags.write_string("a\{i},")
  }
  flags.write_string("} }")
  assert_true(verify(flags.to_string()) is Err(_))
}

///|
test "map and fixed list edges follow pinned resolver categories and u32 bounds" {
  for
    body in [
      "type t = map<string, u8>;", "type t = map<s64, tuple<u8, string>>;", "type t = list<u8, 0>;",
      "type t = list<u8, 4294967295>;", "type t = list<u8, 001>;", "type t = future<u8>;",
      "type t = stream;", "type t = error-context;",
    ] {
    assert_true(
      verify("package example:app; interface api { " + body + " }") is Ok(_),
    )
  }
  for
    body in [
      "type t = map<f32, u8>;", "type key = string; type t = map<key, u8>;", "enum key { a } type t = map<key, u8>;",
      "type t = list<u8, 4294967296>;",
    ] {
    let source = "package example:app; interface api { " + body + " }"
    assert_true(
      @parser.parse(source, features=@parser.Features::reference()).is_valid(),
    )
    assert_true(verify(source) is Err(_))
  }
}

///|
test "wrong type namespaces include their non-type declaration" {
  guard verify(
      "package example:app; interface api { type t = run; run: func(); }",
    )
    is Err(errors) else {
    fail("non-type accepted")
  }
  assert_eq(errors[0].code, "WIT-S008")
  assert_eq(errors[0].related.length(), 1)
}

///|
test "deep composite types and wide graphs remain stack safe and deterministic" {
  let source = StringBuilder()
  source.write_string("package example:app; interface api { type deep = ")
  for _ in 0..<10000 {
    source.write_string("list<")
  }
  source.write_string("u8")
  for _ in 0..<10000 {
    source.write_string(">")
  }
  source.write_string("; record wide {")
  for i in 0..<1000 {
    source.write_string("field\{i}: deep,")
  }
  source.write_string("} }")
  let text = source.to_string()
  let model = match verify(text) {
    Ok(model) => model
    Err(errors) => fail(errors[0].render())
  }
  assert_true(model.types().length() > 10000)
  assert_true(verify(text) is Ok(again) && again.types() == model.types())
  assert_eq(model.text(), text)
}

///|
test "law: arbitrary source verification is total deterministic and source qualified" {
  @quickcheck.check(
    (text : String) => {
      match (verify(text), verify(text)) {
        (Ok(a), Ok(b)) => a.types() == b.types() && a.ast() == b.ast()
        (Err(a), Err(b)) =>
          a == b && a.all(d => d.primary.location.source == "api.wit")
        _ => false
      }
    },
    count=500,
    max_size=256,
    seed=20261018,
  )
}

///|
test "law: generated valid acyclic type graphs retain every resolved edge" {
  @quickcheck.check(
    (picks : Array[Byte]) => {
      let source = StringBuilder()
      source.write_string("package example:app; interface api { type t0 = u8;")
      for i, pick in picks {
        let name = "t\{i+1}"
        let dependency = "t\{pick.to_int() % (i+1)}"
        let ty = match pick.to_int() % 4 {
          0 => dependency
          1 => "list<" + dependency + ">"
          2 => "tuple<" + dependency + ", u8>"
          _ => "result<" + dependency + ", string>"
        }
        source.write_string("type " + name + " = " + ty + ";")
      }
      source.write_string("}")
      let source = source.to_string()
      guard verify(source) is Ok(model) else { return false }
      let types = model.types()
      let ids = types.map(t => t.id)
      types.all(t => {
        match t.kind {
          Alias(id) | List(id, _) | Option(id) => ids.contains(id)
          Tuple(elements) => elements.all(id => ids.contains(id))
          Result(ok, error) =>
            (ok is None || (ok is Some(id) && ids.contains(id))) &&
            (error is None || (error is Some(id) && ids.contains(id)))
          _ => true
        }
      }) &&
      model.text() == source
    },
    count=200,
    max_size=128,
    seed=2620,
  )
}

///|
test "opaque resource aliases retain nominal identities and forward references" {
  let source = "package example:app; interface api { type alias = first; resource first; resource second; }"
  guard verify(source) is Ok(model) else {
    fail("opaque resource aliases rejected")
  }
  let resources = model.types().filter(t => t.kind is Resource)
  assert_eq(resources.length(), 2)
  assert_false(resources[0].id == resources[1].id)
  assert_eq(resources[0].name, Some("first"))
  let reference = model
    .declarations()
    .filter(b => b.name == "first" && b.node != b.target)
  assert_eq(reference.length(), 1)
  assert_eq(reference[0].target, resources[0].id)
}

///|
test "strong local name uniqueness folds kebab casing while type lookup preserves spelling" {
  for
    body in [
      "record r{a:u8,A:u8}", "flags f{a,A}", "enum e{a,A}", "variant v{a,A}", "f:func(a:u8,A:u8);",
      "type a=u8;type A=u16;", "f:func();F:func();", "type a=u8;A:func();",
    ] {
    let text = "package example:app;interface api{" + body + "}"
    assert_true(
      @parser.parse(text, features=@parser.Features::reference()).is_valid(),
    )
    assert_true(
      verify(text) is Err(errors) &&
      errors.any(d => d.code == "WIT-S004" && !d.related.is_empty()),
    )
  }
  assert_true(
    verify("package example:app;interface api{type a=u8;f:func(x:A);}")
    is Err(errors) &&
    errors[0].code == "WIT-S005",
  )
  assert_true(
    verify(
      "package example:app;interface api{}interface API{}use api as other;use API as OTHER;",
    )
    is Ok(_),
  )
}

///|
test "strong local names remove hyphens without changing lookup or package globals" {
  for
    body in [
      "record r{a-b:u8,ab:u8}", "flags f{a-b,AB}", "enum e{ab,a-b}", "variant v{a-b,ab}",
      "f:func(a-b:u8,ab:u8);", "type a-b=u8;type ab=u16;", "a-b:func();AB:func();",
      "type a-b=u8;ab:func();",
    ] {
    let text = "package example:app;interface api{" + body + "}"
    assert_true(
      @parser.parse(text, features=@parser.Features::reference()).is_valid(),
    )
    assert_true(
      verify(text) is Err(errors) && errors.any(d => d.code == "WIT-S004"),
    )
  }
  assert_true(
    verify("package example:app;interface api{type a-b=u8;f:func(x:ab);}")
    is Err(errors) &&
    errors[0].code == "WIT-S005",
  )
  assert_true(
    verify(
      "package example:app;interface a-b{}interface ab{}use a-b as c-d;use ab as cd;",
    )
    is Ok(_),
  )
}
