///|
test "compiled core component greeter" {
  let bytes = greeter_component()
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "1", "hello", "func", "function", "false", "0", "some", "scalar",
    "string", "1", "greet", "func", "function", "false", "0", "some", "scalar", "string",
    "instance", "interface", "", "0", "1", "greet", "func", "function", "false",
    "0", "some", "scalar", "string", "definitions", "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let source = "package test:app; let i = new test:dep {...}; export i as \"out\";\n"
  let resolved = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:dep", version: None, source: "greeter.wasm", bytes, },
  ])
  assert_eq(
    resolved is Ok(_),
    true,
    msg=match resolved {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "1", "hello", "func", "function", "false", "0", "some", "scalar", "string", "1",
    "out", "instance", "interface", "", "0", "1", "greet", "func", "function", "false",
    "0", "some", "scalar", "string",
  ]
  assert_eq(source_projection(resolved.unwrap()), expected)
}

///|
test "compiled core component hello" {
  let bytes = hello_component()
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "world", "", "0", "0", "1", "hello", "func", "function", "false", "0", "some",
    "scalar", "string", "instance", "interface", "", "0", "1", "hello", "func", "function",
    "false", "0", "some", "scalar", "string", "definitions", "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let source = "package test:app; let i = new test:dep {...}; export i as \"out\";\n"
  let resolved = @verifier.verify(@parser.parse(source), source~, dependencies=[
    { name: "test:dep", version: None, source: "hello.wasm", bytes, },
  ])
  assert_eq(
    resolved is Ok(_),
    true,
    msg=match resolved {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let expected = [
    "0", "1", "out", "instance", "interface", "", "0", "1", "hello", "func", "function",
    "false", "0", "some", "scalar", "string",
  ]
  assert_eq(source_projection(resolved.unwrap()), expected)
}
