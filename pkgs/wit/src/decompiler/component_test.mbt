///|
fn component(source : String) -> Bytes raise {
  @component_text.parse_normalized_component_wat(source)
}

///|
/// Remove the comments that name omitted core-module custom sections. The text
/// compiler drops those sections, so a second print cannot name them.
fn without_omissions(text : String) -> String {
  text
  .split("\n")
  .filter(line => !line.contains(";; custom section omitted: "))
  .map(line => line.to_owned())
  .to_array()
  .join("\n")
}

///|
/// Print, compile the document through the component WAT path, validate it
/// under the same profile and print it again. The second print is identical.
fn round_trip_component(bytes : Bytes) -> String raise {
  let printed = match @decompiler.print_component(bytes) {
    Ok(printed) => printed
    Err(errors) => fail("in-profile component rejected: \{errors[0].message}")
  }
  assert_eq(printed.documents.length(), 1)
  assert_eq(printed.root().name, "root")
  let text = printed.root().text
  assert_true(text.has_suffix(")\n"))
  let compiled = @component_text.parse_normalized_component_wat(text)
  assert_true(@binary.validate_declarative_component(compiled) is Ok(_))
  guard @decompiler.print_component(compiled) is Ok(again) else {
    fail("compiled component rejected")
  }
  assert_eq(again.root().text, without_omissions(text))
  text
}

///|
fn component_error(bytes : Bytes) -> @decompiler.Diagnostic raise {
  guard @decompiler.print_component(bytes, source_id="in.wasm") is Err(errors) else {
    fail("out-of-profile component printed")
  }
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].source, "in.wasm")
  errors[0]
}

///|
let package_component : String =
  #|(component
  #|  (type (component
  #|    (type (instance
  #|      (export "r" (type (sub resource)))
  #|      (type (own 0))
  #|      (type (list string))
  #|      (type (record (field "id" u32) (field "tags" 2)))
  #|      (export "item" (type (eq 3)))
  #|      (type (func (param "x" string) (param "i" 4) (result 1)))
  #|      (export "make" (func (type 5)))))
  #|    (export "example:pkg/api@1.0.0" (instance (type 0)))))
  #|  (export "api" (type 0))
  #|  (@custom "package-docs" "\00{}"))

