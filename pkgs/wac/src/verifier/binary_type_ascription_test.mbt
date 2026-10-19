// Original fixtures and pinned reference results: tests/semantic/wac-type-ascriptions/.

///|
test "type export ascription scalar" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x02\x79\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "scalar", "u32", "instance", "interface",
    "", "0", "1", "value", "type", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a u32) (type $b u32) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="scalar.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "scalar", "u32", "instance", "interface",
    "", "0", "1", "value", "type", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "type export ascription scalar-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x02\x79\x77\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="scalar-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a u32) (type $b u64) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="scalar-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription list" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x70\x79\x70\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="list.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "list", "scalar", "u32", "instance",
    "interface", "", "0", "1", "value", "type", "list", "scalar", "u32", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (list u32)) (type $b (list u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="list.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "list", "scalar", "u32", "instance",
    "interface", "", "0", "1", "value", "type", "list", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "type export ascription list-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x70\x79\x70\x77\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="list-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (list u32)) (type $b (list u64)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="list-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription fixed" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x67\x79\x03\x67\x79\x03\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="fixed.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "fixed-list", "3", "scalar", "u32",
    "instance", "interface", "", "0", "1", "value", "type", "fixed-list", "3", "scalar",
    "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (list u32 3)) (type $b (list u32 3)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="fixed.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "fixed-list", "3", "scalar", "u32",
    "instance", "interface", "", "0", "1", "value", "type", "fixed-list", "3", "scalar",
    "u32", "definitions", "0",
  ])
}

///|
test "type export ascription fixed-length" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x67\x79\x03\x67\x79\x04\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="fixed-length.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (list u32 3)) (type $b (list u32 4)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="fixed-length.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription map" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x63\x73\x79\x63\x73\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="map.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "map", "scalar", "string", "scalar",
    "u32", "instance", "interface", "", "0", "1", "value", "type", "map", "scalar",
    "string", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (map string u32)) (type $b (map string u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="map.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "map", "scalar", "string", "scalar",
    "u32", "instance", "interface", "", "0", "1", "value", "type", "map", "scalar",
    "string", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "type export ascription map-value" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x63\x73\x79\x63\x73\x77\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="map-value.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (map string u32)) (type $b (map string u64)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="map-value.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription record" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x72\x01\x05\x76\x61\x6c\x75\x65\x79\x72\x01\x05\x76\x61\x6c\x75\x65\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="record.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "record", "1", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "value", "type", "record", "1",
    "value", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (record (field \"value\" u32))) (type $b (record (field \"value\" u32))) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="record.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "record", "1", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "value", "type", "record", "1",
    "value", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "type export ascription record-name" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x72\x01\x05\x76\x61\x6c\x75\x65\x79\x72\x01\x05\x6f\x74\x68\x65\x72\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="record-name.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (record (field \"value\" u32))) (type $b (record (field \"other\" u32))) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="record-name.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription tuple" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x02\x6f\x02\x79\x73\x6f\x02\x79\x73\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="tuple.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "tuple", "2", "scalar", "u32", "scalar",
    "string", "instance", "interface", "", "0", "1", "value", "type", "tuple", "2",
    "scalar", "u32", "scalar", "string", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (tuple u32 string)) (type $b (tuple u32 string)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="tuple.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "tuple", "2", "scalar", "u32", "scalar",
    "string", "instance", "interface", "", "0", "1", "value", "type", "tuple", "2",
    "scalar", "u32", "scalar", "string", "definitions", "0",
  ])
}

///|
test "type export ascription tuple-order" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x02\x6f\x02\x79\x73\x6f\x02\x73\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="tuple-order.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (tuple u32 string)) (type $b (tuple string u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="tuple-order.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription variant" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x02\x71\x02\x01\x61\x00\x00\x01\x62\x01\x79\x00\x71\x02\x01\x61\x00\x00\x01\x62\x01\x79\x00\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="variant.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "variant", "2", "a", "none", "b",
    "some", "scalar", "u32", "instance", "interface", "", "0", "1", "value", "type",
    "variant", "2", "a", "none", "b", "some", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (variant (case \"a\") (case \"b\" u32))) (type $b (variant (case \"a\") (case \"b\" u32))) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="variant.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "variant", "2", "a", "none", "b",
    "some", "scalar", "u32", "instance", "interface", "", "0", "1", "value", "type",
    "variant", "2", "a", "none", "b", "some", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "type export ascription variant-payload" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x02\x71\x02\x01\x61\x00\x00\x01\x62\x01\x79\x00\x71\x02\x01\x61\x00\x00\x01\x62\x01\x77\x00\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="variant-payload.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (variant (case \"a\") (case \"b\" u32))) (type $b (variant (case \"a\") (case \"b\" u64))) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="variant-payload.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription flags" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x02\x6e\x02\x01\x61\x01\x62\x6e\x02\x01\x61\x01\x62\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="flags.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "flags", "2", "a", "b", "instance",
    "interface", "", "0", "1", "value", "type", "flags", "2", "a", "b", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (flags \"a\" \"b\")) (type $b (flags \"a\" \"b\")) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="flags.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "flags", "2", "a", "b", "instance",
    "interface", "", "0", "1", "value", "type", "flags", "2", "a", "b", "definitions",
    "0",
  ])
}

///|
test "type export ascription flags-order" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x02\x6e\x02\x01\x61\x01\x62\x6e\x02\x01\x62\x01\x61\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="flags-order.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (flags \"a\" \"b\")) (type $b (flags \"b\" \"a\")) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="flags-order.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription enum" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x02\x6d\x02\x01\x61\x01\x62\x6d\x02\x01\x61\x01\x62\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(bytes, source_id="enum.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "enum", "2", "a", "b", "instance",
    "interface", "", "0", "1", "value", "type", "enum", "2", "a", "b", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (enum \"a\" \"b\")) (type $b (enum \"a\" \"b\")) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="enum.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "enum", "2", "a", "b", "instance",
    "interface", "", "0", "1", "value", "type", "enum", "2", "a", "b", "definitions",
    "0",
  ])
}

