// Original exception probes checked with wasm-tools 1.262.0,
// validate --features all,-custom-descriptors. No exception handlers execute.

///|
test "exception instruction throw-params" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7e\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x08\x01\x06\x00\x41\x01\x08\x00\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i32)) (func (result i64) i32.const 1 throw 0))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction throw-wrong-param" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x08\x01\x06\x00\x42\x01\x08\x00\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction throw-unknown-tag" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x08\x00\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction throw-ref-null" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\xd0\x69\x0a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse("(module  (func  ref.null exn throw_ref))")
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction throw-ref-nonnull" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x64\x69\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\x20\x00\x0a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func (param (ref exn)) local.get 0 throw_ref))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction throw-ref-wrong-hierarchy" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x07\x01\x05\x00\xd0\x6e\x0a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction throw-ref-shared" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\xd0\x65\x69\x0a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-catch-param" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x01\x7f\x00\x60\x00\x01\x7f\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x13\x01\x11\x00\x02\x7f\x1f\x40\x01\x00\x00\x00\x41\x01\x08\x00\x0b\x00\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i32)) (func (result i32) block (result i32) try_table (catch 0 0) i32.const 1 throw 0 end unreachable end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-own-label-excluded" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x1f\x7f\x01\x00\x00\x00\x41\x01\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-catch-ref-nonnull" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x13\x01\x11\x00\x02\x64\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag) (func  block (result (ref exn)) try_table (catch_ref 0 0) throw 0 end unreachable end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-catch-ref-nullable" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x12\x01\x10\x00\x02\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag) (func  block (result exnref) try_table (catch_ref 0 0) throw 0 end unreachable end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-catch-ref-number" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x12\x01\x10\x00\x02\x7f\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-catch-ref-shared" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x64\x65\x69\x1f\x40\x01\x01\x00\x00\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-catch-all-ref-nonnull" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x11\x01\x0f\x00\x02\x64\x69\x1f\x40\x01\x03\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  block (result (ref exn)) try_table (catch_all_ref 0) unreachable end unreachable end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-catch-all-ref-number" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x7f\x1f\x40\x01\x03\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-catch-all-ref-arity" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x03\x00\x00\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-catch-all" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x02\x00\x00\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  try_table (catch_all 0) unreachable end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-catch-all-arity" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x7f\x1f\x40\x01\x02\x00\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-bad-depth" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\x1f\x40\x01\x02\x01\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-bad-tag" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x1f\x40\x01\x00\x00\x00\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction try-table-block-params" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x41\x02\x1f\x01\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  i32.const 2 try_table (param i32) (result i32) end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-catch-subtype" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x6c\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x6e\x1f\x40\x01\x00\x00\x00\xd0\x6c\x08\x00\x0b\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i31ref)) (func  block (result anyref) try_table (catch 0 0) ref.null i31 throw 0 end unreachable end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction try-table-catch-loop-params" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x03\x60\x01\x6c\x00\x60\x00\x00\x60\x01\x6e\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x15\x01\x13\x00\xd0\x6e\x03\x02\x1a\x1f\x40\x01\x00\x00\x00\xd0\x6c\x08\x00\x0b\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i31ref)) (func  ref.null any loop (param anyref) drop try_table (catch 0 0) ref.null i31 throw 0 end end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-catch" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7f\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i32)) (func  try (result i32) i32.const 1 throw 0 catch 0 end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-catch-result-mismatch" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7e\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction legacy-catch-all" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x06\x40\x00\x19\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse("(module  (func  try unreachable catch_all end))")
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-rethrow" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x06\x40\x00\x19\x09\x00\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  try unreachable catch_all rethrow 0 end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-rethrow-outer" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0e\x01\x0c\x00\x06\x40\x00\x19\x02\x40\x09\x01\x0b\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  try unreachable catch_all block rethrow 1 end end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-rethrow-wrong-label" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0e\x01\x0c\x00\x06\x40\x00\x19\x02\x40\x09\x00\x0b\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction legacy-rethrow-outside-catch" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\x06\x40\x09\x00\x19\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction legacy-rethrow-function" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x06\x01\x04\x00\x09\x00\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction legacy-delegate-function" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x00\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse("(module  (func  try delegate 0))")
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-delegate-invalid-depth" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x01\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction legacy-delegate-outer-block" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x02\x40\x06\x40\x18\x00\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse("(module  (func  block try delegate 0 end))")
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-no-catches" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x01\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse("(module  (func  try nop end))")
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-catch-arm-reset" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0d\x03\x01\x00\x00\x0a\x11\x01\x0f\x00\x06\x7f\x41\x01\x07\x00\x41\x02\x19\x41\x03\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag) (func  try (result i32) i32.const 1 catch 0 i32.const 2 catch_all i32.const 3 end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-catch-param-reset" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x01\x7f\x01\x7f\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x41\x01\x06\x01\x19\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction legacy-uninitialized-local" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x13\x01\x11\x01\x01\x64\x70\x06\x40\xd0\x70\xd4\x21\x00\x19\x20\x00\x1a\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect exception acceptance")
  }
}

///|
test "exception instruction modern-nested-in-legacy" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0f\x01\x0d\x00\x06\x40\x1f\x40\x01\x02\x00\x00\x0b\x19\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  try try_table (catch_all 0) unreachable end catch_all end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction legacy-nested-in-modern" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0f\x01\x0d\x00\x1f\x40\x01\x02\x00\x06\x40\x00\x19\x0b\x0b\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module  (func  try_table (catch_all 0) try unreachable catch_all end end))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction folded-legacy" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x0e\x01\x0c\x00\x06\x7f\x41\x01\x08\x00\x07\x00\x0b\x1a\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i32)) (func  (try (result i32) (do (i32.const 1) (throw 0)) (catch 0)) drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction folded-legacy-delegate" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x06\x40\x18\x00\x0b",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse("(module  (func  (try (do) (delegate 0))))")
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}

///|
test "exception instruction named-modern-label" {
  let parsed = @parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0d\x03\x01\x00\x00\x0a\x14\x01\x12\x00\x02\x7f\x1f\x40\x01\x00\x00\x00\x41\x01\x08\x00\x0b\x00\x0b\x1a\x0b\x00\x18\x04\x6e\x61\x6d\x65\x03\x11\x01\x00\x02\x00\x05\x6f\x75\x74\x65\x72\x01\x05\x69\x6e\x6e\x65\x72",
  )
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect exception acceptance")
  }
  let from_text = @wat.parse(
    "(module (tag (param i32)) (func  block $outer (result i32) try_table $inner (catch 0 $outer) i32.const 1 throw 0 end unreachable end drop))",
  )
  @core_validation.validate_module(from_text)
  let encoded = @encoder.encode(parsed)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  @core_validation.validate_module(@parser.parse_module(bytes))
}
