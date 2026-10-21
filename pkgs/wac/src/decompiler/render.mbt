///|
fn ints(ids : ReadOnlyArray[Int32]) -> Json {
  Json::array(ids.map(id => Json::number(id.to_double())).iter().to_array())
}

///|
fn strings(names : ReadOnlyArray[String]) -> Json {
  Json::array(names.map(Json::string).iter().to_array())
}

///|
fn optional_int(id : Int32?) -> Json {
  id.map(id => Json::number(id.to_double())).unwrap_or(Json::null())
}

///|
fn extern_json(item : @verifier.Extern) -> Json {
  let tag = match item.kind {
    Type(_) => "type"
    Function(_) => "func"
    Instance(_) => "instance"
    Component(_) => "component"
    Module(_) => "core-module"
    Value(_) => "value"
  }
  {
    "name": Json::string(item.name),
    "kind": Json::string(tag),
    "type": Json::number(item_id(item.kind).to_double()),
  }
}

///|
fn externs_json(items : ReadOnlyArray[@verifier.Extern]) -> Json {
  Json::array(items.map(extern_json).iter().to_array())
}

///|
fn core_value_json(value : @core_types.Value) -> Json {
  match value {
    Scalar(name) => { "kind": "scalar", "name": Json::string(name) }
    Concrete(nullable, identity) =>
      {
        "kind": "concrete-reference",
        "nullable": Json::boolean(nullable),
        "identity": core_identity_json(identity),
      }
    SharedReference(nullable, heap) =>
      {
        "kind": "reference",
        "nullable": Json::boolean(nullable),
        "shared": Json::boolean(true),
        "heap": Json::string(heap),
      }
    Reference(nullable, heap) =>
      {
        "kind": "reference",
        "nullable": Json::boolean(nullable),
        "heap": Json::string(heap),
      }
  }
}

///|
fn core_function_json(function : @core_types.Function) -> Json {
  {
    "params": Json::array(
      function.params.map(core_value_json).iter().to_array(),
    ),
    "results": Json::array(
      function.results.map(core_value_json).iter().to_array(),
    ),
  }
}

///|
fn core_external_json(kind : @core_types.External) -> Json {
  match kind {
    TypedFunc(identity) =>
      { "kind": "func", "identity": core_identity_json(identity) }
    TypedTag(identity) =>
      { "kind": "tag", "identity": core_identity_json(identity) }
    Func(function) =>
      { "kind": "func", "signature": core_function_json(function) }
    Global(value, mutable_, shared) =>
      {
        "kind": "global",
        "value": core_value_json(value),
        "mutable": Json::boolean(mutable_),
        "shared": Json::boolean(shared),
      }
    Table(value, min, max, index64, shared) =>
      {
        "kind": "table",
        "value": core_value_json(value),
        "min": Json::string(min.to_string()),
        "max": max.map(m => Json::string(m.to_string())).unwrap_or(Json::null()),
        "index64": Json::boolean(index64),
        "shared": Json::boolean(shared),
      }
    Memory(min, max, index64, shared, page) =>
      {
        "kind": "memory",
        "min": Json::string(min.to_string()),
        "max": max.map(m => Json::string(m.to_string())).unwrap_or(Json::null()),
        "index64": Json::boolean(index64),
        "shared": Json::boolean(shared),
        "page-size-log2": optional_int(page),
      }
    Tag(function) =>
      { "kind": "tag", "signature": core_function_json(function) }
  }
}

///|
fn core_json(core : @core_types.Module) -> Json {
  {
    "imports": Json::array(
      core.imports
      .map(i => {
        Json::object({
          "module": Json::string(i.module_name),
          "name": Json::string(i.name),
          "signature": core_external_json(i.kind),
        })
      })
      .iter()
      .to_array(),
    ),
    "exports": Json::array(
      core.exports
      .map(e => {
        Json::object({
          "name": Json::string(e.name),
          "signature": core_external_json(e.kind),
        })
      })
      .iter()
      .to_array(),
    ),
  }
}

