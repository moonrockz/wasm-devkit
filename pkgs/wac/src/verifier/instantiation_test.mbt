// Original instantiation probes against WAC0.12.0 Document::resolve.
// The crossed-resource probe is accepted by Resolve but rejected by the same
// pin's validating wac compose: resource types are not the same.

// (component (type (func (param "x" u32) (result u32))) (import "f" (func (type 0))) (export "out" (func 0)))

///|
fn instantiation_function_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x00\x79\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (instance (type (func (param "x" u32) (result u32))) (export "f" (func (type 0))))) (import "api" (instance (type 0))) (export "api" (instance 0)))

///|
fn instantiation_instance_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x00\x79\x04\x00\x01\x66\x01\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00"
}

// (component (type (instance (export "handle" (type (sub resource))) (type (func (param "h" (own 0)))) (export "take" (func (type 2))))) (import "api" (instance (type 0))) (export "api" (instance 0)))

///|
fn instantiation_resource_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x01\x42\x04\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00"
}

// (component (type (component (type (func)) (import "f" (func (type 0))) (export "g" (func (type 0))))) (import "factory" (component (type 0))) (export "factory" (component 0)))

///|
fn instantiation_component_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x41\x03\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x0a\x0c\x01\x00\x07\x66\x61\x63\x74\x6f\x72\x79\x04\x00\x0b\x0d\x01\x00\x07\x66\x61\x63\x74\x6f\x72\x79\x04\x00\x00"
}

// (component (import "handle" (type (sub resource))) (type (func (param "h" (own 0)))) (import "take" (func (type 2))) (export "take" (func 0)))

///|
fn instantiation_cross_resource_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x02\x0b\x0a\x01\x00\x04\x74\x61\x6b\x65\x01\x00\x00"
}

// (component (type (list u32)) (type (func (param "x" 0))) (import "f" (func (type 1))) (export "out" (func 0)))

///|
fn instantiation_aggregate_list_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0a\x02\x70\x79\x40\x01\x01\x78\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (tuple u32 string)) (type (func (param "x" 0))) (import "f" (func (type 1))) (export "out" (func 0)))

///|
fn instantiation_aggregate_tuple_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x02\x6f\x02\x79\x73\x40\x01\x01\x78\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (option u32)) (type (func (param "x" 0))) (import "f" (func (type 1))) (export "out" (func 0)))

///|
fn instantiation_aggregate_option_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0a\x02\x6b\x79\x40\x01\x01\x78\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (result u32 (error string))) (type (func (param "x" 0))) (import "f" (func (type 1))) (export "out" (func 0)))

///|
fn instantiation_aggregate_result_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0d\x02\x6a\x01\x79\x01\x73\x40\x01\x01\x78\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (future u32)) (type (func (param "x" 0))) (import "f" (func (type 1))) (export "out" (func 0)))

///|
fn instantiation_aggregate_future_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x02\x65\x01\x79\x40\x01\x01\x78\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (stream u32)) (type (func (param "x" 0))) (import "f" (func (type 1))) (export "out" (func 0)))

///|
fn instantiation_aggregate_stream_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0b\x02\x66\x01\x79\x40\x01\x01\x78\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x01\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (record (field "a" u32) (field "b" string))) (import "t" (type (eq 0))) (type (func (param "x" 1))) (import "f" (func (type 2))) (export "out" (func 0)))

///|
fn instantiation_aggregate_record_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x72\x02\x01\x61\x79\x01\x62\x73\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (variant (case "a" u32) (case "b"))) (import "t" (type (eq 0))) (type (func (param "x" 1))) (import "f" (func (type 2))) (export "out" (func 0)))

///|
fn instantiation_aggregate_variant_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0c\x01\x71\x02\x01\x61\x01\x79\x00\x01\x62\x00\x00\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (flags "a" "b")) (import "t" (type (eq 0))) (type (func (param "x" 1))) (import "f" (func (type 2))) (export "out" (func 0)))

///|
fn instantiation_aggregate_flags_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x01\x6e\x02\x01\x61\x01\x62\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (enum "a" "b")) (import "t" (type (eq 0))) (type (func (param "x" 1))) (import "f" (func (type 2))) (export "out" (func 0)))

///|
fn instantiation_aggregate_enum_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x07\x01\x6d\x02\x01\x61\x01\x62\x0a\x07\x01\x00\x01\x74\x03\x00\x00\x07\x08\x01\x40\x01\x01\x78\x01\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x02\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "api" (instance (type 0))) (export "api" (instance (type 0))))) (import "factory" (component (type 0))) (export "factory" (component 0)))

