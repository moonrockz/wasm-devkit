///|
priv struct Closure {
  snapshot : Snapshot
  fragment : String
  bindings : Array[
    (@component_text.OuterReference, Int32, @core_types.Definition?),
  ]
  captures : Array[@verifier.Extern]
  ensure : Array[Int32]
  origins : Map[String, (String, Int32, Int32)]
}

///|
fn type_edges(kind : @verifier.TypeKind) -> Array[Int32] {
  match kind {
    Interface(_, uses, exports) =>
      uses.map(u => u.ty).iter().to_array() +
      exports.map(e => item_id(e.kind)).iter().to_array()
    World(_, uses, imports, exports) =>
      uses.map(u => u.ty).iter().to_array() +
      imports.map(e => item_id(e.kind)).iter().to_array() +
      exports.map(e => item_id(e.kind)).iter().to_array()
    _ => type_children(kind)
  }
}

///|
fn free_resources(
  types : ReadOnlyArray[@verifier.ResolvedType],
  root : Int32,
) -> Array[Int32] raise Failure {
  let seen : Map[Int32, Bool] = Map([])
  let bound : Map[Int32, Bool] = Map([])
  let resources : Array[Int32] = []
  let work = [root]
  while work.pop() is Some(id) {
    if seen.contains(id) {
      continue
    }
    seen[id] = true
    if seen.length() > 1000000 {
      reject("closure signature exceeds its work limit")
    }
    match types[id].kind {
      Resource(None) => resources.push(id)
      Interface(_, _, exports) | World(_, _, _, exports) => {
        let externs = exports.iter().to_array()
        if types[id].kind is World(_, _, imports, _) {
          externs.append(imports.iter().to_array())
        }
        for item in externs {
          if item.kind is Type(id) && types[id].kind is Resource(None) {
            bound[id] = true
          }
        }
      }
      _ => ()
    }
    work.append(type_edges(types[id].kind))
  }
  resources.filter(id => !bound.contains(id))
}

///|
fn enclosing(
  snapshot : Snapshot,
  distance : Int32,
  inspection : Inspection,
) -> Snapshot raise Failure {
  let mut current = snapshot
  for _ in 0..<distance {
    guard current.entry.parent is Some(parent) else {
      reject("outer alias exceeds lexical components")
    }
    let mut found : Snapshot? = None
    for candidate in inspection.snapshots {
      if candidate.entry.id == parent {
        found = Some(candidate)
        break
      }
    }
    guard found is Some(parent) else {
      reject("outer component is absent from inventory")
    }
    current = parent
  }
  current
}

///|
fn closure(
  snapshot : Snapshot,
  inspection : Inspection,
) -> Closure raise Failure {
  if snapshot.entry.id == "root" {
    return {
      snapshot,
      fragment: "",
      bindings: [],
      captures: [],
      ensure: [],
      origins: Map([]),
    }
  }
  let path : Array[Int32] = []
  let mut current = snapshot
  while current.entry.parent is Some(_) {
    path.push(current.scope.unwrap().index)
    current = enclosing(current, 1, inspection)
  }
  let path = Array::makei(path.length(), i => path[path.length() - i - 1])
  let fragment = match
    @wat.component_fragment_validated(
      inspection.validated.unwrap(),
      ReadOnlyArray::from_array(path),
    ) {
    Ok(fragment) => fragment.text
    Err(errors) => raise Failure("WAC-D004", errors[0].message)
  }
  let references = @component_text.outer_references(fragment) catch {
    error => raise Failure("WAC-D004", error.to_string())
  }
  let captures : Array[@verifier.Extern] = []
  let captured : Map[String, Bool] = Map([])
  let origins : Map[String, (String, Int32, Int32)] = Map([])
  let ensure : Array[Int32] = []
  let bindings : Array[
    (@component_text.OuterReference, Int32, @core_types.Definition?),
  ] = []
  let types = inspection.inventory.types
  for reference in references {
    let ancestor = enclosing(snapshot, reference.distance, inspection)
    let outer = ancestor.scope.unwrap()
    let id = match reference.sort {
      3 => outer.types[reference.index]
      4 => outer.components[reference.index]
      0x111 => outer.modules[reference.index]
      0x110 => {
        bindings.push(
          (reference, reference.index, Some(outer.core_types[reference.index])),
        )
        continue
      }
      _ => reject("unsupported lexical capture sort")
    }
    bindings.push((reference, id, None))
    let values = if reference.sort == 3 {
      free_resources(types, id)
    } else {
      [id]
    }
    if reference.sort == 3 {
      ensure.push(id)
    }
    for value in values {
      let sort = if reference.sort == 3 { 3 } else { reference.sort }
      let name = if sort == 3 {
        "capture-type-n\{value}"
      } else {
        capture_name(ancestor.entry.id, sort, reference.index)
      }
      if captured.contains(name) {
        continue
      }
      captured[name] = true
      origins[name] = (ancestor.entry.id, sort, reference.index)
      let kind : @verifier.ItemKind = match sort {
        3 => Type(value)
        4 => Component(value)
        _ => Module(value)
      }
      captures.push({
        name,
        kind,
        location: @verifier.Location::binary(snapshot.entry.id),
      })
    }
  }
  { snapshot, fragment, bindings, captures, ensure, origins, }
}

