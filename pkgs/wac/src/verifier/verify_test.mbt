///|
fn verify(
  source : String,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(@parser.parse(source), source_id="app.wac", source~)
}

///|
test "ordered WAC declarations preserve runtime imports" {
  let source = "package example:app; import greet: func(name: string) -> string; let run = greet; export run as \"run\";"
  guard verify(source) is Ok(model) else { fail("valid composition rejected") }
  assert_eq(model.source(), "app.wac")
  assert_eq(model.text(), source)
  assert_true(model.ast().equivalent(@parser.parse(source).ast))
  assert_eq(model.declarations().length(), 4)
  let copy = model.declarations().map(b => { ..b, name: "changed", })
  assert_eq(copy[0].name, "changed")
  assert_eq(model.declarations()[0].name, "greet")
  let source = "package example:app; let run = greet; import greet: func(name: string) -> string; export run as \"run\";"
  assert_true(@parser.parse(source).is_valid())
  guard verify(source) is Err(errors) else {
    fail("use before declaration accepted")
  }
  assert_eq(errors[0].code, "WAC-S005")
}

///|
test "duplicates types parameters and export names are checked" {
  for
    source in [
      "package example:app; type t = missing;", "package example:app; type t = u8; type t = u16;",
      "package example:app; import f: func(a: u8, a: u8);", "package example:app; import f: func(); export f as \"x\"; export f as \"x\";",
      "package example:app; type t = u8; let x = t;", "package example:app; import f: func(); type t = f;",
    ] {
    assert_true(@parser.parse(source).is_valid())
    assert_true(verify(source) is Err(_))
  }
  assert_true(verify("package example:app; type a = u8; type b = a;") is Ok(_))
  assert_true(verify("package example:app; type a = b; type b = u8;") is Err(_))
}

///|
test "source qualified deterministic diagnostics retain related labels" {
  let source = "// 😀\npackage example:app; type a = u8; type a = u16;"
  guard verify(source) is Err(errors) else { fail("duplicate accepted") }
  assert_eq(errors[0].code, "WAC-S004")
  assert_eq(errors[0].related.length(), 1)
  assert_eq(errors[0].primary.location.source, "app.wac")
  assert_eq(errors[0].related[0].location.source, "app.wac")
  assert_true(errors[0].render().contains("app.wac:"))
  assert_true(verify(source) is Err(again) && again == errors)
}

///|
test "unsupported input recovery and malformed caller trees cannot yield models" {
  for
    source in [
      "package a:b; let x = new a:b {...};", "package a:b; type a = list<u8>;", "package a:b; let x = ;",
    ] {
    assert_true(verify(source) is Err(_))
  }
  let span : @span.Span = { start: 0, end: 0, }
  let malformed : @ast.Tree = {
    nodes: [{ data: File(directive=None, statements=[99]), span, }],
  }
  assert_true(@verifier.verify_ast(malformed, source="") is Err(_))
  let wrong_role : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="u8"), span, },
      { data: File(directive=Some(0), statements=[]), span, },
    ],
  }
  assert_true(wrong_role.validate())
  assert_true(@verifier.verify_ast(wrong_role, source="") is Err(_))
  assert_true(
    @verifier.verify_ast(@parser.parse("package a:b;").ast, source="") is Err(_),
  )
}

///|
test "long ordered alias chains are stack safe" {
  let source = StringBuilder()
  source.write_string("package example:app; type a0 = u8;")
  for i in 1..<5000 {
    source.write_string("type a\{i} = a\{i-1};")
  }
  assert_true(verify(source.to_string()) is Ok(_))
}
