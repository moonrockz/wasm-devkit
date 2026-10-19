// Original WIT fixture encoded by wasm-tools1.262.0; source retained in this comment.
// package encoded:original@2.0.0;
// interface api { resource handle; type number = u32; take: func(h: borrow<handle>) -> number; }
// world service { import api; export answer: func() -> u32; }
// Ordered source models from pinned WAC0.12.0 Document::resolve.

///|
fn provider_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x52\x01\x41\x02\x01\x42\x06\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x79\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x01\x01\x68\x00\x01\x40\x01\x01\x68\x03\x00\x02\x04\x00\x04\x74\x61\x6b\x65\x01\x04\x04\x00\x1a\x65\x6e\x63\x6f\x64\x65\x64\x3a\x6f\x72\x69\x67\x69\x6e\x61\x6c\x2f\x61\x70\x69\x40\x32\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x88\x01\x01\x41\x02\x01\x41\x04\x01\x42\x06\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x79\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x01\x01\x68\x00\x01\x40\x01\x01\x68\x03\x00\x02\x04\x00\x04\x74\x61\x6b\x65\x01\x04\x03\x00\x1a\x65\x6e\x63\x6f\x64\x65\x64\x3a\x6f\x72\x69\x67\x69\x6e\x61\x6c\x2f\x61\x70\x69\x40\x32\x2e\x30\x2e\x30\x05\x00\x01\x40\x00\x00\x79\x04\x00\x06\x61\x6e\x73\x77\x65\x72\x01\x01\x04\x00\x1e\x65\x6e\x63\x6f\x64\x65\x64\x3a\x6f\x72\x69\x67\x69\x6e\x61\x6c\x2f\x73\x65\x72\x76\x69\x63\x65\x40\x32\x2e\x30\x2e\x30\x04\x00\x0b\x0d\x01\x00\x07\x73\x65\x72\x76\x69\x63\x65\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"
}

///|
test "provider reference different-keys" {
  let source = "package test:app; import a as first: lookup:one/api; import b as second: lookup:two/api; export a as first; export b as second;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:one",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
    },
    {
      name: "lookup:two",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "2", "first", "instance", "interface", "encoded:original/api@2.0.0", "0", "3",
    "handle", "type", "resource", "0", "number", "type", "scalar", "u32", "take",
    "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar", "u32",
    "second", "instance", "interface", "encoded:original/api@2.0.0", "0", "3", "handle",
    "type", "resource", "1", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "1", "some", "scalar", "u32", "2", "first", "instance",
    "interface", "encoded:original/api@2.0.0", "0", "3", "handle", "type", "resource",
    "0", "number", "type", "scalar", "u32", "take", "func", "function", "false",
    "1", "h", "borrow", "0", "some", "scalar", "u32", "second", "instance", "interface",
    "encoded:original/api@2.0.0", "0", "3", "handle", "type", "resource", "1", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "1", "some", "scalar", "u32",
  ])
}

///|
test "provider reference build-metadata-exact" {
  let source = "package test:app; import i: lookup:dep/api@1.2.3+one; export i;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: Some("1.2.3+one"),
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "lookup:dep/api@1.2.3+one", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32", "1", "encoded:original/api@2.0.0", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32",
  ])
}

///|
test "provider reference build-metadata-miss" {
  let source = "package test:app; import i: lookup:dep/api@1.2.3+two;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: Some("1.2.3+one"),
      source: "dep.wasm",
      bytes: provider_bytes(),
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
test "provider reference repeated-renamed" {
  let source = "package test:app; import i as first: lookup:dep/api; import j as second: lookup:dep/api; export i as first; export j as second;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "2", "first", "instance", "interface", "encoded:original/api@2.0.0", "0", "3",
    "handle", "type", "resource", "0", "number", "type", "scalar", "u32", "take",
    "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar", "u32",
    "second", "instance", "interface", "encoded:original/api@2.0.0", "0", "3", "handle",
    "type", "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "2", "first", "instance",
    "interface", "encoded:original/api@2.0.0", "0", "3", "handle", "type", "resource",
    "0", "number", "type", "scalar", "u32", "take", "func", "function", "false",
    "1", "h", "borrow", "0", "some", "scalar", "u32", "second", "instance", "interface",
    "encoded:original/api@2.0.0", "0", "3", "handle", "type", "resource", "0", "number",
    "type", "scalar", "u32", "take", "func", "function", "false", "1", "h", "borrow",
    "0", "some", "scalar", "u32",
  ])
}

///|
test "provider reference nested-value" {
  let source = "package test:app; import n as number: lookup:dep/api/number; export n;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "number", "type", "scalar", "u32", "1", "number", "type", "scalar", "u32",
  ])
}

///|
test "provider reference nested-resource" {
  let source = "package test:app; import h as handle: lookup:dep/api/handle; export h;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "handle", "type", "resource", "0", "1", "handle", "type", "resource", "0",
  ])
}

///|
test "provider reference package-import" {
  let source = "package test:app; import i: lookup:dep/api; export i;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "lookup:dep/api", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32", "1", "encoded:original/api@2.0.0", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32",
  ])
}

