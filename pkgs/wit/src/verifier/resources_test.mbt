///|
fn resource_model(
  text : String,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(
    @parser.parse(text, features=@parser.Features::reference()),
    source=text,
    source_id="resource.wit",
  )
}

///|
test "resource functions expose nominal targets implicit receivers and owned constructor results" {
  let model = resource_model(
    "package example:app;interface api{resource r{constructor(value:u8);read:async func(x:u8)->r;make:static async func()->r;}read:async func();}",
  ).unwrap()
  let resource = model.types().filter(t => t.kind is Resource)[0].id
  let functions = model.interfaces()[0].functions
  assert_eq(functions.length(), 4)
  assert_eq(functions[0].name, "[constructor]r")
  assert_eq(functions[0].kind, Constructor(resource))
  assert_eq(functions[0].params.length(), 1)
  assert_false(functions[0].asynchronous)
  assert_true(
    model
    .types()
    .any(t => Some(t.id) == functions[0].result && t.kind == Own(resource)),
  )
  assert_eq(functions[1].name, "[method]r.read")
  assert_eq(functions[1].kind, Method(resource))
  assert_eq(functions[1].params.length(), 2)
  assert_eq(functions[1].params[0].name, "self")
  assert_true(
    model
    .types()
    .any(t => t.id == functions[1].params[0].ty && t.kind == Borrow(resource)),
  )
  assert_true(functions[1].asynchronous)
  assert_eq(functions[2].kind, Static(resource))
  assert_eq(functions[2].params.length(), 0)
  assert_true(functions[2].asynchronous)
  assert_eq(functions[3].kind, Freestanding)
  assert_true(functions[3].asynchronous)
}

///|
test "fallible constructors require a direct resource success type" {
  for
    output in ["result<r,string>", "result<own<r>,string>", "result<r>", "out"] {
    let text = "package example:app;interface api{resource r{constructor()->" +
      output +
      ";}type out=result<r,string>;}"
    assert_true(resource_model(text) is Ok(_))
  }
  for
    output in [
      "own<r>", "u8", "result", "result<_,string>", "result<other,string>", "result<alias,string>",
      "result<own<alias>,string>", "result<borrow<r>,string>", "result<r,borrow<r>>",
      "out-alias",
    ] {
    let text = "package example:app;interface api{resource other;resource r{constructor()->" +
      output +
      ";}type alias=r;type out=result<r,string>;type out-alias=out;}"
    guard resource_model(text) is Err(errors) else {
      fail("invalid constructor accepted")
    }
    assert_true(errors.any(d => d.code == "WIT-S007"))
  }
}

///|
test "resource component names and explicit receiver parameters are strongly unique" {
  for
    body in [
      "constructor();constructor();", "read:func();read:static func();", "read-value:func();READVALUE:async func();",
      "r:func();", "R:static func();", "read:func(self:u8);", "read:func(s-elf:u8);",
    ] {
    let text = "package example:app;interface api{resource r{" + body + "}}"
    guard resource_model(text) is Err(errors) else {
      fail("name conflict accepted")
    }
    assert_true(errors.any(d => d.code == "WIT-S004"))
  }
  assert_true(
    resource_model(
      "package example:app;interface api{resource r{%constructor:func();constructor();read:static func(self:u8);}}",
    )
    is Ok(_),
  )
  assert_true(
    resource_model(
      "package example:app;interface api{resource r;resource r{constructor();}}",
    )
    is Err(_),
  )
}

///|
test "world includes rename resource functions and remap their nominal contracts" {
  let model = resource_model(
    "package example:app;world base{resource r{constructor();read:func()->r;make:static async func();}}world app{include base with{r as s}}",
  ).unwrap()
  let world = model.select_world(name=Some("app")).unwrap()
  let resource = model.types().filter(t => t.name == Some("s"))[0].id
  assert_true(world.imports.any(i => i.name == "[constructor]s"))
  assert_true(world.imports.any(i => i.name == "[method]s.read"))
  assert_true(world.imports.any(i => i.name == "[static]s.make"))
  let functions = model.functions().filter(f => f.kind == Method(resource))
  assert_eq(functions.length(), 1)
  assert_true(
    model
    .types()
    .any(t => t.id == functions[0].params[0].ty && t.kind == Borrow(resource)),
  )
  assert_true(
    model
    .types()
    .any(t => Some(t.id) == functions[0].result && t.kind == Own(resource)),
  )
  assert_true(
    resource_model(
      "package example:app;world base{resource r{read:func();}}world app{include base with{r as read}}",
    )
    is Err(errors) &&
    errors.any(d => d.code == "WIT-S004"),
  )
}

///|
test "included anonymous resource methods retain source provenance and fresh nominal identity" {
  let text = "package example:app;world base{import host:interface{resource r{constructor();read:func()->r;}}}world app{include base;}"
  let model = resource_model(text).unwrap()
  let interfaces = model.interfaces()
  assert_eq(interfaces.length(), 2)
  let a = interfaces[0].functions[1]
  let b = interfaces[1].functions[1]
  assert_false(a.kind == b.kind)
  assert_false(a.id == b.id)
  assert_eq(a.location, b.location)
  assert_true(
    model
    .types()
    .any(t => t.id == b.params[0].ty && t.scope == interfaces[1].id),
  )
  assert_eq(model.text(), text)
  assert_eq(resource_model(text).unwrap().types(), model.types())
}

