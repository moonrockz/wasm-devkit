///|
test "canonical handle and GC composition task.cancel" {
  let source = "package test:app; let dep = new test:intrinsics { ... }; export dep as \"out\";"
  let text = assert_package(
    "(component   (core func $f (canon task.cancel)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    "task.cancel.wat",
  )
  for
    bytes in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x05\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x29\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76",
      text.bytes(),
    ] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:intrinsics", version: None, source: "dep.wasm", bytes, },
    ])
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "0", "1", "out", "instance", "interface", "", "0", "0",
    ])
  }
}

///|
test "canonical handle and GC composition stream.new" {
  let source = "package test:app; let dep = new test:intrinsics { ... }; export dep as \"out\";"
  let text = assert_package(
    "(component (type $t (stream u32)) (export \"t\" (type $t))  (core func $f (canon stream.new $t)) (core instance $env (export \"f\" (func $f))) (core module $m (import \"env\" \"f\" (func (result i64)))) (core instance (instantiate $m (with \"env\" (instance $env)))) )",
    "stream.new.wat",
  )
  for
    bytes in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x79\x0b\x07\x01\x00\x01\x74\x03\x00\x00\x08\x03\x01\x0e\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7e\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x00\x30\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x08\x00\x12\x01\x00\x03\x65\x6e\x76\x01\x05\x03\x01\x00\x01\x74",
      text.bytes(),
    ] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:intrinsics", version: None, source: "dep.wasm", bytes, },
    ])
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "0", "1", "out", "instance", "interface", "", "0", "1", "t", "type", "stream",
      "some", "scalar", "u32",
    ])
  }
}

///|
test "canonical handle and GC composition gc-lift-many" {
  let source = "package test:app; let dep = new test:intrinsics { ... }; export dep as \"out\";"
  let text = assert_package(
    "(component  (core module $m (func (export \"f\") (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func (export \"f\") (param \"p0\" u32) (param \"p1\" u32) (param \"p2\" u32) (param \"p3\" u32) (param \"p4\" u32) (param \"p5\" u32) (param \"p6\" u32) (param \"p7\" u32) (param \"p8\" u32) (param \"p9\" u32) (param \"p10\" u32) (param \"p11\" u32) (param \"p12\" u32) (param \"p13\" u32) (param \"p14\" u32) (param \"p15\" u32) (param \"p16\" u32) (param \"p17\" u32) (param \"p18\" u32) (param \"p19\" u32) (result u32) (canon lift (core func $f) gc)))",
    "gc-lift-many.wat",
  )
  for
    bytes in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x40\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x19\x01\x60\x14\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x01\x7f\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x05\x01\x03\x00\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x5f\x01\x40\x14\x02\x70\x30\x79\x02\x70\x31\x79\x02\x70\x32\x79\x02\x70\x33\x79\x02\x70\x34\x79\x02\x70\x35\x79\x02\x70\x36\x79\x02\x70\x37\x79\x02\x70\x38\x79\x02\x70\x39\x79\x03\x70\x31\x30\x79\x03\x70\x31\x31\x79\x03\x70\x31\x32\x79\x03\x70\x31\x33\x79\x03\x70\x31\x34\x79\x03\x70\x31\x35\x79\x03\x70\x31\x36\x79\x03\x70\x31\x37\x79\x03\x70\x31\x38\x79\x03\x70\x31\x39\x79\x00\x79\x08\x07\x01\x00\x00\x00\x01\x09\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x27\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69",
      text.bytes(),
    ] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:intrinsics", version: None, source: "dep.wasm", bytes, },
    ])
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "0", "1", "out", "instance", "interface", "", "0", "1", "f", "func", "function",
      "false", "20", "p0", "scalar", "u32", "p1", "scalar", "u32", "p2", "scalar",
      "u32", "p3", "scalar", "u32", "p4", "scalar", "u32", "p5", "scalar", "u32",
      "p6", "scalar", "u32", "p7", "scalar", "u32", "p8", "scalar", "u32", "p9",
      "scalar", "u32", "p10", "scalar", "u32", "p11", "scalar", "u32", "p12", "scalar",
      "u32", "p13", "scalar", "u32", "p14", "scalar", "u32", "p15", "scalar", "u32",
      "p16", "scalar", "u32", "p17", "scalar", "u32", "p18", "scalar", "u32", "p19",
      "scalar", "u32", "some", "scalar", "u32",
    ])
  }
}

///|
test "canonical handle and GC composition gc-lower-scalars" {
  let source = "package test:app; let dep = new test:intrinsics { ... }; export dep as \"out\";"
  let text = assert_package(
    "(component  (core type $ct (func (param i32 i32 i32 i32 i32 i32 i32 i64 i64 f32 f64 i32) (result i64))) (import \"f\" (func $f  (param \"p0\" bool) (param \"p1\" s8) (param \"p2\" u8) (param \"p3\" s16) (param \"p4\" u16) (param \"p5\" s32) (param \"p6\" u32) (param \"p7\" s64) (param \"p8\" u64) (param \"p9\" f32) (param \"p10\" f64) (param \"p11\" char) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct))))",
    "gc-lower-scalars.wat",
  )
  for
    bytes in [
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x11\x01\x60\x0c\x7f\x7f\x7f\x7f\x7f\x7f\x7f\x7e\x7e\x7d\x7c\x7f\x01\x7e\x07\x37\x01\x40\x0c\x02\x70\x30\x7f\x02\x70\x31\x7e\x02\x70\x32\x7d\x02\x70\x33\x7c\x02\x70\x34\x7b\x02\x70\x35\x7a\x02\x70\x36\x79\x02\x70\x37\x78\x02\x70\x38\x77\x02\x70\x39\x76\x03\x70\x31\x30\x75\x03\x70\x31\x31\x74\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x00\x08\x08\x01\x01\x00\x00\x02\x09\x08\x00\x00\x2b\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x00\x01\x00\x05\x6c\x6f\x77\x65\x72\x01\x07\x00\x10\x01\x00\x02\x63\x74\x01\x05\x01\x01\x00\x01\x66",
      text.bytes(),
    ] {
    let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
      { name: "test:intrinsics", version: None, source: "dep.wasm", bytes, },
    ])
    assert_true(
      result is Ok(_),
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].render()
      },
    )
    assert_eq(source_projection(result.unwrap()), [
      "1", "f", "func", "function", "false", "12", "p0", "scalar", "bool", "p1",
      "scalar", "s8", "p2", "scalar", "u8", "p3", "scalar", "s16", "p4", "scalar",
      "u16", "p5", "scalar", "s32", "p6", "scalar", "u32", "p7", "scalar", "s64",
      "p8", "scalar", "u64", "p9", "scalar", "f32", "p10", "scalar", "f64", "p11",
      "scalar", "char", "some", "scalar", "u64", "1", "out", "instance", "interface",
      "", "0", "0",
    ])
  }
}