///|
fn instantiation_nested_variance_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x21\x01\x41\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x03\x61\x70\x69\x05\x00\x04\x00\x03\x61\x70\x69\x05\x00\x0a\x0c\x01\x00\x07\x66\x61\x63\x74\x6f\x72\x79\x04\x00\x0b\x0d\x01\x00\x07\x66\x61\x63\x74\x6f\x72\x79\x04\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:app/api" (instance (type 0))) (export "api" (instance 0)))

///|
fn instantiation_qualified_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x61\x70\x70\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00"
}

// (component (type (resource (rep i32))) (export "handle" (type 0)))

///|
fn instantiation_resource_generator_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x04\x01\x3f\x7f\x00\x0b\x0c\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x00"
}

///|
test "pinned instantiation named" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {f: f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:f", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "instance:lookup:dep", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "alias:1:out", "func", "function", "false", "1", "x", "scalar", "u32",
    "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "f", "0", "2", "alias", "1", "out",
  ])
}

///|
test "pinned instantiation inferred" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:f", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "instance:lookup:dep", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "alias:1:out", "func", "function", "false", "1", "x", "scalar", "u32",
    "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "f", "0", "2", "alias", "1", "out",
  ])
}

///|
test "pinned instantiation group" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {f: ((f))}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:f", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "instance:lookup:dep", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "alias:1:out", "func", "function", "false", "1", "x", "scalar", "u32",
    "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "f", "0", "2", "alias", "1", "out",
  ])
}

///|
test "pinned instantiation missing" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation duplicate" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {f, f: f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation unknown" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {g: f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation param-name" {
  let source = "package test:app; import f: func(y: u32) -> u32; let i = new lookup:dep {f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation param-type" {
  let source = "package test:app; import f: func(x: u16) -> u32; let i = new lookup:dep {f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation result" {
  let source = "package test:app; import f: func(x: u32); let i = new lookup:dep {f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation async" {
  let source = "package test:app; import f: async func(x: u32) -> u32; let i = new lookup:dep {f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation kind" {
  let source = "package test:app; interface api{} import f: api; let i = new lookup:dep {f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation alias" {
  let source = "package test:app; import f: func(x: u32) -> u32; let a = f; let i = new lookup:dep {a}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:f", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "instance:lookup:dep", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "alias:1:out", "func", "function", "false", "1", "x", "scalar", "u32",
    "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "f", "0", "2", "alias", "1", "out",
  ])
}

///|
test "pinned instantiation quoted" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {\"f\": f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:f", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "instance:lookup:dep", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "alias:1:out", "func", "function", "false", "1", "x", "scalar", "u32",
    "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "f", "0", "2", "alias", "1", "out",
  ])
}

///|
test "pinned instantiation type-value" {
  let source = "package test:app; type t=func(x: u32)->u32; let i = new lookup:dep {f: t};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation nested" {
  let source = "package test:app; import f: func(x: u32) -> u32; let i = new lookup:dep {f:(new lookup:dep {f}).out}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "import:f", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "instance:lookup:dep", "instance", "interface", "", "0", "1",
    "out", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "alias:1:out", "func", "function", "false", "1", "x", "scalar", "u32",
    "some", "scalar", "u32", "instance:lookup:dep", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "scalar", "u32", "some",
    "scalar", "u32", "alias:3:out", "func", "function", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "f", "0", "2", "alias", "1", "out", "3", "f", "2", "4", "alias", "3", "out",
  ])
}

///|
test "pinned instantiation instance-exact" {
  let source = "package test:app; interface a{f: func(x: u32)->u32;} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_instance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "api", "instance", "interface", "test:app/a", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "u32", "2", "a", "type",
    "interface", "test:app/a", "0", "1", "f", "func", "function", "false", "1", "x",
    "scalar", "u32", "some", "scalar", "u32", "output", "instance", "interface",
    "", "0", "1", "api", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/a", "0", "1", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "u32", "import:api",
    "instance", "interface", "test:app/a", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "u32", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "api", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "u32",
    "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "api", "1"])
}

