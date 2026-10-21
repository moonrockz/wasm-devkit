///|
fn equal(left : String, right : String) -> Bool {
  @wat_compare.compare(left, right).unwrap().is_equal()
}

///|
fn constant(ty : String, value : String) -> String {
  "(module (func (result \{ty}) \{ty}.const \{value}))"
}

///|
test "typed integer equivalence and strict text" {
  let decimal = constant("i32", "16")
  let hex = constant("i32", "0x10")
  assert_true(equal(decimal, hex))
  assert_false(equal(decimal, constant("i32", "17")))
  assert_false(
    @wat_compare.compare(decimal, hex, mode=Text).unwrap().is_equal(),
  )
  for
    (ty, a, b) in [
      ("i32", "-1", "0xffff_ffff"),
      ("i32", "-2147483648", "0x80000000"),
      ("i32", "+0x10", "16"),
      ("i64", "-1", "18446744073709551615"),
      ("i64", "-9223372036854775808", "0x8000000000000000"),
    ] {
    assert_true(equal(constant(ty, a), constant(ty, b)))
  }
}

///|
test "float bit equivalence includes signed zero and all NaNs" {
  for ty in ["f32", "f64"] {
    assert_true(equal(constant(ty, "16"), constant(ty, "0x1p+4")))
    assert_false(equal(constant(ty, "0"), constant(ty, "-0")))
    assert_true(equal(constant(ty, "nan:0x1"), constant(ty, "+nan:0x01")))
    assert_false(equal(constant(ty, "nan:0x1"), constant(ty, "nan:0x2")))
    assert_false(equal(constant(ty, "nan:0x1"), constant(ty, "0")))
    assert_false(equal(constant(ty, "nan:0x1"), constant(ty, "-nan:0x1")))
  }
  assert_true(equal(constant("f32", "nan"), constant("f32", "nan:0x400000")))
  assert_true(
    equal(constant("f64", "nan"), constant("f64", "nan:0x8000000000000")),
  )
  assert_true(
    equal(
      constant("v128", "f32x4 nan:0x1 -0 inf 1"),
      constant("v128", "f32x4 +nan:0x01 -0x0p0 +inf 0x1p0"),
    ),
  )
}

///|
test "invalid and unsupported inputs never compare equal" {
  for
    source in [
      constant("i32", "0x100000000"),
      constant("i32", "-2147483649"),
      constant("i64", "0x10000000000000000"),
      constant("i64", "-9223372036854775809"),
      constant("i32", "1__6"),
      constant("f32", "nan:0x0"),
      constant("f32", "nan:0x800000"),
      constant("f64", "nan:0x10000000000000"),
      "(module (func i32.add))",
      "(module (func call 10))",
      "(module (func unknown))",
      "(module (export \"x\"))",
      "(module (memory 2 1))",
      "(module (unknown))",
      "(module",
      "(module) (module)",
      "(module binary \"\\00asm\")",
      "(component)",
    ] {
    assert_true(@wat_compare.compare(source, source) is Err(_), msg=source)
  }
  guard @wat_compare.compare("(module", "(module") is Err(errors) else {
    abort("expected diagnostics")
  }
  assert_eq(errors.length(), 2)
  assert_eq(errors[0].side, Left)
  assert_eq(errors[1].side, Right)
}

///|
test "structural differences preserve ordered instructions types indices and data" {
  for
    (a, b) in [
      ("(module (func nop))", "(module (func))"),
      (
        "(module (func i32.const 1 drop i32.const 2 drop))", "(module (func i32.const 2 drop i32.const 1 drop))",
      ),
      ("(module (func (param i32)))", "(module (func (param i64)))"),
      (
        "(module (func) (func) (export \"f\" (func 0)))", "(module (func) (func) (export \"f\" (func 1)))",
      ),
      (
        "(module (memory 1) (data (i32.const 0) \"a\"))", "(module (memory 1) (data (i32.const 0) \"b\"))",
      ),
    ] {
    assert_false(equal(a, b))
  }
  let source = ";; 😀\n(module\n (func (result i32) i32.const 16))"
  let diff = @wat_compare.compare(source, constant("i32", "17")).unwrap().differences[0]
  assert_eq(diff.path, "module.code[0]")
  assert_eq(
    diff.left_span,
    Some({ start: source.find("(func").unwrap(), end: source.length() - 1, }),
  )
  assert_true(diff.left != diff.right)
}

