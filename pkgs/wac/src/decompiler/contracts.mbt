///|
fn quote(value : String) -> String {
  // JSON and WAC share string escapes for Unicode names.
  Json::string(value).stringify()
}

///|
fn wat_quote(value : String) -> String {
  let out = StringBuilder()
  let hex = "0123456789abcdef"
  out.write_char('"')
  for byte in @utf8.encode(value) {
    let c = byte.to_int()
    if c < 32 || c > 126 || c == 34 || c == 92 {
      out.write_char('\\')
      out.write_char(hex[(c >> 4) & 15].to_int().unsafe_to_char())
      out.write_char(hex[c & 15].to_int().unsafe_to_char())
    } else {
      out.write_char(c.unsafe_to_char())
    }
  }
  out.write_char('"')
  out.to_string()
}

///|
priv struct ContractScope {
  parent : Int32?
  mut instances : Int32
  names : Map[Int32, String]
  out : StringBuilder
}

///|
priv enum ContractTask {
  Ensure(Int32, Int32)
  Define(Int32, Int32)
  Extern(Int32, @verifier.Extern, Bool, String)
  EmitExtern(Int32, @verifier.Extern, Bool, String)
  Finish(Int32, Int32, Int32, Bool)
}

///|
fn item_id(kind : @verifier.ItemKind) -> Int32 {
  match kind {
    Type(id)
    | Function(id)
    | Instance(id)
    | Component(id)
    | Module(id)
    | Value(id) => id
  }
}

///|
fn type_children(kind : @verifier.TypeKind) -> Array[Int32] {
  match kind {
    Alias(id)
    | Own(id)
    | Borrow(id)
    | List(id)
    | FixedList(id, _)
    | Option(id) => [id]
    Resource(Some(id)) => [id]
    Map(a, b) => [a, b]
    Tuple(ids) => ids.iter().to_array()
    Result(a, b) => a.iter().to_array() + b.iter().to_array()
    Future(id) | Stream(id) => id.iter().to_array()
    Record(fields) => fields.map(f => f.ty).iter().to_array()
    Variant(cases) => cases.iter().filter_map(c => c.payload).to_array()
    Function(params, result, _) =>
      params.map(p => p.ty).iter().to_array() + result.iter().to_array()
    _ => []
  }
}

///|
fn core_value(value : @core_types.Value) -> String {
  match value {
    Scalar(value) => value
    Reference(nullable, heap) =>
      "(ref " + (if nullable { "null " } else { "" }) + heap + ")"
  }
}

///|
fn core_function(function : @core_types.Function) -> String {
  let out = StringBuilder()
  out.write_string("(func")
  for value in function.params {
    out.write_string(" (param " + core_value(value) + ")")
  }
  for value in function.results {
    out.write_string(" (result " + core_value(value) + ")")
  }
  out.write_char(')')
  out.to_string()
}

///|
fn core_external(
  kind : @core_types.External,
  tags : Map[String, String],
) -> String {
  match kind {
    Func(function) => core_function(function)
    Global(value, mutable_, shared) =>
      "(global " +
      (if shared { "shared " } else { "" }) +
      (if mutable_ {
        "(mut " + core_value(value) + ")"
      } else {
        core_value(value)
      }) +
      ")"
    Table(value, min, max, index64, shared) =>
      "(table " +
      (if index64 { "i64 " } else { "" }) +
      min.to_string() +
      max.map(m => " " + m.to_string()).unwrap_or("") +
      (if shared { " shared" } else { "" }) +
      " " +
      core_value(value) +
      ")"
    Memory(min, max, index64, shared, page) =>
      "(memory " +
      (if index64 { "i64 " } else { "" }) +
      min.to_string() +
      max.map(m => " " + m.to_string()).unwrap_or("") +
      (if shared { " shared" } else { "" }) +
      page.map(p => " (pagesize " + (1 << p).to_string() + ")").unwrap_or("") +
      ")"
    Tag(function) => "(tag (type " + tags[core_function(function)] + "))"
  }
}

