///|
fn output(out : String, errors : String, exit_code : Int32) -> @cli.Output {
  { stdout: out, stderr: errors, exit_code, write_text: None, }
}

///|
fn parent(path : String) -> String {
  let mut separator = -1
  for i in 0..<path.length() {
    let c = path.code_unit_at(i).to_int()
    if c == 47 || c == 92 {
      separator = i
    }
  }
  if separator < 0 {
    "."
  } else if separator == 0 {
    path[:1].to_owned()
  } else {
    path[:separator].to_owned()
  }
}

///|
fn relative(base : String, path : String) -> String {
  if path.has_prefix("/") ||
    path.has_prefix("\\") ||
    (path.length() > 1 && path.code_unit_at(1).to_int() == 58) {
    path
  } else {
    base + "/" + path
  }
}

///|
async fn read_document(
  path : String,
  features : @parser.Features,
) -> @verifier.Document {
  let source = @utf8.decode(@fs.read_file(path).binary(), ignore_bom=false)
  @verifier.Document::from_parse(path, source, @parser.parse(source, features~))
}

///|
async fn load_source_package(
  path : String,
  features : @parser.Features,
) -> @verifier.SourcePackage {
  let documents : Array[@verifier.Document] = []
  if @fs.kind(path) is Directory {
    for entry in @fs.readdir(path, sort=true) {
      let child = relative(path, entry)
      if entry.has_suffix(".wit") && @fs.kind(child) is Regular {
        documents.push(read_document(child, features))
      }
    }
  } else {
    documents.push(read_document(path, features))
  }
  { documents: ReadOnlyArray::from_array(documents), }
}

///|
async fn load_package(
  path : String,
  features : @parser.Features,
) -> Result[@verifier.PackageInput, ReadOnlyArray[@verifier.Diagnostic]] {
  if @fs.kind(path) is Directory {
    Ok(Source(load_source_package(path, features)))
  } else if path.has_suffix(".wasm") {
    @verifier.decode_package(@fs.read_file(path).binary(), source_id=path).map(input => {
      @verifier.PackageInput::Encoded(input)
    })
  } else if path.has_suffix(".wat") {
    let text = @utf8.decode(@fs.read_file(path).binary(), ignore_bom=false)
    @verifier.decode_wat_package(text, source_id=path).map(input => {
      @verifier.PackageInput::Encoded(input)
    })
  } else {
    Ok(Source(load_source_package(path, features)))
  }
}

