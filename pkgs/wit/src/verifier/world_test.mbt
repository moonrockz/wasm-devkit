///|
fn world_model(
  text : String,
) -> Result[@verifier.Resolution, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.resolve({
    documents: [
      @verifier.Document::from_parse(
        "world.wit",
        text,
        @parser.parse(text, features=@parser.Features::reference()),
      ),
    ],
  })
}

///|
test "includes and renames preserve original function and type provenance" {
  let text = "package example:app; world base {type t=u8; import f:func(a:t)->t; export g:func();} world app {include base with {f as host,g as run,t as item}}"
  let model = world_model(text).unwrap()
  let base = model.select_world(name=Some("base")).unwrap()
  let app = model.select_world(name=Some("app")).unwrap()
  assert_eq(app.imports.length(), 2)
  assert_true(app.imports.any(item => item.name == "host"))
  assert_true(app.imports.any(item => item.name == "item"))
  assert_eq(app.exports[0].name, "run")
  assert_eq(app.exports[0].location, base.exports[0].location)
  assert_false(app.exports[0].kind == base.exports[0].kind)
  assert_true(
    model
    .functions()
    .any(f => f.name == "f" && f.params.length() == 1 && f.result is Some(_)),
  )
}

///|
test "canonical interface include diamonds merge while named and function duplicates fail" {
  let model = world_model(
    "package example:app; interface api {} world base {import api;} world left {include base;} world right {include base;} world app {include left;include right;}",
  ).unwrap()
  let app = model.select_world(name=Some("app")).unwrap()
  assert_eq(app.imports.length(), 1)
  assert_true(app.imports[0].by_id)
  for
    body in [
      "world base {import f:func();} world app {include base;include base;}", "world base {type t=u8;} world app {include base;include base;}",
      "interface api {} world base {import local:api;} world app {include base;include base;}",
      "interface api {} world app {import api;import api;}", "world base {import f:func();import g:func();} world app {include base with {f as same,g as same}}",
      "world base {import f:func();} world app {include base with {missing as renamed}}",
      "interface api {} world base {import api;} world app {include base with {api as renamed}}",
    ] {
    assert_true(world_model("package example:app;" + body) is Err(_))
  }
}

///|
test "world elaboration inserts transitive interface dependencies with compatible export paths" {
  let prefix = "package example:app; interface base {type t=u8;} interface api {use base.{t}; f:func()->t;} "
  let model = world_model(prefix + "world app {export api;}").unwrap()
  let world = model.select_world().unwrap()
  assert_eq(world.imports[0].name, "example:app/base")
  assert_eq(world.exports[0].name, "example:app/api")
  let both = world_model(prefix + "world app {export api;export base;}")
    .unwrap()
    .select_world()
    .unwrap()
  assert_true(both.imports.is_empty())
  assert_eq(both.exports.length(), 2)
  let imported = world_model(prefix + "world app {import api;export base;}")
    .unwrap()
    .select_world()
    .unwrap()
  assert_eq(imported.imports.length(), 2)
  let invalid = "package example:app; interface base {type t=u8;} interface middle {use base.{t};} interface api {use middle.{t};} world app {export base;export api;}"
  assert_true(
    world_model(invalid) is Err(errors) && errors.any(d => d.code == "WIT-S012"),
  )
}

///|
test "inline world interfaces and uses expose checked function type metadata" {
  let model = world_model(
    "package example:app; interface api {type t=u8;} world app {use api.{t}; import host:interface{use api.{t}; call:func(value:t)->t;} export run:func()->t;}",
  ).unwrap()
  let world = model.select_world().unwrap()
  assert_true(
    world.imports.any(item => item.name == "example:app/api" && item.by_id),
  )
  let inline_ = model.interfaces().filter(i => i.name is None)
  assert_eq(inline_.length(), 1)
  assert_eq(inline_[0].functions[0].name, "call")
  assert_eq(inline_[0].functions[0].params[0].name, "value")
  let ids = model.types().map(t => t.id)
  assert_true(ids.contains(inline_[0].functions[0].params[0].ty))
  assert_true(model.select_world(name=Some("app")) is Ok(_))
}

///|
test "world selection rejects missing and ambiguous choices with candidate locations" {
  let model = world_model(
    "package example:app@1.0.0; world first {} world second {}",
  ).unwrap()
  guard model.select_world() is Err(errors) else {
    fail("ambiguous selection accepted")
  }
  assert_eq(errors[0].code, "WIT-S010")
  assert_eq(errors[0].related.length(), 2)
  assert_true(
    model.select_world(name=Some("missing")) is Err(errors) &&
    errors[0].code == "WIT-S005",
  )
  assert_eq(
    model.select_world(name=Some("example:app/second@1.0.0")).unwrap().name,
    "second",
  )
  assert_true(model.select_world(name=Some("example:app@1.0.0")) is Err(_))
}

