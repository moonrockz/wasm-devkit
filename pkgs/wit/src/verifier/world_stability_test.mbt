///|
test "pinned world stability local-conflict" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "local-conflict.wit", "package example:test@2.0.0;interface i{}world a{@since(version=1.0.0) import i;}world b{@since(version=2.0.0) import i;}world c{include a;include b;}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_true(result is Err(_))
}

///|
test "pinned world stability local-upgrade" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "local-upgrade.wit", "package example:test@2.0.0;interface i{}world a{import i;}world b{@since(version=1.0.0) import i;}world c{include a;include b;}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "1", "interface", "example:test/i@2.0.0",
    "", "unknown", "0", "0", "worlds", "3", "world", "example:test/a@2.0.0", "",
    "unknown", "imports", "1", "example:test/i@2.0.0", "true", "interface", "", "unknown",
    "interface", "example:test/i@2.0.0", "", "unknown", "0", "0", "exports", "0",
    "world", "example:test/b@2.0.0", "", "unknown", "imports", "1", "example:test/i@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/i@2.0.0",
    "", "unknown", "0", "0", "exports", "0", "world", "example:test/c@2.0.0", "",
    "unknown", "imports", "1", "example:test/i@2.0.0", "true", "interface", "", "stable",
    "1.0.0", "", "interface", "example:test/i@2.0.0", "", "unknown", "0", "0", "exports",
    "0",
  ])
}

///|
test "pinned world stability local-preserve" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "local-preserve.wit", "package example:test@2.0.0;interface i{}world a{import i;}world b{@since(version=1.0.0) import i;}world c{include b;include a;}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "1", "interface", "example:test/i@2.0.0",
    "", "unknown", "0", "0", "worlds", "3", "world", "example:test/a@2.0.0", "",
    "unknown", "imports", "1", "example:test/i@2.0.0", "true", "interface", "", "unknown",
    "interface", "example:test/i@2.0.0", "", "unknown", "0", "0", "exports", "0",
    "world", "example:test/b@2.0.0", "", "unknown", "imports", "1", "example:test/i@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/i@2.0.0",
    "", "unknown", "0", "0", "exports", "0", "world", "example:test/c@2.0.0", "",
    "unknown", "imports", "1", "example:test/i@2.0.0", "true", "interface", "", "stable",
    "1.0.0", "", "interface", "example:test/i@2.0.0", "", "unknown", "0", "0", "exports",
    "0",
  ])
}

///|
test "pinned world stability external-clear" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "external-clear.wit", "package example:test@2.0.0;world a{@unstable(feature=active) import example:dep/i@2.0.0;include example:dep/a@2.0.0;}package example:dep@2.0.0{interface i{}world a{@since(version=1.0.0) import i;}}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "2", "example:dep@2.0.0", "example:test@2.0.0", "interfaces", "1",
    "interface", "example:dep/i@2.0.0", "", "unknown", "0", "0", "worlds", "2", "world",
    "example:dep/a@2.0.0", "", "unknown", "imports", "1", "example:dep/i@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:dep/i@2.0.0",
    "", "unknown", "0", "0", "exports", "0", "world", "example:test/a@2.0.0", "",
    "unknown", "imports", "1", "example:dep/i@2.0.0", "true", "interface", "", "unknown",
    "interface", "example:dep/i@2.0.0", "", "unknown", "0", "0", "exports", "0",
  ])
}

///|
test "pinned world stability external-unstable-conflict" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "external-unstable-conflict.wit", "package example:test@2.0.0;world a{@unstable(feature=active) import example:dep/i@2.0.0;include example:dep/a@2.0.0;}package example:dep@2.0.0{interface i{}world a{@unstable(feature=other) import i;}}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_true(result is Err(_))
}

///|
test "pinned world stability use-stability" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "use-stability.wit", "package example:test@2.0.0;interface base{resource r;}world a{@unstable(feature=active) use base.{r};}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "1", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "worlds", "1",
    "world", "example:test/a@2.0.0", "", "unknown", "imports", "2", "example:test/base@2.0.0",
    "true", "interface", "", "unstable", "active", "", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "r", "false", "type",
    "", "unstable", "active", "", "resource", "0", "exports", "0",
  ])
}

///|
test "pinned world stability import-chain" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "import-chain.wit", "package example:test@2.0.0;interface base{resource r;}interface middle{use base.{r};}interface leaf{use middle.{r};}world a{@since(version=1.0.0) import leaf;}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "3", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "interface", "example:test/leaf@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "interface", "example:test/middle@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "worlds", "1",
    "world", "example:test/a@2.0.0", "", "unknown", "imports", "3", "example:test/base@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "example:test/leaf@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/leaf@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "example:test/middle@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/middle@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "exports", "0",
  ])
}

///|
test "pinned world stability export-chain" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "export-chain.wit", "package example:test@2.0.0;interface base{resource r;}interface middle{use base.{r};}interface leaf{use middle.{r};}world a{@since(version=1.0.0) export leaf;}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "3", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "interface", "example:test/leaf@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "interface", "example:test/middle@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "worlds", "1",
    "world", "example:test/a@2.0.0", "", "unknown", "imports", "2", "example:test/base@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "example:test/middle@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/middle@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "exports", "1",
    "example:test/leaf@2.0.0", "true", "interface", "", "stable", "1.0.0", "", "interface",
    "example:test/leaf@2.0.0", "", "unknown", "1", "r", "", "unknown", "resource",
    "0", "0",
  ])
}

///|
test "pinned world stability export-dependency" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "export-dependency.wit", "package example:test@2.0.0;interface base{resource r;}interface leaf{use base.{r};}world a{export base;@since(version=1.0.0) export leaf;}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "2", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "interface", "example:test/leaf@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "worlds", "1",
    "world", "example:test/a@2.0.0", "", "unknown", "imports", "0", "exports", "2",
    "example:test/base@2.0.0", "true", "interface", "", "unknown", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "example:test/leaf@2.0.0",
    "true", "interface", "", "stable", "1.0.0", "", "interface", "example:test/leaf@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0",
  ])
}

///|
test "pinned world stability use-after-import" {
  let result = @verifier.resolve(
    {
      documents: [
        section_document(
          "use-after-import.wit", "package example:test@2.0.0;interface base{resource r;}world a{import base;@unstable(feature=active) use base.{r};}\n",
        ),
      ],
    },
    semantic_features={ enabled: ["active", "other"], all_enabled: false, },
  )
  assert_eq(model_projection(result.unwrap()), [
    "packages", "1", "example:test@2.0.0", "interfaces", "1", "interface", "example:test/base@2.0.0",
    "", "unknown", "1", "r", "", "unknown", "resource", "0", "0", "worlds", "1",
    "world", "example:test/a@2.0.0", "", "unknown", "imports", "2", "example:test/base@2.0.0",
    "true", "interface", "", "unknown", "interface", "example:test/base@2.0.0", "",
    "unknown", "1", "r", "", "unknown", "resource", "0", "0", "r", "false", "type",
    "", "unstable", "active", "", "resource", "0", "exports", "0",
  ])
}
