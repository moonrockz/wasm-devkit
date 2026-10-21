///|
fn comparison_hex(bytes : Bytes?) -> Json {
  match bytes {
    None => Json::null()
    Some(bytes) => {
      let out = StringBuilder()
      let hex = "0123456789abcdef"
      for b in bytes {
        let v = b.to_int()
        out.write_string(hex[v >> 4:(v >> 4) + 1].to_owned())
        out.write_string(hex[v & 15:(v & 15) + 1].to_owned())
      }
      Json::string(out.to_string())
    }
  }
}

///|
fn comparison_location(
  source : @wit_span.Source,
  span : @wit_span.Span?,
) -> Json {
  match span {
    None => Json::null()
    Some(span) => {
      let p = source.position(span.start)
      {
        "start": span.start,
        "end": span.end,
        "line": p.map(p => p.line + 1),
        "column": p.map(p => p.column + 1),
      }
    }
  }
}

///|
/// Compare sources already loaded by the caller. JSON has equal=null on a
/// validation failure; neither malformed nor unsupported inputs report equality.
pub fn compare(
  options : CompareOptions,
  left : String,
  right : String,
) -> Output {
  let left_source = @wit_span.Source::new(left)
  let right_source = @wit_span.Source::new(right)
  let mode = if options.mode == Text { "text" } else { "semantic" }
  match @wat_compare.compare(left, right, mode=options.mode) {
    Ok(result) => {
      let differences = result.differences.map(d => {
        (
          {
            "path": d.path,
            "left": comparison_hex(d.left),
            "right": comparison_hex(d.right),
            "left_location": comparison_location(left_source, d.left_span),
            "right_location": comparison_location(right_source, d.right_span),
          } : Json)
      })
      let text = if options.json {
        (
          {
            "mode": mode,
            "equal": result.is_equal(),
            "differences": differences,
            "diagnostics": ([] : Array[Json]),
          } : Json).stringify() +
        "\n"
      } else if result.is_equal() {
        "equal (" + mode + ")\n"
      } else {
        let out = StringBuilder()
        for d in result.differences {
          out.write_string("different: " + d.path + "\n")
          for
            (path, source, span, value) in [
              (options.left, left_source, d.left_span, d.left),
              (options.right, right_source, d.right_span, d.right),
            ] {
            let location = match
              (match span {
                Some(span) => source.position(span.start)
                None => None
              }) {
              Some(p) => ":\{p.line+1}:\{p.column+1}"
              None => ""
            }
            out.write_string(
              "  " +
              path +
              location +
              ": " +
              comparison_hex(value).stringify() +
              "\n",
            )
          }
        }
        out.to_string()
      }
      output(text, "", if result.is_equal() { 0 } else { 1 })
    }
    Err(errors) => {
      let stderr = StringBuilder()
      let diagnostics = errors.map(error => {
        let (side, path, source) = if error.side == Left {
          ("left", options.left, left_source)
        } else {
          ("right", options.right, right_source)
        }
        let kind = match error.kind {
          Malformed => "malformed"
          Invalid => "invalid"
          Unsupported => "unsupported"
        }
        stderr.write_string(path + ": " + kind + ": " + error.message + "\n")
        (
          {
            "side": side,
            "path": path,
            "kind": kind,
            "message": error.message,
            "location": comparison_location(source, error.span),
          } : Json)
      })
      let stdout = if options.json {
        (
          {
            "mode": mode,
            "equal": Json::null(),
            "differences": ([] : Array[Json]),
            "diagnostics": diagnostics,
          } : Json).stringify() +
        "\n"
      } else {
        ""
      }
      output(stdout, stderr.to_string(), 3)
    }
  }
}
