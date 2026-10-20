///|
pub(all) enum DocumentKind {
  Wat
  Wac
} derive(Eq, Debug)

///|
/// A complete document at a portable, relative path. Package names are valid
/// WAC keys. The library never writes these paths to the filesystem.
pub struct Document {
  id : String
  path : String
  package_name : String
  kind : DocumentKind
  text : String
  priv bodies : ReadOnlyArray[String]
}

///|
pub struct Split {
  inventory : Inventory
  documents : ReadOnlyArray[Document]
}

///|
fn package_key(id : String) -> String {
  if id == "root" {
    return "split:root"
  }
  let parts = id.split("/").to_array()
  let label = slug(parts[parts.length() - 1].to_owned())
  let short = if label.length() > 40 { label[:40].to_owned() } else { label }
  "split:p" +
  short +
  "-h" +
  @crypto.bytes_to_hex_string(@crypto.sha256(@utf8.encode(id)))
}

///|
fn document_path(id : String, kind : DocumentKind) -> String {
  let ext = match kind {
    Wat => ".wat"
    Wac => ".wac"
  }
  if id == "root" {
    "root" + ext
  } else {
    "deps/split/" + package_key(id)[6:].to_owned() + ext
  }
}

///|
fn lookup(
  refs : Map[(Int32, Int32), String],
  kind : Int32,
  index : Int32,
) -> String raise Failure {
  match refs.get((kind, index)) {
    Some(value) => value
    None => reject("composition reference \{kind}:\{index} has no binding")
  }
}

///|
fn component_imports(
  types : ReadOnlyArray[@verifier.ResolvedType],
  scope : @verifier.ComponentScope,
) -> ReadOnlyArray[@verifier.Extern] raise Failure {
  match types[scope.world].kind {
    World(_, _, imports, _) => imports
    _ => reject("component contract is not a world")
  }
}

///|
fn compile(text : String) -> Bytes raise Failure {
  @component_text.parse_normalized_component_wat(text) catch {
    error => raise Failure("WAC-D004", error.to_string())
  }
}

///|
fn wat_document(id : String, bytes : Bytes) -> Document raise Failure {
  let printed = match @wat.print_binary(bytes) {
    Ok(printed) => printed
    Err(errors) => raise Failure("WAC-D004", errors[0].message)
  }
  {
    id,
    path: document_path(id, Wat),
    package_name: package_key(id),
    bodies: [],
    kind: Wat,
    text: printed.root().text,
  }
}

///|
priv struct Lifted {
  text : String
  helpers : Array[Document]
}

