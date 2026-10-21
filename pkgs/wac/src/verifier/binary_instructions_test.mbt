// Original instruction probes exercise the complete binary and WAT verification paths.

///|
test "public gc instructions struct-packed-get-s" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x03\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i8))) (func  ref.null 0 struct.get_s 0 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x03\x00\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions struct-packed-get-u" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x77\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x04\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i16))) (func  ref.null 0 struct.get_u 0 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x77\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x04\x00\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions struct-packed-plain-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i8))) (func  ref.null 0 struct.get 0 0 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions struct-unpacked-packed-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x03\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i32))) (func  ref.null 0 struct.get_s 0 0 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions struct-field-out-of-range" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x63\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i32))) (func  ref.null 0 struct.get 0 99 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions struct-set-out-of-range" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x7f\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x05\x00\x63\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field (mut i32)))) (func  ref.null 0 i32.const 0 struct.set 0 99)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions struct-default-nonnullable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x03\x5f\x00\x5f\x01\x64\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x08\x01\x06\x00\xfb\x01\x01\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct)) (type (struct (field (ref 0)))) (func  struct.new_default 1 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions struct-default-nullable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x03\x5f\x00\x5f\x01\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x08\x01\x06\x00\xfb\x01\x01\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct)) (type (struct (field (ref null 0)))) (func  struct.new_default 1 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x03\x5f\x00\x5f\x01\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x08\x01\x06\x00\xfb\x01\x01\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-packed-plain-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0b\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i8)) (func  ref.null 0 i32.const 0 array.get 0 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-packed-get-s" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0c\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i8)) (func  ref.null 0 i32.const 0 array.get_s 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0c\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-unpacked-packed-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0d\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i32)) (func  ref.null 0 i32.const 0 array.get_u 0 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-default-nonnullable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5f\x00\x5e\x64\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x0a\x01\x08\x00\x41\x00\xfb\x07\x01\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct)) (type (array (ref 0))) (func  i32.const 0 array.new_default 1 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-default-nullable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5f\x00\x5e\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x0a\x01\x08\x00\x41\x00\xfb\x07\x01\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct)) (type (array (ref null 0))) (func  i32.const 0 array.new_default 1 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5f\x00\x5e\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x0a\x01\x08\x00\x41\x00\xfb\x07\x01\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-fixed-huge-unreachable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0e\x01\x0c\x00\x00\xfb\x08\x00\xff\xff\xff\xff\x0f\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i32)) (func  unreachable array.new_fixed 0 4294967295 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0e\x01\x0c\x00\x00\xfb\x08\x00\xff\xff\xff\xff\x0f\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-fixed-huge-reachable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xfb\x08\x00\xff\xff\xff\xff\x0f\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i32)) (func  array.new_fixed 0 4294967295 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-copy-reference-subtyping" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x6e\x01\x5e\x6c\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut anyref))) (type (array i31ref)) (func  ref.null 0 i32.const 0 ref.null 1 i32.const 0 i32.const 1 array.copy 0 1)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x6e\x01\x5e\x6c\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-copy-reference-reversed" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x6c\x01\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i31ref))) (type (array anyref)) (func  ref.null 0 i32.const 0 ref.null 1 i32.const 0 i32.const 1 array.copy 0 1)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-copy-packed-different" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x78\x01\x5e\x77\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i8))) (type (array i16)) (func  ref.null 0 i32.const 0 ref.null 1 i32.const 0 i32.const 1 array.copy 0 1)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-copy-packed-same" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x78\x01\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i8))) (type (array i8)) (func  ref.null 0 i32.const 0 ref.null 1 i32.const 0 i32.const 1 array.copy 0 1)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x78\x01\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-new-elem-subtyping" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x0d\x01\x0b\x00\x41\x00\x41\x00\xfb\x0a\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array anyref)) (elem i31ref (ref.i31 (i32.const 1))) (func  i32.const 0 i32.const 0 array.new_elem 0 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x0d\x01\x0b\x00\x41\x00\x41\x00\xfb\x0a\x00\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-new-elem-numeric" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x09\x04\x01\x05\x70\x00\x0a\x0d\x01\x0b\x00\x41\x00\x41\x00\xfb\x0a\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i32)) (elem funcref) (func  i32.const 0 i32.const 0 array.new_elem 0 0 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-init-elem-subtyping" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x01\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x00\xfb\x13\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut anyref))) (elem i31ref (ref.i31 (i32.const 1))) (func  ref.null 0 i32.const 0 i32.const 0 i32.const 0 array.init_elem 0 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x01\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x00\xfb\x13\x00\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-init-elem-numeric" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x01\x60\x00\x00\x03\x02\x01\x01\x09\x04\x01\x05\x70\x00\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x00\xfb\x13\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i32))) (elem funcref) (func  ref.null 0 i32.const 0 i32.const 0 i32.const 0 array.init_elem 0 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions ref-is-null-number" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x41\x00\xd1\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  i32.const 0 ref.is_null drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions unreachable-select-ref" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x00\xd0\x70\x41\x01\x1b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  unreachable ref.null func i32.const 1 select drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions unreachable-select-number" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x00\x41\x00\x1b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  unreachable i32.const 0 select drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x00\x41\x00\x1b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions unreachable-reference-to-number" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x00\xd4\x45\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  unreachable ref.as_non_null i32.eqz drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions unreachable-reference-to-ref" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x00\xd4\xd1\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  unreachable ref.as_non_null ref.is_null drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x00\xd4\xd1\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions ref-test-wrong-hierarchy" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x70\xfb\x14\x6b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null func ref.test (ref struct) drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions ref-test-shared-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\xd0\x6e\xfb\x14\x65\x6b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null any ref.test (ref (shared struct)) drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions ref-cast-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0c\x01\x0a\x00\xd0\x65\x6e\xfb\x16\x65\x6b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null (shared any) ref.cast (ref (shared struct)) drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0c\x01\x0a\x00\xd0\x65\x6e\xfb\x16\x65\x6b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions ref-eq-functions" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x70\xd0\x70\xd3\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null func ref.null func ref.eq drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions ref-eq-shared-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\xd0\x6d\xd0\x65\x6d\xd3\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null eq ref.null (shared eq) ref.eq drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions ref-i31-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x00\x01\x64\x65\x6c\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x41\x01\xfe\x72\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func (result (ref (shared i31))) i32.const 1 ref.i31_shared)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x00\x01\x64\x65\x6c\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x41\x01\xfe\x72\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions global-ref-i31-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x14\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x0a\x01\x64\x65\x6c\x00\x41\x01\xfe\x72\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (global (ref (shared i31)) (ref.i31_shared (i32.const 1)))))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x14\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x0a\x01\x64\x65\x6c\x00\x41\x01\xfe\x72\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions any-convert-extern-nonnullable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x01\x60\x01\x64\x6f\x01\x64\x6e\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func (param (ref extern)) (result (ref any)) local.get 0 any.convert_extern)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x01\x60\x01\x64\x6f\x01\x64\x6e\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions extern-convert-any-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x01\x60\x01\x64\x65\x6e\x01\x64\x65\x6f\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func (param (ref (shared any))) (result (ref (shared extern))) local.get 0 extern.convert_any)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x01\x60\x01\x64\x65\x6e\x01\x64\x65\x6f\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions br-on-cast-prefix" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x00\x02\x7f\x6d\x03\x02\x01\x00\x0a\x19\x01\x17\x00\x02\x01\x41\x01\xd0\x6e\xfb\x18\x03\x00\x6e\x6d\x1a\x1a\x41\x02\xd0\x6d\x0b\x1a\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result i32 (ref null eq)) i32.const 1 ref.null any br_on_cast 0 (ref null any) (ref null eq) drop drop i32.const 2 ref.null eq end drop drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x00\x02\x7f\x6d\x03\x02\x01\x00\x0a\x19\x01\x17\x00\x02\x01\x41\x01\xd0\x6e\xfb\x18\x03\x00\x6e\x6d\x1a\x1a\x41\x02\xd0\x6d\x0b\x1a\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions br-on-cast-empty-label" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x40\xd0\x6e\xfb\x18\x03\x00\x6e\x6d\x1a\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block ref.null any br_on_cast 0 (ref null any) (ref null eq) drop end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions br-on-cast-upcast" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x6e\xd0\x6d\xfb\x18\x03\x00\x6d\x6e\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result anyref) ref.null eq br_on_cast 0 (ref null eq) (ref null any) end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions br-on-cast-fail" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x6e\xd0\x6e\xfb\x19\x01\x00\x6e\x6d\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result anyref) ref.null any br_on_cast_fail 0 (ref null any) (ref eq) end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x6e\xd0\x6e\xfb\x19\x01\x00\x6e\x6d\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions br-on-non-null-numeric-label" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x20\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0c\x01\x0a\x00\x02\x7f\x41\x00\xd6\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result i32) i32.const 0 br_on_non_null 0 end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions constant-struct-new" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x06\x0a\x01\x64\x00\x00\x41\x01\xfb\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i32))) (global (ref 0) (struct.new 0 (i32.const 1)))))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x06\x0a\x01\x64\x00\x00\x41\x01\xfb\x00\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions constant-struct-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x06\x0d\x01\x7f\x00\x41\x01\xfb\x00\x00\xfb\x02\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i32))) (global i32 (struct.get 0 0 (struct.new 0 (i32.const 1))))))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions constant-array-new-fixed" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x5e\x7f\x00\x06\x0d\x01\x64\x00\x00\x41\x01\x41\x02\xfb\x08\x00\x02\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i32)) (global (ref 0) (array.new_fixed 0 2 (i32.const 1) (i32.const 2)))))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x5e\x7f\x00\x06\x0d\x01\x64\x00\x00\x41\x01\x41\x02\xfb\x08\x00\x02\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions constant-conversion" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x12\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x08\x01\x6e\x00\xd0\x6f\xfb\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (global (ref null any) (any.convert_extern (ref.null extern)))))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x12\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x08\x01\x6e\x00\xd0\x6f\xfb\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions table-init-global-forward" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x04\x0a\x01\x40\x00\x64\x70\x00\x01\x23\x00\x0b\x06\x07\x01\x64\x70\x00\xd2\x00\x0b\x0a\x04\x01\x02\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (table 1 (ref func) (global.get 0)) (global (ref func) (ref.func 0)) (func)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions table-init-ref-func-declares" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x03\x02\x00\x00\x04\x0a\x01\x40\x00\x64\x70\x00\x01\xd2\x00\x0b\x0a\x0a\x02\x02\x00\x0b\x05\x00\xd2\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (table 1 (ref func) (ref.func 0)) (func) (func ref.func 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x03\x02\x00\x00\x04\x0a\x01\x40\x00\x64\x70\x00\x01\xd2\x00\x0b\x0a\x0a\x02\x02\x00\x0b\x05\x00\xd2\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions struct-set-mutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x03\xfb\x05\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field (mut i8)))) (func  ref.null 0 i32.const 3 struct.set 0 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x03\xfb\x05\x00\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions struct-set-immutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x03\xfb\x05\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i8))) (func  ref.null 0 i32.const 3 struct.set 0 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions struct-new-packed" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0a\x01\x08\x00\x41\x03\xfb\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (struct (field i8))) (func  i32.const 3 struct.new 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0a\x01\x08\x00\x41\x03\xfb\x00\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-new-numeric" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\x41\x03\x41\x04\xfb\x06\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i32)) (func  i32.const 3 i32.const 4 array.new 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\x41\x03\x41\x04\xfb\x06\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-set-mutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xd0\x00\x41\x00\x41\x01\xfb\x0e\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i8))) (func  ref.null 0 i32.const 0 i32.const 1 array.set 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xd0\x00\x41\x00\x41\x01\xfb\x0e\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-set-immutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xd0\x00\x41\x00\x41\x01\xfb\x0e\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i8)) (func  ref.null 0 i32.const 0 i32.const 1 array.set 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-fill-mutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0f\x01\x0d\x00\xd0\x00\x41\x00\x41\x01\x41\x02\xfb\x10\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i8))) (func  ref.null 0 i32.const 0 i32.const 1 i32.const 2 array.fill 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0f\x01\x0d\x00\xd0\x00\x41\x00\x41\x01\x41\x02\xfb\x10\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-fill-immutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0f\x01\x0d\x00\xd0\x00\x41\x00\x41\x01\x41\x02\xfb\x10\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i8)) (func  ref.null 0 i32.const 0 i32.const 1 i32.const 2 array.fill 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-len-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x65\x6a\xfb\x0f\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null (shared array) array.len drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x65\x6a\xfb\x0f\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-len-non-array" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\xd0\x6b\xfb\x0f\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null struct array.len drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-new-data" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x0d\x01\x0b\x00\x41\x00\x41\x03\xfb\x09\x00\x00\x1a\x0b\x0b\x06\x01\x01\x03\x61\x62\x63",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i8)) (data \"abc\") (func  i32.const 0 i32.const 3 array.new_data 0 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x0d\x01\x0b\x00\x41\x00\x41\x03\xfb\x09\x00\x00\x1a\x0b\x0b\x06\x01\x01\x03\x61\x62\x63",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-new-data-reference" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x0d\x01\x0b\x00\x41\x00\x41\x03\xfb\x09\x00\x00\x1a\x0b\x0b\x06\x01\x01\x03\x61\x62\x63",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array anyref)) (data \"abc\") (func  i32.const 0 i32.const 3 array.new_data 0 0 drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions array-init-data" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x03\xfb\x12\x00\x00\x0b\x0b\x06\x01\x01\x03\x61\x62\x63",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array (mut i8))) (data \"abc\") (func  ref.null 0 i32.const 0 i32.const 0 i32.const 3 array.init_data 0 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x03\xfb\x12\x00\x00\x0b\x0b\x06\x01\x01\x03\x61\x62\x63",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions array-init-data-immutable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x32\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x03\xfb\x12\x00\x00\x0b\x0b\x06\x01\x01\x03\x61\x62\x63",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (array i8)) (data \"abc\") (func  ref.null 0 i32.const 0 i32.const 0 i32.const 3 array.init_data 0 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public gc instructions ref-test-null" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x15\x6d\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null any ref.test (ref null eq) drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x15\x6d\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions ref-cast-null" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x17\x6d\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null any ref.cast (ref null eq) drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x17\x6d\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions shared-struct-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x65\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (shared (struct (field i32)))) (func  ref.null 0 struct.get 0 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x65\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions shared-array-get" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x65\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0b\x00\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (shared (array i32))) (func  ref.null 0 i32.const 0 array.get 0 drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x65\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0b\x00\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions table-copy-concrete-subtyping" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x35\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x09\x02\x63\x00\x00\x01\x63\x01\x00\x01\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0e\x00\x01\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (sub (func))) (type (sub 0 (func))) (table 1 (ref null 0)) (table 1 (ref null 1)) (func  i32.const 0 i32.const 0 i32.const 0 table.copy 0 1)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x35\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x09\x02\x63\x00\x00\x01\x63\x01\x00\x01\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0e\x00\x01\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public gc instructions table-init-concrete-subtyping" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x38\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x05\x01\x63\x00\x00\x01\x09\x05\x01\x05\x63\x01\x00\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0c\x00\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (type (sub (func))) (type (sub 0 (func))) (table 1 (ref null 0)) (elem (ref null 1)) (func  i32.const 0 i32.const 0 i32.const 0 table.init 0 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x38\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x05\x01\x63\x00\x00\x01\x09\x05\x01\x05\x63\x01\x00\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0c\x00\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions throw-params" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7e\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x08\x01\x06\x00\x41\x01\x08\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func (result i64) i32.const 1 throw 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7e\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x08\x01\x06\x00\x41\x01\x08\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions throw-wrong-param" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x08\x01\x06\x00\x42\x01\x08\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func  i64.const 1 throw 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions throw-unknown-tag" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x08\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  throw 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions throw-ref-null" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\xd0\x69\x0a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null exn throw_ref)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\xd0\x69\x0a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions throw-ref-nonnull" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x64\x69\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\x20\x00\x0a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func (param (ref exn)) local.get 0 throw_ref)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x64\x69\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\x20\x00\x0a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions throw-ref-wrong-hierarchy" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\xd0\x6e\x0a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null any throw_ref)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions throw-ref-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\xd0\x65\x69\x0a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  ref.null (shared exn) throw_ref)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-catch-param" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x31\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7f\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x13\x01\x11\x00\x02\x7f\x1f\x40\x01\x00\x00\x00\x41\x01\x08\x00\x0b\x00\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func (result i32) block (result i32) try_table (catch 0 0) i32.const 1 throw 0 end unreachable end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x31\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7f\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x13\x01\x11\x00\x02\x7f\x1f\x40\x01\x00\x00\x00\x41\x01\x08\x00\x0b\x00\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-own-label-excluded" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x1f\x7f\x01\x00\x00\x00\x41\x01\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func  try_table (result i32) (catch 0 0) i32.const 1 end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-catch-ref-nonnull" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x13\x01\x11\x00\x02\x64\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag) (func  block (result (ref exn)) try_table (catch_ref 0 0) throw 0 end unreachable end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x13\x01\x11\x00\x02\x64\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-catch-ref-nullable" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x12\x01\x10\x00\x02\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag) (func  block (result exnref) try_table (catch_ref 0 0) throw 0 end unreachable end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x12\x01\x10\x00\x02\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-catch-ref-number" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x12\x01\x10\x00\x02\x7f\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag) (func  block (result i32) try_table (catch_ref 0 0) throw 0 end unreachable end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-catch-ref-shared" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x64\x65\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag) (func  block (result (ref (shared exn))) try_table (catch_ref 0 0) throw 0 end unreachable end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-catch-all-ref-nonnull" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x11\x01\x0f\x00\x02\x64\x69\x1f\x40\x01\x03\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result (ref exn)) try_table (catch_all_ref 0) unreachable end unreachable end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x11\x01\x0f\x00\x02\x64\x69\x1f\x40\x01\x03\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-catch-all-ref-number" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x7f\x1f\x40\x01\x03\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result i32) try_table (catch_all_ref 0) unreachable end unreachable end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-catch-all-ref-arity" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x03\x00\x00\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try_table (catch_all_ref 0) unreachable end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-catch-all" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x02\x00\x00\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try_table (catch_all 0) unreachable end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x02\x00\x00\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-catch-all-arity" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x7f\x1f\x40\x01\x02\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block (result i32) try_table (catch_all 0) unreachable end unreachable end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-bad-depth" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\x1f\x40\x01\x02\x01\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try_table (catch_all 1) end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-bad-tag" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x00\x00\x00\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try_table (catch 0 0) end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions try-table-block-params" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x41\x02\x1f\x01\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  i32.const 2 try_table (param i32) (result i32) end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x41\x02\x1f\x01\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-catch-subtype" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x31\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x6c\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x6e\x1f\x40\x01\x00\x00\x00\xd0\x6c\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i31ref)) (func  block (result anyref) try_table (catch 0 0) ref.null i31 throw 0 end unreachable end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x31\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x6c\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x6e\x1f\x40\x01\x00\x00\x00\xd0\x6c\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions try-table-catch-loop-params" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x36\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x03\x60\x01\x6c\x00\x60\x00\x00\x60\x01\x6e\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x15\x01\x13\x00\xd0\x6e\x03\x02\x1a\x1f\x40\x01\x00\x00\x00\xd0\x6c\x08\x00\x0b\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i31ref)) (func  ref.null any loop (param anyref) drop try_table (catch 0 0) ref.null i31 throw 0 end end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x36\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x03\x60\x01\x6c\x00\x60\x00\x00\x60\x01\x6e\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x15\x01\x13\x00\xd0\x6e\x03\x02\x1a\x1f\x40\x01\x00\x00\x00\xd0\x6c\x08\x00\x0b\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-catch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7f\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func  try (result i32) i32.const 1 throw 0 catch 0 end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7f\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-catch-result-mismatch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7e\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func  try (result i64) i32.const 1 throw 0 catch 0 end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions legacy-catch-all" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x06\x40\x00\x19\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try unreachable catch_all end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1d\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x06\x40\x00\x19\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-rethrow" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x06\x40\x00\x19\x09\x00\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try unreachable catch_all rethrow 0 end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x06\x40\x00\x19\x09\x00\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-rethrow-outer" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0e\x01\x0c\x00\x06\x40\x00\x19\x02\x40\x09\x01\x0b\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try unreachable catch_all block rethrow 1 end end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0e\x01\x0c\x00\x06\x40\x00\x19\x02\x40\x09\x01\x0b\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-rethrow-wrong-label" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x22\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0e\x01\x0c\x00\x06\x40\x00\x19\x02\x40\x09\x00\x0b\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try unreachable catch_all block rethrow 0 end end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions legacy-rethrow-outside-catch" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\x06\x40\x09\x00\x19\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try rethrow 0 catch_all end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions legacy-rethrow-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x09\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  rethrow 0)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions legacy-delegate-function" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try delegate 0)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-delegate-invalid-depth" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x01\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try delegate 1)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions legacy-delegate-outer-block" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x02\x40\x06\x40\x18\x00\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  block try delegate 0 end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x02\x40\x06\x40\x18\x00\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-no-catches" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x01\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try nop end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x01\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-catch-arm-reset" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x11\x01\x0f\x00\x06\x7f\x41\x01\x07\x00\x41\x02\x19\x41\x03\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag) (func  try (result i32) i32.const 1 catch 0 i32.const 2 catch_all i32.const 3 end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x11\x01\x0f\x00\x06\x7f\x41\x01\x07\x00\x41\x02\x19\x41\x03\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-catch-param-reset" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x41\x01\x06\x01\x19\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  i32.const 1 try (param i32) (result i32) catch_all end drop)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions legacy-uninitialized-local" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x13\x01\x11\x01\x01\x64\x70\x06\x40\xd0\x70\xd4\x21\x00\x19\x20\x00\x1a\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    false,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func (local (ref func)) try ref.null func ref.as_non_null local.set 0 catch_all local.get 0 drop end)))",
  )
  assert_eq(
    text is Ok(_),
    false,
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
}

