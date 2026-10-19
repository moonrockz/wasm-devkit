// Original pinned module export annotation probes: tests/semantic/wac-module-ascriptions/.

///|
test "module export annotation empty" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x05\x02\x50\x00\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="empty.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({ imports: [], exports: [], })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({ imports: [], exports: [], })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module )) (core type $b (module )) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="empty.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation function" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x23\x02\x50\x02\x01\x60\x01\x7f\x01\x7e\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x50\x02\x01\x60\x01\x7f\x01\x7e\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Func({ params: [Scalar("i32")], results: [Scalar("i64")], }),
      },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Func({ params: [Scalar("i32")], results: [Scalar("i64")], }),
      },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (func (param i32) (result i64))))) (core type $b (module (export \"value\" (func (param i32) (result i64))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="function.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation function-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x21\x02\x50\x02\x01\x60\x01\x7f\x00\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x50\x02\x01\x60\x01\x7e\x00\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (func (param i32))))) (core type $b (module (export \"value\" (func (param i64))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="function-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, false), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, false), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global i32)))) (core type $b (module (export \"value\" (global i32)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation global-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7e\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global i32)))) (core type $b (module (export \"value\" (global i64)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation global-mutable" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x01\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-mutable.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global (mut i32))))) (core type $b (module (export \"value\" (global i32)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global-mutable.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation global-ref-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1a\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x64\x70\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x70\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-ref-narrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global (ref func))))) (core type $b (module (export \"value\" (global funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global-ref-narrow.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation global-ref-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1a\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x70\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x64\x70\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-ref-wide.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global funcref)))) (core type $b (module (export \"value\" (global (ref func))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global-ref-wide.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation global-ref-bottom" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x73\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x70\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-ref-bottom.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global nullfuncref)))) (core type $b (module (export \"value\" (global funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global-ref-bottom.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation function-ref-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x22\x02\x50\x02\x01\x60\x00\x01\x64\x70\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x50\x02\x01\x60\x00\x01\x70\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-ref-narrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (func (result (ref func)))))) (core type $b (module (export \"value\" (func (result funcref))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="function-ref-narrow.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation function-ref-param" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x22\x02\x50\x02\x01\x60\x01\x70\x00\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x50\x02\x01\x60\x01\x64\x70\x00\x03\x05\x76\x61\x6c\x75\x65\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="function-ref-param.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (func (param funcref))))) (core type $b (module (export \"value\" (func (param (ref func)))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="function-ref-param.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation table-ref-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1e\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x64\x70\x01\x01\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x01\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table-ref-narrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (table 1 5 (ref func))))) (core type $b (module (export \"value\" (table 1 5 funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="table-ref-narrow.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation global-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x02\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="global-shared.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, true), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, true), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global (shared i32))))) (core type $b (module (export \"value\" (global (shared i32))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="global-shared.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation memory-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x02\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x01\x0a\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-narrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(2UL, Some(5UL), false, false, None), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, Some(10UL), false, false, None), },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 2 5)))) (core type $b (module (export \"value\" (memory 1 10)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory-narrow.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation memory-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x01\x0a\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x02\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-wide.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 1 10)))) (core type $b (module (export \"value\" (memory 2 5)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory-wide.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation memory-no-max" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1a\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x00\x01\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x01\x0a\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-no-max.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 1)))) (core type $b (module (export \"value\" (memory 1 10)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory-no-max.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation memory-drop-max" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1a\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x02\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x00\x01\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-drop-max.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(2UL, Some(5UL), false, false, None), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "value", kind: Memory(1UL, None, false, false, None), }],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 2 5)))) (core type $b (module (export \"value\" (memory 1)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory-drop-max.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation memory64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x05\x02\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x05\x01\x0a\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory64.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(2UL, Some(5UL), true, false, None), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, Some(10UL), true, false, None), },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory i64 2 5)))) (core type $b (module (export \"value\" (memory i64 1 10)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory64.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation memory64-flag" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x05\x01\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x01\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory64-flag.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory i64 1 5)))) (core type $b (module (export \"value\" (memory 1 5)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory64-flag.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation memory-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x03\x01\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x03\x01\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-shared.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, Some(5UL), false, true, None), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, Some(5UL), false, true, None), },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 1 5 shared)))) (core type $b (module (export \"value\" (memory 1 5 shared)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory-shared.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation memory-shared-flag" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x03\x01\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x01\x01\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="memory-shared-flag.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 1 5 shared)))) (core type $b (module (export \"value\" (memory 1 5)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="memory-shared-flag.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation pagesize" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x40\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="pagesize.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775807UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory i64 9223372036854775808 18446744073709551615 (pagesize 1))))) (core type $b (module (export \"value\" (memory i64 9223372036854775807 18446744073709551615 (pagesize 1))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="pagesize.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation pagesize-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x09\x01\x05\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x09\x01\x05\x10\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="pagesize-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (memory 1 5 (pagesize 1))))) (core type $b (module (export \"value\" (memory 1 5 (pagesize 65536))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="pagesize-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation table" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x02\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x01\x0a\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="table.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(Reference(true, "func"), 2UL, Some(5UL), false, false),
      },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(Reference(true, "func"), 1UL, Some(10UL), false, false),
      },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (table 2 5 funcref)))) (core type $b (module (export \"value\" (table 1 10 funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="table.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation table-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x01\x0a\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x02\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table-wide.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (table 1 10 funcref)))) (core type $b (module (export \"value\" (table 2 5 funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="table-wide.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation table-heap" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x01\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x6f\x01\x01\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table-heap.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (table 1 5 funcref)))) (core type $b (module (export \"value\" (table 1 5 externref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="table-heap.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation table64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x02\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x01\x0a\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table64.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(Reference(true, "func"), 2UL, Some(5UL), true, false),
      },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(Reference(true, "func"), 1UL, Some(10UL), true, false),
      },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (table i64 2 5 funcref)))) (core type $b (module (export \"value\" (table i64 1 10 funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="table64.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation table64-flag" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x01\x05\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x01\x01\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="table64-flag.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (table i64 1 5 funcref)))) (core type $b (module (export \"value\" (table 1 5 funcref)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="table64-flag.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation tag" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x23\x02\x50\x02\x01\x60\x01\x7f\x00\x03\x05\x76\x61\x6c\x75\x65\x04\x00\x00\x50\x02\x01\x60\x01\x7f\x00\x03\x05\x76\x61\x6c\x75\x65\x04\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="tag.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Tag({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "value", kind: Tag({ params: [Scalar("i32")], results: [], }), },
    ],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (tag (param i32))))) (core type $b (module (export \"value\" (tag (param i32))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="tag.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation tag-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x23\x02\x50\x02\x01\x60\x01\x7f\x00\x03\x05\x76\x61\x6c\x75\x65\x04\x00\x00\x50\x02\x01\x60\x01\x7e\x00\x03\x05\x76\x61\x6c\x75\x65\x04\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tag-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (tag (param i32))))) (core type $b (module (export \"value\" (tag (param i64))))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="tag-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation extra-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0f\x02\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x00\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="extra-export.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, false), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({ imports: [], exports: [], })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"value\" (global i32)))) (core type $b (module )) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="extra-export.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation missing-export" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0f\x02\x50\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="missing-export.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module )) (core type $b (module (export \"value\" (global i32)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="missing-export.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation fewer-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x10\x02\x50\x00\x50\x01\x00\x04\x68\x6f\x73\x74\x01\x67\x03\x7f\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="fewer-imports.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({ imports: [], exports: [], })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "host",
        name: "g",
        kind: Global(Scalar("i32"), false, false),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module )) (core type $b (module (import \"host\" \"g\" (global i32)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="fewer-imports.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation extra-import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x10\x02\x50\x01\x00\x04\x68\x6f\x73\x74\x01\x67\x03\x7f\x00\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="extra-import.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (import \"host\" \"g\" (global i32)))) (core type $b (module )) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="extra-import.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation import-memory-wide" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x00\x04\x68\x6f\x73\x74\x01\x6d\x02\x01\x01\x0a\x50\x01\x00\x04\x68\x6f\x73\x74\x01\x6d\x02\x01\x02\x05\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-memory-wide.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "host",
        name: "m",
        kind: Memory(1UL, Some(10UL), false, false, None),
      },
    ],
    exports: [],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "host",
        name: "m",
        kind: Memory(2UL, Some(5UL), false, false, None),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (import \"host\" \"m\" (memory 1 10)))) (core type $b (module (import \"host\" \"m\" (memory 2 5)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="import-memory-wide.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation import-memory-narrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1d\x02\x50\x01\x00\x04\x68\x6f\x73\x74\x01\x6d\x02\x01\x02\x05\x50\x01\x00\x04\x68\x6f\x73\x74\x01\x6d\x02\x01\x01\x0a\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="import-memory-narrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (import \"host\" \"m\" (memory 2 5)))) (core type $b (module (import \"host\" \"m\" (memory 1 10)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="import-memory-narrow.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation tuple-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x2d\x02\x50\x02\x00\x03\x61\x3a\x62\x01\x63\x03\x7f\x00\x00\x01\x61\x03\x62\x3a\x63\x03\x7e\x00\x50\x02\x00\x03\x61\x3a\x62\x01\x63\x03\x7f\x00\x00\x01\x61\x03\x62\x3a\x63\x03\x7e\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tuple-imports.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "a:b",
        name: "c",
        kind: Global(Scalar("i32"), false, false),
      },
      {
        module_name: "a",
        name: "b:c",
        kind: Global(Scalar("i64"), false, false),
      },
    ],
    exports: [],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "a:b",
        name: "c",
        kind: Global(Scalar("i32"), false, false),
      },
      {
        module_name: "a",
        name: "b:c",
        kind: Global(Scalar("i64"), false, false),
      },
    ],
    exports: [],
  })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (import \"a:b\" \"c\" (global i32)) (import \"a\" \"b:c\" (global i64)))) (core type $b (module (import \"a:b\" \"c\" (global i32)) (import \"a\" \"b:c\" (global i64)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="tuple-imports.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation tuple-imports-missing" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x19\x02\x50\x01\x00\x03\x61\x3a\x62\x01\x63\x03\x7f\x00\x50\x01\x00\x01\x61\x03\x62\x3a\x63\x03\x7f\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tuple-imports-missing.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (import \"a:b\" \"c\" (global i32)))) (core type $b (module (import \"a\" \"b:c\" (global i32)))) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type $b))))\n",
    source_id="tuple-imports-missing.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation outer-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0a\x01\x50\x01\x03\x01\x6d\x02\x01\x01\x05\x06\x06\x01\x00\x10\x02\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="outer-alias.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(5UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"m\" (memory 1 5)))) (alias outer 0 0 (core type)) (import \"m\" (core module (type 0))) (export \"m\" (core module 0) (core module (type 1))))\n",
    source_id="outer-alias.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation reexport-hidden" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x02\x50\x01\x03\x01\x6d\x02\x01\x01\x05\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x1e\x02\x00\x05\x66\x69\x72\x73\x74\x00\x11\x00\x01\x00\x11\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x00\x11\x01\x01\x00\x11\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-hidden.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"m\" (memory 1 5)))) (core type $b (module)) (import \"m\" (core module (type $a))) (export \"first\" (core module 0) (core module (type $b))) (export \"second\" (core module 1) (core module (type $a))))\n",
    source_id="reexport-hidden.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation reexport-visible" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x02\x50\x01\x03\x01\x6d\x02\x01\x01\x05\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x1e\x02\x00\x05\x66\x69\x72\x73\x74\x00\x11\x00\x01\x00\x11\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x00\x11\x01\x01\x00\x11\x01\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-visible.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "m", kind: Memory(1UL, Some(5UL), false, false, None), }],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let kind_1 : @verifier.TypeKind = Module({ imports: [], exports: [], })
  let module_1 = match kind_1 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "2",
    "first",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "module",
    module_1.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "2",
    "first",
    "module",
    module_1.to_repr().to_string(),
    "second",
    "module",
    module_1.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"m\" (memory 1 5)))) (core type $b (module)) (import \"m\" (core module (type $a))) (export \"first\" (core module 0) (core module (type $b))) (export \"second\" (core module 1) (core module (type $b))))\n",
    source_id="reexport-visible.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation future-type" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x03\x01\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x03\x03\x01\x50\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="future-type.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module)) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type 1))) (core type (module)))\n",
    source_id="future-type.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation wrong-type-sort" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x06\x02\x50\x00\x60\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="wrong-type-sort.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module)) (core type (func)) (import \"m\" (core module (type $a))) (export \"m\" (core module 0) (core module (type 1))))\n",
    source_id="wrong-type-sort.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module export annotation concrete" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x01\x60\x00\x01\x7f\x03\x01\x66\x00\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x41\x2a\x0b\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="concrete.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [], results: [Scalar("i32")], }), },
    ],
  })
  let module_0 = match kind_0 {
    Module(m) => m
    _ => fail("expected module")
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"f\" (func (result i32))))) (core module (func (export \"f\") (result i32) i32.const 42)) (export \"m\" (core module 0) (core module (type $a))))\n",
    source_id="concrete.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), expected)
}

