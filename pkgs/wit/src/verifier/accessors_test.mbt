///|
fn accessor_model(
  text : String,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(
    @parser.parse(text, features=@parser.Features::reference()),
    source=text,
    source_id="accessors.wit",
  )
}

///|
test "accessors expose flavor mangling receivers and reference-permitted differing value types" {
  let text = "package example:app;interface api{p:set(value:string);p:get()->u8;resource r{position:get()->u64;position:set(value:u32);limit:static get()->u32;limit:static set(value:u32)->result<_,string>;}}"
  let model = accessor_model(text).unwrap()
  let functions = model.interfaces()[0].functions
  assert_eq(functions[0].name, "[get]p")
  assert_eq(functions[0].flavor, Getter)
  assert_eq(functions[0].kind, Freestanding)
  assert_eq(functions[0].params.length(), 0)
  assert_eq(functions[1].name, "[set]p")
  assert_eq(functions[1].flavor, Setter)
  let resource = model.types().filter(t => t.kind is Resource)[0].id
  assert_eq(functions[2].name, "[method][get]r.position")
  assert_eq(functions[2].kind, Method(resource))
  assert_eq(functions[2].params.length(), 1)
  assert_eq(functions[2].params[0].name, "self")
  assert_eq(functions[3].params.length(), 2)
  assert_eq(functions[4].name, "[static][get]r.limit")
  assert_eq(functions[4].kind, Static(resource))
  assert_eq(functions[4].params.length(), 0)
  assert_eq(functions[5].params.length(), 1)
  assert_eq(model.text(), text)
  assert_eq(accessor_model(text).unwrap().functions(), model.functions())
}

///|
test "accessor signature arity result and borrow restrictions follow the pinned resolver" {
  for
    body in [
      "p:get();", "p:get(x:u8)->u8;", "p:get()->u8;p:set();", "p:get()->u8;p:set(x:u8,y:u8);",
      "p:get()->u8;p:set(x:u8)->u8;", "p:get()->u8;p:set(x:u8)->result<u8,string>;",
      "resource r;p:get()->borrow<r>;", "resource r;p:get()->u8;p:set(x:u8)->result<_,future<borrow<r>>>;",
      "type out=result<_,string>;type alias=out;p:get()->u8;p:set(x:u8)->alias;",
    ] {
    let text = "package example:app;interface api{" + body + "}"
    assert_true(
      @parser.parse(text, features=@parser.Features::reference()).is_valid(),
    )
    assert_true(
      accessor_model(text) is Err(errors) &&
      errors.any(d => d.code == "WIT-S007"),
    )
  }
  for
    body in [
      "p:get()->u8;", "p:get()->u8;p:set(x:u8)->result;", "type out=result<_,string>;p:get()->u8;p:set(x:u8)->out;",
      "resource r{p:get()->u8;p:set(x:u8);}",
    ] {
    assert_true(
      accessor_model("package example:app;interface api{" + body + "}") is Ok(_),
    )
  }
}

///|
test "setters require an exact getter in the same interface and resource function kind" {
  for
    body in [
      "p:set(x:u8);", "p:get()->u8;P:set(x:u8);", "max-size:get()->u8;maxsize:set(x:u8);",
      "resource r{p:get()->u8;p:static set(x:u8);}",
    ] {
    let text = "package example:app;interface api{" + body + "}"
    guard accessor_model(text) is Err(errors) else {
      fail("orphan setter accepted")
    }
    assert_true(
      errors.any(d => {
        d.code == "WIT-S007" && d.message.contains("corresponding getter")
      }),
    )
  }
  for
    body in [
      "p:get()->u8;p:func();", "type p=u8;p:get()->u8;", "p:get()->u8;P:get()->u8;",
      "p:get()->u8;p:set(x:u8);p:set(x:u8);", "resource r{r:get()->u8;}", "resource r{r:set(x:u8);}",
    ] {
    assert_true(
      accessor_model("package example:app;interface api{" + body + "}")
      is Err(errors) &&
      errors.any(d => d.code == "WIT-S004"),
    )
  }
}

///|
test "world pairing waits for includes and keeps import and export scopes separate" {
  let model = accessor_model(
    "package example:app;world base{import p:get()->u8;}world app{import p:set(x:string);include base;}",
  ).unwrap()
  let world = model.select_world(name=Some("app")).unwrap()
  assert_eq(world.imports[0].name, "[get]p")
  assert_eq(world.imports[1].name, "[set]p")
  for
    body in [
      "import p:get()->u8;export p:set(x:u8);", "export p:get()->u8;import p:set(x:u8);",
      "import p:set(x:u8);", "include base;export p:set(x:u8);",
    ] {
    assert_true(
      accessor_model(
        "package example:app;world base{import p:get()->u8;}world app{" +
        body +
        "}",
      )
      is Err(errors) &&
      errors.any(d => d.code == "WIT-S007"),
    )
  }
}