///|
test "ignored spellings and names retain meaning" {
  assert_true(
    equal(
      "(module $a (func $f (param $x i32) (result i32) local.get $x) (export \"f\" (func $f)))",
      "(module (func (param i32) (result i32) (local.get 0)) (export \"f\" (func 0)))",
    ),
  )
  assert_true(
    equal(
      "(module (global f32 (f32.const nan:0x1)) (func (result f32) f32.const nan:0x2))",
      "(module (func (result f32) f32.const nan:0x2) (global f32 (f32.const nan:0x1)))",
    ),
  )
}

///|
test "deep inputs reject before recursive compilation and nested comments are iterative" {
  let flat = "(module (func " +
    "block ".repeat(30000) +
    "end ".repeat(30000) +
    "))"
  assert_true(@wat_compare.compare(flat, flat) is Err(_))
  let folded = "(module (func " +
    "(block ".repeat(30000) +
    ")".repeat(30000) +
    "))"
  assert_true(@wat_compare.compare(folded, folded) is Err(_))
  let comments = "(;".repeat(30000) + ";)".repeat(30000)
  assert_true(equal(comments + "(module)", "(module)"))
  let accepted = "(module (func " +
    "block ".repeat(32) +
    "nop " +
    "end ".repeat(32) +
    "))"
  assert_true(equal(accepted, accepted))
}

///|
test "vectors compare by bits across lane spellings" {
  assert_true(
    equal(
      constant("v128", "f32x4 nan:0x1 -0 inf 1"),
      constant("v128", "i32x4 0x7f800001 0x80000000 0x7f800000 0x3f800000"),
    ),
  )
  assert_true(
    equal(
      constant("v128", "i8x16 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"),
      constant("v128", "i32x4 255 0 0 0"),
    ),
  )
  assert_true(
    equal(
      constant("v128", "f64x2 -nan:0x1 -0"),
      constant("v128", "i64x2 0xfff0000000000001 0x8000000000000000"),
    ),
  )
}

///|
test "literal grammar bounds duplicate bindings and indices reject explicitly" {
  for
    source in [
      constant("f32", "1__0"),
      constant("f64", "1e_2"),
      constant("f64", "0x1_p0"),
      constant("f32", "1e100"),
      constant("f64", "0x1p1024"),
      constant("i32", "0x10000000000000000"),
      "(module (func block br 0x100000000 end))",
      "(module (func $f) (func $f))",
      "(module (type $t (func)) (type $t (func)))",
      "(module (func (param $x i32) (local $x i32)))",
      "(module (func) (@custom \"x\" \"y\"))",
      "(module (memory 1) (func i32.const 0 i32.load offset=1__0 drop))",
    ] {
    assert_true(@wat_compare.compare(source, source) is Err(_), msg=source)
  }
}

///|
test "floating bit boundaries rounding and instruction locations" {
  for
    (ty, a, b) in [
      ("f32", "0x1p-149", "1.401298464324817070923729583289916131280e-45"),
      ("f32", "0x1.fffffep127", "3.40282346638528859811704183484516925440e38"),
      ("f32", "1.000000059604644775390625", "1"),
      ("f64", "0x1p-1074", "4.9406564584124654e-324"),
      ("f64", "0x1.fffffffffffffp1023", "1.7976931348623157e308"),
    ] {
    assert_true(equal(constant(ty, a), constant(ty, b)), msg=ty + ": " + a)
  }
  let source = constant("f32", "nan:0x1")
  let diff = @wat_compare.compare(source, constant("f32", "nan:0x2")).unwrap().differences
  assert_eq(diff.length(), 1)
  assert_eq(diff[0].path, "module.func[0].constant[0].bits")
  assert_eq(diff[0].left, Some(b"\x01\x00\x80\x7f"))
  assert_eq(
    diff[0].left_span,
    Some({ start: source.find("nan").unwrap(), end: source.length() - 2, }),
  )
}

///|
test "equivalence laws for many integer spellings" {
  for i in 0..<256 {
    let a = constant("i32", i.to_string())
    let b = constant("i32", "0x" + i.to_string(radix=16))
    let c = constant("i32", "+" + i.to_string())
    assert_true(equal(a, a))
    assert_true(equal(a, b))
    assert_eq(equal(a, b), equal(b, a))
    assert_true(equal(b, c))
    assert_true(equal(a, c))
    assert_false(equal(a, constant("i32", (i + 1).to_string())))
  }
}