///|
async fn wit(options : @cli.Options) -> @cli.Output {
  let features = @parser.Features::reference()
  let is_directory = options.path != "-" && @fs.kind(options.path) is Directory
  let base = options.base.unwrap_or(
    if is_directory {
      options.path
    } else {
      parent(options.path)
    },
  )
  let root = if options.path == "-" {
    let text = @utf8.decode(@stdio.stdin.read_all().binary(), ignore_bom=false)
    @verifier.PackageInput::Source({
      documents: [
        @verifier.Document::from_parse(
          "<stdin>",
          text,
          @parser.parse(text, features~),
        ),
      ],
    })
  } else {
    match load_package(options.path, features) {
      Ok(input) => input
      Err(diagnostics) =>
        return output(
          "",
          diagnostics.map(diagnostic => diagnostic.render()).iter().join(""),
          1,
        )
    }
  }
  let dependencies : Array[@verifier.PackageInput] = []
  let errors : Array[@verifier.Diagnostic] = []
  let deps_dir = relative(base, options.deps_dir.unwrap_or("deps"))
  if @fs.exists(deps_dir) {
    if !(@fs.kind(deps_dir) is Directory) {
      return output("", deps_dir + ": dependency root must be a directory\n", 2)
    }
    for entry in @fs.readdir(deps_dir, sort=true) {
      let path = relative(deps_dir, entry)
      if @fs.kind(path) is Directory ||
        entry.has_suffix(".wit") ||
        entry.has_suffix(".wasm") ||
        entry.has_suffix(".wat") {
        match load_package(path, features) {
          Ok(input) => dependencies.push(input)
          Err(diagnostics) => errors.append(diagnostics.iter().to_array())
        }
      }
    }
  } else if options.deps_dir is Some(_) {
    return output("", deps_dir + ": dependency directory does not exist\n", 2)
  }
  for mapping in options.dependencies {
    let path = relative(base, mapping.path)
    // Explicit mappings are checked even if the root never references them.
    if !@fs.exists(path) {
      return output("", path + ": dependency mapping does not exist\n", 2)
    }
    let package_input = match load_package(path, features) {
      Ok(input) => input
      Err(diagnostics) => {
        errors.append(diagnostics.iter().to_array())
        continue
      }
    }
    match package_input.identity() {
      Err(diagnostics) => errors.append(diagnostics.iter().to_array())
      Ok(identity) => {
        let base_name = identity.namespace_name + ":" + identity.name
        if mapping.name != identity.key() && mapping.name != base_name {
          let message = "dependency mapping expected " +
            mapping.name +
            ", found " +
            identity.key()
          let mut location : @verifier.Location = {
            source: path,
            position: SourceSpan({ start: 0, end: 0, }),
          }
          match package_input {
            Source(source_package) =>
              for document in source_package.documents {
                for node in document.ast.nodes {
                  if node.data is Package(nested=false, ..) {
                    location = @verifier.Location::text(document.id, node.span)
                  }
                }
              }
            Encoded(_) => location = @verifier.Location::binary(path)
          }
          errors.push({
            code: "WIT-S011",
            message,
            primary: { location, message, },
            related: [],
          })
        }
      }
    }
    // Explicit mappings override discovered packages with the same declared identity.
    if package_input.identity() is Ok(identity) {
      let retained = dependencies.filter(existing => {
        match existing.identity() {
          Ok(previous) => previous != identity
          Err(_) => true
        }
      })
      dependencies.clear()
      dependencies.append(retained)
    }
    dependencies.push(package_input)
  }
  let sources : Array[(String, String)] = []
  for package_input in [root].iter().concat(dependencies.iter()) {
    if package_input is Source(source_package) {
      for document in source_package.documents {
        sources.push((document.id, document.text))
      }
    }
  }
  if !errors.is_empty() {
    return output(
      "",
      @cli.render_wit_diagnostics(
        ReadOnlyArray::from_array(errors),
        ReadOnlyArray::from_array(sources),
      ),
      1,
    )
  }
  match
    @verifier.resolve_packages(
      root,
      dependencies=ReadOnlyArray::from_array(dependencies),
      semantic_features={
        enabled: options.semantic_features,
        all_enabled: options.all_semantic_features,
      },
    ) {
    Ok(model) => {
      if options.world is Some(_) {
        if model.select_world(name=options.world) is Err(diagnostics) {
          return output(
            "",
            @cli.render_wit_diagnostics(
              diagnostics,
              ReadOnlyArray::from_array(sources),
            ),
            1,
          )
        }
      }
      output(
        if options.json {
          model.world_summary().stringify() + "\n"
        } else {
          (if options.path == "-" { "<stdin>" } else { options.path }) +
          ": verified wit\n"
        },
        "",
        0,
      )
    }
    Err(diagnostics) =>
      output(
        "",
        @cli.render_wit_diagnostics(
          diagnostics,
          ReadOnlyArray::from_array(sources),
        ),
        1,
      )
  }
}

///|
/// I/O adapter for the pure language verifiers. Components are never executed.
pub async fn execute(options : @cli.Options) -> @cli.Output {
  match options.language {
    Wit => wit(options)
    Wac => {
      if options.deps_dir is Some(_) || !options.dependencies.is_empty() {
        return output(
          "",
          options.path +
          ":1:1: error WAC-S003: dependency providers are not yet supported for WAC\n",
          1,
        )
      }
      let data = if options.path == "-" {
        @stdio.stdin.read_all()
      } else {
        @fs.read_file(options.path)
      }
      let source = @utf8.decode(data.binary(), ignore_bom=false)
      @cli.execute(options, source)
    }
  }
}
