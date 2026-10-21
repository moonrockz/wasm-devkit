///|
test "shared instruction context global-get-shared" {
  let source = "(module (type $f (shared (func (result i32)))) (global $g (shared i32) (i32.const 1)) (func (type $f) global.get $g))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context global-set-shared" {
  let source = "(module (type $f (shared (func))) (global $g (shared mut i32) (i32.const 1)) (func (type $f) i32.const 2 global.set $g))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context table-size-shared" {
  let source = "(module (type $f (shared (func (result i32)))) (table shared 1 (ref null (shared func))) (func (type $f) table.size 0))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context call-shared" {
  let source = "(module (type $caller (shared (func (result i32)))) (type $callee (shared (func (result i32)))) (func $callee (type $callee) i32.const 1) (func (type $caller) call $callee))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context ref-func-shared" {
  let source = "(module (type $caller (shared (func))) (type $callee (shared (func))) (func $callee (export \"callee\") (type $callee)) (func (type $caller) ref.func $callee drop))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context global-get-unshared" {
  let source = "(module (type $f (shared (func (result i32)))) (global $g i32 (i32.const 1)) (func (type $f) global.get $g))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context global-set-unshared" {
  let source = "(module (type $f (shared (func))) (global $g (mut i32) (i32.const 1)) (func (type $f) i32.const 2 global.set $g))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context table-size-unshared" {
  let source = "(module (type $f (shared (func (result i32)))) (table 1 (ref null (shared func))) (func (type $f) table.size 0))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context call-unshared" {
  let source = "(module (type $caller (shared (func (result i32)))) (type $callee (func (result i32))) (func $callee (type $callee) i32.const 1) (func (type $caller) call $callee))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context ref-func-unshared" {
  let source = "(module (type $caller (shared (func))) (type $callee (func)) (func $callee (export \"callee\") (type $callee)) (func (type $caller) ref.func $callee drop))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context local-unshared" {
  let source = "(module (type $f (shared (func))) (func (type $f) (local funcref) local.get 0 drop))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context memory-unshared" {
  let source = "(module (type $f (shared (func (result i32)))) (memory 1) (func (type $f) i32.const 0 i32.load))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context call-ref-shared" {
  let source = "(module (type $f (shared (func (result i32)))) (func (type $f) ref.null $f call_ref $f))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context call-ref-unshared" {
  let source = "(module (type $f (shared (func (result i32)))) (type $u (func (result i32))) (func (type $f) ref.null $u call_ref $u))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context block-type-shared" {
  let source = "(module (type $f (shared (func (result i32)))) (func (type $f) block (type $f) i32.const 1 end))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(true, msg=e.to_string())
  } noraise {
    _ => assert_true(true, msg="invalid shared access accepted")
  }
}

///|
test "shared instruction context block-type-unshared" {
  let source = "(module (type $f (shared (func (result i32)))) (type $u (func (result i32))) (func (type $f) block (type $u) i32.const 1 end))"
  let mod_ = @wat.parse(source)
  let encoded = @encoder.encode(mod_)
  let bytes = Bytes::makei(encoded.length(), i => encoded[i].to_byte())
  let parsed = @parser.parse_module(bytes)
  try @core_validation.validate_module(parsed) catch {
    e => assert_false(false, msg=e.to_string())
  } noraise {
    _ => assert_true(false, msg="invalid shared access accepted")
  }
}
