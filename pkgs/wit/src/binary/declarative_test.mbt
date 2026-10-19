// Original fixtures checked against WAC 0.12.0 Package::from_bytes.

///|
// (component (import "f" (func)) (export "f" (func 0)))
test "declarative package reexport-function" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00",
    source_id="reexport-function.wasm",
  )
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
// (component (type (component)) (import "c" (component (type 0))) (export "c" (component 0)))
test "declarative package reexport-component" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x41\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x07\x01\x00\x01\x63\x04\x00\x00",
    source_id="reexport-component.wasm",
  )
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
// (component (type (instance (type u32) (export "data" (type (eq 0))))) (import "a" (instance (type 0))) (export "b" (instance 0)) (alias export 1 "data" (type)) (type (record (field "value" 1))) (import "data" (type (eq 2))))
test "declarative package instance-export-index" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x01\x42\x02\x01\x79\x04\x00\x04\x64\x61\x74\x61\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x0b\x07\x01\x00\x01\x62\x05\x00\x00\x06\x09\x01\x03\x00\x01\x04\x64\x61\x74\x61\x07\x0a\x01\x72\x01\x05\x76\x61\x6c\x75\x65\x01\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x02",
    source_id="instance-export-index.wasm",
  )
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
// (component (type (instance (type (instance (type u32) (export "data" (type (eq 0))))) (export "nested" (instance (type 0))))) (import "a" (instance (type 0))) (alias export 0 "nested" (instance)) (alias export 1 "data" (type)) (type (record (field "value" 1))) (import "data" (type (eq 2))))
test "declarative package nested-instance-alias" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x01\x42\x02\x01\x42\x02\x01\x79\x04\x00\x04\x64\x61\x74\x61\x03\x00\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x06\x13\x02\x05\x00\x00\x06\x6e\x65\x73\x74\x65\x64\x03\x00\x01\x04\x64\x61\x74\x61\x07\x0a\x01\x72\x01\x05\x76\x61\x6c\x75\x65\x01\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x02",
    source_id="nested-instance-alias.wasm",
  )
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
// (component (type (instance (type (list u64 1048576)) (export "data" (type (eq 0))))) (import "a" (instance (type 0))) (alias export 0 "data" (type)) (type (list 1 32)))
test "declarative package large-aliased-layout" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x67\x77\x80\x80\x40\x04\x00\x04\x64\x61\x74\x61\x03\x00\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x06\x09\x01\x03\x00\x00\x04\x64\x61\x74\x61\x07\x04\x01\x67\x01\x20",
    source_id="large-aliased-layout.wasm",
  )
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
// (component (import "f" (func (type 100))))
test "declarative package missing-function-type" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x64",
    source_id="missing-function-type.wasm",
  )
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
// (component (alias export 100 "data" (type)))
test "declarative package missing-alias-instance" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x09\x01\x03\x00\x64\x04\x64\x61\x74\x61",
    source_id="missing-alias-instance.wasm",
  )
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
// (component (import "f" (func)) (import "f" (func)))
test "declarative package duplicate-import" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01",
    source_id="duplicate-import.wasm",
  )
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
// (component (import "f" (func)) (export "f" (func 0)) (export "f" (func 0)))
test "declarative package duplicate-export" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x0d\x02\x00\x01\x66\x01\x00\x00\x00\x01\x66\x01\x00\x00",
    source_id="duplicate-export.wasm",
  )
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
test "declarative aliases preserve pinned prefix acceptance and binary offsets" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x01\x42\x02\x01\x42\x02\x01\x79\x04\x00\x04\x64\x61\x74\x61\x03\x00\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x06\x13\x02\x05\x00\x00\x06\x6e\x65\x73\x74\x65\x64\x03\x00\x01\x04\x64\x61\x74\x61\x07\x0a\x01\x72\x01\x05\x76\x61\x6c\x75\x65\x01\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x02"
  for end in 0..<bytes.length() {
    let result = @binary.validate_declarative_component(
      bytes[0:end].to_owned(),
      source_id="dep.wasm",
    )
    assert_eq(
      result is Ok(_),
      [8, 39, 47, 68, 80].contains(end),
      msg="prefix \{end}",
    )
    if result is Err(errors) {
      assert_eq(errors[0].source, "dep.wasm")
      assert_true(
        errors[0].offset
        .map(offset => offset >= 0 && offset <= end)
        .unwrap_or(true),
      )
    }
  }
}

