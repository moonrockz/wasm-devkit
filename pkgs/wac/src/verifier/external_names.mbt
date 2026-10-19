///|
// WAC 0.12.0 uses wasmparser 0.258.0's default ComponentName grammar.
// Interface version suffixes are opaque at resolution time. Dependency
// versions are checked, and dependency/url/integrity names are import-only.
fn valid_external_name(name : String, importing : Bool) -> Bool {
  if identifier(name) {
    return true
  }
  if name.has_prefix("[constructor]") {
    return identifier(name[13:].to_owned())
  }
  for prefix in ["[method]", "[static]"] {
    if name.has_prefix(prefix) {
      let pieces = name[prefix.length():].split(".").to_array()
      return pieces.length() == 2 &&
        pieces.all(part => identifier(part.to_owned()))
    }
  }
  for prefix in ["url=<", "integrity=<", "locked-dep=<", "unlocked-dep=<"] {
    if !name.has_prefix(prefix) {
      continue
    }
    let ending = if prefix == "unlocked-dep=<" && name.contains("@{") {
      name.find("}>").map(i => i + 1)
    } else {
      name.find(">")
    }
    guard importing && ending is Some(end) else { return false }
    let body = name[prefix.length():end].to_owned()
    let suffix = name[end + 1:].to_owned()
    guard suffix.is_empty() ||
      (
        (prefix == "url=<" || prefix == "locked-dep=<") &&
        valid_integrity_suffix(suffix)
      ) else {
      return false
    }
    match prefix {
      "url=<" => return !body.contains("<")
      "integrity=<" => return valid_integrity(body)
      "locked-dep=<" => return valid_package_external(body, false, false)
      _ => return valid_package_external(body, false, true)
    }
  }
  valid_package_external(name, true, false)
}

///|
fn valid_package_external(
  name : String,
  interface_name : Bool,
  query : Bool,
) -> Bool {
  let at = name.find("@")
  let path = match at {
    Some(at) => name[:at].to_owned()
    None => name
  }
  let parts = path.split("/").to_array()
  guard parts.length() >= (if interface_name { 2 } else { 1 }) &&
    parts.length() <= 2 else {
    return false
  }
  let names = parts[0].split(":").to_array()
  guard names.length() == 2 else { return false }
  for name in names {
    guard identifier(name.to_owned()) else { return false }
    for c in name {
      if c >= 'A' && c <= 'Z' {
        return false
      }
    }
  }
  if parts.length() == 2 && !identifier(parts[1].to_owned()) {
    return false
  }
  match at {
    None => true
    Some(at) => {
      let version = name[at + 1:].to_owned()
      if interface_name {
        !version.contains(">")
      } else if !query {
        semantic_version(version)
      } else if version == "*" {
        true
      } else {
        guard version.has_prefix("{") && version.has_suffix("}") else {
          return false
        }
        let range = version[1:version.length() - 1].to_owned()
        let bounds = range.split(" ").to_array()
        if range.has_prefix(">=") {
          bounds.length() <= 2 &&
          semantic_version(bounds[0][2:].to_owned()) &&
          (
            bounds.length() == 1 ||
            (
              bounds[1].has_prefix("<") &&
              semantic_version(bounds[1][1:].to_owned())
            )
          )
        } else {
          bounds.length() == 1 &&
          range.has_prefix("<") &&
          semantic_version(range[1:].to_owned())
        }
      }
    }
  }
}

///|
fn valid_integrity_suffix(suffix : String) -> Bool {
  suffix.has_prefix(",integrity=<") &&
  suffix.has_suffix(">") &&
  valid_integrity(suffix[12:suffix.length() - 1].to_owned())
}

///|
fn integrity_space(c : Char) -> Bool {
  // Unicode White_Space, matching Rust's split_whitespace.
  match c.to_int() {
    9..<=13
    | 32
    | 133
    | 160
    | 5760
    | 8192..<=8202
    | 8232
    | 8233
    | 8239
    | 8287
    | 12288 => true
    _ => false
  }
}

///|
fn valid_integrity(body : String) -> Bool {
  let hashes : Array[String] = []
  let mut token = StringBuilder()
  let mut token_present = false
  for c in body {
    if integrity_space(c) {
      if token_present {
        hashes.push(token.to_string())
        token = StringBuilder()
        token_present = false
      }
    } else {
      token.write_char(c)
      token_present = true
    }
  }
  if token_present {
    hashes.push(token.to_string())
  }
  guard !hashes.is_empty() else { return false }
  for hash in hashes {
    guard hash.has_prefix("sha256-") ||
      hash.has_prefix("sha384-") ||
      hash.has_prefix("sha512-") else {
      return false
    }
    let content = hash[7:].to_owned()
    let encoded = match content.find("?") {
      Some(i) => content[:i].to_owned()
      None => content
    }
    guard !encoded.is_empty() else { return false }
    let mut padding = 0
    for i in 0..<encoded.length() {
      let c = encoded.code_unit_at(i).to_int()
      if c == 61 && i > 0 && padding < 2 {
        padding += 1
      } else if padding == 0 &&
        (
          (c >= 65 && c <= 90) ||
          (c >= 97 && c <= 122) ||
          (c >= 48 && c <= 57) ||
          c == 43 ||
          c == 47
        ) {
        ()
      } else {
        return false
      }
    }
  }
  true
}
