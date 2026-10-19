///|
test "mixed stability keeps selected function and anonymous type metadata" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (list u32))\n              (export (;2;) \"t\" (type (eq 1)))\n              (type (;3;) (own 0))\n              (type (;4;) (func (result 3)))\n              (export (;0;) \"[constructor]r\" (func (type 4)))\n              (type (;5;) (borrow 0))\n              (type (;6;) (list u32))\n              (type (;7;) (func (param \"self\" 5) (param \"x\" 6)))\n              (export (;1;) \"[method]r.method\" (func (type 7)))\n              (type (;8;) (option 2))\n              (type (;9;) (tuple 2 3))\n              (type (;10;) (func (param \"x\" 8) (result 9)))\n              (export (;2;) \"f\" (func (type 10)))\n            )\n          )\n          (import \"test:dep/base@1.0.0\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="input.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "supplied.wit", "package test:dep@1.0.0;interface base{@since(version=1.0.0) resource r{@since(version=1.0.0) constructor();@since(version=1.0.0) method:func(x:list<u32>);}@since(version=1.0.0) type t=list<u32>;@since(version=1.0.0) f:func(x:option<t>)->tuple<t,r>;}",
      ),
    ],
  }
  for binary_first in [false, true] {
    let model = if binary_first {
      @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)]).unwrap()
    } else {
      @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)]).unwrap()
    }
    let types : Map[Int32, @verifier.ResolvedType] = Map([])
    for ty in model.types() {
      types[ty.id] = ty
    }
    for function in model.functions() {
      assert_eq(function.stability == Unknown, binary_first)
      if function.name == "f" {
        assert_eq(
          types[function.params[0].ty].stability == Unknown,
          binary_first,
        )
        let origin = model.origin(function.params[0].ty).unwrap()
        assert_eq(
          origin.location.source,
          if binary_first {
            "input.wat"
          } else {
            "supplied.wit"
          },
        )
        assert_eq(origin.node is None, binary_first)
        assert_eq(
          types[function.result.unwrap()].stability == Unknown,
          binary_first,
        )
      }
      assert_eq(function.location.source, "supplied.wit")
    }
    let api = model.interfaces().filter(info => info.name == Some("base"))[0]
    for entry in api.types {
      assert_true(types[entry.ty].stability != Unknown)
      assert_eq(types[entry.ty].location.source, "supplied.wit")
    }
  }
}

///|
test "mixed stability preserves anonymous sharing and nominal resources" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"t\" (type (eq 0)))\n              (type (;2;) (option 1))\n              (type (;3;) (record (field \"v\" 2)))\n              (export (;4;) \"box\" (type (eq 3)))\n              (export (;5;) \"r\" (type (sub resource)))\n              (export (;6;) \"s\" (type (sub resource)))\n              (type (;7;) (borrow 5))\n              (type (;8;) (func (param \"x\" 2) (param \"r\" 7)))\n              (export (;0;) \"f\" (func (type 8)))\n              (type (;9;) (borrow 6))\n              (type (;10;) (func (param \"x\" 2) (param \"s\" 9)))\n              (export (;1;) \"g\" (func (type 10)))\n            )\n          )\n          (import \"test:dep/base@1.0.0\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="sharing.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "source.wit", "package test:dep@1.0.0;interface base{@since(version=1.0.0) type t=u32;@since(version=1.0.0) record box{v:option<t>}resource r;resource s;f:func(x:option<t>,r:borrow<r>);g:func(x:option<t>,s:borrow<s>);@unstable(feature=hidden) h:func(x:option<t>);}",
      ),
    ],
  }
  for binary_first in [false, true] {
    for
      features in [
        @verifier.SemanticFeatures::default(),
        @verifier.SemanticFeatures::all(),
      ] {
      let model = if binary_first {
        @verifier.resolve_packages(
          Encoded(input),
          dependencies=[Source(source)],
          semantic_features=features,
        ).unwrap()
      } else {
        @verifier.resolve_packages(
          Source(source),
          dependencies=[Encoded(input)],
          semantic_features=features,
        ).unwrap()
      }
      let types : Map[Int32, @verifier.ResolvedType] = Map([])
      for ty in model.types() {
        types[ty.id] = ty
      }
      let funcs : Map[String, @verifier.ResolvedFunction] = Map([])
      for fn_ in model.functions() {
        funcs[fn_.name] = fn_
      }
      let f = funcs["f"]
      let g = funcs["g"]
      assert_eq(
        types[f.params[0].ty].stability,
        types[g.params[0].ty].stability,
      )
      assert_eq(types[f.params[0].ty].stability == Unknown, binary_first)
      if features.all_enabled {
        let h = funcs["h"]
        assert_eq(
          types[h.params[0].ty].stability == types[f.params[0].ty].stability,
          !binary_first,
        )
        assert_true(types[h.params[0].ty].stability != Unknown)
      } else {
        assert_eq(funcs.get("h"), None)
      }
      let api = model.interfaces().filter(info => info.name == Some("base"))[0]
      let names : Map[String, Int32] = Map([])
      for entry in api.types {
        names[entry.name] = entry.ty
      }
      assert_true(names["r"] != names["s"])
      assert_eq(types[f.params[1].ty].kind, Borrow(names["r"]))
      assert_eq(types[g.params[1].ty].kind, Borrow(names["s"]))
      guard types[names["box"]].kind is Record(fields) else { fail("record") }
      assert_eq(types[fields[0].ty].stability == Unknown, binary_first)
      assert_true(types[names["box"]].stability != Unknown)
    }
  }
}