///|
test "module export annotation concrete-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0d\x01\x50\x02\x01\x60\x00\x01\x7e\x03\x01\x66\x00\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x06\x01\x04\x00\x41\x2a\x0b\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x61"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="concrete-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (core type $a (module (export \"f\" (func (result i64))))) (core module (func (export \"f\") (result i32) i32.const 42)) (export \"m\" (core module 0) (core module (type $a))))\n",
    source_id="concrete-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "module annotation scoped or inline inline" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x01\x50\x02\x01\x60\x00\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x03\x0c\x01\x50\x02\x01\x60\x00\x00\x03\x01\x66\x00\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (import \"m\" (core module (export \"f\" (func)))) (export \"m\" (core module 0) (core module (export \"f\" (func)))))",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(text.unwrap()),
  )
}

///|
test "module annotation scoped or inline inline-empty" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x03\x01\x50\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x03\x03\x01\x50\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (import \"m\" (core module)) (export \"m\" (core module 0) (core module)))",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(text.unwrap()),
  )
}

///|
test "module annotation scoped or inline instance-module" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x01\x50\x02\x01\x60\x00\x00\x03\x01\x66\x00\x00\x07\x10\x01\x42\x02\x02\x00\x10\x02\x01\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x07\x01\x00\x11\x00\x00\x01\x6d\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x69",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $t (module (export \"f\" (func)))) (type $i (instance (alias outer 1 $t (core type $t)) (export \"m\" (core module (type $t))))) (import \"i\" (instance (type $i))) (alias export 0 \"m\" (core module $m)) (export \"m\" (core module $m) (core module (type $t))))",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(text.unwrap()),
  )
}

///|
test "module annotation scoped or inline instance-module-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x0c\x01\x50\x02\x01\x60\x00\x00\x03\x01\x66\x00\x00\x07\x10\x01\x42\x02\x02\x00\x10\x02\x01\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x07\x01\x00\x11\x00\x00\x01\x6d\x03\x0d\x01\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x66\x00\x00\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x01\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x69",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $t (module (export \"f\" (func)))) (type $i (instance (alias outer 1 $t (core type $t)) (export \"m\" (core module (type $t))))) (import \"i\" (instance (type $i))) (alias export 0 \"m\" (core module $m)) (export \"m\" (core module $m) (core module (export \"f\" (func (param i32))))))",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary.unwrap_err()[0].code, "WAC-B003")
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}
