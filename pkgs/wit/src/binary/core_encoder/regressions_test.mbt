// Original probes checked independently with wasm-tools 1.262.0.

///|
test "retained encoder preserves load32" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x05\x05\x02\x00\x01\x00\x02\x07\x05\x01\x01\x66\x00\x00\x0a\x0a\x01\x08\x00\x41\x00\x28\x42\x01\x00\x0b",
  )
  let source = @wat.parse(
    "(module (memory 1) (memory 2) (func (export \"f\") (result i32) i32.const 0 i32.load 1))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves store32" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x05\x05\x02\x00\x01\x00\x02\x0a\x0c\x01\x0a\x00\x41\x00\x41\x02\x36\x41\x01\x09\x0b",
  )
  let source = @wat.parse(
    "(module (memory 1) (memory 2) (func i32.const 0 i32.const 2 i32.store 1 offset=9 align=2))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves load64" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7e\x03\x02\x01\x00\x05\x05\x02\x00\x01\x04\x02\x0a\x0e\x01\x0c\x00\x20\x00\x29\x42\x01\x80\x80\x80\x80\x20\x0b",
  )
  let source = @wat.parse(
    "(module (memory 1) (memory i64 2) (func (param i64) (result i64) local.get 0 i64.load 1 offset=8589934592 align=4))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves simd" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7b\x03\x02\x01\x00\x05\x05\x02\x00\x01\x00\x02\x0a\x0b\x01\x09\x00\x41\x00\xfd\x00\x43\x01\x09\x0b",
  )
  let source = @wat.parse(
    "(module (memory 1) (memory 2) (func (result v128) i32.const 0 v128.load 1 offset=9 align=8))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves atomic" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x05\x06\x02\x00\x01\x03\x02\x02\x0a\x0b\x01\x09\x00\x41\x00\xfe\x10\x42\x01\x04\x0b",
  )
  let source = @wat.parse(
    "(module (memory 1) (memory 2 2 shared) (func (result i32) i32.const 0 i32.atomic.load 1 offset=4))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves load64-max" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x7e\x01\x7e\x03\x02\x01\x00\x05\x05\x02\x00\x01\x04\x02\x0a\x13\x01\x11\x00\x20\x00\x29\x43\x01\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01\x0b",
  )
  let source = @wat.parse(
    "(module (memory 1) (memory i64 2) (func (param i64) (result i64) local.get 0 i64.load 1 offset=18446744073709551615 align=8))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves abstract-params" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x01\x60\x04\x64\x6b\x6b\x64\x6a\x6a\x00\x03\x02\x01\x00\x0a\x04\x01\x02\x00\x0b",
  )
  let source = @wat.parse(
    "(module (func (param (ref struct) structref (ref array) arrayref)))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "retained encoder preserves abstract-select" {
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x11\x03\x5f\x02\x6b\x00\x6a\x00\x5e\x6a\x00\x60\x03\x6b\x6b\x7f\x01\x6b\x03\x02\x01\x02\x0a\x0d\x01\x0b\x00\x20\x00\x20\x01\x20\x02\x1c\x01\x6b\x0b",
  )
  let source = @wat.parse(
    "(module (type (struct (field structref) (field arrayref))) (type (array arrayref)) (func (param structref structref i32) (result structref) local.get 0 local.get 1 local.get 2 select (result structref)))",
  )
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  assert_eq(actual.types, reference.types)
  assert_eq(actual.memories, reference.memories)
  assert_eq(actual.codes, reference.codes)
}

///|
test "legacy abstract struct and array sentinels keep heap meanings" {
  let source = @types.Module::empty()
  source.types.push(
    @types.SubType::from_func({
      params: [RefStruct(-1), RefNullStruct(-1), RefArray(-1), RefNullArray(-1)],
      results: [],
    }),
  )
  source.funcs.push(0)
  source.codes.push({ locals: [], body: [], })
  let encoded = @core_encoder.encode(source)
  let actual = @core_parser.parse_module(
    Bytes::makei(encoded.length(), i => encoded[i].to_byte()),
  )
  let reference = @core_parser.parse_module(
    b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x0a\x01\x60\x04\x64\x6b\x6b\x64\x6a\x6a\x00\x03\x02\x01\x00\x0a\x04\x01\x02\x00\x0b",
  )
  assert_eq(actual.types, reference.types)
}
