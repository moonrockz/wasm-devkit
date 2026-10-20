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
  } else if options.command == Verify {
    @wit_parser.Features::reference()
  } else {
    @wit_parser.Features::default()
  }
  let parsed = @wit_parser.parse(source, features~)
  let errors = wit_errors(source, parsed.diagnostics, label)
  let valid = parsed.is_valid()
  let code = if valid { 0 } else { 1 }
  match options.command {
    Verify =>
      match
        @wit_verifier.verify(parsed, source_id=label, source~, semantic_features={
          enabled: options.semantic_features,
          all_enabled: options.all_semantic_features,
        }) {
        Ok(model) => {
          if options.world is Some(_) {
            if model.select_world(name=options.world) is Err(diagnostics) {
              return output(
                "",
                render_wit_diagnostics(diagnostics, [(label, source)]),
                1,
              )
            }
          }
          output(
            if options.json {
              model.world_summary().stringify() + "\n"
            } else {
              label + ": verified wit\n"
            },
            "",
            0,
          )
        }
        Err(diagnostics) =>
          output("", render_wit_diagnostics(diagnostics, [(label, source)]), 1)
      }
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
fn wac_execute(
  options : Options,
  source : String,
  label : String,
  dependencies~ : ReadOnlyArray[@wac_verifier.PackageSource] = [],
  wit_dependencies~ : ReadOnlyArray[@wac_verifier.WitPackageSource] = [],
  compositions~ : ReadOnlyArray[@wac_verifier.CompositionPackage] = [],
) -> Output {
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
    Verify =>
      match
        @wac_verifier.verify(
          parsed,
          source_id=label,
          source~,
          dependencies~,
          wit_dependencies~,
          compositions~,
        ) {
        Ok(_) => output(label + ": verified wac\n", "", 0)
        Err(diagnostics) =>
          output("", render_wac_diagnostics(diagnostics, source, label), 1)
      }
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
/// Print immutable binary input as WAT. With `output`, `write_text` holds the
/// document for the executable to write; failures never carry a document.
pub fn decompile(options : DecompileOptions, bytes : Bytes) -> Output {
  let label = if options.path == "-" { "<stdin>" } else { options.path }
  match
    @wit_decompiler.print_binary(
      bytes,
      source_id=label,
      compatibility=options.compatibility,
    ) {
    Ok(printed) => {
      let text = printed.root().text
      match options.output {
        Some(_) =>
          { stdout: "", stderr: "", exit_code: 0, write_text: Some(text), }
        None => output(text, "", 0)
      }
    }
    Err(diagnostics) => {
      let out = StringBuilder()
      for diagnostic in diagnostics {
        let location = match diagnostic.offset {
          Some(offset) => "[byte \{offset}]"
          None => "[binary]"
        }
        out.write_string(
          "\{diagnostic.source}:\{location}: error \{diagnostic.code}: \{diagnostic.message}\n",
        )
      }
      output("", out.to_string(), 1)
    }
  }
}

///|
pub extend Output with Eq::{equal, not_equal}

///|
pub extend Output with @debug.Debug::{to_repr}

///|
/// Render every label against its own source. Dependency offsets are never
/// interpreted through the root file's line table.
pub fn render_wit_diagnostics(
  diagnostics : ReadOnlyArray[@wit_verifier.Diagnostic],
  sources : ReadOnlyArray[(String, String)],
) -> String {
  let indexed : Map[String, @wit_span.Source] = Map([])
  for (id, text) in sources {
    if !indexed.contains(id) {
      indexed[id] = @wit_span.Source::new(text)
    }
  }
  let render_location = fn(location : @wit_verifier.Location) {
    match location.position {
      SourceSpan(span) =>
        match indexed.get(location.source) {
          Some(source) =>
            match source.position(span.start) {
              Some(position) =>
                "\{location.source}:\{position.line+1}:\{position.column+1}"
              None => location.render()
            }
          None => location.render()
        }
      BinaryOffset(_) => location.render()
    }
  }
  let out = StringBuilder()
  for diagnostic in diagnostics {
    out.write_string(
      render_location(diagnostic.primary.location) +
      ": error " +
      diagnostic.code +
      ": " +
      diagnostic.message +
      "\n",
    )
    for label in diagnostic.related {
      out.write_string(
        render_location(label.location) + ": " + label.message + "\n",
      )
    }
  }
  out.to_string()
}

///|
pub fn render_wac_diagnostics(
  diagnostics : ReadOnlyArray[@wac_verifier.Diagnostic],
  source : String,
  label : String,
) -> String {
  let out = StringBuilder()
  let text = @wac_span.Source::new(source)
  for diagnostic in diagnostics {
    let p = diagnostic.primary.location
    let location = if p.source == label && p.span() is Some(span) {
      let coordinates = match text.position(span.start) {
        Some(position) => "\{position.line+1}:\{position.column+1}"
        None => "?:?"
      }
      "\{p.source}:\{coordinates}"
    } else {
      p.render()
    }
    out.write_string(
      "\{location}: error \{diagnostic.code}: \{diagnostic.message}\n",
    )
    for label in diagnostic.related {
      let p = label.location
      out.write_string("\{p.render()}: \{label.message}\n")
    }
  }

  out.to_string()
}

///|
/// Verify WAC with caller-supplied binary and WIT dependencies and CLI formatting.
pub fn verify_wac(
  options : Options,
  source : String,
  dependencies~ : ReadOnlyArray[@wac_verifier.PackageSource] = [],
  wit_dependencies~ : ReadOnlyArray[@wac_verifier.WitPackageSource] = [],
  compositions~ : ReadOnlyArray[@wac_verifier.CompositionPackage] = [],
) -> Output {
  if options.command != Verify || options.language != Wac {
    return output("", "WAC verification requires verify and language wac\n", 2)
  }
  wac_execute(
    options,
    source,
    if options.path == "-" {
      "<stdin>"
    } else {
      options.path
    },
    dependencies~,
    wit_dependencies~,
    compositions~,
  )
}

///|
pub fn inventory(options : InventoryOptions, bytes : Bytes) -> Output {
  match @wac_decompiler.inventory(bytes, source_id=options.path) {
    Ok(inventory) => {
      let text = if options.json {
        inventory.to_json().stringify() + "\n"
      } else {
        inventory.to_text()
      }
      if options.output is Some(_) {
        { stdout: "", stderr: "", exit_code: 0, write_text: Some(text), }
      } else {
        output(text, "", 0)
      }
    }
    Err(errors) => output("", render_split_diagnostics(errors), 1)
  }
}

///|
pub fn render_split_diagnostics(
  errors : ReadOnlyArray[@wac_decompiler.Diagnostic],
) -> String {
  errors
  .map(e => e.source + ": error " + e.code + ": " + e.message + "\n")
  .iter()
  .to_array()
  .join("")
}