///|
test "selected model copy traverses nested anonymous types iteratively" {
  let input = @verifier.decode_wat_package(
    "(component (type (component (type (component (type (instance (type (option u32)) (type (option 0))(type (option 1))(type (option 2))(type (option 3))(type (option 4))(type (option 5))(type (option 6))(type (option 7))(type (option 8))(type (option 9))(type (option 10))(type (option 11))(type (option 12))(type (option 13))(type (option 14))(type (option 15))(type (option 16))(type (option 17))(type (option 18))(type (option 19))(type (option 20))(type (option 21))(type (option 22))(type (option 23))(type (option 24))(type (option 25))(type (option 26))(type (option 27))(type (option 28))(type (option 29))(type (option 30))(type (option 31))(type (option 32))(type (option 33))(type (option 34))(type (option 35))(type (option 36))(type (option 37))(type (option 38))(type (option 39))(type (option 40))(type (option 41))(type (option 42))(type (option 43))(type (option 44))(type (option 45))(type (option 46))(type (option 47))(type (option 48))(export \"t\" (type (eq 49))))) (import \"test:dep/base@1.0.0\" (instance (type 0))))) (export \"test:root/app\" (component (type 0))))) (export \"app\" (type 0)))",
    source_id="deep.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "deep.wit", "package test:dep@1.0.0;interface base{@since(version=1.0.0) type t=option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<option<u32>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;}",
      ),
    ],
  }
  for binary_first in [false, true] {
    let model = if binary_first {
      @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)]).unwrap()
    } else {
      @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)]).unwrap()
    }
    let types : Map[Int32, @verifier.ResolvedType] = Map([])
    for ty in model.types() {
      types[ty.id] = ty
    }
    let api = model.interfaces().filter(info => info.name == Some("base"))[0]
    let mut id = api.types[0].ty
    let mut options = 0
    while true {
      let ty = types[id]
      match ty.kind {
        Alias(next) => id = next
        Option(next) => {
          if options > 0 {
            assert_eq(ty.stability == Unknown, binary_first)
          }
          options += 1
          id = next
        }
        Scalar("u32") => break
        _ => fail("unexpected nested type")
      }
    }
    assert_eq(options, 50)
  }
}

///|
test "mixed input named bodies body" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"t\" (type (eq 0)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="body.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "body.wit", "package test:dep;interface base{type t=string;h:func(x:t);}",
      ),
    ],
  }
  for binary_first in [false, true] {
    let result = if binary_first {
      @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)])
    } else {
      @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
    }
    let model = result.unwrap()
    let types : Map[Int32, @verifier.ResolvedType] = Map([])
    for ty in model.types() {
      types[ty.id] = ty
    }
    let api = model.interfaces().filter(info => info.name == Some("base"))[0]
    let mut id = api.types[0].ty
    while types[id].kind is Alias(next) {
      id = next
    }
    assert_eq(
      types[id].kind,
      Scalar(if binary_first { "u32" } else { "string" }),
    )
    assert_eq(types[api.types[0].ty].location.source, "body.wit")
  }
}

///|
test "mixed input named bodies resource-body" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"r\" (type (eq 0)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="body.wat",
  ).unwrap()
  for
    body in [
      "resource r;h:func(x:borrow<r>);", "resource r{make:static func();}",
    ] {
    let source = @verifier.SourcePackage::{
      documents: [
        section_document(
          "body.wit",
          "package test:dep;interface base{" + body + "}",
        ),
      ],
    }
    for binary_first in [false, true] {
      let result = if binary_first {
        @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)])
      } else {
        @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
      }
      if binary_first {
        assert_eq(result.unwrap_err()[0].code, "WIT-B004")
        continue
      }
      let model = result.unwrap()
      let types : Map[Int32, @verifier.ResolvedType] = Map([])
      for ty in model.types() {
        types[ty.id] = ty
      }
      let api = model.interfaces().filter(info => info.name == Some("base"))[0]
      assert_eq(types[api.types[0].ty].kind, Resource)
    }
  }
}

