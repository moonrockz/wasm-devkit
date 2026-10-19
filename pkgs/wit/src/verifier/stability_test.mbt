///|
test "stable declarations retain metadata without changing source syntax" {
  let source = "package example:app@2.0.0;@since(version=1.0.0)interface api{@since(version=1.1.0)@deprecated(version=0.1.0)record data{value:list<u8>}@since(version=1.2.0)resource r{@since(version=1.3.0)constructor();@since(version=1.4.0)f:func()->r;}}@since(version=1.5.0)world app{@since(version=1.6.0)export api;}"
  let parsed = @parser.parse(source, features=@parser.Features::reference())
  let model = @verifier.verify(parsed, source~).unwrap()
  assert_eq(model.ast(), parsed.ast)
  assert_eq(model.text(), source)
  assert_eq(model.interfaces()[0].stability, Stable("1.0.0", None))
  assert_eq(model.worlds()[0].stability, Stable("1.5.0", None))
  assert_eq(model.worlds()[0].exports[0].stability, Stable("1.6.0", None))
  let data = model.types().filter(t => t.name == Some("data"))[0]
  assert_eq(data.stability, Stable("1.1.0", Some("0.1.0")))
  let resource = model.types().filter(t => t.kind is Resource)[0]
  assert_eq(resource.stability, Stable("1.2.0", None))
  assert_eq(model.functions()[0].stability, Stable("1.3.0", None))
  assert_eq(model.functions()[1].stability, Stable("1.4.0", None))
  let receiver = model
    .types()
    .filter(t => t.id == model.functions()[1].params[0].ty)[0]
  assert_eq(receiver.stability, resource.stability)
  let output = model
    .types()
    .filter(t => Some(t.id) == model.functions()[0].result)[0]
  assert_eq(output.stability, Unknown)
}

///|
test "stable version ordering follows the pinned resolver including build metadata" {
  for
    (package_version, since, accepted) in [
      ("1.0.0", "1.0.0", true),
      ("2.0.0", "1.999.999", true),
      ("1.0.0", "1.0.0-rc.10", true),
      ("1.0.0-rc.2", "1.0.0-rc.10", false),
      ("1.0.0-rc.10", "1.0.0-rc.2", true),
      ("1.0.0-alpha", "1.0.0-1", true),
      ("1.0.0-1", "1.0.0-alpha", false),
      ("1.0.0+abc", "1.0.0+def", false),
      ("1.0.0", "1.0.0+abc", false),
      ("1.0.0+002", "1.0.0+02", true),
      ("1.0.0+02", "1.0.0+002", false),
      ("1.0.0+10", "1.0.0+002", true),
      ("1.0.0+z", "1.0.0+9999", true),
      ("18446744073709551615.0.0", "18446744073709551614.0.0", true),
    ] {
    let source = "package example:app@" +
      package_version +
      ";interface api{@since(version=" +
      since +
      ")f:func();}"
    assert_eq(verify(source) is Ok(_), accepted, msg=source)
  }
}

///|
test "invalid annotations report original annotation and package locations" {
  for
    annotation in [
      "@since(version=3.0.0)", "@deprecated(version=1.0.0)", "@since(version=1.0.0)@since(version=1.1.0)",
      "@since(version=1.0.0)@deprecated(version=1.0.0)@deprecated(version=2.0.0)",
      "@since(version=1.0.0)@unstable(feature=preview)",
    ] {
    let source = "// 😀\npackage example:app@2.0.0;interface api{" +
      annotation +
      "f:func();}"
    guard verify(source) is Err(errors) else { fail(source) }
    assert_true(errors.any(d => d.code == "WIT-S013"))
    for error in errors {
      assert_eq(error.primary.location.source, "api.wit")
      assert_true(error.primary.location.span.start >= 45)
    }
    assert_true(verify(source) is Err(again) && again == errors)
  }
  for
    source in [
      "package example:app;@since(version=1.0.0)interface api{}", "package example:app;world app{@since(version=1.0.0)import f:func();}",
    ] {
    guard verify(source) is Err(errors) else { fail(source) }
    assert_eq(errors[0].code, "WIT-S013")
    assert_eq(errors[0].related[0].message, "package example:app")
  }
}

