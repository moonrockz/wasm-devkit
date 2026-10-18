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
