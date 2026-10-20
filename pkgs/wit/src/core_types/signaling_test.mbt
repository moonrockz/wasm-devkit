///|
test "signaling f32 constants report opcode offsets in input order" {
  // (global f32 (f32.const nan:0x1)) and
  // (func (result f32 f32) f32.const nan:0x400000 f32.const nan:0x200000)
  let bytes = b"\x00asm\x01\x00\x00\x00\x01\x06\x01\x60\x00\x02\x7d\x7d\x03\x02\x01\x00\x06\x09\x01\x7d\x00\x43\x01\x00\x80\x7f\x0b\x0a\x0e\x01\x0c\x00\x43\x00\x00\xc0\x7f\x43\x00\x00\xa0\x7f\x0b"
  assert_eq(@core_types.signaling_f32_constants(bytes), Ok([25, 41]))
  assert_true(@core_types.inspect_module(bytes) is Ok(_))
  let quiet = b"\x00asm\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7d\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x43\x00\x00\xc0\xff\x0b"
  assert_eq(@core_types.signaling_f32_constants(quiet), Ok([]))
  let truncated = bytes[:bytes.length() - 1].to_owned()
  guard @core_types.inspect_module(truncated) is Err(expected) else {
    fail("truncated module accepted")
  }
  assert_eq(@core_types.signaling_f32_constants(truncated), Err(expected))
}
