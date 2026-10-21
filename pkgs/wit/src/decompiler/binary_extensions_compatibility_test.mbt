// Exact wasm-tools 1.262.0 output for the admitted compatibility profile.

///|
test "GC reference printer gc-struct-packed-get-s" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x03\x00\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct (field i8)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    struct.get_s 0 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-struct-packed-get-u" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x77\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x04\x00\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct (field i16)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    struct.get_u 0 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-struct-default-nullable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x03\x5f\x00\x5f\x01\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x08\x01\x06\x00\xfb\x01\x01\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct))\n  (type (;1;) (struct (field (ref null 0))))\n  (type (;2;) (func))\n  (func (;0;) (type 2)\n    struct.new_default 1\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-packed-get-s" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0c\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array i8))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 0\n    array.get_s 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-default-nullable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5f\x00\x5e\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x0a\x01\x08\x00\x41\x00\xfb\x07\x01\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct))\n  (type (;1;) (array (ref null 0)))\n  (type (;2;) (func))\n  (func (;0;) (type 2)\n    i32.const 0\n    array.new_default 1\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-fixed-huge-unreachable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0e\x01\x0c\x00\x00\xfb\x08\x00\xff\xff\xff\xff\x0f\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array i32))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    unreachable\n    array.new_fixed 0 4294967295\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-copy-reference-subtyping" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x6e\x01\x5e\x6c\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array (mut anyref)))\n  (type (;1;) (array i31ref))\n  (type (;2;) (func))\n  (func (;0;) (type 2)\n    ref.null 0\n    i32.const 0\n    ref.null 1\n    i32.const 0\n    i32.const 1\n    array.copy 0 1\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-copy-packed-same" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x78\x01\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array (mut i8)))\n  (type (;1;) (array i8))\n  (type (;2;) (func))\n  (func (;0;) (type 2)\n    ref.null 0\n    i32.const 0\n    ref.null 1\n    i32.const 0\n    i32.const 1\n    array.copy 0 1\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-new-elem-subtyping" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x0d\x01\x0b\x00\x41\x00\x41\x00\xfb\x0a\x00\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array anyref))\n  (type (;1;) (func))\n  (elem (;0;) i31ref (item i32.const 1 ref.i31))\n  (func (;0;) (type 1)\n    i32.const 0\n    i32.const 0\n    array.new_elem 0 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-init-elem-subtyping" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x01\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x00\xfb\x13\x00\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array (mut anyref)))\n  (type (;1;) (func))\n  (elem (;0;) i31ref (item i32.const 1 ref.i31))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 0\n    i32.const 0\n    i32.const 0\n    array.init_elem 0 0\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-unreachable-select-number" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x00\x41\x00\x1b\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    unreachable\n    i32.const 0\n    select\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-unreachable-reference-to-ref" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x00\xd4\xd1\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    unreachable\n    ref.as_non_null\n    ref.is_null\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-ref-cast-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0c\x01\x0a\x00\xd0\x65\x6e\xfb\x16\x65\x6b\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    ref.null (shared any)\n    ref.cast (ref (shared struct))\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-ref-i31-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x00\x01\x64\x65\x6c\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x41\x01\xfe\x72\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func (result (ref (shared i31)))))\n  (func (;0;) (type 0) (result (ref (shared i31)))\n    i32.const 1\n    ref.i31_shared\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-global-ref-i31-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x0a\x01\x64\x65\x6c\x00\x41\x01\xfe\x72\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (global (;0;) (ref (shared i31)) i32.const 1 ref.i31_shared)\n)\n",
  )
}