///|
test "declarative validation does not widen the WIT type-only boundary" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1d\x01\x42\x02\x01\x42\x02\x01\x79\x04\x00\x04\x64\x61\x74\x61\x03\x00\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x06\x01\x00\x01\x61\x05\x00\x06\x13\x02\x05\x00\x00\x06\x6e\x65\x73\x74\x65\x64\x03\x00\x01\x04\x64\x61\x74\x61\x07\x0a\x01\x72\x01\x05\x76\x61\x6c\x75\x65\x01\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x02"
  assert_true(@binary.validate_declarative_component(bytes) is Ok(_))
  guard @binary.validate_type_component(bytes) is Err(errors) else {
    fail("WIT profile admitted root imports")
  }
  assert_eq(errors[0].code, "WIT-B002")
}

///|
test "declarative malformed sections are total and deterministic" {
  @quickcheck.check(
    (input : Array[Byte]) => {
      for section in [6, 10, 11] {
        let payload = Bytes::from_array(input)
        let bytes : Array[Byte] = [
          0,
          97,
          115,
          109,
          13,
          0,
          1,
          0,
          section.to_byte(),
        ]
        let mut length = payload.length()
        while length >= 128 {
          bytes.push(((length & 127) | 128).to_byte())
          length = length >> 7
        }
        bytes.push(length.to_byte())
        bytes.append(input)
        let bytes = Bytes::from_array(bytes)
        match
          @binary.validate_declarative_component(bytes, source_id="fuzz.wasm") {
          Ok(valid) => if valid.bytes() != bytes { return false }
          Err(errors) => {
            if !errors.all(error => {
                error.source == "fuzz.wasm" &&
                error.offset
                .map(offset => offset >= 0 && offset <= bytes.length())
                .unwrap_or(true)
              }) {
              return false
            }
            guard @binary.validate_declarative_component(
                bytes,
                source_id="fuzz.wasm",
              )
              is Err(again) else {
              return false
            }
            if again != errors {
              return false
            }
          }
        }
      }
      true
    },
    count=500,
    max_size=256,
    seed=258012,
  )
}

///|
test "declarative physical type scopes reject before dependency recursion" {
  let payload : Array[Byte] = [1]
  for _ in 0..<10000 {
    payload.append([0x41, 1, 1])
  }
  payload.push(0x79)
  guard @binary.validate_declarative_component(component_with_types(payload))
    is Err(errors) else {
    fail("deep scope accepted")
  }
  assert_eq(errors[0].code, "WIT-B002")
  assert_true(errors[0].offset.unwrap() < 1000)
}

///|
// (component (type (record (field "x" u32))) (type (map string 0)) (type (func (param "x" 1))) (import "f" (func (type 2))))
test "declarative package unnamed-map-value" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x03\x72\x01\x01\x78\x79\x63\x73\x00\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02",
  )
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
// (component (type (record (field "x" u32))) (import "item" (type (eq 0))) (type (map string 1)) (type (func (param "x" 2))) (import "f" (func (type 3))))
test "declarative package named-map-value" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x0a\x01\x00\x04\x69\x74\x65\x6d\x03\x00\x00\x07\x0b\x02\x63\x73\x01\x40\x01\x01\x78\x02\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x03",
  )
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
// (component (type (record (field "x" u32))) (type (list 0 2)) (type (func (param "x" 1))) (import "f" (func (type 2))))
test "declarative package unnamed-fixed-list-element" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x10\x03\x72\x01\x01\x78\x79\x67\x00\x02\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02",
  )
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
// (component (type (list u8 1073741825)))
test "declarative package fixed-list-count" {
  let result = @binary.validate_declarative_component(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x67\x7d\x81\x80\x80\x80\x04",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
}
