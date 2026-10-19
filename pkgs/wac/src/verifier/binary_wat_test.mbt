///|
fn wat_binary(bytes : Bytes) -> String {
  let text = StringBuilder()
  let digits = "0123456789abcdef"
  text.write_string("(component binary \"")
  for byte in bytes {
    let value = byte.to_int()
    text.write_string(
      "\\" +
      digits[value / 16:value / 16 + 1].to_owned() +
      digits[value % 16:value % 16 + 1].to_owned(),
    )
  }
  text.write_string("\")")
  text.to_string()
}

///|
test "WAC text binary forms validate after compilation without recursive parsing" {
  let payload : Array[Byte] = [1]
  for _ in 0..<10000 {
    payload.append([0x41, 1, 1])
  }
  payload.push(0x79)
  let text = wat_binary(package_section(7, payload))
  guard @verifier.decode_wat_component_package(text, source_id="deep.wat")
    is Err([error]) else {
    fail("accepted unbounded binary scopes")
  }
  assert_eq(error.code, "WAC-B002")
  assert_eq(error.primary.location.source, "deep.wat")
  assert_eq(error.primary.location.position, BinaryOffset(None))
}

///|
test "WAC WAT diagnostics never expose compiled byte offsets as source offsets" {
  for
    text in [
      "(component", "(component binary \"bad\")", "(component (type (own 0)))", "(component definition binary \"bad\")",
    ] {
    let first = @verifier.decode_wat_component_package(
      text,
      source_id="input.wat",
    )
    let second = @verifier.decode_wat_component_package(
      text,
      source_id="input.wat",
    )
    guard first is Err(errors) && second is Err(again) else {
      fail("accepted invalid component text")
    }
    assert_eq(errors, again)
    for problem in errors {
      assert_eq(problem.primary.location.position, BinaryOffset(None))
    }
  }
}

///|
test "WAC normalized WAT retains custom bytes and quoted identifiers" {
  let text = "(component (type $\"func type\" (func)) (import \"f\" (func (type $\"func type\"))) (export \"f\" (func 0)) (@custom \"extra\" \"\\ff\\00\"))"
  let result = @verifier.decode_wat_component_package(
    text,
    source_id="custom.wat",
  )
  guard result is Ok(model) else { fail(result.unwrap_err()[0].render()) }
  assert_eq(model.source(), "custom.wat")
  assert_true(model.bytes().length() > 8)
  assert_eq(
    binary_projection(model),
    binary_projection(
      @verifier.decode_component_package(model.bytes()).unwrap(),
    ),
  )
}

///|
test "WAC WAT nesting fails before recursive compiler helpers" {
  let text = StringBuilder()
  for _ in 0..<10000 {
    text.write_string("(")
  }
  for _ in 0..<10000 {
    text.write_string(")")
  }
  guard @verifier.decode_wat_component_package(text.to_string())
    is Err([problem]) else {
    fail("accepted deep WAT")
  }
  assert_eq(problem.code, "WAC-B002")
}

///|
// Source/license/pin retained in wit/binary/fixtures/wac. Pinned WAT parser rejects this input.
test "WAC corpus invalid named-result WAT remains rejected" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result \"a\" string)))\n  )\n)\n",
    )
    is Err(_),
  )
}
