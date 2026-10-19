//! Dependency-free oracle for the pinned Document::resolve API. Test use only.
use std::{env, fs};
use wac_parser::Document;

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let path = env::args().nth(1).ok_or("expected WAC source file")?;
    if path == "--version" {
        println!("wac-parser 0.12.0 5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9");
        return Ok(());
    }
    let source = fs::read_to_string(path)?;
    let document = Document::parse(&source)?;
    let resolution = document.resolve(Default::default())?;
    println!("{:?}", resolution.graph());
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("{error:#}");
        std::process::exit(1);
    }
}
