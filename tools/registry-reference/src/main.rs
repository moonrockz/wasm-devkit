//! Controlled loopback registry and the actual pinned WAC registry resolver.
//! The fixed keys below are public test keys from WAC's Apache-2.0 test suite.
use anyhow::{Context, Result, bail};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::{collections::HashSet, env, fs, path::Path, time::Duration};
use warg_client::{
    FileSystemClient,
    storage::{ContentStorage, PublishEntry, PublishInfo},
};
use warg_crypto::signing::PrivateKey;
use warg_protocol::{operator::NamespaceState, registry::PackageName};

const OPERATOR: &str = "ecdsa-p256:I+UlDo0HxyBBFeelhPPWmD+LnklOpqZDkrFP5VduASk=";
const PUBLISHER: &str = "ecdsa-p256:2CV1EpLaSYEn4In4OAEDAj5O4Hzu8AFAxgHXuG310Ew=";

async fn serve(root: &Path, manifest: &Path) -> Result<()> {
    fs::create_dir_all(root)?;
    let root = fs::canonicalize(root)?;
    let stop = root.join("stop");
    let config = warg_server::Config::new(
        PrivateKey::decode(OPERATOR.to_owned())?,
        Some(vec![("test".to_owned(), NamespaceState::Defined)]),
        root.join("server"),
    )
    .with_addr(([127, 0, 0, 1], 0))
    .with_checkpoint_interval(Duration::from_millis(25))
    .with_shutdown(async move {
        while !stop.exists() {
            tokio::time::sleep(Duration::from_millis(25)).await;
        }
    });
    // No content policy: an authenticated registry may contain invalid component
    // bytes, which the product must reject after downloading or caching them.
    let server = warg_server::Server::new(config).initialize().await?;
    let url = format!("http://{}", server.local_addr()?);
    let task = tokio::spawn(server.serve());
    let config = warg_client::Config {
        home_url: Some(url.clone()),
        registries_dir: Some(root.join("publisher/registries")),
        content_dir: Some(root.join("publisher/content")),
        namespace_map_path: Some(root.join("publisher/namespaces")),
        disable_interactive: true,
        ..Default::default()
    };
    let client = FileSystemClient::new_with_config(None, &config, None).await?;
    let seed: Value = serde_json::from_slice(&fs::read(manifest)?)?;
    let mut initialized = HashSet::new();
    let mut published = Vec::new();
    for row in seed
        .as_array()
        .context("fixture manifest must be an array")?
    {
        let name = PackageName::new(
            row["name"]
                .as_str()
                .context("missing package name")?
                .to_owned(),
        )?;
        let mut entries = Vec::new();
        if initialized.insert(name.clone()) {
            entries.push(PublishEntry::Init);
        }
        if let Some(version) = row["version"].as_str() {
            let path = manifest
                .parent()
                .unwrap()
                .join(row["source"].as_str().context("missing fixture source")?);
            let bytes = match row["format"].as_str() {
                Some("wat") => wat::parse_file(path)?,
                Some("wit") => {
                    let mut resolve = wit_parser::Resolve::new();
                    let package = resolve.push_path(path)?.0;
                    wit_component::encode(&resolve, package)?
                }
                Some("raw") => fs::read(path)?,
                _ => bail!("unsupported fixture format"),
            };
            let digest = format!("sha256:{:x}", Sha256::digest(&bytes));
            let content = client
                .content()
                .store_content(
                    Box::pin(futures::stream::once(async move { Ok(bytes.into()) })),
                    None,
                )
                .await?;
            entries.push(PublishEntry::Release {
                version: version.parse()?,
                content,
            });
            if row["yanked"] == true {
                entries.push(PublishEntry::Yank {
                    version: version.parse()?,
                });
            }
            published.push(json!({"name": name, "version": version, "digest": digest, "yanked": row["yanked"] == true}));
        }
        let id = client
            .publish_with_info(
                &PrivateKey::decode(PUBLISHER.to_owned())?,
                PublishInfo {
                    name: name.clone(),
                    head: None,
                    entries,
                },
            )
            .await?;
        client
            .wait_for_publish(&name, &id, Duration::from_millis(25))
            .await?;
    }
    drop(client);
    let reference = warg_client::Config {
        registries_dir: Some(root.join("reference/registries")),
        content_dir: Some(root.join("reference/content")),
        namespace_map_path: Some(root.join("reference/namespaces")),
        ..config
    };
    reference.write_to_file(&root.join("reference-config.json"))?;
    fs::write(
        root.join("running.json"),
        serde_json::to_vec(&json!({"registry": url, "published": published}))?,
    )?;
    task.await??;
    Ok(())
}

async fn resolve(config: &Path, source: &Path, deps: Option<&Path>) -> Result<()> {
    let config = warg_client::Config::from_file(config)?;
    let source = fs::read_to_string(source)?;
    let document = wac_parser::Document::parse(&source)?;
    let mut keys = wac_resolver::packages(&document)?;
    let mut packages = match deps {
        Some(path) => wac_resolver::FileSystemPackageResolver::new(path, Default::default(), false)
            .resolve(&keys)?,
        None => Default::default(),
    };
    keys.retain(|key, _| !packages.contains_key(key));
    let resolver =
        wac_resolver::RegistryPackageResolver::new_with_config(None, &config, None).await?;
    packages.extend(resolver.resolve(&keys).await?);
    let selected = packages.iter().map(|(key, bytes)| json!({"key": key.to_string(), "digest": format!("sha256:{:x}", Sha256::digest(bytes))})).collect::<Vec<_>>();
    document.resolve(packages)?;
    println!("{}", json!({"packages": selected}));
    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = env::args().skip(1).collect::<Vec<_>>();
    match args.as_slice() {
        [mode, root, manifest] if mode == "serve" => {
            serve(Path::new(root), Path::new(manifest)).await
        }
        [mode, config, source] if mode == "resolve" => {
            resolve(Path::new(config), Path::new(source), None).await
        }
        [mode, config, source, deps] if mode == "resolve" => {
            resolve(Path::new(config), Path::new(source), Some(Path::new(deps))).await
        }
        _ => bail!("usage: registry-reference serve ROOT MANIFEST | resolve CONFIG SOURCE"),
    }
}
