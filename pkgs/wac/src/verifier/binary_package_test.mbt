// Original component packages, compared with pinned WAC 0.12.0 Package::from_bytes.

///|
// (component (type u32) (export "n" (type 0) (type (eq 0))))
test "package graph valid-type-ascription" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x02\x01\x79\x0b\x0a\x01\x00\x01\x6e\x03\x00\x01\x03\x00\x00",
    source_id="valid-type-ascription.wasm",
  )
  assert_true(result is Ok(_))
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "n", "type", "scalar", "u32", "instance", "interface",
    "", "0", "1", "n", "type", "scalar", "u32", "definitions", "0",
  ])
}

///|
// (component (import "r" (type (sub resource))) (alias outer 0 0 (type)) (type (borrow 1)) (type (func (param "r" 2))) (import "f" (func (type 3))))
test "package graph outer-resource-alias" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x06\x05\x01\x03\x02\x00\x00\x07\x0a\x02\x68\x01\x40\x01\x01\x72\x02\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x03",
    source_id="outer-resource-alias.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "f", "func", "function",
    "false", "1", "r", "borrow", "0", "none", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
// (component (type (instance (export "r" (type (sub resource))))) (import "original" (instance (type 0))) (export "again" (instance 0)) (alias export 1 "r" (type)) (type (borrow 1)) (type (func (param "r" 2))) (import "f" (func (type 3))))
test "package graph reexported-resource-instance" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x0d\x01\x00\x08\x6f\x72\x69\x67\x69\x6e\x61\x6c\x05\x00\x0b\x0b\x01\x00\x05\x61\x67\x61\x69\x6e\x05\x00\x00\x06\x06\x01\x03\x00\x01\x01\x72\x07\x0a\x02\x68\x01\x40\x01\x01\x72\x02\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x03",
    source_id="reexported-resource-instance.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "original", "instance", "interface", "", "0", "1", "r",
    "type", "resource", "0", "f", "func", "function", "false", "1", "r", "borrow",
    "0", "none", "1", "again", "instance", "interface", "", "0", "1", "r", "type",
    "resource", "0", "instance", "interface", "", "0", "1", "again", "instance",
    "interface", "", "0", "1", "r", "type", "resource", "0", "definitions", "0",
  ])
}

///|
// (component (type (resource (rep i32))) (export "r" (type 0)) (type (borrow 1)) (type (func (param "r" 2))) (import "f" (func (type 3))))
test "package graph export-only-resource-import" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0a\x02\x68\x01\x40\x01\x01\x72\x02\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x03",
    source_id="export-only-resource-import.wasm",
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
// (component (type $api (instance (type u32) (export "n" (type (eq 0))))) (type (component (alias outer 1 0 (type)) (import "unused" (instance (type 0))))) (import "example:dep/api" (instance (type $api))))
test "package graph unused-template-identity" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1e\x02\x42\x02\x01\x79\x04\x00\x01\x6e\x03\x00\x00\x41\x02\x02\x03\x02\x01\x00\x03\x00\x06\x75\x6e\x75\x73\x65\x64\x05\x00\x0a\x14\x01\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x00\x03\x61\x70\x69",
    source_id="unused-template-identity.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "example:dep/api", "instance", "interface", "example:dep/api",
    "0", "1", "n", "type", "scalar", "u32", "0", "instance", "interface", "", "0",
    "0", "definitions", "0",
  ])
}

