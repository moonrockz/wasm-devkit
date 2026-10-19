///|
// These probes are accepted by pinned wit-parser 0.262.0. Source WIT requires
// explicit use aliases, so compare canonical function types and check encoded
// declaration counts separately. The binary must not gain those source aliases.
test "direct foreign references preserve identities without invented aliases" {
  for
    (name, wat, bytes, source, imports, named_types) in [
      (
        "basic", "(component(type(component(type(component (type (instance (export \"r\" (type (sub resource))))) (import \"example:dep/api\" (instance (type 0))) (alias export 0 \"r\" (type)) (type (own 1)) (type (func (param \"x\" 2))) (import \"f\" (func (type 3)))))(export \"example:test/app\" (component(type 0)))))(export \"app\"(type 0)))",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4f\x01\x41\x02\x01\x41\x06\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x01\x69\x01\x01\x40\x01\x01\x78\x02\x01\x00\x03\x00\x01\x66\x01\x03\x04\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x65\x73\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00",
        "package example:test; world app {use example:dep/api.{r};import f:func(x:own<r>);} package example:dep {interface api{resource r;}}",
        2, 1,
      ),
      (
        "values", "(component(type(component(type(component (type(instance(export \"r\"(type(sub resource)))(type u32)(export \"id\"(type(eq 1)))))(import \"example:dep/api\"(instance(type 0)))(alias export 0 \"r\"(type))(alias export 0 \"id\"(type))(type(own 1))(type(borrow 1))(type(func(param \"owned\" 3)(param \"borrowed\" 4)(param \"number\" 2)(result 2)))(import \"f\"(func(type 5)))))(export \"example:test/app\"(component(type 0)))))(export \"app\"(type 0)))",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x79\x01\x41\x02\x01\x41\x08\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x69\x01\x01\x68\x01\x01\x40\x03\x05\x6f\x77\x6e\x65\x64\x03\x08\x62\x6f\x72\x72\x6f\x77\x65\x64\x04\x06\x6e\x75\x6d\x62\x65\x72\x02\x00\x02\x03\x00\x01\x66\x01\x05\x04\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x65\x73\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00",
        "package example:test; world app {use example:dep/api.{r,id};import f:func(owned:own<r>,borrowed:borrow<r>,number:id)->id;} package example:dep {interface api{resource r;type id=u32;}}",
        2, 2,
      ),
      (
        "distinct", "(component(type(component(type(component (type(instance(export \"r\"(type(sub resource)))))(import \"example:dep/left\"(instance(type 0)))(import \"example:dep/right\"(instance(type 0)))(alias export 0 \"r\"(type))(alias export 1 \"r\"(type))(type(own 1))(type(own 2))(type(func(param \"a\" 3)(param \"b\" 4)))(import \"f\"(func(type 5)))))(export \"example:test/app\"(component(type 0)))))(export \"app\"(type 0)))",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x72\x01\x41\x02\x01\x41\x09\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x6c\x65\x66\x74\x05\x00\x03\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x72\x69\x67\x68\x74\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x01\x01\x72\x01\x69\x01\x01\x69\x02\x01\x40\x02\x01\x61\x03\x01\x62\x04\x01\x00\x03\x00\x01\x66\x01\x05\x04\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x65\x73\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00",
        "package example:test; world app {use example:dep/left.{r as left};use example:dep/right.{r as right};import f:func(a:own<left>,b:own<right>);} package example:dep {interface left{resource r;}interface right{resource r;}}",
        3, 2,
      ),
      (
        "collision", "(component(type(component(type(component (type(instance(export \"r\"(type(sub resource)))))(import \"example:dep/api\"(instance(type 0)))(alias export 0 \"r\"(type))(import \"wit-implicit-0\"(type(sub resource)))(type(own 1))(type(own 2))(type(func(param \"a\" 3)(param \"b\" 4)))(import \"f\"(func(type 5)))))(export \"example:test/app\"(component(type 0)))))(export \"app\"(type 0)))",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x68\x01\x41\x02\x01\x41\x08\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x03\x00\x0e\x77\x69\x74\x2d\x69\x6d\x70\x6c\x69\x63\x69\x74\x2d\x30\x03\x01\x01\x69\x01\x01\x69\x02\x01\x40\x02\x01\x61\x03\x01\x62\x04\x01\x00\x03\x00\x01\x66\x01\x05\x04\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x65\x73\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00",
        "package example:test; world app {use example:dep/api.{r};resource wit-implicit-0;import f:func(a:own<r>,b:own<wit-implicit-0>);} package example:dep {interface api{resource r;}}",
        3, 2,
      ),
      (
        "interface", "(component(type(component(type(instance(export \"r\"(type(sub resource)))))(import \"example:dep/api\"(instance(type 0)))(alias export 0 \"r\"(type))(type(instance(alias outer 1 1(type))(type(borrow 0))(type(func(param \"x\" 1)))(export \"f\"(func(type 2)))))(export \"example:test/api\"(instance(type 2)))))(export \"api\"(type 0)))",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x54\x01\x41\x05\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x04\x02\x03\x02\x01\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x65\x73\x74\x2f\x61\x70\x69\x05\x02\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00",
        "package example:test; interface api {use example:dep/api.{r};f:func(x:borrow<r>);} package example:dep {interface api{resource r;}}",
        0, 1,
      ),
    ] {
    let expected = @verifier.resolve({
      documents: [section_document("source.wit", source)],
    }).unwrap()
    for
      decoded in [
        @verifier.decode_package(bytes, source_id=name + ".wasm"),
        @verifier.decode_wat_package(wat, source_id=name + ".wat"),
      ] {
      let input = decoded.unwrap()
      let model = @verifier.resolve_packages(Encoded(input)).unwrap()
      assert_eq(direct_function_model(model), direct_function_model(expected))
      assert_eq(
        model.types().iter().filter(ty => ty.name is Some(_)).count(),
        named_types,
      )
      if imports == 0 {
        assert_eq(model.worlds().length(), 0)
      } else {
        assert_eq(model.worlds()[0].imports.length(), imports)
        assert_eq(model.worlds()[0].exports.length(), 0)
        assert_eq(
          model.worlds()[0].imports
          .iter()
          .filter(item => item.kind is Type(_))
          .count(),
          if name == "collision" {
            1
          } else {
            0
          },
        )
      }
      assert_eq(model.sources().length(), 0)
      for declaration in model.declarations() {
        assert_true(
          !declaration.name.has_prefix("wit-implicit-") ||
          (declaration.name == "wit-implicit-0" && name == "collision"),
        )
        assert_eq(model.origin(declaration.node).unwrap().node, None)
      }
    }
  }
}

