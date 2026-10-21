//! Independent complete core contract projection using pinned wasmparser.
//! Test use only. Never linked into the product or used to validate at runtime.
use serde_json::{Value, json};
use std::{env, fs};
use wasmparser::{
    AbstractHeapType as A, CompositeInnerType as C, ExternalKind, FieldType, HeapType, Parser,
    Payload, RefType, StorageType, SubType, TypeRef, UnpackedIndex, ValType, Validator,
    WasmFeatures,
};
type Error = Box<dyn std::error::Error>;
type Result<T> = std::result::Result<T, Error>;

struct Node {
    ty: SubType,
    start: usize,
    size: usize,
}

fn abstract_heap(ty: A) -> (i32, &'static str) {
    match ty {
        A::Func => (-16, "func"),
        A::Extern => (-17, "extern"),
        A::Any => (-18, "any"),
        A::Eq => (-19, "eq"),
        A::I31 => (-20, "i31"),
        A::Struct => (-21, "struct"),
        A::Array => (-22, "array"),
        A::Exn => (-23, "exn"),
        A::None => (-15, "none"),
        A::NoExtern => (-14, "noextern"),
        A::NoFunc => (-13, "nofunc"),
        A::NoExn => (-12, "noexn"),
        A::Cont => (-24, "cont"),
        A::NoCont => (-11, "nocont"),
    }
}
fn module_index(index: UnpackedIndex) -> Result<usize> {
    index
        .as_module_index()
        .map(|i| i as usize)
        .ok_or_else(|| "expected lexical module type index".into())
}
fn heap(reference: RefType, nodes: &[Node]) -> Result<(i32, bool)> {
    match reference.heap_type() {
        HeapType::Abstract { shared, ty } => Ok((abstract_heap(ty).0, shared)),
        HeapType::Concrete(index) => {
            let index = module_index(index)?;
            Ok((
                index as i32,
                nodes
                    .get(index)
                    .ok_or("unknown concrete type")?
                    .ty
                    .composite_type
                    .shared,
            ))
        }
        HeapType::Exact(_) => Err("custom descriptors excluded".into()),
    }
}
fn graph_value(ty: ValType, nodes: &[Node]) -> Result<Value> {
    Ok(match ty {
        ValType::Ref(reference) => {
            let (h, shared) = heap(reference, nodes)?;
            json!({"kind":"reference","nullable":reference.is_nullable(),"shared":shared,"heap":h})
        }
        other => json!({"kind":"scalar","name":other.to_string()}),
    })
}
fn graph_field(field: FieldType, nodes: &[Node]) -> Result<Value> {
    let storage = match field.element_type {
        StorageType::I8 => json!({"kind":"packed","name":"i8"}),
        StorageType::I16 => json!({"kind":"packed","name":"i16"}),
        StorageType::Val(ty) => graph_value(ty, nodes)?,
    };
    Ok(json!({"mutable":field.mutable,"storage":storage}))
}
fn graph(nodes: &[Node]) -> Result<Vec<Value>> {
    nodes.iter().map(|node| {
        let composite=match &node.ty.composite_type.inner {
            C::Func(f)=>json!({"kind":"func",
                "params":f.params().iter().map(|t|graph_value(*t,nodes)).collect::<Result<Vec<_>>>()?,
                "results":f.results().iter().map(|t|graph_value(*t,nodes)).collect::<Result<Vec<_>>>()?}),
            C::Struct(s)=>json!({"kind":"struct","fields":s.fields.iter().map(|f|graph_field(*f,nodes)).collect::<Result<Vec<_>>>()?}),
            C::Array(a)=>json!({"kind":"array","field":graph_field(a.0,nodes)?}),
            C::Cont(_)=>return Err("stack switching excluded".into()),
        };
        let parent=node.ty.supertype_idxs.first().map(|i|module_index(i.unpack())).transpose()?;
        Ok(json!({"final":node.ty.is_final,"shared":node.ty.composite_type.shared,
            "supertype":parent,"group-start":node.start,"group-size":node.size,"composite":composite}))
    }).collect()
}
fn identity(index: usize, nodes: &[Node]) -> Result<Value> {
    Ok(json!({"index":index,"types":graph(nodes)?}))
}
fn contract_value(ty: ValType, nodes: &[Node]) -> Result<Value> {
    Ok(match ty {
        ValType::Ref(r) => match r.heap_type() {
            HeapType::Concrete(i) => {
                json!({"kind":"concrete-reference","nullable":r.is_nullable(),"identity":identity(module_index(i)?,nodes)?})
            }
            HeapType::Abstract { ty, shared } => {
                let mut v = json!({"kind":"reference","nullable":r.is_nullable(),"heap":abstract_heap(ty).1});
                if shared {
                    v["shared"] = json!(true);
                }
                v
            }
            HeapType::Exact(_) => return Err("custom descriptors excluded".into()),
        },
        other => json!({"kind":"scalar","name":other.to_string()}),
    })
}
fn function(index: u32, tag: bool, nodes: &[Node]) -> Result<Value> {
    let index = index as usize;
    let node = nodes.get(index).ok_or("unknown function type")?;
    let C::Func(f) = &node.ty.composite_type.inner else {
        return Err("not a function type".into());
    };
    let kind = if tag { "tag" } else { "func" };
    let typed = node.ty.composite_type.shared
        || !node.ty.is_final
        || !node.ty.supertype_idxs.is_empty()
        || node.size != 1
        || f.params()
            .iter()
            .chain(f.results())
            .any(|t| matches!(t,ValType::Ref(r) if matches!(r.heap_type(),HeapType::Concrete(_))));
    Ok(if typed {
        json!({"kind":kind,"identity":identity(index,nodes)?})
    } else {
        json!({"kind":kind,"signature":{
            "params":f.params().iter().map(|t|contract_value(*t,nodes)).collect::<Result<Vec<_>>>()?,
            "results":f.results().iter().map(|t|contract_value(*t,nodes)).collect::<Result<Vec<_>>>()?
        }})
    })
}
fn external(ty: TypeRef, nodes: &[Node]) -> Result<Value> {
    Ok(match ty {
        TypeRef::Func(i) => function(i, false, nodes)?,
        TypeRef::Tag(t) => function(t.func_type_idx, true, nodes)?,
        TypeRef::Global(g) => {
            json!({"kind":"global","value":contract_value(g.content_type,nodes)?,"mutable":g.mutable,"shared":g.shared})
        }
        TypeRef::Table(t) => {
            json!({"kind":"table","value":contract_value(ValType::Ref(t.element_type),nodes)?,
            "min":t.initial.to_string(),"max":t.maximum.map(|m|m.to_string()),"index64":t.table64,"shared":t.shared})
        }
        TypeRef::Memory(m) => {
            json!({"kind":"memory","min":m.initial.to_string(),"max":m.maximum.map(|m|m.to_string()),
            "index64":m.memory64,"shared":m.shared,"page-size-log2":m.page_size_log2})
        }
        TypeRef::FuncExact(_) => return Err("custom descriptors excluded".into()),
    })
}
fn run() -> Result<()> {
    let args = env::args().skip(1).collect::<Vec<_>>();
    if args == ["--version"] {
        println!("wasmparser 0.262.0 e22db44da4eaf17a0e46ec55b911c7539589a3cc");
        return Ok(());
    }
    if args.len() != 1 {
        return Err("usage: wasm-core-reference CORE_WASM".into());
    }
    let bytes = fs::read(&args[0])?;
    let features = WasmFeatures::all() & !WasmFeatures::CUSTOM_DESCRIPTORS;
    Validator::new_with_features(features).validate_all(&bytes)?;
    let mut nodes = Vec::new();
    let mut imports = Vec::new();
    let mut exports = Vec::new();
    let mut funcs = Vec::new();
    let mut tables = Vec::new();
    let mut memories = Vec::new();
    let mut globals = Vec::new();
    let mut tags = Vec::new();
    for payload in Parser::new(0).parse_all(&bytes) {
        match payload? {
            Payload::Version { encoding, .. } if encoding != wasmparser::Encoding::Module => {
                return Err("expected a core module".into());
            }
            Payload::TypeSection(section) => {
                for group in section {
                    let group = group?;
                    let start = nodes.len();
                    let size = group.types().len();
                    for ty in group.into_types() {
                        nodes.push(Node { ty, start, size });
                    }
                }
            }
            Payload::ImportSection(section) => {
                for item in section.into_imports() {
                    let i = item?;
                    match i.ty {
                        TypeRef::Func(t) => funcs.push(t),
                        TypeRef::Table(t) => tables.push(t),
                        TypeRef::Memory(t) => memories.push(t),
                        TypeRef::Global(t) => globals.push(t),
                        TypeRef::Tag(t) => tags.push(t),
                        TypeRef::FuncExact(_) => return Err("custom descriptors excluded".into()),
                    };
                    imports.push((i.module.to_owned(), i.name.to_owned(), i.ty));
                }
            }
            Payload::FunctionSection(s) => {
                for i in s {
                    funcs.push(i?);
                }
            }
            Payload::TableSection(s) => {
                for i in s {
                    tables.push(i?.ty);
                }
            }
            Payload::MemorySection(s) => {
                for i in s {
                    memories.push(i?);
                }
            }
            Payload::GlobalSection(s) => {
                for i in s {
                    globals.push(i?.ty);
                }
            }
            Payload::TagSection(s) => {
                for i in s {
                    tags.push(i?);
                }
            }
            Payload::ExportSection(s) => {
                for i in s {
                    let i = i?;
                    exports.push((i.name.to_owned(), i.kind, i.index as usize));
                }
            }
            _ => {}
        }
    }
    let imports = imports
        .into_iter()
        .map(|(module, name, ty)| {
            Ok(json!({"module":module,"name":name,"signature":external(ty,&nodes)?}))
        })
        .collect::<Result<Vec<_>>>()?;
    let exports = exports
        .into_iter()
        .map(|(name, kind, index)| {
            let ty = match kind {
                ExternalKind::Func => {
                    TypeRef::Func(*funcs.get(index).ok_or("unknown exported function")?)
                }
                ExternalKind::Table => {
                    TypeRef::Table(*tables.get(index).ok_or("unknown exported table")?)
                }
                ExternalKind::Memory => {
                    TypeRef::Memory(*memories.get(index).ok_or("unknown exported memory")?)
                }
                ExternalKind::Global => {
                    TypeRef::Global(*globals.get(index).ok_or("unknown exported global")?)
                }
                ExternalKind::Tag => TypeRef::Tag(*tags.get(index).ok_or("unknown exported tag")?),
                ExternalKind::FuncExact => return Err("custom descriptors excluded".into()),
            };
            Ok(json!({"name":name,"signature":external(ty,&nodes)?}))
        })
        .collect::<Result<Vec<_>>>()?;
    println!("{}", json!({"imports":imports,"exports":exports}));
    Ok(())
}
fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