///|
// (component (import "r" (type (sub resource))) (type (own 0)) (type (func (result 1))) (import "f" (func (type 2))) (export "s" (type 0) (type (sub resource))) (export "f" (func 0)))
test "package graph root-resource-ascription" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x07\x02\x69\x00\x40\x00\x00\x01\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x0f\x02\x00\x01\x73\x03\x00\x01\x03\x01\x00\x01\x66\x01\x00\x00",
    source_id="root-resource-ascription.wasm",
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
// (component
//  (type $api (instance (export "r" (type (sub resource))) (type (own 0)) (type (func (result 1))) (export "make" (func (type 2)))))
//  (import "example:a/api" (instance (type $api))) (import "example:b/api" (instance (type $api)))
//  (alias export 0 "r" (type)) (alias export 1 "r" (type))
//  (type (borrow 1)) (type (borrow 2)) (type (func (param "a" 3) (param "b" 4))) (import "f" (func (type 5))))
test "package graph repeated-resource-instances" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x02\x0a\x23\x02\x00\x0d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x2f\x61\x70\x69\x05\x00\x00\x0d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x62\x2f\x61\x70\x69\x05\x00\x06\x0b\x02\x03\x00\x00\x01\x72\x03\x00\x01\x01\x72\x07\x0f\x03\x68\x01\x68\x02\x40\x02\x01\x61\x03\x01\x62\x04\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x05\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x00\x03\x61\x70\x69",
    source_id="repeated-resource-instances.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "3", "example:a/api", "instance", "interface", "example:a/api",
    "0", "2", "r", "type", "resource", "0", "make", "func", "function", "false",
    "0", "some", "own", "0", "example:b/api", "instance", "interface", "example:b/api",
    "0", "2", "r", "type", "resource", "1", "make", "func", "function", "false",
    "0", "some", "own", "1", "f", "func", "function", "false", "2", "a", "borrow",
    "0", "b", "borrow", "1", "none", "0", "instance", "interface", "", "0", "0",
    "definitions", "0",
  ])
}

///|
// (component (import "r" (type (sub resource)))
//  (type $api (instance (alias outer 1 0 (type)) (export "r" (type (eq 0))) (type (own 1)) (type (func (result 2))) (export "make" (func (type 3)))))
//  (import "example:a/api" (instance (type $api))) (import "example:b/api" (instance (type $api))))
test "package graph captured-resource-instances" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x20\x01\x42\x05\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x04\x6d\x61\x6b\x65\x01\x03\x0a\x23\x02\x00\x0d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x2f\x61\x70\x69\x05\x01\x00\x0d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x62\x2f\x61\x70\x69\x05\x01\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x01\x03\x61\x70\x69",
    source_id="captured-resource-instances.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "3", "r", "type", "resource", "0", "example:a/api", "instance",
    "interface", "example:a/api", "0", "2", "r", "type", "resource", "0", "make",
    "func", "function", "false", "0", "some", "own", "0", "example:b/api", "instance",
    "interface", "example:a/api", "0", "2", "r", "type", "resource", "0", "make",
    "func", "function", "false", "0", "some", "own", "0", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
}

///|
// (component
//  (type (instance (type (record (field "z" u32) (field "a" string))) (export "shape" (type (eq 0)))))
//  (import "example:dep/source" (instance (type 0))) (alias export 0 "shape" (type))
//  (type (instance (alias outer 1 1 (type)) (export "renamed" (type (eq 0)))))
//  (import "example:dep/consumer" (instance (type 2))))
test "package graph renamed-structural-use" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x42\x02\x01\x72\x02\x01\x7a\x79\x01\x61\x73\x04\x00\x05\x73\x68\x61\x70\x65\x03\x00\x00\x0a\x17\x01\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x73\x6f\x75\x72\x63\x65\x05\x00\x06\x0a\x01\x03\x00\x00\x05\x73\x68\x61\x70\x65\x07\x15\x01\x42\x02\x02\x03\x02\x01\x01\x04\x00\x07\x72\x65\x6e\x61\x6d\x65\x64\x03\x00\x00\x0a\x19\x01\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x63\x6f\x6e\x73\x75\x6d\x65\x72\x05\x02",
    source_id="renamed-structural-use.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "example:dep/source", "instance", "interface", "example:dep/source",
    "0", "1", "shape", "type", "record", "2", "z", "scalar", "u32", "a", "scalar",
    "string", "example:dep/consumer", "instance", "interface", "example:dep/consumer",
    "1", "renamed", "shape", "example:dep/source", "1", "renamed", "type", "record",
    "2", "z", "scalar", "u32", "a", "scalar", "string", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
}

