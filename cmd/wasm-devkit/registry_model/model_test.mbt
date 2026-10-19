///|
test "registry metadata preserves exact build versions and checks content digests" {
  assert_eq(
    @registry_model.digest(b"abc"),
    "sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
  let record : @registry_model.Artifact = {
    registry: "https://registry.example",
    name: "demo:api",
    requested_version: Some("1.2.3+build.1"),
    version: "1.2.3+build.1",
    resolved_registry: "registry.example",
    digest: @registry_model.digest(b"abc"),
  }
  assert_eq(@registry_model.artifact(record.to_json()), Ok(record))
  assert_true(
    @registry_model.artifact({ ..record, version: "1.2.3+build.2", }.to_json())
    is Err(_),
  )
  assert_true(
    @registry_model.artifact(
      { ..record, version: "01.2.3", requested_version: None, }.to_json(),
    )
    is Err(_),
  )
  assert_true(
    @registry_model.artifact({ ..record, digest: "sha256:bad", }.to_json())
    is Err(_),
  )
  assert_true(
    !record.matches(
      "https://another.example",
      "demo:api",
      record.requested_version,
    ),
  )
  assert_true(
    @registry_model.cache_key(record.registry, record.name, None) !=
    @registry_model.cache_key(
      record.registry,
      record.name,
      Some(record.version),
    ),
  )
  let lock = @registry_model.lockfile_json(record.registry, [record])
  assert_eq(@registry_model.lockfile(lock, record.registry), Ok([record]))
  assert_true(
    @registry_model.lockfile(lock, "https://another.example") is Err(_),
  )
  assert_true(
    @registry_model.lockfile(
      @registry_model.lockfile_json(record.registry, [record, record]),
      record.registry,
    )
    is Err(_),
  )
}

///|
test "registry identities reject source injection and ambiguous URLs" {
  for
    url in [
      "file:///tmp/data", "https://user:secret@host", "https://host/#fragment", "http:///missing-host",
      "https://host/\npath",
    ] {
    assert_true(!@registry_model.valid_registry(url))
  }
  let record : @registry_model.Artifact = {
    registry: "http://localhost:8080",
    name: "demo:api",
    requested_version: None,
    version: "1.0.0",
    resolved_registry: "localhost:8080",
    digest: @registry_model.digest(b""),
  }
  assert_true(
    @registry_model.artifact(
      { ..record, name: "demo:api { ... }; let other = new demo:other", }.to_json(),
    )
    is Err(_),
  )
  assert_true(
    @registry_model.artifact({ ..record, version: "1.0.0 { ... };", }.to_json())
    is Err(_),
  )
}
