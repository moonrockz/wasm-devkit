///|
test "core module package empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x03\x01\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({ imports: [], exports: [], })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module )) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x13\x01\x50\x02\x01\x60\x05\x7f\x7e\x7d\x7c\x7b\x02\x7f\x7e\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "f",
        kind: Func({
          params: [
            Scalar("i32"),
            Scalar("i64"),
            Scalar("f32"),
            Scalar("f64"),
            Scalar("v128"),
          ],
          results: [Scalar("i32"), Scalar("i64")],
        }),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (type $f (func (param i32 i64 f32 f64 v128) (result i32 i64))) (export \"f\" (func (type $f))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x16\x01\x50\x03\x01\x60\x01\x7f\x00\x00\x03\x65\x6e\x76\x01\x66\x00\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="imports.wasm",
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
    "(component (core type $m (module (type $f (func (param i32))) (import \"env\" \"f\" (func (type $f))) (export \"f\" (func (type $f))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package table" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0f\x01\x50\x01\x03\x05\x74\x61\x62\x6c\x65\x01\x70\x01\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "table",
        kind: Table(Reference(true, "func"), 1UL, Some(3UL), false, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"table\" (table 1 3 funcref)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package memory" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0f\x01\x50\x01\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x01\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "memory", kind: Memory(1UL, Some(3UL), false, false, None), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"memory\" (memory 1 3)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7e\x01\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i64"), true, false), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"g\" (global (mut i64))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package tag" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0e\x01\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x65\x04\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "e", kind: Tag({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (type $e (func (param i32))) (export \"e\" (tag (type $e))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package unicode" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x01\x50\x03\x01\x60\x00\x00\x00\x02\xc3\xa9\x04\xf0\x9f\x98\x80\x00\x00\x03\x03\x66\xce\xbb\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="unicode.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "é",
        name: "😀",
        kind: Func({ params: [], results: [], }),
      },
    ],
    exports: [{ name: "fλ", kind: Func({ params: [], results: [], }), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (type $f (func)) (import \"é\" \"😀\" (func (type $f))) (export \"fλ\" (func (type $f))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package tuple-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x01\x50\x03\x01\x60\x00\x00\x00\x03\x61\x3a\x62\x01\x63\x00\x00\x00\x01\x61\x03\x62\x3a\x63\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
    "(component (core type $m (module (type $f (func)) (import \"a:b\" \"c\" (func (type $f))) (import \"a\" \"b:c\" (func (type $f))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package duplicate-import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x01\x50\x03\x01\x60\x00\x00\x00\x01\x61\x01\x62\x00\x00\x00\x01\x61\x01\x62\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
}

///|
test "core module package duplicate-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0f\x01\x50\x02\x03\x01\x6d\x02\x00\x00\x03\x01\x6d\x02\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="duplicate-export.wasm",
  )
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
test "core module package bad-memory" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0a\x01\x50\x01\x03\x01\x6d\x02\x01\x03\x01\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="bad-memory.wasm",
  )
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
test "core module package bad-table" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0b\x01\x50\x01\x03\x01\x74\x01\x70\x01\x03\x01\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="bad-table.wasm",
  )
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
test "core module package memory64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0e\x01\x50\x01\x03\x01\x6d\x02\x05\xf0\xa2\x04\x80\xf1\x04\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "m", kind: Memory(70000UL, Some(80000UL), true, false, None), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"m\" (memory i64 70000 80000)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package shared-memory" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0a\x01\x50\x01\x03\x01\x6d\x02\x03\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(3UL), false, true, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"m\" (memory 1 3 shared)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package table64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0b\x01\x50\x01\x03\x01\x74\x01\x70\x05\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
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
    "(component (core type $m (module (export \"t\" (table i64 1 3 funcref)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package typed-ref" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x10\x01\x50\x02\x01\x60\x00\x00\x03\x01\x74\x01\x63\x00\x01\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="typed-ref.wasm",
  )
  let model = result.unwrap()
  let identity : @core_types.TypeIdentity = {
    types: [
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 1,
        composite: Function([], []),
      },
    ],
    index: 0,
  }
  let expected = @verifier.TypeKind::Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Concrete(true, identity), 1UL, Some(3UL), false, false),
      },
    ],
  })
  assert_true(model.types().any(t => t.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (type $f (func)) (export \"t\" (table 1 3 (ref null $f))))) (import \"m\" (core module $m0 (type $m))) (export \"out\" (core module $m0)))",
  ).unwrap()
  assert_eq(binary_projection(model), binary_projection(text))
}

///|
test "core module package abstract-ref" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0b\x01\x50\x01\x03\x01\x74\x01\x6e\x01\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="abstract-ref.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Reference(true, "any"), 1UL, Some(3UL), false, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"t\" (table 1 3 anyref)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package shared-global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7f\x02\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="shared-global.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"g\" (global (shared i32))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package module-definition" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x24\x01\x41\x03\x00\x50\x01\x03\x01\x6d\x02\x00\x00\x03\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x04\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x0b\x0f\x01\x00\x09\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="module-definition.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(0UL, None, false, false, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"m\" (memory 0)))) (import \"module\" (core module (type $m))) (export \"module\" (core module (type $m))))) (export \"component\" (type $c)))",
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
test "core module package outer-function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x11\x02\x60\x01\x7f\x00\x50\x02\x02\x10\x01\x01\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x01\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x66\x01\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-function.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $f (func (param i32))) (core type $m (module (alias outer 1 $f (type $f)) (export \"f\" (func (type $f))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package memory-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x01\x50\x01\x03\x01\x6d\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-u64.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "m",
        kind: Memory(
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"m\" (memory i64 18446744073709551615 18446744073709551615 (pagesize 1))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package memory-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x13\x01\x50\x01\x03\x01\x6d\x02\x09\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-u32.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "m",
        kind: Memory(4294967295UL, Some(4294967295UL), false, false, Some(0)),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"m\" (memory 4294967295 4294967295 (pagesize 1))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package table-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x01\x50\x01\x03\x01\x74\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table-u64.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"t\" (table i64 18446744073709551615 18446744073709551615 funcref)))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package memory-page-default" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0b\x01\x50\x01\x03\x01\x6d\x02\x09\x01\x02\x10\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-page-default.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "m", kind: Memory(1UL, Some(2UL), false, false, Some(16)), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"m\" (memory 1 2 (pagesize 65536))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package local-function-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x12\x01\x50\x03\x01\x60\x01\x7f\x00\x02\x10\x01\x00\x00\x03\x01\x66\x00\x01\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="local-function-alias.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (type $f (func (param i32))) (alias outer 0 $f (type $a)) (export \"f\" (func (type $a))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package global-shared-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7e\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-shared-mut.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i64"), true, true), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"g\" (global (shared mut i64))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package nonnull-table" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x01\x50\x01\x03\x01\x74\x01\x64\x70\x01\x01\x03\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="nonnull-table.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "t",
        kind: Table(Reference(false, "func"), 1UL, Some(3UL), false, false),
      },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"t\" (table 1 3 (ref func))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