///|
// (component
//  (type (instance (export "r" (type (sub resource)))))
//  (import "example:dep/source" (instance (type 0))) (alias export 0 "r" (type))
//  (type (instance (alias outer 1 1 (type)) (export "renamed" (type (eq 0))) (type (borrow 1)) (type (func (param "x" 2))) (export "f" (func (type 3)))))
//  (import "example:dep/consumer" (instance (type 2))))
test "package graph renamed-resource-use" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x0a\x17\x01\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x73\x6f\x75\x72\x63\x65\x05\x00\x06\x06\x01\x03\x00\x00\x01\x72\x07\x26\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x07\x72\x65\x6e\x61\x6d\x65\x64\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x19\x01\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x63\x6f\x6e\x73\x75\x6d\x65\x72\x05\x02",
    source_id="renamed-resource-use.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "example:dep/source", "instance", "interface", "example:dep/source",
    "0", "1", "r", "type", "resource", "0", "example:dep/consumer", "instance", "interface",
    "example:dep/consumer", "1", "renamed", "r", "example:dep/source", "2", "renamed",
    "type", "resource", "0", "f", "func", "function", "false", "1", "x", "borrow",
    "0", "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (type (component (type (instance (type u32) (export "n" (type (eq 0))))) (export "example:dep/api" (instance (type 0))))) (export "api" (type 0)))
test "package graph interface-definition" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x01\x41\x02\x01\x42\x02\x01\x79\x04\x00\x01\x6e\x03\x00\x00\x04\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00",
    source_id="interface-definition.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:dep/api",
    "instance", "interface", "example:dep/api", "0", "1", "n", "type", "scalar",
    "u32", "instance", "interface", "", "0", "1", "api", "type", "world", "", "0",
    "0", "1", "example:dep/api", "instance", "interface", "example:dep/api", "0",
    "1", "n", "type", "scalar", "u32", "definitions", "1", "api", "type", "interface",
    "example:dep/api", "0", "1", "n", "type", "scalar", "u32",
  ])
}

///|
// (component (type (component (type (component (type (func)) (import "f" (func (type 0))))) (export "example:dep/app" (component (type 0))))) (export "app" (type 0)))
test "package graph world-definition" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x25\x01\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00",
    source_id="world-definition.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "1", "app", "type", "world", "", "0", "0", "1", "example:dep/app",
    "component", "world", "example:dep/app", "0", "1", "f", "func", "function", "false",
    "0", "none", "0", "instance", "interface", "", "0", "1", "app", "type", "world",
    "", "0", "0", "1", "example:dep/app", "component", "world", "example:dep/app",
    "0", "1", "f", "func", "function", "false", "0", "none", "0", "definitions",
    "1", "app", "type", "world", "example:dep/app", "0", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
}

///|
// (component (type (record (field "z" u32) (field "a" string))) (import "r" (type (eq 0))) (type (func (param "z" 1) (param "a" u8) (result u64))) (import "f" (func (type 2))) (export "f" (func 0)))
test "package graph ordered-function-reexport" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x72\x02\x01\x7a\x79\x01\x61\x73\x0a\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0b\x01\x40\x02\x01\x7a\x01\x01\x61\x7d\x00\x77\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x07\x01\x00\x01\x66\x01\x00\x00",
    source_id="ordered-function-reexport.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "record", "2", "z", "scalar", "u32", "a",
    "scalar", "string", "f", "func", "function", "false", "2", "z", "record", "2",
    "z", "scalar", "u32", "a", "scalar", "string", "a", "scalar", "u8", "some", "scalar",
    "u64", "1", "f", "func", "function", "false", "2", "z", "record", "2", "z", "scalar",
    "u32", "a", "scalar", "string", "a", "scalar", "u8", "some", "scalar", "u64",
    "instance", "interface", "", "0", "1", "f", "func", "function", "false", "2",
    "z", "record", "2", "z", "scalar", "u32", "a", "scalar", "string", "a", "scalar",
    "u8", "some", "scalar", "u64", "definitions", "0",
  ])
}

///|
// (component (import "v" (value u32)) (export "v" (value 0)))
test "package graph value-reexport" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    source_id="value-reexport.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "primary" (implements "example:dep/api") (instance (type 0))))
test "package graph implements-instance" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1e\x01\x02\x07\x70\x72\x69\x6d\x61\x72\x79\x01\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00",
    source_id="implements-instance.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "primary", "instance", "interface", "example:dep/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "0", "instance", "interface",
    "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (type (list u32 7)) (import "data" (type (eq 0))))
test "package graph fixed-list" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x67\x79\x07\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x00",
    source_id="fixed-list.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "data", "type", "fixed-list", "7", "scalar", "u32", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (type (future u8)) (type (stream u16)) (type (func async (param "f" 0) (param "s" 1) (result error-context))) (import "f" (func (type 2))))
