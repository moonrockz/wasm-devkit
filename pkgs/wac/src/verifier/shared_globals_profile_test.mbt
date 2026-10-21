// Original regression witnesses. Reference pins and licenses are in
// tests/semantic/wac-shared-globals/README.md.

///|
test "shared concrete globals i32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(bytes, source_id="i32.wasm")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared i32) (i32.const 1))) (export \"m\" (core module $m)))",
    source_id="i32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals i32-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x03\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="i32-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared mut i32) (i32.const 1))) (export \"m\" (core module $m)))",
    source_id="i32-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), true, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7e\x02\x42\x02\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(bytes, source_id="i64.wasm")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared i64) (i64.const 2))) (export \"m\" (core module $m)))",
    source_id="i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i64"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals i64-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7e\x03\x42\x02\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="i64-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared mut i64) (i64.const 2))) (export \"m\" (core module $m)))",
    source_id="i64-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i64"), true, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals f32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x09\x01\x7d\x02\x43\x00\x00\xc0\x3f\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(bytes, source_id="f32.wasm")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared f32) (f32.const 1.5))) (export \"m\" (core module $m)))",
    source_id="f32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("f32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals f32-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x09\x01\x7d\x03\x43\x00\x00\xc0\x3f\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="f32-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared mut f32) (f32.const 1.5))) (export \"m\" (core module $m)))",
    source_id="f32-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("f32"), true, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals f64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x29\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x0d\x01\x7c\x02\x44\x00\x00\x00\x00\x00\x00\x02\xc0\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(bytes, source_id="f64.wasm")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared f64) (f64.const -2.25))) (export \"m\" (core module $m)))",
    source_id="f64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("f64"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals f64-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x29\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x0d\x01\x7c\x03\x44\x00\x00\x00\x00\x00\x00\x02\xc0\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="f64-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared mut f64) (f64.const -2.25))) (export \"m\" (core module $m)))",
    source_id="f64-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("f64"), true, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals v128" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x16\x01\x7b\x02\xfd\x0c\x01\x00\x00\x00\x02\x00\x00\x00\x03\x00\x00\x00\x04\x00\x00\x00\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(bytes, source_id="v128.wasm")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared v128) (v128.const i32x4 1 2 3 4))) (export \"m\" (core module $m)))",
    source_id="v128.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("v128"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals v128-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x16\x01\x7b\x03\xfd\x0c\x01\x00\x00\x00\x02\x00\x00\x00\x03\x00\x00\x00\x04\x00\x00\x00\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="v128-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared mut v128) (v128.const i32x4 1 2 3 4))) (export \"m\" (core module $m)))",
    source_id="v128-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("v128"), true, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals ordinary" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x01\x41\x07\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="ordinary.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (mut i32) (i32.const 7))) (export \"m\" (core module $m)))",
    source_id="ordinary.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), true, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x02\x07\x05\x01\x01\x67\x03\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="import.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"g\" (global $g (shared i32))) (export \"g\" (global $g))) (export \"m\" (core module $m)))",
    source_id="import.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "g",
        kind: Global(Scalar("i32"), false, true),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals inline-import" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7e\x03\x07\x05\x01\x01\x67\x03\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="inline-import.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global $g (import \"env\" \"g\") (shared mut i64)) (export \"g\" (global $g))) (export \"m\" (core module $m)))",
    source_id="inline-import.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "g",
        kind: Global(Scalar("i64"), true, true),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i64"), true, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals mixed-index" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x47\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x61\x03\x7f\x02\x06\x0b\x02\x7e\x01\x42\x02\x0b\x7f\x02\x41\x03\x0b\x07\x0d\x03\x01\x62\x03\x01\x01\x63\x03\x02\x01\x61\x03\x00\x00\x15\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x0a\x03\x00\x01\x61\x01\x01\x62\x02\x01\x63\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="mixed-index.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"a\" (global $a (shared i32))) (global $b (export \"b\") (mut i64) (i64.const 2)) (global $c (export \"c\") (shared i32) (i32.const 3)) (export \"a\" (global $a))) (export \"m\" (core module $m)))",
    source_id="mixed-index.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "a",
        kind: Global(Scalar("i32"), false, true),
      },
    ],
    exports: [
      { name: "b", kind: Global(Scalar("i64"), true, false), },
      { name: "c", kind: Global(Scalar("i32"), false, true), },
      { name: "a", kind: Global(Scalar("i32"), false, true), },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals get-set" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x53\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x01\x7f\x60\x01\x7f\x00\x03\x03\x02\x00\x01\x06\x06\x01\x7f\x03\x41\x00\x0b\x07\x11\x03\x03\x67\x65\x74\x00\x00\x03\x73\x65\x74\x00\x01\x01\x67\x03\x00\x0a\x0d\x02\x04\x00\x23\x00\x0b\x06\x00\x20\x00\x24\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="get-set.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global $g (shared mut i32) (i32.const 0)) (func (export \"get\") (result i32) global.get $g) (func (export \"set\") (param i32) local.get 0 global.set $g) (export \"g\" (global $g))) (export \"m\" (core module $m)))",
    source_id="get-set.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      { name: "get", kind: Func({ params: [], results: [Scalar("i32")], }), },
      { name: "set", kind: Func({ params: [Scalar("i32")], results: [], }), },
      { name: "g", kind: Global(Scalar("i32"), true, true), },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals import-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x34\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x61\x03\x7f\x02\x06\x06\x01\x7f\x02\x23\x00\x0b\x07\x05\x01\x01\x67\x03\x01\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x61\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="import-init.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"a\" (global $a (shared i32))) (global (export \"g\") (shared i32) (global.get $a))) (export \"m\" (core module $m)))",
    source_id="import-init.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "a",
        kind: Global(Scalar("i32"), false, true),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals ordinary-import-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x34\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x61\x03\x7f\x00\x06\x06\x01\x7f\x02\x23\x00\x0b\x07\x05\x01\x01\x67\x03\x01\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x61\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="ordinary-import-init.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"a\" (global $a i32)) (global (export \"g\") (shared i32) (global.get $a))) (export \"m\" (core module $m)))",
    source_id="ordinary-import-init.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "a",
        kind: Global(Scalar("i32"), false, false),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals extended-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x09\x01\x7e\x02\x42\x01\x42\x02\x7c\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="extended-init.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"g\") (shared i64) (i64.add (i64.const 1) (i64.const 2)))) (export \"m\" (core module $m)))",
    source_id="extended-init.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i64"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals nested" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x53\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x1b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x0b\x07\x01\x00\x01\x63\x04\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="nested.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (component $c (core module $m (global (export \"g\") (shared i32) (i32.const 1))) (export \"m\" (core module $m))) (export \"c\" (component $c)))",
    source_id="nested.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "component",
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals ascribe-00" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7f\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x00\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="ascribe-00.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $t (module (export \"g\" (global i32)))) (core module $m (global (export \"g\") i32 (i32.const 1))) (export \"m\" (core module $m) (core module (type $t))))",
    source_id="ascribe-00.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals ascribe-01" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7f\x02\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x00\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="ascribe-01.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $t (module (export \"g\" (global (shared i32))))) (core module $m (global (export \"g\") i32 (i32.const 1))) (export \"m\" (core module $m) (core module (type $t))))",
    source_id="ascribe-01.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals ascribe-10" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7f\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="ascribe-10.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $t (module (export \"g\" (global i32)))) (core module $m (global (export \"g\") (shared i32) (i32.const 1))) (export \"m\" (core module $m) (core module (type $t))))",
    source_id="ascribe-10.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals ascribe-11" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x09\x01\x50\x01\x03\x01\x67\x03\x7f\x02\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0b\x01\x00\x01\x6d\x00\x11\x00\x01\x00\x11\x00\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x74\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="ascribe-11.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $t (module (export \"g\" (global (shared i32))))) (core module $m (global (export \"g\") (shared i32) (i32.const 1))) (export \"m\" (core module $m) (core module (type $t))))",
    source_id="ascribe-11.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals instantiate-00" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x00\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x70\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x00\x07\x05\x01\x01\x67\x03\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x63\x07\x04\x01\x00\x01\x67\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x63\x00\x11\x01\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-00.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $p (global (export \"g\") i32 (i32.const 1))) (core module $c (import \"env\" \"g\" (global $g i32)) (export \"g\" (global $g))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))) (export \"c\" (core module $c)))",
    source_id="instantiate-00.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "g",
        kind: Global(Scalar("i32"), false, false),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals instantiate-01" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x00\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x70\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x02\x07\x05\x01\x01\x67\x03\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x63\x07\x04\x01\x00\x01\x67\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x63\x00\x11\x01\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-01.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $p (global (export \"g\") i32 (i32.const 1))) (core module $c (import \"env\" \"g\" (global $g (shared i32))) (export \"g\" (global $g))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))) (export \"c\" (core module $c)))",
    source_id="instantiate-01.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals instantiate-10" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x70\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x00\x07\x05\x01\x01\x67\x03\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x63\x07\x04\x01\x00\x01\x67\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x63\x00\x11\x01\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-10.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $p (global (export \"g\") (shared i32) (i32.const 1))) (core module $c (import \"env\" \"g\" (global $g i32)) (export \"g\" (global $g))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))) (export \"c\" (core module $c)))",
    source_id="instantiate-10.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals instantiate-11" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x70\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x02\x07\x05\x01\x01\x67\x03\x00\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x63\x07\x04\x01\x00\x01\x67\x02\x0d\x02\x00\x00\x00\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x63\x00\x11\x01\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x11\x02\x00\x01\x70\x01\x01\x63\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-11.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $p (global (export \"g\") (shared i32) (i32.const 1))) (core module $c (import \"env\" \"g\" (global $g (shared i32))) (export \"g\" (global $g))) (core instance $p (instantiate $p)) (core instance (instantiate $c (with \"env\" (instance $p)))) (export \"c\" (core module $c)))",
    source_id="instantiate-11.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "g",
        kind: Global(Scalar("i32"), false, true),
      },
    ],
    exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "module",
    core_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "module",
    core_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary.unwrap().bytes(), bytes)
  for result in [binary, text] {
    let model = result.unwrap()
    assert_eq(binary_projection(model), expected)
    assert_eq(
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
      expected,
    )
  }
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals wrong-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x42\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="wrong-init.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (shared i32) (i64.const 0))) (export \"m\" (core module $m)))",
    source_id="wrong-init.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals mutable-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x0a\x01\x03\x65\x6e\x76\x01\x67\x03\x7f\x03\x06\x06\x01\x7f\x02\x23\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="mutable-init.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"g\" (global $g (shared mut i32))) (global (shared i32) (global.get $g))) (export \"m\" (core module $m)))",
    source_id="mutable-init.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals missing-init-global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x23\x01\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="missing-init-global.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (shared i32) (global.get 1))) (export \"m\" (core module $m)))",
    source_id="missing-init-global.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals immutable-set" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x35\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x06\x06\x01\x7f\x02\x41\x00\x0b\x0a\x08\x01\x06\x00\x41\x01\x24\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="immutable-set.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global $g (shared i32) (i32.const 0)) (func i32.const 1 global.set $g)) (export \"m\" (core module $m)))",
    source_id="immutable-set.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals bad-body" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x03\x02\x01\x00\x06\x06\x01\x7f\x02\x41\x00\x0b\x0a\x06\x01\x04\x00\x41\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="bad-body.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (shared i32) (i32.const 0)) (func (result i64) i32.const 0)) (export \"m\" (core module $m)))",
    source_id="bad-body.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals unshared-reference" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x6f\x02\xd0\x6f\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="unshared-reference.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (shared externref) (ref.null extern))) (export \"m\" (core module $m)))",
    source_id="unshared-reference.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals gc-reference" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x03\x01\x5f\x00\x06\x07\x01\x63\x00\x02\xd0\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x04\x04\x01\x00\x01\x73\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="gc-reference.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (type $s (struct)) (global (shared (ref null $s)) (ref.null $s))) (export \"m\" (core module $m)))",
    source_id="gc-reference.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
  assert_eq(
    @verifier.decode_component_package(bytes).unwrap_err()[0].code,
    "WAC-B003",
  )
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals exception" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x38\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x06\x06\x01\x7f\x02\x41\x00\x0b\x0a\x06\x01\x04\x00\x08\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x04\x01\x00\x01\x74\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="exception.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (shared i32) (i32.const 0)) (tag $t) (func throw $t)) (export \"m\" (core module $m)))",
    source_id="exception.wat",
  )
  assert_true(binary is Ok(_))
  assert_true(text is Ok(_))
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(text.unwrap()),
  )
  assert_true(@binary_validation.validate_declarative_component(bytes) is Ok(_))
}

///|
test "shared concrete globals atomic" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x36\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x06\x06\x01\x7f\x03\x41\x00\x0b\x0a\x08\x01\x06\x00\xfe\x4f\x00\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x07\x04\x01\x00\x01\x67\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="atomic.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global $g (shared mut i32) (i32.const 0)) (func (result i32) global.atomic.get seqcst $g)) (export \"m\" (core module $m)))",
    source_id="atomic.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_eq(text.unwrap_err()[0].code, "WAC-B002")
  assert_eq(
    @verifier.decode_component_package(bytes).unwrap_err()[0].code,
    "WAC-B002",
  )
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals malformed-flags" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x10\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x04\x41\x00\x0b"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-flags.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\10\\00\\61\\73\\6d\\01\\00\\00\\00\\06\\06\\01\\7f\\04\\41\\00\\0b\")",
    source_id="malformed-flags.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals malformed-truncated-flags" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0c\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x02\x01\x7f"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-truncated-flags.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0c\\00\\61\\73\\6d\\01\\00\\00\\00\\06\\02\\01\\7f\")",
    source_id="malformed-truncated-flags.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "shared concrete globals malformed-truncated-init" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0f\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x05\x01\x7f\x02\x41\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-truncated-init.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0f\\00\\61\\73\\6d\\01\\00\\00\\00\\06\\05\\01\\7f\\02\\41\\00\")",
    source_id="malformed-truncated-init.wat",
  )
  for result in [binary, text] {
    let errors = result.unwrap_err()
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}
