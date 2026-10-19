///|
test "package requests retain first key order and last requesting location" {
  let source = "package test:app targets target:pkg/world; import a: first:pkg/api; interface local { use second:pkg/api@1.2.3.{item}; } import b: first:pkg/other;"
  let result = @verifier.package_requests(
    @parser.parse(source),
    source~,
    source_id="root.wac",
  )
  guard result is Ok(requests) else { fail("request discovery failed") }
  assert_eq(requests.map(request => request.name), [
    "target:pkg", "first:pkg", "second:pkg",
  ])
  assert_eq(requests[2].version, Some("1.2.3"))
  assert_eq(requests[0].location.source, "root.wac")
  assert_true(
    requests[1].location.span().unwrap().start >
    requests[2].location.span().unwrap().start,
  )
  let span = requests[1].location.span().unwrap()
  assert_eq(source[span.start:span.end].to_owned(), "first:pkg/other")
}

///|
test "local package paths never request bytes and nested self instantiation fails" {
  let source = "package test:app; interface local {} import x: test:app/local@9.9.9;"
  assert_eq(
    @verifier.package_requests(@parser.parse(source), source~).unwrap().length(),
    0,
  )
  let source = "package test:app; let x = new other:pkg { arg: new test:app@1.0.0 {} };"
  let result = @verifier.package_requests(@parser.parse(source), source~)
  guard result is Err(errors) else {
    fail("accepted nested self instantiation")
  }
  assert_eq(errors[0].code, "WAC-P005")
}

///|
test "request discovery validates syntax identity and source bounds" {
  for source in ["package test:app; import x: ;", "package test:app@01.0.0;"] {
    assert_true(
      @verifier.package_requests(@parser.parse(source), source~) is Err(_),
    )
  }
  assert_true(
    @verifier.package_requests(@parser.parse("package test:app;"), source="")
    is Err(_),
  )
}

///|
test "request discovery uses a stack for nested instantiation" {
  let source = StringBuilder()
  source.write_string("package test:app; let x = ")
  for _ in 0..<2000 {
    source.write_string("new dep:pkg { arg: ")
  }
  source.write_string("new test:app {}")
  for _ in 0..<2000 {
    source.write_string(" }")
  }
  source.write_string(";")
  let source = source.to_string()
  let result = @verifier.package_requests(@parser.parse(source), source~)
  guard result is Err(errors) else {
    fail("accepted deeply nested self instantiation")
  }
  assert_eq(errors[0].code, "WAC-P005")
}
