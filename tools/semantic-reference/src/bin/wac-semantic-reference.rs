//! Oracles for pinned Document::resolve and Package::from_bytes. Test use only.
use serde_json::{Value, json};
use std::{env, fs};
use wac_parser::Document;
use wac_types::{
    BorrowedPackageKey, DefinedType, ItemKind, Package, SubtypeChecker, Type, TypeAggregator, Types,
};

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
    if path == "--target" {
        let mut args = env::args().skip(2);
        let target_path = args.next().ok_or("expected target package binary")?;
        let world_name = args.next().ok_or("expected target world definition name")?;
        let component_path = args.next().ok_or("expected component binary")?;
        if args.next().is_some() {
            return Err("usage: --target TARGET_BINARY WORLD_NAME COMPONENT_BINARY".into());
        }
        let mut types = Types::new();
        let target =
            Package::from_bytes("oracle:target", None, fs::read(target_path)?, &mut types)?;
        let world = match target.definitions().get(&world_name) {
            Some(ItemKind::Type(Type::World(world))) => *world,
            Some(_) => {
                return Err(format!("target definition `{world_name}` is not a world").into());
            }
            None => return Err(format!("missing target world definition `{world_name}`").into()),
        };
        let component = Package::from_bytes(
            "oracle:component",
            None,
            fs::read(component_path)?,
            &mut types,
        )?;
        wac_types::validate_target(&types, world, component.ty())?;
        println!(
            "{}",
            json!({"target": world, "component": component.ty(), "types": types_json(&types)})
        );
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
    let mut args = env::args().skip(2);
    let mut dependencies = Vec::new();
    let mut aggregate_imports = false;
    while let Some(flag) = args.next() {
        if flag == "--aggregate-imports" {
            if aggregate_imports {
                return Err("duplicate --aggregate-imports flag".into());
            }
            aggregate_imports = true;
            continue;
        }
        if flag != "--dependency" {
            return Err(
                "usage: SOURCE [--aggregate-imports] [--dependency NAME[@VERSION] BINARY]..."
                    .into(),
            );
        }
        let key = args.next().ok_or("expected dependency name")?;
        let binary = args.next().ok_or("expected dependency binary path")?;
        let (name, version) = match key.rsplit_once('@') {
            Some((name, version)) => (name.to_owned(), Some(version.parse()?)),
            None => (key, None),
        };
        if dependencies
            .iter()
            .any(|(n, v, _)| n == &name && v == &version)
        {
            return Err("duplicate dependency key".into());
        }
        dependencies.push((name, version, fs::read(binary)?));
    }
    let packages = dependencies
        .iter()
        .map(|(name, version, bytes)| {
            (
                BorrowedPackageKey::from_name_and_version(name, version.as_ref()),
                bytes.clone(),
            )
        })
        .collect();
    let resolution = document.resolve(packages)?;
    let graph = resolution.graph();
    if aggregate_imports {
        // Match graph::resolve_imports without invoking the component encoder.
        // Public imports() yields implicit requirements before explicit imports.
        let requests = graph.imports().collect::<Vec<_>>();
        for (name, _, node) in &requests {
            if node.is_none()
                && requests
                    .iter()
                    .any(|(other, _, node)| node.is_some() && other == name)
            {
                return Err(
                    format!("implicit import `{name}` conflicts with an explicit import").into(),
                );
            }
        }
        let mut aggregator = TypeAggregator::new();
        let mut cache = Default::default();
        let mut checker = SubtypeChecker::new(&mut cache);
        for (name, kind, _) in &requests {
            aggregator = aggregator.aggregate(name, graph.types(), *kind, &mut checker)?;
        }
        println!(
            "{}",
            json!({
                "types": types_json(aggregator.types()),
                "imports": aggregator.imports().collect::<Vec<_>>(),
                "requests": requests.iter().map(|(name, _, node)| json!({
                    "name": name,
                    "canonical": aggregator.canonical_import_name(name),
                    "explicit": node.map(|id| id.to_string()),
                })).collect::<Vec<_>>()
            })
        );
        return Ok(());
    }
    println!(
        "{}",
        json!({
            "types": types_json(graph.types()),
            "nodes": graph.node_ids().map(|id| {
                let node = &graph[id];
                let alias = graph.get_alias_source(id);
                let role = if node.import_name().is_some() { "import" }
                    else if alias.is_some() { "alias" }
                    else if node.package().is_some() { "instance" }
                    else { "definition" };
                // Graph edges are stored in reverse insertion order. Sort arguments
                // by external name so the snapshot does not expose that storage detail.
                let mut arguments = graph.get_instantiation_arguments(id)
                    .map(|(name, source)| (name.to_owned(), source.to_string()))
                    .collect::<Vec<_>>();
                arguments.sort_by(|a, b| a.0.cmp(&b.0));
                json!({
                    "id": id.to_string(), "role": role, "kind": node.item_kind(),
                    "import": node.import_name(), "name": node.name(),
                    "last_export_name": node.export_name(),
                    "package": node.package().map(|package| graph[package].key().to_string()),
                    "alias": alias.map(|(source, name)| (source.to_string(), name)),
                    "arguments": arguments,
                })
            }).collect::<Vec<_>>(),
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
