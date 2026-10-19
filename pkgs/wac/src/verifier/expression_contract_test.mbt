///|
test "deep groups followed by access preserve nominal resource identity" {
  let source = StringBuilder()
  source.write_string(
    "package test:app; interface api {resource handle;} import i: api; let alias = ",
  )
  for _ in 0..<5000 {
    source.write_string("(")
  }
  source.write_string("i")
  for _ in 0..<5000 {
    source.write_string(")")
  }
  source.write_string(".handle; export alias as handle;")
  let source = source.to_string()
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  guard model.imports()[0].kind is Instance(ty) &&
    model.types()[ty].kind is Interface(_, _, [item]) else {
    fail("missing instance")
  }
  guard item.kind is Type(resource) &&
    model.exports()[1].kind is Type(resource_alias) else {
    fail("missing resource export")
  }
  assert_eq(
    model.resource_identity(resource_alias),
    model.resource_identity(resource),
  )
  assert_eq(resource_alias, resource)
  let changed = model.exports().map(item => { ..item, name: "changed", })
  assert_eq(changed[1].name, "changed")
  assert_eq(model.exports()[1].name, "handle")
}

///|
test "access diagnostics retain root spans and binary type provenance" {
  let source = "// 😀\npackage test:app; import i: lookup:nested/container; export i.missing;"
  let parsed = @parser.parse(source)
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ]
  let result = @verifier.verify(
    parsed,
    source~,
    source_id="root.wac",
    dependencies~,
  )
  guard result is Err(errors) else { fail("accepted missing export") }
  assert_eq(errors[0].code, "WAC-C002")
  assert_eq(errors[0].primary.location.source, "root.wac")
  assert_true(errors[0].primary.location.span().unwrap().start > 60)
  assert_eq(errors[0].related[0].location.source, "nested.wasm")
  assert_true(errors[0].related[0].location.position is BinaryOffset(_))
  guard @verifier.verify(parsed, source~, source_id="root.wac", dependencies~)
    is Err(again) else {
    fail("nondeterministic access")
  }
  assert_eq(errors, again)
}
