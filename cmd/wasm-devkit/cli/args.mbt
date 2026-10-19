///|
pub fn version() -> String {
  "0.2.0"
}

///|
pub let help : String =
  #|wasm-devkit: WIT and WAC language tools
  #|
  #|Usage: wasm-devkit <parse|verify|ast|cst|tokens|print|format> [FILE|-] [OPTIONS]
  #|       wasm-devkit --help | --version
  #|
  #|Language: inferred from .wit/.wac; verify also accepts .wasm/.wat as WIT.
  #|Use --language wit|wac for stdin.
  #|Input defaults to stdin. Output goes to stdout; diagnostics go to stderr.
  #|
  #|Options:
  #|  --language wit|wac   Select the source language
  #|  --world NAME         Require a WIT world, short or package-qualified
  #|  --json               Emit a WIT world-key/interface-identity summary
  #|  --base PATH          Dependency resolution base (required for verify stdin)
  #|  --deps-dir PATH      Dependency directory relative to the resolution base
  #|  --dep PKG=PATH       Map a package to a file/directory, relative to the base
  #|  --registry URL       Fetch missing WAC packages from an explicit Warg registry
  #|  --cache-dir PATH     Registry cache relative to base (default: user cache)
  #|  --offline            Use local inputs and checked cache only
  #|  --refresh            Refresh registry entries; existing lock versions stay pinned
  #|  --lockfile PATH      Create or enforce a registry package lockfile
  #|  --warg-provider PATH Optional network companion (default: wasm-devkit-warg)
  #|  --registry-config PATH  Explicit Warg client configuration
  #|  --all-features       Enable documented grammar extensions
  #|  --semantic-feature NAME  Enable a named WIT semantic feature (repeatable)
  #|  --all-semantic-features   Enable all WIT semantic features
  #|  --indent 0..8        Spaces per indentation level (default: 2)
  #|  --check              Fail if formatting would change input (format only)
  #|  --write              Update a named file after successful formatting
  #|  --                   Treat the next argument as a filename
  #|
  #|verify checks supported semantics; unsupported constructs fail explicitly.
  #|parse reports syntax validity; ast/cst/tokens inspect immutable flat arenas.
  #|print emits canonical AST source; format retains comments and token spelling.
  #|Exit codes: 0 success, 1 syntax/semantic errors or formatting differences, 2 usage/I/O.
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
  Verify
  Ast
  Cst
  Tokens
  Print
  Format
} derive(Eq, Debug)

///|
pub(all) struct DependencyMapping {
  name : String
  path : String
} derive(Eq, Debug)

///|
pub(all) struct RegistryOptions {
  url : String
  cache_dir : String?
  lockfile : String?
  provider : String
  config : String?
  offline : Bool
  refresh : Bool
} derive(Eq, Debug)