///|
test "mixed input named bodies cycle-body" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) (list u32))\n              (export (;1;) \"a\" (type (eq 0)))\n              (export (;2;) \"b\" (type (eq 1)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="body.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "body.wit", "package test:dep;interface base{type b=list<u32>;type a=b;}",
      ),
    ],
  }
  for binary_first in [false, true] {
    let result = if binary_first {
      @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)])
    } else {
      @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
    }
    let model = result.unwrap()
    let types : Map[Int32, @verifier.ResolvedType] = Map([])
    for ty in model.types() {
      types[ty.id] = ty
    }
    let api = model.interfaces().filter(info => info.name == Some("base"))[0]
    let names : Map[String, Int32] = Map([])
    for entry in api.types {
      names[entry.name] = entry.ty
    }
    let mut id = names[if binary_first { "b" } else { "a" }]
    while types[id].kind is Alias(next) {
      id = next
    }
    assert_true(types[id].kind is List(_, None))
  }
}

///|
test "merged named bodies preserve borrow-result" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (borrow 0))\n              (export (;2;) \"t\" (type (eq 1)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="input.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "input.wit", "package test:dep;interface base{resource r;type t=u32;f:func()->option<t>;}",
      ),
    ],
  }
  assert_eq(
    @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)]).unwrap_err()[0].code,
    "WIT-B004",
  )
  assert_true(
    @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
    is Ok(_),
  )
}

///|
test "merged named bodies preserve constructor-result" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (export (;1;) \"s\" (type (sub resource)))\n              (type (;2;) (own 1))\n              (type (;3;) (result 2))\n              (export (;4;) \"t\" (type (eq 3)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="input.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "input.wit", "package test:dep;interface base{resource r{constructor()->t;}resource s;type t=result<r>;}",
      ),
    ],
  }
  assert_eq(
    @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)]).unwrap_err()[0].code,
    "WIT-B004",
  )
  assert_true(
    @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
    is Ok(_),
  )
}

///|
test "merged named bodies preserve setter-result" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"t\" (type (eq 0)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="input.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "input.wit", "package test:dep;interface base{type t=result;v:get()->u32;v:set(value:u32)->t;}",
      ),
    ],
  }
  assert_eq(
    @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)]).unwrap_err()[0].code,
    "WIT-B004",
  )
  assert_true(
    @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
    is Ok(_),
  )
}

///|
test "selected model replay does not merge supplied world definitions" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (list u32))\n              (export (;2;) \"t\" (type (eq 1)))\n              (type (;3;) (own 0))\n              (type (;4;) (func (result 3)))\n              (export (;0;) \"[constructor]r\" (func (type 4)))\n              (type (;5;) (borrow 0))\n              (type (;6;) (list u32))\n              (type (;7;) (func (param \"self\" 5) (param \"x\" 6)))\n              (export (;1;) \"[method]r.method\" (func (type 7)))\n              (type (;8;) (option 2))\n              (type (;9;) (tuple 2 3))\n              (type (;10;) (func (param \"x\" 8) (result 9)))\n              (export (;2;) \"f\" (func (type 10)))\n            )\n          )\n          (import \"test:dep/base@1.0.0\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="input.wat",
  ).unwrap()
  let duplicate = @verifier.SourcePackage::{
    documents: [
      section_document("duplicate.wit", "package test:root;world app{}"),
    ],
  }
  for first in [true, false] {
    let result = if first {
      @verifier.resolve_packages(Encoded(input), dependencies=[
        Source(duplicate),
      ])
    } else {
      @verifier.resolve_packages(Source(duplicate), dependencies=[
        Encoded(input),
      ])
    }
    assert_true(result is Err(_))
  }
}

///|
test "merged values cannot contain bare resources" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"t\" (type (sub resource)))\n            )\n          )\n          (import \"test:dep/base\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="input.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "input.wit", "package test:dep;interface base{type t=u32;f:func(x:option<t>)->t;}",
      ),
    ],
  }
  assert_eq(
    @verifier.resolve_packages(Encoded(input), dependencies=[Source(source)]).unwrap_err()[0].code,
    "WIT-B004",
  )
  assert_true(
    @verifier.resolve_packages(Source(source), dependencies=[Encoded(input)])
    is Ok(_),
  )
}