///|
fn direct_function_model(model : @verifier.Resolution) -> Map[String, String] {
  let kinds : Map[Int32, @verifier.TypeKind] = Map([])
  let names : Map[Int32, String] = Map([])
  for ty in model.types() {
    kinds[ty.id] = ty.kind
  }
  for info in model.interfaces() {
    for ty in info.types {
      if kinds[ty.ty] is Resource {
        names[ty.ty] = encoded_alias_package(info.package_identity) +
          "/" +
          info.name.unwrap() +
          "/" +
          ty.name
      }
    }
  }
  for world in model.worlds() {
    for item in world.imports {
      if item.kind is Type(id) && kinds[id] is Resource {
        names[id] = encoded_alias_package(world.package_identity) +
          "/" +
          world.name +
          "/" +
          item.name
      }
    }
  }
  let shape = fn(initial : Int32) {
    let mut id = initial
    let out = StringBuilder()
    for _ in 0..<=kinds.length() {
      match kinds[id] {
        Alias(target) => id = target
        Own(target) => {
          out.write_string("own/")
          id = target
        }
        Borrow(target) => {
          out.write_string("borrow/")
          id = target
        }
        Resource => {
          out.write_string(names[id])
          break
        }
        Scalar(name) => {
          out.write_string(name)
          break
        }
        _ => {
          out.write_string("unexpected")
          break
        }
      }
    }
    out.to_string()
  }
  let result : Map[String, String] = Map([])
  for function in model.functions() {
    let out = StringBuilder()
    for param in function.params {
      out.write_string(param.name + ":" + shape(param.ty) + ";")
    }
    if function.result is Some(id) {
      out.write_string("->" + shape(id))
    }
    result[function.name] = out.to_string()
  }
  result
}

///|
test "direct references survive supplied dependency selection and compaction" {
  let input = @verifier.decode_wat_package(
    "(component(type(component(type(instance(export \"r\"(type(sub resource)))))(import \"example:dep/api\"(instance(type 0)))(alias export 0 \"r\"(type))(type(instance(alias outer 1 1(type))(type(borrow 0))(type(func(param \"x\" 1)))(export \"f\"(func(type 2)))))(export \"example:test/api\"(instance(type 2)))))(export \"api\"(type 0)))",
    source_id="direct.wat",
  ).unwrap()
  let dependency = @verifier.SourcePackage::{
    documents: [
      section_document(
        "dependency.wit", "package example:dep; interface api {resource r; @unstable(feature=hidden) extra:func();}",
      ),
    ],
  }
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "root.wit", "package example:consumer; world app {import example:test/api;}",
      ),
    ],
  }
  for
    features in [
      @verifier.SemanticFeatures::default(),
      @verifier.SemanticFeatures::all(),
    ] {
    let orders : Array[ReadOnlyArray[@verifier.PackageInput]] = [
      [Encoded(input), Source(dependency)],
      [Source(dependency), Encoded(input)],
    ]
    for inputs in orders {
      let model = @verifier.resolve_packages(
        Source(source),
        dependencies=inputs,
        semantic_features=features,
      ).unwrap()
      let api = model
        .interfaces()
        .filter(info => info.package_identity.name == "dep")[0]
      assert_eq(api.location.source, "dependency.wit")
      assert_eq(
        api.functions.length(),
        if features.all_enabled {
          1
        } else {
          0
        },
      )
      let resource = api.types[0].ty
      assert_eq(
        model.origin(resource).unwrap().location.source,
        "dependency.wit",
      )
      let f = model.functions().filter(f => f.name == "f")[0]
      let borrow = model.types().filter(ty => ty.id == f.params[0].ty)[0]
      assert_eq(borrow.kind, Borrow(resource))
      let world = model.worlds()[0]
      assert_eq(world.imports.length(), 2)
      assert_true(world.imports.all(item => item.kind is Interface(_)))
    }
  }
}

