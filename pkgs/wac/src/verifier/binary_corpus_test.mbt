// Original WAC dependency encodings. Sources, licenses, revision and exclusions:
// pkgs/wit/src/binary/fixtures/wac/README.md.
// Ordered graph expectations from pinned WAC 0.12.0 Package::from_bytes.

///|
test "package corpus fail/duplicate-inst-args/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x08\x01\x00\x03\x66\x6f\x6f\x01\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (import \"foo\" (func))\n)",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "foo", "func", "function", "false", "0", "none", "0",
      "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/expected-result-scalar/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result string)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "scalar", "string", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/export-needs-with/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(b"\x00\x61\x73\x6d\x0d\x00\x01\x00"),
      @verifier.decode_wat_component_package("(component)"),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/fill-not-last/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(b"\x00\x61\x73\x6d\x0d\x00\x01\x00"),
      @verifier.decode_wat_component_package("(component)\n"),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/func-results-not-present/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result string)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "scalar", "string", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/func-results-present/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "none", "0", "instance", "interface", "", "0", "0",
      "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-async/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x43\x00\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (func async (result string)))\n    (export \"f\" (func (type 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "true", "0", "some", "scalar", "string", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-enum-cases/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6d\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x65\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (enum \"a\" \"b\" \"c\"))\n    (export \"e\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "e", "type",
      "enum", "3", "a", "b", "c", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-enum-count/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6d\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x65\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (enum \"a\" \"b\" \"c\"))\n    (export \"e\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "e", "type",
      "enum", "3", "a", "b", "c", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-err-result-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x00\x01\x7d\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result (result (error u8)))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "result", "none", "some", "scalar", "u8",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-flags/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6e\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x66\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (flags \"a\" \"b\" \"c\"))\n    (export \"f\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "type",
      "flags", "3", "a", "b", "c", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-flags-count/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6e\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x66\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (flags \"a\" \"b\" \"c\"))\n    (export \"f\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "type",
      "flags", "3", "a", "b", "c", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-func-param-name/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x61\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (param \"a\" u32)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "1", "a", "scalar", "u32", "none", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-func-param-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"r\" (type (sub resource)))\n    (type $own-r (borrow 0))\n    (export \"f\" (func (param \"r\" $own-r)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "2", "r", "type",
      "resource", "0", "f", "func", "function", "false", "1", "r", "borrow", "0",
      "none", "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-func-params/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (param \"x\" u32)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "1", "x", "scalar", "u32", "none", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-func-scalar-result/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x7d\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result u8)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "scalar", "u8", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-kind/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x78\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"x\" (func))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "x", "func",
      "function", "false", "0", "none", "0", "instance", "interface", "", "0", "0",
      "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-list-element/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x70\x7d\x01\x40\x01\x01\x6c\x00\x01\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (param \"l\" (list u8))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "1", "l", "list", "scalar", "u8", "none", "0", "instance",
      "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-ok-result-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x01\x7d\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result (result u8))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "result", "some", "scalar", "u8", "none",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-option/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x6b\x73\x01\x40\x01\x01\x6f\x00\x01\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (param \"o\" (option string))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "1", "o", "option", "scalar", "string", "none", "0", "instance",
      "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-record-field-count/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x02\x01\x72\x03\x01\x61\x7d\x01\x62\x7b\x01\x63\x79\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (record (field \"a\" u8) (field \"b\" u16) (field \"c\" u32)))\n    (export \"r\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "r", "type",
      "record", "3", "a", "scalar", "u8", "b", "scalar", "u16", "c", "scalar", "u32",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-record-field-name/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x02\x01\x72\x03\x01\x61\x7d\x01\x62\x7b\x01\x63\x79\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (record (field \"a\" u8) (field \"b\" u16) (field \"c\" u32)))\n    (export \"r\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "r", "type",
      "record", "3", "a", "scalar", "u8", "b", "scalar", "u16", "c", "scalar", "u32",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-record-field-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x02\x01\x72\x03\x01\x61\x7d\x01\x62\x7b\x01\x63\x79\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type (record (field \"a\" u8) (field \"b\" u16) (field \"c\" u32)))\n    (export \"r\" (type (eq 0)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "r", "type",
      "record", "3", "a", "scalar", "u8", "b", "scalar", "u16", "c", "scalar", "u32",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-resource-types/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x05\x04\x00\x01\x78\x03\x01\x04\x00\x01\x79\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"x\" (type (sub resource)))\n    (export \"y\" (type (sub resource)))\n    (type $own-x (own 0))\n    (export \"f\" (func (param \"x\" $own-x)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "3", "x", "type",
      "resource", "0", "y", "type", "resource", "1", "f", "func", "function", "false",
      "1", "x", "own", "0", "none", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-tuple-size/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x6f\x01\x79\x01\x6f\x03\x7d\x73\x00\x04\x00\x01\x74\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $t (tuple u8 string (tuple u32)))\n    (export \"t\" (type (eq $t)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "t", "type",
      "tuple", "3", "scalar", "u8", "scalar", "string", "tuple", "1", "scalar", "u32",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-tuple-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x6f\x01\x79\x01\x6f\x03\x7d\x73\x00\x04\x00\x01\x74\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $t (tuple u8 string (tuple u32)))\n    (export \"t\" (type (eq $t)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "t", "type",
      "tuple", "3", "scalar", "u8", "scalar", "string", "tuple", "1", "scalar", "u32",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-variant-case-count/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $v (variant (case \"a\") (case \"b\" u16) (case \"c\" (tuple string u16))))\n    (export \"v\" (type (eq $v)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "v", "type",
      "variant", "3", "a", "none", "b", "some", "scalar", "u16", "c", "some", "tuple",
      "2", "scalar", "string", "scalar", "u16", "0", "instance", "interface", "",
      "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-variant-case-name/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $v (variant (case \"a\") (case \"b\" u16) (case \"c\" (tuple string u16))))\n    (export \"v\" (type (eq $v)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "v", "type",
      "variant", "3", "a", "none", "b", "some", "scalar", "u16", "c", "some", "tuple",
      "2", "scalar", "string", "scalar", "u16", "0", "instance", "interface", "",
      "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/mismatched-variant-case-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $v (variant (case \"a\") (case \"b\" u16) (case \"c\" (tuple string u16))))\n    (export \"v\" (type (eq $v)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "v", "type",
      "variant", "3", "a", "none", "b", "some", "scalar", "u16", "c", "some", "tuple",
      "2", "scalar", "string", "scalar", "u16", "0", "instance", "interface", "",
      "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-constructor/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x32\x01\x42\x06\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x02\x01\x40\x00\x00\x01\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x03\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"r\" (type (sub resource)))\n    (type $own-r (own 0))\n    (export \"f\" (func (param \"r\" $own-r)))\n    (export \"[constructor]r\" (func (result $own-r)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "3", "r", "type",
      "resource", "0", "f", "func", "function", "false", "1", "r", "own", "0", "none",
      "[constructor]r", "func", "function", "false", "0", "some", "own", "0", "0",
      "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-err-result-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x00\x01\x73\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result (result (error string)))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "result", "none", "some", "scalar", "string",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-inst-arg/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x08\x01\x00\x03\x66\x6f\x6f\x01\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (import \"foo\" (func))\n)",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "foo", "func", "function", "false", "0", "none", "0",
      "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-interface-export/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "none", "0", "instance", "interface", "", "0", "0",
      "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-method/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x3a\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x68\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x03\x01\x40\x01\x04\x73\x65\x6c\x66\x02\x01\x00\x04\x00\x0d\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x6f\x6f\x01\x04\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"r\" (type (sub resource)))\n    (type $own-r (own 0))\n    (type $borrow-r (borrow 0))\n    (export \"f\" (func (param \"r\" $own-r)))\n    (export \"[method]r.foo\" (func (param \"self\" $borrow-r)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "3", "r", "type",
      "resource", "0", "f", "func", "function", "false", "1", "r", "own", "0", "none",
      "[method]r.foo", "func", "function", "false", "1", "self", "borrow", "0", "none",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-ok-result-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x01\x73\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result (result string))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "result", "some", "scalar", "string", "none",
      "0", "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-package-definition/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x08\x01\x00\x03\x66\x6f\x6f\x01\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (import \"foo\" (func))\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "foo", "func", "function", "false", "0", "none", "0",
      "instance", "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/missing-static-method/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x34\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x68\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x03\x01\x40\x00\x01\x00\x04\x00\x0d\x5b\x73\x74\x61\x74\x69\x63\x5d\x72\x2e\x66\x6f\x6f\x01\x04\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"r\" (type (sub resource)))\n    (type $own-r (own 0))\n    (type $borrow-r (borrow 0))\n    (export \"f\" (func (param \"r\" $own-r)))\n    (export \"[static]r.foo\" (func))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "3", "r", "type",
      "resource", "0", "f", "func", "function", "false", "1", "r", "own", "0", "none",
      "[static]r.foo", "func", "function", "false", "0", "none", "0", "instance",
      "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/no-err-result-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x42\x03\x01\x6a\x00\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result (result))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "result", "none", "none", "0", "instance",
      "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/no-import/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(b"\x00\x61\x73\x6d\x0d\x00\x01\x00"),
      @verifier.decode_wat_component_package("(component)\n"),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/no-ok-result-type/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x42\x03\x01\x6a\x00\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result (result))))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "f", "func",
      "function", "false", "0", "some", "result", "none", "none", "0", "instance",
      "interface", "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/non-instance-spread/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(b"\x00\x61\x73\x6d\x0d\x00\x01\x00"),
      @verifier.decode_wat_component_package("(component)\n"),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/spread-instantiation-no-match/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(b"\x00\x61\x73\x6d\x0d\x00\x01\x00"),
      @verifier.decode_wat_component_package("(component)\n"),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus fail/targets-interface-use/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x02\x01\x71\x01\x03\x66\x6f\x6f\x00\x00\x04\x00\x0a\x6d\x79\x2d\x76\x61\x72\x69\x61\x6e\x74\x03\x00\x00\x0a\x22\x01\x00\x1d\x74\x65\x73\x74\x3a\x63\x6f\x6d\x70\x2f\x69\x6e\x64\x69\x72\x65\x63\x74\x2d\x64\x65\x70\x65\x6e\x64\x65\x6e\x63\x79\x05\x00\x06\x0f\x01\x03\x00\x00\x0a\x6d\x79\x2d\x76\x61\x72\x69\x61\x6e\x74\x07\x25\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x0a\x6d\x79\x2d\x76\x61\x72\x69\x61\x6e\x74\x03\x00\x00\x01\x40\x00\x00\x01\x04\x00\x03\x66\x75\x6e\x01\x02\x0a\x20\x01\x00\x1b\x74\x65\x73\x74\x3a\x63\x6f\x6d\x70\x2f\x64\x69\x72\x65\x63\x74\x2d\x64\x65\x70\x65\x6e\x64\x65\x6e\x63\x79\x05\x02",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (type (;0;)\n    (instance\n      (type (;0;) (variant (case \"foo\")))\n      (export (;1;) \"my-variant\" (type (eq 0)))\n    )\n  )\n  (import \"test:comp/indirect-dependency\" (instance (;0;) (type 0)))\n  (alias export 0 \"my-variant\" (type (;1;)))\n  (type (;2;)\n    (instance\n      (alias outer 1 1 (type (;0;)))\n      (export (;1;) \"my-variant\" (type (eq 0)))\n      (type (;2;) (func (result 1)))\n      (export (;0;) \"fun\" (func (type 2)))\n    )\n  )\n  (import \"test:comp/direct-dependency\" (instance (;1;) (type 2)))\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "test:comp/indirect-dependency", "instance", "interface",
      "test:comp/indirect-dependency", "0", "1", "my-variant", "type", "variant",
      "1", "foo", "none", "test:comp/direct-dependency", "instance", "interface",
      "test:comp/direct-dependency", "1", "my-variant", "my-variant", "test:comp/indirect-dependency",
      "2", "my-variant", "type", "variant", "1", "foo", "none", "fun", "func", "function",
      "false", "0", "some", "variant", "1", "foo", "none", "0", "instance", "interface",
      "", "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/targets-world-use/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x01\x04\x00\x0e\x6f\x74\x68\x65\x72\x2d\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x01\x0a\x22\x01\x00\x1d\x74\x65\x73\x74\x3a\x63\x6f\x6d\x70\x2f\x69\x6e\x64\x69\x72\x65\x63\x74\x2d\x64\x65\x70\x65\x6e\x64\x65\x6e\x63\x79\x05\x00\x06\x13\x01\x03\x00\x00\x0e\x6f\x74\x68\x65\x72\x2d\x72\x65\x73\x6f\x75\x72\x63\x65\x0a\x11\x01\x00\x0b\x6d\x79\x2d\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x00\x01\x07\x07\x02\x69\x02\x40\x00\x00\x03\x0a\x0c\x01\x00\x07\x6d\x79\x2d\x66\x75\x6e\x63\x01\x04\x06\x13\x01\x03\x00\x00\x0e\x6f\x74\x68\x65\x72\x2d\x72\x65\x73\x6f\x75\x72\x63\x65",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (type (;0;)\n    (instance\n      (export (;0;) \"other-resource\" (type (sub resource)))\n    )\n  )\n  (import \"test:comp/indirect-dependency\" (instance (;0;) (type 0)))\n  (alias export 0 \"other-resource\" (type (;1;)))\n  (import \"my-resource\" (type (;2;) (eq 1)))\n  (type (;3;) (own 2))\n  (type (;4;) (func (result 3)))\n  (import \"my-func\" (func (;0;) (type 4)))\n  (alias export 0 \"other-resource\" (type (;5;)))\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "3", "test:comp/indirect-dependency", "instance", "interface",
      "test:comp/indirect-dependency", "0", "1", "other-resource", "type", "resource",
      "0", "my-resource", "type", "resource", "0", "my-func", "func", "function",
      "false", "0", "some", "own", "0", "0", "instance", "interface", "", "0", "0",
      "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/variant-case-typed/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $v (variant (case \"a\") (case \"b\" u16) (case \"c\" (tuple string u16))))\n    (export \"v\" (type (eq $v)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "v", "type",
      "variant", "3", "a", "none", "b", "some", "scalar", "u16", "c", "some", "tuple",
      "2", "scalar", "string", "scalar", "u16", "0", "instance", "interface", "",
      "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus fail/variant-case-untyped/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (instance (import \"x\")\n    (type $v (variant (case \"a\") (case \"b\" u16) (case \"c\" (tuple string u16))))\n    (export \"v\" (type (eq $v)))\n  )\n)\n",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "x", "instance", "interface", "", "0", "1", "v", "type",
      "variant", "3", "a", "none", "b", "some", "scalar", "u16", "c", "some", "tuple",
      "2", "scalar", "string", "scalar", "u16", "0", "instance", "interface", "",
      "0", "0", "definitions", "0",
    ])
  }
}

///|
test "package corpus let-statements/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xb8\x02\x01\x42\x10\x04\x00\x0d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x03\x01\x01\x69\x00\x01\x6d\x02\x15\x6c\x61\x73\x74\x2d\x6f\x70\x65\x72\x61\x74\x69\x6f\x6e\x2d\x66\x61\x69\x6c\x65\x64\x06\x63\x6c\x6f\x73\x65\x64\x04\x00\x0b\x77\x72\x69\x74\x65\x2d\x65\x72\x72\x6f\x72\x03\x00\x02\x04\x00\x0c\x69\x6e\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x03\x01\x01\x68\x00\x01\x6a\x01\x77\x01\x03\x01\x40\x01\x04\x73\x65\x6c\x66\x05\x00\x06\x04\x00\x21\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x63\x68\x65\x63\x6b\x2d\x77\x72\x69\x74\x65\x01\x07\x01\x70\x7d\x01\x6a\x00\x01\x03\x01\x40\x02\x04\x73\x65\x6c\x66\x05\x08\x63\x6f\x6e\x74\x65\x6e\x74\x73\x08\x00\x09\x04\x00\x1b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x77\x72\x69\x74\x65\x01\x0a\x04\x00\x2e\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x62\x6c\x6f\x63\x6b\x69\x6e\x67\x2d\x77\x72\x69\x74\x65\x2d\x61\x6e\x64\x2d\x66\x6c\x75\x73\x68\x01\x0a\x01\x40\x01\x04\x73\x65\x6c\x66\x05\x00\x09\x04\x00\x24\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x62\x6c\x6f\x63\x6b\x69\x6e\x67\x2d\x66\x6c\x75\x73\x68\x01\x0b\x0a\x28\x01\x00\x23\x77\x61\x73\x69\x3a\x69\x6f\x2f\x73\x74\x72\x65\x61\x6d\x73\x40\x30\x2e\x32\x2e\x30\x2d\x72\x63\x2d\x32\x30\x32\x33\x2d\x31\x30\x2d\x31\x38\x05\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x16\x01\x00\x11\x66\x6f\x6f\x3a\x62\x61\x72\x2f\x62\x61\x7a\x40\x30\x2e\x31\x2e\x30\x05\x01\x0b\x17\x01\x00\x11\x66\x6f\x6f\x3a\x62\x61\x72\x2f\x62\x61\x7a\x40\x30\x2e\x31\x2e\x30\x05\x01\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (type\n    (instance\n      (export (;0;) \"output-stream\" (type (sub resource)))\n      (type (;2;) (own 0))\n      (type (;3;) (enum \"last-operation-failed\" \"closed\"))\n      (export (;4;) \"write-error\" (type (eq 2)))\n      (export (;5;) \"input-stream\" (type (sub resource)))\n      (type (;6;) (borrow 0))\n      (type (;7;) (result u64 (error 3)))\n      (type (;8;) (func (param \"self\" 5) (result 6)))\n      (export (;0;) \"[method]output-stream.check-write\" (func (type 7)))\n      (type (;9;) (list u8))\n      (type (;10;) (result (error 3)))\n      (type (;11;) (func (param \"self\" 5) (param \"contents\" 8) (result 9)))\n      (export (;1;) \"[method]output-stream.write\" (func (type 10)))\n      (export (;2;) \"[method]output-stream.blocking-write-and-flush\" (func (type 10)))\n      (type (;12;) (func (param \"self\" 5) (result 9)))\n      (export (;3;) \"[method]output-stream.blocking-flush\" (func (type 11)))\n    )\n  )\n  (import (interface \"wasi:io/streams@0.2.0-rc-2023-10-18\") (instance (type 0)))\n  (type\n    (instance\n      (export \"f\" (func))\n    )\n  )\n  (import (interface \"foo:bar/baz@0.1.0\") (instance (type 1)))\n  (export (interface \"foo:bar/baz@0.1.0\") (instance 1))\n)",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "2", "wasi:io/streams@0.2.0-rc-2023-10-18", "instance", "interface",
      "wasi:io/streams@0.2.0-rc-2023-10-18", "0", "7", "output-stream", "type", "resource",
      "0", "write-error", "type", "enum", "2", "last-operation-failed", "closed",
      "input-stream", "type", "resource", "1", "[method]output-stream.check-write",
      "func", "function", "false", "1", "self", "borrow", "0", "some", "result",
      "some", "scalar", "u64", "some", "enum", "2", "last-operation-failed", "closed",
      "[method]output-stream.write", "func", "function", "false", "2", "self", "borrow",
      "0", "contents", "list", "scalar", "u8", "some", "result", "none", "some",
      "enum", "2", "last-operation-failed", "closed", "[method]output-stream.blocking-write-and-flush",
      "func", "function", "false", "2", "self", "borrow", "0", "contents", "list",
      "scalar", "u8", "some", "result", "none", "some", "enum", "2", "last-operation-failed",
      "closed", "[method]output-stream.blocking-flush", "func", "function", "false",
      "1", "self", "borrow", "0", "some", "result", "none", "some", "enum", "2",
      "last-operation-failed", "closed", "foo:bar/baz@0.1.0", "instance", "interface",
      "foo:bar/baz@0.1.0", "0", "1", "f", "func", "function", "false", "0", "none",
      "1", "foo:bar/baz@0.1.0", "instance", "interface", "foo:bar/baz@0.1.0", "0",
      "1", "f", "func", "function", "false", "0", "none", "instance", "interface",
      "", "0", "1", "foo:bar/baz@0.1.0", "instance", "interface", "foo:bar/baz@0.1.0",
      "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "0",
    ])
  }
}

///|
test "package corpus no-imports/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(b"\x00\x61\x73\x6d\x0d\x00\x01\x00"),
      @verifier.decode_wat_component_package("(component)"),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
      "0",
    ])
  }
}

///|
test "package corpus targets-world/foo/bar.wat" {
  for
    result in [
      @verifier.decode_component_package(
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00",
      ),
      @verifier.decode_wat_component_package(
        "(component\n  (import \"f\" (func))\n  (export \"f\" (func 0))\n)",
      ),
    ] {
    assert_eq(
      result is Ok(_),
      true,
      msg=match result {
        Ok(_) => "accepted"
        Err(errors) => errors[0].message
      },
    )
    assert_eq(binary_projection(result.unwrap()), [
      "world", "", "0", "1", "f", "func", "function", "false", "0", "none", "1",
      "f", "func", "function", "false", "0", "none", "instance", "interface", "",
      "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "0",
    ])
  }
}