///|
test "type export ascription enum-order" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x02\x6d\x02\x01\x61\x01\x62\x6d\x02\x01\x62\x01\x61\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="enum-order.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (enum \"a\" \"b\")) (type $b (enum \"b\" \"a\")) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="enum-order.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription option" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x6b\x79\x6b\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="option.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "option", "scalar", "u32", "instance",
    "interface", "", "0", "1", "value", "type", "option", "scalar", "u32", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (option u32)) (type $b (option u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="option.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "option", "scalar", "u32", "instance",
    "interface", "", "0", "1", "value", "type", "option", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "type export ascription option-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x6b\x79\x6b\x77\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="option-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (option u32)) (type $b (option u64)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="option-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription result" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x02\x6a\x01\x79\x01\x73\x6a\x01\x79\x01\x73\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "result", "some", "scalar", "u32",
    "some", "scalar", "string", "instance", "interface", "", "0", "1", "value", "type",
    "result", "some", "scalar", "u32", "some", "scalar", "string", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (result u32 (error string))) (type $b (result u32 (error string))) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="result.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "result", "some", "scalar", "u32",
    "some", "scalar", "string", "instance", "interface", "", "0", "1", "value", "type",
    "result", "some", "scalar", "u32", "some", "scalar", "string", "definitions",
    "0",
  ])
}

///|
test "type export ascription result-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0a\x02\x6a\x01\x79\x01\x73\x6a\x01\x79\x00\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="result-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (result u32 (error string))) (type $b (result u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="result-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription future" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x65\x01\x79\x65\x01\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="future.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "future", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "value", "type", "future", "some", "scalar",
    "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (future u32)) (type $b (future u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="future.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "future", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "value", "type", "future", "some", "scalar",
    "u32", "definitions", "0",
  ])
}

///|
test "type export ascription future-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x02\x65\x01\x79\x65\x00\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="future-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (future u32)) (type $b (future)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="future-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription stream" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x66\x01\x79\x66\x01\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="stream.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "stream", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "value", "type", "stream", "some", "scalar",
    "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (stream u32)) (type $b (stream u32)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="stream.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "value", "type", "stream", "some", "scalar", "u32",
    "instance", "interface", "", "0", "1", "value", "type", "stream", "some", "scalar",
    "u32", "definitions", "0",
  ])
}

///|
test "type export ascription stream-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x66\x01\x79\x66\x01\x77\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x01\x03\x00\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="stream-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $a (stream u32)) (type $b (stream u64)) (export \"value\" (type $a) (type (eq $b))))\n",
    source_id="stream-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x0b\x0a\x01\x00\x01\x72\x03\x00\x01\x03\x00\x00"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "r", "type", "resource",
    "0", "instance", "interface", "", "0", "1", "r", "type", "resource", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (export \"r\" (type 0) (type (eq 0))))\n",
    source_id="resource.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "r", "type", "resource",
    "0", "instance", "interface", "", "0", "1", "r", "type", "resource", "0", "definitions",
    "0",
  ])
}

///|
test "type export ascription resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x0b\x0a\x01\x00\x01\x72\x03\x00\x01\x03\x00\x01"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (export \"r\" (type 0) (type (eq 1))))\n",
    source_id="resource-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription resource-sub" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x0b\x09\x01\x00\x01\x72\x03\x00\x01\x03\x01"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="resource-sub.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (export \"r\" (type 0) (type (sub resource))))\n",
    source_id="resource-sub.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription local-resource" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x0a\x01\x00\x01\x72\x03\x00\x01\x03\x00\x00"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="local-resource.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type (resource (rep i32))) (export \"r\" (type 0) (type (eq 0))))\n",
    source_id="local-resource.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "1", "r", "type", "resource", "0", "instance", "interface",
    "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ])
}

///|
test "type export ascription local-resource-sub" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x09\x01\x00\x01\x72\x03\x00\x01\x03\x01"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="local-resource-sub.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type (resource (rep i32))) (export \"r\" (type 0) (type (sub resource))))\n",
    source_id="local-resource-sub.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x05\x02\x69\x00\x69\x00\x0b\x0f\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x03\x00\x02"
  let result = @verifier.decode_component_package(bytes, source_id="own.wasm")
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "handle", "type", "own",
    "0", "instance", "interface", "", "0", "1", "handle", "type", "own", "0", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type (own 0)) (type (own 0)) (export \"handle\" (type 1) (type (eq 2))))\n",
    source_id="own.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "handle", "type", "own",
    "0", "instance", "interface", "", "0", "1", "handle", "type", "own", "0", "definitions",
    "0",
  ])
}