///|
fn lift(
  snapshot : Snapshot,
  inspection : Inspection,
  closures : Map[String, Closure],
) -> Lifted raise Failure {
  let scope = snapshot.scope.unwrap()
  let types = inspection.inventory.types
  let original_imports = component_imports(types, scope)
  // Preserve encoded type metadata, including name attributes, without
  // reconstructing type-only packages through a less detailed semantic graph.
  if original_imports.is_empty() &&
    closures[snapshot.entry.id].captures.is_empty() &&
    snapshot.parsed.unwrap().sections.all(s => {
      s.id == 0 || s.id == 7 || s.id == 11
    }) &&
    types[scope.world].kind is World(_, _, _, exports) &&
    exports.all(e => e.kind is Type(_)) &&
    !exports.is_empty() {
    let helper_id = snapshot.entry.id + "/types"
    let helper = wat_document(helper_id, snapshot.bytes)
    let out = StringBuilder()
    out.write_string(
      "package " +
      package_key(snapshot.entry.id) +
      ";\nlet metadata = new " +
      helper.package_name +
      " {};\n",
    )
    for item in exports {
      out.write_string(
        "export metadata[" +
        quote(item.name) +
        "] as " +
        quote(item.name) +
        ";\n",
      )
    }
    return { text: out.to_string(), helpers: [helper], }
  }
  let captures = closures[snapshot.entry.id].captures
  let imports = ReadOnlyArray::from_array(
    captures + original_imports.iter().to_array(),
  )
  let out = StringBuilder()
  let id = snapshot.entry.id
  out.write_string("package " + package_key(id) + ";\n")
  let helpers : Array[Document] = []
  let carrier_needed : Array[Int32] = []
  let refs : Map[(Int32, Int32), String] = Map([])
  let packages : Map[Int32, Snapshot] = Map([])
  let unnamed_values : Map[(Int32, Int32), Bool] = Map([])
  let captured_values : Map[String, String] = Map([])
  let counts : Map[Int32, Int32] = Map([])
  let take = fn(kind : Int32) {
    let n = counts.get(kind).unwrap_or(0)
    counts[kind] = n + 1
    n
  }
  let children : Map[Int32, Snapshot] = Map([])
  for child in inspection.snapshots {
    if child.entry.parent == Some(id) && child.scope is Some(scope) {
      children[scope.index] = child
    }
  }
  let source_names : Map[Int32, String] = Map([])
  let materialize = fn(type_id : Int32) -> String raise Failure {
    if source_names.get(type_id) is Some(name) {
      return name
    }
    let inputs : Array[@verifier.Extern] = []
    let args : Array[String] = []
    for
      (item, value) in type_captures(
        types,
        source_names,
        id,
        roots=Some([type_id]),
      ) {
      inputs.push(item)
      args.push(quote(item.name) + ": " + value)
    }
    let helper_id = id + "/type-id-n\{type_id}"
    let text = definition_component(
      types,
      ReadOnlyArray::from_array(inputs),
      type_id,
    )
    helpers.push({
      id: helper_id,
      path: document_path(helper_id, Wat),
      package_name: package_key(helper_id),
      bodies: [],
      kind: Wat,
      text,
    })
    out.write_string(
      "let d\{type_id} = new " +
      package_key(helper_id) +
      " {" +
      args.join(", ") +
      "};\nlet t\{type_id} = d\{type_id}[\"value\"];\n",
    )
    source_names[type_id] = "t\{type_id}"
    "t\{type_id}"
  }
  let type_ref = fn(index : Int32) -> String raise Failure {
    if refs.get((3, index)) is Some(value) {
      return value
    }
    let value = materialize(scope.types[index])
    refs[(3, index)] = value
    value
  }
  let emit_import = fn(
    resolved : @verifier.ItemKind,
    name : String,
    binding : String,
    import_index : Int32,
  ) -> Unit raise Failure {
    let target = match resolved {
      Function(type_id) =>
        source_type(types, type_id, source_names, materialize)
      Instance(type_id) | Component(type_id) =>
        match types[type_id].kind {
          Interface(Some(identity), _, _) | World(Some(identity), _, _, _) if identity.contains(
              ":",
            ) => {
            let helper_id = id + "/interface-n\{import_index}"
            let text = named_instance_contract(
              types,
              {
                name,
                kind: resolved,
                location: @verifier.Location::binary(id),
              },
              identity,
            )
            helpers.push({
              id: helper_id,
              path: document_path(helper_id, Wat),
              package_name: package_key(helper_id),
              bodies: [],
              kind: Wat,
              text,
            })
            package_key(helper_id) + "/interface"
          }
          _ => package_key(id + "/imports") + "/imports/i\{import_index}"
        }
      Type(type_id) => {
        let mut current = type_id
        let mut known : String? = None
        for _ in 0..<types.length() {
          if source_names.get(current) is Some(value) {
            known = Some(value)
            break
          }
          match types[current].kind {
            Alias(next) | Resource(Some(next)) => current = next
            _ => break
          }
        }
        known.unwrap_or(
          package_key(id + "/imports") + "/imports/i\{import_index}",
        )
      }
      _ => package_key(id + "/imports") + "/imports/i\{import_index}"
    }
    if target.has_prefix(package_key(id + "/imports") + "/") {
      carrier_needed.push(import_index)
    }
    out.write_string(
      "import " + binding + " as " + quote(name) + ": " + target + ";\n",
    )
    if resolved is Instance(type_id) &&
      types[type_id].kind is Interface(_, _, exports) {
      for exported in exports {
        if exported.kind is Type(type_id) && !source_names.contains(type_id) {
          let resource = "r\{type_id}"
          out.write_string(
            "let " +
            resource +
            " = " +
            binding +
            "[" +
            quote(exported.name) +
            "];\n",
          )
          source_names[type_id] = resource
        }
      }
    }
    if resolved is Type(type_id) {
      source_names[type_id] = binding
    }
    if resolved is Component(_) || resolved is Module(_) {
      captured_values[name] = binding
    }
  }
  let component_values : Map[Int32, String] = Map([])
  let component_value = fn(index : Int32) -> String raise Failure {
    if !packages.contains(index) {
      return lookup(refs, 4, index)
    }
    let work : Array[(Int32, Bool)] = [(index, false)]
    while work.pop() is Some((index, finish)) {
      if component_values.contains(index) {
        continue
      }
      let target = packages[index]
      let closed = closures[target.entry.id]
      if !finish {
        work.push((index, true))
        for capture in closed.captures {
          if capture.kind is Component(_) &&
            !captured_values.contains(capture.name) {
            let origin = closed.origins[capture.name]
            if origin.0 != id {
              reject(
                "component capture was not forwarded through its enclosing scope",
              )
            }
            let i = origin.2
            if packages.contains(i) {
              work.push((i, false))
            } else {
              captured_values[capture.name] = lookup(refs, 4, i)
            }
          }
        }
        continue
      }
      let helper_id = id + "/value-component-n\{index}"
      let text = close_wat(closed, inspection, true)
      let bodies = inspection.inventory.entries
        .filter(e => {
          e.kind == Component &&
          (e.id == target.entry.id || e.id.has_prefix(target.entry.id + "/"))
        })
        .map(e => e.id)
      helpers.push({
        id: helper_id,
        path: document_path(helper_id, Wat),
        package_name: package_key(helper_id),
        bodies,
        kind: Wat,
        text,
      })
      let args : Array[String] = []
      for capture in closed.captures {
        let value = match capture.kind {
          Type(id) => materialize(id)
          Component(_) | Module(_) => captured_values[capture.name]
          _ => reject("invalid lexical capture")
        }
        args.push(quote(capture.name) + ": " + value)
      }
      let binding = "component\{index}"
      out.write_string(
        "let factory\{index} = new " +
        package_key(helper_id) +
        " {" +
        args.join(", ") +
        "};\nlet " +
        binding +
        " = factory\{index}[\"value\"];\n",
      )
      component_values[index] = binding
      captured_values[capture_name(id, 4, index)] = binding
    }
    component_values[index]
  }
  let reference = fn(kind : Int32, index : Int32) -> String raise Failure {
    if kind == 3 {
      type_ref(index)
    } else if kind == 4 {
      component_value(index)
    } else {
      lookup(refs, kind, index)
    }
  }
  for i, capture in captures {
    emit_import(capture.kind, capture.name, "capture\{i}", i)
  }
  let mut import_index = captures.length()
  for section in snapshot.parsed.unwrap().sections {
    match section.id {
      0 => ()
      7 => {
        let entries = @type_parser.parse_type_section(section.payload) catch {
          error => raise Failure("WAC-D001", error.to_string())
        }
        for _ in entries {
          ignore(take(3))
        }
      }
      4 => {
        let n = take(4)
        guard children.get(n) is Some(child) else {
          reject("component definition is missing from inventory")
        }
        unnamed_values[(4, n)] = true
        packages[n] = child
        refs[(4, n)] = package_key(child.entry.id)
      }
      10 => {
        let entries = @component.parse_import_section(section.payload) catch {
          error => raise Failure("WAC-D001", error.to_string())
        }
        for imported in entries {
          let kind = desc_sort(imported.desc)
          let n = take(kind)
          let binding = "i\{import_index}"
          let name = imported_name(imported.name)
          let resolved = scope_item(
            scope,
            match imported.desc {
              FuncType(_) => @component.Func
              InstanceType(_) => @component.Instance
              ComponentType(_) => @component.Component
              Type(_) => @component.Type
              CoreModuleType(_) => @component.Core(0x11)
              Value(_) => @component.Value
            },
            n,
          )
          emit_import(resolved, name, binding, import_index)
          refs[(kind, n)] = binding
          if kind == 4 || kind == 0x111 {
            captured_values[capture_name(id, kind, n)] = binding
          }
          import_index += 1
        }
      }
      5 => {
        let entries = @component.parse_instance_section(section.payload) catch {
          error => raise Failure("WAC-D001", error.to_string())
        }
        for instance in entries {
          let n = take(5)
          let binding = "n\{n}"
          unnamed_values[(5, n)] = true
          match instance.expr {
            Instantiate(component, arguments) => {
              let args : Array[String] = []
              for argument in arguments {
                args.push(
                  quote(argument.name) +
                  ": " +
                  reference(sort(argument.sortidx.sort), argument.sortidx.idx),
                )
              }
              if packages.get(component) is Some(target) {
                for capture in closures[target.entry.id].captures {
                  let value = match capture.kind {
                    Type(id) => materialize(id)
                    Component(_) => {
                      if !captured_values.contains(capture.name) {
                        let origin = closures[target.entry.id].origins[capture.name]
                        if origin.0 != id {
                          reject("component capture was not forwarded")
                        }
                        let value = component_value(origin.2)
                        captured_values[capture.name] = value
                      }
                      captured_values[capture.name]
                    }
                    Module(_) => captured_values[capture.name]
                    _ => reject("invalid capture")
                  }
                  args.push(quote(capture.name) + ": " + value)
                }
                out.write_string(
                  "let " +
                  binding +
                  " = new " +
                  package_key(target.entry.id) +
                  " {" +
                  args.join(", ") +
                  "};\n",
                )
              } else {
                let helper_id = id + "/invoke-n\{n}"
                let kinds : Array[@verifier.Extern] = []
                let supplied : Array[String] = []
                for argument in arguments {
                  kinds.push({
                    name: argument.name,
                    kind: scope_item(
                      scope,
                      argument.sortidx.sort,
                      argument.sortidx.idx,
                    ),
                    location: @verifier.Location::binary(id),
                  })
                  supplied.push(
                    quote(argument.name) +
                    ": " +
                    reference(sort(argument.sortidx.sort), argument.sortidx.idx),
                  )
                }
                let roots = [scope.components[component]] +
                  kinds.map(k => item_id(k.kind))
                let captured = type_captures(
                  types,
                  source_names,
                  id,
                  roots=Some(ReadOnlyArray::from_array(roots)),
                ).filter(c => {
                  !kinds.any(k => {
                    k.name == c.0.name &&
                    (
                      item_id(k.kind) == item_id(c.0.kind) ||
                      (
                        resource_base(types, item_id(k.kind)) is Some(root) &&
                        resource_base(types, item_id(c.0.kind)) == Some(root)
                      )
                    )
                  })
                })
                supplied.push(
                  quote(
                    invocation_target(
                      ReadOnlyArray::from_array(kinds),
                      ReadOnlyArray::from_array(captured.map(c => c.0)),
                    ),
                  ) +
                  ": " +
                  component_value(component),
                )
                for (item, value) in captured {
                  supplied.push(quote(item.name) + ": " + value)
                }
                let text = invoke_component(
                  types,
                  scope.components[component],
                  ReadOnlyArray::from_array(kinds),
                  captured=ReadOnlyArray::from_array(captured.map(c => c.0)),
                )
                helpers.push({
                  id: helper_id,
                  path: document_path(helper_id, Wat),
                  package_name: package_key(helper_id),
                  bodies: [],
                  kind: Wat,
                  text,
                })
                out.write_string(
                  "let invocation\{n} = new " +
                  package_key(helper_id) +
                  " {" +
                  supplied.join(", ") +
                  "};\nlet " +
                  binding +
                  " = invocation\{n}[\"value\"];\n",
                )
              }
            }
            InlineExports(exports) => {
              let inputs : Array[@verifier.Extern] = []
              let names : Array[String] = []
              let args : Array[String] = []
              for i, exported in exports {
                let kind = scope_item(
                  scope,
                  exported.sortidx.sort,
                  exported.sortidx.idx,
                )
                inputs.push({
                  name: "i\{i}",
                  kind,
                  location: @verifier.Location::binary(id),
                })
                names.push(exported.name)
                args.push(
                  "i\{i}: " +
                  reference(sort(exported.sortidx.sort), exported.sortidx.idx),
                )
              }
              let helper_id = id + "/inline-n\{n}"
              let captured = type_captures(
                types,
                source_names,
                id,
                roots=Some(
                  ReadOnlyArray::from_array(inputs.map(i => item_id(i.kind))),
                ),
              )
              for i, input in inputs {
                let parameter = helper_parameter(
                  input.name,
                  ReadOnlyArray::from_array(captured.map(c => c.0)),
                )
                args[i] = quote(parameter) +
                  args[i][input.name.length():].to_owned()
                inputs[i] = { ..input, name: parameter, }
              }
              for (item, value) in captured {
                args.push(quote(item.name) + ": " + value)
              }
              let text = forwarding_component(
                types,
                ReadOnlyArray::from_array(inputs),
                ReadOnlyArray::from_array(names),
                captured=ReadOnlyArray::from_array(captured.map(c => c.0)),
              )

              helpers.push({
                id: helper_id,
                path: document_path(helper_id, Wat),
                package_name: package_key(helper_id),
                bodies: [],
                kind: Wat,
                text,
              })
              out.write_string(
                "let " +
                binding +
                " = new " +
                package_key(helper_id) +
                " {" +
                args.join(", ") +
                "};\n",
              )
            }
          }
          refs[(5, n)] = binding
        }
      }
      6 => {
        let entries = @component.parse_alias_section(section.payload) catch {
          error => raise Failure("WAC-D001", error.to_string())
        }
        for entry in entries {
          let kind = sort(entry.sort)
          let n = take(kind)
          match entry.target {
            Export(instance, name) => {
              let binding = "a\{kind}n\{n}"
              if kind == 2 {
                let helper_id = id + "/value-alias-n\{n}"
                let captured = type_captures(
                  types,
                  source_names,
                  id,
                  roots=Some([scope.instances[instance]]),
                )
                let text = instance_value_component(
                  types,
                  scope.instances[instance],
                  name,
                  ReadOnlyArray::from_array(captured.map(c => c.0)),
                )
                helpers.push({
                  id: helper_id,
                  path: document_path(helper_id, Wat),
                  package_name: package_key(helper_id),
                  bodies: [],
                  kind: Wat,
                  text,
                })
                let args = captured.map(c => quote(c.0.name) + ": " + c.1)
                args.push(
                  quote(
                    helper_parameter(
                      "source",
                      ReadOnlyArray::from_array(captured.map(c => c.0)),
                    ),
                  ) +
                  ": " +
                  lookup(refs, 5, instance),
                )
                out.write_string(
                  "let valuealias\{n} = new " +
                  package_key(helper_id) +
                  " {" +
                  args.join(", ") +
                  "};\nlet " +
                  binding +
                  " = valuealias\{n}[\"value\"];\n",
                )
              } else {
                out.write_string(
                  "let " +
                  binding +
                  " = " +
                  lookup(refs, 5, instance) +
                  "[" +
                  quote(name) +
                  "];\n",
                )
              }
              refs[(kind, n)] = binding
              if kind == 4 || kind == 0x111 {
                captured_values[capture_name(id, kind, n)] = binding
              }
              if kind == 3 {
                source_names[scope.types[n]] = binding
              }
            }
            Outer(_, _) if kind == 3 => ()
            Outer(count, outer_index) if kind == 4 =>
              refs[(kind, n)] = captured_values[capture_name(
                  enclosing(snapshot, count, inspection).entry.id,
                  4,
                  outer_index,
                )]
            _ => reject("core alias in pure component composition")
          }
          if kind == 4 && !packages.contains(n) {
            captured_values[capture_name(id, 4, n)] = lookup(refs, 4, n)
          }
        }
      }
      11 => {
        let entries = @component.parse_export_section(section.payload) catch {
          error => raise Failure("WAC-D001", error.to_string())
        }
        for exported in entries {
          let kind = sort(exported.sortidx.sort)
          let n = take(kind)
          let mut value = reference(kind, exported.sortidx.idx)
          let expected = scope_item(scope, exported.sortidx.sort, n)
          let identity = match types[item_id(expected)].kind {
            Interface(name, _, _) | World(name, _, _, _) => name
            _ => None
          }
          if exported.desc is Some(_) ||
            (
              identity is Some(_) &&
              unnamed_values.contains((kind, exported.sortidx.idx))
            ) {
            let actual = scope_item(
              scope,
              exported.sortidx.sort,
              exported.sortidx.idx,
            )
            let helper_id = id + "/ascribe-" + kind.to_string() + "-n\{n}"
            let captured = type_captures(
              types,
              source_names,
              id,
              roots=Some([item_id(actual), item_id(expected)]),
            )
            let args = captured.map(c => quote(c.0.name) + ": " + c.1)
            args.push(
              quote(
                helper_parameter(
                  "input",
                  ReadOnlyArray::from_array(captured.map(c => c.0)),
                ),
              ) +
              ": " +
              value,
            )
            let text = ascribe_component(
              types,
              actual,
              expected,
              identity~,
              captured=ReadOnlyArray::from_array(captured.map(c => c.0)),
            )
            helpers.push({
              id: helper_id,
              path: document_path(helper_id, Wat),
              package_name: package_key(helper_id),
              bodies: [],
              kind: Wat,
              text,
            })
            out.write_string(
              "let ascription\{kind}n\{n} = new " +
              package_key(helper_id) +
              " {" +
              args.join(", ") +
              "};\nlet ascribed\{kind}n\{n} = ascription\{kind}n\{n}[" +
              quote(identity.unwrap_or("value")) +
              "];\n",
            )
            value = "ascribed\{kind}n\{n}"
          }
          out.write_string(
            "export " +
            value +
            " as " +
            quote(external_name(exported.name)) +
            ";\n",
          )
          refs[(kind, n)] = value
          match exported.sortidx.sort {
            Type => source_names[scope.types[n]] = value
            Component => captured_values[capture_name(id, 4, n)] = value
            Core(0x11) => captured_values[capture_name(id, 0x111, n)] = value
            _ => ()
          }
        }
      }
      _ => reject("core content cannot be lifted to WAC")
    }
  }
  if !carrier_needed.is_empty() {
    let contract_id = id + "/imports"
    helpers.push({
      id: contract_id,
      path: document_path(contract_id, Wat),
      package_name: package_key(contract_id),
      bodies: [],
      kind: Wat,
      text: import_contract(
        types,
        imports,
        ReadOnlyArray::from_array(carrier_needed),
      ),
    })
  }
  { text: out.to_string(), helpers, }
}

