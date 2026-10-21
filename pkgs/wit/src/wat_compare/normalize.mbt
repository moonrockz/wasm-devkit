///|
fn inline_import(field : Field, tokens : Array[Token]) -> Bool raise Failure {
  let mut at = field.first + 2
  if tokens.get(at) is Some(token) && token.text.has_prefix("$") {
    at += 1
  }
  let mut imported = false
  while at + 1 < field.last && tokens[at].text == "(" {
    let kind = tokens[at + 1].text
    if kind != "import" && kind != "export" {
      break
    }
    guard !imported else {
      raise Failure(
        Malformed,
        Some(tokens[at].span),
        "inline import must occur once, after export annotations",
      )
    }
    if kind == "import" {
      imported = true
    }
    let mut depth = 0
    while at < field.last {
      let text = tokens[at].text
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
  imported
}

///|
fn prepare(
  source : String,
) -> (String, Array[Field], Array[FloatLiteral], Array[Token]) raise Failure {
  let tokens = tokenize(source)
  let fields = fields(tokens)
  let floats : Array[FloatLiteral] = []
  normalize_identifiers(tokens)
  check_bindings(fields, tokens)
  let counts : Map[String, Int32] = Map([])
  let consumed : Map[Int32, Bool] = Map([])
  for field in fields {
    let index = counts.get(field.kind).unwrap_or(0)
    if !inline_import(field, tokens) {
      counts[field.kind] = index + 1
    }
    let mut constant = 0
    let mut at = field.first + 1
    while at < field.last {
      let opcode = tokens[at].text
      let vector = opcode == "v128.const"
      let (width, lanes, floating) = match opcode {
        "i32.const" => (32, 1, false)
        "i64.const" => (64, 1, false)
        "f32.const" => (32, 1, true)
        "f64.const" => (64, 1, true)
        "v128.const" => {
          guard at + 1 < field.last else {
            raise Failure(
              Malformed,
              Some(tokens[at].span),
              "missing vector shape",
            )
          }
          at += 1
          match tokens[at].text {
            "i8x16" => (8, 16, false)
            "i16x8" => (16, 8, false)
            "i32x4" => (32, 4, false)
            "i64x2" => (64, 2, false)
            "f32x4" => (32, 4, true)
            "f64x2" => (64, 2, true)
            _ =>
              raise Failure(
                Malformed,
                Some(tokens[at].span),
                "invalid vector shape",
              )
          }
        }
        _ => {
          at += 1
          continue
        }
      }
      let shape = at
      let vector_bytes : Array[Byte] = []
      for _lane in 0..<lanes {
        at += 1
        guard at < field.last else {
          raise Failure(
            Malformed,
            Some(tokens[at - 1].span),
            "missing constant literal",
          )
        }
        consumed[at] = true
        let token = tokens[at]
        if floating {
          let bits = floating_bits(token, width)
          if vector {
            vector_bytes.append(bits.to_array())
          } else {
            floats.push({
              path: "module.\{field.kind}[\{index}].constant[\{constant}].bits",
              bits,
              span: token.span,
            })
          }
          tokens[at] = {
            text: if vector {
              ""
            } else {
              "0"
            },
            span: token.span,
          }
        } else {
          let normalized = integer(token, width)
          if vector {
            let negative = normalized.has_prefix("-")
            let value = unsigned(
              if negative {
                normalized[1:].to_owned()
              } else {
                normalized
              },
              0xffffffffffffffffUL,
              token,
            )
            let value = if negative { 0UL - value } else { value }
            for i in 0..<(width / 8) {
              vector_bytes.push((value >> (i * 8)).to_byte())
            }
          }
          tokens[at] = {
            text: if vector {
              ""
            } else {
              normalized
            },
            span: token.span,
          }
        }
      }
      if vector {
        tokens[shape] = {
          text: "i8x16 " +
          vector_bytes.map(b => b.to_int().to_string()).join(" "),
          span: tokens[shape].span,
        }
      }
      constant += 1
      at += 1
    }
  }
  // Index immediates cannot silently wrap in the retained parser. Limits have
  // their own UInt64 checks in the maintained frontend.
  let heads : Array[String] = []
  for i in 0..<tokens.length() {
    let token = tokens[i]
    if token.text == "(" {
      heads.push(tokens.get(i + 1).map(t => t.text).unwrap_or(""))
      continue
    }
    if token.text == ")" {
      ignore(heads.pop())
      continue
    }
    if consumed.contains(i) || token.text.is_empty() {
      continue
    }
    if token.text.has_prefix("@") {
      raise Failure(
        Unsupported,
        Some(token.span),
        "WAT annotations are outside the comparison profile",
      )
    }
    if token.text.has_prefix("offset=") || token.text.has_prefix("align=") {
      let prefix = if token.text.has_prefix("offset=") {
        "offset="
      } else {
        "align="
      }
      let maximum = if prefix == "offset=" {
        0xffffffffffffffffUL
      } else {
        0xffffffffUL
      }
      let value = unsigned(
        token.text[prefix.length():].to_owned(),
        maximum,
        token,
      )
      tokens[i] = { text: prefix + value.to_string(), span: token.span, }
      continue
    }
    let c = token.text[0].to_int()
    if (c >= 48 && c <= 57) || c == 43 || c == 45 {
      let maximum = if heads.last() == Some("memory") ||
        heads.last() == Some("table") {
        0xffffffffffffffffUL
      } else {
        0xffffffffUL
      }
      let text = if token.text.has_prefix("+") {
        token.text[1:].to_owned()
      } else {
        token.text
      }
      let value = unsigned(text, maximum, token)
      tokens[i] = { text: value.to_string(), span: token.span, }
    }
  }
  let out = StringBuilder()
  out.write_string("(component (core ")
  for i in 1..<tokens.length() {
    out.write_string(tokens[i].text)
    out.write_string(" ")
  }
  out.write_string(")")
  let locations = fields.map(field => {
    if inline_import(field, tokens) {
      {
        kind: "import",
        span: field.span,
        first: field.first,
        last: field.last,
      }
    } else {
      field
    }
  })
  (out.to_string(), locations, floats, tokens)
}
