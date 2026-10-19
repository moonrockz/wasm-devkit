///|
fn provider_input(
  name : String,
  version~ : String? = None,
  source~ : String = "dep.wasm",
  bytes~ : Bytes = provider_bytes(),
) -> @verifier.PackageSource {
  { name, version, source, bytes, }
}

///|
test "package input identity and duplicate diagnostics are deterministic" {
  let source = "package test:app;"
  for
    input in [
      provider_input("broken"),
      provider_input("lookup:dep", version=Some("01.2.3")),
    ] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      input,
    ])
    guard result is Err(errors) else { fail("accepted invalid identity") }
    assert_eq(errors[0].code, "WAC-P001")
  }
  let inputs : ReadOnlyArray[@verifier.PackageSource] = [
    provider_input("lookup:dep"),
    provider_input("lookup:dep", source="second.wasm"),
  ]
  let first = @verifier.verify(
    @parser.parse(source),
    source~,
    dependencies=inputs,
  )
  assert_eq(first is Err(_), true)
  guard first is Err(errors) else { fail("accepted duplicate input") }
  assert_eq(errors[0].code, "WAC-P002")
  assert_eq(errors[0].primary.location.source, "second.wasm")
  assert_eq(errors[0].related[0].location.source, "dep.wasm")
  let again = @verifier.verify(
    @parser.parse(source),
    source~,
    dependencies=inputs,
  )
  guard again is Err(other) else { fail("nondeterministic result") }
  assert_eq(errors, other)
}

///|
test "binary failures retain bytes and requesting WAC provenance" {
  let source = "package test:app; import i: lookup:dep/api;"
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="root.wac",
    dependencies=[provider_input("lookup:dep", bytes=b"bad")],
  )
  guard result is Err(errors) else { fail("accepted malformed dependency") }
  assert_eq(errors[0].code, "WAC-B001")
  assert_eq(errors[0].primary.location.source, "dep.wasm")
  assert_true(errors[0].primary.location.position is BinaryOffset(_))
  assert_eq(errors[0].related[0].location.source, "root.wac")
  assert_true(errors[0].related[0].location.position is SourceSpan(_))
}

///|
test "unused binary inputs are not decoded and lookup versions are independent" {
  let source = "package test:app; import i: lookup:dep/api@1.2.3; export i;"
  let inputs : ReadOnlyArray[@verifier.PackageSource] = [
    provider_input("lookup:dep", bytes=b"unused invalid bytes"),
    provider_input("lookup:dep", version=Some("1.2.3")),
  ]
  assert_true(
    @verifier.verify(@parser.parse(source), source~, dependencies=inputs)
    is Ok(_),
  )
}

///|
test "self instantiation is rejected regardless of dependency or version" {
  for
    source in [
      "package test:app; let x = new test:app {};", "package test:app; let x = new test:app@9.9.9 {};",
    ] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      provider_input("test:app"),
    ])
    guard result is Err(errors) else { fail("accepted self instantiation") }
    assert_eq(errors[0].code, "WAC-P005")
  }
}
