///|
priv suberror RegistryFailure {
  RegistryProblem(String, String, Int32)
}

///|
priv struct RegistrySession {
  options : @cli.RegistryOptions
  cache : String
  lock_path : String?
  locked : ReadOnlyArray[@registry_model.Artifact]?
  resolved : Array[@registry_model.Artifact]
  temporary : String
  config : String?
  provider : String
  mut provider_checked : Bool
}

///|
async fn atomic_write(path : String, bytes : Bytes, replace~ : Bool) -> Unit {
  let unique = @fs.tmpdir(prefix="wasm-devkit-write")
  defer @fs.rmdir(unique)
  let staged = parent(path) +
    "/.wasm-devkit-" +
    @registry_model.digest(@utf8.encode(unique))[7:].to_owned() +
    ".tmp"
  defer (@fs.remove(staged) catch { _ => () })
  @fs.write_file(staged, bytes, create_mode=CreateNew)
  @fs.rename(staged, path, replace~)
}

///|
async fn registry_session(
  options : @cli.RegistryOptions,
  base : String,
) -> RegistrySession {
  let cache = match options.cache_dir {
    Some(path) => relative(base, path)
    None => {
      let root = match @env.get_env_var("XDG_CACHE_HOME") {
        Some(root) => Some(root)
        None =>
          match @env.get_env_var("LOCALAPPDATA") {
            Some(root) => Some(root)
            None => @env.get_env_var("HOME").map(home => home + "/.cache")
          }
      }
      match root {
        Some(root) => root + "/wasm-devkit"
        None =>
          fail("set --cache-dir because no user cache directory is configured")
      }
    }
  }
  let lock_path = options.lockfile.map(path => relative(base, path))
  if lock_path is Some(path) {
    @fs.mkdir(path + ".lock") catch {
      error =>
        fail(
          "cannot acquire registry lockfile guard `" +
          path +
          ".lock`: " +
          error.to_string(),
        )
    }
  }
  let mut ready = false
  defer (if !ready { if lock_path is Some(path) { @fs.rmdir(path + ".lock") } })
  let locked = match lock_path {
    Some(path) if @fs.exists(path) =>
      match
        @registry_model.lockfile(
          @json.parse(@fs.read_file(path).text()),
          options.url,
        ) {
        Ok(entries) => Some(entries)
        Err(error) => fail(path + ": " + error)
      }
    _ => None
  }
  @fs.mkdir(cache + "/entries", recursive=true, allow_exist=true)
  @fs.mkdir(cache + "/content", recursive=true, allow_exist=true)
  let temporary = @fs.tmpdir(prefix="wasm-devkit-registry")
  let provider = if options.provider.contains("/") ||
    options.provider.contains("\\") {
    relative(base, options.provider)
  } else {
    options.provider
  }
  let result = {
    options,
    cache,
    lock_path,
    locked,
    resolved: [],
    temporary,
    config: options.config.map(path => relative(base, path)),
    provider,
    provider_checked: false,
  }
  ready = true
  result
}

///|
async fn RegistrySession::close(self : RegistrySession) -> Unit nocancel {
  defer @fs.rmdir(self.temporary, recursive=true)
  if self.lock_path is Some(path) {
    @fs.rmdir(path + ".lock")
  }
}

///|
async fn RegistrySession::save(self : RegistrySession) -> Unit {
  if self.lock_path is Some(path) && self.locked is None {
    let text = @registry_model.lockfile_json(
        self.options.url,
        ReadOnlyArray::from_array(self.resolved),
      ).stringify() +
      "\n"
    atomic_write(path, @utf8.encode(text), replace=false)
  }
}

///|
fn RegistrySession::entry_path(
  self : RegistrySession,
  name : String,
  version : String?,
) -> String {
  self.cache +
  "/entries/" +
  @registry_model.cache_key(self.options.url, name, version) +
  ".json"
}

///|
fn RegistrySession::content_path(
  self : RegistrySession,
  artifact : @registry_model.Artifact,
) -> String {
  self.cache + "/content/" + artifact.digest[7:].to_owned() + ".wasm"
}

///|
async fn RegistrySession::read_cached(
  self : RegistrySession,
  name : String,
  version : String?,
) -> (@registry_model.Artifact, Bytes)? {
  let path = self.entry_path(name, version)
  if !@fs.exists(path) {
    return None
  }
  let metadata = @json.parse(@fs.read_file(path).text()) catch {
    error =>
      raise RegistryProblem(
        "WAC-R002",
        path + ": invalid cache metadata: " + error.to_string(),
        2,
      )
  }
  let entry = match @registry_model.artifact(metadata) {
    Ok(entry) => entry
    Err(error) => raise RegistryProblem("WAC-R002", path + ": " + error, 2)
  }
  if !entry.matches(self.options.url, name, version) {
    raise RegistryProblem(
      "WAC-R002", "cached package identity does not match the requested registry/key",
      2,
    )
  }
  let content = self.content_path(entry)
  if !@fs.exists(content) {
    return None
  }
  let bytes = @fs.read_file(content).binary()
  if @registry_model.digest(bytes) != entry.digest {
    raise RegistryProblem(
      "WAC-R002", "cached package content digest does not match metadata; use --refresh to fetch it again",
      2,
    )
  }
  Some((entry, bytes))
}

