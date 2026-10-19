///|
test "core WAT data-bytes" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (memory 1) (data (i32.const 0) \"\\ff\\00\\80\\c3\\a9\")) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({ imports: [], exports: [], })
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
}

///|
test "core WAT data-unicode" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (memory 1) (data (i32.const 0) \"crab 🦀\")) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({ imports: [], exports: [], })
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
}

///|
test "core WAT export-invalid-name" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"\\ff\"))) (export \"module\" (core module $m)))\n",
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

///|
test "core WAT flat-folded-control" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) block (result i32) (if (result i32) (i32.const 1) (then (i32.const 2)) (else (i32.const 3))) end)) (export \"module\" (core module $m)))\n",
  )
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
}

///|
test "core WAT folded-flat-control" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (func (export \"f\") (result i32) (block (result i32) i32.const 1 if (result i32) i32.const 2 else i32.const 3 end))) (export \"module\" (core module $m)))\n",
  )
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
}

///|
test "core WAT import-inline-forward" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"f\" (func $f (type $t) (param i32))) (type $t (func (param i32))) (export \"f\" (func $f))) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
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
}

///|
test "core WAT import-inline-mismatch" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (type $t (func (param i32) (result i64))) (import \"env\" \"f\" (func (type $t) (param i64) (result i64)))) (export \"module\" (core module $m)))\n",
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

///|
test "core WAT import-inline-named-param" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (type $t (func (param i32))) (import \"env\" \"f\" (func $f (type $t) (param $x i32))) (export \"f\" (func $f))) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
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
}

///|
test "core WAT import-inline-reference-spelling" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (type $t (func (param funcref))) (import \"env\" \"f\" (func $f (type $t) (param (ref null func)))) (export \"f\" (func $f))) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "f",
        kind: Func({ params: [Reference(true, "func")], results: [], }),
      },
    ],
    exports: [
      {
        name: "f",
        kind: Func({ params: [Reference(true, "func")], results: [], }),
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
}

///|
test "core WAT import-inline-type" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (type $t (func (param i32) (result i64))) (import \"env\" \"f\" (func $f (type $t) (param i32) (result i64))) (export \"f\" (func $f))) (export \"module\" (core module $m)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let kind_0 : @verifier.TypeKind = Module({
    imports: [
      {
        module_name: "env",
        name: "f",
        kind: Func({ params: [Scalar("i32")], results: [Scalar("i64")], }),
      },
    ],
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
}

///|
test "core WAT import-invalid-item-name" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"env\" \"\\ff\" (func))) (export \"module\" (core module $m)))\n",
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

///|
test "core WAT import-invalid-module-name" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (import \"\\ff\" \"f\" (func))) (export \"module\" (core module $m)))\n",
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

///|
test "core WAT import-result-mismatch" {
  let result = @verifier.decode_wat_component_package(
    "(component (core module $m (type $t (func (param i32) (result i64))) (import \"env\" \"f\" (func (type $t) (param i32) (result i32)))) (export \"module\" (core module $m)))\n",
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
