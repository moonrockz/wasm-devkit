///|
test "concrete module empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x13\x00\x61\x73\x6d\x01\x00\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(bytes, source_id="empty.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({ imports: [], exports: [], })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m ) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x20\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "f",
        kind: Func({ params: [Scalar("i32")], results: [Scalar("i32")], }),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32) (result i32) local.get 0)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module invalid-body" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-body.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module memory" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x01\x01\x02\x07\x05\x01\x01\x6d\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(2UL), false, false, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"m\") 1 2)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7e\x00\x42\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i64"), false, false), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") i64 (i64.const 1))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module table" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x21\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x05\x01\x70\x01\x01\x03\x07\x05\x01\x01\x74\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(bytes, source_id="table.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Reference(true, "func"), 1UL, Some(3UL), false, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"t\") 1 3 funcref)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module tag" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x0d\x03\x01\x00\x00\x07\x05\x01\x01\x65\x04\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(bytes, source_id="tag.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "e", kind: Tag({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (tag (export \"e\") (param i32))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module data" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x01\x07\x05\x01\x01\x6d\x02\x00\x0b\x0b\x01\x00\x41\x00\x0b\x05\x68\x65\x6c\x6c\x6f\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(bytes, source_id="data.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, None, false, false, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"m\") 1) (data (i32.const 0) \"hello\")) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module passive-data" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x0b\x08\x01\x01\x05\x68\x65\x6c\x6c\x6f\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="passive-data.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({ imports: [], exports: [], })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (data \"hello\")) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module element" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x04\x04\x01\x70\x00\x01\x07\x05\x01\x01\x74\x01\x00\x09\x07\x01\x00\x41\x00\x0b\x01\x00\x0a\x04\x01\x02\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="element.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Reference(true, "func"), 1UL, None, false, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func $f) (table (export \"t\") 1 funcref) (elem (i32.const 0) $f)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module passive-element" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x09\x05\x01\x01\x00\x01\x00\x0a\x04\x01\x02\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="passive-element.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({ imports: [], exports: [], })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func $f) (elem func $f)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module start" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x08\x01\x00\x0a\x04\x01\x02\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(bytes, source_id="start.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({ imports: [], exports: [], })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func $f) (start $f)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module bad-start" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x08\x01\x00\x0a\x04\x01\x02\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="bad-start.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module import-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-function.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "f",
        kind: Func({ params: [Scalar("i32")], results: [], }),
      },
    ],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"f\" (func $f (param i32))) (export \"f\" (func $f))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module duplicate-import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x11\x02\x03\x65\x6e\x76\x01\x66\x00\x00\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="duplicate-import.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module different-duplicate-import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x00\x00\x60\x01\x7f\x00\x02\x11\x02\x03\x65\x6e\x76\x01\x66\x00\x00\x03\x65\x6e\x76\x01\x66\x00\x01\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="different-duplicate-import.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module tuple-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x11\x02\x03\x61\x3a\x62\x01\x63\x00\x00\x01\x61\x03\x62\x3a\x63\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tuple-imports.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "a:b",
        name: "c",
        kind: Func({ params: [], results: [], }),
      },
      {
        module_name: "a",
        name: "b:c",
        kind: Func({ params: [], results: [], }),
      },
    ],
    exports: [],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"a:b\" \"c\" (func)) (import \"a\" \"b:c\" (func))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module memory64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x08\x01\x05\xf0\xa2\x04\x80\xf1\x04\x07\x05\x01\x01\x6d\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory64.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "m", kind: Memory(70000UL, Some(80000UL), true, false, None), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"m\") i64 70000 80000)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module shared-memory" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x03\x01\x02\x07\x05\x01\x01\x6d\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="shared-memory.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(2UL), false, true, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"m\") 1 2 shared)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module table64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x21\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x05\x01\x70\x05\x01\x03\x07\x05\x01\x01\x74\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table64.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Reference(true, "func"), 1UL, Some(3UL), true, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"t\") i64 1 3 funcref)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module shared-global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7e\x02\x42\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="shared-global.wasm",
  )
  assert_true(result is Ok(_))
}

///|
test "concrete module custom-pages" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x21\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x05\x01\x09\x01\x03\x00\x07\x05\x01\x01\x6d\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="custom-pages.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "m", kind: Memory(1UL, Some(3UL), false, false, Some(0)), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"m\") 1 3 (pagesize 1))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module import-global-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x34\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x00\x06\x06\x01\x7f\x00\x23\x00\x0b\x07\x05\x01\x01\x67\x03\x01\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-global-init.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "g",
        kind: Global(Scalar("i32"), false, false),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, false), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"g\" (global $g i32)) (global (export \"g\") i32 (global.get $g))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module extended-const" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x09\x01\x7f\x00\x41\x01\x41\x02\x6a\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="extended-const.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, false), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") i32 (i32.add (i32.const 1) (i32.const 2)))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module bad-global-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x00\x42\x00\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="bad-global-init.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module canonical-lift" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="canonical-lift.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "f", "func", "function", "false", "0", "none", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "definitions",
    "0",
  ])
}