///|
test "anonymous composites inherit known metadata while named aliases form annotation boundaries" {
  let model = verify(
    "package example:app@2.0.0;interface api{@since(version=1.0.0)type t=u8;type boundary=t;type declared=list<t>;@since(version=1.1.0)record data{value:list<option<t>>}f:func(x:list<t>,y:list<boundary>);}",
  ).unwrap()
  let t = model.types().filter(t => t.name == Some("t"))[0]
  let boundary = model.types().filter(t => t.name == Some("boundary"))[0]
  assert_eq(t.stability, Stable("1.0.0", None))
  assert_eq(boundary.stability, Unknown)
  assert_eq(
    model.types().filter(t => t.name == Some("declared"))[0].stability,
    Unknown,
  )
  let function = model.functions()[0]
  assert_eq(
    model.types().filter(t => t.id == function.params[0].ty)[0].stability,
    t.stability,
  )
  assert_eq(
    model.types().filter(t => t.id == function.params[1].ty)[0].stability,
    Unknown,
  )
  let record = model.types().filter(t => t.name == Some("data"))[0]
  guard record.kind is Record(members) else { fail("record missing") }
  let list = model.types().filter(t => t.id == members[0].ty)[0]
  assert_eq(list.stability, record.stability)
  guard list.kind is List(element, _) else { fail("list missing") }
  assert_eq(
    model.types().filter(t => t.id == element)[0].stability,
    record.stability,
  )
}

///|
test "dependency annotations use their own package versions and source labels" {
  let root = section_document(
    "root.wit", "package example:app@1.0.0;interface api{use example:dep/api@2.0.0.{t};f:func(x:list<t>);}",
  )
  let dependency = section_document(
    "dep.wit", "package example:dep@2.0.0;interface api{@since(version=2.0.0)type t=u8;}",
  )
  let model = @verifier.resolve({ documents: [root], }, dependencies=[
    { documents: [dependency], },
  ]).unwrap()
  let function = model.functions()[0]
  assert_eq(
    model.types().filter(t => t.id == function.params[0].ty)[0].stability,
    Unknown,
  )
  let dependency = section_document(
    "dep.wit", "// 😀\npackage example:dep@2.0.0;interface api{@since(version=3.0.0)type t=u8;}",
  )
  guard @verifier.resolve({ documents: [root], }, dependencies=[
      { documents: [dependency], },
    ])
    is Err(errors) else {
    fail("unreleased dependency annotation accepted")
  }
  assert_eq(errors[0].primary.location.source, "dep.wit")
  assert_true(
    errors[0].related.any(label => {
      label.location.source == "dep.wit" &&
      label.message.contains("example:dep@2.0.0")
    }),
  )
  assert_true(
    errors[0].related.any(label => label.location.source == "root.wit"),
  )
}

///|
test "world includes preserve release annotations while freshening resource identities" {
  let model = section_model(
    "package example:app@2.0.0;world base{@since(version=1.0.0)resource r{@since(version=1.1.0)constructor();@since(version=1.2.0)x:get()->u8;@since(version=1.3.0)x:set(value:u8);}@since(version=1.4.0)export f:func(x:r);}world app{@since(version=1.5.0)include base with{r as renamed};}",
  ).unwrap()
  let base = model.worlds().filter(w => w.name == "base")[0]
  let app = model.worlds().filter(w => w.name == "app")[0]
  let resource = model
    .types()
    .filter(t => t.scope == base.id && t.kind is Resource)[0]
  let copied = model
    .types()
    .filter(t => t.scope == app.id && t.kind is Resource)[0]
  assert_true(resource.id != copied.id)
  assert_eq(copied.name, Some("renamed"))
  assert_eq(copied.stability, resource.stability)
  assert_eq(copied.stability, Stable("1.0.0", None))
  for item in app.imports {
    if item.kind is Function(id) {
      let function = model.functions().filter(f => f.id == id)[0]
      assert_eq(item.stability, function.stability)
      assert_true(function.stability != Unknown)
    }
  }
  assert_eq(app.exports[0].stability, Stable("1.4.0", None))
}

///|
test "stability propagation is stack safe on deep composites and long forward alias graphs" {
  let source = StringBuilder()
  source.write_string(
    "package example:app@2.0.0;interface api{@since(version=1.0.0)record data{value:",
  )
  for _ in 0..<10000 {
    source.write_string("list<")
  }
  source.write_string("u8")
  for _ in 0..<10000 {
    source.write_string(">")
  }
  source.write_string("}type a0=a1;")
  for i in 1..<5000 {
    source.write_string("type a\{i}=a\{i+1};")
  }
  source.write_string("@since(version=1.1.0)type a5000=u8;f:func(x:list<a0>);}")
  let text = source.to_string()
  let model = verify(text).unwrap()
  assert_eq(
    model
    .types()
    .filter(t => t.kind is List(_, _) && t.stability == Stable("1.0.0", None))
    .length(),
    10000,
  )
  assert_eq(
    model.types().filter(t => t.name == Some("a0"))[0].stability,
    Unknown,
  )
  assert_eq(
    model.types().filter(t => t.name == Some("a5000"))[0].stability,
    Stable("1.1.0", None),
  )
  assert_eq(
    model.ast(),
    @parser.parse(text, features=@parser.Features::reference()).ast,
  )
}
