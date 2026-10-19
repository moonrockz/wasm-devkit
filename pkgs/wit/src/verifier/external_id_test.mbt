///|
// Expected metadata is projected from pinned Resolve source and binary models.
test "external IDs agree across source binary and WAT" {
  for
    (name, source, wat, bytes, expected) in [
      (
        "duplicate-include",
        "package test:ids; world base{import f:func();}world app{@external-id(\"urn:a\") @external-id(\"urn:b\") include base;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;) (func))\n          (import \"f\" (func (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/base\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;) (func))\n          (import \"f\" (func (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x01\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x62\x61\x73\x65\x04\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x00\x00\x07\x22\x01\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([]),
      ),
      (
        "duplicate-interface",
        "package test:ids; @external-id(\"urn:a\") @external-id(\"urn:b\") interface api{}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance)\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x01\x42\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([]),
      ),
      (
        "duplicate-world",
        "package test:ids; @external-id(\"urn:a\") @external-id(\"urn:b\") world app{}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component)\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x01\x41\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([]),
      ),
      (
        "empty",
        "package test:ids;interface api{@external-id(\"\") type t=u32;@external-id(\"\") f:func();}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) u32)\n          (export (;1;) \"t\" (external-id \"\") (type (eq 0)))\n          (type (;2;) (func))\n          (export (;0;) \"f\" (external-id \"\") (func (type 2)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x31\x01\x41\x02\x01\x42\x04\x01\x79\x04\x02\x01\x74\x01\x02\x00\x03\x00\x00\x01\x40\x00\x01\x00\x04\x02\x01\x66\x01\x02\x00\x01\x02\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([
          ("type/interface/test:ids/api/t", ""),
          ("function/interface/test:ids/api/f", ""),
        ]),
      ),
      (
        "escapes",
        "package test:ids; interface api{@external-id(\"a\\n\\t\\r\\\"\\27\\\\\\u{1f600}\\c3\\a9\") type t=u32;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) u32)\n          (export (;1;) \"t\" (external-id \"a\\u{a}\\u{9}\\u{d}\\u{22}'\\u{5c}\\u{1f600}\\u{e9}\") (type (eq 0)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x30\x01\x41\x02\x01\x42\x02\x01\x79\x04\x02\x01\x74\x01\x02\x0d\x61\x0a\x09\x0d\x22\x27\x5c\xf0\x9f\x98\x80\xc3\xa9\x03\x00\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([("type/interface/test:ids/api/t", "a\n\t\r\"'\\😀é")]),
      ),
      (
        "function",
        "package test:ids; interface api{@external-id(\"urn:a\") f:func();}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) (func))\n          (export (;0;) \"f\" (external-id \"urn:a\") (func (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2a\x01\x41\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x02\x01\x66\x01\x02\x05\x75\x72\x6e\x3a\x61\x01\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([("function/interface/test:ids/api/f", "urn:a")]),
      ),
      (
        "include",
        "package test:ids; world base{import f:func();}world app{@external-id(\"urn:a\") include base;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;) (func))\n          (import \"f\" (func (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/base\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;) (func))\n          (import \"f\" (func (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x23\x01\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x62\x61\x73\x65\x04\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x00\x00\x07\x22\x01\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([]),
      ),
      (
        "interface",
        "package test:ids; @external-id(\"urn:a\") interface api{}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance)\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x01\x42\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([]),
      ),
      (
        "methods",
        "package test:ids;interface api{@external-id(\"resource\") resource r{@external-id(\"ctor\") constructor();@external-id(\"method\") f:async func(x:u32);@external-id(\"static\") make:static func()->r;@external-id(\"getter\") position:get()->u32;@external-id(\"setter\") position:set(value:u32);} @external-id(\"free\") ready:func();} world base{@external-id(\"instance\") import api;@external-id(\"world-fn\") import run:func();}world app{include base;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"resource\") (type (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (export (;0;) \"[constructor]r\" (external-id \"ctor\") (func (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func async (param \"self\" 3) (param \"x\" u32)))\n          (export (;1;) \"[method]r.f\" (external-id \"method\") (func (type 4)))\n          (export (;2;) \"[static]r.make\" (external-id \"static\") (func (type 2)))\n          (type (;5;) (func (param \"self\" 3) (result u32)))\n          (export (;3;) \"[method][get]r.position\" (external-id \"getter\") (func (type 5)))\n          (type (;6;) (func (param \"self\" 3) (param \"value\" u32)))\n          (export (;4;) \"[method][set]r.position\" (external-id \"setter\") (func (type 6)))\n          (type (;7;) (func))\n          (export (;5;) \"ready\" (external-id \"free\") (func (type 7)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (external-id \"resource\") (type (sub resource)))\n              (type (;1;) (own 0))\n              (type (;2;) (func (result 1)))\n              (export (;0;) \"[constructor]r\" (external-id \"ctor\") (func (type 2)))\n              (type (;3;) (borrow 0))\n              (type (;4;) (func async (param \"self\" 3) (param \"x\" u32)))\n              (export (;1;) \"[method]r.f\" (external-id \"method\") (func (type 4)))\n              (export (;2;) \"[static]r.make\" (external-id \"static\") (func (type 2)))\n              (type (;5;) (func (param \"self\" 3) (result u32)))\n              (export (;3;) \"[method][get]r.position\" (external-id \"getter\") (func (type 5)))\n              (type (;6;) (func (param \"self\" 3) (param \"value\" u32)))\n              (export (;4;) \"[method][set]r.position\" (external-id \"setter\") (func (type 6)))\n              (type (;7;) (func))\n              (export (;5;) \"ready\" (external-id \"free\") (func (type 7)))\n            )\n          )\n          (import \"test:ids/api\" (external-id \"instance\") (instance (;0;) (type 0)))\n          (type (;1;) (func))\n          (import \"run\" (external-id \"world-fn\") (func (;0;) (type 1)))\n        )\n      )\n      (export (;0;) \"test:ids/base\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"base\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (external-id \"resource\") (type (sub resource)))\n              (type (;1;) (own 0))\n              (type (;2;) (func (result 1)))\n              (export (;0;) \"[constructor]r\" (external-id \"ctor\") (func (type 2)))\n              (type (;3;) (borrow 0))\n              (type (;4;) (func async (param \"self\" 3) (param \"x\" u32)))\n              (export (;1;) \"[method]r.f\" (external-id \"method\") (func (type 4)))\n              (export (;2;) \"[static]r.make\" (external-id \"static\") (func (type 2)))\n              (type (;5;) (func (param \"self\" 3) (result u32)))\n              (export (;3;) \"[method][get]r.position\" (external-id \"getter\") (func (type 5)))\n              (type (;6;) (func (param \"self\" 3) (param \"value\" u32)))\n              (export (;4;) \"[method][set]r.position\" (external-id \"setter\") (func (type 6)))\n              (type (;7;) (func))\n              (export (;5;) \"ready\" (external-id \"free\") (func (type 7)))\n            )\n          )\n          (import \"test:ids/api\" (external-id \"instance\") (instance (;0;) (type 0)))\n          (type (;1;) (func))\n          (import \"run\" (external-id \"world-fn\") (func (;0;) (type 1)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x8d\x02\x01\x41\x02\x01\x42\x0e\x04\x02\x01\x72\x01\x02\x08\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x02\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x04\x63\x74\x6f\x72\x01\x02\x01\x68\x00\x01\x43\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x79\x01\x00\x04\x02\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x02\x06\x6d\x65\x74\x68\x6f\x64\x01\x04\x04\x02\x0e\x5b\x73\x74\x61\x74\x69\x63\x5d\x72\x2e\x6d\x61\x6b\x65\x01\x02\x06\x73\x74\x61\x74\x69\x63\x01\x02\x01\x40\x01\x04\x73\x65\x6c\x66\x03\x00\x79\x04\x02\x17\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x67\x65\x74\x5d\x72\x2e\x70\x6f\x73\x69\x74\x69\x6f\x6e\x01\x02\x06\x67\x65\x74\x74\x65\x72\x01\x05\x01\x40\x02\x04\x73\x65\x6c\x66\x03\x05\x76\x61\x6c\x75\x65\x79\x01\x00\x04\x02\x17\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x73\x65\x74\x5d\x72\x2e\x70\x6f\x73\x69\x74\x69\x6f\x6e\x01\x02\x06\x73\x65\x74\x74\x65\x72\x01\x06\x01\x40\x00\x01\x00\x04\x02\x05\x72\x65\x61\x64\x79\x01\x02\x04\x66\x72\x65\x65\x01\x07\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xc5\x02\x01\x41\x02\x01\x41\x04\x01\x42\x0e\x04\x02\x01\x72\x01\x02\x08\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x02\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x04\x63\x74\x6f\x72\x01\x02\x01\x68\x00\x01\x43\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x79\x01\x00\x04\x02\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x02\x06\x6d\x65\x74\x68\x6f\x64\x01\x04\x04\x02\x0e\x5b\x73\x74\x61\x74\x69\x63\x5d\x72\x2e\x6d\x61\x6b\x65\x01\x02\x06\x73\x74\x61\x74\x69\x63\x01\x02\x01\x40\x01\x04\x73\x65\x6c\x66\x03\x00\x79\x04\x02\x17\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x67\x65\x74\x5d\x72\x2e\x70\x6f\x73\x69\x74\x69\x6f\x6e\x01\x02\x06\x67\x65\x74\x74\x65\x72\x01\x05\x01\x40\x02\x04\x73\x65\x6c\x66\x03\x05\x76\x61\x6c\x75\x65\x79\x01\x00\x04\x02\x17\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x73\x65\x74\x5d\x72\x2e\x70\x6f\x73\x69\x74\x69\x6f\x6e\x01\x02\x06\x73\x65\x74\x74\x65\x72\x01\x06\x01\x40\x00\x01\x00\x04\x02\x05\x72\x65\x61\x64\x79\x01\x02\x04\x66\x72\x65\x65\x01\x07\x03\x02\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x01\x02\x08\x69\x6e\x73\x74\x61\x6e\x63\x65\x05\x00\x01\x40\x00\x01\x00\x03\x02\x03\x72\x75\x6e\x01\x02\x08\x77\x6f\x72\x6c\x64\x2d\x66\x6e\x01\x01\x04\x00\x0d\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x62\x61\x73\x65\x04\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x02\x00\x07\xc4\x02\x01\x41\x02\x01\x41\x04\x01\x42\x0e\x04\x02\x01\x72\x01\x02\x08\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x02\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x04\x63\x74\x6f\x72\x01\x02\x01\x68\x00\x01\x43\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x79\x01\x00\x04\x02\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x02\x06\x6d\x65\x74\x68\x6f\x64\x01\x04\x04\x02\x0e\x5b\x73\x74\x61\x74\x69\x63\x5d\x72\x2e\x6d\x61\x6b\x65\x01\x02\x06\x73\x74\x61\x74\x69\x63\x01\x02\x01\x40\x01\x04\x73\x65\x6c\x66\x03\x00\x79\x04\x02\x17\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x67\x65\x74\x5d\x72\x2e\x70\x6f\x73\x69\x74\x69\x6f\x6e\x01\x02\x06\x67\x65\x74\x74\x65\x72\x01\x05\x01\x40\x02\x04\x73\x65\x6c\x66\x03\x05\x76\x61\x6c\x75\x65\x79\x01\x00\x04\x02\x17\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x73\x65\x74\x5d\x72\x2e\x70\x6f\x73\x69\x74\x69\x6f\x6e\x01\x02\x06\x73\x65\x74\x74\x65\x72\x01\x06\x01\x40\x00\x01\x00\x04\x02\x05\x72\x65\x61\x64\x79\x01\x02\x04\x66\x72\x65\x65\x01\x07\x03\x02\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x01\x02\x08\x69\x6e\x73\x74\x61\x6e\x63\x65\x05\x00\x01\x40\x00\x01\x00\x03\x02\x03\x72\x75\x6e\x01\x02\x08\x77\x6f\x72\x6c\x64\x2d\x66\x6e\x01\x01\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x04\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([
          ("type/interface/test:ids/api/r", "resource"),
          ("function/interface/test:ids/api/[constructor]r", "ctor"),
          ("function/interface/test:ids/api/[method][get]r.position", "getter"),
          ("function/interface/test:ids/api/[method][set]r.position", "setter"),
          ("function/interface/test:ids/api/[method]r.f", "method"),
          ("function/interface/test:ids/api/[static]r.make", "static"),
          ("function/interface/test:ids/api/ready", "free"),
          ("interface/world/test:ids/base/imports/test:ids/api", "instance"),
          ("function/world/test:ids/base/imports/run", "world-fn"),
          ("interface/world/test:ids/app/imports/test:ids/api", "instance"),
          ("function/world/test:ids/app/imports/run", "world-fn"),
        ]),
      ),
      (
        "named-path",
        "package test:ids;interface api{}world app{@external-id(\"first\") import one:api;@external-id(\"second\") import two:api;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance)\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance)\n          )\n          (import \"one\" (implements \"test:ids/api\") (external-id \"first\") (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance)\n          )\n          (import \"two\" (implements \"test:ids/api\") (external-id \"second\") (instance (;1;) (type 1)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x01\x42\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x5a\x01\x41\x02\x01\x41\x04\x01\x42\x00\x03\x02\x03\x6f\x6e\x65\x02\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x02\x05\x66\x69\x72\x73\x74\x05\x00\x01\x42\x00\x03\x02\x03\x74\x77\x6f\x02\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x02\x06\x73\x65\x63\x6f\x6e\x64\x05\x01\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([
          ("interface/world/test:ids/app/imports/one", "first"),
          ("interface/world/test:ids/app/imports/two", "second"),
        ]),
      ),
      (
        "resource",
        "package test:ids; interface api{@external-id(\"urn:a\") resource r;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"urn:a\") (type (sub resource)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x25\x01\x41\x02\x01\x42\x01\x04\x02\x01\x72\x01\x02\x05\x75\x72\x6e\x3a\x61\x03\x01\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([("type/interface/test:ids/api/r", "urn:a")]),
      ),
      (
        "underscores",
        "package test:ids; interface api{@external-id(\"\\u{1__f600}\") type t=u32;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) u32)\n          (export (;1;) \"t\" (external-id \"\\u{1f600}\") (type (eq 0)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x41\x02\x01\x42\x02\x01\x79\x04\x02\x01\x74\x01\x02\x04\xf0\x9f\x98\x80\x03\x00\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([("type/interface/test:ids/api/t", "😀")]),
      ),
      (
        "use",
        "package test:ids; interface a{resource r;type t=u32;} interface b{@external-id(\"urn:a\") use a.{r,t};}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"t\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"test:ids/a\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"a\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"t\" (type (eq 1)))\n        )\n      )\n      (import \"test:ids/a\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"t\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (external-id \"urn:a\") (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"t\" (external-id \"urn:a\") (type (eq 2)))\n        )\n      )\n      (export (;1;) \"test:ids/b\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"b\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x24\x01\x41\x02\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x74\x03\x00\x01\x04\x00\x0a\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x05\x00\x0b\x07\x01\x00\x01\x61\x03\x00\x00\x07\x6a\x01\x41\x06\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x74\x03\x00\x01\x03\x00\x0a\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x01\x74\x01\x42\x04\x02\x03\x02\x01\x01\x04\x02\x01\x72\x01\x02\x05\x75\x72\x6e\x3a\x61\x03\x00\x00\x02\x03\x02\x01\x02\x04\x02\x01\x74\x01\x02\x05\x75\x72\x6e\x3a\x61\x03\x00\x02\x04\x00\x0a\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x62\x05\x03\x0b\x07\x01\x00\x01\x62\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([
          ("type/interface/test:ids/b/r", "urn:a"),
          ("type/interface/test:ids/b/t", "urn:a"),
        ]),
      ),
      (
        "world-function",
        "package test:ids; world app{@external-id(\"urn:a\") import f:func();}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;) (func))\n          (import \"f\" (external-id \"urn:a\") (func (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2a\x01\x41\x02\x01\x41\x02\x01\x40\x00\x01\x00\x03\x02\x01\x66\x01\x02\x05\x75\x72\x6e\x3a\x61\x01\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([("function/world/test:ids/app/imports/f", "urn:a")]),
      ),
      (
        "world-inline",
        "package test:ids;world app{@external-id(\"inline\") import api:interface{@external-id(\"type\") type t=u32;@external-id(\"fn\") f:func(x:t);}}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"t\" (external-id \"type\") (type (eq 0)))\n              (type (;2;) (func (param \"x\" 1)))\n              (export (;0;) \"f\" (external-id \"fn\") (func (type 2)))\n            )\n          )\n          (import \"api\" (external-id \"inline\") (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4e\x01\x41\x02\x01\x41\x02\x01\x42\x04\x01\x79\x04\x02\x01\x74\x01\x02\x04\x74\x79\x70\x65\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x02\x01\x66\x01\x02\x02\x66\x6e\x01\x02\x03\x02\x03\x61\x70\x69\x01\x02\x06\x69\x6e\x6c\x69\x6e\x65\x05\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([
          ("type/interface/test:ids/inline/t", "type"),
          ("function/interface/test:ids/inline/f", "fn"),
          ("interface/world/test:ids/app/imports/api", "inline"),
        ]),
      ),
      (
        "world-interface",
        "package test:ids; interface api{} world app{@external-id(\"urn:a\") import api;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance)\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance)\n          )\n          (import \"test:ids/api\" (external-id \"urn:a\") (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x01\x42\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x33\x01\x41\x02\x01\x41\x02\x01\x42\x00\x03\x02\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x01\x02\x05\x75\x72\x6e\x3a\x61\x05\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([("interface/world/test:ids/app/imports/test:ids/api", "urn:a")]),
      ),
      (
        "world-types",
        "package test:ids;interface api{resource r;type t=u32;} world base{@external-id(\"alias\") use api.{r,t}; @external-id(\"owned\") resource local{@external-id(\"ctor\") constructor();@external-id(\"method\") f:func();}}world app{include base;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"t\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"t\" (type (eq 1)))\n            )\n          )\n          (import \"test:ids/api\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (import \"r\" (external-id \"alias\") (type (;2;) (eq 1)))\n          (alias export 0 \"t\" (type (;3;)))\n          (import \"t\" (external-id \"alias\") (type (;4;) (eq 3)))\n          (import \"local\" (external-id \"owned\") (type (;5;) (sub resource)))\n          (type (;6;) (own 5))\n          (type (;7;) (func (result 6)))\n          (import \"[constructor]local\" (external-id \"ctor\") (func (;0;) (type 7)))\n          (type (;8;) (borrow 5))\n          (type (;9;) (func (param \"self\" 8)))\n          (import \"[method]local.f\" (external-id \"method\") (func (;1;) (type 9)))\n        )\n      )\n      (export (;0;) \"test:ids/base\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"base\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"t\" (type (eq 1)))\n            )\n          )\n          (import \"test:ids/api\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (import \"r\" (external-id \"alias\") (type (;2;) (eq 1)))\n          (alias export 0 \"t\" (type (;3;)))\n          (import \"t\" (external-id \"alias\") (type (;4;) (eq 3)))\n          (import \"local\" (external-id \"owned\") (type (;5;) (sub resource)))\n          (type (;6;) (own 5))\n          (type (;7;) (func (result 6)))\n          (import \"[constructor]local\" (external-id \"ctor\") (func (;0;) (type 7)))\n          (type (;8;) (borrow 5))\n          (type (;9;) (func (param \"self\" 8)))\n          (import \"[method]local.f\" (external-id \"method\") (func (;1;) (type 9)))\n        )\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x26\x01\x41\x02\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x74\x03\x00\x01\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xc8\x01\x01\x41\x02\x01\x41\x0d\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x74\x03\x00\x01\x03\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x03\x02\x01\x72\x01\x02\x05\x61\x6c\x69\x61\x73\x03\x00\x01\x02\x03\x00\x00\x01\x74\x03\x02\x01\x74\x01\x02\x05\x61\x6c\x69\x61\x73\x03\x00\x03\x03\x02\x05\x6c\x6f\x63\x61\x6c\x01\x02\x05\x6f\x77\x6e\x65\x64\x03\x01\x01\x69\x05\x01\x40\x00\x00\x06\x03\x02\x12\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x6c\x6f\x63\x61\x6c\x01\x02\x04\x63\x74\x6f\x72\x01\x07\x01\x68\x05\x01\x40\x01\x04\x73\x65\x6c\x66\x08\x01\x00\x03\x02\x0f\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6c\x6f\x63\x61\x6c\x2e\x66\x01\x02\x06\x6d\x65\x74\x68\x6f\x64\x01\x09\x04\x00\x0d\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x62\x61\x73\x65\x04\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x02\x00\x07\xc7\x01\x01\x41\x02\x01\x41\x0d\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x74\x03\x00\x01\x03\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x03\x02\x01\x72\x01\x02\x05\x61\x6c\x69\x61\x73\x03\x00\x01\x02\x03\x00\x00\x01\x74\x03\x02\x01\x74\x01\x02\x05\x61\x6c\x69\x61\x73\x03\x00\x03\x03\x02\x05\x6c\x6f\x63\x61\x6c\x01\x02\x05\x6f\x77\x6e\x65\x64\x03\x01\x01\x69\x05\x01\x40\x00\x00\x06\x03\x02\x12\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x6c\x6f\x63\x61\x6c\x01\x02\x04\x63\x74\x6f\x72\x01\x07\x01\x68\x05\x01\x40\x01\x04\x73\x65\x6c\x66\x08\x01\x00\x03\x02\x0f\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6c\x6f\x63\x61\x6c\x2e\x66\x01\x02\x06\x6d\x65\x74\x68\x6f\x64\x01\x09\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x04\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([
          ("type/world/test:ids/base/r", "alias"),
          ("type/world/test:ids/base/t", "alias"),
          ("type/world/test:ids/base/local", "owned"),
          ("function/world/test:ids/base/imports/[constructor]local", "ctor"),
          ("function/world/test:ids/base/imports/[method]local.f", "method"),
          ("type/world/test:ids/app/r", "alias"),
          ("type/world/test:ids/app/t", "alias"),
          ("type/world/test:ids/app/local", "owned"),
          ("function/world/test:ids/app/imports/[constructor]local", "ctor"),
          ("function/world/test:ids/app/imports/[method]local.f", "method"),
        ]),
      ),
      (
        "world",
        "package test:ids; @external-id(\"urn:a\") world app{}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component)\n      )\n      (export (;0;) \"test:ids/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x17\x01\x41\x02\x01\x41\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x69\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        Map([]),
      ),
    ] {
    let source_model = @verifier.resolve({
      documents: [section_document(name + ".wit", source)],
    }).unwrap()
    assert_eq(external_id_projection(source_model), expected)
    for
      decoded in [
        @verifier.decode_package(bytes),
        @verifier.decode_wat_package(wat),
      ] {
      let input = decoded.unwrap()
      let model = @verifier.resolve_packages(Encoded(input)).unwrap()
      assert_eq(external_id_projection(model), expected)
      assert_eq(model.world_summary(), source_model.world_summary())
    }
  }
}

