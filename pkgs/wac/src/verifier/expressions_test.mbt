// Original access probes. Expected acceptance and ordered models from pinned
// WAC0.12.0 Document::resolve. Input package text is retained below.
// (component
//  (type (component
//    (type (instance
//      (type (instance (type (func)) (export "f" (func (type 0)))))
//      (type (func))
//      (export "a:one/api@1.0.0" (instance (type 0)))
//      (export "b:two/api@2.0.0" (instance (type 0)))
//      (export "a:one/only@1.2.0" (instance (type 0)))
//      (export "a:one/other@1.0.0" (instance (type 0)))
//      (export "only" (func (type 1)))
//    ))
//    (export "test:nested/container" (instance (type 0)))
//  ))
//  (export "container" (type 0))
// )

///|
fn access_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x8f\x01\x01\x41\x02\x01\x42\x07\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x01\x40\x00\x01\x00\x04\x00\x0f\x61\x3a\x6f\x6e\x65\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x04\x00\x0f\x62\x3a\x74\x77\x6f\x2f\x61\x70\x69\x40\x32\x2e\x30\x2e\x30\x05\x00\x04\x00\x10\x61\x3a\x6f\x6e\x65\x2f\x6f\x6e\x6c\x79\x40\x31\x2e\x32\x2e\x30\x05\x00\x04\x00\x11\x61\x3a\x6f\x6e\x65\x2f\x6f\x74\x68\x65\x72\x40\x31\x2e\x30\x2e\x30\x05\x00\x04\x00\x04\x6f\x6e\x6c\x79\x01\x01\x04\x00\x15\x74\x65\x73\x74\x3a\x6e\x65\x73\x74\x65\x64\x2f\x63\x6f\x6e\x74\x61\x69\x6e\x65\x72\x05\x00\x0b\x0f\x01\x00\x09\x63\x6f\x6e\x74\x61\x69\x6e\x65\x72\x03\x00\x00"
}

///|
test "pinned instance access function" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i.take;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "2", "api", "type",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "take", "func", "function", "false", "1", "h",
    "borrow", "0", "some", "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "import:i", "instance",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "alias:1:take", "func", "function", "false", "1",
    "h", "borrow", "0", "some", "scalar", "u32", "0",
  ])
}

///|
test "pinned instance access resource" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i.handle;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "2", "api", "type",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "handle", "type", "resource", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "import:i", "instance",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "alias:1:handle", "type", "resource", "0", "0",
  ])
}

///|
test "pinned instance access type" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i.number;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "2", "api", "type",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "number", "type", "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "import:i", "instance",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "alias:1:number", "type", "scalar", "u32", "0",
  ])
}

///|
test "pinned instance access group-alias" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; let j = ((i)); let f = (j).take; export f;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "2", "api", "type",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "take", "func", "function", "false", "1", "h",
    "borrow", "0", "some", "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "import:i", "instance",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "alias:1:take", "func", "function", "false", "1",
    "h", "borrow", "0", "some", "scalar", "u32", "0",
  ])
}

///|
test "pinned instance access type-is-not-instance" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export api.take;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access function-is-not-instance" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i.take.x;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access missing" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i.missing;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access quoted" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i[\"take\"];"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "2", "api", "type",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "take", "func", "function", "false", "1", "h",
    "borrow", "0", "some", "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "import:i", "instance",
    "interface", "test:app/api", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32", "alias:1:take", "func", "function", "false", "1",
    "h", "borrow", "0", "some", "scalar", "u32", "0",
  ])
}

///|
test "pinned instance access quoted-missing" {
  let source = "package test:app; interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; } import i: api; export i[\"missing\"];"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access ambiguous" {
  let source = "package test:app; import i: lookup:nested/container; export i.api;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access exact-wins" {
  let source = "package test:app; import i: lookup:nested/container; export i.only;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:nested/container", "instance", "interface", "test:nested/container",
    "0", "5", "a:one/api@1.0.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "b:two/api@2.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "a:one/only@1.2.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "a:one/other@1.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "only", "func", "function", "false", "0", "none", "1", "only", "func",
    "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "2", "import:lookup:nested/container", "instance", "interface", "test:nested/container",
    "0", "5", "a:one/api@1.0.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "b:two/api@2.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "a:one/only@1.2.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "a:one/other@1.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "only", "func", "function", "false", "0", "none", "alias:0:only", "func",
    "function", "false", "0", "none", "0",
  ])
}

///|
test "pinned instance access quoted-qualified" {
  let source = "package test:app; import i: lookup:nested/container; export i[\"a:one/api@1.0.0\"].f;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:nested/container", "instance", "interface", "test:nested/container",
    "0", "5", "a:one/api@1.0.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "b:two/api@2.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "a:one/only@1.2.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "a:one/other@1.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "only", "func", "function", "false", "0", "none", "1", "f", "func", "function",
    "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:nested/container", "instance", "interface", "test:nested/container",
    "0", "5", "a:one/api@1.0.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "b:two/api@2.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "a:one/only@1.2.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "a:one/other@1.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "only", "func", "function", "false", "0", "none", "alias:0:a:one/api@1.0.0",
    "instance", "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:1:f", "func", "function", "false", "0", "none",
    "0",
  ])
}

///|
test "pinned instance access quoted-suffix-is-exact" {
  let source = "package test:app; import i: lookup:nested/container; export i[\"api\"];"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access qualified-not-instance" {
  let source = "package test:app; import i: lookup:nested/container; export i.only.f;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instance access inferred-unique" {
  let source = "package test:app; import i: lookup:nested/container; export i.other.f;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:nested",
      version: None,
      source: "nested.wasm",
      bytes: access_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:nested/container", "instance", "interface", "test:nested/container",
    "0", "5", "a:one/api@1.0.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "b:two/api@2.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "a:one/only@1.2.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "a:one/other@1.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "only", "func", "function", "false", "0", "none", "1", "f", "func", "function",
    "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:nested/container", "instance", "interface", "test:nested/container",
    "0", "5", "a:one/api@1.0.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "b:two/api@2.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "a:one/only@1.2.0", "instance", "interface", "a:one/api@1.0.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "a:one/other@1.0.0", "instance",
    "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function", "false", "0",
    "none", "only", "func", "function", "false", "0", "none", "alias:0:a:one/other@1.0.0",
    "instance", "interface", "a:one/api@1.0.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:1:f", "func", "function", "false", "0", "none",
    "0",
  ])
}
