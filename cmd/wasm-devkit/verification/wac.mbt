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
  let registry = match options.registry {
    Some(settings) => Some(registry_session(settings, base))
    None => None
  }
  defer (if registry is Some(session) { session.close() })
  let root = relative(base, options.deps_dir.unwrap_or("deps"))
  let overrides : Map[String, String] = Map([])
  for mapping in options.dependencies {
    overrides[mapping.name] = relative(base, mapping.path)
  }
  let dependencies : Array[@wac_verifier.PackageSource] = []
  let wit_dependencies : Array[@wac_verifier.WitPackageSource] = []
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
    if !@fs.exists(path) && !explicit && registry is Some(session) {
      let dependency = session.fetch_package(request) catch {
        RegistryProblem(code, message, status) =>
          return output(
            "",
            @cli.render_wac_diagnostics(
              [wac_problem(request, code, message)],
              source,
              label,
            ),
            status,
          )
        error =>
          return output(
            "",
            @cli.render_wac_diagnostics(
              [
                wac_problem(
                  request,
                  "WAC-R003",
                  "registry/cache provider failed: " + error.to_string(),
                ),
              ],
              source,
              label,
            ),
            2,
          )
      }
      dependencies.push(dependency)
      continue
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
    let directory = @fs.kind(path) is Directory
    if explicit && directory {
      return output(
        "",
        @cli.render_wac_diagnostics(
          [
            wac_problem(
              request,
              "WAC-P006",
              "explicit dependency path must be a file: `" + path + "`",
            ),
          ],
          source,
          label,
        ),
        2,
      )
    }
    if directory || path.has_suffix(".wit") {
      let features : @parser.Features = {
        ..@parser.Features::default(),
        fixed_lists: true,
        external_ids: true,
      }
      let inputs : Array[@verifier.PackageInput] = []
      let loaded = try {
        let root = @verifier.PackageInput::Source(
          load_source_package(path, features),
        )
        if directory {
          let deps_dir = path + "/deps"
          if @fs.exists(deps_dir) {
            for entry in @fs.readdir(deps_dir, sort=true) {
              let child = relative(deps_dir, entry)
              if @fs.kind(child) is Directory ||
                entry.has_suffix(".wit") ||
                entry.has_suffix(".wasm") ||
                entry.has_suffix(".wat") {
                match load_package(child, features) {
                  Ok(input) => inputs.push(input)
                  Err(errors) =>
                    return output(
                      "",
                      errors.map(error => error.render()).iter().join("") +
                      request.location.render() +
                      ": package requested here\n",
                      1,
                    )
                }
              }
            }
          }
        }
        root
      } catch {
        error =>
          return output(
            "",
            @cli.render_wac_diagnostics(
              [
                wac_problem(
                  request,
                  "WAC-P006",
                  "failed to read WIT package `" +
                  path +
                  "`: " +
                  error.to_string(),
                ),
              ],
              source,
              label,
            ),
            2,
          )
      }
      wit_dependencies.push({
        name: request.name,
        version: request.version,
        source: path,
        root: loaded,
        dependencies: ReadOnlyArray::from_array(inputs),
      })
      continue
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
    let binary = bytes.length() >= 4 &&
      bytes[0] == 0 &&
      bytes[1] == 0x61 &&
      bytes[2] == 0x73 &&
      bytes[3] == 0x6d
    let bytes = if path.has_suffix(".wat") && !binary {
      let text = @utf8.decode(bytes, ignore_bom=false)
      match @wac_verifier.decode_wat_component_package(text, source_id=path) {
        Ok(model) => model.bytes()
        Err(errors) => {
          let errors = errors.map(problem => {
            let related = problem.related.iter().to_array()
            related.push({
              location: request.location,
              message: "package `" + request.name + "` requested here",
            })
            { ..problem, related: ReadOnlyArray::from_array(related), }
          })
          return output(
            "",
            @cli.render_wac_diagnostics(errors, source, label),
            1,
          )
        }
      }
    } else {
      bytes
    }
    dependencies.push({
      name: request.name,
      version: request.version,
      source: path,
      bytes,
    })
  }
  let result = @cli.verify_wac(
    options,
    source,
    dependencies=ReadOnlyArray::from_array(dependencies),
    wit_dependencies=ReadOnlyArray::from_array(wit_dependencies),
  )
  if result.exit_code == 0 && registry is Some(session) {
    session.save()
  }
  result
}
