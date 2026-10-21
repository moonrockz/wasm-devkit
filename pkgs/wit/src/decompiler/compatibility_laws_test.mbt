///|
test "compatibility rejects reference limits and out-of-profile binaries without output" {
  let component = b"\x00asm\x0d\x00\x01\x00"
  guard @decompiler.print_binary(
      component,
      compatibility=Some(@decompiler.Compatibility::Wabt),
    )
    is Err(errors) else {
    fail("WABT component printed")
  }
  assert_eq(errors[0].code, "WIT-D003")
  for
    mode in [
      @decompiler.Compatibility::WasmTools,
      @decompiler.Compatibility::Wabt,
    ] {
    for
      source in [
        "(module (func try_table nop end))", "(module (func (result i32) i64.const 1))",
        "(module (memory 1 1 shared) (func (result i32) i32.const 0 i32.atomic.load))",
      ] {
      assert_true(
        @decompiler.print_binary(wasm(source), compatibility=Some(mode))
        is Err(_),
      )
    }
    for input in [b"", b"\x00asm", b"\x00asm\x01\x00\x00\x00\x01\x01\x01"] {
      assert_true(
        @decompiler.print_binary(input, compatibility=Some(mode)) is Err(_),
      )
    }
  }
  let groups = wasm("(module (rec (type (func))))")
  assert_true(
    @decompiler.print_binary(
      groups,
      compatibility=Some(@decompiler.Compatibility::WasmTools),
    )
    is Ok(_),
  )
  guard @decompiler.print_binary(
      groups,
      compatibility=Some(@decompiler.Compatibility::Wabt),
    )
    is Err(errors) else {
    fail("WABT recursive group printed")
  }
  assert_eq(errors[0].code, "WIT-D003")
}

///|
test "law: compatibility is total and deterministic on arbitrary binary input" {
  @quickcheck.check(
    (input : Array[Byte]) => {
      let core = b"\x00asm\x01\x00\x00\x00".to_array()
      core.append(input)
      let component = b"\x00asm\x0d\x00\x01\x00".to_array()
      component.append(input)
      [
        Bytes::from_array(input),
        Bytes::from_array(core),
        Bytes::from_array(component),
      ].all(bytes => {
        [@decompiler.Compatibility::WasmTools, @decompiler.Compatibility::Wabt].all(mode => {
            let first = @decompiler.print_binary(
              bytes,
              compatibility=Some(mode),
            )
            first == @decompiler.print_binary(bytes, compatibility=Some(mode)) &&
            (match first {
              Ok(documents) => documents.documents.length() == 1
              Err(errors) => errors.length() == 1
            })
          },
        )
      })
    },
    count=500,
    max_size=128,
    seed=1340,
  )
}

///|
test "compatibility prints deep core input up to the existing profile limit" {
  for
    mode in [
      @decompiler.Compatibility::WasmTools,
      @decompiler.Compatibility::Wabt,
    ] {
    assert_true(
      @decompiler.print_binary(nested_blocks(256), compatibility=Some(mode))
      is Ok(_),
    )
    assert_true(
      @decompiler.print_binary(nested_blocks(257), compatibility=Some(mode))
      is Err(_),
    )
  }
}

///|
test "try_table prints by default and keeps explicit compatibility bounds" {
  let input = wasm("(module (func try_table nop end))")
  assert_true(@decompiler.print_binary(input) is Ok(_))
  for
    compatibility in [
      Some(@decompiler.Compatibility::WasmTools),
      Some(@decompiler.Compatibility::Wabt),
    ] {
    guard @decompiler.print_binary(input, compatibility~) is Err(errors) else {
      fail("try_table printed")
    }
    assert_eq(errors[0].code, "WIT-D003")
  }
}

///|
test "GC metadata prints in wasm-tools mode and remains explicit for WABT" {
  let bytes = wasm("(module (type $s (struct (field (ref null $s)))))")
  let printed = @decompiler.print_binary(
    bytes,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  ).unwrap()
  assert_same_module(bytes, wasm(printed.root().text))
  assert_true(
    @decompiler.print_binary(
      bytes,
      compatibility=Some(@decompiler.Compatibility::Wabt),
    )
    is Err(_),
  )
}
