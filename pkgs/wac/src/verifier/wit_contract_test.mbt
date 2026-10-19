///|
fn wit_input(text : String) -> @verifier.WitPackageSource {
  {
    name: "lookup:types",
    version: None,
    source: "provider.wit",
    root: @wit_verifier.PackageInput::Source({
      documents: [wit_document("provider.wit", text)],
    }),
    dependencies: [],
  }
}

///|
test "WIT provider resolution is lazy and errors preserve both sources" {
  let input = wit_input(
    "package embedded:types;interface api {type bad=missing;}",
  )
  let source = "package test:app;"
  assert_true(
    @verifier.verify(@parser.parse(source), source~, wit_dependencies=[input])
    is Ok(_),
  )
  let source = "package test:app;import i: lookup:types/api;"
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="root.wac",
    wit_dependencies=[input],
  )
  guard result is Err(errors) else { fail("invalid provider accepted") }
  assert_eq(errors[0].primary.location.source, "provider.wit")
  assert_true(
    errors[0].related.any(label => label.location.source == "root.wac"),
  )
}

///|
test "WIT provider keys share duplicate checks with binary inputs" {
  let source = "package test:app;"
  let input = wit_input("package embedded:types;")
  let duplicate = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    input, input,
  ])
  guard duplicate is Err(errors) else { fail("duplicate provider accepted") }
  assert_eq(errors[0].code, "WAC-P002")
  let mixed = @verifier.verify(
    @parser.parse(source),
    source~,
    dependencies=[
      {
        name: "lookup:types",
        version: None,
        source: "binary.wasm",
        bytes: b"",
      },
    ],
    wit_dependencies=[input],
  )
  guard mixed is Err(errors) else { fail("mixed duplicate accepted") }
  assert_eq(errors[0].code, "WAC-P002")
  assert_eq(errors[0].related[0].location.source, "binary.wasm")
}

///|
test "WIT providers use exact lookup versions independent of embedded identities" {
  let input = {
    ..wit_input("package embedded:types@9.0.0;interface api {f:func();}"),
    version: Some("1.2.3"),
  }
  let source = "package test:app;import i: lookup:types/api@1.2.3;"
  assert_true(
    @verifier.verify(@parser.parse(source), source~, wit_dependencies=[input])
    is Ok(_),
  )
  let source = "package test:app;import i: lookup:types/api@1.2.4;"
  guard @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
      input,
    ])
    is Err(errors) else {
    fail("non-exact lookup accepted")
  }
  assert_eq(errors[0].code, "WAC-P003")
}

///|
test "WAC WIT profile guards apply to caller parsed source" {
  for
    text in [
      "package example:types@1.2.3;interface api {resource handle {value: get() -> u32;value: set(value: u32);}}",
    ] {
    let parsed = @wit_parser.parse(text, features=@wit_parser.Features::all())
    assert_true(parsed.is_valid(), msg=@debug.to_string(parsed.diagnostics))
    let root = @wit_verifier.PackageInput::Source({
      documents: [
        @wit_verifier.Document::from_parse("profile.wit", text, parsed),
      ],
    })
    let result = @verifier.resolve_wit_package(root)
    guard result is Err(errors) else { fail("outside-profile source accepted") }
    assert_eq(errors[0].primary.location.source, "profile.wit")
    assert_eq(errors[0].code, "WAC-W001")
  }
}

///|
test "WIT adapter preserves input and independent resource binders" {
  let input = wit_input(
    "package example:types;interface api {resource handle;}world app {import a:api;import b:api;}",
  )
  let resolution = @wit_verifier.resolve_packages(input.root).unwrap()
  let before = resolution.types()
  let first = @verifier.adapt_wit_package(resolution).unwrap()
  let second = @verifier.adapt_wit_package(resolution).unwrap()
  assert_eq(resolution.types(), before)
  assert_eq(wit_projection(first), wit_projection(second))
  assert_eq(first.types()[first.world()].location.source, "provider.wit")
  assert_eq(first.resource_identity(-1), None)
  assert_eq(first.resource_identity(first.types().length()), None)
}

///|
test "WIT adapter handles deeply nested type graphs without recursion" {
  let text = StringBuilder()
  text.write_string("package example:types;interface api {type value=")
  for _ in 0..<3000 {
    text.write_string("list<")
  }
  text.write_string("u8")
  for _ in 0..<3000 {
    text.write_string(">")
  }
  text.write_string(";f:func(x:value);}")
  let input = wit_input(text.to_string())
  let result = @verifier.resolve_wit_package(input.root)
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_true(result.unwrap().types().length() > 3000)
}
