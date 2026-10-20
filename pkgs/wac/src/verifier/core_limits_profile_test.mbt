// Original Apache-2.0 probes. Complete expected models derive from the pinned
// WAC Package::from_bytes snapshots in tests/semantic/wac-core-limits.

///|
test "core limits component-memory-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 4294967295 4294967295 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967295UL, Some(4294967295UL), true, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-memory-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-memory-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory i64 4294967295 4294967295 (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-memory-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967295UL, Some(4294967295UL), true, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x0d\x01\x0d\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 4294967295 4294967295 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967295UL, Some(4294967295UL), true, false, Some(0)),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-table-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-table-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (table i64 4294967295 4294967295 funcref)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-table-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          4294967295UL,
          Some(4294967295UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-table-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-table-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (table i64 4294967295 4294967295 funcref)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-table-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          4294967295UL,
          Some(4294967295UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-table-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x0d\x01\x70\x05\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"value\") i64 4294967295 4294967295 funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          4294967295UL,
          Some(4294967295UL),
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-memory-past-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\x80\x80\x80\x80\x10\x80\x80\x80\x80\x10\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-past-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 4294967296 4294967296 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-past-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967296UL, Some(4294967296UL), true, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-memory-past-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\x80\x80\x80\x80\x10\x80\x80\x80\x80\x10\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-memory-past-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory i64 4294967296 4294967296 (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-memory-past-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967296UL, Some(4294967296UL), true, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-past-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x0d\x01\x0d\x80\x80\x80\x80\x10\x80\x80\x80\x80\x10\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-past-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 4294967296 4294967296 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-past-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967296UL, Some(4294967296UL), true, false, Some(0)),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-table-past-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x80\x80\x80\x80\x10\x80\x80\x80\x80\x10\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-table-past-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (table i64 4294967296 4294967296 funcref)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-table-past-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          4294967296UL,
          Some(4294967296UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-table-past-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x80\x80\x80\x80\x10\x80\x80\x80\x80\x10\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-table-past-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (table i64 4294967296 4294967296 funcref)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-table-past-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          4294967296UL,
          Some(4294967296UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-table-past-u32" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x0d\x01\x70\x05\x80\x80\x80\x80\x10\x80\x80\x80\x80\x10\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-past-u32.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"value\") i64 4294967296 4294967296 funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-past-u32.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          4294967296UL,
          Some(4294967296UL),
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-memory-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 9223372036854775807 9223372036854775807 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775807UL,
          Some(9223372036854775807UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-memory-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-memory-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory i64 9223372036854775807 9223372036854775807 (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-memory-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775807UL,
          Some(9223372036854775807UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x35\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x15\x01\x0d\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 9223372036854775807 9223372036854775807 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775807UL,
          Some(9223372036854775807UL),
          true,
          false,
          Some(0),
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-table-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-table-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (table i64 9223372036854775807 9223372036854775807 funcref)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-table-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          9223372036854775807UL,
          Some(9223372036854775807UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-table-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x29\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-table-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (table i64 9223372036854775807 9223372036854775807 funcref)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-table-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          9223372036854775807UL,
          Some(9223372036854775807UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-table-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x35\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x15\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"value\") i64 9223372036854775807 9223372036854775807 funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          9223372036854775807UL,
          Some(9223372036854775807UL),
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-memory-past-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-past-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 9223372036854775808 9223372036854775808 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-past-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(9223372036854775808UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-memory-past-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-memory-past-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory i64 9223372036854775808 9223372036854775808 (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-memory-past-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(9223372036854775808UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-past-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x37\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x17\x01\x0d\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-past-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 9223372036854775808 9223372036854775808 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-past-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(9223372036854775808UL),
          true,
          false,
          Some(0),
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-table-past-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-table-past-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (table i64 9223372036854775808 9223372036854775808 funcref)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-table-past-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          9223372036854775808UL,
          Some(9223372036854775808UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-table-past-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-table-past-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (table i64 9223372036854775808 9223372036854775808 funcref)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-table-past-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          9223372036854775808UL,
          Some(9223372036854775808UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-table-past-i64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x37\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x17\x01\x70\x05\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-past-i64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"value\") i64 9223372036854775808 9223372036854775808 funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-past-i64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          9223372036854775808UL,
          Some(9223372036854775808UL),
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-memory-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-u64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 18446744073709551615 18446744073709551615 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-u64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-memory-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-memory-u64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory i64 18446744073709551615 18446744073709551615 (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-memory-u64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x37\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x17\x01\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-u64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 18446744073709551615 18446744073709551615 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-u64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-table-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-table-u64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (table i64 18446744073709551615 18446744073709551615 funcref)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-table-u64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-table-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-table-u64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (table i64 18446744073709551615 18446744073709551615 funcref)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-table-u64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-table-u64" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x37\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x17\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-u64.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"value\") i64 18446744073709551615 18446744073709551615 funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-u64.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-page-default" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x08\x01\x10\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-page-default.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory 1 (pagesize 65536))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-page-default.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, None, false, false, Some(16)), },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-page-default" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x08\x01\x10\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-page-default.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory 1 (pagesize 65536))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-page-default.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, None, false, false, Some(16)), },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-page-default" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x08\x01\x10\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-page-default.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") 1 (pagesize 65536))) (export \"m\" (core module $m)))",
    source_id="concrete-page-default.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      { name: "value", kind: Memory(1UL, None, false, false, Some(16)), },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-page-byte" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x08\xff\xff\xff\xff\x0f\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-page-byte.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory 4294967295 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-page-byte.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967295UL, None, false, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-page-byte" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x08\xff\xff\xff\xff\x0f\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-page-byte.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory 4294967295 (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-page-byte.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967295UL, None, false, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-page-byte" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x28\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x08\x01\x08\xff\xff\xff\xff\x0f\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-page-byte.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") 4294967295 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-page-byte.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(4294967295UL, None, false, false, Some(0)),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-page-absent" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x00\x01\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-page-absent.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory 1)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-page-absent.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Memory(1UL, None, false, false, None), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-page-absent" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x00\x01\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-page-absent.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory 1)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-page-absent.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Memory(1UL, None, false, false, None), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-page-absent" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-page-absent.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") 1)) (export \"m\" (core module $m)))",
    source_id="concrete-page-absent.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Memory(1UL, None, false, false, None), }],
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-memory-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0f\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-shared.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 9223372036854775808 18446744073709551615 shared (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-shared.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(18446744073709551615UL),
          true,
          true,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-memory-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0f\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-memory-shared.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (memory i64 9223372036854775808 18446744073709551615 shared (pagesize 1))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-memory-shared.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(18446744073709551615UL),
          true,
          true,
          Some(0),
        ),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x37\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x17\x01\x0f\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-shared.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 9223372036854775808 18446744073709551615 shared (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-shared.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          9223372036854775808UL,
          Some(18446744073709551615UL),
          true,
          true,
          Some(0),
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7e\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-global.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (global i64)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-global.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i64"), false, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7e\x00\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-global.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (global i64)))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-global.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i64"), false, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-global-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x01\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-global-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (global (mut i32))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-global-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), true, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-global-mut" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x01\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-global-mut.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (global (mut i32))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-global-mut.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), true, false), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-global-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x02\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-global-shared.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (global (shared i32))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-global-shared.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instance-global-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x42\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x03\x7f\x02\x04\x00\x01\x6d\x00\x11\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x69\x05\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instance-global-shared.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $i (instance (core type $m (module (export \"value\" (global (shared i32))))) (export \"m\" (core module (type $m))))) (import \"i\" (instance $i (type $i))) (export \"i\" (instance $i)))",
    source_id="instance-global-shared.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i32"), false, true), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "1",
    "i",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "1",
    "i",
    "instance",
    "interface",
    "",
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
    "i",
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instantiate-memory-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x17\x01\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x02\x04\x01\x00\x00\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x22\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x00\x11\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-memory-equal.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $provider (memory (export \"value\") i64 18446744073709551615 18446744073709551615 (pagesize 1))) (core instance $p (instantiate $provider)) (core module $consumer (import \"env\" \"value\" (memory i64 18446744073709551615 18446744073709551615 (pagesize 1)))) (core instance (instantiate $consumer (with \"env\" (instance $p)))) (export \"m\" (core module $provider)))",
    source_id="instantiate-memory-equal.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
          Some(0),
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instantiate-memory-min-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x15\x01\x0d\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x02\x04\x01\x00\x00\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x22\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x02\x0d\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x00\x11\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-memory-min-mismatch.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $provider (memory (export \"value\") i64 9223372036854775807 9223372036854775807 (pagesize 1))) (core instance $p (instantiate $provider)) (core module $consumer (import \"env\" \"value\" (memory i64 9223372036854775808 9223372036854775808 (pagesize 1)))) (core instance (instantiate $consumer (with \"env\" (instance $p)))) (export \"m\" (core module $provider)))",
    source_id="instantiate-memory-min-mismatch.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits instantiate-memory-max-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x17\x01\x0d\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x02\x04\x01\x00\x00\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x20\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x00\x11\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-memory-max-mismatch.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $provider (memory (export \"value\") i64 9223372036854775808 9223372036854775808 (pagesize 1))) (core instance $p (instantiate $provider)) (core module $consumer (import \"env\" \"value\" (memory i64 9223372036854775807 9223372036854775807 (pagesize 1)))) (core instance (instantiate $consumer (with \"env\" (instance $p)))) (export \"m\" (core module $provider)))",
    source_id="instantiate-memory-max-mismatch.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits instantiate-table-equal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x17\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x02\x04\x01\x00\x00\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x22\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x00\x11\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-table-equal.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $provider (table (export \"value\") i64 18446744073709551615 18446744073709551615 funcref)) (core instance $p (instantiate $provider)) (core module $consumer (import \"env\" \"value\" (table i64 18446744073709551615 18446744073709551615 funcref))) (core instance (instantiate $consumer (with \"env\" (instance $p)))) (export \"m\" (core module $provider)))",
    source_id="instantiate-table-equal.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          Some(18446744073709551615UL),
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits instantiate-table-min-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x15\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x02\x04\x01\x00\x00\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x22\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x01\x70\x05\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x00\x11\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-table-min-mismatch.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $provider (table (export \"value\") i64 9223372036854775807 9223372036854775807 funcref)) (core instance $p (instantiate $provider)) (core module $consumer (import \"env\" \"value\" (table i64 9223372036854775808 9223372036854775808 funcref))) (core instance (instantiate $consumer (with \"env\" (instance $p)))) (export \"m\" (core module $provider)))",
    source_id="instantiate-table-min-mismatch.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits instantiate-table-max-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x3e\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x17\x01\x70\x05\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x02\x04\x01\x00\x00\x00\x01\x3c\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x20\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x10\x04\x6e\x61\x6d\x65\x00\x09\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x00\x11\x02\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x01\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x06\x00\x12\x01\x00\x01\x70"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="instantiate-table-max-mismatch.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $provider (table (export \"value\") i64 9223372036854775808 9223372036854775808 funcref)) (core instance $p (instantiate $provider)) (core module $consumer (import \"env\" \"value\" (table i64 9223372036854775807 9223372036854775807 funcref))) (core instance (instantiate $consumer (with \"env\" (instance $p)))) (export \"m\" (core module $provider)))",
    source_id="instantiate-table-max-mismatch.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits component-memory-reversed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-reversed.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 18446744073709551615 9223372036854775808 (pagesize 1))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-reversed.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits concrete-memory-reversed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x17\x01\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-reversed.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory i64 18446744073709551615 9223372036854775808 (pagesize 1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-reversed.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits component-table-reversed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2b\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-table-reversed.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (table i64 18446744073709551615 9223372036854775808 funcref)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-table-reversed.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits concrete-table-reversed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x17\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-reversed.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table i64 18446744073709551615 9223372036854775808 funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-reversed.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits component-memory-bound" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x04\x81\x80\x80\x80\x80\x80\x40\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory-bound.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory i64 281474976710657)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory-bound.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits concrete-memory-bound" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x09\x01\x04\x81\x80\x80\x80\x80\x80\x40\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-bound.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory i64 281474976710657)) (export \"m\" (core module $m)))",
    source_id="concrete-memory-bound.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits component-memory32-bound" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x19\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x00\x81\x80\x04\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-memory32-bound.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory 65537)))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-memory32-bound.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits concrete-memory32-bound" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1a\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x05\x01\x00\x81\x80\x04\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory32-bound.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory 65537)) (export \"m\" (core module $m)))",
    source_id="concrete-memory32-bound.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits component-page-invalid" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x41\x02\x00\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x08\x01\x08\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-page-invalid.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (export \"value\" (memory 1 (pagesize 256))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-page-invalid.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits concrete-page-invalid" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x19\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x08\x01\x08\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-page-invalid.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory 1 (pagesize 256))) (export \"m\" (core module $m)))",
    source_id="concrete-page-invalid.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits concrete-global" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7e\x00\x42\x00\x0b\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-global.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"value\") i64 (i64.const 0))) (export \"m\" (core module $m)))",
    source_id="concrete-global.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [{ name: "value", kind: Global(Scalar("i64"), false, false), }],
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-global-shared" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x00\x0b\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-global-shared.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (global (export \"value\") (shared i32) (i32.const 0))) (export \"m\" (core module $m)))",
    source_id="concrete-global-shared.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
    assert_eq(errors[0].code, "WAC-B002")
    assert_true(errors[0].message.contains("shared"))
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits outer-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x17\x01\x50\x01\x03\x05\x76\x61\x6c\x75\x65\x02\x0c\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x07\x10\x01\x41\x02\x02\x00\x10\x02\x01\x00\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x1e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="outer-alias.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (export \"value\" (memory i64 18446744073709551615 (pagesize 1))))) (type $c (component (alias outer 1 $m (core type $copy)) (import \"m\" (core module (type $copy))))) (export \"c\" (type $c)))",
    source_id="outer-alias.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(18446744073709551615UL, None, true, false, Some(0)),
      },
    ],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits nested-concrete" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x5e\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x0d\x01\x70\x04\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x1b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x02\x01\x63\x01\x06\x00\x11\x01\x00\x01\x6d\x0b\x07\x01\x00\x01\x63\x04\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x04\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="nested-concrete.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (component $c (core module $m (table (export \"value\") i64 18446744073709551615 funcref)) (export \"m\" (core module $m))) (export \"c\" (component $c)))",
    source_id="nested-concrete.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          None,
          true,
          false,
        ),
      },
    ],
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-import-page-default" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x10\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x02\x0d\x01\x02\x10\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-import-page-default.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"value\" (memory i64 1 2 (pagesize 65536))) (export \"value\" (memory 0))) (export \"m\" (core module $m)))",
    source_id="concrete-import-page-default.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "value",
        kind: Memory(1UL, Some(2UL), true, false, Some(16)),
      },
    ],
    exports: [
      { name: "value", kind: Memory(1UL, Some(2UL), true, false, Some(16)), },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-import-mixed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x7b\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x35\x03\x03\x65\x6e\x76\x05\x74\x61\x62\x6c\x65\x01\x70\x04\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x03\x65\x6e\x76\x06\x67\x6c\x6f\x62\x61\x6c\x03\x7e\x00\x03\x65\x6e\x76\x06\x6d\x65\x6d\x6f\x72\x79\x02\x0c\x01\x10\x05\x10\x02\x0c\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x08\x01\x10\x07\x1d\x03\x04\x62\x79\x74\x65\x02\x01\x07\x64\x65\x66\x61\x75\x6c\x74\x02\x02\x08\x69\x6d\x70\x6f\x72\x74\x65\x64\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-import-mixed.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"table\" (table i64 18446744073709551615 funcref)) (import \"env\" \"global\" (global i64)) (import \"env\" \"memory\" (memory i64 1 (pagesize 65536))) (memory (export \"byte\") i64 18446744073709551615 (pagesize 1)) (memory (export \"default\") 1 (pagesize 65536)) (export \"imported\" (memory 0))) (export \"m\" (core module $m)))",
    source_id="concrete-import-mixed.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "table",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          None,
          true,
          false,
        ),
      },
      {
        module_name: "env",
        name: "global",
        kind: Global(Scalar("i64"), false, false),
      },
      {
        module_name: "env",
        name: "memory",
        kind: Memory(1UL, None, true, false, Some(16)),
      },
    ],
    exports: [
      {
        name: "byte",
        kind: Memory(18446744073709551615UL, None, true, false, Some(0)),
      },
      { name: "default", kind: Memory(1UL, None, false, false, Some(16)), },
      { name: "imported", kind: Memory(1UL, None, true, false, Some(16)), },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-inline-import-page-default" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x10\x01\x03\x65\x6e\x76\x05\x76\x61\x6c\x75\x65\x02\x0d\x01\x02\x10\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-inline-import-page-default.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") (import \"env\" \"value\") i64 1 2 (pagesize 65536))) (export \"m\" (core module $m)))",
    source_id="concrete-inline-import-page-default.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "value",
        kind: Memory(1UL, Some(2UL), true, false, Some(16)),
      },
    ],
    exports: [
      { name: "value", kind: Memory(1UL, Some(2UL), true, false, Some(16)), },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits component-imports" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4c\x01\x41\x02\x00\x50\x04\x00\x03\x65\x6e\x76\x03\x6d\x65\x6d\x02\x0c\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x00\x03\x65\x6e\x76\x03\x74\x61\x62\x01\x70\x04\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x03\x65\x6e\x76\x01\x67\x03\x7f\x02\x03\x03\x6d\x65\x6d\x02\x08\x01\x10\x03\x00\x01\x6d\x00\x11\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="component-imports.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $m (module (import \"env\" \"mem\" (memory i64 18446744073709551615 (pagesize 1))) (import \"env\" \"tab\" (table i64 9223372036854775808 funcref)) (import \"env\" \"g\" (global (shared i32))) (export \"mem\" (memory 1 (pagesize 65536))))) (import \"m\" (core module (type $m))))) (export \"c\" (type $c)))",
    source_id="component-imports.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [
      {
        module_name: "env",
        name: "mem",
        kind: Memory(18446744073709551615UL, None, true, false, Some(0)),
      },
      {
        module_name: "env",
        name: "tab",
        kind: Table(
          Reference(true, "func"),
          9223372036854775808UL,
          None,
          true,
          false,
        ),
      },
      {
        module_name: "env",
        name: "g",
        kind: Global(Scalar("i32"), false, true),
      },
    ],
    exports: [{ name: "mem", kind: Memory(1UL, None, false, false, Some(16)), }],
  }
  let expected = [
    "world",
    "",
    "0",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "instance",
    "interface",
    "",
    "0",
    "1",
    "c",
    "type",
    "world",
    "",
    "0",
    "1",
    "m",
    "module",
    core_0.to_repr().to_string(),
    "0",
    "definitions",
    "0",
  ]
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-table-hex" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x0d\x01\x70\x04\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x01\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-table-hex.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (table (export \"value\") i64 +0xffff_ffff_ffff_ffff funcref)) (export \"m\" (core module $m)))",
    source_id="concrete-table-hex.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Table(
          Reference(true, "func"),
          18446744073709551615UL,
          None,
          true,
          false,
        ),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits concrete-memory-decimal" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x0d\x01\x0c\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\x07\x09\x01\x05\x76\x61\x6c\x75\x65\x02\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="concrete-memory-decimal.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module $m (memory (export \"value\") i64 +18_446_744_073_709_551_615 (pagesize +1))) (export \"m\" (core module $m)))",
    source_id="concrete-memory-decimal.wat",
  )
  let core_0 : @core_types.Module = {
    imports: [],
    exports: [
      {
        name: "value",
        kind: Memory(18446744073709551615UL, None, true, false, Some(0)),
      },
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
  for result in [binary, text] {
    guard result is Ok(model) else {
      fail(
        match result {
          Err(errors) => errors[0].render()
          _ => "unreachable"
        },
      )
      continue
    }
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
test "core limits malformed-concrete-u64-overflow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x16\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x0c\x01\x04\xff\xff\xff\xff\xff\xff\xff\xff\xff\x02"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-u64-overflow.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\16\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\0c\\01\\04\\ff\\ff\\ff\\ff\\ff\\ff\\ff\\ff\\ff\\02\")",
    source_id="malformed-concrete-u64-overflow.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-u64-overflow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x04\xff\xff\xff\xff\xff\xff\xff\xff\xff\x02"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-u64-overflow.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\15\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\04\\ff\\ff\\ff\\ff\\ff\\ff\\ff\\ff\\ff\\02\")",
    source_id="malformed-nested-u64-overflow.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-u64-unterminated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x16\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x0c\x01\x04\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-u64-unterminated.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\16\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\0c\\01\\04\\80\\80\\80\\80\\80\\80\\80\\80\\80\\80\")",
    source_id="malformed-concrete-u64-unterminated.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-u64-unterminated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x04\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-u64-unterminated.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\15\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\04\\80\\80\\80\\80\\80\\80\\80\\80\\80\\80\")",
    source_id="malformed-nested-u64-unterminated.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-limit-truncated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x05\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-limit-truncated.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0d\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\03\\01\\05\\00\")",
    source_id="malformed-concrete-limit-truncated.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-limit-truncated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x05\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-limit-truncated.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\0c\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\05\\00\")",
    source_id="malformed-nested-limit-truncated.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-page-truncated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x0c\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-page-truncated.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0d\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\03\\01\\0c\\00\")",
    source_id="malformed-concrete-page-truncated.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-page-truncated" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x0c\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-page-truncated.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\0c\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\0c\\00\")",
    source_id="malformed-nested-page-truncated.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-page-overflow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x12\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x08\x01\x0c\x00\xff\xff\xff\xff\x10"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-page-overflow.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\12\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\08\\01\\0c\\00\\ff\\ff\\ff\\ff\\10\")",
    source_id="malformed-concrete-page-overflow.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-page-overflow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x0c\x00\xff\xff\xff\xff\x10"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-page-overflow.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\11\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\0c\\00\\ff\\ff\\ff\\ff\\10\")",
    source_id="malformed-nested-page-overflow.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-page-invalid" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0e\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x04\x01\x0c\x00\x20"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-page-invalid.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0e\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\04\\01\\0c\\00\\20\")",
    source_id="malformed-concrete-page-invalid.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-page-invalid" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x0c\x00\x20"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-page-invalid.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\0d\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\0c\\00\\20\")",
    source_id="malformed-nested-page-invalid.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-flags-invalid" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x10\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-flags-invalid.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0d\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\03\\01\\10\\00\")",
    source_id="malformed-concrete-flags-invalid.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-flags-invalid" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x10\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-flags-invalid.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\0c\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\10\\00\")",
    source_id="malformed-nested-flags-invalid.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-concrete-shared-without-max" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x0d\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x06\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-concrete-shared-without-max.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\01\\0d\\00\\61\\73\\6d\\01\\00\\00\\00\\05\\03\\01\\06\\00\")",
    source_id="malformed-concrete-shared-without-max.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}

///|
test "core limits malformed-nested-shared-without-max" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x01\x41\x01\x00\x50\x01\x03\x01\x6d\x02\x06\x00"
  let binary = @verifier.decode_component_package(
    bytes,
    source_id="malformed-nested-shared-without-max.wasm",
  )
  let text = @verifier.decode_wat_component_package(
    "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\0c\\01\\41\\01\\00\\50\\01\\03\\01\\6d\\02\\06\\00\")",
    source_id="malformed-nested-shared-without-max.wat",
  )
  for result in [binary, text] {
    guard result is Err(errors) else {
      fail("invalid limits accepted")
      continue
    }
    assert_true(errors[0].code.has_prefix("WAC-B"))
    assert_true(!errors[0].message.is_empty())
  }
  assert_true(
    @binary_validation.validate_declarative_component(bytes) is Err(_),
  )
}
