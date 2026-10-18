//! Test oracle for the pinned wit-parser::Resolve API. Never used by the product.
use std::env;
use wit_parser::{Resolve, WorldItem, WorldKey};

fn entry(key: &WorldKey, item: &WorldItem) -> serde_json::Value {
    let key = match key {
        WorldKey::Name(name) => serde_json::json!({"name": name}),
        WorldKey::Interface(id) => serde_json::json!({"interface": id.index()}),
    };
    serde_json::json!({"key": key, "item": item})
}

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let path = env::args().nth(1).ok_or("expected WIT file or directory")?;
    if path == "--version" {
        println!("wit-parser 0.262.0 e22db44da4eaf17a0e46ec55b911c7539589a3cc");
        return Ok(());
    }
    let mut resolve = Resolve::default();
    resolve.push_path(path)?;
    let mut value = serde_json::to_value(&resolve)?;
    // Resolve's JSON map keys cannot distinguish a user name `interface-0`
    // from WorldKey::Interface(0). Preserve actual key discriminants and items.
    let entries = resolve.worlds.iter().map(|(_, world)| {
        serde_json::json!({
            "imports": world.imports.iter().map(|(key, item)| entry(key, item)).collect::<Vec<_>>(),
            "exports": world.exports.iter().map(|(key, item)| entry(key, item)).collect::<Vec<_>>()
        })
    }).collect::<Vec<_>>();
    value["world-entries"] = serde_json::Value::Array(entries);
    println!("{value}");
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("{error:#}");
        std::process::exit(1);
    }
}
