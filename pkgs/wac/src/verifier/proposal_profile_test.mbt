///|
fn assert_package(
  text : String,
  source : String,
) -> @verifier.BinaryPackage raise {
  match @verifier.decode_wat_component_package(text, source_id=source) {
    Ok(model) => model
    Err(errors) => {
      fail(errors[0].render())
      panic()
    }
  }
}

///|
fn assert_rejected(
  text : String,
  source : String,
  code : String,
) -> String raise {
  match @verifier.decode_wat_component_package(text, source_id=source) {
    Err(errors) => {
      if errors[0].code != code {
        fail(source + " " + errors[0].code + ": " + errors[0].message)
      }
      errors[0].message
    }
    Ok(_) => {
      fail("input was accepted")
      panic()
    }
  }
}

///|
test "async callback lift accepts the pinned core signature" {
  let text = "(component (core module $m (func (export \"callback\") (param i32 i32 i32) (result i32) unreachable) (func (export \"foo\") (param i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"callback\" (core func $callback)) (alias core export $i \"foo\" (core func $foo)) (func $foo (export \"foo\") async (param \"p1\" u32) (result u32) (canon lift (core func $foo) async (callback (core func $callback)))))"
  let model = assert_package(text, "async-callback.wat")
  let again = assert_package(text, "async-callback.wat")
  assert_eq(model.bytes(), again.bytes())
  assert_eq(binary_projection(model), binary_projection(again))
  assert_true(binary_projection(model).contains("true"))
}

///|
test "async stackful lift omits the callback status result" {
  let text = "(component (core module $m (func (export \"foo\") (param i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"foo\" (core func $foo)) (func $foo (export \"foo\") async (param \"p1\" u32) (result u32) (canon lift (core func $foo) async)))"
  let _ = assert_package(text, "async-stackful.wat")
  let wrong = "(component (core module $m (func (export \"foo\") (param i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"foo\" (core func $foo)) (func $foo (export \"foo\") async (param \"p1\" u32) (result u32) (canon lift (core func $foo) async)))"
  let message = assert_rejected(wrong, "async-stackful-wrong.wat", "WAC-B003")
  assert_true(message.contains("incompatible core external type"))
}

///|
test "async lower requires memory for a returned value" {
  let text = "(component (import \"foo\" (func $foo async (param \"p1\" u32) (result u32))) (core module $libc (memory (export \"memory\") 1)) (core instance $libc (instantiate $libc)) (alias core export $libc \"memory\" (core memory $memory)) (core func $foo (canon lower (func $foo) async (memory $memory))))"
  let _ = assert_package(text, "async-lower.wat")
  let missing = "(component (import \"foo\" (func $foo async (param \"p1\" u32) (result u32))) (core func $foo (canon lower (func $foo) async)))"
  let message = assert_rejected(missing, "async-lower-memory.wat", "WAC-B003")
  assert_true(message.contains("memory"))
  let sync = "(component (core module $m (func (export \"foo\") (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"foo\" (core func $foo)) (func $foo (export \"foo\") (result u32) (canon lift (core func $foo) async)))"
  let message = assert_rejected(sync, "async-sync-type.wat", "WAC-B003")
  assert_true(message.contains("async"))
}

///|
test "component start consumes a value and publishes its result" {
  let text = "(component (import \"v\" (value $v u32)) (core module $m (func (export \"f\") (param i32) (result i32) local.get 0)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func $f (export \"f\") (param \"x\" u32) (result u32) (canon lift (core func $f))) (start $f (value $v) (result $out)) (export \"out\" (value $out)))"
  let model = assert_package(text, "start.wat")
  let again = assert_package(text, "start.wat")
  assert_eq(binary_projection(model), binary_projection(again))
  assert_true(binary_projection(model).contains("out"))
  let mismatch = "(component (import \"v\" (value $v string)) (core module $m (func (export \"f\") (param i32) (result i32) unreachable)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func $f (param \"x\" u32) (result u32) (canon lift (core func $f))) (start $f (value $v) (result $out)) (export \"out\" (value $out)))"
  let message = assert_rejected(mismatch, "start-mismatch.wat", "WAC-B003")
  assert_true(message.contains("start"))
  let unused = "(component (core module $m (func (export \"f\") (result i32) i32.const 1)) (core instance $i (instantiate $m)) (alias core export $i \"f\" (core func $f)) (func $f (result u32) (canon lift (core func $f))) (start $f (result 1)))"
  let message = assert_rejected(unused, "start-unused.wat", "WAC-B003")
  assert_true(message.contains("value was not used"))
}

///|
test "malformed start and excluded proposals keep explicit diagnostics" {
  let malformed = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x09\x00",
    source_id="start.wasm",
  )
  guard malformed is Err(errors) else { fail("empty start section accepted") }
  assert_eq(errors[0].code, "WAC-B001")
  let intrinsic = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x08\x02\x01\x26",
    source_id="thread-index.wasm",
  )
  guard intrinsic is Err(errors) else { fail("thread.index accepted") }
  assert_eq(errors[0].code, "WAC-B002")
  assert_true(errors[0].message.contains("canonical intrinsic"))
  let shared_module = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x06\x01\x7f\x02\x41\x00\x0b\x07\x05\x01\x01\x67\x03\x00"
  let shared = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x17" + shared_module,
    source_id="shared-global.wasm",
  )
  guard shared is Err(errors) else { fail("shared global accepted") }
  assert_eq(errors[0].code, "WAC-B002")
  assert_true(errors[0].message.contains("shared"))
  let wide_module = b"\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x0d\x01\x0c\x80\x80\x80\x80\x80\x80\x80\x80\x80\x01\x00\x07\x05\x01\x01\x6d\x02\x00"
  let limit = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x1e" + wide_module,
    source_id="wide-limit.wasm",
  )
  assert_true(limit is Ok(_))
  let reference = assert_rejected(
    "(component (core module (type (struct)) (func (export \"f\") unreachable)))",
    "gc-struct.wat", "WAC-B002",
  )
  assert_true(
    reference.contains("GC") ||
    reference.contains("struct") ||
    reference.contains("heap"),
  )
  let exception = assert_rejected(
    "(component (core module (tag (export \"e\") (param i32)) (func (export \"f\") throw 0)))",
    "throw.wat", "WAC-B002",
  )
  assert_true(
    exception.contains("exception") ||
    exception.contains("throw") ||
    exception.contains("proposal"),
  )
}
