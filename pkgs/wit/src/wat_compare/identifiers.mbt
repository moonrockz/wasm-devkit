///|
// Resolve quoted and ordinary identifier spellings to the same safe token
// before duplicate-binding checks, while retaining every original source span.
fn normalize_identifiers(tokens : Array[Token]) -> Unit raise Failure {
  let names : Map[String, String] = Map([])
  let quoted : Map[String, String] = Map([])
  let mut remaining = 1000000
  for i, token in tokens {
    if !token.text.has_prefix("$") {
      continue
    }
    let name = if token.text.has_prefix("$\"") {
      if quoted.get(token.text) is Some(name) {
        name
      } else {
        guard token.text.length() <= remaining else {
          raise Failure(
            Unsupported,
            Some(token.span),
            "quoted identifier work exceeds 1000000",
          )
        }
        remaining -= token.text.length()
        // The maintained normalizer enforces UTF-8, escape and token grammar.
        ignore(
          @component_text.parse_normalized_component_wat(
            "(component (core module (func " + token.text + ")))",
          ) catch {
            @component_text.ParseError(message) =>
              raise Failure(Malformed, Some(token.span), message)
            @component_text.Unsupported(message) =>
              raise Failure(Unsupported, Some(token.span), message)
          },
        )
        let parsed = @core_text.parse("(module (func " + token.text + "))") catch {
          error => raise Failure(Malformed, Some(token.span), error.to_string())
        }
        guard parsed.func_names.get(0) is Some(name) else {
          raise Failure(
            Malformed,
            Some(token.span),
            "invalid quoted identifier",
          )
        }
        quoted[token.text] = name
        name
      }
    } else {
      guard token.text.length() > 1 else {
        raise Failure(Malformed, Some(token.span), "empty WAT identifier")
      }
      for char in token.text[1:] {
        let code = char.to_int()
        guard (code >= 48 && code <= 57) ||
          (code >= 65 && code <= 90) ||
          (code >= 97 && code <= 122) ||
          [
            33, 35, 36, 37, 38, 39, 42, 43, 45, 46, 47, 58, 60, 61, 62, 63, 64, 92,
            94, 95, 96, 124, 126,
          ].contains(code) else {
          raise Failure(
            Malformed,
            Some(token.span),
            "invalid unquoted WAT identifier",
          )
        }
      }
      token.text[1:].to_owned()
    }
    let safe = if names.get(name) is Some(safe) {
      safe
    } else {
      let safe = "$compare-id-" + names.length().to_string()
      names[name] = safe
      safe
    }
    tokens[i] = { text: safe, span: token.span, }
  }
}