///|
test "direct-reference metadata survives independent input feature selection" {
  let bytes = metadata_input(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x54\x01\x41\x05\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0f\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x04\x02\x03\x02\x01\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x10\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x65\x73\x74\x2f\x61\x70\x69\x05\x02\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00",
    b"{\"interfaces\":{\"api\":{\"funcs\":{\"f\":{\"stability\":{\"unstable\":{\"feature\":\"hidden\"}}}}}}}",
  )
  let wat = "(component(type(component(type(instance(export \"r\"(type(sub resource)))))(import \"example:dep/api\"(instance(type 0)))(alias export 0 \"r\"(type))(type(instance(alias outer 1 1(type))(type(borrow 0))(type(func(param \"x\" 1)))(export \"f\"(func(type 2)))))(export \"example:test/api\"(instance(type 2)))))(export \"api\"(type 0)) (@custom \"package-docs\" \"\\01\\7b\\22\\69\\6e\\74\\65\\72\\66\\61\\63\\65\\73\\22\\3a\\7b\\22\\61\\70\\69\\22\\3a\\7b\\22\\66\\75\\6e\\63\\73\\22\\3a\\7b\\22\\66\\22\\3a\\7b\\22\\73\\74\\61\\62\\69\\6c\\69\\74\\79\\22\\3a\\7b\\22\\75\\6e\\73\\74\\61\\62\\6c\\65\\22\\3a\\7b\\22\\66\\65\\61\\74\\75\\72\\65\\22\\3a\\22\\68\\69\\64\\64\\65\\6e\\22\\7d\\7d\\7d\\7d\\7d\\7d\\7d\"))"
  let supplied = @verifier.SourcePackage::{
    documents: [
      section_document(
        "supplied.wit", "package example:dep; interface api {resource r;}",
      ),
    ],
  }
  for
    decoded in [
      @verifier.decode_package(bytes),
      @verifier.decode_wat_package(wat),
    ] {
    let input = decoded.unwrap()
    for
      features in [
        @verifier.SemanticFeatures::default(),
        @verifier.SemanticFeatures::all(),
      ] {
      let model = @verifier.resolve_packages(
        Encoded(input),
        dependencies=[Source(supplied)],
        semantic_features=features,
      ).unwrap()
      let api = model
        .interfaces()
        .filter(info => info.package_identity.name == "test")[0]
      assert_eq(api.types.length(), 0)
      assert_eq(
        api.functions.length(),
        if features.all_enabled {
          1
        } else {
          0
        },
      )
      if features.all_enabled {
        assert_eq(api.functions[0].stability, Unstable("hidden", None))
        let dep = model
          .interfaces()
          .filter(info => info.package_identity.name == "dep")[0]
        let parameter = api.functions[0].params[0].ty
        assert_eq(
          model.types().filter(ty => ty.id == parameter)[0].kind,
          Borrow(dep.types[0].ty),
        )
      }
    }
  }
}

///|
test "source views retain packages reached only through direct encoded types" {
  let wat = "(component(type(component(type(instance(export \"r\"(type(sub resource)))))(import \"example:dep/api\"(instance(type 0)))(alias export 0 \"r\"(type))(type(instance(alias outer 1 1(type))(type(borrow 0))(type(func(param \"x\" 1)))(export \"f\"(func(type 2)))))(export \"example:test/api\"(instance(type 2)))))(export \"api\"(type 0)))"
  let first = @verifier.decode_wat_package(wat, source_id="first.wat").unwrap()
  let second = @verifier.decode_wat_package(
    wat.replace(old="example:test/api", new="example:other/api"),
    source_id="second.wat",
  ).unwrap()
  let source = @verifier.SourcePackage::{
    documents: [
      section_document(
        "root.wit", "package example:consumer; world app {import example:test/api;}",
      ),
    ],
  }
  let model = @verifier.resolve_packages(Source(source), dependencies=[
    Encoded(first),
    Encoded(second),
  ]).unwrap()
  assert_eq(model.worlds()[0].imports.length(), 2)
  let dep = model
    .interfaces()
    .filter(info => info.package_identity.name == "dep")[0]
  assert_eq(dep.types.length(), 1)
  for function in model.functions() {
    let parameter = model.types().filter(ty => ty.id == function.params[0].ty)[0]
    assert_eq(parameter.kind, Borrow(dep.types[0].ty))
  }
}