///|
/// Split at component boundaries. None selects all; Some([]) selects none.
/// Core-module and unknown selectors fail before any document is returned.
pub fn split(
  bytes : Bytes,
  select~ : ReadOnlyArray[String]? = None,
  source_id~ : String = "<wasm>",
) -> Result[Split, ReadOnlyArray[Diagnostic]] {
  try {
    let inspection = inspect(bytes, source_id)
    let wanted : Map[String, Bool] = Map([])
    match select {
      None =>
        for snapshot in inspection.snapshots {
          wanted[snapshot.entry.id] = true
        }
      Some(ids) =>
        for id in ids {
          let mut found : Entry? = None
          for entry in inspection.inventory.entries {
            if entry.id == id {
              found = Some(entry)
            }
          }
          guard found is Some(entry) else {
            reject("unknown component selector: " + id)
          }
          if entry.kind == CoreModule {
            reject("core-module selectors are not supported: " + id)
          }
          wanted[id] = true
        }
    }
    if wanted.is_empty() {
      return Ok({ inventory: inspection.inventory, documents: [], })
    }
    let leaves : Array[String] = []
    let active : Array[Snapshot] = []
    for snapshot in inspection.snapshots {
      if snapshot.entry.kind == CoreModule && snapshot.entry.id != "root" {
        continue
      }
      let selected_inside = fn(leaf : String) {
        select is Some(ids) &&
        ids.any(selected => {
          selected.has_prefix(leaf + "/") &&
          (
            snapshot.entry.id == selected ||
            snapshot.entry.id.has_prefix(selected + "/")
          )
        })
      }
      if leaves.any(id => {
          snapshot.entry.id.has_prefix(id + "/") && !selected_inside(id)
        }) {
        continue
      }
      active.push(snapshot)
      if !snapshot.pure {
        leaves.push(snapshot.entry.id)
      }
    }
    let closures : Map[String, Closure] = Map([])
    for snapshot in active {
      if snapshot.entry.kind == Component {
        closures[snapshot.entry.id] = closure(snapshot, inspection)
      }
    }
    let documents : Array[Document] = []
    for snapshot in active {
      if snapshot.pure {
        let lifted = lift(snapshot, inspection, closures)
        documents.push({
          id: snapshot.entry.id,
          path: document_path(snapshot.entry.id, Wac),
          package_name: package_key(snapshot.entry.id),
          bodies: [],
          kind: Wac,
          text: lifted.text,
        })
        documents.append(lifted.helpers)
      } else if snapshot.entry.kind == Component &&
        !closures[snapshot.entry.id].bindings.is_empty() {
        documents.push({
          id: snapshot.entry.id,
          path: document_path(snapshot.entry.id, Wat),
          package_name: package_key(snapshot.entry.id),
          kind: Wat,
          bodies: [],
          text: close_wat(closures[snapshot.entry.id], inspection, false),
        })
      } else {
        documents.push(wat_document(snapshot.entry.id, snapshot.bytes))
      }
    }
    ignore(
      verify_documents(
        documents,
        inspection.inventory.entries[0].kind == CoreModule,
      ),
    )
    let selected_documents = match select {
      None => documents
      Some(_) =>
        documents.filter(document => {
          wanted.contains(document.id) ||
          wanted
          .keys()
          .any(id => {
            document.id.has_prefix(id + "/") &&
            !document.id[id.length() + 1:].contains("/") &&
            document.bodies.all(body => wanted.contains(body)) &&
            !inspection.inventory.entries.any(entry => entry.id == document.id)
          })
        })
    }
    Ok({
      inventory: inspection.inventory,
      documents: ReadOnlyArray::from_array(selected_documents),
    })
  } catch {
    Failure(code, message) => Err([{ source: source_id, code, message, }])
  }
}