///|
test "public exception instructions modern-nested-in-legacy" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0f\x01\x0d\x00\x06\x40\x1f\x40\x01\x02\x00\x00\x0b\x19\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try try_table (catch_all 0) unreachable end catch_all end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0f\x01\x0d\x00\x06\x40\x1f\x40\x01\x02\x00\x00\x0b\x19\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions legacy-nested-in-modern" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0f\x01\x0d\x00\x1f\x40\x01\x02\x00\x06\x40\x00\x19\x0b\x0b\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  try_table (catch_all 0) try unreachable catch_all end end)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0f\x01\x0d\x00\x1f\x40\x01\x02\x00\x06\x40\x00\x19\x0b\x0b\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions folded-legacy" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7f\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func  (try (result i32) (do (i32.const 1) (throw 0)) (catch 0)) drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7f\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions folded-legacy-delegate" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x00\x0b",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module  (func  (try (do) (delegate 0)))))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1c\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x00\x0b",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}

///|
test "public exception instructions named-modern-label" {
  let binary = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x4b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x7f\x1f\x40\x01\x00\x00\x00\x41\x01\x08\x00\x0b\x00\x0b\x1a\x0b\x00\x18\x04\x6e\x61\x6d\x65\x03\x11\x01\x00\x02\x00\x05\x6f\x75\x74\x65\x72\x01\x05\x69\x6e\x6e\x65\x72",
  )
  assert_eq(
    binary is Ok(_),
    true,
    msg=match binary {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core module (tag (param i32)) (func  block $outer (result i32) try_table $inner (catch 0 $outer) i32.const 1 throw 0 end unreachable end drop)))",
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
  let printed = @decompiler.print_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x4b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x7f\x1f\x40\x01\x00\x00\x00\x41\x01\x08\x00\x0b\x00\x0b\x1a\x0b\x00\x18\x04\x6e\x61\x6d\x65\x03\x11\x01\x00\x02\x00\x05\x6f\x75\x74\x65\x72\x01\x05\x69\x6e\x6e\x65\x72",
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  let again = @verifier.decode_wat_component_package(
    printed.unwrap().root().text,
  )
  assert_true(
    again is Ok(_),
    msg=match again {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(binary.unwrap()),
    binary_projection(again.unwrap()),
  )
}
