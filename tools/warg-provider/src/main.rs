//! Network transport only. MoonBit checks digests and verifies package semantics.
use serde::Deserialize;
use serde_json::{Value, json};
use std::{env, fs, path::PathBuf, time::Duration};
use warg_client::{ClientError, Config, FileSystemClient};
use warg_protocol::{Version, VersionReq, registry::PackageName};

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Request {
    schema: u32,
    registry: String,
    name: String,
    version: Option<String>,
    storage: PathBuf,
    output: PathBuf,
    config: Option<PathBuf>,
}

struct Failure {
    code: &'static str,
    message: String,
}

fn failure(code: &'static str, error: impl std::fmt::Display) -> Failure {
    Failure {
        code,
        message: error.to_string(),
    }
}

fn client_failure(error: ClientError) -> Failure {
    let code = match &error {
        ClientError::PackageDoesNotExist { .. }
        | ClientError::PackageDoesNotExistWithHintHeader { .. } => "not-found",
        ClientError::PackageVersionDoesNotExist { .. }
        | ClientError::PackageVersionRequirementDoesNotExist { .. } => "unknown-version",
        ClientError::OperatorValidationFailed { .. }
        | ClientError::PackageValidationFailed { .. }
        | ClientError::IncorrectContent { .. } => "invalid-registry-data",
        _ => "registry-transport",
    };
    failure(code, error)
}

async fn fetch(request: Request) -> Result<Value, Failure> {
    if request.schema != 1 {
        return Err(failure("protocol", "unsupported request schema"));
    }
    let url = url::Url::parse(&request.registry).map_err(|e| failure("configuration", e))?;
    if !matches!(url.scheme(), "http" | "https")
        || !url.username().is_empty()
        || url.password().is_some()
        || url.fragment().is_some()
        || url.query().is_some()
    {
        return Err(failure(
            "configuration",
            "registry requires an HTTP(S) URL without credentials, query or fragment",
        ));
    }
    let name = PackageName::new(request.name.clone()).map_err(|e| failure("identity", e))?;
    let version = request
        .version
        .as_deref()
        .map(str::parse::<Version>)
        .transpose()
        .map_err(|e| failure("identity", e))?;
    let mut config = match &request.config {
        Some(path) => Config::from_file(path).map_err(|e| failure("configuration", e))?,
        None => Config::default(),
    };
    fs::create_dir_all(&request.storage).map_err(|e| failure("storage", e))?;
    let storage = fs::canonicalize(&request.storage).map_err(|e| failure("storage", e))?;
    config.registries_dir = Some(storage.join("registries"));
    config.content_dir = Some(storage.join("content"));
    config.namespace_map_path = Some(storage.join("namespaces"));
    config.disable_interactive = true;
    let client = FileSystemClient::new_with_config(Some(&request.registry), &config, None)
        .await
        .map_err(client_failure)?;
    // Match RegistryPackageResolver: update the authenticated package log before
    // selecting an exact release or the latest non-yanked stable release.
    client
        .fetch_packages([&name])
        .await
        .map_err(client_failure)?;
    let download = match &version {
        Some(version) => client
            .download_exact(&name, version)
            .await
            .map_err(client_failure)?,
        None => client
            .download(&name, &VersionReq::STAR)
            .await
            .map_err(client_failure)?
            .ok_or_else(|| {
                failure(
                    "no-releases",
                    "package has no matching non-yanked stable release",
                )
            })?,
    };
    fs::copy(&download.path, &request.output).map_err(|e| failure("storage", e))?;
    let resolved_registry = client
        .get_warg_registry(name.namespace())
        .await
        .map_err(client_failure)?
        .map(|domain| domain.to_string())
        .unwrap_or_else(|| client.url().to_string());
    Ok(json!({
        "schema": 1, "name": request.name, "registry": request.registry,
        "resolved_registry": resolved_registry, "version": download.version.to_string(),
        "digest": download.digest.to_string()
    }))
}

#[tokio::main]
async fn main() {
    let args = env::args().skip(1).collect::<Vec<_>>();
    if args == ["--version"] {
        println!(
            "wasm-devkit-warg {} protocol=1 warg-client=0.9.0",
            env!("CARGO_PKG_VERSION")
        );
        return;
    }
    let result = match args.as_slice() {
        [command, input] if command == "fetch" => match serde_json::from_str::<Request>(input) {
            Ok(request) => {
                match tokio::time::timeout(Duration::from_secs(120), fetch(request)).await {
                    Ok(result) => result,
                    Err(_) => Err(failure("registry-transport", "registry request timed out")),
                }
            }
            Err(error) => Err(failure("protocol", error)),
        },
        _ => Err(failure(
            "protocol",
            "usage: wasm-devkit-warg fetch REQUEST_JSON | --version",
        )),
    };
    match result {
        Ok(value) => println!("{value}"),
        Err(error) => {
            println!(
                "{}",
                json!({"schema": 1, "error": {"code": error.code, "message": error.message}})
            );
            std::process::exit(1);
        }
    }
}
