///|
test "empty use selections resolve names without introducing world imports" {
  for
    body in [
      "interface api {}world app {use api.{};}", "interface api {type item=u32;}world app {use api.{};}",
      "interface base {}interface api {use base.{};}world app {import api;}",
    ] {
    let result = section_model("package example:empty;" + body).unwrap()
    let world = result.worlds()[0]
    assert_eq(
      world.imports.length(),
      if body.contains("import api") {
        1
      } else {
        0
      },
    )
  }
}

///|
test "empty use selections retain missing name kind and cycle checks" {
  for
    body in [
      "interface api {use api.{};}", "interface a {use b.{};}interface b {use a.{};}",
      "interface api {use missing.{};}", "world target {}interface api {use target.{};}",
    ] {
    assert_true(section_model("package example:empty;" + body) is Err(_))
  }
}
