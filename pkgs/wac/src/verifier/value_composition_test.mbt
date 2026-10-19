///|
test "value source composition unused-access" {
  let source = "package test:app; let i = new test:dep {...}; let v = i.v; export i as \"out\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C010")
}

///|
test "value source composition path-import" {
  let source = "package test:app; import v: test:dep/v; export v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition path-unused" {
  let source = "package test:app; import v: test:dep/v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition repeat-fill" {
  let source = "package test:app; let i = new test:dep {...}; let j = new test:dep {...}; export i.v as \"a\"; export j.v as \"b\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C010")
}

///|
test "value source composition fill" {
  let source = "package test:app; let i = new test:dep {...}; export i.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar", "u32",
  ])
}

///|
test "value source composition explicit-type" {
  let source = "package test:app; import v: u32; let i = new test:dep {v}; export i.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition missing" {
  let source = "package test:app; let i = new test:dep {}; export i.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition instance-export" {
  let source = "package test:app; let i = new test:dep {...}; export i as \"out\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "v", "value", "scalar", "u32", "1", "out", "instance", "interface", "",
    "0", "1", "v", "value", "scalar", "u32",
  ])
}

///|
test "value source composition duplicate-export" {
  let source = "package test:app; let i = new test:dep {...}; export i.v as \"a\"; export i.v as \"b\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C010")
}

///|
test "value source composition forward" {
  let source = "package test:app; let i = new test:dep {...}; let j = new test:dep {v: i.v}; export j.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar", "u32",
  ])
}

///|
test "value source composition duplicate-use" {
  let source = "package test:app; let i = new test:dep {...}; let j = new test:dep {v: i.v}; let k = new test:dep {v: i.v}; export j.v as \"a\"; export k.v as \"b\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C010")
}

///|
test "value source composition spread-forward" {
  let source = "package test:app; let i = new test:dep {...}; let j = new test:dep {...i}; export j.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar", "u32",
  ])
}

///|
test "value source composition wrong-function-kind" {
  let source = "package test:app; import v: func(); let i = new test:dep {v}; export i.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition wrong-type-kind" {
  let source = "package test:app; type v = u32; let i = new test:dep {v}; export i.v;\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition wrong-value-type" {
  let source = "package test:app; let i = new test:dep {...}; let j = new test:dep {v: i.w, w: i.v}; export j as \"out\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x76\x02\x79\x00\x01\x77\x02\x77\x0b\x0d\x02\x00\x01\x76\x02\x00\x00\x00\x01\x77\x02\x01\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "value source composition forward-two-types" {
  let source = "package test:app; let i = new test:dep {...}; let j = new test:dep {v: i.v, w: i.w}; export j as \"out\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x76\x02\x79\x00\x01\x77\x02\x77\x0b\x0d\x02\x00\x01\x76\x02\x00\x00\x00\x01\x77\x02\x01\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "v", "value", "scalar", "u32", "w", "value", "scalar", "u64", "1", "out",
    "instance", "interface", "", "0", "2", "v", "value", "scalar", "u32", "w", "value",
    "scalar", "u64",
  ])
}

///|
test "value source composition unicode-duplicate" {
  let source = "package test:app; /* 🦀 */ let i = new test:dep {...}; export i.v as \"a\"; export i.v as \"b\";\n"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "value-dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C010")
  let error = result.unwrap_err()[0]
  assert_eq(error.primary.location.source, "<input>")
  assert_eq(error.primary.location.span().unwrap().start, 74)
  assert_eq(error.related.length(), 2)
  assert_eq(error.related[0].location.span().unwrap().start, 55)
}
