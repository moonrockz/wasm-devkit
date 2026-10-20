///|
fn wasm(source : String) -> Bytes raise {
  let encoded = @encoder.encode(@wat.parse(source))
  Bytes::makei(encoded.length(), i => encoded[i].to_byte())
}

///|
/// Compare instruction trees with explicit stacks. Derived equality recurses
/// through nested bodies.
fn assert_same_body(
  expected : Array[@types.Instruction],
  actual : Array[@types.Instruction],
) -> Unit raise {
  let pending = [(expected, actual)]
  while pending.pop() is Some((expected, actual)) {
    assert_eq(actual.length(), expected.length())
    for i, instruction in expected {
      match (instruction, actual[i]) {
        (Block(left, left_body), Block(right, right_body))
        | (Loop(left, left_body), Loop(right, right_body)) => {
          assert_eq(right, left)
          pending.push((left_body, right_body))
        }
        (If(left, left_then, left_else), If(right, right_then, right_else)) => {
          assert_eq(right, left)
          pending.push((left_then, right_then))
          pending.push((left_else, right_else))
        }
        (Block(_) | Loop(_) | If(_), _) => fail("control instruction differs")
        // NaN payloads compare by bits; derived float equality rejects NaN.
        (F32Const(left), F32Const(right)) =>
          assert_eq(right.reinterpret_as_uint(), left.reinterpret_as_uint())
        (F64Const(left), F64Const(right)) =>
          assert_eq(right.reinterpret_as_uint64(), left.reinterpret_as_uint64())
        (left, right) => assert_true(left == right)
      }
    }
  }
}

///|
fn assert_same_module(expected : Bytes, actual : Bytes) -> Unit raise {
  let expected = @core_parser.parse_module(expected)
  let actual = @core_parser.parse_module(actual)
  assert_eq(actual.types, expected.types)
  assert_eq(actual.type_rec_groups, expected.type_rec_groups)
  assert_eq(actual.imports, expected.imports)
  assert_eq(actual.funcs, expected.funcs)
  assert_eq(actual.tables, expected.tables)
  assert_eq(actual.memories, expected.memories)
  assert_eq(actual.globals.length(), expected.globals.length())
  for i, global in expected.globals {
    assert_eq(actual.globals[i].type_, global.type_)
    assert_same_body(global.init, actual.globals[i].init)
  }
  assert_eq(actual.exports, expected.exports)
  assert_eq(actual.start, expected.start)
  assert_eq(actual.elems, expected.elems)
  assert_eq(actual.codes.length(), expected.codes.length())
  for i, code in expected.codes {
    assert_eq(actual.codes[i].locals, code.locals)
    assert_same_body(code.body, actual.codes[i].body)
  }
  assert_eq(actual.datas, expected.datas)
  assert_eq(actual.tags, expected.tags)
}

///|
/// Print, parse the document with the pinned WAT parser, encode it again and
/// compare module structure. Printing the re-encoded module is idempotent.
fn round_trip(bytes : Bytes) -> String raise {
  guard @decompiler.print_core_module(bytes) is Ok(printed) else {
    fail("in-profile module rejected")
  }
  assert_eq(printed.documents.length(), 1)
  let text = printed.root().text
  let encoded = wasm(text)
  assert_same_module(bytes, encoded)
  guard @decompiler.print_core_module(encoded) is Ok(again) else {
    fail("re-encoded module rejected")
  }
  // Re-encoding drops custom sections, so their omission comments disappear.
  let module_text = text[text.find("(module").unwrap():].to_owned()
  assert_eq(again.root().text, module_text)
  text
}

///|
fn error_of(bytes : Bytes) -> @decompiler.Diagnostic raise {
  guard @decompiler.print_core_module(bytes, source_id="in.wasm") is Err(errors) else {
    fail("out-of-profile binary printed")
  }
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].source, "in.wasm")
  errors[0]
}