///|
test "type export ascription borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x05\x02\x68\x00\x68\x00\x0b\x0f\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x03\x00\x02"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="borrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "handle", "type", "borrow",
    "0", "instance", "interface", "", "0", "1", "handle", "type", "borrow", "0",
    "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type (borrow 0)) (type (borrow 0)) (export \"handle\" (type 1) (type (eq 2))))\n",
    source_id="borrow.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "handle", "type", "borrow",
    "0", "instance", "interface", "", "0", "1", "handle", "type", "borrow", "0",
    "definitions", "0",
  ])
}

///|
test "type export ascription handle-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x05\x02\x69\x00\x68\x00\x0b\x0f\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x03\x00\x02"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="handle-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type (own 0)) (type (borrow 0)) (export \"handle\" (type 1) (type (eq 2))))\n",
    source_id="handle-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription handle-resource-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x05\x02\x69\x00\x69\x01\x0b\x0f\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x02\x01\x03\x00\x03"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="handle-resource-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (import \"s\" (type (sub resource))) (type (own 0)) (type (own 1)) (export \"handle\" (type 2) (type (eq 3))))\n",
    source_id="handle-resource-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription instance-alias" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x70\x79\x04\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0a\x01\x03\x00\x00\x05\x76\x61\x6c\x75\x65\x07\x03\x01\x70\x79\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x01\x01\x03\x00\x02\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-alias.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "value", "type",
    "list", "scalar", "u32", "1", "value", "type", "list", "scalar", "u32", "instance",
    "interface", "", "0", "1", "value", "type", "list", "scalar", "u32", "definitions",
    "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type (list u32)) (export \"value\" (type (eq 0))))) (import \"i\" (instance (type $i))) (alias export 0 \"value\" (type)) (type (list u32)) (export \"value\" (type 1) (type (eq 2))))\n",
    source_id="instance-alias.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "value", "type",
    "list", "scalar", "u32", "1", "value", "type", "list", "scalar", "u32", "instance",
    "interface", "", "0", "1", "value", "type", "list", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "type export ascription instance-alias-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x70\x79\x04\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0a\x01\x03\x00\x00\x05\x76\x61\x6c\x75\x65\x07\x03\x01\x70\x77\x0b\x0e\x01\x00\x05\x76\x61\x6c\x75\x65\x03\x01\x01\x03\x00\x02\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="instance-alias-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type (list u32)) (export \"value\" (type (eq 0))))) (import \"i\" (instance (type $i))) (alias export 0 \"value\" (type)) (type (list u64)) (export \"value\" (type 1) (type (eq 2))))\n",
    source_id="instance-alias-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "type export ascription reexport" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x02\x79\x79\x0b\x1c\x02\x00\x05\x66\x69\x72\x73\x74\x03\x00\x01\x03\x00\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x03\x02\x01\x03\x00\x00"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "2", "first", "type", "scalar", "u32", "second", "type",
    "scalar", "u32", "instance", "interface", "", "0", "2", "first", "type", "scalar",
    "u32", "second", "type", "scalar", "u32", "definitions", "0",
  ])
  assert_eq(result.unwrap().bytes(), bytes)
  let text_result = @verifier.decode_wat_component_package(
    "(component (type u32) (type u32) (export \"first\" (type 0) (type (eq 1))) (export \"second\" (type 2) (type (eq 0))))\n",
    source_id="reexport.wat",
  )
  assert_eq(
    text_result is Ok(_),
    true,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(binary_projection(text_result.unwrap()), [
    "world", "", "0", "0", "2", "first", "type", "scalar", "u32", "second", "type",
    "scalar", "u32", "instance", "interface", "", "0", "2", "first", "type", "scalar",
    "u32", "second", "type", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "type export ascription reexport-mismatch" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x02\x79\x77\x0b\x19\x02\x00\x05\x66\x69\x72\x73\x74\x03\x00\x00\x00\x06\x73\x65\x63\x6f\x6e\x64\x03\x02\x01\x03\x00\x01"
  let result = @verifier.decode_component_package(
    bytes,
    source_id="reexport-mismatch.wasm",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  let text_result = @verifier.decode_wat_component_package(
    "(component (type u32) (type u64) (export \"first\" (type 0)) (export \"second\" (type 2) (type (eq 1))))\n",
    source_id="reexport-mismatch.wat",
  )
  assert_eq(
    text_result is Ok(_),
    false,
    msg=match text_result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(text_result.unwrap_err()[0].code, "WAC-B003")
}