///|
test "include property and resource renames preserve paired names and fresh receivers" {
  let model = accessor_model(
    "package example:app;world base{import p:set(x:u8);import p:get()->u8;resource r{position:set(x:u8);position:get()->u8;}}world app{include base with{p as q,r as s}}",
  ).unwrap()
  let world = model.select_world(name=Some("app")).unwrap()
  for
    name in [
      "[get]q", "[set]q", "[method][get]s.position", "[method][set]s.position",
    ] {
    assert_true(world.imports.any(item => item.name == name))
    assert_true(model.functions().any(f => f.name == name))
  }
  let resource = model.types().filter(t => t.name == Some("s"))[0].id
  let methods = model.functions().filter(f => f.kind == Method(resource))
  assert_eq(methods.length(), 2)
  for f in methods {
    assert_true(
      model
      .types()
      .any(t => t.id == f.params[0].ty && t.kind == Borrow(resource)),
    )
  }
}

///|
test "accessor ordering moves early setters while preserving already ordered gaps" {
  let model = accessor_model(
    "package example:app;interface api{p:get()->u8;middle:func();p:set(x:u8);q:set(x:u8);between:func();q:get()->u8;}",
  ).unwrap()
  assert_eq(model.interfaces()[0].functions.map(f => f.name), [
    "[get]p", "middle", "[set]p", "between", "[get]q", "[set]q",
  ])
}

///|
test "caller-built asynchronous accessor signatures reject without a public panic" {
  let text = "package example:app;interface api{p:get()->u8;}"
  let parsed = @parser.parse(text, features=@parser.Features::reference())
  let ast : @ast.Tree = {
    nodes: parsed.ast.nodes.map(node => {
      match node.data {
        Signature(params~, result~, flavor~, ..) =>
          {
            ..node,
            data: Signature(params~, result~, flavor~, asynchronous=true),
          }
        _ => node
      }
    }),
  }
  assert_true(ast.validate())
  assert_true(
    @verifier.verify_ast(ast, source=text) is Err(errors) &&
    errors.any(d => d.code == "WIT-S001"),
  )
  assert_false(@parser.parse(text).is_valid())
  assert_true(@parser.parse(text, features=@parser.Features::all()).is_valid())
}

///|
test "deep accessor includes and wide orphan setter diagnostics remain stack safe" {
  let source = StringBuilder()
  source.write_string(
    "package example:app;world base{resource r{p:set(x:u8);p:get()->u8;}}",
  )
  for i in 0..<2000 {
    let parent = if i == 0 { "base" } else { "w\{i-1}" }
    source.write_string("world w\{i}{include " + parent + ";}")
  }
  let model = accessor_model(source.to_string()).unwrap()
  let world = model.select_world(name=Some("w1999")).unwrap()
  assert_eq(world.imports[1].name, "[method][get]r.p")
  assert_eq(world.imports[2].name, "[method][set]r.p")
  let invalid = StringBuilder()
  invalid.write_string("package example:app;interface api{")
  for i in 0..<5000 {
    invalid.write_string("p\{i}:set(x:u8);")
  }
  invalid.write_string("}")
  assert_true(
    accessor_model(invalid.to_string()) is Err(errors) &&
    errors.length() == 5000,
  )
}

///|
test "included getter mismatches label the original dependency and local setter" {
  let root = "package example:app;world app{import P:set(x:u8);include example:dep/base;}"
  let dep = "package example:dep;world base{import p:get()->u8;}"
  let result = @verifier.resolve(
    {
      documents: [
        @verifier.Document::from_parse(
          "root.wit",
          root,
          @parser.parse(root, features=@parser.Features::reference()),
        ),
      ],
    },
    dependencies=[
      {
        documents: [
          @verifier.Document::from_parse(
            "dep.wit",
            dep,
            @parser.parse(dep, features=@parser.Features::reference()),
          ),
        ],
      },
    ],
  )
  guard result is Err(errors) else { fail("inexact getter accepted") }
  assert_eq(errors[0].primary.location.source, "root.wit")
  assert_eq(errors[0].code, "WIT-S007")
  assert_eq(errors[0].related[0].location.source, "dep.wit")
}

///|
test "law: generated accessor pairs retain nominal receiver and value types through includes" {
  @quickcheck.check(
    (picks : Array[Byte]) => {
      let source = StringBuilder()
      source.write_string("package example:app;world base{resource r{")
      for i, pick in picks {
        let modifier = if pick.to_int() % 2 == 0 { "" } else { "static " }
        let getter = "p\{i}:" + modifier + "get()->r;"
        let setter = "p\{i}:" +
          modifier +
          "set(value:borrow<r>)" +
          (if pick.to_int() % 3 == 0 { "->result<_,string>" } else { "" }) +
          ";"
        source.write_string(
          if pick.to_int() % 4 < 2 {
            getter + setter
          } else {
            setter + getter
          },
        )
      }
      source.write_string("}}world app{include base with{r as s}}")
      let text = source.to_string()
      guard accessor_model(text) is Ok(model) else { return false }
      let types = model.types()
      let functions = model.functions()
      functions.all(f => {
        let resource = match f.kind {
          Method(id) | Static(id) => id
          _ => return false
        }
        if f.flavor is Getter {
          types.any(t => Some(t.id) == f.result && t.kind == Own(resource))
        } else {
          f.flavor is Setter &&
          functions.any(g => {
            g.name == f.name.replace(old="[set]", new="[get]") &&
            g.kind == f.kind
          }) &&
          f.params.all(p => {
            types.any(t => t.id == p.ty && t.kind == Borrow(resource))
          })
        }
      }) &&
      model.text() == text &&
      accessor_model(text) is Ok(again) &&
      again.functions() == functions
    },
    count=150,
    max_size=64,
    seed=2620142,
  )
}