///|
test "inline and explicit imports have the same float identity and source spans" {
  let a = "(module (import \"m\" \"f\" (func)) (func (result f32) f32.const nan:0x1))"
  let b = "(module (func (import \"m\" \"f\")) (func (result f32) f32.const nan:0x1))"
  assert_true(equal(a, b))
  let c = "(module (func (import \"m\" \"f\")) (func (result i32) i32.const 1))"
  let d = "(module (func (import \"m\" \"f\")) (func (result i32) i32.const 2))"
  let diff = @wat_compare.compare(c, d).unwrap().differences[0]
  assert_eq(diff.path, "module.code[0]")
  assert_eq(
    diff.left_span,
    Some({ start: c.find("(func (result").unwrap(), end: c.length() - 1, }),
  )
}

///|
test "original source validity survives compilation normalization" {
  for
    source in [
      "(module (type (func (param i32))) (func (type 0) (param i64)))", "(module (type (func (result i32))) (func (type 0) (result i64) i32.const 0))",
      "(module (type (func (result i32))) (func (result i32) block (type 0) (result i64) i32.const 0 end))",
      "(module (func) (import \"m\" \"f\" (func)))", "(module (memory 1) (import \"m\" \"m\" (memory 1)))",
      "(module (global i32 (i32.const 0)) (global (import \"m\" \"g\") i32))", "(module (func (param $x i32 i64)))",
      "(module (start 0) (func) (start 0))",
    ] {
    assert_true(@wat_compare.compare(source, source) is Err(_), msg=source)
  }
  assert_true(
    equal(
      "(module (type $t (func (param i32))) (func (type $t) (param i32)))", "(module (type (func (param i32))) (func (type 0)))",
    ),
  )
}

///|
test "inline signatures compare canonical reference forms without renumbering" {
  assert_true(
    equal(
      "(module (type (func (param structref arrayref) (result structref arrayref))) (func (type 0) (param structref arrayref) (result structref arrayref) local.get 0 local.get 1))",
      "(module (type (func (param (ref null struct) (ref null array)) (result (ref null struct) (ref null array)))) (func (type 0) local.get 0 local.get 1))",
    ),
  )
}

///|
test "quoted identifiers normalize before binding and reference checks" {
  assert_true(
    equal(
      "(module (func $\"f\\6f\\6f\" (param $\"😀\" i32) (result i32) local.get $\"\\f0\\9f\\98\\80\") (export \"run\" (func $foo)))",
      "(module (func (param i32) (result i32) local.get 0) (export \"run\" (func 0)))",
    ),
  )
  for
    source in [
      "(module (func $foo) (func $\"f\\6f\\6f\"))", "(module (func (param $x i32) (local $\"x\" i32)))",
      "(module (func $\"\\zz\"))", "(module (import \"a\"\"b\" (func)))", "(module (import\"a\" \"b\" (func)))",
      ";; \u202a\n(module)",
    ] {
    assert_true(@wat_compare.compare(source, source) is Err(_), msg=source)
  }
}

///|
test "leading export annotations do not change imported index spaces or spans" {
  let explicit = "(module (import \"m\" \"f\" (func)) (export \"x\" (func 0)) (export \"y\" (func 0)) (func (result f32) f32.const nan:0x1))"
  let inline_ = "(module (func $f (export \"x\") (export \"y\") (import \"m\" \"f\")) (func (result f32) f32.const nan:0x1))"
  assert_true(equal(explicit, inline_))
  let globals = "(module (global $g (export \"x\") (import \"m\" \"g\") f32) (global f32 (f32.const nan:0x1)))"
  let explicit_globals = "(module (import \"m\" \"g\" (global f32)) (export \"x\" (global 0)) (global f32 (f32.const nan:0x1)))"
  assert_true(equal(globals, explicit_globals))
  let before = "(module (func (export \"x\") (import \"m\" \"f\")) (func (result i32) i32.const 1))"
  let after = "(module (func (export \"x\") (import \"m\" \"f\")) (func (result i32) i32.const 2))"
  let diff = @wat_compare.compare(before, after).unwrap().differences[0]
  assert_eq(diff.path, "module.code[0]")
  assert_eq(
    diff.left_span,
    Some({
      start: before.find("(func (result").unwrap(),
      end: before.length() - 1,
    }),
  )
  for
    invalid in [
      "(module (func (import \"m\" \"f\") (export \"x\")))", "(module (func (import \"m\" \"f\") (import \"m\" \"g\")))",
    ] {
    assert_true(@wat_compare.compare(invalid, invalid) is Err(_))
  }
  // A following import is still before the first definition.
  let imports = "(module (memory (export \"m\") (import \"m\" \"m\") 1) (table (export \"t\") (import \"m\" \"t\") 1 funcref) (func (import \"m\" \"f\")))"
  assert_true(equal(imports, imports))
}