///|
fn kind_name(kind : @verifier.ItemKind) -> String {
  match kind {
    Type(_) => "type"
    Function(_) => "func"
    Instance(_) => "instance"
    Component(_) => "component"
    Module(_) => "core module"
    Value(_) => "value"
  }
}

///|
// A closure document explicitly imports its free nominal types and component
// or module values. Pure metadata is copied as type declarations. The original
// body stays nested with unchanged local index spaces and relocated aliases.
fn close_wat(
  value : Closure,
  inspection : Inspection,
  reify : Bool,
) -> String raise Failure {
  let scope = value.snapshot.scope.unwrap()
  let types = inspection.inventory.types
  let inputs = value.captures.copy()
  let original = component_imports(types, scope)
  if !reify {
    inputs.append(original.iter().to_array())
  }
  let names : Map[Int32, String] = Map([])
  let prelude = render_contract(
    types,
    ReadOnlyArray::from_array(inputs),
    [],
    false,
    prelude=true,
    preserve_names=true,
    ensure=ReadOnlyArray::from_array(value.ensure),
    out_names=Some(names),
  )
  let replacements : Array[@component_text.OuterBinding] = []
  let core = StringBuilder()
  let mut core_serial = 0
  for i, (reference, id, core_type) in value.bindings {
    let name = match core_type {
      Some(definition) => {
        let name = "$capture-core-n\{i}"
        let render : CoreRender = {
          out: StringBuilder(),
          serial: core_serial,
          remaining: 1000000,
          component: true,
        }
        let body = match definition {
          Function(function) => core_function(function, render)
          Module(module_) => module_type(module_)
          Heap(identity) => {
            let root = core_identity(identity, render)
            core.write_string(render.out.to_string())
            root
          }
        }
        core_serial = render.serial
        if definition is Heap(_) {
          body
        } else {
          core.write_string(render.out.to_string())
          core.write_string("(core type " + name + " " + body + ")\n")
          name
        }
      }
      None if reference.sort == 3 => names[id]
      None => {
        let ancestor = enclosing(value.snapshot, reference.distance, inspection)
        let key = capture_name(
          ancestor.entry.id,
          reference.sort,
          reference.index,
        )
        let mut binding = ""
        for i, capture in value.captures {
          if capture.name == key {
            binding = "$i\{i}"
            break
          }
        }
        if binding.is_empty() {
          reject("capture has no containing declaration")
        }
        binding
      }
    }
    replacements.push({
      distance: reference.distance,
      sort: reference.sort,
      index: reference.index,
      name,
    })
  }
  let body = @component_text.relocate_outer_references(
    value.fragment,
    ReadOnlyArray::from_array(replacements),
  ) catch {
    error => raise Failure("WAC-D004", error.to_string())
  }
  let out = StringBuilder()
  out.write_string(
    "(component\n" +
    prelude +
    core.to_string() +
    "(component $body" +
    body[10:].to_owned(),
  )
  if reify {
    out.write_string("(export \"value\" (component $body))\n")
  } else {
    out.write_string("(instance $run (instantiate $body")
    for i, item in original {
      out.write_string(
        " (with " +
        wat_quote(item.name) +
        " (" +
        kind_name(item.kind) +
        " $i\{value.captures.length() + i}))",
      )
    }
    out.write_string("))\n")
    guard types[scope.world].kind is World(_, _, _, exports) else {
      reject("closure has no world contract")
    }
    for i, item in exports {
      out.write_string(
        "(alias export $run " +
        wat_quote(item.name) +
        " (" +
        kind_name(item.kind) +
        " $out\{i}))\n(export " +
        wat_quote(item.name) +
        " (" +
        kind_name(item.kind) +
        " $out\{i}))\n",
      )
    }
  }
  out.write_string(")\n")
  let result = out.to_string()
  ignore(compile(result))
  result
}

