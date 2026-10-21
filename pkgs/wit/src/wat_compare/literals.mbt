///|
fn digit(c : Int32) -> Int32? {
  if c >= 48 && c <= 57 {
    Some(c - 48)
  } else if c >= 97 && c <= 102 {
    Some(c - 87)
  } else if c >= 65 && c <= 70 {
    Some(c - 55)
  } else {
    None
  }
}

///|
// Check before arithmetic, so arbitrarily long literals cannot wrap.
fn unsigned(
  text : String,
  maximum : UInt64,
  token : Token,
) -> UInt64 raise Failure {
  let base = if text.has_prefix("0x") { 16UL } else { 10UL }
  let start = if base == 16UL { 2 } else { 0 }
  let mut value = 0UL
  let mut previous = false
  for i in start..<text.length() {
    let c = text[i].to_int()
    if c == 95 {
      guard previous &&
        i + 1 < text.length() &&
        digit(text[i + 1].to_int()) is Some(d) &&
        d.to_uint64() < base else {
        raise Failure(Malformed, Some(token.span), "invalid numeric separator")
      }
      previous = false
      continue
    }
    guard digit(c) is Some(d) && d.to_uint64() < base else {
      raise Failure(Malformed, Some(token.span), "invalid integer literal")
    }
    let d = d.to_uint64()
    guard value <= (maximum - d) / base && d <= maximum else {
      raise Failure(
        Malformed,
        Some(token.span),
        "integer literal is out of range",
      )
    }
    value = value * base + d
    previous = true
  }
  guard previous else {
    raise Failure(Malformed, Some(token.span), "integer literal needs a digit")
  }
  value
}

///|
fn integer(token : Token, width : Int32) -> String raise Failure {
  let text = token.text
  let negative = text.has_prefix("-")
  let body = if negative || text.has_prefix("+") {
    text[1:].to_owned()
  } else {
    text
  }
  let maximum = if negative {
    1UL << (width - 1)
  } else if width == 64 {
    0xffffffffffffffffUL
  } else {
    (1UL << width) - 1UL
  }
  let value = unsigned(body, maximum, token)
  if negative {
    "-" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn nan_bits(token : Token, width : Int32) -> Bytes raise Failure {
  let negative = token.text.has_prefix("-")
  let text = if negative || token.text.has_prefix("+") {
    token.text[1:].to_owned()
  } else {
    token.text
  }
  let fraction = if width == 32 { 23 } else { 52 }
  let payload = if text == "nan" {
    1UL << (fraction - 1)
  } else if text.has_prefix("nan:0x") {
    unsigned(text[4:].to_owned(), (1UL << fraction) - 1UL, token)
  } else {
    raise Failure(Malformed, Some(token.span), "invalid NaN literal")
  }
  guard payload != 0UL else {
    raise Failure(Malformed, Some(token.span), "NaN payload must be nonzero")
  }
  let bits = payload |
    (if width == 32 { 0x7f800000UL } else { 0x7ff0000000000000UL }) |
    (if negative { 1UL << (width - 1) } else { 0UL })
  Bytes::from_array(Array::makei(width / 8, i => (bits >> (8 * i)).to_byte()))
}

///|
// The finite parsers use exact rounding. NaNs bypass host floating point.
fn floating_bits(token : Token, width : Int32) -> Bytes raise Failure {
  if token.text.contains("nan") {
    return nan_bits(token, width)
  }
  float_grammar(token)
  let ty = if width == 32 { "f32" } else { "f64" }
  let module_ = @core_text.parse(
    "(module (func (result " + ty + ") " + ty + ".const " + token.text + "))",
  ) catch {
    error => raise Failure(Malformed, Some(token.span), error.to_string())
  }
  let bits = match module_.codes[0].body[0] {
    F32Const(value) => value.reinterpret_as_uint().to_uint64()
    F64Const(value) => value.reinterpret_as_uint64()
    _ =>
      raise Failure(
        Malformed,
        Some(token.span),
        "expected floating point constant",
      )
  }
  let infinity = if width == 32 { 0x7f800000UL } else { 0x7ff0000000000000UL }
  let magnitude = bits & ((1UL << (width - 1)) - 1UL)
  if magnitude == infinity && !token.text.contains("inf") {
    raise Failure(
      Malformed,
      Some(token.span),
      "floating point literal overflows its type",
    )
  }
  Bytes::from_array(Array::makei(width / 8, i => (bits >> (8 * i)).to_byte()))
}

///|
fn float_grammar(token : Token) -> Unit raise Failure {
  let raw = token.text
  guard raw.length() <= 4096 else {
    raise Failure(
      Unsupported,
      Some(token.span),
      "floating point literal exceeds 4096 code units",
    )
  }
  let text = if raw.has_prefix("+") || raw.has_prefix("-") {
    raw[1:].to_owned()
  } else {
    raw
  }
  if text == "inf" {
    return
  }
  let hex = text.has_prefix("0x")
  let mut at = if hex { 2 } else { 0 }
  fn digits() -> Bool raise Failure {
    let mut seen = false
    while at < text.length() {
      if text[at] == '_' {
        guard seen &&
          at + 1 < text.length() &&
          digit(text[at + 1].to_int()) is Some(d) &&
          (hex || d < 10) else {
          raise Failure(
            Malformed,
            Some(token.span),
            "invalid floating point separator",
          )
        }
        seen = false
        at += 1
      } else if digit(text[at].to_int()) is Some(d) && (hex || d < 10) {
        seen = true
        at += 1
      } else {
        break
      }
    }
    seen
  }
  let before = digits()
  guard before else {
    raise Failure(
      Malformed,
      Some(token.span),
      "floating point literal needs a digit",
    )
  }
  if at < text.length() && text[at] == '.' {
    at += 1
    ignore(digits())
  }
  if at < text.length() &&
    (if hex {
      text[at] == 'p' || text[at] == 'P'
    } else {
      text[at] == 'e' || text[at] == 'E'
    }) {
    at += 1
    if at < text.length() && (text[at] == '+' || text[at] == '-') {
      at += 1
    }
    let mut seen = false
    let mut exponent = 0
    while at < text.length() {
      if text[at] == '_' {
        guard seen &&
          at + 1 < text.length() &&
          text[at + 1] >= '0' &&
          text[at + 1] <= '9' else {
          raise Failure(
            Malformed,
            Some(token.span),
            "invalid exponent separator",
          )
        }
        seen = false
      } else {
        guard text[at] >= '0' && text[at] <= '9' else { break }
        exponent = exponent * 10 + text[at].to_int() - 48
        guard exponent <= 10000 else {
          raise Failure(
            Unsupported,
            Some(token.span),
            "floating point exponent magnitude exceeds 10000",
          )
        }
        seen = true
      }
      at += 1
    }
    guard seen else {
      raise Failure(Malformed, Some(token.span), "exponent needs a digit")
    }
  }
  guard at == text.length() else {
    raise Failure(Malformed, Some(token.span), "invalid floating point literal")
  }
}