///|
fn external_id_projection(model : @verifier.Resolution) -> Map[String, String] {
  let types : Map[Int32, @verifier.ResolvedType] = Map([])
  let functions : Map[Int32, @verifier.ResolvedFunction] = Map([])
  let interfaces : Map[Int32, String] = Map([])
  let result : Map[String, String] = Map([])
  for ty in model.types() {
    types[ty.id] = ty
  }
  for function in model.functions() {
    functions[function.id] = function
  }
  for interface in model.interfaces() {
    let owner = encoded_alias_package(interface.package_identity) +
      "/" +
      interface.name.unwrap_or("inline")
    interfaces[interface.id] = owner
    for ty in interface.types {
      if types[ty.ty].external_id is Some(value) {
        result["type/interface/" + owner + "/" + ty.name] = value
      }
    }
    for function in interface.functions {
      if function.external_id is Some(value) {
        result["function/interface/" + owner + "/" + function.name] = value
      }
    }
  }
  for world in model.worlds() {
    let owner = encoded_alias_package(world.package_identity) + "/" + world.name
    for
      (direction, items) in [
        ("imports", world.imports),
        ("exports", world.exports),
      ] {
      for item in items {
        match item.kind {
          Type(id) =>
            if types[id].external_id is Some(value) {
              result["type/world/" + owner + "/" + item.name] = value
            }
          Function(id) =>
            if functions[id].external_id is Some(value) {
              result["function/world/" +
              owner +
              "/" +
              direction +
              "/" +
              item.name] = value
            }
          Interface(id) =>
            if item.external_id is Some(value) {
              result["interface/world/" +
              owner +
              "/" +
              direction +
              "/" +
              (if item.by_id { interfaces[id] } else { item.name })] = value
            }
        }
      }
    }
  }
  result
}