///|
pub(all) struct Options {
  command : Command
  language : Language
  path : String
  all_features : Bool
  semantic_features : ReadOnlyArray[String]
  all_semantic_features : Bool
  indent_width : Int32
  check : Bool
  write : Bool
  base : String?
  deps_dir : String?
  dependencies : ReadOnlyArray[DependencyMapping]
  world : String?
  json : Bool
  registry : RegistryOptions?
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
    "verify" => Verify
    "ast" => Ast
    "cst" => Cst
    "tokens" => Tokens
    "print" => Print
    "format" => Format
    _ => return Err("unknown command: " + args[0])
  }
  let registry_values : Map[String, String] = Map([])
  let mut offline = false
  let mut refresh = false
  let mut path = None
  let mut language = None
  let mut indent_width = 2
  let mut all_features = false
  let semantic_features : Array[String] = []
  let mut all_semantic_features = false
  let mut check = false
  let mut write = false
  let mut base = None
  let mut deps_dir = None
  let mut world = None
  let mut json = false
  let dependencies : Array[DependencyMapping] = []
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
    } else if !literal &&
      (arg == "--base" || arg == "--deps-dir" || arg == "--dep") {
      at += 1
      if at == args.length() || args[at].is_empty() {
        return Err(arg + " requires a value")
      }
      if arg == "--base" {
        base = Some(args[at])
      } else if arg == "--deps-dir" {
        deps_dir = Some(args[at])
      } else {
        guard args[at].find("=") is Some(separator) &&
          separator > 0 &&
          separator + 1 < args[at].length() else {
          return Err("--dep requires PKG=PATH")
        }
        dependencies.push({
          name: args[at][:separator].to_owned(),
          path: args[at][separator + 1:].to_owned(),
        })
      }
    } else if !literal &&
      [
        "--registry", "--cache-dir", "--lockfile", "--warg-provider", "--registry-config",
      ].contains(arg) {
      at += 1
      if at == args.length() || args[at].is_empty() || args[at].has_prefix("--") {
        return Err(arg + " requires a value")
      }
      if registry_values.contains(arg) {
        return Err("duplicate " + arg)
      }
      registry_values[arg] = args[at]
    } else if !literal && arg == "--offline" {
      offline = true
    } else if !literal && arg == "--refresh" {
      refresh = true
    } else if !literal && arg == "--world" {
      at += 1
      if at == args.length() || args[at].is_empty() {
        return Err("--world requires a name")
      }
      world = Some(args[at])
    } else if !literal && arg == "--json" {
      json = true
    } else if !literal && arg.has_prefix("--semantic-feature=") {
      let start = "--semantic-feature=".length()
      semantic_features.push(arg[start:].to_owned())
    } else if !literal && arg == "--semantic-feature" {
      at += 1
      if at == args.length() || args[at].is_empty() || args[at].has_prefix("-") {
        return Err("--semantic-feature requires a feature name")
      }
      semantic_features.push(args[at])
    } else if !literal && arg == "--all-semantic-features" {
      all_semantic_features = true
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
      if path.has_suffix(".wit") ||
        (
          command == Verify &&
          (path.has_suffix(".wasm") || path.has_suffix(".wat"))
        ) {
        Wit
      } else if path.has_suffix(".wac") {
        Wac
      } else {
        return Err(
          "select --language wit|wac for stdin or an unrecognized extension",
        )
      }
  }
  let registry = if !registry_values.is_empty() || offline || refresh {
    if command != Verify || language != Wac {
      return Err("registry options require verify --language wac")
    }
    guard registry_values.get("--registry") is Some(url) else {
      return Err("registry options require --registry URL")
    }
    if !@registry_model.valid_registry(url) {
      return Err(
        "--registry requires an HTTP(S) URL without credentials, query or fragment",
      )
    }
    if offline && refresh {
      return Err("--offline and --refresh are mutually exclusive")
    }
    Some({
      url,
      cache_dir: registry_values.get("--cache-dir"),
      lockfile: registry_values.get("--lockfile"),
      provider: registry_values
      .get("--warg-provider")
      .unwrap_or("wasm-devkit-warg"),
      config: registry_values.get("--registry-config"),
      offline,
      refresh,
    })
  } else {
    None
  }
  if command != Verify &&
    (base is Some(_) || deps_dir is Some(_) || !dependencies.is_empty()) {
    return Err("dependency options require verify")
  }
  if (world is Some(_) || json) && (command != Verify || language != Wit) {
    return Err("--world and --json require verify --language wit")
  }
  if (all_semantic_features || !semantic_features.is_empty()) &&
    (command != Verify || language != Wit) {
    return Err("semantic feature options require verify --language wit")
  }
  if command == Verify && path == "-" && base is None {
    return Err("verify on stdin requires --base PATH")
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
    Run({
      command,
      language,
      path,
      all_features,
      semantic_features: ReadOnlyArray::from_array(semantic_features),
      all_semantic_features,
      indent_width,
      check,
      write,
      base,
      deps_dir,
      dependencies: ReadOnlyArray::from_array(dependencies),
      world,
      json,
      registry,
    }),
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

///|
pub extend DependencyMapping with Eq::{equal, not_equal}

///|
pub extend DependencyMapping with @debug.Debug::{to_repr}

///|
pub extend RegistryOptions with Eq::{equal, not_equal}

///|
pub extend RegistryOptions with @debug.Debug::{to_repr}