///|
pub extend DocumentKind with Eq::{equal, not_equal}

///|
pub extend DocumentKind with @debug.Debug::{to_repr}

///|
fn scope_item(
  scope : @verifier.ComponentScope,
  sort : @component.Sort,
  index : Int32,
) -> @verifier.ItemKind raise Failure {
  match sort {
    Type => @verifier.Type(scope.types[index])
    Func => @verifier.Function(scope.functions[index])
    Value => @verifier.Value(scope.values[index])
    Component => @verifier.Component(scope.components[index])
    Instance => @verifier.Instance(scope.instances[index])
    Core(0x11) => @verifier.Module(scope.modules[index])
    _ => reject("core item in pure component composition")
  }
}

///|
fn verify_documents(
  documents : Array[Document],
  core_root : Bool,
) -> ReadOnlyArray[@verifier.CompositionPackage] raise Failure {
  let binary : Array[@verifier.PackageSource] = []
  let source : Array[@verifier.SourcePackage] = []
  for document in documents {
    match document.kind {
      Wat => {
        if document.id == "root" && core_root {
          continue
        }
        let bytes = compile(document.text)
        if @component.sniff_binary_kind(bytes) == Some(Component) {
          binary.push({
            name: document.package_name,
            version: None,
            source: document.path,
            bytes,
          })
        }
      }
      Wac =>
        source.push({
          name: document.package_name,
          version: None,
          source: document.path,
          text: document.text,
        })
    }
  }
  match
    @verifier.resolve_composition_packages(
      ReadOnlyArray::from_array(source),
      dependencies=ReadOnlyArray::from_array(binary),
    ) {
    Ok(models) => models
    Err(errors) => raise Failure("WAC-D004", errors[0].render())
  }
}