///|
fn invoke_component(
  types : ReadOnlyArray[@verifier.ResolvedType],
  target : Int32,
  arguments : ReadOnlyArray[@verifier.Extern],
  captured~ : ReadOnlyArray[@verifier.Extern] = [],
) -> String raise Failure {
  let inputs = captured.iter().to_array()
  let positions : Map[Int32, Int32] = Map([])
  for i, argument in arguments {
    if argument.kind is Type(_) {
      positions[i] = inputs.length()
      inputs.push(argument)
    }
  }
  let target_index = inputs.length()
  inputs.push({
    name: invocation_target(arguments, captured),
    kind: @verifier.Component(target),
    location: @verifier.Location::binary("<invoke>"),
  })
  for i, argument in arguments {
    if !(argument.kind is Type(_)) {
      positions[i] = inputs.length()
      inputs.push(argument)
    }
  }
  let prelude = render_contract(
    types,
    ReadOnlyArray::from_array(inputs),
    [],
    false,
    prelude=true,
    preserve_names=true,
  )
  let out = StringBuilder()
  out.write_string(
    "(component\n" + prelude + "(instance $run (instantiate $i\{target_index}",
  )
  for i, argument in arguments {
    out.write_string(
      " (with " +
      wat_quote(argument.name) +
      " (" +
      kind_name(argument.kind) +
      " $i\{positions[i]}))",
    )
  }
  out.write_string("))\n(export \"value\" (instance $run)))\n")
  out.to_string()
}

///|
fn ascribe_component(
  types : ReadOnlyArray[@verifier.ResolvedType],
  actual : @verifier.ItemKind,
  expected : @verifier.ItemKind,
  identity~ : String? = None,
  captured~ : ReadOnlyArray[@verifier.Extern] = [],
) -> String raise Failure {
  let names : Map[Int32, String] = Map([])
  let original_id = item_id(expected)
  let graph = types.iter().to_array()
  let id = if identity is Some(_) {
    let id = graph.length()
    graph.push({ ..types[original_id], id, })
    id
  } else {
    original_id
  }
  let types = ReadOnlyArray::from_array(graph)
  let prelude = render_contract(
    types,
    ReadOnlyArray::from_array(
      captured.iter().to_array() +
      [
        {
          name: helper_parameter("input", captured),
          kind: actual,
          location: @verifier.Location::binary("<ascription>"),
        },
      ],
    ),
    [],
    false,
    prelude=true,
    preserve_names=true,
    ensure=[id],
    out_names=Some(names),
  )
  let name = names[id]
  let desc = match expected {
    Type(_) => "(type (eq " + name + "))"
    Value(_) => "(value " + contract_value_name(types, names, id) + ")"
    _ => "(" + kind_name(expected) + " (type " + name + "))"
  }
  "(component\n" +
  prelude +
  "(export " +
  wat_quote(identity.unwrap_or("value")) +
  " (" +
  kind_name(actual) +
  " $i\{captured.length()}) " +
  desc +
  "))\n"
}

///|
fn capture_name(origin : String, sort : Int32, index : Int32) -> String {
  "capture-" +
  (if sort == 4 { "component" } else { "module" }) +
  "-h" +
  @crypto.bytes_to_hex_string(@crypto.sha256(@utf8.encode(origin))) +
  "-n\{index}"
}

///|
fn invocation_target(
  arguments : ReadOnlyArray[@verifier.Extern],
  captured : ReadOnlyArray[@verifier.Extern],
) -> String {
  let mut name = "invoke-target"
  while arguments.any(a => a.name == name) || captured.any(a => a.name == name) {
    name += "-target"
  }
  name
}

///|
fn instance_value_component(
  types : ReadOnlyArray[@verifier.ResolvedType],
  instance : Int32,
  name : String,
  captured : ReadOnlyArray[@verifier.Extern],
) -> String raise Failure {
  let inputs = captured.iter().to_array()
  inputs.push({
    name: helper_parameter("source", captured),
    kind: @verifier.Instance(instance),
    location: @verifier.Location::binary("<value-alias>"),
  })
  let prelude = render_contract(
    types,
    ReadOnlyArray::from_array(inputs),
    [],
    false,
    prelude=true,
    preserve_names=true,
  )
  "(component\n" +
  prelude +
  "(alias export $i\{captured.length()} " +
  wat_quote(name) +
  " (value $value))\n(export \"value\" (value $value)))\n"
}

///|
fn helper_parameter(
  base : String,
  captured : ReadOnlyArray[@verifier.Extern],
) -> String {
  let mut name = base
  while captured.any(c => c.name == name) {
    name += "-input"
  }
  name
}
