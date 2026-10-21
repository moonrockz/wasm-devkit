// Original instruction probes. Expected acceptance checked with wasm-tools 1.262.0,
// validate --features all,-custom-descriptors. No handlers or module code execute.

///|
test "GC instruction struct-packed-get-s" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x03\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-packed-get-u" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x77\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x04\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-packed-plain-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-unpacked-packed-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x03\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-field-out-of-range" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x63\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-set-out-of-range" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x7f\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x05\x00\x63\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-default-nonnullable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x03\x5f\x00\x5f\x01\x64\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x08\x01\x06\x00\xfb\x01\x01\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-default-nullable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0b\x03\x5f\x00\x5f\x01\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x08\x01\x06\x00\xfb\x01\x01\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-packed-plain-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0b\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-packed-get-s" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0c\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-unpacked-packed-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0d\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-default-nonnullable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5f\x00\x5e\x64\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x0a\x01\x08\x00\x41\x00\xfb\x07\x01\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-default-nullable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5f\x00\x5e\x63\x00\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x0a\x01\x08\x00\x41\x00\xfb\x07\x01\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-fixed-huge-unreachable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0e\x01\x0c\x00\x00\xfb\x08\x00\xff\xff\xff\xff\x0f\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-fixed-huge-reachable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xfb\x08\x00\xff\xff\xff\xff\x0f\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-copy-reference-subtyping" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x6e\x01\x5e\x6c\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-copy-reference-reversed" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x6c\x01\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-copy-packed-different" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x78\x01\x5e\x77\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-copy-packed-same" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x03\x5e\x78\x01\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x02\x0a\x12\x01\x10\x00\xd0\x00\x41\x00\xd0\x01\x41\x00\x41\x01\xfb\x11\x00\x01\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-new-elem-subtyping" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x0d\x01\x0b\x00\x41\x00\x41\x00\xfb\x0a\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-new-elem-numeric" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x09\x04\x01\x05\x70\x00\x0a\x0d\x01\x0b\x00\x41\x00\x41\x00\xfb\x0a\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-init-elem-subtyping" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x01\x60\x00\x00\x03\x02\x01\x01\x09\x09\x01\x05\x6c\x01\x41\x01\xfb\x1c\x0b\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x00\xfb\x13\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-init-elem-numeric" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x01\x60\x00\x00\x03\x02\x01\x01\x09\x04\x01\x05\x70\x00\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x00\xfb\x13\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-is-null-number" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x41\x00\xd1\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction unreachable-select-ref" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\x00\xd0\x70\x41\x01\x1b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction unreachable-select-number" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x00\x41\x00\x1b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction unreachable-reference-to-number" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x00\xd4\x45\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction unreachable-reference-to-ref" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x00\xd4\xd1\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-test-wrong-hierarchy" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x70\xfb\x14\x6b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-test-shared-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\xd0\x6e\xfb\x14\x65\x6b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-cast-shared" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0c\x01\x0a\x00\xd0\x65\x6e\xfb\x16\x65\x6b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-eq-functions" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x70\xd0\x70\xd3\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-eq-shared-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0b\x01\x09\x00\xd0\x6d\xd0\x65\x6d\xd3\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-i31-shared" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x00\x01\x64\x65\x6c\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x41\x01\xfe\x72\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction global-ref-i31-shared" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x0a\x01\x64\x65\x6c\x00\x41\x01\xfe\x72\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction any-convert-extern-nonnullable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x01\x60\x01\x64\x6f\x01\x64\x6e\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction extern-convert-any-shared" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x01\x60\x01\x64\x65\x6e\x01\x64\x65\x6f\x03\x02\x01\x00\x0a\x08\x01\x06\x00\x20\x00\xfb\x1b\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction br-on-cast-prefix" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x00\x00\x60\x00\x02\x7f\x6d\x03\x02\x01\x00\x0a\x19\x01\x17\x00\x02\x01\x41\x01\xd0\x6e\xfb\x18\x03\x00\x6e\x6d\x1a\x1a\x41\x02\xd0\x6d\x0b\x1a\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction br-on-cast-empty-label" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x40\xd0\x6e\xfb\x18\x03\x00\x6e\x6d\x1a\x0b\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction br-on-cast-upcast" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x6e\xd0\x6d\xfb\x18\x03\x00\x6d\x6e\x0b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction br-on-cast-fail" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x10\x01\x0e\x00\x02\x6e\xd0\x6e\xfb\x19\x01\x00\x6e\x6d\x0b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction br-on-non-null-numeric-label" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0c\x01\x0a\x00\x02\x7f\x41\x00\xd6\x00\x0b\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction constant-struct-new" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x06\x0a\x01\x64\x00\x00\x41\x01\xfb\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction constant-struct-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x06\x0d\x01\x7f\x00\x41\x01\xfb\x00\x00\xfb\x02\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction constant-array-new-fixed" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x5e\x7f\x00\x06\x0d\x01\x64\x00\x00\x41\x01\x41\x02\xfb\x08\x00\x02\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction constant-conversion" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x08\x01\x6e\x00\xd0\x6f\xfb\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction table-init-global-forward" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x04\x0a\x01\x40\x00\x64\x70\x00\x01\x23\x00\x0b\x06\x07\x01\x64\x70\x00\xd2\x00\x0b\x0a\x04\x01\x02\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction table-init-ref-func-declares" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x03\x02\x00\x00\x04\x0a\x01\x40\x00\x64\x70\x00\x01\xd2\x00\x0b\x0a\x0a\x02\x02\x00\x0b\x05\x00\xd2\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-set-mutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x03\xfb\x05\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-set-immutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x03\xfb\x05\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction struct-new-packed" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x5f\x01\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0a\x01\x08\x00\x41\x03\xfb\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-new-numeric" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\x41\x03\x41\x04\xfb\x06\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-set-mutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xd0\x00\x41\x00\x41\x01\xfb\x0e\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-set-immutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0d\x01\x0b\x00\xd0\x00\x41\x00\x41\x01\xfb\x0e\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-fill-mutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0a\x0f\x01\x0d\x00\xd0\x00\x41\x00\x41\x01\x41\x02\xfb\x10\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-fill-immutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0f\x01\x0d\x00\xd0\x00\x41\x00\x41\x01\x41\x02\xfb\x10\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-len-shared" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x65\x6a\xfb\x0f\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-len-non-array" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\xd0\x6b\xfb\x0f\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-new-data" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x0d\x01\x0b\x00\x41\x00\x41\x03\xfb\x09\x00\x00\x1a\x0b\x0b\x06\x01\x01\x03\x61\x62\x63"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-new-data-reference" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x6e\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x0d\x01\x0b\x00\x41\x00\x41\x03\xfb\x09\x00\x00\x1a\x0b\x0b\x06\x01\x01\x03\x61\x62\x63"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-init-data" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x01\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x03\xfb\x12\x00\x00\x0b\x0b\x06\x01\x01\x03\x61\x62\x63"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction array-init-data-immutable" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x02\x5e\x78\x00\x60\x00\x00\x03\x02\x01\x01\x0c\x01\x01\x0a\x10\x01\x0e\x00\xd0\x00\x41\x00\x41\x00\x41\x03\xfb\x12\x00\x00\x0b\x0b\x06\x01\x01\x03\x61\x62\x63"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-test-null" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x15\x6d\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction ref-cast-null" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x0a\x01\x08\x00\xd0\x6e\xfb\x17\x6d\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction shared-struct-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x65\x5f\x01\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0b\x01\x09\x00\xd0\x00\xfb\x02\x00\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction shared-array-get" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x65\x5e\x7f\x00\x60\x00\x00\x03\x02\x01\x01\x0a\x0c\x01\x0a\x00\xd0\x00\x41\x00\xfb\x0b\x00\x1a\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction table-copy-concrete-subtyping" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x09\x02\x63\x00\x00\x01\x63\x01\x00\x01\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0e\x00\x01\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}

///|
test "GC instruction table-init-concrete-subtyping" {
  let bytes = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0c\x02\x50\x00\x60\x00\x00\x50\x01\x00\x60\x00\x00\x03\x02\x01\x00\x04\x05\x01\x63\x00\x00\x01\x09\x05\x01\x05\x63\x01\x00\x0a\x0e\x01\x0c\x00\x41\x00\x41\x00\x41\x00\xfc\x0c\x00\x00\x0b"
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="incorrect GC instruction acceptance")
  }
}