///|
test "file aliases refer to direct declarations and remain file local" {
  let document = fn(id : String, text : String) {
    @verifier.Document::from_parse(
      id,
      text,
      @parser.parse(text, features=@parser.Features::reference()),
    )
  }
  let model = @verifier.resolve({
    documents: [
      document("a.wit", "package example:app; interface api {resource item;}"),
      document(
        "b.wit", "use api as other; interface consumer {use other.{item};}",
      ),
    ],
  }).unwrap()
  assert_eq(model.types().filter(t => t.kind is Resource).length(), 1)
  assert_true(
    @verifier.resolve({
      documents: [
        document("a.wit", "package example:app; interface api {resource item;}"),
        document("b.wit", "use api as other;"),
        document("c.wit", "interface consumer {use other.{item};}"),
      ],
    })
    is Err(_),
  )
  assert_true(
    world_model(
      "package example:app;use api as other;use other as third;interface api {}",
    )
    is Err(_),
  )
}

///|
test "deep world includes are stack safe and leave input immutable" {
  let source = StringBuilder()
  source.write_string("package example:app;world base{import f:func();}")
  for i in 0..<5000 {
    source.write_string(
      "world w\{i}{include " + (if i == 0 { "base" } else { "w\{i-1}" }) + ";}",
    )
  }
  let text = source.to_string()
  let model = world_model(text).unwrap()
  assert_eq(model.select_world(name=Some("w4999")).unwrap().imports.length(), 1)
  assert_eq(model.sources()[0].text, text)
  assert_eq(model.world_summary(), world_model(text).unwrap().world_summary())
}

///|
test "world includes freshen owned resources and preserve their original provenance" {
  let model = world_model(
    "package example:app; world base {resource first;resource second;} world app {include base with {first as resource-a,second as resource-b}}",
  ).unwrap()
  let base = model.select_world(name=Some("base")).unwrap()
  let app = model.select_world(name=Some("app")).unwrap()
  assert_false(app.imports[0].kind == base.imports[0].kind)
  assert_false(app.imports[1].kind == base.imports[1].kind)
  assert_false(app.imports[0].kind == app.imports[1].kind)
}

///|
test "malformed inline AST names and include selectors fail without a public panic" {
  let text = "package example:app; world app {import host:interface{}}"
  let parsed = @parser.parse(text)
  let ast : @ast.Tree = {
    nodes: parsed.ast.nodes.map(node => {
      match node.data {
        Interface(..) =>
          { ..node, data: Interface(name="named", attributes=[], items=[]), }
        _ => node
      }
    }),
  }
  assert_true(ast.validate())
  assert_true(@verifier.verify_ast(ast, source=text) is Err(_))
}

///|
test "included anonymous interfaces freshen resource identities and rewrite their signatures" {
  let model = world_model(
    "package example:app; world base{import host:interface{resource r; f:func(x:r)->r;}} world app{include base;}",
  ).unwrap()
  let base = model.select_world(name=Some("base")).unwrap()
  let app = model.select_world(name=Some("app")).unwrap()
  assert_false(base.imports[0].kind == app.imports[0].kind)
  let resources = model.types().filter(t => t.kind is Resource)
  assert_eq(resources.length(), 2)
  assert_false(resources[0].scope == resources[1].scope)
  assert_eq(resources[0].location, resources[1].location)
  assert_true(model.origin(resources[1].id) is Some(_))
  let interfaces = model.interfaces().filter(i => i.name is None)
  assert_eq(interfaces.length(), 2)
  assert_false(interfaces[0].functions[0].id == interfaces[1].functions[0].id)
  assert_false(
    interfaces[0].functions[0].params[0].ty ==
    interfaces[1].functions[0].params[0].ty,
  )
}

///|
test "included aliases to named interface resources preserve the external resource" {
  let model = world_model(
    "package example:app; interface api{resource r;} world base{use api.{r};} world app{include base with{r as handle}} ",
  ).unwrap()
  assert_eq(model.types().filter(t => t.kind is Resource).length(), 1)
  assert_true(
    model.select_world(name=Some("app")).unwrap().imports.any(i => {
      i.name == "handle"
    }),
  )
}

///|
test "strong world name conflicts do not collapse case-distinct canonical interfaces" {
  assert_true(
    world_model(
      "package example:app;world app{import f:func();import F:func();}",
    )
    is Err(errors) &&
    errors.any(d => d.code == "WIT-S004"),
  )
  let model = world_model(
    "package example:app;interface api{}interface API{}world app{import api;import API;}",
  ).unwrap()
  assert_eq(model.select_world().unwrap().imports.length(), 2)
}

///|
test "world named keys remove hyphens while canonical interface IDs keep their spelling" {
  for
    body in [
      "import a-b:func();import ab:func();", "export a-b:interface{}export ab:interface{}",
      "resource a-b;import ab:func();", "include base;import ab:func();",
    ] {
    assert_true(
      world_model(
        "package example:app;world base{import a-b:func();}world app{" +
        body +
        "}",
      )
      is Err(errors) &&
      errors.any(d => d.code == "WIT-S004"),
    )
  }
  assert_true(
    world_model(
      "package example:app;interface a-b{}interface ab{}world app{import a-b;import ab;}",
    )
    is Ok(_),
  )
}