///|
let rich_module : String =
  #|(module
  #|  (type (func (param i32) (result i32)))
  #|  (import "env" "f" (func (type 0)))
  #|  (import "env" "mem" (memory 1 2))
  #|  (import "env" "g" (global (mut i64)))
  #|  (import "env" "t" (table 1 funcref))
  #|  (table 2 funcref)
  #|  (table 1 externref)
  #|  (global (mut f32) (f32.const 0.1))
  #|  (global f64 (f64.const -0x1p-1074))
  #|  (global f32 (f32.const nan:0x400001))
  #|  (func (param i32) (result i32) (local i64 f64)
  #|    local.get 0
  #|    block (result i32)
  #|      loop
  #|        local.get 0
  #|        local.get 0
  #|        br_if 1
  #|        drop
  #|      end
  #|      local.get 0
  #|      if (result i32)
  #|        i32.const 1
  #|      else
  #|        i32.const 2
  #|      end
  #|    end
  #|    i32.add
  #|    i32.load offset=4
  #|    local.get 0
  #|    call_indirect 1 (type 0)
  #|    local.get 0
  #|    br_table 0 0)
  #|  (func (result f32 f64 v128)
  #|    f32.const -0
  #|    f64.const inf
  #|    v128.const i32x4 1 2 3 4)
  #|  (func
  #|    i32.const 0
  #|    i32.const 0
  #|    i32.const 1
  #|    memory.init 0
  #|    data.drop 1
  #|    i32.const 0
  #|    ref.null extern
  #|    table.set 2)
  #|  (elem (i32.const 0) func 1)
  #|  (elem func 2)
  #|  (elem declare func 0)
  #|  (data (i32.const 8) "hi\00\ff\"\\")
  #|  (data "passive")
  #|  (export "id" (func 1))
  #|  (export "mem" (memory 0))
  #|  (export "table" (table 1))
  #|  (export "global" (global 1))
  #|  (start 3)
  #|)

///|
test "a core module prints as one deterministic WAT document" {
  let bytes = wasm(
    "(module (import \"env\" \"log\" (func (param i32))) (memory 1) (func (export \"run\") i32.const 7 call 0) (data (i32.const 0) \"ok\"))",
  )
  guard @decompiler.print_core_module(bytes) is Ok(printed) else {
    fail("module rejected")
  }
  assert_eq(printed.documents.length(), 1)
  assert_eq(printed.root().name, "root")
  inspect(
    printed.root().text,
    content=(
      #|(module
      #|  (type (;0;) (func (param i32)))
      #|  (type (;1;) (func))
      #|  (import "env" "log" (func (type 0)))
      #|  (memory (;0;) 1)
      #|  (export "run" (func 1))
      #|  (func (;1;) (type 1)
      #|    i32.const 7
      #|    call 0
      #|  )
      #|  (data (;0;) (i32.const 0) "ok")
      #|)
      #|
    ),
  )
  assert_eq(@decompiler.print_core_module(bytes), Ok(printed))
}

///|
test "law: printed documents re-encode to the same module structure" {
  for
    source in [
      "(module)", rich_module, "(module (memory i64 1) (func (result i64) memory.size))",
      "(module (memory 1) (memory 2 3) (func i32.const 0 i32.const 0 i32.const 1 memory.copy 1 0))",
      "(module (func (param i32) (result i32 i64) local.get 0 i64.const -9223372036854775808 block (param i32 i64) (result i32 i64) end))",
      "(module (func (param f32 f64) (result i32) local.get 0 i32.trunc_sat_f32_s local.get 1 i64.trunc_sat_f64_u i32.wrap_i64 i32.add i32.extend8_s))",
      "(module (type (func)) (table 1 funcref) (func i32.const 0 return_call_indirect (type 0)))",
      "(module (func (result f32 f32 f32 f64 f64) f32.const 0x1p-149 f32.const 3.4028235e38 f32.const -nan:0x7fffff f64.const nan:0x1 f64.const -0x1.fffffffffffffp+1023))",
    ] {
    ignore(round_trip(wasm(source)))
  }
}

///|
test "absolute index comments follow imported items" {
  let text = round_trip(wasm(rich_module))
  assert_true(text.contains("  (table (;1;) 2 funcref)\n"))
  assert_true(text.contains("  (table (;2;) 1 externref)\n"))
  assert_true(text.contains("  (global (;1;) (mut f32) "))
  assert_true(
    text.contains("  (func (;1;) (type 0) (param i32) (result i32)\n"),
  )
}

///|
fn custom_section(name : String, payload : Bytes) -> Array[Byte] {
  let encoded = @utf8.encode(name)
  let body : Array[Byte] = [encoded.length().to_byte()]
  body.append(encoded.to_array())
  body.append(payload.to_array())
  let section : Array[Byte] = [0, body.length().to_byte()]
  section.append(body)
  section
}

///|
test "custom sections are named in leading comments and omitted" {
  let base = wasm("(module (func (export \"f\")))")
  let bytes = base.to_array()
  bytes.append(custom_section("name", b"\x00"))
  bytes.append(custom_section("a\nb\"\\ü", b"payload"))
  let bytes = Bytes::from_array(bytes)
  let text = round_trip(bytes)
  assert_true(
    text.has_prefix(
      ";; custom section omitted: \"name\"\n;; custom section omitted: \"a\\0ab\\22\\5cü\"\n(module\n",
    ),
  )
  assert_eq(text[text.find("(module").unwrap():].to_owned(), round_trip(base))
}

