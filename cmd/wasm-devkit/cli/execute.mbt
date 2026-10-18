///|
pub(all) struct Output {
  stdout : String
  stderr : String
  exit_code : Int32
  write_text : String?
} derive(Eq, Debug)

///|
fn output(text : String, errors : String, code : Int32) -> Output {
  { stdout: text, stderr: errors, exit_code: code, write_text: None, }
}

///|
fn formatted(
  options : Options,
  source : String,
  text : String,
  label : String,
) -> Output {
  if options.check {
    if source == text {
      output("", "", 0)
    } else {
      output("", label + ": formatting differs\n", 1)
    }
  } else if options.write {
    { stdout: "", stderr: "", exit_code: 0, write_text: Some(text), }
  } else {
    output(text, "", 0)
  }
}

///|
fn wit_errors(
  source : String,
  diagnostics : ReadOnlyArray[@wit_diagnostic.Diagnostic],
  label : String,
) -> String {
  let text = @wit_span.Source::new(source)
  let out = StringBuilder()
  for diagnostic in diagnostics {
    let position = text.position(diagnostic.primary.span.start)
    let location = match position {
      Some(p) => "\{p.line+1}:\{p.column+1}"
      None => "?:?"
    }
    out.write_string(
      "\{label}:\{location}: " +
      (if diagnostic.severity == Error { "error" } else { "warning" }) +
      " " +
      diagnostic.code +
      ": " +
      diagnostic.message +
      "\n",
    )
  }
  out.to_string()
}

///|
fn wit_execute(options : Options, source : String, label : String) -> Output {
  if options.command == Tokens {
    let scanned = @wit_scanner.scan(source)
    let out = StringBuilder()
    for i, token in scanned.tokens {
      out.write_string("\{i}\t" + @debug.to_string(token) + "\n")
    }
    return output(
      out.to_string(),
      wit_errors(source, scanned.diagnostics, label),
      if scanned.diagnostics.any(d => d.severity == Error) {
        1
      } else {
        0
      },
    )
  }
  let features = if options.all_features {
    @wit_parser.Features::all()
  } else {
    @wit_parser.Features::default()
  }
  let parsed = @wit_parser.parse(source, features~)
  let errors = wit_errors(source, parsed.diagnostics, label)
  let valid = parsed.is_valid()
  let code = if valid { 0 } else { 1 }
  match options.command {
    Parse =>
      output(if valid { label + ": valid wit\n" } else { "" }, errors, code)
    Ast => {
      let out = StringBuilder()
      for i, node in parsed.ast.nodes {
        out.write_string(
          "\{i}\t[\{node.span.start},\{node.span.end})\t" +
          @debug.to_string(node.data) +
          "\n",
        )
      }
      output(out.to_string(), errors, code)
    }
    Cst => {
      let out = StringBuilder()
      out.write_string("nodes\n")
      for i, node in parsed.cst.nodes {
        out.write_string("\{i}\t" + @debug.to_string(node) + "\n")
      }
      out.write_string("tokens\n")
      for i, token in parsed.cst.tokens {
        out.write_string("\{i}\t" + @debug.to_string(token) + "\n")
      }
      output(out.to_string(), errors, code)
    }
    Print =>
      if !valid {
        output("", errors, 1)
      } else {
        match
          @wit_printer.print(parsed.ast, indent_width=options.indent_width) {
          Ok(text) => output(text, "", 0)
          Err(error) =>
            output(
              "",
              label + ": cannot print: " + @debug.to_string(error) + "\n",
              2,
            )
        }
      }
    Format =>
      if !valid {
        output("", errors, 1)
      } else {
        match
          @wit_formatter.format_cst(
            parsed.cst,
            indent_width=options.indent_width,
            features~,
          ) {
          Ok(text) => formatted(options, source, text, label)
          Err(error) =>
            output(
              "",
              label + ": cannot format: " + @debug.to_string(error) + "\n",
              2,
            )
        }
      }
    Tokens => output("", "unreachable command\n", 2)
  }
}

///|
fn wac_errors(
  source : String,
  diagnostics : ReadOnlyArray[@wac_diagnostic.Diagnostic],
  label : String,
) -> String {
  let text = @wac_span.Source::new(source)
  let out = StringBuilder()
  for diagnostic in diagnostics {
    let position = text.position(diagnostic.primary.span.start)
    let location = match position {
      Some(p) => "\{p.line+1}:\{p.column+1}"
      None => "?:?"
    }
    out.write_string(
      "\{label}:\{location}: " +
      (if diagnostic.severity == Error { "error" } else { "warning" }) +
      " " +
      diagnostic.code +
      ": " +
      diagnostic.message +
      "\n",
    )
  }
  out.to_string()
}

///|
fn wac_execute(options : Options, source : String, label : String) -> Output {
  if options.command == Tokens {
    let scanned = @wac_scanner.scan(source)
    let out = StringBuilder()
    for i, token in scanned.tokens {
      out.write_string("\{i}\t" + @debug.to_string(token) + "\n")
    }
    return output(
      out.to_string(),
      wac_errors(source, scanned.diagnostics, label),
      if scanned.diagnostics.any(d => d.severity == Error) {
        1
      } else {
        0
      },
    )
  }
  let features = if options.all_features {
    @wac_parser.Features::all()
  } else {
    @wac_parser.Features::default()
  }
  let parsed = @wac_parser.parse(source, features~)
  let errors = wac_errors(source, parsed.diagnostics, label)
  let valid = parsed.is_valid()
  let code = if valid { 0 } else { 1 }
  match options.command {
    Parse =>
      output(if valid { label + ": valid wac\n" } else { "" }, errors, code)
    Ast => {
      let out = StringBuilder()
      for i, node in parsed.ast.nodes {
        out.write_string(
          "\{i}\t[\{node.span.start},\{node.span.end})\t" +
          @debug.to_string(node.data) +
          "\n",
        )
      }
      output(out.to_string(), errors, code)
    }
    Cst => {
      let out = StringBuilder()
      out.write_string("nodes\n")
      for i, node in parsed.cst.nodes {
        out.write_string("\{i}\t" + @debug.to_string(node) + "\n")
      }
      out.write_string("tokens\n")
      for i, token in parsed.cst.tokens {
        out.write_string("\{i}\t" + @debug.to_string(token) + "\n")
      }
      output(out.to_string(), errors, code)
    }
    Print =>
      if !valid {
        output("", errors, 1)
      } else {
        match
          @wac_printer.print(parsed.ast, indent_width=options.indent_width) {
          Ok(text) => output(text, "", 0)
          Err(error) =>
            output(
              "",
              label + ": cannot print: " + @debug.to_string(error) + "\n",
              2,
            )
        }
      }
    Format =>
      if !valid {
        output("", errors, 1)
      } else {
        match
          @wac_formatter.format_cst(
            parsed.cst,
            indent_width=options.indent_width,
            features~,
          ) {
          Ok(text) => formatted(options, source, text, label)
          Err(error) =>
            output(
              "",
              label + ": cannot format: " + @debug.to_string(error) + "\n",
              2,
            )
        }
      }
    Tokens => output("", "unreachable command\n", 2)
  }
}

///|
/// Run a command against immutable decoded source; filesystem writes belong to the executable.
pub fn execute(options : Options, source : String) -> Output {
  let label = if options.path == "-" { "<stdin>" } else { options.path }
  match options.language {
    Wit => wit_execute(options, source, label)
    Wac => wac_execute(options, source, label)
  }
}

///|
pub extend Output with Eq::{equal, not_equal}

///|
pub extend Output with @debug.Debug::{to_repr}