///|
fn module_type(module_ : @core_types.Module) -> String {
  let out = StringBuilder()
  out.write_string("(module\n")
  let tags : Map[String, String] = Map([])
  let externals = module_.imports.map(i => i.kind).iter().to_array() +
    module_.exports.map(e => e.kind).iter().to_array()
  for external in externals {
    if external is Tag(function) {
      let signature = core_function(function)
      if !tags.contains(signature) {
        let name = "$tag-type-n" + tags.length().to_string()
        tags[signature] = name
        out.write_string("(type " + name + " " + signature + ")\n")
      }
    }
  }
  for item in module_.imports {
    out.write_string(
      "(import " +
      wat_quote(item.module_name) +
      " " +
      wat_quote(item.name) +
      " " +
      core_external(item.kind, tags) +
      ")\n",
    )
  }
  for item in module_.exports {
    out.write_string(
      "(export " +
      wat_quote(item.name) +
      " " +
      core_external(item.kind, tags) +
      ")\n",
    )
  }
  out.write_char(')')
  out.to_string()
}

///|
// Build a type carrier for WAC package-path imports. It contains signatures,
// imports and re-exports only, never any executable module or component body.
// Explicit tasks handle nested interface/world types and their lexical aliases.
fn render_contract(
  types : ReadOnlyArray[@verifier.ResolvedType],
  imports : ReadOnlyArray[@verifier.Extern],
  export_names : ReadOnlyArray[String],
  carrier : Bool,
  definitions~ : ReadOnlyArray[@verifier.Extern] = [],
  named~ : String? = None,
  prelude~ : Bool = false,
  preserve_names~ : Bool = false,
  ensure~ : ReadOnlyArray[Int32] = [],
  out_names~ : Map[Int32, String]? = None,
) -> String raise Failure {
  let scopes : Array[ContractScope] = [
    { instances: 0, parent: None, names: Map([]), out: StringBuilder(), },
    { instances: 0, parent: None, names: Map([]), out: StringBuilder(), },
  ]
  let tasks : Array[ContractTask] = []
  for i = ensure.length() - 1; i >= 0; i = i - 1 {
    tasks.push(Ensure(0, ensure[i]))
  }
  for i = definitions.length() - 1; i >= 0; i = i - 1 {
    tasks.push(Extern(0, definitions[i], false, "$d\{i}"))
  }
  for i = imports.length() - 1; i >= 0; i = i - 1 {
    tasks.push(
      Extern(
        if carrier {
          1
        } else {
          0
        },
        {
          ..imports[i],
          name: if preserve_names {
            imports[i].name
          } else {
            named.unwrap_or("i\{i}")
          },
        },
        !carrier,
        "$i\{i}",
      ),
    )
  }
  let renamed : Map[String, String] = Map([])
  for i, name in export_names {
    renamed["i\{i}"] = name
  }
  let mut remaining = 1000000
  while tasks.pop() is Some(task) {
    remaining -= 1
    if remaining < 0 {
      reject("signature rendering exceeds its work limit")
    }
    match task {
      Ensure(scope_id, id) => {
        let scope = scopes[scope_id]
        if scope.names.contains(id) {
          continue
        }
        let mut parent = scope.parent
        let mut depth = 1
        let mut outer : String? = None
        while parent is Some(p) {
          if scopes[p].names.get(id) is Some(name) {
            outer = Some(name)
            break
          }
          parent = scopes[p].parent
          depth += 1
        }
        if outer is Some(name) {
          scope.out.write_string(
            "(alias outer \{depth} \{name} (type $t\{id}))\n",
          )
          scope.names[id] = "$t\{id}"
          continue
        }
        match types[id].kind {
          Interface(_, _, exports) | World(_, _, _, exports) => {
            let child = scopes.length()
            scopes.push({
              instances: 0,
              parent: Some(scope_id),
              names: Map([]),
              out: StringBuilder(),
            })
            let world = types[id].kind is World(_)
            tasks.push(Finish(scope_id, id, child, world))
            for i = exports.length() - 1; i >= 0; i = i - 1 {
              tasks.push(Extern(child, exports[i], false, "$e\{i}"))
            }
            if types[id].kind is World(_, _, imports, _) {
              for i = imports.length() - 1; i >= 0; i = i - 1 {
                tasks.push(Extern(child, imports[i], true, "$i\{i}"))
              }
            }
          }
          _ => {
            tasks.push(Define(scope_id, id))
            let children = type_children(types[id].kind)
            for i = children.length() - 1; i >= 0; i = i - 1 {
              tasks.push(Ensure(scope_id, children[i]))
            }
          }
        }
      }
      Finish(parent, id, child, world) => {
        let scope = scopes[parent]
        scope.out.write_string(
          "(type $t\{id} (" +
          (if world { "component" } else { "instance" }) +
          "\n" +
          scopes[child].out.to_string() +
          "))\n",
        )
        scope.names[id] = "$t\{id}"
      }
      Define(scope_id, id) => {
        let scope = scopes[scope_id]
        if scope.names.contains(id) {
          continue
        }
        let name = fn(id : Int32) { scope.names[id] }
        let optional = fn(id : Int32?, label : String) {
          id.map(id => " (" + label + " " + name(id) + ")").unwrap_or("")
        }
        let body = match types[id].kind {
          Scalar(value) => value
          Alias(id) => scope.names[id]
          Resource(Some(id)) => scope.names[id]
          Resource(None) => "(resource (rep i32))"
          Own(id) => "(own " + name(id) + ")"
          Borrow(id) => "(borrow " + name(id) + ")"
          List(id) => "(list " + name(id) + ")"
          FixedList(id, size) =>
            "(list " + name(id) + " " + size.to_string() + ")"
          Map(a, b) => "(map " + name(a) + " " + name(b) + ")"
          Tuple(ids) =>
            "(tuple " +
            ids.map(id => name(id)).iter().to_array().join(" ") +
            ")"
          Option(id) => "(option " + name(id) + ")"
          Result(a, b) =>
            "(result" +
            a.map(id => " " + name(id)).unwrap_or("") +
            optional(b, "error") +
            ")"
          Future(id) =>
            "(future" + id.map(id => " " + name(id)).unwrap_or("") + ")"
          Stream(id) =>
            "(stream" + id.map(id => " " + name(id)).unwrap_or("") + ")"
          Record(fields) =>
            "(record " +
            fields
            .map(f => "(field " + wat_quote(f.name) + " " + name(f.ty) + ")")
            .iter()
            .to_array()
            .join(" ") +
            ")"
          Flags(names) =>
            "(flags " + names.map(wat_quote).iter().to_array().join(" ") + ")"
          Enum(names) =>
            "(enum " + names.map(wat_quote).iter().to_array().join(" ") + ")"
          Variant(cases) =>
            "(variant " +
            cases
            .map(c => {
              "(case " +
              wat_quote(c.name) +
              c.payload.map(id => " " + name(id)).unwrap_or("") +
              ")"
            })
            .iter()
            .to_array()
            .join(" ") +
            ")"
          Function(params, result, async_) =>
            "(func" +
            (if async_ { " async" } else { "" }) +
            params
            .map(p => " (param " + wat_quote(p.name) + " " + name(p.ty) + ")")
            .iter()
            .to_array()
            .join("") +
            optional(result, "result") +
            ")"
          Module(module_) => module_type(module_)
          _ => reject("compound signature was not scheduled")
        }
        match types[id].kind {
          Alias(next) | Resource(Some(next)) =>
            scope.names[id] = scope.names[next]
          Module(_) => {
            scope.out.write_string("(core type $t\{id} " + body + ")\n")
            scope.names[id] = "$t\{id}"
          }
          _ => {
            scope.out.write_string("(type $t\{id} " + body + ")\n")
            scope.names[id] = "$t\{id}"
          }
        }
      }
      Extern(scope_id, item, importing, binding) => {
        let id = item_id(item.kind)
        if (scope_id != 0 || importing) &&
          item.kind is Type(_) &&
          types[id].kind is Resource(None) {
          let scope = scopes[scope_id]
          let mut parent = scope.parent
          let mut inherited = false
          while parent is Some(p) {
            if scopes[p].names.contains(id) {
              inherited = true
              break
            }
            parent = scopes[p].parent
          }
          if !scope.names.contains(id) && !inherited {
            scope.out.write_string(
              "(" +
              (if importing { "import" } else { "export" }) +
              " " +
              wat_quote(item.name) +
              " (type $t\{id} (sub resource)))\n",
            )
            scope.names[id] = "$t\{id}"
            if scope_id == 0 && !prelude {
              scope.out.write_string(
                "(export " +
                wat_quote(renamed.get(item.name).unwrap_or(item.name)) +
                " (type $t\{id}))\n",
              )
            }
            continue
          }
        }
        tasks.push(EmitExtern(scope_id, item, importing, binding))
        tasks.push(Ensure(scope_id, id))
      }
      EmitExtern(scope_id, item, importing, binding) => {
        let scope = scopes[scope_id]
        let id = item_id(item.kind)
        let name = scope.names[id]
        let (kind, desc) = match item.kind {
          Type(_) => ("type", "(eq " + name + ")")
          Function(_) => ("func", "(type " + name + ")")
          Instance(_) => ("instance", "(type " + name + ")")
          Component(_) => ("component", "(type " + name + ")")
          Module(_) => ("core module", "(type " + name + ")")
          Value(_) => ("value", name)
        }
        if scope_id == 0 && !importing {
          scope.out.write_string(
            "(export " +
            wat_quote(item.name) +
            " (" +
            kind +
            " " +
            name +
            "))\n",
          )
          continue
        }
        scope.out.write_string(
          "(" +
          (if importing { "import" } else { "export" }) +
          " " +
          wat_quote(item.name) +
          " (" +
          kind +
          " " +
          (if importing { binding + " " } else { "" }) +
          desc +
          "))\n",
        )
        if scope_id == 0 && !prelude {
          scope.out.write_string(
            "(export " +
            wat_quote(renamed.get(item.name).unwrap_or(item.name)) +
            " (" +
            kind +
            " " +
            binding +
            "))\n",
          )
        }
        // Make the imported instance's named types available to later imports,
        // preserving shared resources instead of copying their declarations.
        if item.kind is Instance(_) &&
          types[id].kind is Interface(_, _, exports) {
          for exported in exports {
            if exported.kind is Type(id) {
              scope.out.write_string(
                "(alias export " +
                (if importing { binding } else { scope.instances.to_string() }) +
                " " +
                wat_quote(exported.name) +
                " (type $a\{id}))\n",
              )
              scope.names[id] = "$a\{id}"
            }
          }
        }
        if item.kind is Instance(_) {
          scope.instances += 1
        }
      }
    }
  }
  if out_names is Some(names) {
    for id, name in scopes[0].names {
      names[id] = name
    }
  }
  if prelude {
    return scopes[0].out.to_string()
  }
  if !carrier {
    return "(component\n" + scopes[0].out.to_string() + ")\n"
  }
  if named is Some(_) {
    return "(component\n(type (component\n" +
      scopes[1].out.to_string() +
      "))\n(export \"interface\" (type 0)))\n"
  }
  "(component\n(type (component\n(type (component\n" +
  scopes[1].out.to_string() +
  "))\n(export \"split:contracts/imports\" (component (type 0)))))\n(export \"imports\" (type 0)))\n"
}

///|
fn import_contract(
  types : ReadOnlyArray[@verifier.ResolvedType],
  imports : ReadOnlyArray[@verifier.Extern],
) -> String raise Failure {
  render_contract(types, imports, [], true)
}

///|
fn forwarding_component(
  types : ReadOnlyArray[@verifier.ResolvedType],
  imports : ReadOnlyArray[@verifier.Extern],
  export_names : ReadOnlyArray[String],
) -> String raise Failure {
  render_contract(types, imports, export_names, false)
}

///|
fn definition_component(
  types : ReadOnlyArray[@verifier.ResolvedType],
  captured : ReadOnlyArray[@verifier.Extern],
  id : Int32,
) -> String raise Failure {
  render_contract(types, captured, [], false, definitions=[
    {
      name: "value",
      kind: @verifier.Type(id),
      location: @verifier.Location::binary("<signature>"),
    },
  ])
}

///|
fn named_instance_contract(
  types : ReadOnlyArray[@verifier.ResolvedType],
  item : @verifier.Extern,
  identity : String,
) -> String raise Failure {
  render_contract(types, [item], [], true, named=Some(identity))
}