test "core module package instance-module" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x42\x02\x00\x50\x01\x03\x01\x6d\x02\x00\x00\x04\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0c\x01\x00\x11\x00\x00\x06\x6d\x6f\x64\x75\x6c\x65\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x25\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-module.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(0UL, None, false, false, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"m\" (memory 0)))) (export \"module\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (alias export $i \"module\" (core module $m)) (export \"out\" (core module $m)))",
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
test "core module package shadowed-core-name" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x05\x01\x60\x01\x7f\x00\x07\x18\x01\x41\x02\x00\x50\x01\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x03\x00\x01\x6d\x00\x11\x00\x03\x0d\x01\x50\x02\x02\x10\x01\x01\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x01\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0b\x00\x10\x02\x00\x01\x6d\x01\x03\x6f\x75\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="shadowed-core-name.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (func (param i32))) (type $c (component (core type $m (module (export \"memory\" (memory 0)))) (import \"m\" (core module (type $m))))) (core type $out (module (alias outer 1 $m (type $f)) (export \"f\" (func (type $f))))) (import \"m\" (core module $m (type $out))) (export \"out\" (core module $m)))",
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
test "core module package outer-module-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0e\x01\x50\x01\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x07\x10\x01\x41\x02\x02\x00\x10\x02\x01\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x0f\x01\x00\x09\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x03\x00\x00\x00\x1e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x63"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-module-alias.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "memory", kind: Memory(0UL, None, false, false, None), }],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"memory\" (memory 0)))) (type $c (component (alias outer 1 $m (core type $copy)) (import \"m\" (core module (type $copy))))) (export \"component\" (type $c)))",
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
test "core module package wrong-core-kind" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x04\x01\x60\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x66"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="wrong-core-kind.wasm",
  )
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
test "core module package forward-core-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x02\x10\x01\x00\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="forward-core-alias.wasm",
  )
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
test "core module package wrong-outer-depth" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x02\x10\x01\x02\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="wrong-outer-depth.wasm",
  )
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
test "core module package equal-core-slots" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x15\x03\x60\x01\x7f\x00\x60\x01\x7f\x00\x50\x02\x02\x10\x01\x01\x01\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x02\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x02\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="equal-core-slots.wasm",
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
  let expected : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  assert_true(model.types().any(ty => ty.kind == expected))
  let text = @verifier.decode_wat_component_package(
    "(component (core type (func (param i32))) (core type (func (param i32))) (core type $m (module (alias outer 1 1 (type $f)) (export \"f\" (func (type $f))))) (import \"m\" (core module $m (type $m))) (export \"out\" (core module $m)))",
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