///|
test "pinned instantiation instance-extra" {
  let source = "package test:app; interface a{f: func(x: u32)->u32;g: func();} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_instance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "api", "instance", "interface", "test:app/a", "0", "2", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "u32", "g", "func", "function",
    "false", "0", "none", "2", "a", "type", "interface", "test:app/a", "0", "2",
    "f", "func", "function", "false", "1", "x", "scalar", "u32", "some", "scalar",
    "u32", "g", "func", "function", "false", "0", "none", "output", "instance", "interface",
    "", "0", "1", "api", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "u32", "some", "scalar", "u32",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/a", "0", "2", "f", "func",
    "function", "false", "1", "x", "scalar", "u32", "some", "scalar", "u32", "g",
    "func", "function", "false", "0", "none", "import:api", "instance", "interface",
    "test:app/a", "0", "2", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "u32", "g", "func", "function", "false", "0", "none",
    "instance:lookup:dep", "instance", "interface", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "1", "x", "scalar",
    "u32", "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "api", "1"])
}

///|
test "pinned instantiation instance-missing" {
  let source = "package test:app; interface a{g: func();} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_instance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation instance-different" {
  let source = "package test:app; interface a{f: func(x: u16)->u32;} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_instance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation resource-same-name" {
  let source = "package test:app; interface a{resource handle; take: func(h: handle);} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "api", "instance", "interface", "test:app/a", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "2", "a", "type", "interface", "test:app/a", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "output",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "", "0",
    "2", "handle", "type", "resource", "1", "take", "func", "function", "false",
    "1", "h", "own", "1", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/a", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:api", "instance", "interface", "test:app/a", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "instance:lookup:dep", "instance", "interface", "", "0", "1", "api", "instance",
    "interface", "", "0", "2", "handle", "type", "resource", "1", "take", "func",
    "function", "false", "1", "h", "own", "1", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "api", "1"])
}

///|
test "pinned instantiation resource-other-name" {
  let source = "package test:app; interface a{resource other; take: func(h: other);} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation resource-renamed-alias" {
  let source = "package test:app; interface a{resource other; type handle=other; take: func(h: handle);} import api: a; let i=new lookup:dep {api}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation component-exact" {
  let source = "package test:app; world a{import f: func(); export g: func();} import factory: a; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_component_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "factory", "component", "world", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "g", "func", "function", "false", "0", "none", "2",
    "a", "type", "world", "test:app/a", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "g", "func", "function", "false", "0", "none", "output", "instance",
    "interface", "", "0", "1", "factory", "component", "world", "", "0", "1", "f",
    "func", "function", "false", "0", "none", "1", "g", "func", "function", "false",
    "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "world", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "g", "func", "function", "false", "0", "none", "import:factory",
    "component", "world", "test:app/a", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "g", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "factory", "component", "world", "", "0",
    "1", "f", "func", "function", "false", "0", "none", "1", "g", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "factory", "1"])
}

///|
test "pinned instantiation component-fewer-imports" {
  let source = "package test:app; world a{export g: func();} import factory: a; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_component_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "factory", "component", "world", "test:app/a", "0", "0", "1", "g", "func",
    "function", "false", "0", "none", "2", "a", "type", "world", "test:app/a", "0",
    "0", "1", "g", "func", "function", "false", "0", "none", "output", "instance",
    "interface", "", "0", "1", "factory", "component", "world", "", "0", "1", "f",
    "func", "function", "false", "0", "none", "1", "g", "func", "function", "false",
    "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "world", "test:app/a", "0", "0", "1", "g", "func",
    "function", "false", "0", "none", "import:factory", "component", "world", "test:app/a",
    "0", "0", "1", "g", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "factory", "component", "world", "", "0",
    "1", "f", "func", "function", "false", "0", "none", "1", "g", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "factory", "1"])
}

///|
test "pinned instantiation component-more-imports" {
  let source = "package test:app; world a{import f: func();import h: func();export g: func();} import factory: a; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_component_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation component-more-exports" {
  let source = "package test:app; world a{import f: func();export g: func();export h: func();} import factory: a; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_component_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "factory", "component", "world", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "2", "g", "func", "function", "false", "0", "none", "h",
    "func", "function", "false", "0", "none", "2", "a", "type", "world", "test:app/a",
    "0", "1", "f", "func", "function", "false", "0", "none", "2", "g", "func", "function",
    "false", "0", "none", "h", "func", "function", "false", "0", "none", "output",
    "instance", "interface", "", "0", "1", "factory", "component", "world", "", "0",
    "1", "f", "func", "function", "false", "0", "none", "1", "g", "func", "function",
    "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "world", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "2", "g", "func", "function", "false", "0", "none", "h",
    "func", "function", "false", "0", "none", "import:factory", "component", "world",
    "test:app/a", "0", "1", "f", "func", "function", "false", "0", "none", "2", "g",
    "func", "function", "false", "0", "none", "h", "func", "function", "false", "0",
    "none", "instance:lookup:dep", "instance", "interface", "", "0", "1", "factory",
    "component", "world", "", "0", "1", "f", "func", "function", "false", "0", "none",
    "1", "g", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "factory", "1"])
}