///|
test "external ID merge precedence follows caller order and preserves None" {
  let wat = "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"projected\") (type (sub resource)))\n        )\n      )\n      (import \"test:dep/base\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (external-id \"alias\") (type (eq 0)))\n          (type (;2;) (borrow 1))\n          (type (;3;) (func (param \"x\" 2)))\n          (export (;0;) \"f\" (func (type 3)))\n        )\n      )\n      (export (;1;) \"test:root/api\" (instance (type 2)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n"
  for
    (binary_id, source_id) in [
      (Some("projected"), Some("supplied")),
      (None, Some("supplied")),
      (Some("projected"), None),
    ] {
    let input = @verifier.decode_wat_package(
      if binary_id is Some(_) {
        wat
      } else {
        wat.replace(old="(external-id \"projected\")", new="")
      },
      source_id="input.wat",
    ).unwrap()
    let text = "package test:dep;interface base{" +
      (if source_id is Some(_) { "@external-id(\"supplied\") " } else { "" }) +
      "resource r;}"
    let supplied = @verifier.SourcePackage::{
      documents: [section_document("supplied.wit", text)],
    }
    for binary_first in [true, false] {
      let model = if binary_first {
        @verifier.resolve_packages(Encoded(input), dependencies=[
          Source(supplied),
        ]).unwrap()
      } else {
        @verifier.resolve_packages(Source(supplied), dependencies=[
          Encoded(input),
        ]).unwrap()
      }
      let base = model.interfaces().filter(info => info.name == Some("base"))[0]
      let resource = model.types().filter(ty => ty.id == base.types[0].ty)[0]
      assert_eq(
        resource.external_id,
        if binary_first {
          binary_id
        } else {
          source_id
        },
      )
      assert_eq(resource.location.source, "supplied.wit")
      assert_eq(
        model.origin(resource.id).unwrap().location.source,
        "supplied.wit",
      )
      assert_eq(model.sources()[0].text, text)
    }
  }
}

