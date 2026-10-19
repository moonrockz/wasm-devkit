///|
test "core control block-extra-result" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x02\x40\x41\x00\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block i32.const 0 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control block-result" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x02\x7f\x41\x07\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block (result i32) i32.const 7 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control block-underflow" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x08\x01\x06\x00\x02\x40\x1a\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block drop end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control block-wrong-result" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x02\x7f\x42\x00\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block (result i32) i64.const 0 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control branch-function" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x34\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0d\x01\x0b\x00\x02\x40\x41\x07\x0c\x01\x0b\x41\x03\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block i32.const 7 br 1 end i32.const 3)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control branch-if-retains-value" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x34\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0d\x01\x0b\x00\x02\x7f\x41\x07\x41\x00\x0d\x00\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block (result i32) i32.const 7 i32.const 0 br_if 0 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control branch-table" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x39\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x12\x01\x10\x00\x02\x7f\x02\x7f\x41\x07\x41\x00\x0e\x01\x00\x01\x0b\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block (result i32) block (result i32) i32.const 7 i32.const 0 br_table 0 1 end end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control branch-table-polymorphic" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x39\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x13\x01\x11\x00\x02\x7f\x02\x7e\x00\x0e\x01\x01\x00\x0b\x1a\x41\x00\x0b\x1a\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block (result i32) block (result i64) unreachable br_table 1 0 end drop i32.const 0 end drop)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control branch-table-wrong-type" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x16\x01\x14\x00\x02\x7f\x02\x7e\x42\x00\x41\x00\x0e\x01\x01\x00\x0b\x1a\x41\x00\x0b\x1a\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block (result i32) block (result i64) i64.const 0 i32.const 0 br_table 1 0 end drop i32.const 0 end drop)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control branch-wrong-index" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x02\x40\x0c\x02\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block br 2 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control branch-wrong-value" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0b\x01\x09\x00\x02\x7f\x42\x00\x0c\x00\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block (result i32) i64.const 0 br 0 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control depth-256" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\xac\x06\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x85\x06\x01\x82\x06\x00\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end )) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B002")
}

///|
test "core control depth-257" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\xaf\x06\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x88\x06\x01\x85\x06\x00\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end )) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B002")
}

///|
test "core control double-else" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x41\x00\x04\x40\x05\x05\x0b\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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

///|
test "core control else-in-block" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x02\x40\x05\x0b\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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

///|
test "core control if-arms" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x36\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7f\x01\x7e\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0e\x01\x0c\x00\x20\x00\x04\x7e\x42\x01\x05\x42\x02\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "f",
        kind: Func({ params: [Scalar("i32")], results: [Scalar("i64")], }),
      },
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32) (result i64) local.get 0 if (result i64) i64.const 1 else i64.const 2 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control if-implicit-else-params" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x37\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x02\x60\x00\x01\x7f\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0b\x01\x09\x00\x41\x07\x41\x00\x04\x01\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 7 i32.const 0 if (param i32) (result i32) end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control if-missing-else" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0b\x01\x09\x00\x41\x00\x04\x7f\x41\x01\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 0 if (result i32) i32.const 1 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control if-wrong-condition" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x42\x00\x04\x40\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") i64.const 0 if end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control if-wrong-else" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x35\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0e\x01\x0c\x00\x41\x00\x04\x7f\x41\x01\x05\x42\x02\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 0 if (result i32) i32.const 1 else i64.const 2 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}

///|
test "core control invalid-block-type" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\x02\x66\x0b\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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

///|
test "core control local-work-bounded" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\xaf\x06\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x88\x06\x01\x85\x06\x01\xe8\x07\x7f\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 ) block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end )) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B002")
}

///|
test "core control local-work-exceeded" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\xaf\x06\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x88\x06\x01\x85\x06\x01\xa0\x1f\x7f\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x02\x40\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B002")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 ) block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block block end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end )) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B002")
}

///|
test "core control loop-back" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0b\x01\x09\x00\x03\x40\x20\x00\x0d\x00\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (param i32) loop local.get 0 br_if 0 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control loop-parameter" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x39\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x02\x60\x00\x01\x7f\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x0d\x01\x0b\x00\x41\x07\x03\x01\x41\x00\x0d\x00\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) i32.const 7 loop (param i32) (result i32) i32.const 0 br_if 0 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control missing-end" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x02\x40\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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

///|
test "core control multi-value-block" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x40\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0d\x02\x60\x00\x02\x7e\x7f\x60\x02\x7f\x7e\x02\x7e\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x11\x01\x0f\x00\x41\x03\x42\x04\x02\x01\x1a\x1a\x42\x04\x41\x03\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [],
    exports: [
      {
        name: "f",
        kind: Func({ params: [], results: [Scalar("i64"), Scalar("i32")], }),
      },
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
    "module",
    "module",
    module_0.to_repr().to_string(),
    "instance",
    "interface",
    "",
    "0",
    "1",
    "module",
    "module",
    module_0.to_repr().to_string(),
    "definitions",
    "0",
  ]
  assert_eq(binary_projection(result.unwrap()), expected)
  assert_eq(result.unwrap().bytes(), bytes)
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i64 i32) i32.const 3 i64.const 4 block (param i32 i64) (result i64 i32) drop drop i64.const 4 i32.const 3 end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    true,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(text.unwrap()), expected)
}

///|
test "core control trailing-end" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x19\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x05\x01\x03\x00\x0b\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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

///|
test "core control unexpected-else" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x19\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x05\x01\x03\x00\x05\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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

///|
test "core control unknown-block-type" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\x02\x01\x0b\x0b".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
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
test "core control unreachable-block-does-not-inherit" {
  let bytes = Bytes::from_array(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x09\x01\x07\x00\x00\x02\x40\x1a\x0b\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d".to_array(),
  )
  let result = @verifier.decode_component_package(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") unreachable block drop end)) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(text.unwrap_err()[0].code, "WAC-B003")
}