///|
test "GC reference printer gc-any-convert-extern-nonnullable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x01\x60\x01\x64\x6f\x01\x64\x6e\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func (param (ref extern)) (result (ref any))))\n  (func (;0;) (type 0) (param (ref extern)) (result (ref any))\n    local.get 0\n    any.convert_extern\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-extern-convert-any-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x01\x60\x01\x64\x65\x6e\x01\x64\x65\x6f\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1b\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func (param (ref (shared any))) (result (ref (shared extern)))))\n  (func (;0;) (type 0) (param (ref (shared any))) (result (ref (shared extern)))\n    local.get 0\n    extern.convert_any\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-br-on-cast-prefix" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x00\x02\x7f\x6d\x03\x02\x01\x00\x0a\x19\x01\x17\x00\x02\x01\x41\x01\xd0\x6e\xfb\x18\x03\x00\x6e\x6d\x1a\x1a\x41\x02\xd0\x6d\x0b\x1a\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (type (;1;) (func (result i32 eqref)))\n  (func (;0;) (type 0)\n    block (type 1) (result i32 eqref) ;; label = @1\n      i32.const 1\n      ref.null any\n      br_on_cast 0 (;@1;) anyref eqref\n      drop\n      drop\n      i32.const 2\n      ref.null eq\n    end\n    drop\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-br-on-cast-fail" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x6e\xd0\x6e\xfb\x19\x01\x00\x6e\x6d\x0b\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    block (result anyref) ;; label = @1\n      ref.null any\n      br_on_cast_fail 0 (;@1;) anyref (ref eq)\n    end\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-constant-struct-new" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x06\x0a\x01\x64\x00\x00\x41\x01\xfb\x00\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct (field i32)))\n  (global (;0;) (ref 0) i32.const 1 struct.new 0)\n)\n",
  )
}

///|
test "GC reference printer gc-constant-array-new-fixed" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x5e\x7f\x00\x06\x0d\x01\x64\x00\x00\x41\x01\x41\x02\xfb\x08\x00\x02\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array i32))\n  (global (;0;) (ref 0) i32.const 1 i32.const 2 array.new_fixed 0 2)\n)\n",
  )
}

///|
test "GC reference printer gc-constant-conversion" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x08\x01\x6e\x00\xd0\x6f\xfb\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (global (;0;) anyref ref.null extern any.convert_extern)\n)\n",
  )
}

///|
test "GC reference printer gc-table-init-ref-func-declares" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x03\x02\x00\x00\x04\x0a\x01\x40\x00\x64\x70\x00\x01\xd2\x00\x0b\x0a\x0a\x02\x02\x00\x0b\x05\x00\xd2\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (table (;0;) 1 (ref func) ref.func 0)\n  (func (;0;) (type 0))\n  (func (;1;) (type 0)\n    ref.func 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-struct-set-mutable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x03\xfb\x05\x00\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct (field (mut i8))))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 3\n    struct.set 0 0\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-struct-new-packed" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0a\x01\x08\x00\x41\x03\xfb\x00\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (struct (field i8)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    i32.const 3\n    struct.new 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-new-numeric" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\x41\x03\x41\x04\xfb\x06\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array i32))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    i32.const 3\n    i32.const 4\n    array.new 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-set-mutable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xd0\x00\x41\x00\x41\x01\xfb\x0e\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array (mut i8)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 0\n    i32.const 1\n    array.set 0\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-fill-mutable" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0f\x01\x0d\x00\xd0\x00\x41\x00\x41\x01\x41\x02\xfb\x10\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array (mut i8)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 0\n    i32.const 1\n    i32.const 2\n    array.fill 0\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-len-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x65\x6a\xfb\x0f\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    ref.null (shared array)\n    array.len\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-array-new-data" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x0d\x01\x0b\x00\x41\x00\x41\x03\xfb\x09\x00\x00\x1a\x0b\x0b\x06\x01\x01\x03\x61\x62\x63"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array i8))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    i32.const 0\n    i32.const 3\n    array.new_data 0 0\n    drop\n  )\n  (data (;0;) \"abc\")\n)\n",
  )
}