test "package graph async-future-stream" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x03\x65\x01\x7d\x66\x01\x7b\x43\x02\x01\x66\x00\x01\x73\x01\x00\x64\x0a\x06\x01\x00\x01\x66\x01\x02",
    source_id="async-future-stream.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "f", "func", "function", "true", "2", "f", "future", "some",
    "scalar", "u8", "s", "stream", "some", "scalar", "u16", "some", "scalar", "error-context",
    "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (type (map f32 string)) (import "data" (type (eq 0))))
test "package graph map-float-key" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x63\x76\x73\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x00",
    source_id="map-float-key.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "data", "type", "map", "scalar", "f32", "scalar", "string",
    "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (import "r" (type (sub resource))) (type (own 0)) (import "handle" (type (eq 1))))
test "package graph import-own" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01",
    source_id="import-own.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "handle", "type", "own",
    "0", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (import "r" (type (sub resource))) (type (own 0)) (export "handle" (type 1)))
test "package graph export-own" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x00",
    source_id="export-own.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "handle", "type", "own",
    "0", "instance", "interface", "", "0", "1", "handle", "type", "own", "0", "definitions",
    "0",
  ])
}

///|
// (component (type (component (type (future u32)) (type (map 0 string)) (import "data" (type (eq 1))))))
test "package graph wrapper-map-future" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x01\x41\x03\x01\x65\x01\x79\x01\x63\x00\x73\x03\x00\x04\x64\x61\x74\x61\x03\x00\x01",
    source_id="wrapper-map-future.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
// (component (type (component (import "r" (type (sub resource))) (type (own 0)) (export "handle" (type (eq 1))))))
test "package graph wrapper-export-own" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x69\x00\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01",
    source_id="wrapper-export-own.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
// (component (type (resource (rep i32))) (type (own 0)) (export "handle" (type 1)))
test "package graph unnamed-own" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x02\x3f\x7f\x00\x69\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x00",
    source_id="unnamed-own.wasm",
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
// (component (type u32) (type (map 0 string)) (import "data" (type (eq 1))))
test "package graph map-aliased-int" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x79\x63\x00\x73\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x01",
    source_id="map-aliased-int.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "data", "type", "map", "scalar", "u32", "scalar", "string",
    "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (type (component (type (map f32 string)) (import "data" (type (eq 0))))))
test "package graph wrapper-map-float" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x41\x02\x01\x63\x76\x73\x03\x00\x04\x64\x61\x74\x61\x03\x00\x00",
    source_id="wrapper-map-float.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
// (component (type (component (type u32) (type (map 0 string)) (import "data" (type (eq 1))))))
test "package graph wrapper-map-int" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x41\x03\x01\x79\x01\x63\x00\x73\x03\x00\x04\x64\x61\x74\x61\x03\x00\x01",
    source_id="wrapper-map-int.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
// (component (import "r" (type (sub resource))) (type (borrow 0)) (export "handle" (type 1)))
test "package graph export-borrow" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x68\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x00",
    source_id="export-borrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "r", "type", "resource", "0", "1", "handle", "type", "borrow",
    "0", "instance", "interface", "", "0", "1", "handle", "type", "borrow", "0",
    "definitions", "0",
  ])
}

///|
// (component (type (stream char)) (import "data" (type (eq 0))))
test "package graph stream-char" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x66\x01\x74\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x00",
    source_id="stream-char.wasm",
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
// (component (type (future u32)) (type (map 0 string)) (import "data" (type (eq 1))))
test "package graph map-future-key" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x02\x65\x01\x79\x63\x00\x73\x0a\x0a\x01\x00\x04\x64\x61\x74\x61\x03\x00\x01",
    source_id="map-future-key.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "data", "type", "map", "future", "some", "scalar", "u32",
    "scalar", "string", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
// (component (import "r" (type (sub resource))) (type (borrow 0)) (import "handle" (type (eq 1))))
test "package graph import-borrow" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x68\x00\x0a\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01",
    source_id="import-borrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "handle", "type", "borrow",
    "0", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
// (component (type (map 99 u32)))
test "package graph map-invalid-index" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x63\xe3\x00\x79",
    source_id="map-invalid-index.wasm",
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
// (component (type (component (import "r" (type (sub resource))) (type (borrow 0)) (export "handle" (type (eq 1))))))
test "package graph wrapper-export-borrow" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x41\x03\x03\x00\x01\x72\x03\x01\x01\x68\x00\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01",
    source_id="wrapper-export-borrow.wasm",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].message
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}
