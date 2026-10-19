//! Oracles for pinned Document::resolve and Package::from_bytes. Test use only.
use serde_json::{Value, json};
use std::{env, fs};
use wac_parser::Document;
use wac_types::{DefinedType, Package, Types};

fn types_json(types: &Types) -> Value {
    // JSON object keys cannot preserve core module import pairs. Ordered entry
    // arrays also retain interface/world declaration order for comparisons.
    let modules = types.modules().map(|module| json!({
        "imports": module.imports.iter().map(|((module, name), ty)| json!({"module": module, "name": name, "type": ty})).collect::<Vec<_>>(),
        "exports": module.exports.iter().collect::<Vec<_>>()
    })).collect::<Vec<_>>();
    let interfaces = types
        .interfaces()
        .map(|interface| {
            json!({
                "id": interface.id,
                "uses": interface.uses.iter().collect::<Vec<_>>(),
                "exports": interface.exports.iter().collect::<Vec<_>>()
            })
        })
        .collect::<Vec<_>>();
    let worlds = types
        .worlds()
        .map(|world| {
            json!({
                "id": world.id,
                "uses": world.uses.iter().collect::<Vec<_>>(),
                "imports": world.imports.iter().collect::<Vec<_>>(),
                "exports": world.exports.iter().collect::<Vec<_>>()
            })
        })
        .collect::<Vec<_>>();
    json!({
        "defined": types.defined_types().map(|ty| match ty {
            DefinedType::Record(record) => json!({"record": record.fields.iter().collect::<Vec<_>>()}),
            DefinedType::Variant(variant) => json!({"variant": variant.cases.iter().collect::<Vec<_>>()}),
            _ => json!(ty)
        }).collect::<Vec<_>>(),
        "resources": types.resources().collect::<Vec<_>>(),
        "funcs": types.func_types().map(|ty| json!({
            "params": ty.params.iter().collect::<Vec<_>>(), "result": ty.result, "async": ty.is_async
        })).collect::<Vec<_>>(),
        "interfaces": interfaces, "worlds": worlds, "modules": modules
    })
}

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let path = env::args().nth(1).ok_or("expected WAC source file")?;
    if path == "--version" {
        println!("wac-parser 0.12.0 5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9");
        return Ok(());
    }
    if path == "--package" {
        let mut args = env::args().skip(2);
        let name = args.next().ok_or("expected package name")?;
        let path = args.next().ok_or("expected component binary path")?;
        let version = args.next().map(|value| value.parse()).transpose()?;
        if args.next().is_some() {
            return Err("usage: --package NAME BINARY [VERSION]".into());
        }
        let mut types = Types::new();
        let package = Package::from_bytes(&name, version.as_ref(), fs::read(path)?, &mut types)?;
        println!(
            "{}",
            json!({
                "name": package.name(), "version": package.version().map(ToString::to_string),
                "world": package.ty(), "instance": package.instance_type(),
                "definitions": package.definitions().iter().collect::<Vec<_>>(),
                "types": types_json(&types)
            })
        );
        return Ok(());
    }
    let source = fs::read_to_string(path)?;
    let document = Document::parse(&source)?;
    let resolution = document.resolve(Default::default())?;
    let graph = resolution.graph();
    println!(
        "{}",
        json!({
            "types": types_json(graph.types()),
            "imports": graph.imports().map(|(name, kind, _)| (name, kind)).collect::<Vec<_>>(),
            // The public graph API exposes only the last export name on each node,
        // not the complete export-name map. Keep this projection explicit.
        "exported_nodes": graph.node_ids().filter_map(|id| graph[id].export_name().map(|name| json!({"last_export_name": name, "kind": graph[id].item_kind()}))).collect::<Vec<_>>()
        })
    );
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("{error:#}");
        std::process::exit(1);
    }
}