///|
test "GC reference printer gc-array-init-data" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x03\xfb\x12\x00\x00\x0b\x0b\x06\x01\x01\x03\x61\x62\x63"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (array (mut i8)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 0\n    i32.const 0\n    i32.const 3\n    array.init_data 0 0\n  )\n  (data (;0;) \"abc\")\n)\n",
  )
}

///|
test "GC reference printer gc-ref-test-null" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x15\x6d\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    ref.null any\n    ref.test eqref\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-ref-cast-null" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x17\x6d\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    ref.null any\n    ref.cast eqref\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-shared-struct-get" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x65\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (shared (struct (field i32))))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    struct.get 0 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-shared-array-get" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x65\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0b\x00\x1a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (shared (array i32)))\n  (type (;1;) (func))\n  (func (;0;) (type 1)\n    ref.null 0\n    i32.const 0\n    array.get 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-table-copy-concrete-subtyping" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x09\x02\x63\x00\x00\x01\x63\x01\x00\x01\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0e\x00\x01\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (sub (func)))\n  (type (;1;) (sub 0 (func)))\n  (table (;0;) 1 (ref null 0))\n  (table (;1;) 1 (ref null 1))\n  (func (;0;) (type 0)\n    i32.const 0\n    i32.const 0\n    i32.const 0\n    table.copy 0 1\n  )\n)\n",
  )
}

///|
test "GC reference printer gc-table-init-concrete-subtyping" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x05\x01\x63\x00\x00\x01\x09\x05\x01\x05\x63\x01\x00\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0c\x00\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (sub (func)))\n  (type (;1;) (sub 0 (func)))\n  (table (;0;) 1 (ref null 0))\n  (elem (;0;) (ref null 1))\n  (func (;0;) (type 0)\n    i32.const 0\n    i32.const 0\n    i32.const 0\n    table.init 0\n  )\n)\n",
  )
}

///|
test "GC reference printer exception-throw-params" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7e\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x08\x01\x06\x00\x41\x01\x08\x00\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func (param i32)))\n  (type (;1;) (func (result i64)))\n  (tag (;0;) (type 0) (param i32))\n  (func (;0;) (type 1) (result i64)\n    i32.const 1\n    throw 0\n  )\n)\n",
  )
}

///|
test "GC reference printer exception-throw-ref-null" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\xd0\x69\x0a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func))\n  (func (;0;) (type 0)\n    ref.null exn\n    throw_ref\n  )\n)\n",
  )
}

