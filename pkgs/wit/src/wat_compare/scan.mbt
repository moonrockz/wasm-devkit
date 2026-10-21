///|
// Framing uses explicit state before any bounded recursive compiler helpers.
fn tokenize(source : String) -> Array[Token] raise Failure {
  for i in 0..<source.length() {
    let unit = source[i].to_int()
    guard ![
      0x202a, 0x202b, 0x202d, 0x202e, 0x2066, 0x2067, 0x2068, 0x2069, 0x206c,
    ].contains(unit) else {
      raise Failure(
        Malformed,
        Some({ start: i, end: i + 1, }),
        "confusing Unicode in WAT source",
      )
    }
    if unit >= 0xd800 && unit <= 0xdbff {
      guard i + 1 < source.length() &&
        source[i + 1].to_int() >= 0xdc00 &&
        source[i + 1].to_int() <= 0xdfff else {
        raise Failure(
          Malformed,
          Some({ start: i, end: i + 1, }),
          "unpaired UTF-16 surrogate",
        )
      }
    } else if unit >= 0xdc00 && unit <= 0xdfff {
      guard i > 0 &&
        source[i - 1].to_int() >= 0xd800 &&
        source[i - 1].to_int() <= 0xdbff else {
        raise Failure(
          Malformed,
          Some({ start: i, end: i + 1, }),
          "unpaired UTF-16 surrogate",
        )
      }
    }
  }
  let tokens : Array[Token] = []
  let mut at = 0
  let mut depth = 0
  while at < source.length() {
    let start = at
    let c = source[at].to_int()
    let next = if at + 1 < source.length() {
      source[at + 1].to_int()
    } else {
      -1
    }
    if c == 32 || c == 9 || c == 10 || c == 13 {
      at += 1
      continue
    }
    if c == 59 && next == 59 {
      while at < source.length() && source[at] != '\n' && source[at] != '\r' {
        at += 1
      }
      continue
    }
    if c == 40 && next == 59 {
      at += 2
      let mut comments = 1
      while at < source.length() && comments > 0 {
        if at + 1 < source.length() &&
          source[at] == '(' &&
          source[at + 1] == ';' {
          comments += 1
          at += 2
        } else if at + 1 < source.length() &&
          source[at] == ';' &&
          source[at + 1] == ')' {
          comments -= 1
          at += 2
        } else {
          at += 1
        }
      }
      guard comments == 0 else {
        raise Failure(
          Malformed,
          Some({ start, end: at, }),
          "unclosed block comment",
        )
      }
      continue
    }
    if c == 34 || (c == 36 && next == 34) {
      if c == 36 {
        at += 1
      }
      at += 1
      let mut closed = false
      while at < source.length() {
        if source[at] == '"' {
          at += 1
          closed = true
          break
        }
        if source[at] == '\\' {
          at += 1
        }
        at += 1
      }
      guard closed else {
        raise Failure(
          Malformed,
          Some({ start, end: source.length(), }),
          "unclosed string",
        )
      }
    } else if c == 40 || c == 41 {
      depth += if c == 40 { 1 } else { -1 }
      guard depth >= 0 else {
        raise Failure(
          Malformed,
          Some({ start, end: start + 1, }),
          "unmatched parenthesis",
        )
      }
      guard depth <= 256 else {
        raise Failure(
          Unsupported,
          Some({ start, end: start + 1, }),
          "WAT expression nesting exceeds 256",
        )
      }
      at += 1
    } else {
      while at < source.length() &&
            ![32, 9, 10, 13, 40, 41, 34, 59].contains(source[at].to_int()) {
        at += 1
      }
      guard at > start else {
        raise Failure(
          Malformed,
          Some({ start, end: start + 1, }),
          "unexpected WAT character",
        )
      }
    }
    if at < source.length() && c != 40 && c != 41 {
      let next = source[at].to_int()
      guard [32, 9, 10, 13, 40, 41, 59].contains(next) else {
        raise Failure(
          Malformed,
          Some({ start, end: at + 1, }),
          "reserved adjacent WAT tokens",
        )
      }
    }
    tokens.push({
      text: source[start:at].to_owned(),
      span: { start, end: at, },
    })
  }
  guard depth == 0 else {
    raise Failure(Malformed, None, "unclosed expression")
  }
  tokens
}

