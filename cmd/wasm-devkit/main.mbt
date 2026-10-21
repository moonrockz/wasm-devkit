///|
async fn main {
  let code = try {
    match @cli.arguments(@env.args()[1:]) {
      Err(message) => {
        @stdio.stderr.write(
          "wasm-devkit: " + message + "\nRun wasm-devkit --help for usage.\n",
        )
        2
      }
      Ok(Help) => {
        @stdio.stdout.write(@cli.help)
        0
      }
      Ok(Version) => {
        @stdio.stdout.write("wasm-devkit " + @cli.version() + "\n")
        0
      }
      Ok(Compare(options)) => {
        let left_data = if options.left == "-" {
          @stdio.stdin.read_all()
        } else {
          @fs.read_file(options.left)
        }
        let right_data = if options.right == "-" {
          @stdio.stdin.read_all()
        } else {
          @fs.read_file(options.right)
        }
        let left = @utf8.decode(left_data.binary(), ignore_bom=false)
        let right = @utf8.decode(right_data.binary(), ignore_bom=false)
        let result = @cli.compare(options, left, right)
        @stdio.stdout.write(result.stdout)
        @stdio.stderr.write(result.stderr)
        result.exit_code
      }
      Ok(Decompile(options)) => {
        let data = if options.path == "-" {
          @stdio.stdin.read_all()
        } else {
          @fs.read_file(options.path)
        }
        let input = data.binary()
        let result = @cli.decompile(options, input)
        // Only a complete document reaches the output file. An existing output
        // with the input's bytes can be the input under another path.
        if result.write_text is Some(text) && options.output is Some(path) {
          if options.path != "-" &&
            @fs.exists(path) &&
            @fs.read_file(path).binary() == input {
            @stdio.stderr.write(
              path + ": output holds the input binary; file was not written\n",
            )
            @sys.exit(2)
          }
          write_document(path, text)
        }
        if !result.stdout.is_empty() {
          @stdio.stdout.write(result.stdout)
        }
        if !result.stderr.is_empty() {
          @stdio.stderr.write(result.stderr)
        }
        result.exit_code
      }
      Ok(Inventory(options)) => {
        let data = if options.path == "-" {
          @stdio.stdin.read_all()
        } else {
          @fs.read_file(options.path)
        }
        let input = data.binary()
        let result = @cli.inventory(options, input)
        if result.write_text is Some(text) && options.output is Some(path) {
          if options.path != "-" &&
            @fs.exists(path) &&
            @fs.read_file(path).binary() == input {
            @stdio.stderr.write(
              path + ": output holds the input binary; file was not written\n",
            )
            @sys.exit(2)
          }
          write_document(path, text)
        }
        @stdio.stdout.write(result.stdout)
        @stdio.stderr.write(result.stderr)
        result.exit_code
      }
      Ok(Split(options)) => {
        let data = if options.path == "-" {
          @stdio.stdin.read_all()
        } else {
          @fs.read_file(options.path)
        }
        match
          @decompiler.split(
            data.binary(),
            select=options.select,
            source_id=options.path,
          ) {
          Err(errors) => {
            @stdio.stderr.write(@cli.render_split_diagnostics(errors))
            1
          }
          Ok(split) => {
            if !split.documents.is_empty() {
              let destination = options.directory
                .trim_end(chars="/\\")
                .to_owned()
              if destination.is_empty() || @fs.exists(destination) {
                @stdio.stderr.write(
                  options.directory +
                  ": split destination must be a new directory\n",
                )
                @sys.exit(2)
              }
              let unique = @fs.tmpdir(prefix="wasm-devkit-split")
              defer (@fs.rmdir(unique) catch { _ => () })
              let staged = destination +
                ".tmp-" +
                @registry_model.digest(@utf8.encode(unique))[7:].to_owned()
              @fs.mkdir(staged)
              defer (@fs.rmdir(staged, recursive=true) catch { _ => () })
              for document in split.documents {
                let path = staged + "/" + document.path
                let parts = path.split("/").to_array()
                let directory = parts[:parts.length() - 1]
                  .map(p => p.to_owned())
                  .join("/")
                @fs.mkdir(directory, recursive=true, allow_exist=true)
                @fs.write_file(path, document.text, create_mode=CreateNew)
              }
              @fs.rename(staged, destination, replace=false)
            }
            0
          }
        }
      }
      Ok(Run(options)) if options.command == Verify => {
        let result = @verification.execute(options)
        if !result.stdout.is_empty() {
          @stdio.stdout.write(result.stdout)
        }
        if !result.stderr.is_empty() {
          @stdio.stderr.write(result.stderr)
        }
        result.exit_code
      }
      Ok(Run(options)) => {
        let data = if options.path == "-" {
          @stdio.stdin.read_all()
        } else {
          @fs.read_file(options.path)
        }
        let source = @utf8.decode(data.binary(), ignore_bom=false)
        let result = @cli.execute(options, source)
        if result.write_text is Some(text) {
          // Do not overwrite a file changed since the read above.
          let current = @utf8.decode(
            @fs.read_file(options.path).binary(),
            ignore_bom=false,
          )
          if current != source {
            @stdio.stderr.write(
              options.path +
              ": changed while formatting; file was not written\n",
            )
            @sys.exit(2)
          }
          @fs.write_file(options.path, text)
        }
        if !result.stdout.is_empty() {
          @stdio.stdout.write(result.stdout)
        }
        if !result.stderr.is_empty() {
          @stdio.stderr.write(result.stderr)
        }
        result.exit_code
      }
    }
  } catch {
    error => {
      @stdio.stderr.write("wasm-devkit: " + error.to_string() + "\n")
      2
    }
  }
  if code != 0 {
    @sys.exit(code)
  }
}

///|
// Stage beside the destination so replacement is one filesystem operation.
// A failed write or rename cannot truncate an existing output document.
async fn write_document(path : String, text : String) -> Unit {
  let unique = @fs.tmpdir(prefix="wasm-devkit-document")
  defer (@fs.rmdir(unique) catch { _ => () })
  let staged = path +
    ".tmp-" +
    @registry_model.digest(@utf8.encode(unique))[7:].to_owned()
  defer (@fs.remove(staged) catch { _ => () })
  @fs.write_file(staged, text, create_mode=CreateNew)
  @fs.rename(staged, path, replace=true)
}