///|
test "external ID merge ignores independently disabled declarations" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (func))\n              (export (;0;) \"f\" (external-id \"projected-f\") (func (type 1)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="functions.wat",
  ).unwrap()
  let supplied = @verifier.SourcePackage::{
    documents: [
      section_document(
        "supplied.wit", "package test:dep;interface base{resource r;@unstable(feature=hidden) @external-id(\"source-f\") f:func();}",
      ),
    ],
  }
  for
    features in [
      @verifier.SemanticFeatures::default(),
      @verifier.SemanticFeatures::all(),
    ] {
    for binary_first in [false, true] {
      let model = if binary_first {
        @verifier.resolve_packages(
          Encoded(input),
          dependencies=[Source(supplied)],
          semantic_features=features,
        ).unwrap()
      } else {
        @verifier.resolve_packages(
          Source(supplied),
          dependencies=[Encoded(input)],
          semantic_features=features,
        ).unwrap()
      }
      let function = model.functions()[0]
      assert_eq(
        function.external_id,
        Some(
          if !binary_first && features.all_enabled {
            "source-f"
          } else {
            "projected-f"
          },
        ),
      )
    }
  }
}

///|
test "duplicate external IDs reject on retained declaration roles" {
  for
    text in [
      "package test:ids;world app{@external-id(\"a\") @external-id(\"b\") import f:func();}",
      "package test:ids;interface api{@external-id(\"a\") @external-id(\"b\") resource r;}",
      "package test:ids;interface api{}world app{@external-id(\"a\") @external-id(\"b\") import api;}",
      "package test:ids; interface api{@external-id(\"urn:a\") @external-id(\"urn:b\") type t=u32;}",
      "package test:ids; interface api{@external-id(\"urn:a\") @external-id(\"urn:b\") f:func();}",
      "package test:ids;interface api{resource r{@external-id(\"a\") @external-id(\"b\") constructor();}}",
      "package test:ids; interface a{type t=u32;} interface b{@external-id(\"urn:a\") @external-id(\"urn:b\") use a.{t};}",
    ] {
    let source = @verifier.SourcePackage::{
      documents: [section_document("duplicate.wit", text)],
    }
    assert_eq(@verifier.resolve(source).unwrap_err()[0].code, "WIT-S013")
  }
}