///|
test "concrete module nested-component" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x43\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x21\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74\x0b\x0b\x01\x00\x05\x63\x68\x69\x6c\x64\x04\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nested-component.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "concrete module arithmetic" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x36\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0d\x01\x0b\x01\x01\x7f\x20\x00\x20\x01\x6a\x22\x02\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="arithmetic.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "f",
        kind: Func({
          params: [Scalar("i32"), Scalar("i32")],
          results: [Scalar("i32")],
        }),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32 i32) (result i32) (local i32) local.get 0 local.get 1 i32.add local.tee 2)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module load-store" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x05\x01\x01\x66\x00\x00\x0a\x10\x01\x0e\x00\x41\x00\x20\x00\x36\x02\x00\x41\x00\x28\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="load-store.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "f",
        kind: Func({ params: [Scalar("i32")], results: [Scalar("i32")], }),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory 1) (func (export \"f\") (param i32) (result i32) i32.const 0 local.get 0 i32.store i32.const 0 i32.load)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module indirect" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x04\x04\x01\x70\x00\x01\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x41\x00\x11\x00\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x04\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="indirect.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [], results: [Scalar("i32")], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (type $f (func (result i32))) (table 1 funcref) (func (export \"f\") (result i32) i32.const 0 call_indirect (type $f))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module bulk-memory" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x4f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x05\x01\x01\x66\x00\x00\x0c\x01\x01\x0a\x11\x01\x0f\x00\x41\x00\x41\x00\x41\x05\xfc\x08\x00\x00\xfc\x09\x00\x0b\x0b\x08\x01\x01\x05\x68\x65\x6c\x6c\x6f\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x09\x04\x01\x00\x01\x64\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="bulk-memory.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory 1) (data $d \"hello\") (func (export \"f\") i32.const 0 i32.const 0 i32.const 5 memory.init $d data.drop $d)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module simd-constant" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7b\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x16\x01\x14\x00\xfd\x0c\x00\x00\x00\x00\x01\x00\x00\x00\x02\x00\x00\x00\x03\x00\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="simd-constant.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [], results: [Scalar("v128")], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result v128) v128.const i32x4 0 1 2 3)) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module ref-null" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x6f\x00\xd0\x6f\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="ref-null.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "g", kind: Global(Reference(true, "extern"), false, false), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") externref (ref.null extern))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module typed-table-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x09\x01\x40\x00\x70\x00\x01\xd0\x70\x0b\x07\x05\x01\x01\x74\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="typed-table-init.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Reference(true, "func"), 1UL, None, false, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"t\") 1 funcref (ref.null func))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module invalid-local" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x20\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-local.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module invalid-call" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x10\x0a\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-call.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module invalid-stack" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-stack.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module invalid-load" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x29\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x41\x00\x28\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-load.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module invalid-data-offset" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x21\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x01\x0b\x07\x01\x00\x42\x00\x0b\x01\x78\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-data-offset.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module invalid-element-offset" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x21\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x04\x01\x70\x00\x01\x09\x06\x01\x00\x42\x00\x0b\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="invalid-element-offset.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "concrete module structured" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x02\x7f\x41\x01\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="structured.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap().bytes(), bytes)
}

///|
test "concrete module recursive-functions" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x33\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x4e\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x04\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="recursive-functions.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (rec (type $f (func (param i32)))) (func (export \"f\") (type $f))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module unicode-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x36\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x0b\x01\x02\xce\xbc\x04\xf0\x9f\x90\x9d\x00\x00\x07\x08\x01\x04\xf0\x9f\x90\x9d\x00\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="unicode-imports.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(model.bytes(), bytes)
  let expected : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "μ",
        name: "🐝",
        kind: Func({ params: [], results: [], }),
      },
    ],
    exports: [{ name: "🐝", kind: Func({ params: [], results: [], }), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"μ\" \"🐝\" (func $f)) (export \"🐝\" (func $f))) (export \"module\" (core module $m)))",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(model), binary_projection(text.unwrap()))
}

///|
test "concrete module concrete-heap-index" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\xa9\x03\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x85\x03\x81\x01\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\xd0\x80\x01\x1a\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="concrete-heap-index.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
}

///|
test "concrete module padded-heap" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x07\x01\x6f\x00\xd0\xef\x7f\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="padded-heap.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B001")
}