///|
fn type_json(type_ : @verifier.ResolvedType) -> Json {
  let shape : Json = match type_.kind {
    Scalar(name) => { "kind": "scalar", "name": Json::string(name) }
    Module(core) => { "kind": "core-module", "contract": core_json(core) }
    Alias(id) => { "kind": "alias", "target": optional_int(Some(id)) }
    Resource(id) => { "kind": "resource", "target": optional_int(id) }
    Own(id) => { "kind": "own", "target": optional_int(Some(id)) }
    Borrow(id) => { "kind": "borrow", "target": optional_int(Some(id)) }
    List(id) => { "kind": "list", "element": optional_int(Some(id)) }
    FixedList(id, size) =>
      {
        "kind": "fixed-list",
        "element": optional_int(Some(id)),
        "length": optional_int(Some(size)),
      }
    Map(key, value) =>
      {
        "kind": "map",
        "key": optional_int(Some(key)),
        "value": optional_int(Some(value)),
      }
    Tuple(ids) => { "kind": "tuple", "elements": ints(ids) }
    Option(id) => { "kind": "option", "value": optional_int(Some(id)) }
    Result(ok, error) =>
      { "kind": "result", "ok": optional_int(ok), "error": optional_int(error) }
    Future(id) => { "kind": "future", "value": optional_int(id) }
    Stream(id) => { "kind": "stream", "value": optional_int(id) }
    Record(fields) =>
      {
        "kind": "record",
        "fields": Json::array(
          fields
          .map(f => {
            Json::object({
              "name": Json::string(f.name),
              "type": optional_int(Some(f.ty)),
            })
          })
          .iter()
          .to_array(),
        ),
      }
    Flags(names) => { "kind": "flags", "names": strings(names) }
    Enum(names) => { "kind": "enum", "names": strings(names) }
    Variant(cases) =>
      {
        "kind": "variant",
        "cases": Json::array(
          cases
          .map(c => {
            Json::object({
              "name": Json::string(c.name),
              "payload": optional_int(c.payload),
            })
          })
          .iter()
          .to_array(),
        ),
      }
    Function(params, result, async_) =>
      {
        "kind": "func",
        "params": Json::array(
          params
          .map(p => {
            Json::object({
              "name": Json::string(p.name),
              "type": optional_int(Some(p.ty)),
            })
          })
          .iter()
          .to_array(),
        ),
        "result": optional_int(result),
        "async": Json::boolean(async_),
      }
    Interface(identity, uses, exports) =>
      {
        "kind": "instance",
        "identity": identity.map(Json::string).unwrap_or(Json::null()),
        "uses": Json::array(
          uses
          .map(u => {
            Json::object({
              "name": Json::string(u.name),
              "original-name": Json::string(u.original_name),
              "interface": optional_int(Some(u.interface)),
              "type": optional_int(Some(u.ty)),
            })
          })
          .iter()
          .to_array(),
        ),
        "exports": externs_json(exports),
      }
    World(identity, uses, imports, exports) =>
      {
        "kind": "component",
        "identity": identity.map(Json::string).unwrap_or(Json::null()),
        "uses": Json::array(
          uses
          .map(u => {
            Json::object({
              "name": Json::string(u.name),
              "original-name": Json::string(u.original_name),
              "interface": optional_int(Some(u.interface)),
              "type": optional_int(Some(u.ty)),
            })
          })
          .iter()
          .to_array(),
        ),
        "imports": externs_json(imports),
        "exports": externs_json(exports),
      }
  }
  {
    "id": optional_int(Some(type_.id)),
    "name": type_.name.map(Json::string).unwrap_or(Json::null()),
    "shape": shape,
  }
}

///|
/// A versioned JSON representation with complete signatures and flat graph
/// references. UInt64 core limits are decimal strings to avoid JSON rounding.
pub fn Inventory::to_json(self : Inventory) -> Json {
  {
    "schema-version": 1,
    "entries": Json::array(
      self.entries
      .map(e => {
        Json::object({
          "id": Json::string(e.id),
          "parent": e.parent.map(Json::string).unwrap_or(Json::null()),
          "kind": Json::string(
            match e.kind {
              Component => "component"
              CoreModule => "core-module"
            },
          ),
          "name": e.name.map(Json::string).unwrap_or(Json::null()),
          "export-names": strings(e.export_names),
          "world": optional_int(e.world),
          "core": e.core.map(core_json).unwrap_or(Json::null()),
        })
      })
      .iter()
      .to_array(),
    ),
    "types": Json::array(self.types.map(type_json).iter().to_array()),
  }
}

///|
/// Human-readable inventory followed by the complete flat signature table.
pub fn Inventory::to_text(self : Inventory) -> String {
  let out = StringBuilder()
  for entry in self.entries {
    out.write_string(
      entry.id +
      " " +
      (match entry.kind {
        Component => "component"
        CoreModule => "core-module"
      }),
    )
    if entry.name is Some(name) {
      out.write_string(" name=" + quote(name))
    }
    if !entry.export_names.is_empty() {
      out.write_string(" exports=" + strings(entry.export_names).stringify())
    }
    if entry.world is Some(id) {
      out.write_string(" type=" + id.to_string())
    }
    if entry.core is Some(core) {
      out.write_string(" " + core_json(core).stringify())
    }
    out.write_char('\n')
  }
  for type_ in self.types {
    out.write_string(type_json(type_).stringify() + "\n")
  }
  out.to_string()
}
