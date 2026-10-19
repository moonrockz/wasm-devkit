///|
test "pinned core codec empty" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(b"\x01\x50\x00", current=ReadOnlyArray::from_array(current)) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(current.last(), Some(Module({ imports: [], exports: [], })))
}

///|
test "pinned core codec function" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x02\x01\x60\x05\x7f\x7e\x7d\x7c\x7b\x02\x7f\x7e\x03\x01\x66\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
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
      }),
    ),
  )
}

///|
test "pinned core codec imports" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x03\x01\x60\x01\x7f\x00\x00\x03\x65\x6e\x76\x01\x66\x00\x00\x03\x01\x66\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
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
      }),
    ),
  )
}

///|
test "pinned core codec table" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x05\x74\x61\x62\x6c\x65\x01\x70\x01\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          {
            name: "table",
            kind: Table(Reference(true, "func"), 1UL, Some(3UL), false, false),
          },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec memory" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x01\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "memory", kind: Memory(1UL, Some(3UL), false, false, None), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec global" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x67\x03\x7e\x01",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [{ name: "g", kind: Global(Scalar("i64"), true, false), }],
      }),
    ),
  )
}

///|
test "pinned core codec tag" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x02\x01\x60\x01\x7f\x00\x03\x01\x65\x04\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "e", kind: Tag({ params: [Scalar("i32")], results: [], }), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec unicode" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x03\x01\x60\x00\x00\x00\x02\xc3\xa9\x04\xf0\x9f\x98\x80\x00\x00\x03\x03\x66\xce\xbb\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [
          {
            module_name: "é",
            name: "😀",
            kind: Func({ params: [], results: [], }),
          },
        ],
        exports: [{ name: "fλ", kind: Func({ params: [], results: [], }), }],
      }),
    ),
  )
}

///|
test "pinned core codec tuple-imports" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x03\x01\x60\x00\x00\x00\x03\x61\x3a\x62\x01\x63\x00\x00\x00\x01\x61\x03\x62\x3a\x63\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
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
      }),
    ),
  )
}

///|
test "pinned core codec duplicate-import" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x03\x01\x60\x00\x00\x00\x01\x61\x01\x62\x00\x00\x00\x01\x61\x01\x62\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some(_))
}

///|
test "pinned core codec duplicate-export" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x02\x03\x01\x6d\x02\x00\x00\x03\x01\x6d\x02\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some(_))
}

///|
test "pinned core codec bad-memory" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x6d\x02\x01\x03\x01",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some(_))
}

///|
test "pinned core codec bad-table" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x74\x01\x70\x01\x03\x01",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some(_))
}

///|
test "pinned core codec memory64" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x6d\x02\x05\xf0\xa2\x04\x80\xf1\x04",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          {
            name: "m",
            kind: Memory(70000UL, Some(80000UL), true, false, None),
          },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec shared-memory" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x6d\x02\x03\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "m", kind: Memory(1UL, Some(3UL), false, true, None), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec table64" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x74\x01\x70\x05\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          {
            name: "t",
            kind: Table(Reference(true, "func"), 1UL, Some(3UL), true, false),
          },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec typed-ref" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x02\x01\x60\x00\x00\x03\x01\x74\x01\x63\x00\x01\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some({ kind: Unsupported, .. }))
}

///|
test "pinned core codec abstract-ref" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x74\x01\x6e\x01\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          {
            name: "t",
            kind: Table(Reference(true, "any"), 1UL, Some(3UL), false, false),
          },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec shared-global" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x67\x03\x7f\x02",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [{ name: "g", kind: Global(Scalar("i32"), false, true), }],
      }),
    ),
  )
}

///|
test "pinned core codec outer-function" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x02\x60\x01\x7f\x00\x50\x02\x02\x10\x01\x01\x00\x03\x01\x66\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec memory-u64" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x6d\x02\x0d\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
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
      }),
    ),
  )
}

///|
test "pinned core codec memory-u32" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x6d\x02\x09\xff\xff\xff\xff\x0f\xff\xff\xff\xff\x0f\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          {
            name: "m",
            kind: Memory(
              4294967295UL,
              Some(4294967295UL),
              false,
              false,
              Some(0),
            ),
          },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec table-u64" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x74\x01\x70\x05\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
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
      }),
    ),
  )
}

///|
test "pinned core codec memory-page-default" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x6d\x02\x09\x01\x02\x10",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "m", kind: Memory(1UL, Some(2UL), false, false, Some(16)), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec local-function-alias" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x03\x01\x60\x01\x7f\x00\x02\x10\x01\x00\x00\x03\x01\x66\x00\x01",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec global-shared-mut" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x67\x03\x7e\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [{ name: "g", kind: Global(Scalar("i64"), true, true), }],
      }),
    ),
  )
}

///|
test "pinned core codec nonnull-table" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x01\x74\x01\x64\x70\x01\x01\x03",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          {
            name: "t",
            kind: Table(Reference(false, "func"), 1UL, Some(3UL), false, false),
          },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec shadowed-core-name" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x60\x01\x7f\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  match
    decode_section(
      b"\x01\x50\x02\x02\x10\x01\x01\x00\x03\x01\x66\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "f", kind: Func({ params: [Scalar("i32")], results: [], }), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec outer-module-alias" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x01\x03\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_eq(error, None)
  assert_eq(
    current.last(),
    Some(
      Module({
        imports: [],
        exports: [
          { name: "memory", kind: Memory(0UL, None, false, false, None), },
        ],
      }),
    ),
  )
}

///|
test "pinned core codec forward-core-alias" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x02\x02\x10\x01\x00\x00\x03\x01\x66\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some(_))
}

///|
test "pinned core codec wrong-outer-depth" {
  let current : Array[Definition] = []
  let mut error : Diagnostic? = None

  match
    decode_section(
      b"\x01\x50\x02\x02\x10\x01\x02\x00\x03\x01\x66\x00\x00",
      current=ReadOnlyArray::from_array(current),
    ) {
    Ok(definitions) =>
      for definition in definitions {
        current.push(definition)
      }
    Err(e) => error = Some(e)
  }
  assert_true(error is Some(_))
}

///|
test "core signatures bound unsigned limits and truncation" {
  let encoded = b"\x50\x01\x03\x01m\x02\x0c\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00"
  assert_true(decode_type(encoded) is Ok(_))
  assert_true(
    scan_type(encoded, 0, encoded.length(), legacy_nested=true)
    is Err({ kind: Unsupported, .. }),
  )
  for end in 0..<encoded.length() {
    assert_true(decode_type(encoded[:end].to_owned()) is Err(_))
  }
  let overflow = b"\x50\x01\x03\x01m\x02\x04\xff\xff\xff\xff\xff\xff\xff\xff\xff\x02"
  assert_true(decode_type(overflow) is Err({ kind: Malformed, .. }))
  assert_true(scan_type(encoded, -1, encoded.length()) is Err(_))
  assert_true(scan_type(encoded, 0, encoded.length() + 1) is Err(_))
}

///|
test "wide core function signatures use bounded sequential decoding" {
  let bytes : Array[Byte] = [0x60, 0xd0, 0x86, 0x03]
  for _ in 0..<50000 {
    bytes.push(0x7f)
  }
  bytes.push(0)
  guard decode_type(Bytes::from_array(bytes)) is Ok(Function(signature)) else {
    fail("function signature rejected")
  }
  assert_eq(signature.params.length(), 50000)
  assert_eq(signature.params[49999], Scalar("i32"))
  assert_eq(signature.results.length(), 0)
}
