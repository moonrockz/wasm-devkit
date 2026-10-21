///|
fn leb(bytes : Bytes, position : Ref[Int32]) -> Int32 {
  let mut value = 0
  let mut shift = 0
  while position.val < bytes.length() {
    let byte = bytes[position.val].to_int()
    position.val += 1
    value = value | ((byte & 127) << shift)
    if byte < 128 {
      break
    }
    shift += 7
  }
  value
}

///|
fn decode(source : String) -> Input raise Failure {
  let (text, fields, floats, tokens) = prepare(source)
  let component = @component_text.parse_normalized_component_wat(text) catch {
    @component_text.Unsupported(message) =>
      raise Failure(Unsupported, None, message)
    @component_text.ParseError(message) =>
      raise Failure(Malformed, None, message)
  }
  // This private envelope is produced by exactly one `(core module ...)`.
  guard component.length() > 9 && component[8].to_int() == 1 else {
    raise Failure(
      Unsupported,
      None,
      "core compiler did not produce a module envelope",
    )
  }
  let position = Ref(9)
  let size = leb(component, position)
  guard size >= 8 && size == component.length() - position.val else {
    raise Failure(Unsupported, None, "unexpected core compiler envelope")
  }
  let bytes = component[position.val:position.val + size].to_owned()
  match @core_types.inspect_module(bytes) {
    Err(error) =>
      raise Failure(
        match error.kind {
          Malformed => Malformed
          Invalid => Invalid
          Unsupported => Unsupported
        },
        None,
        error.message,
      )
    Ok(_) => ()
  }
  let module_ = @core_parser.parse_module(bytes) catch {
    error => raise Failure(Malformed, None, error.to_string())
  }
  check_type_uses(fields, tokens, module_)
  @core_validation.validate_module(module_) catch {
    @core_validation.TypeWorkLimit =>
      raise Failure(
        Unsupported,
        None,
        "core type comparison work exceeds 1000000",
      )
    error =>
      raise Failure(
        Invalid,
        None,
        @core_validation.format_validation_error(error),
      )
  }
  // Re-encode the validated decoded model to normalize equivalent reference
  // encodings, local groups, default limits and text-only block signatures.
  let canonical = @core_encoder.encode(module_) catch {
    error => raise Failure(Unsupported, None, error.to_string())
  }
  let bytes = Bytes::from_array(canonical.map(byte => byte.to_byte()))
  { bytes, fields, floats, }
}

///|
fn section_name(id : Int32) -> String {
  match id {
    1 => "types"
    2 => "imports"
    3 => "functions"
    4 => "tables"
    5 => "memories"
    6 => "globals"
    7 => "exports"
    8 => "start"
    9 => "elements"
    10 => "code"
    11 => "data"
    12 => "data_count"
    13 => "tags"
    _ => "section[\{id}]"
  }
}

///|
// Canonical encoder output, not arbitrary untrusted binary framing.
fn sections(input : Input) -> Map[String, Bytes] {
  let result : Map[String, Bytes] = Map([])
  let position = Ref(8)
  while position.val < input.bytes.length() {
    let id = input.bytes[position.val].to_int()
    position.val += 1
    let size = leb(input.bytes, position)
    let end = position.val + size
    if id == 10 {
      let count = leb(input.bytes, position)
      for i in 0..<count {
        let size = leb(input.bytes, position)
        result["module.code[\{i}]"] = input.bytes[position.val:position.val +
        size].to_owned()
        position.val += size
      }
    } else {
      result["module." + section_name(id)] = input.bytes[position.val:end].to_owned()
    }
    position.val = end
  }
  for literal in input.floats {
    result[literal.path] = literal.bits
  }
  result
}

///|
// Build once, so N changed functions do not rescan N source declarations.
fn locations(input : Input) -> Map[String, @span.Span] {
  let result : Map[String, @span.Span] = Map([])
  let mut function = 0
  for field in input.fields {
    let key = match field.kind {
      "type" | "rec" => "types"
      "import" => "imports"
      "func" => "functions"
      "table" => "tables"
      "memory" => "memories"
      "global" => "globals"
      "export" => "exports"
      "start" => "start"
      "elem" => "elements"
      "data" => "data"
      "tag" => "tags"
      _ => continue
    }
    if field.kind == "func" {
      result["module.code[\{function}]"] = field.span
      function += 1
    }
    let path = "module." + key
    result[path] = {
      start: result
      .get(path)
      .map(span => span.start)
      .unwrap_or(field.span.start),
      end: field.span.end,
    }
    if key == "data" {
      result["module.data_count"] = result[path]
    }
  }
  for literal in input.floats {
    result[literal.path] = literal.span
  }
  result
}

///|
/// Compare two WAT sources. Semantic mode validates both inputs before any
/// equality result, including identical inputs. Diagnostics never imply equality.
pub fn compare(
  left : String,
  right : String,
  mode~ : Mode = Semantic,
) -> Result[Comparison, ReadOnlyArray[Diagnostic]] {
  if mode == Text {
    return Ok({
      differences: if left == right {
        []
      } else {
        [
          {
            path: "text",
            left: Some(utf16_bytes(left)),
            right: Some(utf16_bytes(right)),
            left_span: Some({ start: 0, end: left.length(), }),
            right_span: Some({ start: 0, end: right.length(), }),
          },
        ]
      },
    })
  }
  let diagnostics : Array[Diagnostic] = []
  fn checked(source : String, side : Side) -> Input? {
    Some(decode(source)) catch {
      Failure(kind, span, message) => {
        diagnostics.push({ side, kind, span, message, })
        None
      }
    }
  }
  let l = checked(left, Left)
  let r = checked(right, Right)
  guard l is Some(l) && r is Some(r) else {
    return Err(ReadOnlyArray::from_array(diagnostics))
  }
  let ls = sections(l)
  let rs = sections(r)
  let lspans = locations(l)
  let rspans = locations(r)
  let keys = ls.keys().to_array()
  for key in rs.keys() {
    if !ls.contains(key) {
      keys.push(key)
    }
  }
  keys.sort()
  let differences : Array[Difference] = []
  for path in keys {
    let left = ls.get(path)
    let right = rs.get(path)
    if left != right {
      differences.push({
        path,
        left,
        right,
        left_span: lspans.get(path),
        right_span: rspans.get(path),
      })
    }
  }
  Ok({ differences: ReadOnlyArray::from_array(differences), })
}

///|
// Text mode is lossless even for unpaired UTF-16 surrogates.
fn utf16_bytes(text : String) -> Bytes {
  Bytes::from_array(
    Array::makei(text.length() * 2, i => {
      let unit = text[i / 2].to_int()
      (if i % 2 == 0 { unit & 255 } else { unit >> 8 }).to_byte()
    }),
  )
}