///|
test "provider reference renamed-import" {
  let source = "package test:app; import i as local: lookup:dep/api; export i;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "local", "instance", "interface", "encoded:original/api@2.0.0", "0", "3",
    "handle", "type", "resource", "0", "number", "type", "scalar", "u32", "take",
    "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar", "u32",
    "1", "encoded:original/api@2.0.0", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32",
  ])
}

///|
test "provider reference repeated-import" {
  let source = "package test:app; import i as first: lookup:dep/api; import j as second: lookup:dep/api; export i; export j;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
test "provider reference world-import" {
  let source = "package test:app; import w: lookup:dep/service; export w;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "lookup:dep/service", "component", "world", "encoded:original/service@2.0.0",
    "0", "1", "encoded:original/api@2.0.0", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32", "1", "answer", "func", "function", "false", "0", "some", "scalar", "u32",
    "1", "lookup:dep/service", "component", "world", "encoded:original/service@2.0.0",
    "0", "1", "encoded:original/api@2.0.0", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32", "1", "answer", "func", "function", "false", "0", "some", "scalar", "u32",
  ])
}

///|
test "provider reference nested-function" {
  let source = "package test:app; import f as answer: lookup:dep/service/answer; export f;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "answer", "func", "function", "false", "0", "some", "scalar", "u32", "1",
    "answer", "func", "function", "false", "0", "some", "scalar", "u32",
  ])
}

///|
test "provider reference use-types" {
  let source = "package test:app; interface local { use lookup:dep/api.{number, handle}; f: func(h: borrow<handle>) -> number; }"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "0", "1", "local", "type", "interface", "test:app/local", "2", "number", "number",
    "encoded:original/api@2.0.0", "handle", "handle", "encoded:original/api@2.0.0",
    "3", "number", "type", "scalar", "u32", "handle", "type", "resource", "0", "f",
    "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar", "u32",
  ])
}

///|
test "provider reference world-include" {
  let source = "package test:app; world local { include lookup:dep/service; }"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "0", "1", "local", "type", "world", "test:app/local", "0", "1", "encoded:original/api@2.0.0",
    "instance", "interface", "encoded:original/api@2.0.0", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "1", "answer", "func",
    "function", "false", "0", "some", "scalar", "u32",
  ])
}

///|
test "provider reference world-path" {
  let source = "package test:app; world local { import lookup:dep/api; export lookup:dep/api; }"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "0", "1", "local", "type", "world", "test:app/local", "0", "1", "encoded:original/api@2.0.0",
    "instance", "interface", "encoded:original/api@2.0.0", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32", "1", "encoded:original/api@2.0.0",
    "instance", "interface", "encoded:original/api@2.0.0", "0", "3", "handle", "type",
    "resource", "0", "number", "type", "scalar", "u32", "take", "func", "function",
    "false", "1", "h", "borrow", "0", "some", "scalar", "u32",
  ])
}

///|
test "provider reference version-exact" {
  let source = "package test:app; import i: lookup:dep/api@1.2.3; export i;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: Some("1.2.3"),
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "lookup:dep/api@1.2.3", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32", "1", "encoded:original/api@2.0.0", "instance", "interface", "encoded:original/api@2.0.0",
    "0", "3", "handle", "type", "resource", "0", "number", "type", "scalar", "u32",
    "take", "func", "function", "false", "1", "h", "borrow", "0", "some", "scalar",
    "u32",
  ])
}

///|
test "provider reference version-unversioned-miss" {
  let source = "package test:app; import i: lookup:dep/api;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: Some("1.2.3"),
      source: "dep.wasm",
      bytes: provider_bytes(),
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
test "provider reference version-versioned-miss" {
  let source = "package test:app; import i: lookup:dep/api@1.2.3;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
test "provider reference missing-definition" {
  let source = "package test:app; import i: lookup:dep/missing;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
test "provider reference missing-nested" {
  let source = "package test:app; import i: lookup:dep/api/missing;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
test "provider reference self-qualified" {
  let source = "package test:app; interface local { type x = u8; } import i: test:app/local; export i;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "test:app/local", "instance", "interface", "test:app/local", "0", "1", "x",
    "type", "scalar", "u8", "2", "local", "type", "interface", "test:app/local",
    "0", "1", "x", "type", "scalar", "u8", "test:app/local", "instance", "interface",
    "test:app/local", "0", "1", "x", "type", "scalar", "u8",
  ])
}

///|
test "provider reference self-version" {
  let source = "package test:app; interface local { type x = u8; } import i: test:app/local@9.9.9; export i;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
    "1", "test:app/local@9.9.9", "instance", "interface", "test:app/local", "0",
    "1", "x", "type", "scalar", "u8", "2", "local", "type", "interface", "test:app/local",
    "0", "1", "x", "type", "scalar", "u8", "test:app/local", "instance", "interface",
    "test:app/local", "0", "1", "x", "type", "scalar", "u8",
  ])
}

///|
test "provider reference self-ordered" {
  let source = "package test:app; import i: test:app/local; interface local {}"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: provider_bytes(),
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