///|
fn fields(tokens : Array[Token]) -> Array[Field] raise Failure {
  guard tokens.length() >= 3 &&
    tokens[0].text == "(" &&
    tokens[1].text == "module" else {
    raise Failure(
      Unsupported,
      None,
      "semantic comparison requires a single core (module ...) form",
    )
  }
  let result : Array[Field] = []
  let mut depth = 0
  let mut first = 0
  for i, token in tokens {
    if token.text == "(" {
      if depth == 1 {
        first = i
      }
      depth += 1
    } else if token.text == ")" {
      depth -= 1
      if depth == 1 {
        let kind = tokens[first + 1].text
        if kind.has_prefix("@") || kind == "module" || kind == "component" {
          raise Failure(
            Unsupported,
            Some(token.span),
            "custom annotations and nested modules are outside the comparison profile",
          )
        }
        if kind == "export" && i - first == 3 {
          raise Failure(
            Malformed,
            Some(token.span),
            "export requires a descriptor",
          )
        }
        result.push({
          kind,
          span: { start: tokens[first].span.start, end: token.span.end, },
          first,
          last: i,
        })
      }
      if depth == 0 && i != tokens.length() - 1 {
        raise Failure(
          Malformed,
          Some(token.span),
          "trailing tokens after module",
        )
      }
    } else if depth == 1 && i > 1 && !token.text.has_prefix("$") {
      raise Failure(
        Unsupported,
        Some(token.span),
        "unsupported module text form",
      )
    }
  }
  result
}

///|
fn check_bindings(
  fields : Array[Field],
  tokens : Array[Token],
) -> Unit raise Failure {
  for i in 0..<tokens.length() {
    if tokens[i].text == "(" &&
      tokens.get(i + 1) is Some({ text: "param" | "local", .. }) &&
      tokens.get(i + 2) is Some(name) &&
      name.text.has_prefix("$") {
      let mut end = i + 3
      if tokens.get(end) is Some({ text: "(", .. }) {
        let mut depth = 1
        end += 1
        while end < tokens.length() && depth > 0 {
          if tokens[end].text == "(" {
            depth += 1
          }
          if tokens[end].text == ")" {
            depth -= 1
          }
          end += 1
        }
      } else {
        end += 1
      }
      guard tokens.get(end) is Some({ text: ")", .. }) else {
        raise Failure(
          Malformed,
          Some(name.span),
          "named parameter/local requires exactly one type",
        )
      }
    }
  }
  let names : Map[String, Bool] = Map([])
  fn bind(kind : String, position : Int32) -> Unit raise Failure {
    if tokens.get(position) is Some(token) && token.text.has_prefix("$") {
      let key = kind + ":" + token.text
      guard !names.contains(key) else {
        raise Failure(
          Malformed,
          Some(token.span),
          "duplicate " + kind + " identifier",
        )
      }
      names[key] = true
    }
  }
  let mut defined = false
  let mut start = false
  for field in fields {
    if field.kind == "start" {
      guard !start else {
        raise Failure(
          Malformed,
          Some(field.span),
          "duplicate start declaration",
        )
      }
      start = true
    }
    let imported = field.kind == "import" || inline_import(field, tokens)
    if imported {
      guard !defined else {
        raise Failure(
          Malformed,
          Some(field.span),
          "imports must precede definitions",
        )
      }
    } else if ["func", "global", "memory", "table", "tag"].contains(field.kind) {
      defined = true
    }
    if ["type", "func", "global", "table", "memory", "tag", "elem", "data"].contains(
        field.kind,
      ) {
      bind(field.kind, field.first + 2)
    }
    let mut depth = 0
    let locals : Map[String, Bool] = Map([])
    for i in field.first..<=field.last {
      if tokens[i].text == "(" {
        depth += 1
        if depth == 2 &&
          (field.kind == "rec" || field.kind == "import") &&
          i + 2 < field.last {
          bind(tokens[i + 1].text, i + 2)
        }
        if depth == 2 &&
          field.kind == "func" &&
          i + 2 < field.last &&
          ["param", "local"].contains(tokens[i + 1].text) &&
          tokens[i + 2].text.has_prefix("$") {
          let token = tokens[i + 2]
          guard !locals.contains(token.text) else {
            raise Failure(
              Malformed,
              Some(token.span),
              "duplicate local identifier",
            )
          }
          locals[token.text] = true
        }
      } else if tokens[i].text == ")" {
        depth -= 1
      }
    }
  }
}
