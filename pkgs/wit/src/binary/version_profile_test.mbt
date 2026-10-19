// Original cases compared with WAC 0.12.0 Package::from_bytes and
// wasm-tools 1.262.0 validate --features all.

///|
// (component (type (map f32 string)) (import "data" (type (eq 0))))
test "declarative pinned version map-float-key" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x63\x76\x73\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x00"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (type (future u32)) (type (map 0 string)) (import "data" (type (eq 1))))
test "declarative pinned version map-future-key" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x65\x01\x79\x63\x00\x73\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (type (stream char)) (import "data" (type (eq 0))))
test "declarative pinned version stream-char" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x74\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x00"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (import "r" (type (sub resource))) (type (own 0)) (export "handle" (type 1)))
test "declarative pinned version export-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x00"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (import "r" (type (sub resource))) (type (borrow 0)) (export "handle" (type 1)))
test "declarative pinned version export-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x68\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x00"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (import "r" (type (sub resource))) (type (own 0)) (import "handle" (type (eq 1))))
test "declarative pinned version import-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (import "r" (type (sub resource))) (type (borrow 0)) (import "handle" (type (eq 1))))
test "declarative pinned version import-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x68\x00\x0a\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (type (resource (rep i32))) (type (own 0)) (export "handle" (type 1)))
test "declarative pinned version unnamed-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x02\x3f\x7f\x00\x69\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x00"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (type (map 99 u32)))
test "declarative pinned version map-invalid-index" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x63\xe3\x00\x79"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (type u32) (type (map 0 string)) (import "data" (type (eq 1))))
test "declarative pinned version map-aliased-int" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x79\x63\x00\x73\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}

///|
// (component (type (component (type (map f32 string)) (import "data" (type (eq 0))))))
test "declarative pinned version wrapper-map-float" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x41\x02\x01\x63\x76\x73\x03\x00\x04\x64\x61\x74\x61\x03\x00\x00"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(@binary.validate_type_component(bytes) is Ok(_), false)
}

///|
// (component (type (component (type (future u32)) (type (map 0 string)) (import "data" (type (eq 1))))))
test "declarative pinned version wrapper-map-future" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x01\x41\x03\x01\x65\x01\x79\x01\x63\x00\x73\x03\x00\x04\x64\x61\x74\x61\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(@binary.validate_type_component(bytes) is Ok(_), false)
}

///|
// (component (type (component (type u32) (type (map 0 string)) (import "data" (type (eq 1))))))
test "declarative pinned version wrapper-map-int" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x41\x03\x01\x79\x01\x63\x00\x73\x03\x00\x04\x64\x61\x74\x61\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(@binary.validate_type_component(bytes) is Ok(_), true)
}

///|
// (component (type (component (import "r" (type (sub resource))) (type (own 0)) (export "handle" (type (eq 1))))))
test "declarative pinned version wrapper-export-own" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(@binary.validate_type_component(bytes) is Ok(_), true)
}

///|
// (component (type (component (import "r" (type (sub resource))) (type (borrow 0)) (export "handle" (type (eq 1))))))
test "declarative pinned version wrapper-export-borrow" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x68\x00\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01"
  let result = @binary.validate_declarative_component(bytes)
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(@binary.validate_type_component(bytes) is Ok(_), true)
}
