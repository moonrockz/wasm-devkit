///|
test "module contracts reverse imports and preserve export limits" {
  let wide : @core_types.External = Memory(1UL, Some(10UL), false, false, None)
  let narrow : @core_types.External = Memory(2UL, Some(5UL), false, false, None)
  let actual : @core_types.Module = {
    imports: [{ module_name: "host", name: "memory", kind: wide, }],
    exports: [{ name: "memory", kind: narrow, }],
  }
  let expected : @core_types.Module = {
    imports: [{ module_name: "host", name: "memory", kind: narrow, }],
    exports: [{ name: "memory", kind: wide, }],
  }
  assert_true(@core_types.check_module_subtype(actual, expected) is Ok(_))
  assert_true(
    @core_types.check_module_subtype(expected, actual) is Err(Mismatch(_)),
  )
  let empty : @core_types.Module = { imports: [], exports: [], }
  assert_true(
    @core_types.check_module_subtype({ ..actual, imports: [], }, empty) is Ok(_),
  )
  assert_true(
    @core_types.check_module_subtype(actual, empty) is Err(Mismatch(_)),
  )
  assert_true(
    @core_types.check_module_subtype(empty, expected) is Err(Mismatch(_)),
  )
}

///|
test "module contract keys stay distinct and duplicates reject" {
  let value : @core_types.External = Global(Scalar("i32"), false, false)
  let actual : @core_types.Module = {
    imports: [
      { module_name: "a:b", name: "c", kind: value, },
      { module_name: "a", name: "b:c", kind: value, },
    ],
    exports: [],
  }
  assert_true(@core_types.check_module_subtype(actual, actual) is Ok(_))
  let missing : @core_types.Module = { ..actual, imports: [actual.imports[0]], }
  assert_true(
    @core_types.check_module_subtype(actual, missing) is Err(Mismatch(_)),
  )
  let duplicate : @core_types.Module = {
    ..actual,
    imports: [actual.imports[0], actual.imports[0]],
  }
  assert_true(
    @core_types.check_module_subtype(duplicate, actual) is Err(Mismatch(_)),
  )
  assert_true(
    @core_types.check_module_subtype(actual, duplicate) is Err(Mismatch(_)),
  )
  let duplicate_exports : @core_types.Module = {
    imports: [],
    exports: [{ name: "x", kind: value, }, { name: "x", kind: value, }],
  }
  assert_true(
    @core_types.check_module_subtype(duplicate_exports, actual)
    is Err(Mismatch(_)),
  )
  assert_true(
    @core_types.check_module_subtype(actual, duplicate_exports)
    is Err(Mismatch(_)),
  )
}

///|
test "external contracts retain full unsigned limits and signature flags" {
  let wide : @core_types.External = Memory(
    9223372036854775808UL,
    None,
    true,
    false,
    Some(0),
  )
  let narrow : @core_types.External = Memory(
    9223372036854775809UL,
    Some(18446744073709551615UL),
    true,
    false,
    Some(0),
  )
  assert_true(@core_types.check_external_subtype(narrow, wide) is Ok(_))
  assert_true(
    @core_types.check_external_subtype(wide, narrow) is Err(Mismatch(_)),
  )
  let differences : Array[@core_types.External] = [
    Memory(
      9223372036854775809UL,
      Some(18446744073709551615UL),
      false,
      false,
      Some(0),
    ),
    Memory(
      9223372036854775809UL,
      Some(18446744073709551615UL),
      true,
      true,
      Some(0),
    ),
    Memory(
      9223372036854775809UL,
      Some(18446744073709551615UL),
      true,
      false,
      None,
    ),
  ]
  for different in differences {
    assert_true(
      @core_types.check_external_subtype(narrow, different) is Err(Mismatch(_)),
    )
  }
  let f : @core_types.Function = {
    params: [Scalar("i32")],
    results: [Scalar("i64")],
  }
  let g : @core_types.Function = {
    params: [Scalar("i64")],
    results: [Scalar("i64")],
  }
  assert_true(@core_types.check_external_subtype(Func(f), Func(f)) is Ok(_))
  let tag : @core_types.Function = { params: [Scalar("i32")], results: [], }
  assert_true(@core_types.check_external_subtype(Tag(tag), Tag(tag)) is Ok(_))
  assert_true(
    @core_types.check_external_subtype(Func(f), Func(g)) is Err(Mismatch(_)),
  )
  assert_true(
    @core_types.check_external_subtype(Func(f), Tag(f)) is Err(Mismatch(_)),
  )
  let table : @core_types.External = Table(
    Reference(true, "func"),
    2UL,
    Some(5UL),
    false,
    false,
  )
  assert_true(
    @core_types.check_external_subtype(
      table,
      Table(Reference(true, "func"), 1UL, None, false, false),
    )
    is Ok(_),
  )
  assert_true(
    @core_types.check_external_subtype(
      table,
      Table(Reference(false, "func"), 1UL, None, false, false),
    )
    is Err(Mismatch(_)),
  )
  assert_true(
    @core_types.check_external_subtype(
      Global(Scalar("i32"), false, false),
      Global(Scalar("i32"), true, false),
    )
    is Err(Mismatch(_)),
  )
}

///|
test "comparison allowance includes wide signatures and repeated calls" {
  let params = ReadOnlyArray::from_array(
    Array::make(10000, @core_types.Value::Scalar("i32")),
  )
  let function : @core_types.External = Func({ params, results: [], })
  assert_eq(
    @core_types.check_external_subtype(function, function, work_limit=10000),
    Err(WorkLimit),
  )
  let actual : @core_types.Module = {
    imports: [],
    exports: [{ name: "f", kind: function, }],
  }
  let remaining = @core_types.check_module_subtype(
    actual,
    actual,
    work_limit=30000,
  ).unwrap()
  assert_true(remaining >= 0 && remaining < 10000)
  assert_eq(
    @core_types.check_module_subtype(actual, actual, work_limit=remaining),
    Err(WorkLimit),
  )
  assert_eq(
    @core_types.check_module_subtype(actual, actual, work_limit=-1),
    Err(WorkLimit),
  )
}
