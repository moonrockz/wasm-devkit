///|
test "pinned ordered declarations alias-expression" {
  let source = "package example:app;type t=u8;let x=t;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations function-alias" {
  let source = "package example:app;import f: func();type t=f;import g: t;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations composites" {
  let source = "package example:app;type a=list<tuple<option<u8>,result<string,u32>>>;type f=future<u8>;type s=stream<string>;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations root-in-interface" {
  let source = "package example:app;type a=u8;interface api{type b=a;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations local-interface" {
  let source = "package example:app;interface api{type a=u8;type b=a;f: func(x: b)->a;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations interface-func-name" {
  let source = "package example:app;interface api{f: func();g: f;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations interface-func-type" {
  let source = "package example:app;interface api{type f=func();g: f;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations resource-alias" {
  let source = "package example:app;interface api{resource r{constructor();m: func(x: borrow<r>)->r;s: static func()->r;}type alias=r;f: func(x: borrow<alias>)->alias;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations borrow-result" {
  let source = "package example:app;interface api{resource r;type a=list<borrow<r>>;f: func()->a;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations method-self" {
  let source = "package example:app;interface api{resource r{m: func(self: u8);}}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations static-self" {
  let source = "package example:app;interface api{resource r{m: static func(self: u8);}}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations constructor-self" {
  let source = "package example:app;interface api{resource r{constructor(self: u8);}}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations duplicate-method" {
  let source = "package example:app;interface api{resource r{m: func();m: static func();}}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations duplicate-constructor" {
  let source = "package example:app;interface api{resource r{constructor();constructor();}}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations world-use" {
  let source = "package example:app;interface api{resource r;type id=u32;}world app{use api.{r,id};export f: func(x: borrow<r>)->id;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-local-root" {
  let source = "package example:app;type f=func();interface api{f: func();}world app{import x: f;export api;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-direct-func" {
  let source = "package example:app;type f=func();world app{import f;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations world-import-not-local" {
  let source = "package example:app;world app{import f: func();export g: f;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations world-use-forward" {
  let source = "package example:app;world app{use api.{id};}interface api{type id=u32;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations use-function" {
  let source = "package example:app;interface a{f: func();}interface b{use a.{f};}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations use-function-type" {
  let source = "package example:app;interface a{type f=func();}interface b{use a.{f};}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations use-rename" {
  let source = "package example:app;interface a{resource r;type id=u32;}interface b{use a.{r as handle,id as number};f: func(x: handle)->number;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations include" {
  let source = "package example:app;world a{import f: func();export g: func();}world b{include a with{f as ff,g as gg};}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations include-conflict" {
  let source = "package example:app;world a{import f: func();}world b{include a;import f: func(x: u8);}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations include-missing" {
  let source = "package example:app;world a{}world b{include a with{missing as x};}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations include-repeat-qualified" {
  let source = "package example:app;interface api{}world a{import api;}world b{include a;include a;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations include-repeat-bare" {
  let source = "package example:app;world a{import x: func();}world b{include a;include a;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations root-type-export-conflict" {
  let source = "package example:app;type t=u8;import f: func();export f as \"t\";"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations root-export-type-conflict" {
  let source = "package example:app;import f: func();export f as \"t\";type t=u8;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations root-type-export" {
  let source = "package example:app;type t=u8;export t as \"other\";"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations import-type" {
  let source = "package example:app;type t=u8;import a: t;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations import-instance" {
  let source = "package example:app;interface api{}import x: api;import y: x;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations inline-import" {
  let source = "package example:app;import x: interface{type t=u8;f: func(x: t);};"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-resource" {
  let source = "package example:app;world app{resource r{constructor();m: func()->r;}export f: func(x: r);}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-same-import-export" {
  let source = "package example:app;world app{import f: func();export f: func(x: u8);}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-import-type-conflict" {
  let source = "package example:app;world app{import t: func();type t=u8;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations world-type-import-conflict" {
  let source = "package example:app;world app{type t=u8;import t: func();}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations interface-func-type-conflict" {
  let source = "package example:app;interface api{f: func();type f=u8;}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations interface-type-func-conflict" {
  let source = "package example:app;interface api{type f=u8;f: func();}"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations root-async" {
  let source = "package example:app;import f: async func()->future<u8>;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations root-version" {
  let source = "package example:app@1.2.3;"
  assert_true(@parser.parse(source).is_valid())
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-0-import" {
  let source = "package example:app; import f as \"[constructor]r\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-0-export" {
  let source = "package example:app; import f: func(); export f as \"[constructor]r\";"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-1-import" {
  let source = "package example:app; import f as \"[method]r.f\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-1-export" {
  let source = "package example:app; import f: func(); export f as \"[method]r.f\";"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-2-import" {
  let source = "package example:app; import f as \"[static]r.f\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-2-export" {
  let source = "package example:app; import f: func(); export f as \"[static]r.f\";"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-3-import" {
  let source = "package example:app; import f as \"[get]f\": func();"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-3-export" {
  let source = "package example:app; import f: func(); export f as \"[get]f\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-4-import" {
  let source = "package example:app; import f as \"url=<>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-4-export" {
  let source = "package example:app; import f: func(); export f as \"url=<>\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-5-import" {
  let source = "package example:app; import f as \"url=<https://example.com>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-5-export" {
  let source = "package example:app; import f: func(); export f as \"url=<https://example.com>\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-6-import" {
  let source = "package example:app; import f as \"integrity=<sha256-YQ==>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-6-export" {
  let source = "package example:app; import f: func(); export f as \"integrity=<sha256-YQ==>\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-7-import" {
  let source = "package example:app; import f as \"locked-dep=<a:b@1.2.3>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-7-export" {
  let source = "package example:app; import f: func(); export f as \"locked-dep=<a:b@1.2.3>\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-8-import" {
  let source = "package example:app; import f as \"unlocked-dep=<a:b@{>=1.0.0 <2.0.0}>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-8-export" {
  let source = "package example:app; import f: func(); export f as \"unlocked-dep=<a:b@{>=1.0.0 <2.0.0}>\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-9-import" {
  let source = "package example:app; import f as \"a:b/c@invalid\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-9-export" {
  let source = "package example:app; import f: func(); export f as \"a:b/c@invalid\";"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-10-import" {
  let source = "package example:app; import f as \"a:b:c/d/e\": func();"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-10-export" {
  let source = "package example:app; import f: func(); export f as \"a:b:c/d/e\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-11-import" {
  let source = "package example:app; import f as \"A:b/c\": func();"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-11-export" {
  let source = "package example:app; import f: func(); export f as \"A:b/c\";"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations extern-12-import" {
  let source = "package example:app; import f as \"a:b/C\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-12-export" {
  let source = "package example:app; import f: func(); export f as \"a:b/C\";"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-13-import" {
  let source = "package example:app; import f as \"a:b/c@\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations extern-13-export" {
  let source = "package example:app; import f: func(); export f as \"a:b/c@\";"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations header-aggregate-0" {
  let source = "package a:b:c;"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations header-aggregate-1" {
  let source = "package A:b;"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations header-aggregate-2" {
  let source = "package a:B;"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations header-aggregate-3" {
  let source = "package a:b/c;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations header-aggregate-4" {
  let source = "package a:b@1.2.3-01;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations header-aggregate-5" {
  let source = "package a:b; record r{}"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations header-aggregate-6" {
  let source = "package a:b; flags f{}"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations header-aggregate-7" {
  let source = "package a:b; enum e{}"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations header-aggregate-8" {
  let source = "package a:b; variant v{}"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations header-aggregate-9" {
  let source = "package a:b; type t=tuple<>;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations aggregates" {
  let source = "package example:app; record rec { x: u8, y: string } flags flags-type { a, b } enum enumeration { a, b } variant choice { none, some(rec) } type all = tuple<rec, flags-type, enumeration, choice>; import f: async func(x: all) -> result<all, error-context>;"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations duplicate-record" {
  let source = "package example:app; record rec { x: u8, x: u32 }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations duplicate-flags" {
  let source = "package example:app; flags f { a, a }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations duplicate-enum" {
  let source = "package example:app; enum e { a, a }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations duplicate-variant" {
  let source = "package example:app; variant v { a, a(u8) }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations alias-interface" {
  let source = "package example:app; interface api {} type a = api;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations alias-world" {
  let source = "package example:app; world app {} type a = app;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations value-function" {
  let source = "package example:app; type f = func(); type a = list<f>;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations value-interface" {
  let source = "package example:app; interface api {} import f: func(x: api);"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations borrow-value" {
  let source = "package example:app; interface api { type a = u8; f: func(x: borrow<a>); }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations future-empty" {
  let source = "package example:app; type a = future; type b = stream; type c = result; import f: func(x: a, y: b) -> c;"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-use-shadow" {
  let source = "package example:app; interface api { type t = u8; } world app { use api.{t}; type t = u32; }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations use-shadow" {
  let source = "package example:app; interface api { type t = u8; } interface next { use api.{t}; type t = u32; }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations use-duplicate-renamed" {
  let source = "package example:app; interface api { type a = u8; type b = u8; } interface next { use api.{a as same,b as same}; }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations include-duplicate-selector" {
  let source = "package example:app; world base { import a: func(); } world app { include base with {a as x,a as y}; }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations include-rename-conflict" {
  let source = "package example:app; world base { import a: func(); import b: func(); } world app { include base with {a as x,b as x}; }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations include-component" {
  let source = "package example:app; world base { import f: func(); } import c: base; world app { include c; }"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations world-shadow-root" {
  let source = "package example:app; type f = func(); world app { type f = u8; import x: f; }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations world-root-value-hidden" {
  let source = "package example:app; type t = u8; world app { import f: func(x: t); }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations inline-outer-hidden" {
  let source = "package example:app; world app { type t = u8; import api: interface { f: func(x: t); } }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations inline-root-use" {
  let source = "package example:app; interface api { type t = u8; } world app { import sub: interface { use api.{t}; f: func(x: t); } }"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations repeated-qualified-import" {
  let source = "package example:app; interface api {} import a: api; import b: a; import c: a;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations case-sensitive" {
  let source = "package example:app; type lower = u8; type LOWER = u32;"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations implicit-export-only-name" {
  let source = "package example:app; import f as \"url=<https://example.com>\": func(); export f;"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations include-import-export-rename" {
  let source = "package example:app; world base { import same: func(); export same: func(); } world app { include base with {same as changed}; export own: func(); }"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations external-integrity-suffix" {
  let source = "package example:app; import f as \"url=<x>,integrity=<sha256-YQ== sha384-AB?tag>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations external-invalid-hash" {
  let source = "package example:app; import f as \"integrity=<sha256-==>\": func();"
  assert_true(verify(source) is Err(_))
}

///|
test "pinned ordered declarations external-query-upper" {
  let source = "package example:app; import f as \"unlocked-dep=<a:b@{<2.0.0}>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations external-query-star" {
  let source = "package example:app; import f as \"unlocked-dep=<a:b@*>\": func();"
  assert_true(verify(source) is Ok(_))
}

///|
test "pinned ordered declarations external-query-malformed" {
  let source = "package example:app; import f as \"unlocked-dep=<a:b@{>1.0.0}>\": func();"
  assert_true(verify(source) is Err(_))
}
