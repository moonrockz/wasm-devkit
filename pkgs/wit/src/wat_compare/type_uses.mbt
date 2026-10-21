///|
// The retained compiler checks redundant import signatures, but discards them
// on function/control/call type uses. Compare their complete inline signature
// before that spelling can be accepted as equivalent to a different type.
fn check_type_uses(
  fields : Array[Field],
  tokens : Array[Token],
  module_ : @core_model.Module,
) -> Unit raise Failure {
  let declarations = StringBuilder()
  let names : Map[String, Int32] = Map([])
  let mut count = 0
  fn declaration(at : Int32) -> Unit {
    if tokens.get(at + 2) is Some(token) && token.text.has_prefix("$") {
      names[token.text] = count
    }
    count += 1
  }
  for field in fields {
    if field.kind == "type" || field.kind == "rec" {
      for i in field.first..<=field.last {
        declarations.write_string(tokens[i].text + " ")
      }
      if field.kind == "type" {
        declaration(field.first)
      } else {
        let mut depth = 0
        for i in field.first..<=field.last {
          if tokens[i].text == "(" {
            depth += 1
            if depth == 2 && tokens.get(i + 1) is Some({ text: "type", .. }) {
              declaration(i)
            }
          } else if tokens[i].text == ")" {
            depth -= 1
          }
        }
      }
    }
  }
  let declarations = declarations.to_string()
  let mut work = 1000000
  for i in 0..<tokens.length() {
    guard tokens[i].text == "(" &&
      tokens.get(i + 1) is Some({ text: "type", .. }) &&
      tokens.get(i + 3) is Some({ text: ")", .. }) else {
      continue
    }
    let mut at = i + 4
    let signature = StringBuilder()
    let mut inline = false
    while tokens.get(at) is Some({ text: "(", .. }) &&
          tokens.get(at + 1) is Some({ text: "param" | "result", .. }) {
      inline = true
      let mut depth = 0
      while true {
        guard at < tokens.length() else {
          raise Failure(
            Malformed,
            Some(tokens[i].span),
            "unclosed inline signature",
          )
        }
        let text = tokens[at].text
        signature.write_string(text + " ")
        at += 1
        if text == "(" {
          depth += 1
        }
        if text == ")" {
          depth -= 1
        }
        if depth == 0 {
          break
        }
      }
    }
    if !inline {
      continue
    }
    let reference = tokens[i + 2]
    let index = if reference.text.has_prefix("$") {
      guard names.get(reference.text) is Some(index) else {
        raise Failure(
          Malformed,
          Some(reference.span),
          "undefined type identifier",
        )
      }
      index
    } else {
      unsigned(reference.text, 0xffffffffUL, reference).to_int()
    }
    guard index >= 0 && index < module_.types.length() else {
      raise Failure(Invalid, Some(reference.span), "type index out of bounds")
    }
    work -= declarations.length() + signature.to_string().length()
    guard work >= 0 else {
      raise Failure(
        Unsupported,
        Some(reference.span),
        "inline signature comparison work exceeds 1000000",
      )
    }
    let parsed = @core_text.parse(
      "(module " + declarations + " (func " + signature.to_string() + "))",
    ) catch {
      error => raise Failure(Malformed, Some(reference.span), error.to_string())
    }
    let actual = parsed.types[parsed.funcs[0]].composite
    let matching = match (actual, module_.types[index].composite) {
      (Func(actual), Func(expected) | SharedFunc(expected)) =>
        @core_model.func_types_equal(actual, expected)
      _ => false
    }
    guard matching else {
      raise Failure(
        Invalid,
        Some(reference.span),
        "inline signature does not match its type use",
      )
    }
  }
}