///|
async fn RegistrySession::download(
  self : RegistrySession,
  name : String,
  version : String?,
  expected : @registry_model.Artifact?,
) -> (@registry_model.Artifact, Bytes) {
  if !self.provider_checked {
    let (code, out, _) = @process.collect_output(self.provider, ["--version"])
    let version = out.text().trim()
    if code != 0 ||
      !version.has_prefix("wasm-devkit-warg ") ||
      !version.has_suffix(" protocol=1 warg-client=0.9.0") {
      raise RegistryProblem(
        "WAC-R003", "registry access requires wasm-devkit-warg with protocol=1 and warg-client=0.9.0",
        2,
      )
    }
    self.provider_checked = true
  }
  let output_path = self.temporary + "/download.wasm"
  let request : Json = {
    "schema": 1,
    "registry": Json::string(self.options.url),
    "name": Json::string(name),
    "version": match version {
      Some(value) => Json::string(value)
      None => Json::null()
    },
    "storage": Json::string(
      self.cache +
      "/warg/" +
      @registry_model.cache_key(self.options.url, "", None),
    ),
    "output": Json::string(output_path),
    "config": match self.config {
      Some(value) => Json::string(value)
      None => Json::null()
    },
  }
  let (code, out, error) = @process.collect_output(self.provider, [
    "fetch",
    request.stringify(),
  ])
  let response = @json.parse(out.text()) catch {
    _ =>
      raise RegistryProblem(
        "WAC-R003",
        "registry provider returned an invalid response: " + error.text(),
        2,
      )
  }
  if code != 0 {
    guard response
      is {
        "schema": 1,
        "error": { "code": String(kind), "message": String(message), .. },
        ..
      } else {
      raise RegistryProblem(
        "WAC-R003", "registry provider failed without a structured error", 2,
      )
    }
    let missing = kind == "not-found" ||
      kind == "unknown-version" ||
      kind == "no-releases"
    raise RegistryProblem(
      if missing {
        "WAC-R001"
      } else {
        "WAC-R003"
      },
      kind + ": " + message,
      if missing {
        1
      } else {
        2
      },
    )
  }
  guard response is Object(fields) else {
    raise RegistryProblem("WAC-R003", "invalid registry response", 2)
  }
  fields["requested_version"] = match version {
    Some(value) => Json::string(value)
    None => Json::null()
  }
  let artifact = match @registry_model.artifact(response) {
    Ok(value) => value
    Err(error) => raise RegistryProblem("WAC-R003", error, 2)
  }
  if !artifact.matches(self.options.url, name, version) {
    raise RegistryProblem(
      "WAC-R003", "registry provider returned another package identity", 2,
    )
  }
  let bytes = @fs.read_file(output_path).binary()
  if @registry_model.digest(bytes) != artifact.digest {
    raise RegistryProblem(
      "WAC-R003", "downloaded package digest does not match the authenticated registry record",
      2,
    )
  }
  if expected is Some(expected) &&
    (
      artifact.version != expected.version ||
      artifact.digest != expected.digest ||
      artifact.resolved_registry != expected.resolved_registry
    ) {
    raise RegistryProblem(
      "WAC-R002", "resolved registry content or identity differs from the lockfile",
      2,
    )
  }
  atomic_write(self.content_path(artifact), bytes, replace=true)
  let exact = { ..artifact, requested_version: Some(artifact.version), }
  for entry in [exact, artifact] {
    atomic_write(
      self.entry_path(entry.name, entry.requested_version),
      @utf8.encode(entry.to_json().stringify() + "\n"),
      replace=true,
    )
  }
  (artifact, bytes)
}

///|
async fn RegistrySession::fetch_package(
  self : RegistrySession,
  request : @wac_verifier.PackageRequest,
) -> @wac_verifier.PackageSource {
  let locked = match self.locked {
    Some(entries) => {
      let mut found = None
      for entry in entries {
        if entry.name == request.name &&
          entry.requested_version == request.version {
          found = Some(entry)
          break
        }
      }
      match found {
        Some(entry) => Some(entry)
        None =>
          raise RegistryProblem(
            "WAC-R002",
            "registry lockfile has no entry for `" +
            request.name +
            request.version.map(v => "@" + v).unwrap_or("") +
            "`",
            2,
          )
      }
    }
    None => None
  }
  let version = match locked {
    Some(entry) => Some(entry.version)
    None => request.version
  }
  let cached = if self.options.refresh {
    None
  } else {
    self.read_cached(request.name, version)
  }
  let (artifact, bytes) = match cached {
    Some(entry) => entry
    None => {
      if self.options.offline {
        raise RegistryProblem(
          "WAC-R001",
          "package `" +
          request.name +
          version.map(v => "@" + v).unwrap_or("") +
          "` is absent from the checked cache in offline mode",
          1,
        )
      }
      self.download(request.name, version, locked)
    }
  }
  if locked is Some(expected) &&
    (
      artifact.version != expected.version ||
      artifact.digest != expected.digest ||
      artifact.resolved_registry != expected.resolved_registry
    ) {
    raise RegistryProblem(
      "WAC-R002", "resolved registry content or identity differs from the lockfile",
      2,
    )
  }
  self.resolved.push({ ..artifact, requested_version: request.version, })
  {
    name: request.name,
    version: request.version,
    source: self.content_path(artifact),
    bytes,
  }
}
