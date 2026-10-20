///|
/// Print a pinned production component, then decode the binary and the
/// printed WAT. Both package models and both composition models are equal.
fn assert_printed_models(bytes : Bytes) -> Unit raise {
  guard @decompiler.print_component(bytes, source_id="dep.wasm") is Ok(printed) else {
    fail("production component rejected")
  }
  assert_eq(printed.documents.length(), 1)
  let binary = @verifier.decode_component_package(bytes).unwrap()
  let text = @verifier.decode_wat_component_package(
    printed.root().text,
    source_id="dep.wat",
  ).unwrap()
  assert_eq(binary_projection(text), binary_projection(binary))
  let source = "package test:app; let i = new test:dep {...}; export i as \"out\";"
  let compose = (bytes : Bytes) => {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:dep", version: None, source: "dep", bytes, },
    ])
    guard result is Ok(verified) else { fail("composition rejected") }
    (source_projection(verified), source_runtime_projection(verified))
  }
  assert_eq(compose(text.bytes()), compose(bytes))
}

///|
test "printed WAC hello and greeter components keep their models" {
  assert_printed_models(hello_component())
  assert_printed_models(greeter_component())
}

///|
test "printed WASI HTTP production components keep their models" {
  assert_printed_models(http_component_0_2_0())
  assert_printed_models(http_component_0_2_3())
}
