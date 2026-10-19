///|
test "core module text rejects duplicate-root-alias" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type $a (func)) (alias outer 0 $a (core type $a)))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects duplicate-nested-alias" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type $a (func)) (type (component (alias outer 1 $a (core type $a)) (alias outer 1 $a (core type $a)))))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects duplicate-root" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type $a (func)) (core type $a (func)))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects duplicate-nested" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (type (component (core type $a (func)) (core type $a (func)))))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects duplicate-module" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type (module (type $a (func)) (type $a (func)))))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects overflow-limit" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type (module (export \"m\" (memory i64 18446744073709551616)))))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects bad-separator" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type (module (export \"m\" (memory 1__0)))))",
    )
    is Err(_),
  )
}

///|
test "core module text rejects bad-global" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component (core type (module (export \"g\" (global (shared (mut i64)))))))",
    )
    is Err(_),
  )
}
