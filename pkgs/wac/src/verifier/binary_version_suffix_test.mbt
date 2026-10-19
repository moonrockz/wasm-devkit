///|
test "WAC canonical names retain raw pinned interface IDs" {
  for
    (text, identity) in [
      (
        "(component (type (instance)) (import \"test:dep/base@1\" (version-suffix \".2.3\") (instance (type 0))))",
        "test:dep/base@1",
      ),
      (
        "(component (type (instance)) (import \"local\" (implements \"test:dep/base@1\") (version-suffix \".2.3\") (instance (type 0))))",
        "test:dep/base@1",
      ),
      (
        "(component (type (instance)) (import \"test:dep/base@1.2.3-rc1\" (version-suffix \"+build\") (instance (type 0))))",
        "test:dep/base@1.2.3-rc1",
      ),
      (
        "(component (type (instance)) (import \"test:dep/base@1\" (version-suffix \".0.0-rc\") (instance (type 0))))",
        "test:dep/base@1",
      ),
      (
        "(component (type (instance)) (import \"local\" (implements \"test:dep/base@1.2.3\") (version-suffix \"\") (instance (type 0))))",
        "test:dep/base@1.2.3",
      ),
      (
        "(component (type (instance)) (import \"local\" (implements \"test:dep/base@1\") (instance (type 0))))",
        "test:dep/base@1",
      ),
      (
        "(component (type (instance)) (import \"test:dep/base\" (version-suffix \".0.0\") (instance (type 0))))",
        "test:dep/base",
      ),
      (
        "(component (import \"local\" (implements \"test:dep/base@α\") (version-suffix \"β\") (instance)))",
        "test:dep/base@α",
      ),
      (
        "(component (import \"local\" (implements \"test:dep/base@\") (instance)))",
        "test:dep/base@",
      ),
    ] {
    let result = @verifier.decode_wat_component_package(text)
    guard result is Ok(model) else { fail(result.unwrap_err()[0].render()) }
    let names = model
      .types()
      .iter()
      .filter_map(info => {
        match info.kind {
          Interface(Some(name), _, _) => Some(name)
          _ => None
        }
      })
      .to_array()
    assert_eq(names, [identity])
    assert_eq(
      binary_projection(model),
      binary_projection(
        @verifier.decode_component_package(model.bytes()).unwrap(),
      ),
    )
  }
}