///|
fn leb(out : Array[Byte], value : Int32) -> Unit {
  let mut value = value
  while value >= 0x80 {
    out.push(((value & 0x7f) | 0x80).to_byte())
    value = value >> 7
  }
  out.push(value.to_byte())
}

///|
/// One function whose body nests `depth` empty blocks, encoded directly so the
/// fixture does not depend on the recursive pinned WAT parser.
fn nested_blocks(depth : Int32) -> Bytes {
  let body : Array[Byte] = [0x00]
  for _ in 0..<depth {
    body.append([0x02, 0x40])
  }
  for _ in 0..<=depth {
    body.push(0x0b)
  }
  let code : Array[Byte] = [0x01]
  leb(code, body.length())
  code.append(body)
  let bytes : Array[Byte] = [
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x04, 0x01, 0x60, 0x00,
    0x00, 0x03, 0x02, 0x01, 0x00, 0x0a,
  ]
  leb(bytes, code.length())
  bytes.append(code)
  Bytes::from_array(bytes)
}

///|
test "deep control nesting prints with explicit stacks up to the profile limit" {
  // The pinned WAT parser recurses, so the oracle round trip uses depth 64.
  let text = round_trip(nested_blocks(64))
  assert_true(text.contains("  ".repeat(65) + "block\n"))
  guard @decompiler.print_core_module(nested_blocks(256)) is Ok(printed) else {
    fail("profile-limit nesting rejected")
  }
  let lines = printed.root().text.split("\n").to_array()
  let blocks = lines.filter(line => line.trim_start(chars=" ") == "block")
  let ends = lines.filter(line => line.trim_start(chars=" ") == "end")
  assert_eq(blocks.length(), 256)
  assert_eq(ends.length(), 256)
  assert_true(printed.root().text.contains("  ".repeat(257) + "end\n"))
  assert_eq(error_of(nested_blocks(257)).code, "WIT-D003")
}

///|
test "binaries outside the core-module profile fail explicitly" {
  let component = error_of(b"\x00asm\x0d\x00\x01\x00")
  assert_eq(component.code, "WIT-D003")
  assert_eq(component.offset, Some(4))
  assert_true(component.message.contains("component"))
  for
    bytes in [
      b"", b"\x00asm", b"\x00asm\x02\x00\x00\x00", b"\x7fELF\x01\x00\x00\x00",
    ] {
    let error = error_of(bytes)
    assert_eq(error.code, "WIT-D001")
    assert_eq(error.offset, Some(0))
  }
  let truncated = wasm("(module (func (export \"f\")))")
  let truncated = truncated[:truncated.length() - 1].to_owned()
  assert_eq(error_of(truncated).code, "WIT-D001")
  let invalid = error_of(wasm("(module (func (result i32) i64.const 1))"))
  assert_eq(invalid.code, "WIT-D002")
  assert_eq(invalid.offset, None)
  assert_false(invalid.message.has_suffix("\n"))
  // `(func (result f32) f32.const nan:0x200000)`, encoded directly because the
  // JavaScript target quiets the payload while parsing WAT.
  let signaling = error_of(
    b"\x00asm\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7d\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x43\x00\x00\xa0\x7f\x0b",
  )
  assert_eq(signaling.code, "WIT-D003")
  assert_true(signaling.message.contains("signaling NaN"))
  assert_eq(signaling.offset, Some(24))
  for
    source in [
      "(module (type (struct)))", "(module (memory 1 1 shared) (func (result i32) i32.const 0 i32.atomic.load))",
      "(module (tag (param i32)) (func i32.const 1 throw 0))",
    ] {
    assert_eq(error_of(wasm(source)).code, "WIT-D003")
  }
}

///|
test "law: every prefix either fails or prints a module that round-trips" {
  let bytes = wasm(rich_module)
  let mut printed = 0
  for length in 0..<=bytes.length() {
    let prefix = bytes[:length].to_owned()
    match @decompiler.print_core_module(prefix) {
      Ok(_) => {
        ignore(round_trip(prefix))
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
test "law: printing arbitrary bytes is total and deterministic" {
  @quickcheck.check(
    (input : Array[Byte]) => {
      let bytes = Bytes::from_array(input)
      let header : Array[Byte] = [0x00, 0x61, 0x73, 0x6d, 0x01, 0, 0, 0]
      header.append(input)
      let headed = Bytes::from_array(header)
      [bytes, headed].all(bytes => {
        let first = @decompiler.print_core_module(bytes)
        first == @decompiler.print_core_module(bytes) &&
        (match first {
          Ok(printed) => printed.documents.length() == 1
          Err(errors) =>
            errors.length() == 1 &&
            errors[0].offset
            .map(offset => offset >= 0 && offset <= bytes.length())
            .unwrap_or(true)
        })
      })
    },
    count=500,
    max_size=128,
    seed=1301,
  )
}
