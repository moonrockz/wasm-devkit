///|
fn verify(
  source : String,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(@parser.parse(source), source_id="api.wit", source~)
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
  assert_eq(model.text(), source)
  assert_true(model.ast().equivalent(@parser.parse(source).ast))
  assert_eq(model.declarations().length(), 3)
  let copy = model
    .declarations()
    .map(binding => { ..binding, name: "changed", })
  assert_eq(copy[0].name, "changed")
  assert_eq(model.declarations()[0].name, "b")
}

///|
test "duplicates link their original declaration and Unicode offsets are UTF16" {
  let source = "// 😀\npackage example:app; interface api { type a = u8; type a = u16; }"
  guard verify(source) is Err(errors) else { fail("duplicate accepted") }
  assert_eq(errors[0].code, "WIT-S004")
  assert_eq(errors[0].related.length(), 1)
  assert_eq(errors[0].related[0].location.source, "api.wit")
  assert_eq(errors[0].primary.location.span.start, 56)
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
      "package example:app; interface api { type a = list<u8>; }", "world app {}",
      "package example:app; interface api { type a = ; }",
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