///|
test "pinned instantiation component-fewer-exports" {
  let source = "package test:app; world a{import f: func();} import factory: a; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_component_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation resource-consistent" {
  let source = "package test:app; interface one{resource handle; take: func(h: handle);} interface two{resource handle; take: func(h: handle);} import a: one; import b: two; let i=new lookup:dep {handle: a.handle,take: a.take}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_cross_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/one", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "b", "instance", "interface", "test:app/two", "0", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "3",
    "one", "type", "interface", "test:app/one", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "two",
    "type", "interface", "test:app/two", "0", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "output",
    "instance", "interface", "", "0", "1", "take", "func", "function", "false", "1",
    "h", "own", "2", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "7", "definition", "type", "interface", "test:app/one", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "definition", "type", "interface", "test:app/two", "0", "2", "handle", "type",
    "resource", "1", "take", "func", "function", "false", "1", "h", "own", "1", "none",
    "import:a", "instance", "interface", "test:app/one", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:b", "instance", "interface", "test:app/two", "0", "2", "handle", "type",
    "resource", "1", "take", "func", "function", "false", "1", "h", "own", "1", "none",
    "alias:2:handle", "type", "resource", "0", "alias:2:take", "func", "function",
    "false", "1", "h", "own", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "1", "take", "func", "function", "false", "1", "h", "own", "2", "none",
    "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "4", "alias", "2", "handle", "5", "alias", "2", "take", "6", "handle", "4", "6",
    "take", "5",
  ])
}

///|
test "pinned instantiation resource-crossed" {
  let source = "package test:app; interface one{resource handle; take: func(h: handle);} interface two{resource handle; take: func(h: handle);} import a: one; import b: two; let i=new lookup:dep {handle: a.handle,take: b.take}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_cross_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C005")
}

///|
test "pinned instantiation same-interface-consistent" {
  let source = "package test:app; interface api{resource handle; take: func(h: handle);} import a: api; import b: api; let i=new lookup:dep {handle: a.handle,take: a.take}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_cross_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "b", "instance", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "2",
    "api", "type", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "output",
    "instance", "interface", "", "0", "1", "take", "func", "function", "false", "1",
    "h", "own", "1", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "6", "definition", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:b", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "alias:1:handle", "type", "resource", "0", "alias:1:take", "func", "function",
    "false", "1", "h", "own", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "1", "take", "func", "function", "false", "1", "h", "own", "1", "none",
    "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "3", "alias", "1", "handle", "4", "alias", "1", "take", "5", "handle", "3", "5",
    "take", "4",
  ])
}

///|
test "pinned instantiation same-interface-crossed" {
  let source = "package test:app; interface api{resource handle; take: func(h: handle);} import a: api; import b: api; let i=new lookup:dep {handle: a.handle,take: b.take}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_cross_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C005")
}

///|
test "pinned instantiation resource-argument-reverse" {
  let source = "package test:app; interface api{resource handle; take: func(h: handle);} import a: api; let i=new lookup:dep {take: a.take,handle: a.handle}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_cross_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "2", "api", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "output", "instance", "interface", "", "0", "1", "take", "func", "function",
    "false", "1", "h", "own", "1", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "definition", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "alias:1:take", "func", "function", "false", "1", "h", "own", "0", "none", "alias:1:handle",
    "type", "resource", "0", "instance:lookup:dep", "instance", "interface", "",
    "0", "1", "take", "func", "function", "false", "1", "h", "own", "1", "none",
    "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "alias", "1", "take", "3", "alias", "1", "handle", "4", "handle", "3", "4",
    "take", "2",
  ])
}

///|
test "pinned instantiation resource-through-instance" {
  let source = "package test:app; interface a{resource handle; take: func(h: handle);} import api: a; let i=new lookup:dep {api}; let j=new lookup:dep {api: i.api}; export j as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "api", "instance", "interface", "test:app/a", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "2", "a", "type", "interface", "test:app/a", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "output",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "", "0",
    "2", "handle", "type", "resource", "1", "take", "func", "function", "false",
    "1", "h", "own", "1", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "definition", "type", "interface", "test:app/a", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:api", "instance", "interface", "test:app/a", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "instance:lookup:dep", "instance", "interface", "", "0", "1", "api", "instance",
    "interface", "", "0", "2", "handle", "type", "resource", "1", "take", "func",
    "function", "false", "1", "h", "own", "1", "none", "alias:2:api", "instance",
    "interface", "", "0", "2", "handle", "type", "resource", "1", "take", "func",
    "function", "false", "1", "h", "own", "1", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "api", "instance", "interface", "", "0", "2", "handle",
    "type", "resource", "1", "take", "func", "function", "false", "1", "h", "own",
    "1", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "api", "1", "3", "alias", "2", "api", "4", "api", "3",
  ])
}

