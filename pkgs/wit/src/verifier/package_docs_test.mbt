///|
test "package documentation line" {
  let documents : ReadOnlyArray[@verifier.Document] = [
    section_document("0.wit", "// A\npackage example:docs;"),
    section_document("1.wit", "// B\npackage example:docs;"),
  ]
  let result = @verifier.resolve({ documents, })
  assert_eq(result is Ok(_), false)
  guard result is Err(errors) else { fail("accepted duplicate docs") }
  assert_eq(errors[0].code, "WIT-S011")
  assert_eq(errors[0].primary.location.source, "1.wit")
  assert_eq(errors[0].related[0].location.source, "0.wit")
}

///|
test "package documentation block" {
  let documents : ReadOnlyArray[@verifier.Document] = [
    section_document("0.wit", "/* A */package example:docs;"),
    section_document("1.wit", "/* B */package example:docs;"),
  ]
  let result = @verifier.resolve({ documents, })
  assert_eq(result is Ok(_), false)
  guard result is Err(errors) else { fail("accepted duplicate docs") }
  assert_eq(errors[0].code, "WIT-S011")
  assert_eq(errors[0].primary.location.source, "1.wit")
  assert_eq(errors[0].related[0].location.source, "0.wit")
}

///|
test "package documentation empty" {
  let documents : ReadOnlyArray[@verifier.Document] = [
    section_document("0.wit", "///\npackage example:docs;"),
    section_document("1.wit", "///\npackage example:docs;"),
  ]
  let result = @verifier.resolve({ documents, })
  assert_eq(result is Ok(_), false)
  guard result is Err(errors) else { fail("accepted duplicate docs") }
  assert_eq(errors[0].code, "WIT-S011")
  assert_eq(errors[0].primary.location.source, "1.wit")
  assert_eq(errors[0].related[0].location.source, "0.wit")
}

///|
test "package documentation single" {
  let documents : ReadOnlyArray[@verifier.Document] = [
    section_document("0.wit", "/// A\npackage example:docs;"),
    section_document("1.wit", "package example:docs;"),
  ]
  let result = @verifier.resolve({ documents, })
  assert_eq(result is Ok(_), true)
}

///|
test "package documentation headerless" {
  let documents : ReadOnlyArray[@verifier.Document] = [
    section_document("0.wit", "/// A\npackage example:docs;"),
    section_document("1.wit", "interface api {}"),
  ]
  let result = @verifier.resolve({ documents, })
  assert_eq(result is Ok(_), true)
}

///|
test "package documentation late" {
  let documents : ReadOnlyArray[@verifier.Document] = [
    section_document("0.wit", "package example:docs;interface api {}\n"),
    section_document("1.wit", "/// B\npackage example:docs;"),
  ]
  let result = @verifier.resolve({ documents, })
  assert_eq(result is Ok(_), true)
}
