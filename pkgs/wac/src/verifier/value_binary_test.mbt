///|
test "value extern own-without-resource-export" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x6f",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0",
      "1", "v", "value", "own", "0", "instance", "interface", "", "0", "1", "v",
      "value", "own", "0", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0",
    "1", "v", "value", "own", "0", "instance", "interface", "", "0", "1", "v", "value",
    "own", "0", "definitions", "0",
  ])
}

///|
test "value extern record-unnamed-import" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x06\x01\x00\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x72",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (record (field \"x\" u32))) (import \"v\" (value (type $r))) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern record-named-import" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x0c\x02\x00\x01\x72\x03\x00\x00\x00\x01\x76\x02\x01\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1a\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x09\x03\x02\x00\x01\x72\x01\x02\x72\x74",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "record", "1", "x", "scalar", "u32", "v",
      "value", "record", "1", "x", "scalar", "u32", "1", "v", "value", "record",
      "1", "x", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
      "record", "1", "x", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (record (field \"x\" u32))) (import \"r\" (type $rt (eq $r))) (import \"v\" (value (type $rt))) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "record", "1", "x", "scalar", "u32", "v",
    "value", "record", "1", "x", "scalar", "u32", "1", "v", "value", "record", "1",
    "x", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value", "record",
    "1", "x", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern instance-record-unnamed" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x01\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x76\x02\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $r (record (field \"x\" u32))) (export \"v\" (value (type $r))))) (import \"i\" (instance (type $i))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern instance-record-unused" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x01\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x76\x02\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $r (record (field \"x\" u32))) (export \"v\" (value (type $r))))))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
}

///|
test "value extern component-record-unnamed-import" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x01\x41\x02\x01\x72\x01\x01\x78\x79\x03\x00\x01\x76\x02\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $c (component (type $r (record (field \"x\" u32))) (import \"v\" (value (type $r))))) (import \"c\" (component (type $c))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern component-record-unnamed-export" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x01\x41\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x76\x02\x00\x0a\x06\x01\x00\x01\x63\x04\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $c (component (type $r (record (field \"x\" u32))) (export \"v\" (value (type $r))))) (import \"c\" (component (type $c))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern component-export-resource-import-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x41\x03\x04\x00\x01\x72\x03\x01\x01\x69\x00\x03\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $c (component (export \"r\" (type $r (sub resource))) (type $o (own $r)) (import \"v\" (value (type $o))))) (import \"c\" (component (type $c))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern instance-named-record-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x03\x01\x72\x01\x01\x78\x79\x04\x00\x01\x72\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "r", "type",
      "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
      "u32", "1", "v", "value", "record", "1", "x", "scalar", "u32", "instance",
      "interface", "", "0", "1", "v", "value", "record", "1", "x", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $r (record (field \"x\" u32))) (export \"r\" (type $rt (eq $r))) (export \"v\" (value (type $rt))))) (import \"i\" (instance (type $i))) (alias export 0 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "r", "type",
    "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
    "u32", "1", "v", "value", "record", "1", "x", "scalar", "u32", "instance", "interface",
    "", "0", "1", "v", "value", "record", "1", "x", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "value extern instance-named-record-export-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x03\x01\x72\x01\x01\x78\x79\x04\x00\x01\x72\x03\x00\x00\x04\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x03\x00\x00\x01\x72\x0b\x07\x01\x00\x01\x72\x03\x01\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x69\x01\x01\x72",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "r", "type",
      "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
      "u32", "2", "r", "type", "record", "1", "x", "scalar", "u32", "v", "value",
      "record", "1", "x", "scalar", "u32", "instance", "interface", "", "0", "2",
      "r", "type", "record", "1", "x", "scalar", "u32", "v", "value", "record", "1",
      "x", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $r (record (field \"x\" u32))) (export \"r\" (type $rt (eq $r))) (export \"v\" (value (type $rt))))) (import \"i\" (instance (type $i))) (alias export 0 \"r\" (type $r)) (export \"r\" (type $r)) (alias export 0 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "r", "type",
    "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
    "u32", "2", "r", "type", "record", "1", "x", "scalar", "u32", "v", "value", "record",
    "1", "x", "scalar", "u32", "instance", "interface", "", "0", "2", "r", "type",
    "record", "1", "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar",
    "u32", "definitions", "0",
  ])
}

///|
test "value extern export-alias" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x0d\x02\x00\x01\x61\x02\x00\x00\x00\x01\x62\x02\x01\x00",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)) (export \"a\" (value 0)) (export \"b\" (value 1)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern export-alias-twice" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x13\x03\x00\x01\x61\x02\x00\x00\x00\x01\x62\x02\x01\x00\x00\x01\x63\x02\x01\x00",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)) (export \"a\" (value 0)) (export \"b\" (value 1)) (export \"c\" (value 1)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern instance-unused" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x69\x05\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
      "scalar", "u32", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (instance (export \"v\" (value u32)))) (import \"i\" (instance (type 0))))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "0", "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "value extern alias-unused" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x02\x00\x00\x01\x76",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (instance (export \"v\" (value u32)))) (import \"i\" (instance (type 0))) (alias export 0 \"v\" (value)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern local-own-import" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x02\x3f\x7f\x00\x69\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x76\x02\x00\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x6f",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $o (own $r)) (import \"v\" (value (type $o))) (export \"r\" (type $r)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern borrow-unused-instance" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x18\x01\x42\x04\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x04\x00\x01\x76\x02\x02\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "resource", "0", "i", "instance", "interface",
      "", "0", "2", "r", "type", "resource", "0", "v", "value", "borrow", "0", "0",
      "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type (eq $r))) (type $b (borrow 1)) (export \"v\" (value (type $b))))) (import \"i\" (instance (type $i))))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "i", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "v", "value", "borrow", "0", "0",
    "instance", "interface", "", "0", "0", "definitions", "0",
  ])
}

///|
test "value extern import" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern reexport" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
      "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
test "value extern duplicate-use" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x0d\x02\x00\x01\x61\x02\x00\x00\x00\x01\x62\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)) (export \"a\" (value 0)) (export \"b\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern future" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x0a\x06\x01\x00\x01\x76\x02\x79",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (export \"v\" (value 0)) (import \"v\" (value u32)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern ascription" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x09\x01\x00\x01\x76\x02\x00\x01\x02\x79",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
      "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)) (export \"v\" (value 0) (value u32)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
test "value extern ascription-mismatch" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x09\x01\x00\x01\x76\x02\x00\x01\x02\x77",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value u32)) (export \"v\" (value 0) (value u64)))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern composite" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x70\x79\x0a\x06\x01\x00\x01\x76\x02\x00\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "list", "scalar", "u32", "1", "v", "value",
      "list", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
      "list", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (list u32)) (import \"v\" (value (type 0))) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "list", "scalar", "u32", "1", "v", "value",
    "list", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
    "list", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern instance" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
      "scalar", "u32", "1", "v", "value", "scalar", "u32", "instance", "interface",
      "", "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (instance (export \"v\" (value u32)))) (import \"i\" (instance (type 0))) (alias export 0 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "1", "v", "value", "scalar", "u32", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern instance-duplicate-alias" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0b\x02\x02\x00\x00\x01\x76\x02\x00\x00\x01\x76\x0b\x0d\x02\x00\x01\x61\x02\x00\x00\x00\x01\x62\x02\x01\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
      "scalar", "u32", "2", "a", "value", "scalar", "u32", "b", "value", "scalar",
      "u32", "instance", "interface", "", "0", "2", "a", "value", "scalar", "u32",
      "b", "value", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (instance (export \"v\" (value u32)))) (import \"i\" (instance (type 0))) (alias export 0 \"v\" (value)) (alias export 0 \"v\" (value)) (export \"a\" (value 0)) (export \"b\" (value 1)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "2", "a", "value", "scalar", "u32", "b", "value", "scalar",
    "u32", "instance", "interface", "", "0", "2", "a", "value", "scalar", "u32",
    "b", "value", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern component" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0f\x01\x41\x02\x03\x00\x01\x76\x02\x79\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x07\x01\x00\x01\x63\x04\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "c", "component", "world", "", "0", "1", "v", "value",
      "scalar", "u32", "1", "v", "value", "scalar", "u32", "1", "c", "component",
      "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
      "u32", "instance", "interface", "", "0", "1", "c", "component", "world", "",
      "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (component (import \"v\" (value u32)) (export \"v\" (value u32)))) (import \"c\" (component (type 0))) (export \"c\" (component 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "c", "component", "world", "", "0", "1", "v", "value",
    "scalar", "u32", "1", "v", "value", "scalar", "u32", "1", "c", "component", "world",
    "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar", "u32",
    "instance", "interface", "", "0", "1", "c", "component", "world", "", "0", "1",
    "v", "value", "scalar", "u32", "1", "v", "value", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "value extern own" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x69\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0",
      "2", "r", "type", "resource", "0", "v", "value", "own", "0", "instance", "interface",
      "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0", "definitions",
      "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type (own 0)) (import \"v\" (value (type 1))) (export \"r\" (type 0)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0",
    "2", "r", "type", "resource", "0", "v", "value", "own", "0", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0", "definitions",
    "0",
  ])
}

///|
test "value extern borrow" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x03\x01\x68\x00\x0a\x06\x01\x00\x01\x76\x02\x01\x0b\x0d\x02\x00\x01\x72\x03\x00\x00\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "resource", "0", "v", "value", "borrow",
      "0", "2", "r", "type", "resource", "0", "v", "value", "borrow", "0", "instance",
      "interface", "", "0", "2", "r", "type", "resource", "0", "v", "value", "borrow",
      "0", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type (sub resource))) (type (borrow 0)) (import \"v\" (value (type 1))) (export \"r\" (type 0)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "v", "value", "borrow",
    "0", "2", "r", "type", "resource", "0", "v", "value", "borrow", "0", "instance",
    "interface", "", "0", "2", "r", "type", "resource", "0", "v", "value", "borrow",
    "0", "definitions", "0",
  ])
}

///|
test "value extern named-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
      "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v\" (value $v u32)) (export \"v\" (value $v)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
test "value extern projected-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x09\x01\x42\x01\x04\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69\x01\x05\x05\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
      "scalar", "u32", "1", "v", "value", "scalar", "u32", "instance", "interface",
      "", "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (export \"v\" (value u32)))) (import \"i\" (instance $i (type $i))) (export \"v\" (value $i \"v\")))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "v", "value",
    "scalar", "u32", "1", "v", "value", "scalar", "u32", "instance", "interface",
    "", "0", "1", "v", "value", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern structural-record-ascription" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x0c\x02\x00\x01\x61\x03\x00\x00\x00\x01\x76\x02\x01\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x09\x01\x00\x01\x76\x02\x00\x01\x02\x02\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x03\x00\x01\x61\x01\x02\x61\x74\x02\x01\x62",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $a (record (field \"x\" u32))) (import \"a\" (type $at (eq $a))) (import \"v\" (value (type $at))) (type $b (record (field \"x\" u32))) (export \"v\" (value 0) (value (type $b))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern list-ascription" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x03\x01\x70\x79\x0a\x06\x01\x00\x01\x76\x02\x00\x07\x03\x01\x70\x79\x0b\x09\x01\x00\x01\x76\x02\x00\x01\x02\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x61\x01\x01\x62",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "list", "scalar", "u32", "1", "v", "value",
      "list", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
      "list", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $a (list u32)) (import \"v\" (value (type $a))) (type $b (list u32)) (export \"v\" (value 0) (value (type $b))))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "list", "scalar", "u32", "1", "v", "value",
    "list", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
    "list", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern local-resource-instance-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1b\x02\x3f\x7f\x00\x42\x04\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x04\x00\x01\x76\x02\x02\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type $rt (eq $r))) (type $o (own $rt)) (export \"v\" (value (type $o))))) (import \"i\" (instance (type $i))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern imported-resource-instance-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x06\x01\x00\x01\x72\x03\x01\x07\x18\x01\x42\x04\x02\x03\x02\x01\x00\x04\x00\x01\x72\x03\x00\x00\x01\x69\x01\x04\x00\x01\x76\x02\x02\x0a\x06\x01\x00\x01\x69\x05\x01\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "resource", "0", "i", "instance", "interface",
      "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0", "1",
      "v", "value", "own", "0", "instance", "interface", "", "0", "1", "v", "value",
      "own", "0", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (type $i (instance (alias outer 1 $r (type $r)) (export \"r\" (type $rt (eq $r))) (type $o (own $rt)) (export \"v\" (value (type $o))))) (import \"i\" (instance (type $i))) (alias export 0 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "resource", "0", "i", "instance", "interface",
    "", "0", "2", "r", "type", "resource", "0", "v", "value", "own", "0", "1", "v",
    "value", "own", "0", "instance", "interface", "", "0", "1", "v", "value", "own",
    "0", "definitions", "0",
  ])
}

///|
test "value extern nested-unnamed-record-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x18\x01\x42\x02\x01\x42\x02\x01\x72\x01\x01\x78\x79\x04\x00\x01\x76\x02\x00\x04\x00\x01\x6a\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $j (instance (type $r (record (field \"x\" u32))) (export \"v\" (value (type $r))))) (export \"j\" (instance (type $j))))) (import \"i\" (instance (type $i))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern nested-named-record-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x01\x42\x02\x01\x42\x03\x01\x72\x01\x01\x78\x79\x04\x00\x01\x72\x03\x00\x00\x04\x00\x01\x76\x02\x01\x04\x00\x01\x6a\x05\x00\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0b\x02\x05\x00\x00\x01\x6a\x02\x00\x01\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "j", "instance",
      "interface", "", "0", "2", "r", "type", "record", "1", "x", "scalar", "u32",
      "v", "value", "record", "1", "x", "scalar", "u32", "1", "v", "value", "record",
      "1", "x", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
      "record", "1", "x", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $j (instance (type $r (record (field \"x\" u32))) (export \"r\" (type $rt (eq $r))) (export \"v\" (value (type $rt))))) (export \"j\" (instance (type $j))))) (import \"i\" (instance (type $i))) (alias export 0 \"j\" (instance)) (alias export 1 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "1", "j", "instance",
    "interface", "", "0", "2", "r", "type", "record", "1", "x", "scalar", "u32",
    "v", "value", "record", "1", "x", "scalar", "u32", "1", "v", "value", "record",
    "1", "x", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
    "record", "1", "x", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern wide-type-index" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x86\x02\x82\x01\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x70\x79\x0a\x07\x01\x00\x01\x76\x02\x81\x01\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "list", "scalar", "u32", "1", "v", "value",
      "list", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
      "list", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (type (list u32)) (import \"v\" (value (type 129))) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "list", "scalar", "u32", "1", "v", "value",
    "list", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
    "list", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern many-values" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\xc9\x01\x1e\x00\x02\x76\x30\x02\x79\x00\x02\x76\x31\x02\x79\x00\x02\x76\x32\x02\x79\x00\x02\x76\x33\x02\x79\x00\x02\x76\x34\x02\x79\x00\x02\x76\x35\x02\x79\x00\x02\x76\x36\x02\x79\x00\x02\x76\x37\x02\x79\x00\x02\x76\x38\x02\x79\x00\x02\x76\x39\x02\x79\x00\x03\x76\x31\x30\x02\x79\x00\x03\x76\x31\x31\x02\x79\x00\x03\x76\x31\x32\x02\x79\x00\x03\x76\x31\x33\x02\x79\x00\x03\x76\x31\x34\x02\x79\x00\x03\x76\x31\x35\x02\x79\x00\x03\x76\x31\x36\x02\x79\x00\x03\x76\x31\x37\x02\x79\x00\x03\x76\x31\x38\x02\x79\x00\x03\x76\x31\x39\x02\x79\x00\x03\x76\x32\x30\x02\x79\x00\x03\x76\x32\x31\x02\x79\x00\x03\x76\x32\x32\x02\x79\x00\x03\x76\x32\x33\x02\x79\x00\x03\x76\x32\x34\x02\x79\x00\x03\x76\x32\x35\x02\x79\x00\x03\x76\x32\x36\x02\x79\x00\x03\x76\x32\x37\x02\x79\x00\x03\x76\x32\x38\x02\x79\x00\x03\x76\x32\x39\x02\x79\x0b\xe7\x01\x1e\x00\x02\x76\x30\x02\x00\x00\x00\x02\x76\x31\x02\x01\x00\x00\x02\x76\x32\x02\x02\x00\x00\x02\x76\x33\x02\x03\x00\x00\x02\x76\x34\x02\x04\x00\x00\x02\x76\x35\x02\x05\x00\x00\x02\x76\x36\x02\x06\x00\x00\x02\x76\x37\x02\x07\x00\x00\x02\x76\x38\x02\x08\x00\x00\x02\x76\x39\x02\x09\x00\x00\x03\x76\x31\x30\x02\x0a\x00\x00\x03\x76\x31\x31\x02\x0b\x00\x00\x03\x76\x31\x32\x02\x0c\x00\x00\x03\x76\x31\x33\x02\x0d\x00\x00\x03\x76\x31\x34\x02\x0e\x00\x00\x03\x76\x31\x35\x02\x0f\x00\x00\x03\x76\x31\x36\x02\x10\x00\x00\x03\x76\x31\x37\x02\x11\x00\x00\x03\x76\x31\x38\x02\x12\x00\x00\x03\x76\x31\x39\x02\x13\x00\x00\x03\x76\x32\x30\x02\x14\x00\x00\x03\x76\x32\x31\x02\x15\x00\x00\x03\x76\x32\x32\x02\x16\x00\x00\x03\x76\x32\x33\x02\x17\x00\x00\x03\x76\x32\x34\x02\x18\x00\x00\x03\x76\x32\x35\x02\x19\x00\x00\x03\x76\x32\x36\x02\x1a\x00\x00\x03\x76\x32\x37\x02\x1b\x00\x00\x03\x76\x32\x38\x02\x1c\x00\x00\x03\x76\x32\x39\x02\x1d\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "30", "v0", "value", "scalar", "u32", "v1", "value", "scalar",
      "u32", "v2", "value", "scalar", "u32", "v3", "value", "scalar", "u32", "v4",
      "value", "scalar", "u32", "v5", "value", "scalar", "u32", "v6", "value", "scalar",
      "u32", "v7", "value", "scalar", "u32", "v8", "value", "scalar", "u32", "v9",
      "value", "scalar", "u32", "v10", "value", "scalar", "u32", "v11", "value",
      "scalar", "u32", "v12", "value", "scalar", "u32", "v13", "value", "scalar",
      "u32", "v14", "value", "scalar", "u32", "v15", "value", "scalar", "u32", "v16",
      "value", "scalar", "u32", "v17", "value", "scalar", "u32", "v18", "value",
      "scalar", "u32", "v19", "value", "scalar", "u32", "v20", "value", "scalar",
      "u32", "v21", "value", "scalar", "u32", "v22", "value", "scalar", "u32", "v23",
      "value", "scalar", "u32", "v24", "value", "scalar", "u32", "v25", "value",
      "scalar", "u32", "v26", "value", "scalar", "u32", "v27", "value", "scalar",
      "u32", "v28", "value", "scalar", "u32", "v29", "value", "scalar", "u32", "30",
      "v0", "value", "scalar", "u32", "v1", "value", "scalar", "u32", "v2", "value",
      "scalar", "u32", "v3", "value", "scalar", "u32", "v4", "value", "scalar", "u32",
      "v5", "value", "scalar", "u32", "v6", "value", "scalar", "u32", "v7", "value",
      "scalar", "u32", "v8", "value", "scalar", "u32", "v9", "value", "scalar", "u32",
      "v10", "value", "scalar", "u32", "v11", "value", "scalar", "u32", "v12", "value",
      "scalar", "u32", "v13", "value", "scalar", "u32", "v14", "value", "scalar",
      "u32", "v15", "value", "scalar", "u32", "v16", "value", "scalar", "u32", "v17",
      "value", "scalar", "u32", "v18", "value", "scalar", "u32", "v19", "value",
      "scalar", "u32", "v20", "value", "scalar", "u32", "v21", "value", "scalar",
      "u32", "v22", "value", "scalar", "u32", "v23", "value", "scalar", "u32", "v24",
      "value", "scalar", "u32", "v25", "value", "scalar", "u32", "v26", "value",
      "scalar", "u32", "v27", "value", "scalar", "u32", "v28", "value", "scalar",
      "u32", "v29", "value", "scalar", "u32", "instance", "interface", "", "0", "30",
      "v0", "value", "scalar", "u32", "v1", "value", "scalar", "u32", "v2", "value",
      "scalar", "u32", "v3", "value", "scalar", "u32", "v4", "value", "scalar", "u32",
      "v5", "value", "scalar", "u32", "v6", "value", "scalar", "u32", "v7", "value",
      "scalar", "u32", "v8", "value", "scalar", "u32", "v9", "value", "scalar", "u32",
      "v10", "value", "scalar", "u32", "v11", "value", "scalar", "u32", "v12", "value",
      "scalar", "u32", "v13", "value", "scalar", "u32", "v14", "value", "scalar",
      "u32", "v15", "value", "scalar", "u32", "v16", "value", "scalar", "u32", "v17",
      "value", "scalar", "u32", "v18", "value", "scalar", "u32", "v19", "value",
      "scalar", "u32", "v20", "value", "scalar", "u32", "v21", "value", "scalar",
      "u32", "v22", "value", "scalar", "u32", "v23", "value", "scalar", "u32", "v24",
      "value", "scalar", "u32", "v25", "value", "scalar", "u32", "v26", "value",
      "scalar", "u32", "v27", "value", "scalar", "u32", "v28", "value", "scalar",
      "u32", "v29", "value", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"v0\" (value u32)) (import \"v1\" (value u32)) (import \"v2\" (value u32)) (import \"v3\" (value u32)) (import \"v4\" (value u32)) (import \"v5\" (value u32)) (import \"v6\" (value u32)) (import \"v7\" (value u32)) (import \"v8\" (value u32)) (import \"v9\" (value u32)) (import \"v10\" (value u32)) (import \"v11\" (value u32)) (import \"v12\" (value u32)) (import \"v13\" (value u32)) (import \"v14\" (value u32)) (import \"v15\" (value u32)) (import \"v16\" (value u32)) (import \"v17\" (value u32)) (import \"v18\" (value u32)) (import \"v19\" (value u32)) (import \"v20\" (value u32)) (import \"v21\" (value u32)) (import \"v22\" (value u32)) (import \"v23\" (value u32)) (import \"v24\" (value u32)) (import \"v25\" (value u32)) (import \"v26\" (value u32)) (import \"v27\" (value u32)) (import \"v28\" (value u32)) (import \"v29\" (value u32)) (export \"v0\" (value 0)) (export \"v1\" (value 1)) (export \"v2\" (value 2)) (export \"v3\" (value 3)) (export \"v4\" (value 4)) (export \"v5\" (value 5)) (export \"v6\" (value 6)) (export \"v7\" (value 7)) (export \"v8\" (value 8)) (export \"v9\" (value 9)) (export \"v10\" (value 10)) (export \"v11\" (value 11)) (export \"v12\" (value 12)) (export \"v13\" (value 13)) (export \"v14\" (value 14)) (export \"v15\" (value 15)) (export \"v16\" (value 16)) (export \"v17\" (value 17)) (export \"v18\" (value 18)) (export \"v19\" (value 19)) (export \"v20\" (value 20)) (export \"v21\" (value 21)) (export \"v22\" (value 22)) (export \"v23\" (value 23)) (export \"v24\" (value 24)) (export \"v25\" (value 25)) (export \"v26\" (value 26)) (export \"v27\" (value 27)) (export \"v28\" (value 28)) (export \"v29\" (value 29)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "30", "v0", "value", "scalar", "u32", "v1", "value", "scalar",
    "u32", "v2", "value", "scalar", "u32", "v3", "value", "scalar", "u32", "v4",
    "value", "scalar", "u32", "v5", "value", "scalar", "u32", "v6", "value", "scalar",
    "u32", "v7", "value", "scalar", "u32", "v8", "value", "scalar", "u32", "v9",
    "value", "scalar", "u32", "v10", "value", "scalar", "u32", "v11", "value", "scalar",
    "u32", "v12", "value", "scalar", "u32", "v13", "value", "scalar", "u32", "v14",
    "value", "scalar", "u32", "v15", "value", "scalar", "u32", "v16", "value", "scalar",
    "u32", "v17", "value", "scalar", "u32", "v18", "value", "scalar", "u32", "v19",
    "value", "scalar", "u32", "v20", "value", "scalar", "u32", "v21", "value", "scalar",
    "u32", "v22", "value", "scalar", "u32", "v23", "value", "scalar", "u32", "v24",
    "value", "scalar", "u32", "v25", "value", "scalar", "u32", "v26", "value", "scalar",
    "u32", "v27", "value", "scalar", "u32", "v28", "value", "scalar", "u32", "v29",
    "value", "scalar", "u32", "30", "v0", "value", "scalar", "u32", "v1", "value",
    "scalar", "u32", "v2", "value", "scalar", "u32", "v3", "value", "scalar", "u32",
    "v4", "value", "scalar", "u32", "v5", "value", "scalar", "u32", "v6", "value",
    "scalar", "u32", "v7", "value", "scalar", "u32", "v8", "value", "scalar", "u32",
    "v9", "value", "scalar", "u32", "v10", "value", "scalar", "u32", "v11", "value",
    "scalar", "u32", "v12", "value", "scalar", "u32", "v13", "value", "scalar", "u32",
    "v14", "value", "scalar", "u32", "v15", "value", "scalar", "u32", "v16", "value",
    "scalar", "u32", "v17", "value", "scalar", "u32", "v18", "value", "scalar", "u32",
    "v19", "value", "scalar", "u32", "v20", "value", "scalar", "u32", "v21", "value",
    "scalar", "u32", "v22", "value", "scalar", "u32", "v23", "value", "scalar", "u32",
    "v24", "value", "scalar", "u32", "v25", "value", "scalar", "u32", "v26", "value",
    "scalar", "u32", "v27", "value", "scalar", "u32", "v28", "value", "scalar", "u32",
    "v29", "value", "scalar", "u32", "instance", "interface", "", "0", "30", "v0",
    "value", "scalar", "u32", "v1", "value", "scalar", "u32", "v2", "value", "scalar",
    "u32", "v3", "value", "scalar", "u32", "v4", "value", "scalar", "u32", "v5",
    "value", "scalar", "u32", "v6", "value", "scalar", "u32", "v7", "value", "scalar",
    "u32", "v8", "value", "scalar", "u32", "v9", "value", "scalar", "u32", "v10",
    "value", "scalar", "u32", "v11", "value", "scalar", "u32", "v12", "value", "scalar",
    "u32", "v13", "value", "scalar", "u32", "v14", "value", "scalar", "u32", "v15",
    "value", "scalar", "u32", "v16", "value", "scalar", "u32", "v17", "value", "scalar",
    "u32", "v18", "value", "scalar", "u32", "v19", "value", "scalar", "u32", "v20",
    "value", "scalar", "u32", "v21", "value", "scalar", "u32", "v22", "value", "scalar",
    "u32", "v23", "value", "scalar", "u32", "v24", "value", "scalar", "u32", "v25",
    "value", "scalar", "u32", "v26", "value", "scalar", "u32", "v27", "value", "scalar",
    "u32", "v28", "value", "scalar", "u32", "v29", "value", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "value extern core-body-and-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x30\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x05\x03\x01\x00\x01\x0a\x06\x01\x04\x00\x41\x2a\x0b\x0b\x0e\x01\x00\x41\x00\x0b\x08\x0a\x06\x01\x00\x01\x76\x02\x79\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
      "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (core module (memory 1) (data (i32.const 0) \"\\0a\\06\\01\\00\\01v\\02\\79\") (func (result i32) i32.const 42)) (import \"v\" (value u32)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "v", "value", "scalar", "u32", "1", "v", "value", "scalar",
    "u32", "instance", "interface", "", "0", "1", "v", "value", "scalar", "u32",
    "definitions", "0",
  ])
}

///|
test "value extern outer-named-record-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x07\x01\x00\x01\x72\x03\x00\x00\x07\x0e\x01\x42\x02\x02\x03\x02\x01\x01\x04\x00\x01\x76\x02\x00\x0a\x06\x01\x00\x01\x69\x05\x02\x06\x06\x01\x02\x00\x00\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x03\x00\x01\x72\x01\x02\x72\x74\x02\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "r", "type", "record", "1", "x", "scalar", "u32", "i",
      "instance", "interface", "", "0", "1", "v", "value", "record", "1", "x", "scalar",
      "u32", "1", "v", "value", "record", "1", "x", "scalar", "u32", "instance",
      "interface", "", "0", "1", "v", "value", "record", "1", "x", "scalar", "u32",
      "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (record (field \"x\" u32))) (import \"r\" (type $rt (eq $r))) (type $i (instance (alias outer 1 $rt (type $r)) (export \"v\" (value (type $r))))) (import \"i\" (instance (type $i))) (alias export 0 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "r", "type", "record", "1", "x", "scalar", "u32", "i",
    "instance", "interface", "", "0", "1", "v", "value", "record", "1", "x", "scalar",
    "u32", "1", "v", "value", "record", "1", "x", "scalar", "u32", "instance", "interface",
    "", "0", "1", "v", "value", "record", "1", "x", "scalar", "u32", "definitions",
    "0",
  ])
}

///|
test "value extern outer-unnamed-record-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x02\x72\x01\x01\x78\x79\x42\x02\x02\x03\x02\x01\x00\x04\x00\x01\x76\x02\x00\x0a\x06\x01\x00\x01\x69\x05\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (record (field \"x\" u32))) (type $i (instance (alias outer 1 $r (type $r)) (export \"v\" (value (type $r))))) (import \"i\" (instance (type $i))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern nested-outer-record-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x24\x01\x42\x04\x01\x72\x01\x01\x78\x79\x04\x00\x01\x72\x03\x00\x00\x01\x42\x02\x02\x03\x02\x01\x01\x04\x00\x01\x76\x02\x00\x04\x00\x01\x6a\x05\x02\x0a\x06\x01\x00\x01\x69\x05\x00\x06\x0b\x02\x05\x00\x00\x01\x6a\x02\x00\x01\x01\x76\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x69",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "r", "type",
      "record", "1", "x", "scalar", "u32", "j", "instance", "interface", "", "0",
      "1", "v", "value", "record", "1", "x", "scalar", "u32", "1", "v", "value",
      "record", "1", "x", "scalar", "u32", "instance", "interface", "", "0", "1",
      "v", "value", "record", "1", "x", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $i (instance (type $r (record (field \"x\" u32))) (export \"r\" (type $rt (eq $r))) (type $j (instance (alias outer 1 $rt (type $r)) (export \"v\" (value (type $r))))) (export \"j\" (instance (type $j))))) (import \"i\" (instance (type $i))) (alias export 0 \"j\" (instance)) (alias export 1 \"v\" (value)) (export \"v\" (value 0)))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "1", "i", "instance", "interface", "", "0", "2", "r", "type",
    "record", "1", "x", "scalar", "u32", "j", "instance", "interface", "", "0", "1",
    "v", "value", "record", "1", "x", "scalar", "u32", "1", "v", "value", "record",
    "1", "x", "scalar", "u32", "instance", "interface", "", "0", "1", "v", "value",
    "record", "1", "x", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern named-record-ascription" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x06\x01\x72\x01\x01\x78\x79\x0a\x0c\x02\x00\x01\x61\x03\x00\x00\x00\x01\x76\x02\x01\x07\x06\x01\x72\x01\x01\x78\x79\x0b\x0f\x02\x00\x01\x62\x03\x02\x00\x00\x01\x76\x02\x00\x01\x02\x03\x00\x1d\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x03\x03\x00\x01\x61\x01\x02\x61\x74\x02\x01\x62",
    )
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "a", "type", "record", "1", "x", "scalar", "u32", "v",
      "value", "record", "1", "x", "scalar", "u32", "2", "b", "type", "record", "1",
      "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar", "u32", "instance",
      "interface", "", "0", "2", "b", "type", "record", "1", "x", "scalar", "u32",
      "v", "value", "record", "1", "x", "scalar", "u32", "definitions", "0",
    ])
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $a (record (field \"x\" u32))) (import \"a\" (type $at (eq $a))) (import \"v\" (value (type $at))) (type $b (record (field \"x\" u32))) (export \"b\" (type $b)) (export \"v\" (value 0) (value (type 3))))\n",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(binary_projection(result.unwrap()), [
    "world", "", "0", "2", "a", "type", "record", "1", "x", "scalar", "u32", "v",
    "value", "record", "1", "x", "scalar", "u32", "2", "b", "type", "record", "1",
    "x", "scalar", "u32", "v", "value", "record", "1", "x", "scalar", "u32", "instance",
    "interface", "", "0", "2", "b", "type", "record", "1", "x", "scalar", "u32",
    "v", "value", "record", "1", "x", "scalar", "u32", "definitions", "0",
  ])
}

///|
test "value extern distinct-resource-ascription" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x02\x00\x01\x72\x03\x01\x00\x01\x73\x03\x01\x07\x05\x02\x69\x00\x69\x01\x0a\x06\x01\x00\x01\x76\x02\x02\x0b\x09\x01\x00\x01\x76\x02\x00\x01\x02\x03\x00\x1f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0e\x03\x04\x00\x01\x72\x01\x01\x73\x02\x01\x61\x03\x01\x62",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (import \"r\" (type $r (sub resource))) (import \"s\" (type $s (sub resource))) (type $a (own $r)) (type $b (own $s)) (import \"v\" (value (type $a))) (export \"v\" (value 0) (value (type $b))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}

///|
test "value extern component-local-resource-value" {
  {
    let result = @verifier.decode_component_package(
      b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x02\x3f\x7f\x00\x41\x03\x02\x03\x02\x01\x00\x01\x69\x00\x03\x00\x01\x76\x02\x01\x0a\x06\x01\x00\x01\x63\x04\x01\x00\x19\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x08\x03\x02\x00\x01\x72\x01\x01\x63",
    )
    assert_eq(
      result is Ok(_),
      false,
      msg=match result {
        Ok(_) => "accepted"
        Err(e) => e[0].render()
      },
    )
    assert_eq(result.unwrap_err()[0].code, "WAC-B003")
  }
  let result = @verifier.decode_wat_component_package(
    "(component (type $r (resource (rep i32))) (type $c (component (alias outer 1 $r (type $r)) (type $o (own $r)) (import \"v\" (value (type $o))))) (import \"c\" (component (type $c))))\n",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-B003")
}