///|
test "GC reference printer exception-throw-ref-nonnull" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x64\x69\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\x20\x00\x0a\x0b"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type (;0;) (func (param (ref exn))))\n  (func (;0;) (type 0) (param (ref exn))\n    local.get 0\n    throw_ref\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-global-get-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x65\x60\x00\x01\x7f\x03\x02\x01\x00\x06\x06\x01\x7f\x02\x41\x01\x0b\x0a\x06\x01\x04\x00\x23\x00\x0b\x00\x11\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66\x07\x04\x01\x00\x01\x67"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func (result i32))))\n  (global $g (;0;) (shared i32) i32.const 1)\n  (func (;0;) (type $f)\n    global.get $g\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-global-set-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x65\x60\x00\x00\x03\x02\x01\x00\x06\x06\x01\x7f\x03\x41\x01\x0b\x0a\x08\x01\x06\x00\x41\x02\x24\x00\x0b\x00\x11\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66\x07\x04\x01\x00\x01\x67"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func)))\n  (global $g (;0;) (shared mut i32) i32.const 1)\n  (func (;0;) (type $f)\n    i32.const 2\n    global.set $g\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-table-size-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x65\x60\x00\x01\x7f\x03\x02\x01\x00\x04\x05\x01\x65\x70\x02\x01\x0a\x07\x01\x05\x00\xfc\x10\x00\x0b\x00\x0b\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func (result i32))))\n  (table (;0;) shared 1 (ref null (shared func)))\n  (func (;0;) (type $f)\n    table.size 0\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-call-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x02\x65\x60\x00\x01\x7f\x65\x60\x00\x01\x7f\x03\x03\x02\x01\x00\x0a\x0b\x02\x04\x00\x41\x01\x0b\x04\x00\x10\x00\x0b\x00\x23\x04\x6e\x61\x6d\x65\x01\x09\x01\x00\x06\x63\x61\x6c\x6c\x65\x65\x04\x11\x02\x00\x06\x63\x61\x6c\x6c\x65\x72\x01\x06\x63\x61\x6c\x6c\x65\x65"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $caller (;0;) (shared (func (result i32))))\n  (type $callee (;1;) (shared (func (result i32))))\n  (func $callee (;0;) (type $callee)\n    i32.const 1\n  )\n  (func (;1;) (type $caller)\n    call $callee\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-ref-func-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x65\x60\x00\x00\x65\x60\x00\x00\x03\x03\x02\x01\x00\x07\x0a\x01\x06\x63\x61\x6c\x6c\x65\x65\x00\x00\x0a\x0a\x02\x02\x00\x0b\x05\x00\xd2\x00\x1a\x0b\x00\x23\x04\x6e\x61\x6d\x65\x01\x09\x01\x00\x06\x63\x61\x6c\x6c\x65\x65\x04\x11\x02\x00\x06\x63\x61\x6c\x6c\x65\x72\x01\x06\x63\x61\x6c\x6c\x65\x65"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $caller (;0;) (shared (func)))\n  (type $callee (;1;) (shared (func)))\n  (export \"callee\" (func $callee))\n  (func $callee (;0;) (type $callee))\n  (func (;1;) (type $caller)\n    ref.func $callee\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-ref-func-unshared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x65\x60\x00\x00\x60\x00\x00\x03\x03\x02\x01\x00\x07\x0a\x01\x06\x63\x61\x6c\x6c\x65\x65\x00\x00\x0a\x0a\x02\x02\x00\x0b\x05\x00\xd2\x00\x1a\x0b\x00\x23\x04\x6e\x61\x6d\x65\x01\x09\x01\x00\x06\x63\x61\x6c\x6c\x65\x65\x04\x11\x02\x00\x06\x63\x61\x6c\x6c\x65\x72\x01\x06\x63\x61\x6c\x6c\x65\x65"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $caller (;0;) (shared (func)))\n  (type $callee (;1;) (func))\n  (export \"callee\" (func $callee))\n  (func $callee (;0;) (type $callee))\n  (func (;1;) (type $caller)\n    ref.func $callee\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-local-unshared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x65\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x01\x01\x70\x20\x00\x1a\x0b\x00\x0b\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func)))\n  (func (;0;) (type $f)\n    (local funcref)\n    local.get 0\n    drop\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-memory-unshared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x65\x60\x00\x01\x7f\x03\x02\x01\x00\x05\x03\x01\x00\x01\x0a\x09\x01\x07\x00\x41\x00\x28\x02\x00\x0b\x00\x0b\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func (result i32))))\n  (memory (;0;) 1)\n  (func (;0;) (type $f)\n    i32.const 0\n    i32.load\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-call-ref-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x65\x60\x00\x01\x7f\x03\x02\x01\x00\x0a\x08\x01\x06\x00\xd0\x00\x14\x00\x0b\x00\x0b\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func (result i32))))\n  (func (;0;) (type $f)\n    ref.null $f\n    call_ref $f\n  )\n)\n",
  )
}

///|
test "GC reference printer shared-block-type-shared" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x65\x60\x00\x01\x7f\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x02\x00\x41\x01\x0b\x0b\x00\x0b\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (shared (func (result i32))))\n  (func (;0;) (type $f)\n    block (type $f) ;; label = @1\n      i32.const 1\n    end\n  )\n)\n",
  )
}

