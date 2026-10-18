///|
pub fn version() -> String {
  "0.1.1"
}

///|
pub let help : String =
  #|wasm-devkit: WIT and WAC syntax tools
  #|
  #|Usage: wasm-devkit <parse|ast|cst|tokens|print|format> [FILE|-] [OPTIONS]
  #|       wasm-devkit --help | --version
  #|
  #|Language: inferred from .wit/.wac, or --language wit|wac (required for stdin).
  #|Input defaults to stdin. Output goes to stdout; diagnostics go to stderr.
  #|
  #|Options:
  #|  --language wit|wac   Select the source language
  #|  --all-features       Enable documented grammar extensions
  #|  --indent 0..8        Spaces per indentation level (default: 2)
  #|  --check              Fail if formatting would change input (format only)
  #|  --write              Update a named file after successful formatting
  #|  --                   Treat the next argument as a filename
  #|
  #|parse reports syntax validity; ast/cst/tokens inspect immutable flat arenas.
  #|print emits canonical AST source; format retains comments and token spelling.
  #|Exit codes: 0 success, 1 syntax errors or formatting differences, 2 usage/I/O.
  #|Diagnostic line/column values are 1-based and count UTF-16 code units.
  #|

///|
pub(all) enum Language {
  Wit
  Wac
} derive(Eq, Debug)

///|
pub(all) enum Command {
  Parse
  Ast
  Cst
  Tokens
  Print
  Format
} derive(Eq, Debug)

///|
pub(all) struct Options {
  command : Command
  language : Language
  path : String
  all_features : Bool
  indent_width : Int32
  check : Bool
  write : Bool
} derive(Eq, Debug)

///|
pub(all) enum Action {
  Help
  Version
  Run(Options)
} derive(Eq, Debug)

///|
pub fn arguments(args : ArrayView[String]) -> Result[Action, String] {
  if args is [] || args is ["--help"] || args is ["-h"] {
    return Ok(Help)
  }
  if args is ["--version"] || args is ["-V"] {
    return Ok(Version)
  }
  let command : Command = match args[0] {
    "parse" | "check" => Parse
    "ast" => Ast
    "cst" => Cst
    "tokens" => Tokens
    "print" => Print
    "format" => Format
    _ => return Err("unknown command: " + args[0])
  }
  let mut path = None
  let mut language = None
  let mut indent_width = 2
  let mut all_features = false
  let mut check = false
  let mut write = false
  let mut literal = false
  let mut at = 1
  while at < args.length() {
    let arg = args[at]
    if !literal && arg == "--" {
      literal = true
      at += 1
      continue
    }
    if !literal && (arg == "--help" || arg == "-h") {
      return Ok(Help)
    }
    if !literal && arg == "--language" {
      at += 1
      if at == args.length() {
        return Err("--language requires wit or wac")
      }
      language = Some(
        match args[at] {
          "wit" => Wit
          "wac" => Wac
          _ => return Err("--language requires wit or wac")
        },
      )
    } else if !literal && arg == "--indent" {
      at += 1
      if at == args.length() {
        return Err("--indent requires an integer from 0 through 8")
      }
      let width = match args[at] {
        "0" => 0
        "1" => 1
        "2" => 2
        "3" => 3
        "4" => 4
        "5" => 5
        "6" => 6
        "7" => 7
        "8" => 8
        _ => return Err("--indent requires an integer from 0 through 8")
      }
      indent_width = width
    } else if !literal && arg == "--all-features" {
      all_features = true
    } else if !literal && arg == "--check" {
      check = true
    } else if !literal && arg == "--write" {
      write = true
    } else if !literal && arg.has_prefix("-") && arg != "-" {
      return Err("unknown option: " + arg)
    } else {
      if path is Some(_) {
        return Err("expected one input file")
      }
      path = Some(arg)
    }
    at += 1
  }
  let path = path.unwrap_or("-")
  let language = match language {
    Some(value) => value
    None =>
      if path.has_suffix(".wit") {
        Wit
      } else if path.has_suffix(".wac") {
        Wac
      } else {
        return Err(
          "select --language wit|wac for stdin or an unrecognized extension",
        )
      }
  }
  if (check || write) && command != Format {
    return Err("--check and --write require format")
  }
  if check && write {
    return Err("--check and --write are mutually exclusive")
  }
  if write && path == "-" {
    return Err("--write requires a named file")
  }
  Ok(
    Run({ command, language, path, all_features, indent_width, check, write, }),
  )
}

///|
pub extend Language with Eq::{equal, not_equal}

///|
pub extend Command with Eq::{equal, not_equal}

///|
pub extend Options with Eq::{equal, not_equal}

///|
pub extend Action with Eq::{equal, not_equal}

///|
pub extend Language with @debug.Debug::{to_repr}

///|
pub extend Command with @debug.Debug::{to_repr}

///|
pub extend Options with @debug.Debug::{to_repr}

///|
pub extend Action with @debug.Debug::{to_repr}