///|
test "deep resource includes and nominal alias chains use explicit work stacks" {
  let source = StringBuilder()
  source.write_string(
    "package example:app;world base{resource r{constructor();read:func()->r;}}",
  )
  for i in 0..<2000 {
    let parent = if i == 0 { "base" } else { "w\{i-1}" }
    source.write_string("world w\{i}{include " + parent + ";}")
  }
  let model = resource_model(source.to_string()).unwrap()
  let world = model.select_world(name=Some("w1999")).unwrap()
  assert_eq(world.imports.length(), 3)
  assert_eq(model.functions().length(), 4002)
  assert_eq(model.types().filter(t => t.kind is Resource).length(), 2001)
}

///|
test "law: include renaming preserves checked constructor and receiver contracts" {
  @quickcheck.check(
    (depth : Byte) => {
      let source = StringBuilder()
      source.write_string(
        "package example:app;world base{resource r0{constructor();read:async func()->r0;make:static func()->r0;}}",
      )
      for i in 0..<(depth.to_int() % 32) {
        let parent = if i == 0 { "base" } else { "w\{i-1}" }
        source.write_string(
          "world w\{i}{include " + parent + " with{r\{i} as r\{i+1}}}",
        )
      }
      let text = source.to_string()
      guard resource_model(text) is Ok(model) else { return false }
      let types = model.types()
      model
      .functions()
      .all(f => {
        match f.kind {
          Constructor(resource) =>
            types.any(t => Some(t.id) == f.result && t.kind == Own(resource)) &&
            types.any(t => {
              t.id == resource &&
              Some("[constructor]" + t.name.unwrap_or("")) == Some(f.name)
            })
          Method(resource) =>
            f.params.length() == 1 &&
            f.params[0].name == "self" &&
            types.any(t => t.id == f.params[0].ty && t.kind == Borrow(resource)) &&
            types.any(t => Some(t.id) == f.result && t.kind == Own(resource))
          Static(resource) =>
            f.params.is_empty() &&
            types.any(t => Some(t.id) == f.result && t.kind == Own(resource))
          Freestanding => false
        }
      }) &&
      model.text() == text
    },
    count=100,
    seed=2620141,
  )
}

///|
test "look-alike resources retain distinct nominal identities through use renames and exports" {
  let model = resource_model(
    "package example:app;interface left{resource r;}interface right{resource r;}interface api{use left.{r as a};use right.{r as b};f:func(x:own<a>,y:borrow<b>)->b;}world app{export api;}",
  ).unwrap()
  let types = model.types()
  let resources = types.filter(t => t.kind is Resource)
  assert_eq(resources.length(), 2)
  assert_eq(resources[0].name, resources[1].name)
  assert_false(resources[0].id == resources[1].id)
  let function = model.functions()[0]
  assert_true(
    types.any(t => {
      t.id == function.params[0].ty && t.kind == Own(resources[0].id)
    }),
  )
  assert_true(
    types.any(t => {
      t.id == function.params[1].ty && t.kind == Borrow(resources[1].id)
    }),
  )
  assert_true(
    types.any(t => {
      Some(t.id) == function.result && t.kind == Own(resources[1].id)
    }),
  )
  assert_eq(model.select_world(name=Some("app")).unwrap().imports.length(), 2)
}

///|
test "supplied dependency resources preserve distinct identities in renamed handle signatures" {
  let root = "package example:app;interface api{use example:left/api.{r as a};use example:right/api.{r as b};f:func(x:own<a>,y:borrow<b>)->b;}world app{export api;}"
  let left = "package example:left;interface api{resource r;}"
  let right = "package example:right;interface api{resource r;}"
  let source_package = fn(
    id : String,
    text : String,
  ) -> @verifier.SourcePackage {
    {
      documents: [
        @verifier.Document::from_parse(
          id,
          text,
          @parser.parse(text, features=@parser.Features::reference()),
        ),
      ],
    }
  }
  let root_package = source_package("root.wit", root)
  let left_package = source_package("left.wit", left)
  let right_package = source_package("right.wit", right)
  let model = @verifier.resolve(root_package, dependencies=[
    right_package, left_package,
  ]).unwrap()
  let resources = model.types().filter(t => t.kind is Resource)
  assert_eq(resources.length(), 2)
  assert_false(resources[0].id == resources[1].id)
  assert_eq(resources[0].location.source, "left.wit")
  assert_eq(resources[1].location.source, "right.wit")
  let function = model.functions()[0]
  assert_true(
    model
    .types()
    .any(t => t.id == function.params[0].ty && t.kind == Own(resources[0].id)),
  )
  assert_true(
    model
    .types()
    .any(t => t.id == function.params[1].ty && t.kind == Borrow(resources[1].id)),
  )
  assert_true(
    model
    .types()
    .any(t => Some(t.id) == function.result && t.kind == Own(resources[1].id)),
  )
  assert_eq(
    model.types(),
    @verifier.resolve(root_package, dependencies=[left_package, right_package])
    .unwrap()
    .types(),
  )
}