///|
test "GC reference printer model-recursive-contracts" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x18\x03\x4e\x02\x5f\x01\x63\x01\x00\x5e\x63\x00\x01\x60\x01\x63\x00\x01\x63\x01\x60\x01\x63\x00\x00\x02\x13\x02\x03\x65\x6e\x76\x01\x66\x00\x02\x03\x65\x6e\x76\x01\x67\x03\x63\x00\x00\x03\x02\x01\x02\x04\x05\x01\x63\x01\x00\x01\x05\x04\x01\x01\x01\x02\x0d\x03\x01\x00\x03\x06\x07\x01\x63\x00\x00\xd0\x00\x0b\x07\x20\x05\x05\x74\x61\x62\x6c\x65\x01\x00\x01\x67\x03\x01\x03\x72\x75\x6e\x00\x01\x01\x65\x04\x00\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x0a\x06\x01\x04\x00\xd0\x01\x0b\x00\x11\x04\x6e\x61\x6d\x65\x04\x0a\x03\x00\x01\x73\x01\x01\x61\x02\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (rec\n    (type $s (;0;) (struct (field (ref null $a))))\n    (type $a (;1;) (array (mut (ref null $s))))\n  )\n  (type $f (;2;) (func (param (ref null $s)) (result (ref null $a))))\n  (type (;3;) (func (param (ref null $s))))\n  (import \"env\" \"f\" (func (;0;) (type $f) (param (ref null $s)) (result (ref null $a))))\n  (import \"env\" \"g\" (global (;0;) (ref null $s)))\n  (table (;0;) 1 (ref null $a))\n  (memory (;0;) 1 2)\n  (tag (;0;) (type 3) (param (ref null $s)))\n  (global (;1;) (ref null $s) ref.null $s)\n  (export \"table\" (table 0))\n  (export \"g\" (global 1))\n  (export \"run\" (func 1))\n  (export \"e\" (tag 0))\n  (export \"memory\" (memory 0))\n  (func (;1;) (type $f) (param (ref null $s)) (result (ref null $a))\n    ref.null $a\n  )\n)\n",
  )
}

///|
test "GC reference printer model-nominal-struct-contracts" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x15\x03\x50\x00\x5f\x01\x7f\x00\x50\x01\x00\x5f\x02\x7f\x00\x7e\x01\x60\x00\x01\x64\x00\x03\x02\x01\x02\x06\x0c\x01\x64\x01\x00\x41\x01\x42\x02\xfb\x00\x01\x0b\x07\x10\x02\x04\x6d\x61\x6b\x65\x00\x00\x05\x63\x68\x69\x6c\x64\x03\x00\x0a\x0b\x01\x09\x00\x41\x01\x42\x02\xfb\x00\x01\x0b\x00\x15\x04\x6e\x61\x6d\x65\x04\x0e\x02\x00\x04\x62\x61\x73\x65\x01\x05\x63\x68\x69\x6c\x64"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $base (;0;) (sub (struct (field i32))))\n  (type $child (;1;) (sub $base (struct (field i32) (field (mut i64)))))\n  (type (;2;) (func (result (ref $base))))\n  (global (;0;) (ref $child) i32.const 1 i64.const 2 struct.new $child)\n  (export \"make\" (func 0))\n  (export \"child\" (global 0))\n  (func (;0;) (type 2) (result (ref $base))\n    i32.const 1\n    i64.const 2\n    struct.new $child\n  )\n)\n",
  )
}

///|
test "GC reference printer model-nominal-array-contracts" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x11\x03\x50\x00\x5e\x6e\x00\x50\x01\x00\x5e\x6c\x00\x60\x00\x01\x64\x00\x03\x02\x01\x02\x04\x05\x01\x63\x01\x00\x00\x07\x10\x02\x04\x6d\x61\x6b\x65\x00\x00\x05\x63\x68\x69\x6c\x64\x01\x00\x0a\x0b\x01\x09\x00\xd0\x6c\x41\x00\xfb\x06\x01\x0b\x00\x15\x04\x6e\x61\x6d\x65\x04\x0e\x02\x00\x04\x62\x61\x73\x65\x01\x05\x63\x68\x69\x6c\x64"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $base (;0;) (sub (array anyref)))\n  (type $child (;1;) (sub $base (array i31ref)))\n  (type (;2;) (func (result (ref $base))))\n  (table (;0;) 0 (ref null $child))\n  (export \"make\" (func 0))\n  (export \"child\" (table 0))\n  (func (;0;) (type 2) (result (ref $base))\n    ref.null i31\n    i32.const 0\n    array.new $child\n  )\n)\n",
  )
}

