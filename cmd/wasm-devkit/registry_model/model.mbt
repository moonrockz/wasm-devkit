///|
pub(all) struct Artifact {
  registry : String
  name : String
  requested_version : String?
  version : String
  resolved_registry : String
  digest : String
} derive(Eq, Debug)

///|
pub fn digest(bytes : Bytes) -> String {
  "sha256:" + @crypto.bytes_to_hex_string(@crypto.sha256(bytes))
}

///|
pub fn cache_key(registry : String, name : String, version : String?) -> String {
  let key = Json::array([
    Json::string(registry),
    Json::string(name),
    match version {
      Some(value) => Json::string(value)
      None => Json::null()
    },
  ]).stringify()
  digest(@utf8.encode(key))[7:].to_owned()
}

///|
fn valid_key(name : String, version : String?) -> Bool {
  let key = name + version.map(value => "@" + value).unwrap_or("")
  let owner = if name == "cache:request" {
    "cache:other"
  } else {
    "cache:request"
  }
  let source = "package " + owner + "; let value = new " + key + " { ... };"
  match @verifier.package_requests(@parser.parse(source), source~) {
    Ok(requests) =>
      requests.length() == 1 &&
      requests[0].name == name &&
      requests[0].version == version
    Err(_) => false
  }
}

///|
pub fn valid_registry(registry : String) -> Bool {
  let rest = if registry.has_prefix("https://") {
    registry[8:]
  } else if registry.has_prefix("http://") {
    registry[7:]
  } else {
    return false
  }
  if rest.is_empty() || rest.has_prefix("/") {
    return false
  }
  for unit in rest {
    if unit.to_int() <= 32 || unit.to_int() == 127 {
      return false
    }
  }
  !rest.contains("@") &&
  !rest.contains("?") &&
  !rest.contains("#") &&
  !rest.contains("\\")
}

///|
pub fn valid_digest(value : String) -> Bool {
  if !value.has_prefix("sha256:") || value.length() != 71 {
    return false
  }
  for index in 7..<value.length() {
    let unit = value.code_unit_at(index).to_int()
    if !(unit >= 48 && unit <= 57) && !(unit >= 97 && unit <= 102) {
      return false
    }
  }
  true
}

///|
pub fn Artifact::to_json(self : Artifact) -> Json {
  {
    "schema": 1,
    "registry": Json::string(self.registry),
    "name": Json::string(self.name),
    "requested_version": match self.requested_version {
      Some(value) => Json::string(value)
      None => Json::null()
    },
    "version": Json::string(self.version),
    "resolved_registry": Json::string(self.resolved_registry),
    "digest": Json::string(self.digest),
  }
}

///|
pub fn artifact(input : Json) -> Result[Artifact, String] {
  guard input
    is {
      "schema": 1,
      "registry": String(registry),
      "name": String(name),
      "requested_version": requested,
      "version": String(version),
      "resolved_registry": String(resolved_registry),
      "digest": String(digest),
      ..
    } else {
    return Err("invalid registry artifact metadata")
  }
  let requested_version = match requested {
    Null => None
    String(value) => Some(value)
    _ => return Err("invalid requested version")
  }
  if !valid_registry(registry) ||
    !valid_key(name, Some(version)) ||
    !valid_key(name, requested_version) ||
    !valid_digest(digest) ||
    !(valid_registry(resolved_registry) ||
    valid_registry("https://" + resolved_registry)) ||
    (requested_version is Some(requested) && requested != version) {
    return Err("invalid registry identity, version or digest")
  }
  Ok({ registry, name, requested_version, version, resolved_registry, digest, })
}

///|
pub fn Artifact::matches(
  self : Artifact,
  registry : String,
  name : String,
  requested : String?,
) -> Bool {
  self.registry == registry &&
  self.name == name &&
  self.requested_version == requested
}

///|
pub fn lockfile(
  input : Json,
  registry : String,
) -> Result[ReadOnlyArray[Artifact], String] {
  guard input
    is {
      "schema": 1,
      "registry": String(origin),
      "packages": Array(packages),
      ..
    } else {
    return Err("invalid registry lockfile")
  }
  if origin != registry {
    return Err("lockfile registry does not match --registry")
  }
  let entries = []
  let seen : Map[String, Bool] = Map([])
  for package_data in packages {
    let entry = match artifact(package_data) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let key = cache_key(entry.registry, entry.name, entry.requested_version)
    if entry.registry != registry || seen.contains(key) {
      return Err("lockfile contains another registry or duplicate package key")
    }
    seen[key] = true
    entries.push(entry)
  }
  Ok(ReadOnlyArray::from_array(entries))
}

///|
pub fn lockfile_json(
  registry : String,
  entries : ReadOnlyArray[Artifact],
) -> Json {
  {
    "schema": 1,
    "registry": Json::string(registry),
    "packages": Json::array(
      entries.iter().map(entry => entry.to_json()).to_array(),
    ),
  }
}

///|
pub extend Artifact with Eq::{equal, not_equal}

///|
pub extend Artifact with @debug.Debug::{to_repr}