///|
test "a type-only package prints as one component document" {
  inspect(
    round_trip_component(component(package_component)),
    content=(
      #|(component
      #|  (type (;0;)
      #|    (component
      #|      (type (;0;)
      #|        (instance
      #|          (export "r" (type (;0;) (sub resource)))
      #|          (type (;1;) (own 0))
      #|          (type (;2;) (list string))
      #|          (type (;3;) (record (field "id" u32) (field "tags" 2)))
      #|          (export "item" (type (;4;) (eq 3)))
      #|          (type (;5;) (func (param "x" string) (param "i" 4) (result 1)))
      #|          (export "make" (func (;0;) (type 5)))
      #|        )
      #|      )
      #|      (export "example:pkg/api@1.0.0" (instance (;0;) (type 0)))
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
let runtime_component : String =
  #|(component
  #|  (import "host" (instance $h (export "log" (func (param "msg" string)))))
  #|  (alias export $h "log" (func $log))
  #|  (core module $libc
  #|    (memory (export "mem") 1)
  #|    (func (export "realloc") (param i32 i32 i32 i32) (result i32) i32.const 0))
  #|  (core instance $libc (instantiate $libc))
  #|  (core func $log (canon lower (func $log) (memory $libc "mem")
  #|    (realloc $libc "realloc") string-encoding=utf8))
  #|  (core module $m
  #|    (import "host" "log" (func (param i32 i32)))
  #|    (func (export "run")))
  #|  (core instance $i (instantiate $m
  #|    (with "host" (instance (export "log" (func $log))))))
  #|  (type $run (func))
  #|  (func $run (type $run) (canon lift (core func $i "run")))
  #|  (export "run" (func $run)))

///|
test "a flat runtime component prints each core module inline" {
  inspect(
    round_trip_component(component(runtime_component)),
    content=(
      #|(component
      #|  (type (;0;)
      #|    (instance
      #|      (type (;0;) (func (param "msg" string)))
      #|      (export "log" (func (;0;) (type 0)))
      #|    )
      #|  )
      #|  (import "host" (instance (;0;) (type 0)))
      #|  (alias export 0 "log" (func (;0;)))
      #|  (core module (;0;)
      #|    (type (;0;) (func (param i32) (param i32) (param i32) (param i32) (result i32)))
      #|    (memory (;0;) 1)
      #|    (export "mem" (memory 0))
      #|    (export "realloc" (func 0))
      #|    (func (;0;) (type 0) (param i32) (param i32) (param i32) (param i32) (result i32)
      #|      i32.const 0
      #|    )
      #|  )
      #|  (core instance (;0;) (instantiate 0))
      #|  (alias core export 0 "mem" (core memory (;0;)))
      #|  (alias core export 0 "realloc" (core func (;0;)))
      #|  (core func (;1;) (canon lower (func 0) (memory 0) (realloc 0) string-encoding=utf8))
      #|  (core module (;1;)
      #|    (type (;0;) (func (param i32) (param i32)))
      #|    (type (;1;) (func))
      #|    (import "host" "log" (func (type 0)))
      #|    (export "run" (func 1))
      #|    (func (;1;) (type 1)
      #|    )
      #|  )
      #|  (core instance (;1;)
      #|    (export "log" (func 1))
      #|  )
      #|  (core instance (;2;)
      #|    (instantiate 1
      #|      (with "host" (instance 1))
      #|    )
      #|  )
      #|  (type (;1;) (func))
      #|  (alias core export 2 "run" (core func (;2;)))
      #|  (func (;1;) (type 1) (canon lift (core func 2)))
      #|  (export (;2;) "run" (func 1))
      #|)
      #|
    ),
  )
}

///|
test "nested components and component instances print inline in binary order" {
  inspect(
    round_trip_component(
      component(
        (
          #|(component
          #|  (component $inner
          #|    (import "f" (func $f))
          #|    (component $leaf)
          #|    (export "g" (func $f)))
          #|  (import "f" (func $f))
          #|  (instance $a (instantiate $inner (with "f" (func $f))))
          #|  (instance $b (export "g" (func $a "g")))
          #|  (export "b" (instance $b)))
        ),
      ),
    ),
    content=(
      #|(component
      #|  (component (;0;)
      #|    (type (;0;) (func))
      #|    (import "f" (func (;0;) (type 0)))
      #|    (component (;0;)
      #|    )
      #|    (export (;1;) "g" (func 0))
      #|  )
      #|  (type (;0;) (func))
      #|  (import "f" (func (;0;) (type 0)))
      #|  (instance (;0;)
      #|    (instantiate 0
      #|      (with "f" (func 0))
      #|    )
      #|  )
      #|  (alias export 0 "g" (func (;1;)))
      #|  (instance (;1;)
      #|    (export "g" (func 1))
      #|  )
      #|  (export (;2;) "b" (instance 1))
      #|)
      #|
    ),
  )
}

///|
test "resources and resource intrinsics print" {
  inspect(
    round_trip_component(
      component(
        (
          #|(component
          #|  (core module $m (func (export "dtor") (param i32)))
          #|  (core instance $i (instantiate $m))
          #|  (alias core export $i "dtor" (core func $d))
          #|  (type $r (resource (rep i32) (dtor (func $d))))
          #|  (core func (canon resource.new $r))
          #|  (core func (canon resource.rep $r))
          #|  (core func (canon resource.drop $r)))
        ),
      ),
    ),
    content=(
      #|(component
      #|  (core module (;0;)
      #|    (type (;0;) (func (param i32)))
      #|    (export "dtor" (func 0))
      #|    (func (;0;) (type 0) (param i32)
      #|    )
      #|  )
      #|  (core instance (;0;) (instantiate 0))
      #|  (alias core export 0 "dtor" (core func (;0;)))
      #|  (type (;0;) (resource (rep i32) (dtor (func 0))))
      #|  (core func (;1;) (canon resource.new 0))
      #|  (core func (;2;) (canon resource.rep 0))
      #|  (core func (;3;) (canon resource.drop 0))
      #|)
      #|
    ),
  )
}

///|
test "core types and custom sections print" {
  inspect(
    round_trip_component(
      component(
        (
          #|(component
          #|  (core type (func (param i32) (result i64)))
          #|  (core type (module
          #|    (type (func))
          #|    (import "a" "b" (func (type 0)))
          #|    (export "m" (memory i64 1 2))
          #|    (export "g" (global (mut f32)))
          #|    (export "t" (table 1 externref))))
          #|  (@custom "note" "\00\ff\"\\"))
        ),
      ),
    ),
    content=(
      #|(component
      #|  (core type (;0;) (func (param i32) (result i64)))
      #|  (core type (;1;)
      #|    (module
      #|      (type (;0;) (func))
      #|      (import "a" "b" (func (type 0)))
      #|      (export "m" (memory i64 1 2))
      #|      (export "g" (global (mut f32)))
      #|      (export "t" (table 1 externref))
      #|    )
      #|  )
      #|  (@custom "note" "\00\ff\22\5c")
      #|)
      #|
    ),
  )
}

///|
test "print_binary dispatches on the preamble" {
  let core = b"\x00asm\x01\x00\x00\x00"
  assert_eq(@decompiler.print_binary(core), @decompiler.print_core_module(core))
  let empty = b"\x00asm\x0d\x00\x01\x00"
  assert_eq(@decompiler.print_binary(empty), @decompiler.print_component(empty))
  assert_eq(
    @decompiler.print_binary(empty).map(printed => printed.root().text),
    Ok("(component\n)\n"),
  )
}

///|
test "binaries outside the component profile fail without a partial document" {
  let core = component_error(b"\x00asm\x01\x00\x00\x00")
  assert_eq(core.code, "WIT-D003")
  assert_eq(core.offset, Some(4))
  assert_true(core.message.contains("core-module"))
  for bytes in [b"", b"\x00asm", b"\x7fELF\x01\x00\x00\x00"] {
    let error = component_error(bytes)
    assert_eq(error.code, "WIT-D001")
    assert_eq(error.offset, Some(0))
  }
  // A type section that declares one entry but holds none.
  let truncated = component_error(b"\x00asm\x0d\x00\x01\x00\x07\x01\x01")
  assert_eq(truncated.code, "WIT-D001")
  assert_eq(truncated.offset, Some(11))
  let invalid = component_error(component("(component (type (own 0)))"))
  assert_eq(invalid.code, "WIT-D002")
  // The retained text compiler has no `error-context` value type.
  let error_context = component_error(
    b"\x00asm\x0d\x00\x01\x00\x07\x02\x01\x64",
  )
  assert_eq(error_context.code, "WIT-D003")
  assert_true(error_context.message.contains("error-context"))
  // Prefixed core subtypes (`0x00 0x50 ... 0x60`) fail component validation
  // as GC types, in a core type section and in a component type declaration.
  for
    bytes in [
      b"\x00asm\x0d\x00\x01\x00\x03\x06\x01\x00\x50\x00\x60\x00\x00", b"\x00asm\x0d\x00\x01\x00\x07\x0a\x01\x41\x01\x00\x00\x50\x00\x60\x00\x00",
    ] {
    assert_eq(component_error(bytes).code, "WIT-D003")
  }
  // `(func (result f32) f32.const nan:0x200000)` nested in a component reports
  // the absolute offset of the constant.
  let module_ = b"\x00asm\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7d\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x43\x00\x00\xa0\x7f\x0b"
  let nested : Array[Byte] = [
    0x00,
    0x61,
    0x73,
    0x6d,
    0x0d,
    0x00,
    0x01,
    0x00,
    0x01,
    module_.length().to_byte(),
  ]
  nested.append(module_.to_array())
  let signaling = component_error(Bytes::from_array(nested))
  assert_eq(signaling.code, "WIT-D003")
  assert_eq(signaling.offset, Some(10 + 24))
}

///|
/// `depth` components nested inside each other, encoded directly so the
/// fixture does not depend on the text compiler's nesting bound.
fn nested_components(depth : Int32) -> Bytes {
  let mut bytes : Array[Byte] = [0x00, 0x61, 0x73, 0x6d, 0x0d, 0x00, 0x01, 0x00]
  for _ in 0..<depth {
    let outer : Array[Byte] = [
      0x00, 0x61, 0x73, 0x6d, 0x0d, 0x00, 0x01, 0x00, 0x04,
    ]
    leb(outer, bytes.length())
    outer.append(bytes)
    bytes = outer
  }
  Bytes::from_array(bytes)
}

///|
/// One type section whose type nests `depth` component types.
fn nested_component_types(depth : Int32) -> Bytes {
  let mut definition : Array[Byte] = [0x41, 0x00]
  for _ in 1..<depth {
    let outer : Array[Byte] = [0x41, 0x01, 0x01]
    outer.append(definition)
    definition = outer
  }
  let section : Array[Byte] = [0x01]
  section.append(definition)
  let bytes : Array[Byte] = [
    0x00, 0x61, 0x73, 0x6d, 0x0d, 0x00, 0x01, 0x00, 0x07,
  ]
  leb(bytes, section.length())
  bytes.append(section)
  Bytes::from_array(bytes)
}

///|
test "nested components and types print with explicit stacks up to the profile limit" {
  guard @decompiler.print_component(nested_components(256)) is Ok(printed) else {
    fail("profile-limit component nesting rejected")
  }
  let text = printed.root().text
  assert_true(text.contains("  ".repeat(256) + "(component (;0;)\n"))
  assert_eq(text.split("(component").count(), 258)
  assert_eq(component_error(nested_components(257)).code, "WIT-D003")
  // The retained component validator recurses through type declarations and
  // exhausts the wasm stack before 128 levels (wasm-devkit-p5m.14). The
  // printer's own type traversal uses explicit stacks.
  guard @decompiler.print_component(nested_component_types(64)) is Ok(types) else {
    fail("nested component types rejected")
  }
  // Each type level indents its `(component` body by four spaces.
  let depths = types.root().text
    .split("\n")
    .filter(line => line.trim_start(chars=" ") == "(component")
    .map(line => line.length())
    .to_array()
  // The root component is the first entry.
  assert_eq(depths.length(), 65)
  assert_eq(depths[64], 4 * 64 + "(component".length())
  assert_eq(component_error(nested_component_types(257)).code, "WIT-D003")
  // The text compiler bounds parentheses at 256, so its oracle uses 64.
  ignore(round_trip_component(nested_components(64)))
  ignore(round_trip_component(nested_component_types(32)))
}

///|
test "law: every component prefix either fails or prints a document that round-trips" {
  let bytes = component(runtime_component)
  let mut printed = 0
  for length in 0..<=bytes.length() {
    let prefix = bytes[:length].to_owned()
    match @decompiler.print_component(prefix) {
      Ok(_) => {
        ignore(round_trip_component(prefix))
        printed += 1
      }
      Err(errors) => {
        assert_eq(errors.length(), 1)
        assert_true(
          errors[0].offset
          .map(offset => offset >= 0 && offset <= length)
          .unwrap_or(true),
        )
      }
    }
  }
  assert_true(printed >= 2)
}

///|
test "law: printing arbitrary component bytes is total and deterministic" {
  @quickcheck.check(
    (input : Array[Byte]) => {
      let header : Array[Byte] = [
        0x00, 0x61, 0x73, 0x6d, 0x0d, 0x00, 0x01, 0x00,
      ]
      header.append(input)
      let bytes = Bytes::from_array(header)
      let first = @decompiler.print_component(bytes)
      first == @decompiler.print_component(bytes) &&
      first == @decompiler.print_binary(bytes) &&
      (match first {
        Ok(printed) => printed.documents.length() == 1
        Err(errors) =>
          errors.length() == 1 &&
          errors[0].offset
          .map(offset => offset >= 0 && offset <= bytes.length())
          .unwrap_or(true)
      })
    },
    count=500,
    max_size=128,
    seed=1302,
  )
}

///|
test "extended constant global initializers round trip inside components" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x25\x00\x61\x73\x6d\x01\x00\x00\x00\x06\x09\x01\x7f\x00\x41\x01\x41\x02\x6a\x0b\x07\x05\x01\x01\x67\x03\x00\x00\x09\x04\x6e\x61\x6d\x65\x00\x02\x01\x6d\x0b\x0d\x01\x00\x06\x6d\x6f\x64\x75\x6c\x65\x00\x11\x00\x00\x00\x17\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x11\x01\x00\x01\x6d"
  let text = round_trip_component(bytes)
  assert_true(text.contains("i32.const 1 i32.const 2 i32.add"))
}

///|
test "contextual fragments validate input and select physical component indices" {
  let bytes = b"\x00asm\x0d\x00\x01\x00\x04\x08\x00asm\x0d\x00\x01\x00"
  let fragment = @decompiler.component_fragment(bytes, [0]).unwrap()
  assert_eq(fragment.text, "(component\n)\n")
  assert_eq(
    @decompiler.component_fragment(bytes, [1]).unwrap_err()[0].code,
    "WIT-D003",
  )
  assert_eq(
    @decompiler.component_fragment(b"bad", []).unwrap_err()[0].code,
    "WIT-D001",
  )
}
