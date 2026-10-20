///|
fn component_compatibility_fixture(
  bytes : Bytes,
  expected : String,
) -> Unit raise {
  let printed = @decompiler.print_binary(
    bytes,
    compatibility=Some(@decompiler.Compatibility::WasmTools),
  )
  let actual = match printed {
    Ok(printed) => printed.root().text
    Err(errors) => fail("component rejected: \{errors[0].message}")
  }
  let actual_lines = actual.split("\n").to_array()
  let expected_lines = expected.split("\n").to_array()
  for i in 0..<expected_lines.length() {
    assert_true(i < actual_lines.length(), msg="missing line \{i}")
    assert_eq(
      actual_lines[i],
      expected_lines[i],
      msg="line \{i}: actual=\{actual_lines[i]} expected=\{expected_lines[i]}",
    )
  }
  assert_eq(actual_lines.length(), expected_lines.length())
}

///|
test "pinned wasm-tools: component-core-alias" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x11\x02\x60\x01\x7f\x00\x50\x02\x02\x10\x01\x01\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x01\x0b\x0a\x01\x00\x03\x6f\x75\x74\x00\x11\x00\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x66\x01\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d",
    (
      #|(component
      #|  (core type $f (;0;) (func (param i32)))
      #|  (core type $m (;1;)
      #|    (module
      #|      (alias outer 1 $f (type (;0;)))
      #|      (export "f" (func (type 0)))
      #|    )
      #|  )
      #|  (import "m" (core module $m (;0;) (type $m)))
      #|  (export (;1;) "out" (core module $m))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-core-name" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x08\x00\x61\x73\x6d\x01\x00\x00\x00\x02\x04\x01\x00\x00\x00\x00\x12\x04\x6e\x61\x6d\x65\x00\x05\x04\x72\x6f\x6f\x74\x01\x04\x01\x00\x01\x66",
    (
      #|(component $root
      #|  (core module (;0;))
      #|  (core instance (;0;) (instantiate 0))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-core-types" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1b\x02\x60\x02\x7f\x7e\x01\x7f\x50\x03\x01\x60\x00\x00\x00\x03\x65\x6e\x76\x01\x61\x00\x00\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x01\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x00\x10\x02\x00\x01\x61\x01\x01\x6d\x01\x06\x00\x11\x01\x00\x01\x6d",
    (
      #|(component
      #|  (core type $a (;0;) (func (param i32 i64) (result i32)))
      #|  (core type $m (;1;)
      #|    (module
      #|      (type (;0;) (func))
      #|      (import "env" "a" (func (type 0)))
      #|      (export "f" (func (type 0)))
      #|    )
      #|  )
      #|  (import "m" (core module $m (;0;) (type $m)))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-custom" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x07\x02\xc3\xbc\x64\x61\x74\x61\x00\x22\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x08\x6c\x61\x6e\x67\x75\x61\x67\x65\x01\x07\x4d\x6f\x6f\x6e\x42\x69\x74\x04\x30\x2e\x31\x30",
    (
      #|(component
      #|  (@custom "\u{fc}" "data")
      #|  (@producers
      #|    (language "MoonBit" "0.10")
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-deep" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x8a\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x41\x01\x01\x42\x00",
    (
      #|(component
      #|  (type (;0;)
      #|    (component
      #|      (type (;0;)
      #|        (component
      #|          (type (;0;)
      #|            (component
      #|              (type (;0;)
      #|                (component
      #|                  (type (;0;)
      #|                    (component
      #|                      (type (;0;)
      #|                        (component
      #|                          (type (;0;)
      #|                            (component
      #|                              (type (;0;)
      #|                                (component
      #|                                  (type (;0;)
      #|                                    (component
      #|                                      (type (;0;)
      #|                                        (component
      #|                                          (type (;0;)
      #|                                            (component
      #|                                              (type (;0;)
      #|                                                (component
      #|                                                  (type (;0;)
      #|                                                    (component
      #|                                                      (type (;0;)
      #|                                                        (component
      #|                                                          (type (;0;)
      #|                                                            (component
      #|                                                              (type (;0;)
      #|                                                                (component
      #|                                                                  (type (;0;)
      #|                                                                    (component
      #|                                                                      (type (;0;)
      #|                                                                        (component
      #|                                                                          (type (;0;)
      #|                                                                            (component
      #|                                                                              (type (;0;)
      #|                                                                                (component
      #|                                                                                  (type (;0;)
      #|                                                                                    (component
      #|                                                                                      (type (;0;)
      #|                                                                                        (component
      #|                                                                                          (type (;0;)
      #|                                                                                            (component
      #|                                                                                              (type (;0;)
      #|                                                                                                (component
      #|                                                                                                  (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (component
      #|                                                                                                    (type (;0;)
      #|                                                                                                    (instance)
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                    )
      #|                                                                                                  )
      #|                                                                                                )
      #|                                                                                              )
      #|                                                                                            )
      #|                                                                                          )
      #|                                                                                        )
      #|                                                                                      )
      #|                                                                                    )
      #|                                                                                  )
      #|                                                                                )
      #|                                                                              )
      #|                                                                            )
      #|                                                                          )
      #|                                                                        )
      #|                                                                      )
      #|                                                                    )
      #|                                                                  )
      #|                                                                )
      #|                                                              )
      #|                                                            )
      #|                                                          )
      #|                                                        )
      #|                                                      )
      #|                                                    )
      #|                                                  )
      #|                                                )
      #|                                              )
      #|                                            )
      #|                                          )
      #|                                        )
      #|                                      )
      #|                                    )
      #|                                  )
      #|                                )
      #|                              )
      #|                            )
      #|                          )
      #|                        )
      #|                      )
      #|                    )
      #|                  )
      #|                )
      #|              )
      #|            )
      #|          )
      #|        )
      #|      )
      #|    )
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-empty-module" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x08\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x08\x00\x61\x73\x6d\x0d\x00\x01\x00",
    (
      #|(component
      #|  (core module (;0;))
      #|  (component (;0;))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-empty-types" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x02\x41\x00\x42\x00\x03\x03\x01\x50\x00",
    (
      #|(component
      #|  (type (;0;)
      #|    (component)
      #|  )
      #|  (type (;1;)
      #|    (instance)
      #|  )
      #|  (core type (;0;)
      #|    (module)
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-empty" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
    (
      #|(component)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-instances" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x24\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x2b\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x0a\x04\x6e\x61\x6d\x65\x00\x03\x02\x6d\x32\x02\x0d\x02\x00\x01\x00\x00\x00\x01\x03\x65\x6e\x76\x12\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x02\x07\x01\x01\x01\x01\x66\x00\x00\x00\x2a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0a\x00\x11\x02\x00\x01\x6d\x01\x02\x6d\x32\x01\x0d\x00\x12\x03\x00\x01\x69\x01\x02\x69\x32\x02\x01\x65",
    (
      #|(component
      #|  (core module $m (;0;)
      #|    (type (;0;) (func))
      #|    (import "env" "f" (func (;0;) (type 0)))
      #|  )
      #|  (core module $m2 (;1;)
      #|    (type (;0;) (func))
      #|    (export "f" (func 0))
      #|    (func (;0;) (type 0))
      #|  )
      #|  (core instance $i (;0;) (instantiate $m2))
      #|  (core instance $i2 (;1;) (instantiate $m
      #|      (with "env" (instance $i))
      #|    )
      #|  )
      #|  (alias core export $i "f" (core func (;0;)))
      #|  (core instance $e (;2;)
      #|    (export "f" (func 0))
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-malformed-custom" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x00\x0f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x01\x78\x01\xff\x01\x16\x00\x61\x73\x6d\x01\x00\x00\x00\x00\x0c\x08\x64\x79\x6c\x69\x6e\x6b\x2e\x30\x01\x01\x00",
    (
      #|(component
      #|  ;; failed to parse custom section `producers`: invalid producers field name: `x` (at offset 0x15)
      #|  (@custom "producers" "\01\01x\01\ff")
      #|  (core module (;0;)
      #|    ;; failed to parse custom section `dylink.0`: unexpected end-of-file (at offset 0x31)
      #|    (@custom "dylink.0" (before first) "\01\01\00")
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-named-outer" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x11\x02\x60\x01\x7f\x00\x50\x02\x02\x10\x01\x01\x00\x03\x01\x66\x00\x00\x07\x03\x01\x70\x79\x04\x3d\x00\x61\x73\x6d\x0d\x00\x01\x00\x06\x05\x01\x03\x02\x01\x00\x07\x08\x01\x40\x01\x01\x78\x00\x01\x00\x00\x22\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x06\x05\x63\x68\x69\x6c\x64\x01\x09\x03\x01\x00\x05\x61\x6c\x69\x61\x73\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x00\x05\x04\x72\x6f\x6f\x74\x01\x09\x00\x10\x02\x00\x01\x66\x01\x01\x6d\x01\x05\x03\x01\x00\x01\x74\x01\x09\x04\x01\x00\x05\x63\x68\x69\x6c\x64",
    (
      #|(component $root
      #|  (core type $f (;0;) (func (param i32)))
      #|  (core type $m (;1;)
      #|    (module
      #|      (alias outer $root $f (type (;0;)))
      #|      (export "f" (func (type 0)))
      #|    )
      #|  )
      #|  (type $t (;0;) (list u32))
      #|  (component $child (;0;)
      #|    (alias outer $root $t (type $alias (;0;)))
      #|    (type (;1;) (func (param "x" $alias)))
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-package-component" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x57\x01\x41\x02\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x70\x73\x01\x72\x02\x02\x69\x64\x79\x04\x74\x61\x67\x73\x02\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x03\x01\x40\x02\x01\x78\x73\x01\x69\x04\x00\x01\x04\x00\x04\x6d\x61\x6b\x65\x01\x05\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x70\x6b\x67\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x00\x7b\x7d",
    (
      #|(component
      #|  (type (;0;)
      #|    (component
      #|      (type (;0;)
      #|        (instance
      #|          (export (;0;) "r" (type (sub resource)))
      #|          (type (;1;) (own 0))
      #|          (type (;2;) (list string))
      #|          (type (;3;) (record (field "id" u32) (field "tags" 2)))
      #|          (export (;4;) "item" (type (eq 3)))
      #|          (type (;5;) (func (param "x" string) (param "i" 4) (result 1)))
      #|          (export (;0;) "make" (func (type 5)))
      #|        )
      #|      )
      #|      (export (;0;) "example:pkg/api@1.0.0" (instance (type 0)))
      #|    )
      #|  )
      #|  (export (;1;) "api" (type 0))
      #|  (@custom "package-docs" "\00{}")
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-resource" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x01\x7f\x00\x03\x02\x01\x00\x07\x08\x01\x04\x64\x74\x6f\x72\x00\x00\x0a\x04\x01\x02\x00\x0b\x02\x04\x01\x00\x00\x00\x06\x0a\x01\x00\x00\x01\x00\x04\x64\x74\x6f\x72\x07\x0e\x03\x3f\x7f\x01\x00\x69\x00\x40\x01\x01\x72\x01\x01\x00\x08\x03\x01\x02\x00\x00\x24\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x01\x01\x6e\x01\x0b\x03\x03\x00\x01\x72\x01\x01\x6f\x02\x01\x66",
    (
      #|(component
      #|  (core module (;0;)
      #|    (type (;0;) (func (param i32)))
      #|    (export "dtor" (func 0))
      #|    (func (;0;) (type 0) (param i32))
      #|  )
      #|  (core instance (;0;) (instantiate 0))
      #|  (alias core export 0 "dtor" (core func (;0;)))
      #|  (type $r (;0;) (resource (rep i32) (dtor 0)))
      #|  (type $o (;1;) (own $r))
      #|  (type $f (;2;) (func (param "r" $o)))
      #|  (core func $n (;1;) (canon resource.new $r))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-runtime-component" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x15\x01\x42\x02\x01\x40\x01\x03\x6d\x73\x67\x73\x01\x00\x04\x00\x03\x6c\x6f\x67\x01\x00\x0a\x09\x01\x00\x04\x68\x6f\x73\x74\x05\x00\x06\x08\x01\x01\x00\x00\x03\x6c\x6f\x67\x01\x45\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x01\x60\x04\x7f\x7f\x7f\x7f\x01\x7f\x03\x02\x01\x00\x05\x03\x01\x00\x01\x07\x11\x02\x03\x6d\x65\x6d\x02\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x00\x00\x0a\x06\x01\x04\x00\x41\x00\x0b\x00\x0c\x04\x6e\x61\x6d\x65\x00\x05\x04\x6c\x69\x62\x63\x02\x04\x01\x00\x00\x00\x06\x15\x02\x00\x02\x01\x00\x03\x6d\x65\x6d\x00\x00\x01\x00\x07\x72\x65\x61\x6c\x6c\x6f\x63\x08\x0a\x01\x01\x00\x00\x03\x03\x00\x04\x00\x00\x01\x3f\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x09\x02\x60\x02\x7f\x7f\x00\x60\x00\x00\x02\x0c\x01\x04\x68\x6f\x73\x74\x03\x6c\x6f\x67\x00\x00\x03\x02\x01\x01\x07\x07\x01\x03\x72\x75\x6e\x00\x01\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x13\x02\x01\x01\x03\x6c\x6f\x67\x00\x01\x00\x01\x01\x04\x68\x6f\x73\x74\x12\x01\x07\x05\x01\x40\x00\x01\x00\x06\x09\x01\x00\x00\x01\x02\x03\x72\x75\x6e\x08\x06\x01\x00\x00\x02\x00\x01\x0b\x09\x01\x00\x03\x72\x75\x6e\x01\x01\x00\x00\x53\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x00\x00\x01\x01\x03\x6c\x6f\x67\x01\x0c\x00\x11\x02\x00\x04\x6c\x69\x62\x63\x01\x01\x6d\x01\x0c\x00\x12\x02\x00\x04\x6c\x69\x62\x63\x02\x01\x69\x01\x0c\x01\x02\x00\x03\x6c\x6f\x67\x01\x03\x72\x75\x6e\x01\x07\x03\x01\x01\x03\x72\x75\x6e\x01\x05\x05\x01\x00\x01\x68",
    (
      #|(component
      #|  (type (;0;)
      #|    (instance
      #|      (type (;0;) (func (param "msg" string)))
      #|      (export (;0;) "log" (func (type 0)))
      #|    )
      #|  )
      #|  (import "host" (instance $h (;0;) (type 0)))
      #|  (alias export $h "log" (func $log (;0;)))
      #|  (core module $libc (;0;)
      #|    (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
      #|    (memory (;0;) 1)
      #|    (export "mem" (memory 0))
      #|    (export "realloc" (func 0))
      #|    (func (;0;) (type 0) (param i32 i32 i32 i32) (result i32)
      #|      i32.const 0
      #|    )
      #|  )
      #|  (core instance $libc (;0;) (instantiate $libc))
      #|  (alias core export $libc "mem" (core memory (;0;)))
      #|  (alias core export $libc "realloc" (core func (;0;)))
      #|  (core func $log (;1;) (canon lower (func $log) (memory 0) (realloc 0) string-encoding=utf8))
      #|  (core module $m (;1;)
      #|    (type (;0;) (func (param i32 i32)))
      #|    (type (;1;) (func))
      #|    (import "host" "log" (func (;0;) (type 0) (param i32 i32)))
      #|    (export "run" (func 1))
      #|    (func (;1;) (type 1))
      #|  )
      #|  (core instance (;1;)
      #|    (export "log" (func $log))
      #|  )
      #|  (core instance $i (;2;) (instantiate $m
      #|      (with "host" (instance 1))
      #|    )
      #|  )
      #|  (type $run (;1;) (func))
      #|  (alias core export $i "run" (core func (;2;)))
      #|  (func $run (;1;) (type $run) (canon lift (core func 2)))
      #|  (export (;2;) "run" (func $run))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-start" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x2a\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x00\x09\x03\x00\x00\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    (
      #|(component
      #|  (core module $m (;0;)
      #|    (type (;0;) (func))
      #|    (export "f" (func 0))
      #|    (func (;0;) (type 0))
      #|  )
      #|  (core instance $i (;0;) (instantiate $m))
      #|  (alias core export $i "f" (core func $f (;0;)))
      #|  (type $t (;0;) (func))
      #|  (func $f (;0;) (type $t) (canon lift (core func $f)))
      #|  (start $f)
      #|  (export (;1;) "f" (func $f))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-table-init" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x13\x00\x61\x73\x6d\x01\x00\x00\x00\x04\x09\x01\x40\x00\x70\x00\x01\xd0\x70\x0b",
    (
      #|(component
      #|  (core module (;0;)
      #|    (table (;0;) 1 funcref ref.null func)
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-types" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x01\x41\x02\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x01\x69\x05\x00\x0b\x07\x01\x00\x01\x63\x03\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63",
    (
      #|(component
      #|  (type $c (;0;)
      #|    (component
      #|      (type (;0;)
      #|        (instance
      #|          (export (;0;) "r" (type (sub resource)))
      #|          (type (;1;) (own 0))
      #|          (type (;2;) (func (param "x" 1)))
      #|          (export (;0;) "f" (func (type 2)))
      #|        )
      #|      )
      #|      (export (;0;) "i" (instance (type 0)))
      #|    )
      #|  )
      #|  (export (;1;) "c" (type $c))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-value-types" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x70\x79\x0a\x06\x01\x00\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    (
      #|(component
      #|  (type (;0;) (list u32))
      #|  (import "v" (value (;0;) (type 0)))
      #|  (export (;1;) "v" (value 0))
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component-waitable-poll" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x26\x00\x61\x73\x6d\x01\x00\x00\x00\x05\x03\x01\x00\x01\x07\x0a\x01\x06\x6d\x65\x6d\x6f\x72\x79\x02\x00\x00\x0b\x04\x6e\x61\x6d\x65\x00\x04\x03\x6d\x65\x6d\x02\x04\x01\x00\x00\x00\x06\x0c\x01\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x08\x04\x01\x21\x00\x00\x02\x07\x01\x01\x01\x01\x66\x00\x00\x01\x27\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x07\x01\x60\x02\x7f\x7f\x01\x7f\x02\x09\x01\x03\x65\x6e\x76\x01\x66\x00\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x02\x0a\x01\x00\x01\x01\x03\x65\x6e\x76\x12\x01\x00\x40\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x0b\x00\x02\x01\x00\x06\x6d\x65\x6d\x6f\x72\x79\x01\x0b\x00\x11\x02\x00\x03\x6d\x65\x6d\x01\x01\x6d\x01\x0d\x00\x12\x02\x00\x03\x6d\x65\x6d\x01\x03\x65\x6e\x76",
    (
      #|(component
      #|  (core module $mem (;0;)
      #|    (memory (;0;) 1)
      #|    (export "memory" (memory 0))
      #|  )
      #|  (core instance $mem (;0;) (instantiate $mem))
      #|  (alias core export $mem "memory" (core memory $memory (;0;)))
      #|  (core func $f (;0;) (canon waitable-set.poll (memory $memory)))
      #|  (core instance $env (;1;)
      #|    (export "f" (func $f))
      #|  )
      #|  (core module $m (;1;)
      #|    (type (;0;) (func (param i32 i32) (result i32)))
      #|    (import "env" "f" (func (;0;) (type 0) (param i32 i32) (result i32)))
      #|  )
      #|  (core instance (;2;) (instantiate $m
      #|      (with "env" (instance $env))
      #|    )
      #|  )
      #|)
      #|
    ),
  )
}

///|
test "pinned wasm-tools: component" {
  component_compatibility_fixture(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x05\x01\x01\x66\x00\x00\x0a\x04\x01\x02\x00\x0b\x00\x0f\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x01\x04\x01\x00\x01\x66\x02\x04\x01\x00\x00\x00\x06\x07\x01\x00\x00\x01\x00\x01\x66\x07\x05\x01\x40\x00\x01\x00\x08\x06\x01\x00\x00\x00\x00\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x00\x01\x00\x01\x66\x01\x06\x00\x11\x01\x00\x01\x6d\x01\x06\x00\x12\x01\x00\x01\x69\x01\x05\x01\x01\x00\x01\x66\x01\x05\x03\x01\x00\x01\x74",
    (
      #|(component
      #|  (core module $m (;0;)
      #|    (type (;0;) (func))
      #|    (export "f" (func $f))
      #|    (func $f (;0;) (type 0))
      #|  )
      #|  (core instance $i (;0;) (instantiate $m))
      #|  (alias core export $i "f" (core func $f (;0;)))
      #|  (type $t (;0;) (func))
      #|  (func $f (;0;) (type $t) (canon lift (core func $f)))
      #|)
      #|
    ),
  )
}
