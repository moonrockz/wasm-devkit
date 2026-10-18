// WIT specification examples from WebAssembly/component-model.
// Revision: 0220da84209397d9067c19cac83dae969aa85a7b, design/mvp/WIT.md.
// Licensed under Apache-2.0. See fixtures/LICENSE-APACHE.
// Fixture numbers are zero-based WIT fenced-block indices. See fixtures/README.md.

///|
test "pinned WIT specification example 0" {
  let source =
    #|package wasi:clocks;
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 1" {
  let source =
    #|package wasi:clocks@1.2.0;
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 2" {
  let source =
    #|package local:a {
    #|    interface foo {}
    #|}
    #|
    #|package local:b {
    #|    interface bar {}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 3" {
  let source =
    #|package local:demo;
    #|
    #|interface host {
    #|    log: func(msg: string);
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 4" {
  let source =
    #|package wasi:filesystem;
    #|
    #|interface types {
    #|    use wasi:clocks/wall-clock.{datetime};
    #|
    #|    record stat {
    #|      ino: u64,
    #|      size: u64,
    #|      mtime: datetime,
    #|      // ...
    #|    }
    #|
    #|    stat-file: func(path: string) -> result<stat>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 5" {
  let source =
    #|package local:demo;
    #|
    #|world my-world {
    #|    import host: interface {
    #|      log: func(param: string);
    #|    }
    #|
    #|    export run: func();
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 6" {
  let source =
    #|package local:demo;
    #|
    #|world command {
    #|    import wasi:filesystem/filesystem;
    #|    import wasi:random/random;
    #|    import wasi:clocks/monotonic-clock;
    #|    // ...
    #|
    #|    export main: func(args: list<string>);
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 7" {
  let source =
    #|package local:demo;
    #|
    #|interface out-of-line {
    #|    the-function: func();
    #|}
    #|
    #|world your-world {
    #|    import out-of-line;
    #|    // ... is roughly equivalent to ...
    #|    import out-of-line: interface {
    #|      the-function: func();
    #|    }
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 8" {
  let source =
    #|package local:demo;
    #|
    #|interface my-interface {
    #|    // ..
    #|}
    #|
    #|world command {
    #|    // generates an import of the name `local:demo/my-interface`
    #|    import my-interface;
    #|
    #|    // generates an import of the name `wasi:filesystem/types`
    #|    import wasi:filesystem/types;
    #|
    #|    // generates an import of the plain name `foo`
    #|    import foo: func();
    #|
    #|    // generates an import of the plain name `bar`
    #|    import bar: interface {
    #|      // ...
    #|    }
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 9" {
  let source =
    #|package local:demo;
    #|
    #|// definitions of a, b, c, foo, bar, baz are omitted
    #|
    #|world my-world-a {
    #|    import a;
    #|    import b;
    #|    export c;
    #|}
    #|
    #|world my-world-b {
    #|    import foo;
    #|    import bar;
    #|    export baz;
    #|}
    #|
    #|world union-my-world {
    #|    include my-world-a;
    #|    include my-world-b;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 10" {
  let source =
    #|world union-my-world {
    #|    import a;
    #|    import b;
    #|    export c;
    #|    import foo;
    #|    import bar;
    #|    export baz;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 11" {
  let source =
    #|package local:demo;
    #|
    #|world my-world-a {
    #|    import a1;
    #|    import b1;
    #|}
    #|
    #|world my-world-b {
    #|    import a1;
    #|    import b1;
    #|}
    #|
    #|world union-my-world-a {
    #|    include my-world-a;
    #|    include my-world-b;
    #|}
    #|
    #|world union-my-world-b {
    #|    import a1;
    #|    import b1;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 12" {
  let source =
    #|package local:demo;
    #|
    #|world world-one { import a: func(); }
    #|world world-two { import a: func(); }
    #|
    #|world union-my-world-a {
    #|    include world-one;
    #|    include world-two with { a as b }
    #|}
    #|
    #|world union-my-world-b {
    #|    import a: func();
    #|    import b: func();
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 13" {
  let source =
    #|package local:demo;
    #|
    #|interface store {
    #|    get: func(key: string) -> option<string>;
    #|}
    #|
    #|world base {
    #|    import cache: store;
    #|}
    #|
    #|world extended {
    #|    import cache: func();
    #|    include base with { cache as my-cache }
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 14" {
  let source =
    #|world base-a {
    #|    import cache: store;
    #|}
    #|
    #|world base-b {
    #|    import cache: store;
    #|}
    #|
    #|world conflict {
    #|    include base-a;
    #|    include base-b;  // error: plain name 'cache' conflicts
    #|}
    #|
    #|world resolved {
    #|    include base-a;
    #|    include base-b with { cache as other-cache }  // ok: renamed to avoid conflict
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 15" {
  let source =
    #|package local:demo;
    #|
    #|interface a {
    #|    foo: func();
    #|}
    #|
    #|world world-using-a {
    #|    import a;
    #|}
    #|
    #|world invalid-union-world {
    #|    include world-using-a with { a as b }  // invalid: 'a', which is short for 'local:demo/a', is an interface name
    #|}
    #|
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 16" {
  let source =
    #|package local:demo;
    #|
    #|interface types {
    #|    enum errno { /* ... */ }
    #|
    #|    type size = u32;
    #|}
    #|
    #|interface my-host-functions {
    #|    use types.{errno, size};
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 17" {
  let source =
    #|package local:demo;
    #|
    #|interface my-host-functions {
    #|    use types.{errno as my-errno};
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 20" {
  let source =
    #|package local:demo;
    #|
    #|world my-world {
    #|    import wasi:clocks/monotonic-clock;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 21" {
  let source =
    #|package local:demo;
    #|
    #|interface my-interface {
    #|    use wasi:http/types.{request, response};
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 22" {
  let source =
    #|package local:demo;
    #|
    #|interface my-interface {
    #|    use wasi:http/types@1.0.0.{request, response};
    #|}
    #|
    #|world my-world {
    #|    import wasi:http/handler@1.0.0;
    #|    export wasi:http/handler@1.0.0;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 23" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types@1.0.0;
    #|use wasi:http/handler@1.0.0;
    #|
    #|interface my-interface {
    #|    use types.{request, response};
    #|}
    #|
    #|world my-world {
    #|    import handler;
    #|    export handler;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 24" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types;   // defines the name `types`
    #|use wasi:http/handler; // defines the name `handler`
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 25" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types as http-types;
    #|use wasi:http/handler as http-handler;
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 26" {
  let source =
    #|package local:demo;
    #|
    #|use wasi:http/types@1.0.0 as http-types1;
    #|use wasi:http/types@2.0.0 as http-types2;
    #|
    #|// ...
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 27" {
  let source =
    #|package local:demo;
    #|
    #|interface shared {
    #|    record metadata {
    #|      // ...
    #|    }
    #|}
    #|
    #|world my-world {
    #|    import host: interface {
    #|      use shared.{metadata};
    #|
    #|      get: func() -> metadata;
    #|    }
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 28" {
  let source =
    #|interface a {
    #|    resource r;
    #|}
    #|interface b {
    #|    use a.{r};
    #|    foo: func() -> r;
    #|}
    #|
    #|world w1 {
    #|    export b;
    #|}
    #|world w2 {
    #|    import a;
    #|    export b;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 29" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    a1: func();
    #|    a2: func(x: u32);
    #|    a3: func(y: u64, z: f32);
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 30" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    a1: func() -> u32;
    #|    a2: func() -> string;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 31" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    record r {
    #|      a: u32,
    #|      b: f32
    #|    }
    #|
    #|    a1: func() -> r;
    #|    a2: func() -> tuple<u32, f32>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 32" {
  let source =
    #|package local:demo;
    #|
    #|interface foo {
    #|    // "package of named fields"
    #|    record r {
    #|      a: u32,
    #|      b: string,
    #|    }
    #|
    #|    // values of this type will be one of the specified cases
    #|    variant human {
    #|      baby,
    #|      child(u32), // optional type payload
    #|      adult,
    #|    }
    #|
    #|    // similar to `variant`, but no type payloads
    #|    enum errno {
    #|      too-big,
    #|      too-small,
    #|      too-fast,
    #|      too-slow,
    #|    }
    #|
    #|    // a bitflags type
    #|    flags permissions {
    #|      read,
    #|      write,
    #|      exec,
    #|    }
    #|
    #|    // type aliases are allowed to primitive types and additionally here are some
    #|    // examples of other types
    #|    type t1 = u32;
    #|    type t2 = tuple<u32, u64>;
    #|    type t3 = string;
    #|    type t4 = option<u32>;
    #|    type t5 = result<_, errno>;           // no "ok" type
    #|    type t6 = result<string>;             // no "err" type
    #|    type t7 = result<char, errno>;        // both types specified
    #|    type t8 = result;                     // no "ok" or "err" type
    #|    type t9 = list<string>;
    #|    type t10 = t9;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 34" {
  let source =
    #|interface fixture {
    #|%foo: func(%bar: u32);
    #|
    #|%red-green-blue: func(%r: u32, %g: u32, %b: u32);
    #|
    #|// This form also supports identifiers that would otherwise be keywords.
    #|%variant: func(%enum: s32);
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 35" {
  let source =
    #|interface foo {
    #|    a: func();
    #|
    #|    @since(version = 0.2.1)
    #|    b: func();
    #|
    #|    @since(version = 0.2.2)
    #|    c: func();
    #|
    #|    @unstable(feature = fancier-foo)
    #|    d: func();
    #|
    #|    @since(version = 0.2.0)
    #|    @deprecated(version = 0.2.2)
    #|    e: func();
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 37" {
  let source =
    #|interface i {
    #|    @since(version = 1.0.1)
    #|    type t1 = u32;
    #|
    #|    type t2 = t1; // error
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 38" {
  let source =
    #|@since(version = 1.0.2)
    #|interface i {
    #|    foo: func();  // error: no gate
    #|
    #|    @since(version = 1.0.1)
    #|    bar: func();  // also error: weaker gate
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 39" {
  let source =
    #|package examples:fgates-calc@0.1.0;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 40" {
  let source =
    #|package examples:fgates-calc@0.1.1;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|
    #|    /// By convention, feature flags should be prefixed with package name to reduce chance of collisions
    #|    ///
    #|    /// see: https://github.com/WebAssembly/WASI/blob/main/Contributing.md#filing-changes-to-existing-phase-3-proposals
    #|    @unstable(feature = fgates-calc-minus)
    #|    sub: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 41" {
  let source =
    #|package examples:fgates-calc@0.1.2;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|
    #|    @since(version = 0.1.2)
    #|    sub: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 42" {
  let source =
    #|package examples:fgates-deprecation@0.1.1;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.0)
    #|    add-one: func(x: s32) -> result<s32, calc-error>;
    #|
    #|    @since(version = 0.1.1)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 43" {
  let source =
    #|package examples:fgates-deprecation@0.1.2;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @deprecated(version = 0.1.2)
    #|    add-one: func(x: s32) -> result<s32, calc-error>;
    #|
    #|    @since(version = 0.1.1)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 44" {
  let source =
    #|package examples:fgates-deprecation@0.2.0;
    #|
    #|@since(version = 0.1.0)
    #|interface calc {
    #|    @since(version = 0.1.0)
    #|    variant calc-error {
    #|      integer-overflow,
    #|      integer-underflow,
    #|      unexpected,
    #|    }
    #|
    #|    @since(version = 0.1.1)
    #|    add: func(x: s32, y: s32) -> result<s32, calc-error>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 45" {
  let source =
    #|world my-component {
    #|  @external-id("https://esm.unpkg.com/slugify@1.6.6")
    #|  import slugify: func(text: string) -> string;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 46" {
  let source =
    #|world my-world {
    #|    import primary: wasi:keyvalue/store;
    #|    import secondary: wasi:keyvalue/store;
    #|    export my-handler: wasi:http/handler;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 47" {
  let source =
    #|world w {
    #|    import a:b;  // error: can't import a package
    #|    import a: b; // ok, assuming `b` names an interface in scope
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  assert_false(result.is_valid())
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 48" {
  let source =
    #|world my-world {
    #|    @external-id("user-db-prod:region-a")
    #|    import users: wasi:keyvalue/store;
    #|
    #|    @external-id("catalog-db-prod:region-a")
    #|    import catalog: wasi:keyvalue/store;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 49" {
  let source =
    #|world fixture {
    #|include wasi:io/my-world-1 with { a as a1, b as b1 };
    #|include my-world-2;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 50" {
  let source =
    #|interface fixture {
    #|foo: func(x: u32);
    #|bar: get() -> u64;
    #|bar: set(v: u64);
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 52" {
  let source =
    #|interface my-interface {
    #|  @external-id("foo/0")
    #|  foo: func() -> string;
    #|
    #|  @external-id("DB.Bar")
    #|  resource bar {
    #|    @external-id("baz/1")
    #|    baz: func(s: string) -> string;
    #|  }
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 54" {
  let source =
    #|interface fixture {
    #|type my-awesome-u32 = u32;
    #|type my-complicated-tuple = tuple<u32, s32, string>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 55" {
  let source =
    #|interface fixture {
    #|record pair {
    #|    x: u32,
    #|    y: u32,
    #|}
    #|
    #|record person {
    #|    name: string,
    #|    age: u32,
    #|    has-lego-action-figure: bool,
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 56" {
  let source =
    #|interface fixture {
    #|flags properties {
    #|    lego,
    #|    marvel-superhero,
    #|    supervillan,
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 57" {
  let source =
    #|interface fixture {
    #|variant filter {
    #|    all,
    #|    none,
    #|    some(list<string>),
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 58" {
  let source =
    #|interface fixture {
    #|enum color {
    #|    red,
    #|    green,
    #|    blue,
    #|    yellow,
    #|    other,
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 60" {
  let source =
    #|interface fixture {
    #|resource blob {
    #|    constructor(init: list<u8>);
    #|    write: func(bytes: list<u8>);
    #|    read: func(n: u32) -> list<u8>;
    #|    merge: static func(lhs: borrow<blob>, rhs: borrow<blob>) -> blob;
    #|    position: get() -> u64; // 📡
    #|    position: set(value: u64); // 📡
    #|    max-size: static get() -> result<u64>; // 📡
    #|    max-size: static set(value: u64) -> result<_, string>; // 📡
    #|}
    #|resource blob2 {
    #|    constructor(init: list<u8>) -> result<blob2>;
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 62" {
  let source =
    #|interface fixture {
    #|type number = u32;
    #|type fallible-function-result = result<u32, string>;
    #|type headers = list<string>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 63" {
  let source =
    #|interface fixture {
    #|get-ipv4-address1: func() -> list<u8, 4>;
    #|get-ipv4-address2: func() -> tuple<u8, u8, u8, u8>;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 65" {
  let source =
    #|interface fixture {
    #|resource file {
    #|    read: func(n: u32) -> list<u8>;
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 67" {
  let source =
    #|interface fixture {
    #|type foo = bar;  // ERROR: name `bar` not defined
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 68" {
  let source =
    #|interface fixture {
    #|type foo = u32;
    #|type foo = u64;  // ERROR: name `foo` already defined
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 69" {
  let source =
    #|interface fixture {
    #|type foo = bar;
    #|
    #|record bar {
    #|    age: u32,
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 70" {
  let source =
    #|interface fixture {
    #|type foo = foo;  // ERROR: cannot refer to itself
    #|
    #|record bar1 {
    #|    a: bar2,
    #|}
    #|
    #|record bar2 {
    #|    a: bar1,    // ERROR: record cannot refer to itself
    #|}
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 71" {
  let source =
    #|package local:demo;
    #|
    #|interface types {
    #|    resource file {
    #|      read: func(off: u32, n: u32) -> list<u8>;
    #|      write: func(off: u32, bytes: list<u8>);
    #|    }
    #|}
    #|
    #|interface namespace {
    #|    use types.{file};
    #|    open: func(name: string) -> file;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 72" {
  let source =
    #|package local:demo
    #|
    #|interface foo {
    #|    use wasi:http/types.{request};
    #|    frob: func(r: request) -> request;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  assert_false(result.is_valid())
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 73" {
  let source =
    #|package local:demo;
    #|
    #|world the-world {
    #|    export test: func();
    #|    export run: func();
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 74" {
  let source =
    #|package local:demo;
    #|
    #|world the-world {
    #|    import console;
    #|}
    #|
    #|interface console {
    #|    log: func(arg: string);
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 75" {
  let source =
    #|package local:demo;
    #|
    #|interface store {
    #|    resource bucket {
    #|        constructor(name: string);
    #|        get: func(key: string) -> option<string>;
    #|    }
    #|}
    #|
    #|world w {
    #|    @external-id("//One")
    #|    import one: store;
    #|
    #|    @external-id("//Two")
    #|    import two: store;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 76" {
  let source =
    #|package local:demo;
    #|
    #|interface types {
    #|    resource bucket {
    #|        get: func(key: string) -> option<string>;
    #|    }
    #|}
    #|
    #|interface store {
    #|    use types.{bucket};
    #|    open: func(name: string) -> bucket;
    #|}
    #|
    #|world w {
    #|    import one: store;
    #|    import two: store;
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}

///|
test "pinned WIT specification example 78" {
  let source =
    #|package ns:p@1.1.0;
    #|
    #|interface i {
    #|    f: func();
    #|
    #|    @since(version = 1.1.0)
    #|    g: func();
    #|}
    #|
  let result = @parser.parse(source, features=@parser.Features::all())
  if !result.is_valid() {
    fail(@debug.to_string(result.diagnostics))
  }
  assert_eq(result.cst.to_source(), source)
  assert_true(result.ast.validate())
  assert_true(result.cst.validate())
}
