///|
test "scoped encoded aliases preserve local interface and world identities" {
  for
    (name, wat, bytes, source) in [
      (
        "renamed", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:renamed/first@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"first\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n        )\n      )\n      (export (;0;) \"example:renamed/second@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;3;) \"second\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:renamed/first@1.0.0\" (instance (;0;) (type 0)))\n      (type (;1;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n        )\n      )\n      (import \"example:renamed/second@1.0.0\" (instance (;1;) (type 1)))\n      (alias export 0 \"same\" (type (;2;)))\n      (alias export 0 \"id\" (type (;3;)))\n      (alias export 1 \"same\" (type (;4;)))\n      (type (;5;)\n        (instance\n          (alias outer 1 2 (type (;0;)))\n          (export (;1;) \"left\" (type (eq 0)))\n          (alias outer 1 3 (type (;2;)))\n          (export (;3;) \"number\" (type (eq 2)))\n          (alias outer 1 4 (type (;4;)))\n          (export (;5;) \"right\" (type (eq 4)))\n          (export (;6;) \"twice\" (type (eq 3)))\n          (type (;7;) (borrow 1))\n          (type (;8;) (borrow 5))\n          (type (;9;) (func (param \"a\" 7) (param \"b\" 8) (result 6)))\n          (export (;0;) \"run\" (func (type 9)))\n        )\n      )\n      (export (;2;) \"example:renamed/aliases@1.0.0\" (instance (type 5)))\n    )\n  )\n  (export (;5;) \"aliases\" (type 4))\n  (type (;6;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"same\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:renamed/first@1.0.0\" (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance\n              (export (;0;) \"same\" (type (sub resource)))\n            )\n          )\n          (import \"example:renamed/second@1.0.0\" (instance (;1;) (type 1)))\n          (alias export 0 \"same\" (type (;2;)))\n          (alias export 0 \"id\" (type (;3;)))\n          (alias export 1 \"same\" (type (;4;)))\n          (type (;5;)\n            (instance\n              (alias outer 1 2 (type (;0;)))\n              (export (;1;) \"left\" (type (eq 0)))\n              (alias outer 1 3 (type (;2;)))\n              (export (;3;) \"number\" (type (eq 2)))\n              (alias outer 1 4 (type (;4;)))\n              (export (;5;) \"right\" (type (eq 4)))\n              (export (;6;) \"twice\" (type (eq 3)))\n              (type (;7;) (borrow 1))\n              (type (;8;) (borrow 5))\n              (type (;9;) (func (param \"a\" 7) (param \"b\" 8) (result 6)))\n              (export (;0;) \"run\" (func (type 9)))\n            )\n          )\n          (import \"example:renamed/aliases@1.0.0\" (instance (;2;) (type 5)))\n          (alias export 2 \"left\" (type (;6;)))\n          (import \"l\" (type (;7;) (eq 6)))\n          (alias export 2 \"right\" (type (;8;)))\n          (import \"r\" (type (;9;) (eq 8)))\n          (alias export 2 \"twice\" (type (;10;)))\n          (import \"twice\" (type (;11;) (eq 10)))\n          (type (;12;) (borrow 7))\n          (type (;13;) (borrow 9))\n          (type (;14;) (func (param \"a\" 12) (param \"b\" 13) (result 11)))\n          (export (;0;) \"out\" (func (type 14)))\n        )\n      )\n      (export (;0;) \"example:renamed/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;7;) \"app\" (type 6))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x39\x01\x41\x02\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x04\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0b\x01\x00\x05\x66\x69\x72\x73\x74\x03\x00\x00\x07\x30\x01\x41\x02\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x04\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0c\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x03\x02\x00\x07\xf8\x01\x01\x41\x09\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x01\x02\x03\x00\x00\x04\x73\x61\x6d\x65\x02\x03\x00\x00\x02\x69\x64\x02\x03\x00\x01\x04\x73\x61\x6d\x65\x01\x42\x0b\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x02\x02\x03\x02\x01\x04\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x04\x04\x00\x05\x74\x77\x69\x63\x65\x03\x00\x03\x01\x68\x01\x01\x68\x05\x01\x40\x02\x01\x61\x07\x01\x62\x08\x00\x06\x04\x00\x03\x72\x75\x6e\x01\x09\x04\x00\x1d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x6c\x69\x61\x73\x65\x73\x40\x31\x2e\x30\x2e\x30\x05\x05\x0b\x0d\x01\x00\x07\x61\x6c\x69\x61\x73\x65\x73\x03\x04\x00\x07\xe8\x02\x01\x41\x02\x01\x41\x13\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x01\x02\x03\x00\x00\x04\x73\x61\x6d\x65\x02\x03\x00\x00\x02\x69\x64\x02\x03\x00\x01\x04\x73\x61\x6d\x65\x01\x42\x0b\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x02\x02\x03\x02\x01\x04\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x04\x04\x00\x05\x74\x77\x69\x63\x65\x03\x00\x03\x01\x68\x01\x01\x68\x05\x01\x40\x02\x01\x61\x07\x01\x62\x08\x00\x06\x04\x00\x03\x72\x75\x6e\x01\x09\x03\x00\x1d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x6c\x69\x61\x73\x65\x73\x40\x31\x2e\x30\x2e\x30\x05\x05\x02\x03\x00\x02\x04\x6c\x65\x66\x74\x03\x00\x01\x6c\x03\x00\x06\x02\x03\x00\x02\x05\x72\x69\x67\x68\x74\x03\x00\x01\x72\x03\x00\x08\x02\x03\x00\x02\x05\x74\x77\x69\x63\x65\x03\x00\x05\x74\x77\x69\x63\x65\x03\x00\x0a\x01\x68\x07\x01\x68\x09\x01\x40\x02\x01\x61\x0c\x01\x62\x0d\x00\x0b\x04\x00\x03\x6f\x75\x74\x01\x0e\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x06\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        "package example:renamed@1.0.0;\ninterface first { resource same; type id=u32; }\ninterface second { resource same; }\ninterface aliases { use first.{same as left, id as number}; use second.{same as right}; type twice=number; run:func(a:borrow<left>, b:borrow<right>)->twice; }\nworld app { use aliases.{left as l, right as r, twice}; export out:func(a:borrow<l>, b:borrow<r>)->twice; }\n",
      ),
      (
        "subset", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n          (type (;3;) (func))\n          (export (;0;) \"unused\" (func (type 3)))\n        )\n      )\n      (export (;0;) \"example:subset/base\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:subset/base\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (type (;2;) (borrow 1))\n          (type (;3;) (func (param \"x\" 2)))\n          (export (;0;) \"run\" (func (type 3)))\n        )\n      )\n      (export (;1;) \"example:subset/api\" (instance (type 2)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n              (type (;3;) (func))\n              (export (;0;) \"unused\" (func (type 3)))\n            )\n          )\n          (import \"example:subset/base\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (type (;2;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (type (;2;) (borrow 1))\n              (type (;3;) (func (param \"x\" 2)))\n              (export (;0;) \"run\" (func (type 3)))\n            )\n          )\n          (import \"example:subset/api\" (instance (;1;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:subset/app\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x3e\x01\x41\x02\x01\x42\x05\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x01\x40\x00\x01\x00\x04\x00\x06\x75\x6e\x75\x73\x65\x64\x01\x03\x04\x00\x13\x65\x78\x61\x6d\x70\x6c\x65\x3a\x73\x75\x62\x73\x65\x74\x2f\x62\x61\x73\x65\x05\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x00\x00\x07\x6d\x01\x41\x05\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x13\x65\x78\x61\x6d\x70\x6c\x65\x3a\x73\x75\x62\x73\x65\x74\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x03\x72\x75\x6e\x01\x03\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x73\x75\x62\x73\x65\x74\x2f\x61\x70\x69\x05\x02\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x02\x00\x07\x97\x01\x01\x41\x02\x01\x41\x05\x01\x42\x05\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x01\x40\x00\x01\x00\x04\x00\x06\x75\x6e\x75\x73\x65\x64\x01\x03\x03\x00\x13\x65\x78\x61\x6d\x70\x6c\x65\x3a\x73\x75\x62\x73\x65\x74\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x03\x72\x75\x6e\x01\x03\x03\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x73\x75\x62\x73\x65\x74\x2f\x61\x70\x69\x05\x02\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x73\x75\x62\x73\x65\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x04\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        "package example:subset; interface base { resource r; type id=u32; unused:func(); } interface api { use base.{r}; run:func(x:borrow<r>); } world app { import api; }",
      ),
      (
        "chain", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"n\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:chain/base\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"n\" (type (eq 1)))\n        )\n      )\n      (import \"example:chain/base\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"n\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"n\" (type (eq 2)))\n          (export (;4;) \"next\" (type (eq 3)))\n        )\n      )\n      (export (;1;) \"example:chain/middle\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"middle\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"n\" (type (eq 1)))\n        )\n      )\n      (import \"example:chain/base\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"n\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"n\" (type (eq 2)))\n          (export (;4;) \"next\" (type (eq 3)))\n        )\n      )\n      (import \"example:chain/middle\" (instance (;1;) (type 3)))\n      (alias export 1 \"r\" (type (;4;)))\n      (alias export 1 \"next\" (type (;5;)))\n      (type (;6;)\n        (instance\n          (alias outer 1 4 (type (;0;)))\n          (export (;1;) \"renamed\" (type (eq 0)))\n          (alias outer 1 5 (type (;2;)))\n          (export (;3;) \"next\" (type (eq 2)))\n          (export (;4;) \"last\" (type (eq 3)))\n          (type (;5;) (borrow 1))\n          (type (;6;) (func (param \"x\" 5) (result 4)))\n          (export (;0;) \"run\" (func (type 6)))\n        )\n      )\n      (export (;2;) \"example:chain/last\" (instance (type 6)))\n    )\n  )\n  (export (;5;) \"last\" (type 4))\n  (type (;6;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"n\" (type (eq 1)))\n            )\n          )\n          (import \"example:chain/base\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"n\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"n\" (type (eq 2)))\n              (export (;4;) \"next\" (type (eq 3)))\n            )\n          )\n          (import \"example:chain/middle\" (instance (;1;) (type 3)))\n          (alias export 1 \"r\" (type (;4;)))\n          (alias export 1 \"next\" (type (;5;)))\n          (type (;6;)\n            (instance\n              (alias outer 1 4 (type (;0;)))\n              (export (;1;) \"renamed\" (type (eq 0)))\n              (alias outer 1 5 (type (;2;)))\n              (export (;3;) \"next\" (type (eq 2)))\n              (export (;4;) \"last\" (type (eq 3)))\n              (type (;5;) (borrow 1))\n              (type (;6;) (func (param \"x\" 5) (result 4)))\n              (export (;0;) \"run\" (func (type 6)))\n            )\n          )\n          (import \"example:chain/last\" (instance (;2;) (type 6)))\n        )\n      )\n      (export (;0;) \"example:chain/app\" (component (type 0)))\n    )\n  )\n  (export (;7;) \"app\" (type 6))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2c\x01\x41\x02\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x6e\x03\x00\x01\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x62\x61\x73\x65\x05\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x00\x00\x07\x76\x01\x41\x06\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x6e\x03\x00\x01\x03\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x01\x6e\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x01\x6e\x03\x00\x02\x04\x00\x04\x6e\x65\x78\x74\x03\x00\x03\x04\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x6d\x69\x64\x64\x6c\x65\x05\x03\x0b\x0c\x01\x00\x06\x6d\x69\x64\x64\x6c\x65\x03\x02\x00\x07\xdd\x01\x01\x41\x0a\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x6e\x03\x00\x01\x03\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x01\x6e\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x01\x6e\x03\x00\x02\x04\x00\x04\x6e\x65\x78\x74\x03\x00\x03\x03\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x6d\x69\x64\x64\x6c\x65\x05\x03\x02\x03\x00\x01\x01\x72\x02\x03\x00\x01\x04\x6e\x65\x78\x74\x01\x42\x08\x02\x03\x02\x01\x04\x04\x00\x07\x72\x65\x6e\x61\x6d\x65\x64\x03\x00\x00\x02\x03\x02\x01\x05\x04\x00\x04\x6e\x65\x78\x74\x03\x00\x02\x04\x00\x04\x6c\x61\x73\x74\x03\x00\x03\x01\x68\x01\x01\x40\x01\x01\x78\x05\x00\x04\x04\x00\x03\x72\x75\x6e\x01\x06\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x6c\x61\x73\x74\x05\x06\x0b\x0a\x01\x00\x04\x6c\x61\x73\x74\x03\x04\x00\x07\xf6\x01\x01\x41\x02\x01\x41\x0a\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x01\x6e\x03\x00\x01\x03\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x01\x6e\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x01\x6e\x03\x00\x02\x04\x00\x04\x6e\x65\x78\x74\x03\x00\x03\x03\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x6d\x69\x64\x64\x6c\x65\x05\x03\x02\x03\x00\x01\x01\x72\x02\x03\x00\x01\x04\x6e\x65\x78\x74\x01\x42\x08\x02\x03\x02\x01\x04\x04\x00\x07\x72\x65\x6e\x61\x6d\x65\x64\x03\x00\x00\x02\x03\x02\x01\x05\x04\x00\x04\x6e\x65\x78\x74\x03\x00\x02\x04\x00\x04\x6c\x61\x73\x74\x03\x00\x03\x01\x68\x01\x01\x40\x01\x01\x78\x05\x00\x04\x04\x00\x03\x72\x75\x6e\x01\x06\x03\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x6c\x61\x73\x74\x05\x06\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x06\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        "package example:chain; interface base { resource r; type n=u32; } interface middle { use base.{r,n}; type next=n; } interface last { use middle.{r as renamed,next}; type last=next; run:func(x:borrow<renamed>)->last; } world app { import last; }",
      ),
      (
        "local", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x35\x01\x41\x02\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x04\x00\x1a\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x6c\x69\x61\x73\x65\x73\x2f\x62\x61\x73\x65\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x00\x00\x07\x8f\x01\x01\x41\x06\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1a\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x6c\x69\x61\x73\x65\x73\x2f\x62\x61\x73\x65\x40\x31\x2e\x30\x2e\x30\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x00\x03\x04\x00\x03\x72\x75\x6e\x01\x05\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x6c\x69\x61\x73\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x03\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x02\x00\x07\xb0\x01\x01\x41\x02\x01\x41\x06\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1a\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x6c\x69\x61\x73\x65\x73\x2f\x62\x61\x73\x65\x40\x31\x2e\x30\x2e\x30\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x00\x03\x04\x00\x03\x72\x75\x6e\x01\x05\x03\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x6c\x69\x61\x73\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x03\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x6c\x69\x61\x73\x65\x73\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x04\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        "package example:aliases@1.0.0;interface base { resource r; type id = u32; }interface api { use base.{r,id}; run:func(x:borrow<r>)->id; }world app { import api; }",
      ),
      (
        "world-types", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:worldtypes/api@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:worldtypes/api@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (import \"r\" (type (;2;) (eq 1)))\n          (alias export 0 \"id\" (type (;3;)))\n          (import \"id\" (type (;4;) (eq 3)))\n          (type (;5;) (borrow 2))\n          (type (;6;) (func (param \"x\" 5) (result 4)))\n          (export (;0;) \"run\" (func (type 6)))\n        )\n      )\n      (export (;0;) \"example:worldtypes/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x37\x01\x41\x02\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x04\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x8a\x01\x01\x41\x02\x01\x41\x09\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x02\x03\x00\x00\x01\x72\x03\x00\x01\x72\x03\x00\x01\x02\x03\x00\x00\x02\x69\x64\x03\x00\x02\x69\x64\x03\x00\x03\x01\x68\x02\x01\x40\x01\x01\x78\x05\x00\x04\x04\x00\x03\x72\x75\x6e\x01\x06\x04\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x74\x79\x70\x65\x73\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
        "package example:worldtypes@1.0.0;interface api { resource r; type id=u32; }world app { use api.{r,id}; export run:func(x:borrow<r>)->id; }",
      ),
    ] {
    let input = match @verifier.decode_wat_package(wat) {
      Ok(input) => input
      Err(errors) => fail(name + ": " + errors[0].message)
    }
    let model = @verifier.resolve_packages(Encoded(input)).unwrap()
    let binary = @verifier.resolve_packages(
      Encoded(@verifier.decode_package(bytes).unwrap()),
    ).unwrap()
    assert_eq(encoded_alias_model(model), encoded_alias_model(binary), msg=name)
    let expected = @verifier.resolve({
      documents: [section_document("source.wit", source)],
    }).unwrap()
    assert_eq(model.world_summary(), expected.world_summary(), msg=name)
    assert_eq(model.types().length(), expected.types().length(), msg=name)
    assert_eq(
      encoded_alias_model(model),
      encoded_alias_model(expected),
      msg=name,
    )
  }
}

///|
fn encoded_alias_package(identity : @verifier.PackageIdentity) -> String {
  identity.namespace_name +
  ":" +
  identity.name +
  identity.version.map(v => "@" + v).unwrap_or("")
}

///|
// Compare named and anonymous type edges by their owning declaration and shape,
// never by source/decoder allocation indices.
fn encoded_alias_model(
  model : @verifier.Resolution,
  reachable_only~ : Bool = false,
) -> Map[String, String] {
  let labels : Map[Int32, String] = Map([])
  let functions : Map[Int32, String] = Map([])
  for interface_info in model.interfaces() {
    let owner = "interface/" +
      encoded_alias_package(interface_info.package_identity) +
      "/" +
      interface_info.name.unwrap()
    for function in interface_info.functions {
      functions[function.id] = owner + "/" + function.name
    }
    for ty in interface_info.types {
      labels[ty.ty] = owner + "/" + ty.name
    }
  }
  for world in model.worlds() {
    let owner = "world/" +
      encoded_alias_package(world.package_identity) +
      "/" +
      world.name
    for
      (direction, items) in [
        ("import", world.imports),
        ("export", world.exports),
      ] {
      for item in items {
        if item.kind is Function(id) {
          functions[id] = owner + "/" + direction + "/" + item.name
        }
      }
    }
    for item in world.imports {
      if item.kind is Type(id) {
        labels[id] = owner + "/" + item.name
      }
    }
  }
  let reachable : Map[Int32, Bool] = Map([])
  let kinds : Map[Int32, @verifier.TypeKind] = Map([])
  let work : Array[Int32] = []
  for ty in model.types() {
    kinds[ty.id] = ty.kind
    if labels.contains(ty.id) {
      work.push(ty.id)
    }
  }
  for function in model.functions() {
    for param in function.params {
      work.push(param.ty)
    }
    if function.result is Some(id) {
      work.push(id)
    }
  }
  while work.pop() is Some(id) {
    if reachable.contains(id) {
      continue
    }
    reachable[id] = true
    let edges : Array[Int32] = match kinds[id] {
      Own(id) | Borrow(id) | Alias(id) | List(id, _) | Option(id) => [id]
      Tuple(ids) => ids.iter().to_array()
      Result(a, b) => [a, b].filter_map(id => id)
      Future(id) | Stream(id) => [id].filter_map(id => id)
      Map(a, b) => [a, b]
      Record(fields) => fields.map(field => field.ty).iter().to_array()
      Variant(cases) => cases.iter().filter_map(case => case.payload).to_array()
      _ => []
    }
    work.append(edges)
  }
  let result : Map[String, String] = Map([])
  let pending = model.types().iter().to_array()
  while !pending.is_empty() {
    let before = pending.length()
    for index = pending.length() - 1; index >= 0; index = index - 1 {
      let ty = pending[index]
      if encoded_alias_shape(ty.kind, labels) is Some(shape) {
        let label = labels.get(ty.id).unwrap_or("anonymous/" + shape)
        labels[ty.id] = label
        if !reachable_only || reachable.contains(ty.id) {
          result[label] = shape
        }
        ignore(pending.remove(index))
      }
    }
    if pending.length() == before {
      abort("cyclic fixture type graph")
    }
  }

  for function in model.functions() {
    let kind = match function.kind {
      Freestanding => "free"
      Constructor(id) => "constructor/" + labels[id]
      Method(id) => "method/" + labels[id]
      Static(id) => "static/" + labels[id]
    }
    result["function/" + functions[function.id]] = kind +
      "/" +
      @debug.Repr(function.flavor).to_string() +
      "/" +
      function.asynchronous.to_string() +
      ":" +
      function.params
      .map(parameter => parameter.name + ":" + labels[parameter.ty])
      .join(",") +
      "->" +
      (match function.result {
        None => "none"
        Some(id) => labels[id]
      })
  }
  result
}

///|
test "encoded aliases enforce scope bounds and pinned local projection rules" {
  for
    (name, wat, accepted) in [
      (
        "primitive-projection", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) string)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        true,
      ),
      (
        "missing-type", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"absent\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"absent\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "bad-outer-depth", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 50 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "bad-outer-index", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 99 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "bad-instance-index", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 99 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "bad-instance-name", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"absent\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "resource-projection", "(component (type (component (type (instance (export \"r\" (type (sub resource))) (export \"s\" (type (sub resource))))) (export \"example:project/base\" (instance (type 0))))) (export \"base\" (type 0)) (type (component (type (instance (export \"r\" (type (sub resource))) (export \"s\" (type (eq 0))))) (import \"example:project/base\" (instance (type 0))) (alias export 0 \"r\" (type)) (alias export 0 \"s\" (type)) (type (instance (alias outer 1 1 (type)) (export \"r\" (type (eq 0))) (alias outer 1 2 (type)) (export \"s\" (type (eq 2))))) (export \"example:project/api\" (instance (type 3))))) (export \"api\" (type 2)))",
        true,
      ),
    ] {
    let result = @verifier.decode_wat_package(wat)
    assert_eq(result is Ok(_), accepted, msg=name)
    if result is Ok(input) {
      let model = @verifier.resolve_packages(Encoded(input)).unwrap()
      if name == "primitive-projection" {
        assert_eq(model.interfaces()[0].types.length(), 2)
        assert_eq(
          encoded_alias_model(model)["interface/example:aliases@1.0.0/base/id"],
          "alias anonymous/u32",
        )
      }
      if name == "resource-projection" {
        let graph = encoded_alias_model(model)
        assert_eq(
          graph["interface/example:project/api/r"],
          "alias interface/example:project/base/r",
        )
        assert_eq(
          graph["interface/example:project/api/s"],
          "alias interface/example:project/base/s",
        )
      }
    }
  }
}

///|
fn encoded_alias_shape(
  kind : @verifier.TypeKind,
  labels : Map[Int32, String],
) -> String? {
  let edges : Array[Int32] = match kind {
    Own(id) | Borrow(id) | Alias(id) | List(id, _) | Option(id) => [id]
    Tuple(ids) => ids.iter().to_array()
    Result(a, b) => [a, b].filter_map(id => id)
    Future(id) | Stream(id) => [id].filter_map(id => id)
    Map(a, b) => [a, b]
    Record(fields) => fields.map(field => field.ty).iter().to_array()
    Variant(cases) => cases.iter().filter_map(case => case.payload).to_array()
    _ => []
  }
  if edges.any(id => !labels.contains(id)) {
    return None
  }
  let optional = fn(id : Int32?) {
    match id {
      Some(id) => labels[id]
      None => "_"
    }
  }
  Some(
    match kind {
      Resource => "resource"
      Scalar(name) => name
      Alias(id) => "alias " + labels[id]
      Own(id) => "own " + labels[id]
      Borrow(id) => "borrow " + labels[id]
      List(id, length) =>
        "list " +
        labels[id] +
        ":" +
        (match length {
          None => "_"
          Some(length) => length.to_string()
        })
      Tuple(ids) => "tuple " + ids.map(id => labels[id]).join(",")
      Option(id) => "option " + labels[id]
      Result(a, b) => "result " + optional(a) + "," + optional(b)
      Future(id) => "future " + optional(id)
      Stream(id) => "stream " + optional(id)
      Map(a, b) => "map " + labels[a] + "," + labels[b]
      Record(fields) =>
        "record " +
        fields.map(field => field.name + ":" + labels[field.ty]).join(",")
      Variant(cases) =>
        "variant " +
        cases.map(case => case.name + ":" + optional(case.payload)).join(",")
      Flags(names) => "flags " + names.join(",")
      Enum(names) => "enum " + names.join(",")
    },
  )
}

///|
test "encoded aggregate projections preserve alias and anonymous type edges" {
  let source = "package example:aggregate; interface base { record item { values:list<u32>, id:u32 } variant selection { item(item), none } type pack=tuple<item,selection>; } interface api { use base.{item,selection,pack}; run:func(x:pack)->selection; } world app { import api; }"
  let wat = "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) (list u32))\n          (type (;1;) (record (field \"values\" 0) (field \"id\" u32)))\n          (export (;2;) \"item\" (type (eq 1)))\n          (type (;3;) (variant (case \"item\" 2) (case \"none\")))\n          (export (;4;) \"selection\" (type (eq 3)))\n          (type (;5;) (tuple 2 4))\n          (export (;6;) \"pack\" (type (eq 5)))\n        )\n      )\n      (export (;0;) \"example:aggregate/base\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) (list u32))\n          (type (;1;) (record (field \"values\" 0) (field \"id\" u32)))\n          (export (;2;) \"item\" (type (eq 1)))\n          (type (;3;) (variant (case \"item\" 2) (case \"none\")))\n          (export (;4;) \"selection\" (type (eq 3)))\n          (type (;5;) (tuple 2 4))\n          (export (;6;) \"pack\" (type (eq 5)))\n        )\n      )\n      (import \"example:aggregate/base\" (instance (;0;) (type 0)))\n      (alias export 0 \"item\" (type (;1;)))\n      (alias export 0 \"selection\" (type (;2;)))\n      (alias export 0 \"pack\" (type (;3;)))\n      (type (;4;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"item\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"selection\" (type (eq 2)))\n          (alias outer 1 3 (type (;4;)))\n          (export (;5;) \"pack\" (type (eq 4)))\n          (type (;6;) (func (param \"x\" 5) (result 3)))\n          (export (;0;) \"run\" (func (type 6)))\n        )\n      )\n      (export (;1;) \"example:aggregate/api\" (instance (type 4)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) (list u32))\n              (type (;1;) (record (field \"values\" 0) (field \"id\" u32)))\n              (export (;2;) \"item\" (type (eq 1)))\n              (type (;3;) (variant (case \"item\" 2) (case \"none\")))\n              (export (;4;) \"selection\" (type (eq 3)))\n              (type (;5;) (tuple 2 4))\n              (export (;6;) \"pack\" (type (eq 5)))\n            )\n          )\n          (import \"example:aggregate/base\" (instance (;0;) (type 0)))\n          (alias export 0 \"item\" (type (;1;)))\n          (alias export 0 \"selection\" (type (;2;)))\n          (alias export 0 \"pack\" (type (;3;)))\n          (type (;4;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"item\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"selection\" (type (eq 2)))\n              (alias outer 1 3 (type (;4;)))\n              (export (;5;) \"pack\" (type (eq 4)))\n              (type (;6;) (func (param \"x\" 5) (result 3)))\n              (export (;0;) \"run\" (func (type 6)))\n            )\n          )\n          (import \"example:aggregate/api\" (instance (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:aggregate/app\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x6d\x01\x41\x02\x01\x42\x07\x01\x70\x79\x01\x72\x02\x06\x76\x61\x6c\x75\x65\x73\x00\x02\x69\x64\x79\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x01\x01\x71\x02\x04\x69\x74\x65\x6d\x01\x02\x00\x04\x6e\x6f\x6e\x65\x00\x00\x04\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x03\x00\x03\x01\x6f\x02\x02\x04\x04\x00\x04\x70\x61\x63\x6b\x03\x00\x05\x04\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x2f\x62\x61\x73\x65\x05\x00\x0b\x0a\x01\x00\x04\x62\x61\x73\x65\x03\x00\x00\x07\xec\x01\x01\x41\x07\x01\x42\x07\x01\x70\x79\x01\x72\x02\x06\x76\x61\x6c\x75\x65\x73\x00\x02\x69\x64\x79\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x01\x01\x71\x02\x04\x69\x74\x65\x6d\x01\x02\x00\x04\x6e\x6f\x6e\x65\x00\x00\x04\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x03\x00\x03\x01\x6f\x02\x02\x04\x04\x00\x04\x70\x61\x63\x6b\x03\x00\x05\x03\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x04\x69\x74\x65\x6d\x02\x03\x00\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x02\x03\x00\x00\x04\x70\x61\x63\x6b\x01\x42\x08\x02\x03\x02\x01\x01\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x03\x00\x02\x02\x03\x02\x01\x03\x04\x00\x04\x70\x61\x63\x6b\x03\x00\x04\x01\x40\x01\x01\x78\x05\x00\x03\x04\x00\x03\x72\x75\x6e\x01\x06\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x2f\x61\x70\x69\x05\x04\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x02\x00\x07\x89\x02\x01\x41\x02\x01\x41\x07\x01\x42\x07\x01\x70\x79\x01\x72\x02\x06\x76\x61\x6c\x75\x65\x73\x00\x02\x69\x64\x79\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x01\x01\x71\x02\x04\x69\x74\x65\x6d\x01\x02\x00\x04\x6e\x6f\x6e\x65\x00\x00\x04\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x03\x00\x03\x01\x6f\x02\x02\x04\x04\x00\x04\x70\x61\x63\x6b\x03\x00\x05\x03\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x2f\x62\x61\x73\x65\x05\x00\x02\x03\x00\x00\x04\x69\x74\x65\x6d\x02\x03\x00\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x02\x03\x00\x00\x04\x70\x61\x63\x6b\x01\x42\x08\x02\x03\x02\x01\x01\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x09\x73\x65\x6c\x65\x63\x74\x69\x6f\x6e\x03\x00\x02\x02\x03\x02\x01\x03\x04\x00\x04\x70\x61\x63\x6b\x03\x00\x04\x01\x40\x01\x01\x78\x05\x00\x03\x04\x00\x03\x72\x75\x6e\x01\x06\x03\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x2f\x61\x70\x69\x05\x04\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x04\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"
  let expected = @verifier.resolve({
    documents: [section_document("source.wit", source)],
  }).unwrap()
  for
    input in [
      @verifier.decode_wat_package(wat).unwrap(),
      @verifier.decode_package(bytes).unwrap(),
    ] {
    let model = @verifier.resolve_packages(Encoded(input)).unwrap()
    assert_eq(model.world_summary(), expected.world_summary())
    assert_eq(model.types().length(), expected.types().length())
    assert_eq(encoded_alias_model(model), encoded_alias_model(expected))
  }
}

///|
test "encoded local aggregate projection checks ordered field names" {
  assert_true(
    @verifier.decode_wat_package(
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) (list u32))\n          (type (;1;) (record (field \"values\" 0) (field \"id\" u32)))\n          (export (;2;) \"item\" (type (eq 1)))\n          (type (;3;) (variant (case \"item\" 2) (case \"none\")))\n          (export (;4;) \"selection\" (type (eq 3)))\n          (type (;5;) (tuple 2 4))\n          (export (;6;) \"pack\" (type (eq 5)))\n        )\n      )\n      (export (;0;) \"example:aggregate/base\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) (list u32))\n          (type (;1;) (record (field \"different\" 0) (field \"id\" u32)))\n          (export (;2;) \"item\" (type (eq 1)))\n          (type (;3;) (variant (case \"item\" 2) (case \"none\")))\n          (export (;4;) \"selection\" (type (eq 3)))\n          (type (;5;) (tuple 2 4))\n          (export (;6;) \"pack\" (type (eq 5)))\n        )\n      )\n      (import \"example:aggregate/base\" (instance (;0;) (type 0)))\n      (alias export 0 \"item\" (type (;1;)))\n      (alias export 0 \"selection\" (type (;2;)))\n      (alias export 0 \"pack\" (type (;3;)))\n      (type (;4;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"item\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"selection\" (type (eq 2)))\n          (alias outer 1 3 (type (;4;)))\n          (export (;5;) \"pack\" (type (eq 4)))\n          (type (;6;) (func (param \"x\" 5) (result 3)))\n          (export (;0;) \"run\" (func (type 6)))\n        )\n      )\n      (export (;1;) \"example:aggregate/api\" (instance (type 4)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) (list u32))\n              (type (;1;) (record (field \"values\" 0) (field \"id\" u32)))\n              (export (;2;) \"item\" (type (eq 1)))\n              (type (;3;) (variant (case \"item\" 2) (case \"none\")))\n              (export (;4;) \"selection\" (type (eq 3)))\n              (type (;5;) (tuple 2 4))\n              (export (;6;) \"pack\" (type (eq 5)))\n            )\n          )\n          (import \"example:aggregate/base\" (instance (;0;) (type 0)))\n          (alias export 0 \"item\" (type (;1;)))\n          (alias export 0 \"selection\" (type (;2;)))\n          (alias export 0 \"pack\" (type (;3;)))\n          (type (;4;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"item\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"selection\" (type (eq 2)))\n              (alias outer 1 3 (type (;4;)))\n              (export (;5;) \"pack\" (type (eq 4)))\n              (type (;6;) (func (param \"x\" 5) (result 3)))\n              (export (;0;) \"run\" (func (type 6)))\n            )\n          )\n          (import \"example:aggregate/api\" (instance (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:aggregate/app\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    )
    is Err(_),
  )
}

///|
test "encoded current-scope outer aliases and long named chains use bounded work stacks" {
  let wat = StringBuilder()
  wat.write_string(
    "(component (type (component (type (instance (type u32) (export \"first\" (type (eq 0)))",
  )
  let mut previous = 1
  for index in 0..<1500 {
    wat.write_string("(alias outer 0 " + previous.to_string() + " (type))")
    wat.write_string(
      "(export \"t" +
      index.to_string() +
      "\" (type (eq " +
      (previous + 1).to_string() +
      ")))",
    )
    previous += 2
  }
  wat.write_string(
    ")) (export \"example:deep/api\" (instance (type 0))))) (export \"api\" (type 0)))",
  )
  let input = match @verifier.decode_wat_package(wat.to_string()) {
    Ok(input) => input
    Err(errors) => fail(errors[0].message)
  }
  let model = @verifier.resolve_packages(Encoded(input)).unwrap()
  assert_eq(model.interfaces()[0].types.length(), 1501)
  assert_eq(model.types().length(), 3002)
  assert_eq(
    encoded_alias_model(model)["interface/example:deep/api/t1499"],
    "alias anonymous/alias interface/example:deep/api/t1498",
  )
  assert_eq(model.sources().length(), 0)
  assert_true(
    model.types().all(ty => ty.location.position == BinaryOffset(None)),
  )
}

///|
test "current-scope aliases preserve resource identity and ignore unused dependency scopes" {
  for
    (name, wat, accepted) in [
      (
        "unused-foreign-scope", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n(type (component (type (instance)) (import \"other:package/api\" (instance (type 0))))) )",
        true,
      ),
      (
        "current-scope-invalid-index", "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"base\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 0 99 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;3;) \"api\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "current-scope-resource-0", "(component (type (component (type (instance (export \"r\" (type (sub resource))) (export \"other\" (type (sub resource))) (alias outer 0 0 (type)) (export \"alias\" (type (eq 2))) (type (borrow 3)) (type (func (param \"self\" 4))) (export \"[method]r.m\" (func (type 5))))) (export \"example:current/api\" (instance (type 0))))) (export \"api\" (type 0)))",
        false,
      ),
      (
        "current-scope-resource-1", "(component (type (component (type (instance (export \"r\" (type (sub resource))) (export \"other\" (type (sub resource))) (alias outer 0 1 (type)) (export \"alias\" (type (eq 2))) (type (borrow 3)) (type (func (param \"self\" 4))) (export \"[method]r.m\" (func (type 5))))) (export \"example:current/api\" (instance (type 0))))) (export \"api\" (type 0)))",
        false,
      ),
    ] {
    let decoded = @verifier.decode_wat_package(wat)
    assert_eq(decoded is Ok(_), accepted, msg=name)
    if decoded is Ok(input) {
      assert_true(@verifier.resolve_packages(Encoded(input)) is Ok(_), msg=name)
    }
  }
}

///|
// Pinned Resolve panics at decoding.rs:1567 on this forward inferred local
// package merge. The product reports unsupported inference without panicking.
test "forward local encoded projections fail closed" {
  assert_true(
    @verifier.decode_wat_package(
      "(component (type $t0 \n    (component\n      (type \n        (instance\n          (export  \"r\" (type (sub resource)))\n          (type  u32)\n          (export  \"id\" (type (eq 1)))\n        )\n      )\n      (export  \"example:aliases/base@1.0.0\" (instance (type 0)))\n    )\n  ) (type $t2 \n    (component\n      (type \n        (instance\n          (export  \"r\" (type (sub resource)))\n          (type  u32)\n          (export  \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:aliases/base@1.0.0\" (instance  (type 0)))\n      (alias export 0 \"r\" (type ))\n      (alias export 0 \"id\" (type ))\n      (type \n        (instance\n          (alias outer 1 1 (type ))\n          (export  \"r\" (type (eq 0)))\n          (alias outer 1 2 (type ))\n          (export  \"id\" (type (eq 2)))\n          (type  (borrow 1))\n          (type  (func (param \"x\" 4) (result 3)))\n          (export  \"run\" (func (type 5)))\n        )\n      )\n      (export  \"example:aliases/api@1.0.0\" (instance (type 3)))\n    )\n  ) (type $t4 \n    (component\n      (type \n        (component\n          (type \n            (instance\n              (export  \"r\" (type (sub resource)))\n              (type  u32)\n              (export  \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:aliases/base@1.0.0\" (instance  (type 0)))\n          (alias export 0 \"r\" (type ))\n          (alias export 0 \"id\" (type ))\n          (type \n            (instance\n              (alias outer 1 1 (type ))\n              (export  \"r\" (type (eq 0)))\n              (alias outer 1 2 (type ))\n              (export  \"id\" (type (eq 2)))\n              (type  (borrow 1))\n              (type  (func (param \"x\" 4) (result 3)))\n              (export  \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:aliases/api@1.0.0\" (instance  (type 3)))\n        )\n      )\n      (export  \"example:aliases/app@1.0.0\" (component (type 0)))\n    )\n  ) (export  \"api\" (type $t2)) (export  \"base\" (type $t0)) (export  \"app\" (type $t4)))",
    )
    is Err(_),
  )
}

///|
test "current-scope direct resource aliases preserve method receiver identities" {
  for
    (wat, accepted) in [
      (
        "(component (type (component (type (instance (export \"r\" (type (sub resource))) (export \"other\" (type (sub resource))) (alias outer 0 0 (type)) (type (borrow 2)) (type (func (param \"self\" 3))) (export \"[method]r.m\" (func (type 4))))) (export \"example:current/api\" (instance (type 0))))) (export \"api\" (type 0)))",
        true,
      ),
      (
        "(component (type (component (type (instance (export \"r\" (type (sub resource))) (export \"other\" (type (sub resource))) (alias outer 0 1 (type)) (type (borrow 2)) (type (func (param \"self\" 3))) (export \"[method]r.m\" (func (type 4))))) (export \"example:current/api\" (instance (type 0))))) (export \"api\" (type 0)))",
        false,
      ),
    ] {
    let result = @verifier.decode_wat_package(wat)
    assert_eq(result is Ok(_), accepted)
    if result is Ok(input) {
      assert_true(@verifier.resolve_packages(Encoded(input)) is Ok(_))
    }
  }
}

///|
test "encoded interface and world use aliases retain version zero and one metadata" {
  for
    (wat, bytes) in [
      (
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:renamed/first@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"first\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n        )\n      )\n      (export (;0;) \"example:renamed/second@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;3;) \"second\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:renamed/first@1.0.0\" (instance (;0;) (type 0)))\n      (type (;1;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n        )\n      )\n      (import \"example:renamed/second@1.0.0\" (instance (;1;) (type 1)))\n      (alias export 0 \"same\" (type (;2;)))\n      (alias export 0 \"id\" (type (;3;)))\n      (alias export 1 \"same\" (type (;4;)))\n      (type (;5;)\n        (instance\n          (alias outer 1 2 (type (;0;)))\n          (export (;1;) \"left\" (type (eq 0)))\n          (alias outer 1 3 (type (;2;)))\n          (export (;3;) \"number\" (type (eq 2)))\n          (alias outer 1 4 (type (;4;)))\n          (export (;5;) \"right\" (type (eq 4)))\n          (export (;6;) \"twice\" (type (eq 3)))\n          (type (;7;) (borrow 1))\n          (type (;8;) (borrow 5))\n          (type (;9;) (func (param \"a\" 7) (param \"b\" 8) (result 6)))\n          (export (;0;) \"run\" (func (type 9)))\n        )\n      )\n      (export (;2;) \"example:renamed/aliases@1.0.0\" (instance (type 5)))\n    )\n  )\n  (export (;5;) \"aliases\" (type 4))\n  (type (;6;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"same\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:renamed/first@1.0.0\" (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance\n              (export (;0;) \"same\" (type (sub resource)))\n            )\n          )\n          (import \"example:renamed/second@1.0.0\" (instance (;1;) (type 1)))\n          (alias export 0 \"same\" (type (;2;)))\n          (alias export 0 \"id\" (type (;3;)))\n          (alias export 1 \"same\" (type (;4;)))\n          (type (;5;)\n            (instance\n              (alias outer 1 2 (type (;0;)))\n              (export (;1;) \"left\" (type (eq 0)))\n              (alias outer 1 3 (type (;2;)))\n              (export (;3;) \"number\" (type (eq 2)))\n              (alias outer 1 4 (type (;4;)))\n              (export (;5;) \"right\" (type (eq 4)))\n              (export (;6;) \"twice\" (type (eq 3)))\n              (type (;7;) (borrow 1))\n              (type (;8;) (borrow 5))\n              (type (;9;) (func (param \"a\" 7) (param \"b\" 8) (result 6)))\n              (export (;0;) \"run\" (func (type 9)))\n            )\n          )\n          (import \"example:renamed/aliases@1.0.0\" (instance (;2;) (type 5)))\n          (alias export 2 \"left\" (type (;6;)))\n          (import \"l\" (type (;7;) (eq 6)))\n          (alias export 2 \"right\" (type (;8;)))\n          (import \"r\" (type (;9;) (eq 8)))\n          (alias export 2 \"twice\" (type (;10;)))\n          (import \"twice\" (type (;11;) (eq 10)))\n          (type (;12;) (borrow 7))\n          (type (;13;) (borrow 9))\n          (type (;14;) (func (param \"a\" 12) (param \"b\" 13) (result 11)))\n          (export (;0;) \"out\" (func (type 14)))\n        )\n      )\n      (export (;0;) \"example:renamed/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;7;) \"app\" (type 6))\n  (@custom \"package-docs\" \"\\00\\7b\\22\\69\\6e\\74\\65\\72\\66\\61\\63\\65\\73\\22\\3a\\7b\\22\\61\\6c\\69\\61\\73\\65\\73\\22\\3a\\7b\\22\\74\\79\\70\\65\\73\\22\\3a\\7b\\22\\6c\\65\\66\\74\\22\\3a\\7b\\22\\73\\74\\61\\62\\69\\6c\\69\\74\\79\\22\\3a\\7b\\22\\75\\6e\\73\\74\\61\\62\\6c\\65\\22\\3a\\7b\\22\\66\\65\\61\\74\\75\\72\\65\\22\\3a\\22\\68\\69\\64\\64\\65\\6e\\22\\7d\\7d\\7d\\7d\\7d\\7d\\2c\\22\\77\\6f\\72\\6c\\64\\73\\22\\3a\\7b\\22\\61\\70\\70\\22\\3a\\7b\\22\\74\\79\\70\\65\\73\\22\\3a\\7b\\22\\6c\\22\\3a\\7b\\22\\73\\74\\61\\62\\69\\6c\\69\\74\\79\\22\\3a\\7b\\22\\73\\74\\61\\62\\6c\\65\\22\\3a\\7b\\22\\73\\69\\6e\\63\\65\\22\\3a\\22\\39\\2e\\30\\2e\\30\\22\\7d\\7d\\7d\\7d\\7d\\7d\\7d\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x39\x01\x41\x02\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x04\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0b\x01\x00\x05\x66\x69\x72\x73\x74\x03\x00\x00\x07\x30\x01\x41\x02\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x04\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0c\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x03\x02\x00\x07\xf8\x01\x01\x41\x09\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x01\x02\x03\x00\x00\x04\x73\x61\x6d\x65\x02\x03\x00\x00\x02\x69\x64\x02\x03\x00\x01\x04\x73\x61\x6d\x65\x01\x42\x0b\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x02\x02\x03\x02\x01\x04\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x04\x04\x00\x05\x74\x77\x69\x63\x65\x03\x00\x03\x01\x68\x01\x01\x68\x05\x01\x40\x02\x01\x61\x07\x01\x62\x08\x00\x06\x04\x00\x03\x72\x75\x6e\x01\x09\x04\x00\x1d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x6c\x69\x61\x73\x65\x73\x40\x31\x2e\x30\x2e\x30\x05\x05\x0b\x0d\x01\x00\x07\x61\x6c\x69\x61\x73\x65\x73\x03\x04\x00\x07\xe8\x02\x01\x41\x02\x01\x41\x13\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x01\x02\x03\x00\x00\x04\x73\x61\x6d\x65\x02\x03\x00\x00\x02\x69\x64\x02\x03\x00\x01\x04\x73\x61\x6d\x65\x01\x42\x0b\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x02\x02\x03\x02\x01\x04\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x04\x04\x00\x05\x74\x77\x69\x63\x65\x03\x00\x03\x01\x68\x01\x01\x68\x05\x01\x40\x02\x01\x61\x07\x01\x62\x08\x00\x06\x04\x00\x03\x72\x75\x6e\x01\x09\x03\x00\x1d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x6c\x69\x61\x73\x65\x73\x40\x31\x2e\x30\x2e\x30\x05\x05\x02\x03\x00\x02\x04\x6c\x65\x66\x74\x03\x00\x01\x6c\x03\x00\x06\x02\x03\x00\x02\x05\x72\x69\x67\x68\x74\x03\x00\x01\x72\x03\x00\x08\x02\x03\x00\x02\x05\x74\x77\x69\x63\x65\x03\x00\x05\x74\x77\x69\x63\x65\x03\x00\x0a\x01\x68\x07\x01\x68\x09\x01\x40\x02\x01\x61\x0c\x01\x62\x0d\x00\x0b\x04\x00\x03\x6f\x75\x74\x01\x0e\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x06\x00\x00\xb7\x01\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x00\x7b\x22\x69\x6e\x74\x65\x72\x66\x61\x63\x65\x73\x22\x3a\x7b\x22\x61\x6c\x69\x61\x73\x65\x73\x22\x3a\x7b\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x6c\x65\x66\x74\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x68\x69\x64\x64\x65\x6e\x22\x7d\x7d\x7d\x7d\x7d\x7d\x2c\x22\x77\x6f\x72\x6c\x64\x73\x22\x3a\x7b\x22\x61\x70\x70\x22\x3a\x7b\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x6c\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x39\x2e\x30\x2e\x30\x22\x7d\x7d\x7d\x7d\x7d\x7d\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (export (;0;) \"example:renamed/first@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"first\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n        )\n      )\n      (export (;0;) \"example:renamed/second@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;3;) \"second\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:renamed/first@1.0.0\" (instance (;0;) (type 0)))\n      (type (;1;)\n        (instance\n          (export (;0;) \"same\" (type (sub resource)))\n        )\n      )\n      (import \"example:renamed/second@1.0.0\" (instance (;1;) (type 1)))\n      (alias export 0 \"same\" (type (;2;)))\n      (alias export 0 \"id\" (type (;3;)))\n      (alias export 1 \"same\" (type (;4;)))\n      (type (;5;)\n        (instance\n          (alias outer 1 2 (type (;0;)))\n          (export (;1;) \"left\" (type (eq 0)))\n          (alias outer 1 3 (type (;2;)))\n          (export (;3;) \"number\" (type (eq 2)))\n          (alias outer 1 4 (type (;4;)))\n          (export (;5;) \"right\" (type (eq 4)))\n          (export (;6;) \"twice\" (type (eq 3)))\n          (type (;7;) (borrow 1))\n          (type (;8;) (borrow 5))\n          (type (;9;) (func (param \"a\" 7) (param \"b\" 8) (result 6)))\n          (export (;0;) \"run\" (func (type 9)))\n        )\n      )\n      (export (;2;) \"example:renamed/aliases@1.0.0\" (instance (type 5)))\n    )\n  )\n  (export (;5;) \"aliases\" (type 4))\n  (type (;6;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"same\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"example:renamed/first@1.0.0\" (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance\n              (export (;0;) \"same\" (type (sub resource)))\n            )\n          )\n          (import \"example:renamed/second@1.0.0\" (instance (;1;) (type 1)))\n          (alias export 0 \"same\" (type (;2;)))\n          (alias export 0 \"id\" (type (;3;)))\n          (alias export 1 \"same\" (type (;4;)))\n          (type (;5;)\n            (instance\n              (alias outer 1 2 (type (;0;)))\n              (export (;1;) \"left\" (type (eq 0)))\n              (alias outer 1 3 (type (;2;)))\n              (export (;3;) \"number\" (type (eq 2)))\n              (alias outer 1 4 (type (;4;)))\n              (export (;5;) \"right\" (type (eq 4)))\n              (export (;6;) \"twice\" (type (eq 3)))\n              (type (;7;) (borrow 1))\n              (type (;8;) (borrow 5))\n              (type (;9;) (func (param \"a\" 7) (param \"b\" 8) (result 6)))\n              (export (;0;) \"run\" (func (type 9)))\n            )\n          )\n          (import \"example:renamed/aliases@1.0.0\" (instance (;2;) (type 5)))\n          (alias export 2 \"left\" (type (;6;)))\n          (import \"l\" (type (;7;) (eq 6)))\n          (alias export 2 \"right\" (type (;8;)))\n          (import \"r\" (type (;9;) (eq 8)))\n          (alias export 2 \"twice\" (type (;10;)))\n          (import \"twice\" (type (;11;) (eq 10)))\n          (type (;12;) (borrow 7))\n          (type (;13;) (borrow 9))\n          (type (;14;) (func (param \"a\" 12) (param \"b\" 13) (result 11)))\n          (export (;0;) \"out\" (func (type 14)))\n        )\n      )\n      (export (;0;) \"example:renamed/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;7;) \"app\" (type 6))\n  (@custom \"package-docs\" \"\\01\\7b\\22\\69\\6e\\74\\65\\72\\66\\61\\63\\65\\73\\22\\3a\\7b\\22\\61\\6c\\69\\61\\73\\65\\73\\22\\3a\\7b\\22\\74\\79\\70\\65\\73\\22\\3a\\7b\\22\\6c\\65\\66\\74\\22\\3a\\7b\\22\\73\\74\\61\\62\\69\\6c\\69\\74\\79\\22\\3a\\7b\\22\\75\\6e\\73\\74\\61\\62\\6c\\65\\22\\3a\\7b\\22\\66\\65\\61\\74\\75\\72\\65\\22\\3a\\22\\68\\69\\64\\64\\65\\6e\\22\\7d\\7d\\7d\\7d\\7d\\7d\\2c\\22\\77\\6f\\72\\6c\\64\\73\\22\\3a\\7b\\22\\61\\70\\70\\22\\3a\\7b\\22\\74\\79\\70\\65\\73\\22\\3a\\7b\\22\\6c\\22\\3a\\7b\\22\\73\\74\\61\\62\\69\\6c\\69\\74\\79\\22\\3a\\7b\\22\\73\\74\\61\\62\\6c\\65\\22\\3a\\7b\\22\\73\\69\\6e\\63\\65\\22\\3a\\22\\39\\2e\\30\\2e\\30\\22\\7d\\7d\\7d\\7d\\7d\\7d\\7d\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x39\x01\x41\x02\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x04\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0b\x01\x00\x05\x66\x69\x72\x73\x74\x03\x00\x00\x07\x30\x01\x41\x02\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x04\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x0c\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x03\x02\x00\x07\xf8\x01\x01\x41\x09\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x01\x02\x03\x00\x00\x04\x73\x61\x6d\x65\x02\x03\x00\x00\x02\x69\x64\x02\x03\x00\x01\x04\x73\x61\x6d\x65\x01\x42\x0b\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x02\x02\x03\x02\x01\x04\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x04\x04\x00\x05\x74\x77\x69\x63\x65\x03\x00\x03\x01\x68\x01\x01\x68\x05\x01\x40\x02\x01\x61\x07\x01\x62\x08\x00\x06\x04\x00\x03\x72\x75\x6e\x01\x09\x04\x00\x1d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x6c\x69\x61\x73\x65\x73\x40\x31\x2e\x30\x2e\x30\x05\x05\x0b\x0d\x01\x00\x07\x61\x6c\x69\x61\x73\x65\x73\x03\x04\x00\x07\xe8\x02\x01\x41\x02\x01\x41\x13\x01\x42\x03\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x1b\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x66\x69\x72\x73\x74\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x01\x04\x00\x04\x73\x61\x6d\x65\x03\x01\x03\x00\x1c\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x73\x65\x63\x6f\x6e\x64\x40\x31\x2e\x30\x2e\x30\x05\x01\x02\x03\x00\x00\x04\x73\x61\x6d\x65\x02\x03\x00\x00\x02\x69\x64\x02\x03\x00\x01\x04\x73\x61\x6d\x65\x01\x42\x0b\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x06\x6e\x75\x6d\x62\x65\x72\x03\x00\x02\x02\x03\x02\x01\x04\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x04\x04\x00\x05\x74\x77\x69\x63\x65\x03\x00\x03\x01\x68\x01\x01\x68\x05\x01\x40\x02\x01\x61\x07\x01\x62\x08\x00\x06\x04\x00\x03\x72\x75\x6e\x01\x09\x03\x00\x1d\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x6c\x69\x61\x73\x65\x73\x40\x31\x2e\x30\x2e\x30\x05\x05\x02\x03\x00\x02\x04\x6c\x65\x66\x74\x03\x00\x01\x6c\x03\x00\x06\x02\x03\x00\x02\x05\x72\x69\x67\x68\x74\x03\x00\x01\x72\x03\x00\x08\x02\x03\x00\x02\x05\x74\x77\x69\x63\x65\x03\x00\x05\x74\x77\x69\x63\x65\x03\x00\x0a\x01\x68\x07\x01\x68\x09\x01\x40\x02\x01\x61\x0c\x01\x62\x0d\x00\x0b\x04\x00\x03\x6f\x75\x74\x01\x0e\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x6e\x61\x6d\x65\x64\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x06\x00\x00\xb7\x01\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x22\x69\x6e\x74\x65\x72\x66\x61\x63\x65\x73\x22\x3a\x7b\x22\x61\x6c\x69\x61\x73\x65\x73\x22\x3a\x7b\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x6c\x65\x66\x74\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x68\x69\x64\x64\x65\x6e\x22\x7d\x7d\x7d\x7d\x7d\x7d\x2c\x22\x77\x6f\x72\x6c\x64\x73\x22\x3a\x7b\x22\x61\x70\x70\x22\x3a\x7b\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x6c\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x39\x2e\x30\x2e\x30\x22\x7d\x7d\x7d\x7d\x7d\x7d\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
    ] {
    for
      input in [
        @verifier.decode_wat_package(wat).unwrap(),
        @verifier.decode_package(bytes).unwrap(),
      ] {
      for
        features in [
          @verifier.SemanticFeatures::default(),
          @verifier.SemanticFeatures::all(),
        ] {
        let model = @verifier.resolve_packages(
          Encoded(input),
          semantic_features=features,
        ).unwrap()
        let left = model
          .interfaces()
          .filter(item => item.name == Some("aliases"))[0].types.filter(item => {
            item.name == "left"
          })[0].ty
        let l = model.worlds()[0].imports.filter(item => item.name == "l")[0]
        guard l.kind is Type(world_type) else { fail("missing world use type") }
        assert_eq(
          model.types().filter(item => item.id == left)[0].stability,
          Unstable("hidden", None),
        )
        assert_eq(
          model.types().filter(item => item.id == world_type)[0].stability,
          Stable("9.0.0", None),
        )
        assert_true(
          model
          .types()
          .all(item => item.location.position == BinaryOffset(None)),
        )
      }
    }
  }
}