///|
test "external IDs on package wrapper exports have no declaration" {
  for
    wat in [
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"urn:a\") (type (sub resource)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (external-id \"outer\") (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"urn:a\") (type (sub resource)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (external-id \"wrapper\") (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    ] {
    let input = @verifier.decode_wat_package(wat).unwrap()
    let model = @verifier.resolve_packages(Encoded(input)).unwrap()
    assert_eq(
      external_id_projection(model),
      Map([("type/interface/test:ids/api/r", "urn:a")]),
    )
    let binary = @verifier.decode_package(input.bytes()).unwrap()
    assert_eq(
      external_id_projection(
        @verifier.resolve_packages(Encoded(binary)).unwrap(),
      ),
      external_id_projection(model),
    )
  }
}

///|
test "external ID WAT attributes reject duplicates and invalid UTF8" {
  for
    wat in [
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"a\") (external-id \"b\") (type (sub resource)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (external-id \"\\ff\") (type (sub resource)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    ] {
    assert_true(@verifier.decode_wat_package(wat) is Err(_))
  }
}

///|
test "equal external IDs preserve distinct resource identities" {
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "distinct.wit", "package test:ids;interface api{@external-id(\"same\") resource first;@external-id(\"same\") resource second;f:func(a:borrow<first>,b:borrow<second>);}",
      ),
    ],
  }
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"first\" (external-id \"same\") (type (sub resource)))\n          (export (;1;) \"second\" (external-id \"same\") (type (sub resource)))\n          (type (;2;) (borrow 0))\n          (type (;3;) (borrow 1))\n          (type (;4;) (func (param \"a\" 2) (param \"b\" 3)))\n          (export (;0;) \"f\" (func (type 4)))\n        )\n      )\n      (export (;0;) \"test:ids/api\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
  ).unwrap()
  for
    model in [
      @verifier.resolve(source).unwrap(),
      @verifier.resolve_packages(Encoded(input)).unwrap(),
    ] {
    let resources = model.types().filter(ty => ty.external_id == Some("same"))
    assert_eq(resources.length(), 2)
    assert_true(resources[0].id != resources[1].id)
  }
}
