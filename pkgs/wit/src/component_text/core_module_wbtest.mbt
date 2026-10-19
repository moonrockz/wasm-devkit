///|
test "core data strings retain exact non-UTF8 and Unicode bytes" {
  for
    (source, expected) in [
      ("\\ff\\00\\80\\c3\\a9", b"\x05\xff\x00\x80\xc3\xa9"),
      ("crab 🦀", b"\x09crab \xf0\x9f\xa6\x80"),
    ] {
    let bytes = parse_normalized_component_wat(
      "(component (core module (memory 1) (data (i32.const 0) \"" +
      source +
      "\")))",
    )
    let parsed = @component.parse_component(bytes)
    let core = parsed.core_modules[0]
    let mut found = false
    for i in 0..<(core.length() - expected.length() + 1) {
      if core[i:i + expected.length()] == expected.exact_view() {
        found = true
      }
    }
    assert_true(found, msg="source=\{source} core=\{core}")
  }
}

///|
test "mixed folded and flat core controls share a nesting bound" {
  let source = "(component (core module (func (block " +
    Array::make(256, "block ").join("") +
    Array::make(256, "end ").join("") +
    "))))"
  let rejected = try {
    ignore(parse_normalized_component_wat(source))
    false
  } catch {
    Unsupported(message) => message.contains("nesting")
    _ => false
  }
  assert_true(rejected)
}

///|
test "sequential controls do not accumulate nesting" {
  ignore(
    parse_normalized_component_wat(
      "(component (core module (func " +
      Array::make(2000, "block end ").join("") +
      ")))",
    ),
  )
}

///|
test "WAT controls accept 64 and reject 65 before recursive backend parsing" {
  for depth in [64, 65] {
    let text = "(component (core module (func " +
      Array::make(depth, "block ").join("") +
      Array::make(depth, "end ").join("") +
      ")))"
    let accepted = try {
      ignore(parse_normalized_component_wat(text))
      true
    } catch {
      Unsupported(_) => false
      e => raise e
    }
    assert_eq(accepted, depth == 64)
  }
}

///|
test "folded numeric expressions reject before recursive backend parsing" {
  let text = "(component (core module (func (result i32) " +
    Array::make(100, "(i32.add (i32.const 0) ").join("") +
    "(i32.const 0)" +
    Array::make(100, ")").join("") +
    ")))"
  let rejected = try {
    ignore(parse_normalized_component_wat(text))
    false
  } catch {
    Unsupported(_) => true
    e => raise e
  }
  assert_true(rejected)
}
