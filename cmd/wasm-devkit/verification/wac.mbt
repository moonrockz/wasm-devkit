///|
fn wac_problem(
  request : @wac_verifier.PackageRequest,
  code : String,
  message : String,
) -> @wac_verifier.Diagnostic {
  {
    code,
    message,
    primary: { location: request.location, message, },
    related: [],
  }
}

///|
async fn wac(options : @cli.Options) -> @cli.Output {
  let data = if options.path == "-" {
    @stdio.stdin.read_all()
  } else {
    @fs.read_file(options.path)
  }
  let source = @utf8.decode(data.binary(), ignore_bom=false)
  let label = if options.path == "-" { "<stdin>" } else { options.path }
  let features = if options.all_features {
    @wac_parser.Features::all()
  } else {
    @wac_parser.Features::default()
  }
  let parsed = @wac_parser.parse(source, features~)
  let requests = match
    @wac_verifier.package_requests(parsed, source~, source_id=label) {
    Ok(requests) => requests
    Err(errors) =>
      return output("", @cli.render_wac_diagnostics(errors, source, label), 1)
  }
  let base = options.base.unwrap_or(parent(options.path))
  let root = relative(base, options.deps_dir.unwrap_or("deps"))
  let overrides : Map[String, String] = Map([])
  for mapping in options.dependencies {
    overrides[mapping.name] = relative(base, mapping.path)
  }
  let dependencies : Array[@wac_verifier.PackageSource] = []
  for request in requests {
    let explicit = request.version is None && overrides.contains(request.name)
    let path = if request.version is None &&
      overrides.get(request.name) is Some(path) {
      path
    } else {
      let parts = request.name
        .split(":")
        .map(part => part.to_owned())
        .to_array()
      let path = root +
        "/" +
        parts.join("/") +
        request.version.map(version => "/" + version).unwrap_or("")
      if @fs.exists(path) && @fs.kind(path) is Directory {
        path
      } else if @fs.exists(path + ".wat") {
        path + ".wat"
      } else {
        path + ".wasm"
      }
    }
    if !@fs.exists(path) {
      let error = wac_problem(
        request,
        "WAC-P003",
        "package `" + request.name + "` was not found at `" + path + "`",
      )
      return output(
        "",
        @cli.render_wac_diagnostics([error], source, label),
        if explicit {
          2
        } else {
          1
        },
      )
    }
    if @fs.kind(path) is Directory {
      let error = wac_problem(
        request,
        "WAC-S003",
        "WIT directory dependencies are not yet supported for WAC: `" +
        path +
        "`",
      )
      return output("", @cli.render_wac_diagnostics([error], source, label), 1)
    }
    let bytes = @fs.read_file(path).binary() catch {
      error => {
        let diagnostic = wac_problem(
          request,
          "WAC-P006",
          "failed to read `" + path + "`: " + error.to_string(),
        )
        return output(
          "",
          @cli.render_wac_diagnostics([diagnostic], source, label),
          2,
        )
      }
    }
    // The binary decoder checks actual framing. Text dependencies remain an
    // explicit boundary until the portable WAC text/WIT adapters are implemented.
    if (path.has_suffix(".wat") || path.has_suffix(".wit")) &&
      !(bytes.length() >= 4 &&
      bytes[0] == 0 &&
      bytes[1] == 0x61 &&
      bytes[2] == 0x73 &&
      bytes[3] == 0x6d) {
      let error = wac_problem(
        request,
        "WAC-B002",
        "text dependencies are not yet supported for WAC: `" + path + "`",
      )
      return output("", @cli.render_wac_diagnostics([error], source, label), 1)
    }
    dependencies.push({
      name: request.name,
      version: request.version,
      source: path,
      bytes,
    })
  }
  @cli.verify_wac(
    options,
    source,
    dependencies=ReadOnlyArray::from_array(dependencies),
  )
}