///|
test "GC reference printer model-shared-contracts" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0f\x02\x65\x5f\x01\x65\x6e\x01\x65\x60\x01\x63\x00\x01\x63\x00\x02\x0b\x01\x03\x65\x6e\x76\x01\x67\x03\x63\x00\x02\x03\x02\x01\x01\x04\x05\x01\x63\x00\x02\x01\x06\x07\x01\x63\x00\x02\xd0\x00\x0b\x07\x16\x03\x05\x74\x61\x62\x6c\x65\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x01\x02\x69\x64\x00\x00\x0a\x06\x01\x04\x00\x20\x00\x0b\x00\x0e\x04\x6e\x61\x6d\x65\x04\x07\x02\x00\x01\x73\x01\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $s (;0;) (shared (struct (field (mut (ref null (shared any)))))))\n  (type $f (;1;) (shared (func (param (ref null $s)) (result (ref null $s)))))\n  (import \"env\" \"g\" (global (;0;) (shared (ref null $s))))\n  (table (;0;) shared 1 (ref null $s))\n  (global (;1;) (shared (ref null $s)) ref.null $s)\n  (export \"table\" (table 0))\n  (export \"value\" (global 1))\n  (export \"id\" (func 0))\n  (func (;0;) (type $f)\n    local.get 0\n  )\n)\n",
  )
}

///|
test "GC reference printer model-explicit-recursive-functions" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x01\x4e\x02\x60\x01\x7f\x00\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x61\x00\x00\x03\x02\x01\x01\x07\x05\x01\x01\x62\x00\x01\x0a\x06\x01\x04\x00\x42\x02\x0b\x00\x0e\x04\x6e\x61\x6d\x65\x04\x07\x02\x00\x01\x61\x01\x01\x62"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (rec\n    (type $a (;0;) (func (param i32)))\n    (type $b (;1;) (func (result i64)))\n  )\n  (import \"env\" \"a\" (func (;0;) (type $a) (param i32)))\n  (export \"b\" (func 1))\n  (func (;1;) (type $b) (result i64)\n    i64.const 2\n  )\n)\n",
  )
}

///|
test "GC reference printer model-abstract-bottom-contracts" {
  let input = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x10\x01\x60\x06\x64\x71\x64\x73\x64\x72\x64\x74\x64\x6d\x64\x6c\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x04\x04\x01\x69\x00\x00\x06\x06\x01\x71\x00\xd0\x71\x0b\x07\x0e\x02\x03\x65\x78\x6e\x01\x00\x04\x6e\x6f\x6e\x65\x03\x00\x00\x0b\x04\x6e\x61\x6d\x65\x04\x04\x01\x00\x01\x66"
  let printed = @decompiler.print_core_module(
    input,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  assert_true(
    printed is Ok(_),
    msg=match printed {
      Ok(_) => "printed"
      Err(e) => e[0].message
    },
  )
  assert_eq(
    printed.unwrap().root().text,
    "(module\n  (type $f (;0;) (func (param (ref none) (ref nofunc) (ref noextern) (ref noexn) (ref eq) (ref i31))))\n  (import \"env\" \"f\" (func (;0;) (type $f) (param (ref none) (ref nofunc) (ref noextern) (ref noexn) (ref eq) (ref i31))))\n  (table (;0;) 0 exnref)\n  (global (;0;) nullref ref.null none)\n  (export \"exn\" (table 0))\n  (export \"none\" (global 0))\n)\n",
  )
}
