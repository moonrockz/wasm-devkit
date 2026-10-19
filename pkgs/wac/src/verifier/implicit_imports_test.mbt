// Original cases compare pinned WAC resolve, import aggregation and validating compose.

///|
test "implicit imports single" {
  let source = "package test:app; let i=new test:first {...}; export i.out;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports repeat" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:first {...}; export i.out as first; export j.out as second;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports explicit-before" {
  let source = "package test:app; import f: func(); let i=new test:first {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports explicit-after" {
  let source = "package test:app; let i=new test:first {...}; import f: func();"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports satisfied" {
  let source = "package test:app; import f: func(); let i=new test:first {f,...}; export i.out;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports not-last" {
  let source = "package test:app; import f: func(); let i=new test:first {..., f};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports duplicate" {
  let source = "package test:app; let i=new test:first {...,...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports function-mismatch" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "f-u32.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x08\x01\x40\x01\x01\x78\x79\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "f-u32.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func (param \"x\" u32))) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports interface-union" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "api-f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "api-g.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x67\x01\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "api-f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"api\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "api-g.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"g\" (func (type 0))))) (import \"api\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "api", "instance", "interface", "", "0", "2", "f", "func", "function",
      "false", "0", "none", "g", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports interface-mismatch" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "api-f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "api-f-u32.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "api-f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"api\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "api-f-u32.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func (param \"x\" u32)))(export \"f\" (func (type 0))))) (import \"api\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports version-up" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "v2.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x67\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "v2.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"g\" (func (type 0))))) (import \"test:api/run@1.2.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.2.0", "instance", "interface", "test:api/run@1.0.0", "0",
      "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
      "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports version-down" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v2.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x67\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "v1.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v2.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"g\" (func (type 0))))) (import \"test:api/run@1.2.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "v1.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.2.0", "instance", "interface", "test:api/run@1.2.0", "0",
      "2", "g", "func", "function", "false", "0", "none", "f", "func", "function",
      "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports version-major" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "v3.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x32\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "v3.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@2.0.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0", "0",
      "1", "f", "func", "function", "false", "0", "none", "test:api/run@2.0.0", "instance",
      "interface", "test:api/run@2.0.0", "0", "1", "f", "func", "function", "false",
      "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports resources" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:first {...}; export j.take;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x02\x0b\x0a\x01\x00\x04\x74\x61\x6b\x65\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource.wat",
      bytes: implicit_wat_bytes(
        "(component (import \"handle\" (type (sub resource))) (type (func (param \"h\" (own 0)))) (import \"take\" (func (type 2))) (export \"take\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
      "1", "h", "own", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports resource-capture" {
  let source = "package test:app; interface api {resource handle;} import a: api; let i=new test:first {handle: a.handle,...}; export i.take;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x02\x0b\x0a\x01\x00\x04\x74\x61\x6b\x65\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource.wat",
      bytes: implicit_wat_bytes(
        "(component (import \"handle\" (type (sub resource))) (type (func (param \"h\" (own 0)))) (import \"take\" (func (type 2))) (export \"take\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports resource-crossed" {
  let source = "package test:app; interface api {resource handle;} import a: api; import b: api; let i=new test:first {handle: a.handle,...}; let j=new test:first {handle: b.handle,...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x02\x0b\x0a\x01\x00\x04\x74\x61\x6b\x65\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource.wat",
      bytes: implicit_wat_bytes(
        "(component (import \"handle\" (type (sub resource))) (type (func (param \"h\" (own 0)))) (import \"take\" (func (type 2))) (export \"take\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports nested-up" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "nested-narrow.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "nested-wide.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x01\x42\x02\x01\x42\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "nested-narrow.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (instance (type (func)) (export \"f\" (func (type 0))))) (export \"nested\" (instance (type 0))))) (import \"api\" (instance (type 0))))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "nested-wide.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (instance (type (func)) (export \"f\" (func (type 0))) (export \"g\" (func (type 0))))) (export \"nested\" (instance (type 0))))) (import \"api\" (instance (type 0))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports nested-down" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "nested-wide.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x01\x42\x02\x01\x42\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "nested-narrow.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x06\x6e\x65\x73\x74\x65\x64\x05\x00\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "nested-wide.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (instance (type (func)) (export \"f\" (func (type 0))) (export \"g\" (func (type 0))))) (export \"nested\" (instance (type 0))))) (import \"api\" (instance (type 0))))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "nested-narrow.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (instance (type (func)) (export \"f\" (func (type 0))))) (export \"nested\" (instance (type 0))))) (import \"api\" (instance (type 0))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports build-one-build-two" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "build-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1a\x01\x00\x15\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x30\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "build-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x19\x01\x00\x14\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "build-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0+01\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "build-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0+1\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.0.0+01", "instance", "interface", "test:api/run@1.0.0+01",
      "0", "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports build-two-build-one" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "build-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x19\x01\x00\x14\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "build-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1a\x01\x00\x15\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x30\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "build-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0+1\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "build-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0+01\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.0.0+01", "instance", "interface", "test:api/run@1.0.0+1",
      "0", "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports build-alpha-build-one" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "build-alpha.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1d\x01\x00\x18\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x61\x6c\x70\x68\x61\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "build-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1a\x01\x00\x15\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x30\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "build-alpha.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0+alpha\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "build-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0+01\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.0.0+alpha", "instance", "interface", "test:api/run@1.0.0+alpha",
      "0", "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports minor-one-minor-two" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "minor-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x31\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "minor-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x31\x2e\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "minor-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@0.1.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "minor-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@0.1.1\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@0.1.1", "instance", "interface", "test:api/run@0.1.0", "0",
      "1", "f", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports minor-one-minor-other" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "minor-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x31\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "minor-other.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x32\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "minor-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@0.1.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "minor-other.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@0.2.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:api/run@0.1.0", "instance", "interface", "test:api/run@0.1.0", "0",
      "1", "f", "func", "function", "false", "0", "none", "test:api/run@0.2.0", "instance",
      "interface", "test:api/run@0.2.0", "0", "1", "f", "func", "function", "false",
      "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports zero-one-zero-two" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "zero-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x30\x2e\x31\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "zero-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x30\x2e\x32\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "zero-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@0.0.1\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "zero-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@0.0.2\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:api/run@0.0.1", "instance", "interface", "test:api/run@0.0.1", "0",
      "1", "f", "func", "function", "false", "0", "none", "test:api/run@0.0.2", "instance",
      "interface", "test:api/run@0.0.2", "0", "1", "f", "func", "function", "false",
      "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports pre-one-pre-two" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "pre-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1b\x01\x00\x16\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x6f\x6e\x65\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "pre-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1b\x01\x00\x16\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x74\x77\x6f\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "pre-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0-one\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "pre-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0-two\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:api/run@1.0.0-one", "instance", "interface", "test:api/run@1.0.0-one",
      "0", "1", "f", "func", "function", "false", "0", "none", "test:api/run@1.0.0-two",
      "instance", "interface", "test:api/run@1.0.0-two", "0", "1", "f", "func", "function",
      "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports component-narrow-component-wide" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "component-narrow.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x0e\x01\x00\x09\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x04\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "component-wide.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x41\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x0a\x0e\x01\x00\x09\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x04\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "component-narrow.wat",
      bytes: implicit_wat_bytes(
        "(component (type (component (type (func)) (export \"f\" (func (type 0))))) (import \"component\" (component (type 0))))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "component-wide.wat",
      bytes: implicit_wat_bytes(
        "(component (type (component (type (func)) (export \"f\" (func (type 0)))(export \"g\" (func (type 0))))) (import \"component\" (component (type 0))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "component", "component", "world", "", "0", "0", "2", "f", "func", "function",
      "false", "0", "none", "g", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports component-wide-component-narrow" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "component-wide.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x41\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x0a\x0e\x01\x00\x09\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x04\x00",
    },
    {
      name: "test:second",
      version: None,
      source: "component-narrow.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x0e\x01\x00\x09\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x04\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "component-wide.wat",
      bytes: implicit_wat_bytes(
        "(component (type (component (type (func)) (export \"f\" (func (type 0)))(export \"g\" (func (type 0))))) (import \"component\" (component (type 0))))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "component-narrow.wat",
      bytes: implicit_wat_bytes(
        "(component (type (component (type (func)) (export \"f\" (func (type 0))))) (import \"component\" (component (type 0))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "component", "component", "world", "", "0", "0", "2", "f", "func", "function",
      "false", "0", "none", "g", "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports version-explicit-before" {
  let source = "package test:app; interface local {f: func(); g: func();} import api as \"test:api/run@1.2.0\": local; let i=new test:first {...}; export api;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.2.0", "instance", "interface", "test:api/run@1.0.0", "0",
      "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
      "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports version-explicit-after" {
  let source = "package test:app; let i=new test:first {...}; interface local {f: func(); g: func();} import api as \"test:api/run@1.2.0\": local; export api;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x05\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "v1.wat",
      bytes: implicit_wat_bytes(
        "(component (type (instance (type (func))(export \"f\" (func (type 0))))) (import \"test:api/run@1.0.0\" (instance (type 0))) (export \"api\" (instance 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "test:api/run@1.2.0", "instance", "interface", "test:api/run@1.0.0", "0",
      "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
      "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports generative-explicit" {
  let source = "package test:app; interface api {resource handle;} import a: api; import b: api; let i=new test:first {...}; export a as first; export b as second;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "f.wat",
      bytes: implicit_wat_bytes(
        "(component (type (func)) (import \"f\" (func (type 0))) (export \"out\" (func 0)))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "3", "f", "func", "function", "false", "0", "none", "a", "instance", "interface",
      "test:app/api", "0", "1", "handle", "type", "resource", "0", "b", "instance",
      "interface", "test:app/api", "0", "1", "handle", "type", "resource", "0", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-resource" {
  let source = "package test:app; let i=new test:first {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x0a\x02\x69\x01\x40\x01\x01\x68\x02\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x15\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x03\x04\x74\x61\x6b\x65\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-resource.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $take (func (param \"h\" (own $handle)))) (import \"take\" (func (type $take))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-resource-repeat" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:first {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x0a\x02\x69\x01\x40\x01\x01\x68\x02\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x15\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x03\x04\x74\x61\x6b\x65\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-resource.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $take (func (param \"h\" (own $handle)))) (import \"take\" (func (type $take))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-resource-explicit" {
  let source = "package test:app; interface api {resource handle;} import a: api; let i=new test:first {\"test:dep/api\": a,...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x0a\x02\x69\x01\x40\x01\x01\x68\x02\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x03\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x15\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x03\x04\x74\x61\x6b\x65\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-resource.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $take (func (param \"h\" (own $handle)))) (import \"take\" (func (type $take))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-interface" {
  let source = "package test:app; let i=new test:first {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x28\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x00\x01\x69\x00\x01\x40\x01\x01\x68\x02\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x03\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x05\x02\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x19\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x02\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $consumer (instance (alias outer 1 $handle (type $handle)) (export \"handle\" (type (eq $handle))) (type $take (func (param \"h\" (own $handle)))) (export \"take\" (func (type $take))))) (import \"consumer\" (instance (type $consumer))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:dep/api", "instance", "interface", "test:dep/api", "0", "1", "handle",
      "type", "resource", "0", "consumer", "instance", "interface", "", "1", "handle",
      "handle", "test:dep/api", "2", "handle", "type", "resource", "0", "take", "func",
      "function", "false", "1", "h", "own", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-interface-explicit" {
  let source = "package test:app; interface api {resource handle;} import a: api; let i=new test:first {\"test:dep/api\": a,...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x28\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x00\x01\x69\x00\x01\x40\x01\x01\x68\x02\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x03\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x05\x02\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x19\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x02\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $consumer (instance (alias outer 1 $handle (type $handle)) (export \"handle\" (type (eq $handle))) (type $take (func (param \"h\" (own $handle)))) (export \"take\" (func (type $take))))) (import \"consumer\" (instance (type $consumer))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports resource-api-union" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource-api-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x01\x42\x04\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x00\x03\x61\x70\x69",
    },
    {
      name: "test:second",
      version: None,
      source: "resource-api-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x31\x01\x42\x06\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x01\x40\x00\x01\x00\x04\x00\x05\x6f\x74\x68\x65\x72\x01\x03\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource-api-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))) (type $take (func (param \"h\" (own 0)))) (export \"take\" (func (type $take))) )) (import \"api\" (instance (type $api))))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "resource-api-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))) (type $take (func (param \"h\" (own 0)))) (export \"take\" (func (type $take))) (type (func)) (export \"other\" (func (type 3))))) (import \"api\" (instance (type $api))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "api", "instance", "interface", "", "0", "3", "handle", "type", "resource",
      "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "other",
      "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports resource-api-reverse" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:second {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource-api-two.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x31\x01\x42\x06\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x01\x40\x00\x01\x00\x04\x00\x05\x6f\x74\x68\x65\x72\x01\x03\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x00\x03\x61\x70\x69",
    },
    {
      name: "test:second",
      version: None,
      source: "resource-api-one.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x22\x01\x42\x04\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x0a\x08\x01\x00\x03\x61\x70\x69\x05\x00\x00\x18\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x07\x03\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "resource-api-two.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))) (type $take (func (param \"h\" (own 0)))) (export \"take\" (func (type $take))) (type (func)) (export \"other\" (func (type 3))))) (import \"api\" (instance (type $api))))",
      ),
    },
    {
      name: "test:second",
      version: None,
      source: "resource-api-one.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))) (type $take (func (param \"h\" (own 0)))) (export \"take\" (func (type $take))) )) (import \"api\" (instance (type $api))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "1", "api", "instance", "interface", "", "0", "3", "handle", "type", "resource",
      "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "other",
      "func", "function", "false", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports pair-resource" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:first {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "pair-resource.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x0b\x02\x00\x01\x61\x05\x00\x00\x01\x62\x05\x00\x06\x15\x02\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x01\x06\x68\x61\x6e\x64\x6c\x65\x07\x0f\x03\x69\x01\x69\x02\x40\x02\x01\x61\x03\x01\x62\x04\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x05\x00\x32\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x17\x03\x04\x00\x03\x61\x70\x69\x01\x03\x61\x2d\x68\x02\x03\x62\x2d\x68\x05\x04\x74\x61\x6b\x65\x01\x08\x05\x02\x00\x01\x61\x01\x01\x62",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "pair-resource.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"a\" (instance $a (type $api))) (import \"b\" (instance $b (type $api))) (alias export $a \"handle\" (type $a-h)) (alias export $b \"handle\" (type $b-h)) (type $take (func (param \"a\" (own $a-h)) (param \"b\" (own $b-h)))) (import \"take\" (func (type $take))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-interface-repeated" {
  let source = "package test:app; let i=new test:first {...}; let j=new test:first {...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x28\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x00\x01\x69\x00\x01\x40\x01\x01\x68\x02\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x03\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x05\x02\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x19\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x02\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $consumer (instance (alias outer 1 $handle (type $handle)) (export \"handle\" (type (eq $handle))) (type $take (func (param \"h\" (own $handle)))) (export \"take\" (func (type $take))))) (import \"consumer\" (instance (type $consumer))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:dep/api", "instance", "interface", "test:dep/api", "0", "1", "handle",
      "type", "resource", "0", "consumer", "instance", "interface", "", "1", "handle",
      "handle", "test:dep/api", "2", "handle", "type", "resource", "0", "take", "func",
      "function", "false", "1", "h", "own", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports used-interface-exact-explicit" {
  let source = "package test:app; interface api {resource handle;} import a as \"test:dep/api\": api; let i=new test:first {\"test:dep/api\": a,...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x06\x0b\x01\x03\x00\x00\x06\x68\x61\x6e\x64\x6c\x65\x07\x28\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x00\x00\x01\x69\x00\x01\x40\x01\x01\x68\x02\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x03\x0a\x0d\x01\x00\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x05\x02\x00\x33\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x19\x03\x03\x00\x03\x61\x70\x69\x01\x06\x68\x61\x6e\x64\x6c\x65\x02\x08\x63\x6f\x6e\x73\x75\x6d\x65\x72\x01\x07\x05\x01\x00\x03\x61\x70\x69",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "used-interface.wat",
      bytes: implicit_wat_bytes(
        "(component (type $api (instance (export \"handle\" (type (sub resource))))) (import \"test:dep/api\" (instance $api (type $api))) (alias export $api \"handle\" (type $handle)) (type $consumer (instance (alias outer 1 $handle (type $handle)) (export \"handle\" (type (eq $handle))) (type $take (func (param \"h\" (own $handle)))) (export \"take\" (func (type $take))))) (import \"consumer\" (instance (type $consumer))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(implicit_import_projection(model), [
      "2", "test:dep/api", "instance", "interface", "test:dep/api", "0", "1", "handle",
      "type", "resource", "0", "consumer", "instance", "interface", "", "1", "handle",
      "handle", "test:dep/api", "2", "handle", "type", "resource", "0", "take", "func",
      "function", "false", "1", "h", "own", "0", "none", "0",
    ])
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}

///|
test "implicit imports split-captures" {
  let source = "package test:app; interface left {resource handle; take: func(h: handle);} interface right {resource handle; take: func(h: handle);} import a: left; import b: right; let i=new test:first {handle: a.handle, second: a.take,...}; let j=new test:first {handle: b.handle, first: b.take,...};"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "split-captures.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x14\x02\x00\x05\x66\x69\x72\x73\x74\x01\x02\x00\x06\x73\x65\x63\x6f\x6e\x64\x01\x02\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x01\x02\x04\x74\x61\x6b\x65",
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
  let text_result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:first",
      version: None,
      source: "split-captures.wat",
      bytes: implicit_wat_bytes(
        "(component (import \"handle\" (type (sub resource))) (type $take (func (param \"h\" (own 0)))) (import \"first\" (func (type $take))) (import \"second\" (func (type $take))))",
      ),
    },
  ])
  assert_eq(text_result is Ok(_), result is Ok(_))
  if text_result is Ok(text_model) && result is Ok(model) {
    assert_eq(
      implicit_import_projection(text_model),
      implicit_import_projection(model),
    )
  }
  if result is Ok(model) {
    assert_eq(
      implicit_resource_binding(model, "first"),
      implicit_resource_binding(model, "a"),
    )
    assert_eq(
      implicit_resource_binding(model, "second"),
      implicit_resource_binding(model, "b"),
    )
    assert_true(
      implicit_resource_binding(model, "first") !=
      implicit_resource_binding(model, "second"),
    )
    for node in model.composition() {
      match node.operation {
        Access(parent, _) => assert_true(parent < node.id)
        Instantiate(_, _, arguments) =>
          for argument in arguments {
            assert_true(argument.value < node.id)
          }
        _ => ()
      }
    }
  }
}