///|
test "pinned instantiation resource-type-alias" {
  let source = "package test:app; interface api {resource handle; take: func(h: handle);} import a: api; let handle=a.handle; import take: func(h: handle); let i=new lookup:dep {handle, take};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_cross_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "take", "func", "function", "false", "1", "h", "own", "0", "none", "1", "api",
    "type", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "definition", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "alias:1:handle", "type", "resource", "0", "import:take", "func", "function",
    "false", "1", "h", "own", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "1", "take", "func", "function", "false", "1", "h", "own", "1", "none",
    "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "alias", "1", "handle", "4", "handle", "2", "4", "take", "3",
  ])
}

///|
test "pinned instantiation aggregate-list-equal" {
  let source = "package test:app; type t = list<u32>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_list_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "list", "scalar", "u32", "none",
    "2", "t", "type", "list", "scalar", "u32", "out", "func", "function", "false",
    "1", "x", "list", "scalar", "u32", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "list", "scalar", "u32", "import:f", "func", "function",
    "false", "1", "x", "list", "scalar", "u32", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "list",
    "scalar", "u32", "none", "alias:2:out", "func", "function", "false", "1", "x",
    "list", "scalar", "u32", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-list-different" {
  let source = "package test:app; type t = list<u16>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_list_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-tuple-equal" {
  let source = "package test:app; type t = tuple<u32, string>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_tuple_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "tuple", "2", "scalar", "u32",
    "scalar", "string", "none", "2", "t", "type", "tuple", "2", "scalar", "u32",
    "scalar", "string", "out", "func", "function", "false", "1", "x", "tuple", "2",
    "scalar", "u32", "scalar", "string", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "tuple", "2", "scalar", "u32", "scalar", "string",
    "import:f", "func", "function", "false", "1", "x", "tuple", "2", "scalar", "u32",
    "scalar", "string", "none", "instance:lookup:dep", "instance", "interface", "",
    "0", "1", "out", "func", "function", "false", "1", "x", "tuple", "2", "scalar",
    "u32", "scalar", "string", "none", "alias:2:out", "func", "function", "false",
    "1", "x", "tuple", "2", "scalar", "u32", "scalar", "string", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-tuple-different" {
  let source = "package test:app; type t = tuple<string, u32>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_tuple_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-option-equal" {
  let source = "package test:app; type t = option<u32>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_option_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "option", "scalar", "u32", "none",
    "2", "t", "type", "option", "scalar", "u32", "out", "func", "function", "false",
    "1", "x", "option", "scalar", "u32", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "option", "scalar", "u32", "import:f", "func", "function",
    "false", "1", "x", "option", "scalar", "u32", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "option", "scalar", "u32", "none", "alias:2:out", "func", "function", "false",
    "1", "x", "option", "scalar", "u32", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-option-different" {
  let source = "package test:app; type t = option<u16>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_option_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-result-equal" {
  let source = "package test:app; type t = result<u32, string>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_result_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "result", "some", "scalar",
    "u32", "some", "scalar", "string", "none", "2", "t", "type", "result", "some",
    "scalar", "u32", "some", "scalar", "string", "out", "func", "function", "false",
    "1", "x", "result", "some", "scalar", "u32", "some", "scalar", "string", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "result", "some", "scalar", "u32", "some", "scalar",
    "string", "import:f", "func", "function", "false", "1", "x", "result", "some",
    "scalar", "u32", "some", "scalar", "string", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "result",
    "some", "scalar", "u32", "some", "scalar", "string", "none", "alias:2:out", "func",
    "function", "false", "1", "x", "result", "some", "scalar", "u32", "some", "scalar",
    "string", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-result-different" {
  let source = "package test:app; type t = result<u32>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_result_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-future-equal" {
  let source = "package test:app; type t = future<u32>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_future_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "future", "some", "scalar",
    "u32", "none", "2", "t", "type", "future", "some", "scalar", "u32", "out", "func",
    "function", "false", "1", "x", "future", "some", "scalar", "u32", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "future", "some", "scalar", "u32", "import:f", "func",
    "function", "false", "1", "x", "future", "some", "scalar", "u32", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "future", "some", "scalar", "u32", "none", "alias:2:out", "func", "function",
    "false", "1", "x", "future", "some", "scalar", "u32", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-future-different" {
  let source = "package test:app; type t = future; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_future_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-stream-equal" {
  let source = "package test:app; type t = stream<u32>; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_stream_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "stream", "some", "scalar",
    "u32", "none", "2", "t", "type", "stream", "some", "scalar", "u32", "out", "func",
    "function", "false", "1", "x", "stream", "some", "scalar", "u32", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "stream", "some", "scalar", "u32", "import:f", "func",
    "function", "false", "1", "x", "stream", "some", "scalar", "u32", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "1",
    "x", "stream", "some", "scalar", "u32", "none", "alias:2:out", "func", "function",
    "false", "1", "x", "stream", "some", "scalar", "u32", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-stream-different" {
  let source = "package test:app; type t = stream; import f: func(x: t); let i=new lookup:dep {f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_stream_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-record-equal" {
  let source = "package test:app; record t {a: u32, b: string} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_record_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "record", "2", "a", "scalar",
    "u32", "b", "scalar", "string", "none", "2", "t", "type", "record", "2", "a",
    "scalar", "u32", "b", "scalar", "string", "out", "func", "function", "false",
    "1", "x", "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "record", "2", "a", "scalar", "u32", "b", "scalar",
    "string", "import:f", "func", "function", "false", "1", "x", "record", "2", "a",
    "scalar", "u32", "b", "scalar", "string", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "record",
    "2", "a", "scalar", "u32", "b", "scalar", "string", "none", "alias:2:out", "func",
    "function", "false", "1", "x", "record", "2", "a", "scalar", "u32", "b", "scalar",
    "string", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "2", "t", "0", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-record-different" {
  let source = "package test:app; record t {b: string, a: u32} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_record_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-variant-equal" {
  let source = "package test:app; variant t {a(u32), b} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_variant_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "variant", "2", "a", "some",
    "scalar", "u32", "b", "none", "none", "2", "t", "type", "variant", "2", "a",
    "some", "scalar", "u32", "b", "none", "out", "func", "function", "false", "1",
    "x", "variant", "2", "a", "some", "scalar", "u32", "b", "none", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "variant", "2", "a", "some", "scalar", "u32", "b",
    "none", "import:f", "func", "function", "false", "1", "x", "variant", "2", "a",
    "some", "scalar", "u32", "b", "none", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "variant",
    "2", "a", "some", "scalar", "u32", "b", "none", "none", "alias:2:out", "func",
    "function", "false", "1", "x", "variant", "2", "a", "some", "scalar", "u32",
    "b", "none", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "2", "t", "0", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-variant-different" {
  let source = "package test:app; variant t {a, b(u32)} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_variant_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-flags-equal" {
  let source = "package test:app; flags t {a, b} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_flags_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "flags", "2", "a", "b", "none",
    "2", "t", "type", "flags", "2", "a", "b", "out", "func", "function", "false",
    "1", "x", "flags", "2", "a", "b", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "flags", "2", "a", "b", "import:f", "func", "function",
    "false", "1", "x", "flags", "2", "a", "b", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "flags",
    "2", "a", "b", "none", "alias:2:out", "func", "function", "false", "1", "x",
    "flags", "2", "a", "b", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "2", "t", "0", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-flags-different" {
  let source = "package test:app; flags t {b, a} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_flags_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation aggregate-enum-equal" {
  let source = "package test:app; enum t {a, b} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_enum_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "1", "x", "enum", "2", "a", "b", "none",
    "2", "t", "type", "enum", "2", "a", "b", "out", "func", "function", "false",
    "1", "x", "enum", "2", "a", "b", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "4", "definition", "type", "enum", "2", "a", "b", "import:f", "func", "function",
    "false", "1", "x", "enum", "2", "a", "b", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "1", "out", "func", "function", "false", "1", "x", "enum",
    "2", "a", "b", "none", "alias:2:out", "func", "function", "false", "1", "x",
    "enum", "2", "a", "b", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "f", "1", "2", "t", "0", "3", "alias", "2", "out",
  ])
}

///|
test "pinned instantiation aggregate-enum-different" {
  let source = "package test:app; enum t {b, a} import f: func(x: t); let i=new lookup:dep {t, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_aggregate_enum_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation nested-exact" {
  let source = "package test:app; interface a {f: func();} interface b {f: func();} world w {import api: a; export api: b;} import factory: w; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_nested_variance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "factory", "component", "world", "test:app/w", "0", "1", "api", "instance",
    "interface", "test:app/a", "0", "1", "f", "func", "function", "false", "0", "none",
    "1", "api", "instance", "interface", "test:app/b", "0", "1", "f", "func", "function",
    "false", "0", "none", "4", "a", "type", "interface", "test:app/a", "0", "1",
    "f", "func", "function", "false", "0", "none", "b", "type", "interface", "test:app/b",
    "0", "1", "f", "func", "function", "false", "0", "none", "w", "type", "world",
    "test:app/w", "0", "1", "api", "instance", "interface", "test:app/a", "0", "1",
    "f", "func", "function", "false", "0", "none", "1", "api", "instance", "interface",
    "test:app/b", "0", "1", "f", "func", "function", "false", "0", "none", "output",
    "instance", "interface", "", "0", "1", "factory", "component", "world", "", "0",
    "1", "api", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "api", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "definition", "type", "interface", "test:app/a", "0", "1", "f", "func",
    "function", "false", "0", "none", "definition", "type", "interface", "test:app/b",
    "0", "1", "f", "func", "function", "false", "0", "none", "definition", "type",
    "world", "test:app/w", "0", "1", "api", "instance", "interface", "test:app/a",
    "0", "1", "f", "func", "function", "false", "0", "none", "1", "api", "instance",
    "interface", "test:app/b", "0", "1", "f", "func", "function", "false", "0", "none",
    "import:factory", "component", "world", "test:app/w", "0", "1", "api", "instance",
    "interface", "test:app/a", "0", "1", "f", "func", "function", "false", "0", "none",
    "1", "api", "instance", "interface", "test:app/b", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance:lookup:dep", "instance", "interface", "", "0",
    "1", "factory", "component", "world", "", "0", "1", "api", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "none", "1", "api", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["4", "factory", "3"])
}

///|
test "pinned instantiation nested-narrow-import" {
  let source = "package test:app; interface a {f: func(); g: func();} interface b {f: func();} world w {import api: a; export api: b;} import factory: w; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_nested_variance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation nested-wide-import" {
  let source = "package test:app; interface a {} interface b {f: func();} world w {import api: a; export api: b;} import factory: w; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_nested_variance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "factory", "component", "world", "test:app/w", "0", "1", "api", "instance",
    "interface", "test:app/a", "0", "0", "1", "api", "instance", "interface", "test:app/b",
    "0", "1", "f", "func", "function", "false", "0", "none", "4", "a", "type", "interface",
    "test:app/a", "0", "0", "b", "type", "interface", "test:app/b", "0", "1", "f",
    "func", "function", "false", "0", "none", "w", "type", "world", "test:app/w",
    "0", "1", "api", "instance", "interface", "test:app/a", "0", "0", "1", "api",
    "instance", "interface", "test:app/b", "0", "1", "f", "func", "function", "false",
    "0", "none", "output", "instance", "interface", "", "0", "1", "factory", "component",
    "world", "", "0", "1", "api", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "api", "instance", "interface", "", "0",
    "1", "f", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "definition", "type", "interface", "test:app/a", "0", "0", "definition",
    "type", "interface", "test:app/b", "0", "1", "f", "func", "function", "false",
    "0", "none", "definition", "type", "world", "test:app/w", "0", "1", "api", "instance",
    "interface", "test:app/a", "0", "0", "1", "api", "instance", "interface", "test:app/b",
    "0", "1", "f", "func", "function", "false", "0", "none", "import:factory", "component",
    "world", "test:app/w", "0", "1", "api", "instance", "interface", "test:app/a",
    "0", "0", "1", "api", "instance", "interface", "test:app/b", "0", "1", "f", "func",
    "function", "false", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "1", "factory", "component", "world", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "1",
    "api", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["4", "factory", "3"])
}

///|
test "pinned instantiation nested-wide-export" {
  let source = "package test:app; interface a {f: func();} interface b {f: func(); g: func();} world w {import api: a; export api: b;} import factory: w; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_nested_variance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "factory", "component", "world", "test:app/w", "0", "1", "api", "instance",
    "interface", "test:app/a", "0", "1", "f", "func", "function", "false", "0", "none",
    "1", "api", "instance", "interface", "test:app/b", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "4", "a",
    "type", "interface", "test:app/a", "0", "1", "f", "func", "function", "false",
    "0", "none", "b", "type", "interface", "test:app/b", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "w", "type",
    "world", "test:app/w", "0", "1", "api", "instance", "interface", "test:app/a",
    "0", "1", "f", "func", "function", "false", "0", "none", "1", "api", "instance",
    "interface", "test:app/b", "0", "2", "f", "func", "function", "false", "0", "none",
    "g", "func", "function", "false", "0", "none", "output", "instance", "interface",
    "", "0", "1", "factory", "component", "world", "", "0", "1", "api", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "1",
    "api", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "5", "definition", "type", "interface", "test:app/a", "0", "1", "f", "func",
    "function", "false", "0", "none", "definition", "type", "interface", "test:app/b",
    "0", "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "0", "none", "definition", "type", "world", "test:app/w", "0", "1",
    "api", "instance", "interface", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "api", "instance", "interface", "test:app/b", "0",
    "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "0", "none", "import:factory", "component", "world", "test:app/w", "0",
    "1", "api", "instance", "interface", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "api", "instance", "interface", "test:app/b", "0",
    "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "0", "none", "instance:lookup:dep", "instance", "interface", "", "0",
    "1", "factory", "component", "world", "", "0", "1", "api", "instance", "interface",
    "", "0", "1", "f", "func", "function", "false", "0", "none", "1", "api", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["4", "factory", "3"])
}

///|
test "pinned instantiation nested-narrow-export" {
  let source = "package test:app; interface a {f: func();} interface b {} world w {import api: a; export api: b;} import factory: w; let i=new lookup:dep {factory}; export i as output;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_nested_variance_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation qualified-identity" {
  let source = "package test:app; interface api {f: func();} import other: api; let i=new lookup:dep {other};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_qualified_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "other", "instance", "interface", "test:app/api", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "api", "type", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "1", "f", "func",
    "function", "false", "0", "none", "import:other", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "test:app/api", "1"])
}

///|
test "pinned instantiation qualified-suffix" {
  let source = "package test:app; interface a {f: func();} import api: a; let i=new lookup:dep {api};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_qualified_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "api", "instance", "interface", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "a", "type", "interface", "test:app/a", "0", "1",
    "f", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/a", "0", "1", "f", "func",
    "function", "false", "0", "none", "import:api", "instance", "interface", "test:app/a",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "test:app/api", "1"])
}

///|
test "pinned instantiation qualified-named" {
  let source = "package test:app; interface a {f: func();} import other: a; let i=new lookup:dep {api: other};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_qualified_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "other", "instance", "interface", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "a", "type", "interface", "test:app/a", "0", "1",
    "f", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/a", "0", "1", "f", "func",
    "function", "false", "0", "none", "import:other", "instance", "interface", "test:app/a",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "test:app/api", "1"])
}

///|
test "pinned instantiation qualified-quoted" {
  let source = "package test:app; interface a {f: func();} import other: a; let i=new lookup:dep {\"test:app/api\": other};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_qualified_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "other", "instance", "interface", "test:app/a", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "a", "type", "interface", "test:app/a", "0", "1",
    "f", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/a", "0", "1", "f", "func",
    "function", "false", "0", "none", "import:other", "instance", "interface", "test:app/a",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "test:app/api", "1"])
}

///|
test "pinned instantiation qualified-quoted-suffix" {
  let source = "package test:app; interface a {f: func();} import other: a; let i=new lookup:dep {\"api\": other};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_qualified_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned instantiation qualified-alias" {
  let source = "package test:app; interface api {f: func();} import other: api; let copy=other; let i=new lookup:dep {copy};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_qualified_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "other", "instance", "interface", "test:app/api", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "api", "type", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "definition", "type", "interface", "test:app/api", "0", "1", "f", "func",
    "function", "false", "0", "none", "import:other", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "api", "instance", "interface", "test:app/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), ["2", "test:app/api", "1"])
}

///|
test "pinned instantiation fresh-export" {
  let source = "package test:app; let first=new lookup:dep {}; let second=new lookup:dep {}; export first as first; export second as second;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_resource_generator_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "0", "2", "first", "instance", "interface", "", "0", "1", "handle", "type", "resource",
    "0", "second", "instance", "interface", "", "0", "1", "handle", "type", "resource",
    "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "2", "instance:lookup:dep", "instance", "interface", "", "0", "1", "handle",
    "type", "resource", "0", "instance:lookup:dep", "instance", "interface", "",
    "0", "1", "handle", "type", "resource", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [])
}
