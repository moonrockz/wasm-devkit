///|
test "target checking uses stacks for deep function value types" {
  let text = StringBuilder()
  text.write_string("package test:app targets test:app/w;")
  for name in ["required", "provided"] {
    text.write_string("interface " + name + " {f: func(x: ")
    for _ in 0..<3000 {
      text.write_string("list<")
    }
    text.write_string("u32")
    for _ in 0..<3000 {
      text.write_string(">")
    }
    text.write_string(");}")
  }
  text.write_string(
    "world w {import i: required;export out: required;} import i as i: provided;export i as out;",
  )
  let source = text.to_string()
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  let changed = model
    .composition_exports()
    .map(item => { ..item, name: "changed", })
  assert_eq(changed[changed.length() - 1].name, "changed")
  assert_eq(
    model.composition_exports()[model.composition_exports().length() - 1].name,
    "out",
  )
}

///|
test "target aliases resolve at the end of ordered declarations" {
  let text = StringBuilder()
  text.write_string(
    "package test:app targets test:app/alias5000;world w {}let alias0=w;",
  )
  for i in 1..<=5000 {
    text.write_string(
      "let alias" + i.to_string() + "=alias" + (i - 1).to_string() + ";",
    )
  }
  let source = text.to_string()
  assert_true(@verifier.verify(@parser.parse(source), source~) is Ok(_))
}

///|
test "target diagnostics preserve binary provenance and exact package versions" {
  let source = "// 😀\npackage test:app targets lookup:target/w@1.2.3+build; import c as c: lookup:target/provider@1.2.3+build;"
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: Some("1.2.3+build"),
      source: "target.wasm",
      bytes: target_component_import_more_bytes(),
    },
  ]
  let parsed = @parser.parse(source)
  let first = @verifier.verify(
    parsed,
    source~,
    source_id="root.wac",
    dependencies~,
  ).unwrap_err()
  assert_eq(first[0].code, "WAC-T003")
  assert_eq(first[0].primary.location.source, "root.wac")
  assert_true(first[0].primary.location.span().unwrap().start > 50)
  assert_eq(first[0].related[0].location.source, "root.wac")
  assert_eq(first[0].related[1].location.source, "target.wasm")
  assert_true(first[0].related[1].location.position is BinaryOffset(_))
  assert_eq(
    @verifier.verify(parsed, source~, source_id="root.wac", dependencies~).unwrap_err(),
    first,
  )
  let wrong_version = dependencies.map(item => {
    ..item,
    version: Some("1.2.3"),
  })
  assert_eq(
    @verifier.verify(parsed, source~, dependencies=wrong_version).unwrap_err()[0].code,
    "WAC-P003",
  )
}

///|
test "target checking shares a work limit across all extern comparisons" {
  let text = StringBuilder()
  text.write_string("package test:app targets test:app/w;")
  for name in ["required", "provided"] {
    text.write_string("interface " + name + " {")
    for i in 0..<1000 {
      text.write_string("function" + i.to_string() + ": func();")
    }
    text.write_string("}")
  }
  text.write_string("world w {")
  for i in 0..<300 {
    text.write_string("import i" + i.to_string() + ": required;")
  }
  text.write_string("}")
  for i in 0..<300 {
    let name = "i" + i.to_string()
    text.write_string("import " + name + " as " + name + ": provided;")
  }
  let source = text.to_string()
  let parsed = @parser.parse(source)
  let errors = @verifier.verify(parsed, source~).unwrap_err()
  assert_eq(errors[0].code, "WAC-C006", msg=errors[0].render())
}
