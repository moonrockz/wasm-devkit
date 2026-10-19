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

///|
test "target generic scopes leave the returned arena and resource contexts unchanged" {
  let body = "import c as c: lookup:target/provider;"
  let source = "package test:app targets lookup:target/w;" + body
  let unconstrained = "package test:app                        ;" + body
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "target.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x7e\x04\x41\x03\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x03\x00\x01\x61\x05\x00\x03\x00\x01\x62\x05\x00\x41\x05\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x03\x00\x01\x61\x05\x00\x02\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x01\x42\x02\x02\x03\x02\x01\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x00\x03\x00\x01\x62\x05\x02\x41\x02\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x41\x02\x02\x03\x02\x01\x02\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x03\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x05\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x30\x03\x05\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x05\x77\x6f\x72\x6c\x64\x03\x07\x77\x72\x61\x70\x70\x65\x72\x05\x08\x70\x72\x6f\x76\x69\x64\x65\x72",
    },
  ]
  let result = @verifier.verify(@parser.parse(source), source~, dependencies~)
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let checked = result.unwrap()
  let plain = @verifier.verify(
    @parser.parse(unconstrained),
    source=unconstrained,
    dependencies~,
  ).unwrap()
  assert_eq(checked.types(), plain.types())
  for i in 0..<plain.types().length() {
    assert_eq(checked.types()[i].id, plain.types()[i].id)
    assert_eq(checked.types()[i].name, plain.types()[i].name)
  }
  assert_eq(checked.composition().length(), plain.composition().length())
  for i in 0..<plain.composition().length() {
    assert_eq(checked.composition()[i].kind, plain.composition()[i].kind)
    assert_eq(
      checked.composition()[i].resources,
      plain.composition()[i].resources,
    )
    assert_eq(
      checked.composition()[i].operation,
      plain.composition()[i].operation,
    )
  }
}
