///|
priv enum Role {
  Root
  Top
  Member
  ResourceMember
  Type
  Signature
  Parameter
  Field
  Case
  EmptyCase
  Inline
}

///|
fn declaration(data : @ast.Data) -> String? {
  match data {
    Interface(name~, ..)
    | World(name~, ..)
    | Alias(name~, ..)
    | Record(name~, ..)
    | Flags(name~, ..)
    | Enum(name~, ..)
    | Variant(name~, ..)
    | Resource(name~, ..)
    | Function(name~, ..) => Some(name)
    _ => None
  }
}

///|
/// Verify a caller-built tree directly. Structural validation precedes every
/// arena access; semantic roles and the supplied source bounds are then checked.
pub fn verify_ast(
  tree : @ast.Tree,
  source_id~ : String = "<input>",
  source~ : String,
  semantic_features~ : SemanticFeatures = SemanticFeatures::default(),
) -> Result[Verified, ReadOnlyArray[Diagnostic]] {
  let document : Document = {
    id: source_id,
    text: source,
    ast: tree,
    diagnostics: [],
  }
  match resolve({ documents: [document], }, semantic_features~) {
    Ok(result) => Ok(result.model.with_source(source_id, source, tree))
    Err(errors) => Err(errors)
  }
}

///|
fn verify_prepared(
  prepared : Prepared,
  semantic_features : SemanticFeatures,
  binary_sources~ : Map[String, Bool] = Map([]),
  binary_metadata~ : Map[Int32, Stability] = Map([]),
  binary_references~ : Map[Int32, EncodedReference] = Map([]),
  selection_output~ : Map[(String, Int32), Bool] = Map([]),
  external_id_overrides~ : Map[(String, String, String), String?] = Map([]),
  selected_models~ : Array[Resolution] = [],
  input_ranks~ : Map[String, Int32] = Map([]),
) -> Result[Resolution, ReadOnlyArray[Diagnostic]] {
  let tree = prepared.tree
  let errors : Array[Diagnostic] = []
  let stability_values = parse_stabilities(prepared, errors)
  let external_id_values = parse_external_ids(prepared, errors)
    .iter()
    .to_array()
  if !external_id_overrides.is_empty() {
    for (key, id, _) in encoded_external_id_members(prepared) {
      if external_id_overrides.get(key) is Some(value) {
        external_id_values[id] = value
      }
    }
  }
  let external_ids = ReadOnlyArray::from_array(external_id_values)
  for (id, value) in binary_metadata {
    stability_values[id] = { value, origin: None, }
  }
  let stabilities = ReadOnlyArray::from_array(stability_values)
  let bad = fn(id : Int32, code : String, message : String) {
    errors.push(prepared_error(prepared, id, code, message))
  }
  let scopes : Array[Map[String, Int32]] = []
  for _ in prepared.identities {
    scopes.push({})
  }
  let bindings : Array[Binding] = []
  let pending : Array[(Int32, Role, Int32)] = []
  for i = prepared.roots.length() - 1; i >= 0; i = i - 1 {
    let root = prepared.roots[i]
    pending.push((root, Root, prepared.node_packages[root]))
  }
  let references : Array[(Int32, Int32)] = []
  let aliases : Array[Int32] = []
  let excluded_selectors : Map[Int32, Bool] = Map([])
  let ignored_world_paths : Map[String, Int32] = Map([])
  let owner_scopes : Map[Int32, Int32] = Map([])
  let scope_owners : Map[Int32, Int32] = Map([])
  let interface_edges : Array[(Int32, Int32, Int32)] = []
  let package_edges : Array[(Int32, Int32, Int32)] = []
  let tables = WorldTables::new()
  let includes : Array[(Int32, Int32, Int32, ReadOnlyArray[Int32])] = []
  let strong_scopes : Map[Int32, Map[String, Int32]] = Map([])
  let register = fn(scope_id : Int32, name : String, id : Int32) {
    let names = match strong_scopes.get(scope_id) {
      Some(names) => names
      None => {
        let names : Map[String, Int32] = Map([])
        strong_scopes[scope_id] = names
        names
      }
    }
    let key = if scope_id < prepared.identities.length() {
      name
    } else {
      let name = if !name.has_prefix("[") &&
        tree.nodes[id].data is Function(signature~, ..) {
        signature_name(tree, signature, name)
      } else {
        name
      }
      component_name_key(name)
    }
    if names.get(key) is Some(first) {
      let d = prepared_error(
        prepared,
        id,
        "WIT-S004",
        "duplicate declaration `" + name + "`",
      )
      errors.push({
        ..d,
        related: [
          {
            location: prepared.origins[first].location,
            message: "first declared here",
          },
        ],
      })
    } else {
      names[key] = id
      scopes[scope_id][name] = id
      bindings.push({ name, scope: scope_id, node: id, target: id, })
    }
  }
  // Every interface scope, including inline interfaces, is allocated before
  // resolving forward references. Context validation still visits every node.
  for item, node in tree.nodes {
    match node.data {
      Interface(items=members, ..) | World(items=members, ..) => {
        let scope_id = scopes.length()
        scopes.push({})
        owner_scopes[item] = scope_id
        scope_owners[scope_id] = item
        if node.data is World(..) {
          tables.init(item)
        }
        for member_id in members {
          if declaration(tree.nodes[member_id].data) is Some(name) {
            register(scope_id, name, member_id)
          }
          if tree.nodes[member_id].data is Resource(methods~, ..) {
            for func_id in methods {
              if resource_function_name(tree, member_id, func_id) is Some(name) {
                register(scope_id, name, func_id)
              }
            }
          }
          if tree.nodes[member_id].data is Use(names~, ..) {
            for selector in names {
              if tree.nodes[selector].data is Rename(name~, renamed~) {
                register(scope_id, renamed.unwrap_or(name), selector)
                aliases.push(selector)
              }
            }
          }
        }
      }
      _ => ()
    }
  }
  for root in prepared.roots {
    for item in section_items(tree.nodes[root].data) {
      match tree.nodes[item].data {
        Interface(name~, ..) | World(name~, ..) =>
          register(prepared.node_packages[root], name, item)
        _ => ()
      }
    }
  }
  let foreign_kinds = foreign_kinds(prepared, errors)
  let file_aliases = collect_file_aliases(
    prepared, scopes, bindings, package_edges, foreign_kinds, errors,
  )
  let foreign = foreign_gates(
    prepared,
    scopes,
    file_aliases,
    stabilities,
    semantic_features,
    binary_sources~,
  )
  let record_path = fn(
    owner : Int32,
    path : Int32,
    target : Int32,
    external : Bool,
  ) {
    interface_edges.push((owner, target, path))
    if external {
      package_edges.push(
        (prepared.node_packages[path], prepared.node_packages[target], path),
      )
    }
  }
  let disabled_foreign = fn(at : Int32, path : Int32) {
    if !binary_sources.contains(prepared.origins[at].location.source) &&
      !semantic_features.includes(stabilities[at].value) &&
      prepared.foreign_package(path) is Some(package_index) {
      package_edges.push((prepared.node_packages[at], package_index, path))
      true
    } else {
      false
    }
  }
  let world_entry = fn(
    owner : Int32,
    imported : Bool,
    name : String,
    kind : WorldItemKind,
    node : Int32,
    by_id : Bool,
  ) {
    tables.add(
      prepared,
      owner,
      imported,
      {
        name,
        kind,
        by_id,
        location: prepared.origins[node].location,
        stability: stabilities[node].value,
        external_id: if kind is Interface(_) {
          external_ids[node]
        } else {
          None
        },
      },
      node,
      false,
      errors,
    )
  }
  for owner, node in tree.nodes {
    if node.data is World(items~, ..) {
      for item in items {
        if type_declaration(tree.nodes[item].data) &&
          declaration(tree.nodes[item].data) is Some(name) {
          world_entry(owner, true, name, Type(item), item, false)
        }
      }
    }
  }
  let duplicates = fn(ids : ReadOnlyArray[Int32], kind : String) {
    let seen : Map[String, Int32] = Map([])
    for child in ids {
      let name = match tree.nodes[child].data {
        Field(name~, ..) | Case(name~, ..) | Parameter(name~, ..) => Some(name)
        _ => None
      }
      if name is Some(name) {
        if seen.get(strong_name(name)) is Some(first) {
          let d = prepared_error(
            prepared,
            child,
            "WIT-S004",
            "duplicate " + kind + " `" + name + "`",
          )
          errors.push({
            ..d,
            related: [
              {
                location: prepared.origins[first].location,
                message: "first declared here",
              },
            ],
          })
        } else {
          seen[strong_name(name)] = child
        }
      }
    }
  }
  while pending.pop() is Some((id, role, scope)) {
    let node = tree.nodes[id]
    let data = node.data
    let decoded_name = match data {
      Interface(name~, ..)
      | World(name~, ..)
      | Record(name~, ..)
      | Flags(name~, ..)
      | Enum(name~, ..)
      | Variant(name~, ..)
      | Resource(name~, ..)
      | Field(name~, ..)
      | Case(name~, ..)
      | Alias(name~, ..)
      | Function(name~, ..)
      | Parameter(name~, ..)
      | NamedType(name~) => Some(name)
      _ => None
    }
    if decoded_name is Some(name) &&
      !identifier(name) &&
      !(role is Inline && name.is_empty()) {
      bad(id, "WIT-S001", "invalid decoded identifier")
    }

    if role is Inline && data is Interface(name~, ..) && !name.is_empty() {
      bad(id, "WIT-S001", "inline interface AST must be anonymous")
    }
    let mut accepted = true
    match (role, data) {
      (Root, File(items~)) | (Root, Package(items~, nested=true, ..)) =>
        for i = items.length() - 1; i >= 0; i = i - 1 {
          if !(tree.nodes[items[i]].data is Package(..)) {
            pending.push((items[i], Top, scope))
          }
        }
      (Top, Use(..)) => ()
      (Inline, Interface(items~, attributes~, ..))
      | (Top, Interface(items~, attributes~, ..))
      | (Top, World(items~, attributes~, ..)) => {
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        guard owner_scopes.get(id) is Some(scope_id) else {
          bad(id, "WIT-S001", "invalid interface/world scope")
          continue
        }
        for item in items {
          if data is World(..) && tree.nodes[item].data is Function(..) {
            bad(item, "WIT-S001", "world functions must be imports or exports")
          }
        }
        for i = items.length() - 1; i >= 0; i = i - 1 {
          pending.push((items[i], Member, scope_id))
        }
      }
      (Member, Use(path~, names~, renamed~, attributes~)) => {
        if renamed is Some(_) || !semantic_attributes(tree, attributes) {
          bad(
            id, "WIT-S003", "interface alias and use attributes are not yet supported",
          )
        }
        if names.is_empty() {
          bad(id, "WIT-S001", "use requires selected type names")
        }
        if foreign.paths.contains(id) &&
          (
            !semantic_features.includes(stabilities[id].value) ||
            names.any(selector => foreign.excluded.contains(selector))
          ) {
          ignore(disabled_foreign(id, path))
          for selector in names {
            guard tree.nodes[selector].data is Rename(name~, renamed~) else {
              bad(selector, "WIT-S001", "invalid use selector role")
              continue
            }
            let introduced = renamed.unwrap_or(name)
            if !identifier(name) || !identifier(introduced) {
              bad(selector, "WIT-S001", "invalid decoded use name")
            }
            // No public type is constructed for an excluded foreign selector.
            // References to it are availability failures before model creation.
            excluded_selectors[selector] = true
            if semantic_features.includes(stabilities[selector].value) &&
              foreign.excluded.get(selector) is Some(first) {
              let diagnostic = prepared_error(
                prepared, selector, "WIT-S013", "foreign type excluded by its first semantic feature gate",
              )
              errors.push({
                ..diagnostic,
                related: [
                  {
                    location: prepared.origins[first].location,
                    message: "first foreign type gate",
                  },
                ],
              })
            }
            let owner = scope_owners[scope]
            if tree.nodes[owner].data is World(..) {
              world_entry(
                owner,
                true,
                introduced,
                Type(selector),
                selector,
                false,
              )
            }
          }
          continue
        }
        match prepared.find_item(scopes, path, "interface", file_aliases~) {
          Err(d) => errors.push(d)
          Ok((target, external)) => {
            let owner = scope_owners[scope]
            record_path(owner, path, target, external)
            if tree.nodes[owner].data is World(..) {
              tables.uses[owner].push((target, path))
            }
            let target_scope = owner_scopes[target]
            for selector in names {
              guard tree.nodes[selector].data is Rename(name~, renamed~) else {
                bad(selector, "WIT-S001", "invalid use selector role")
                continue
              }
              let introduced = renamed.unwrap_or(name)
              if !identifier(name) || !identifier(introduced) {
                bad(selector, "WIT-S001", "invalid decoded use name")
              }
              match scopes[target_scope].get(name) {
                None =>
                  bad(
                    selector,
                    "WIT-S005",
                    "unresolved type `" + name + "` in imported interface",
                  )
                Some(declaration) =>
                  if !type_declaration(tree.nodes[declaration].data) &&
                    !(tree.nodes[declaration].data is Rename(..)) {
                    let d = prepared_error(
                      prepared, selector, "WIT-S008", "imported name is not a type",
                    )
                    errors.push({
                      ..d,
                      related: [
                        {
                          location: prepared.origins[declaration].location,
                          message: "non-type declaration is here",
                        },
                      ],
                    })
                  } else {
                    references.push((selector, declaration))
                    bindings.push({
                      name: introduced,
                      scope,
                      node: selector,
                      target: declaration,
                    })
                    if tree.nodes[owner].data is World(..) {
                      world_entry(
                        owner,
                        true,
                        introduced,
                        Type(selector),
                        selector,
                        false,
                      )
                    }
                  }
              }
            }
          }
        }
      }
      (Member, Import(name~, target~, attributes~))
      | (Member, Export(name~, target~, attributes~)) => {
        let owner = scope_owners[scope]
        if !(tree.nodes[owner].data is World(..)) {
          bad(id, "WIT-S001", "imports and exports require a world")
          continue
        }
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "world item attributes are not yet supported")
        }
        let imported = data is Import(..)
        match tree.nodes[target].data {
          Path(..) =>
            match
              prepared.find_item(scopes, target, "interface", file_aliases~) {
              Err(d) =>
                if (d.code == "WIT-S005" || d.code == "WIT-S008") &&
                  disabled_foreign(id, target) {
                  let key = owner.to_string() +
                    ":" +
                    imported.to_string() +
                    ":" +
                    @debug.to_string(tree.nodes[target].data)
                  if ignored_world_paths.get(key) is Some(first) {
                    let diagnostic = prepared_error(
                      prepared, id, "WIT-S004", "duplicate gated foreign world item",
                    )
                    errors.push({
                      ..diagnostic,
                      related: [
                        {
                          location: prepared.origins[first].location,
                          message: "first declared here",
                        },
                      ],
                    })
                  } else {
                    ignored_world_paths[key] = id
                  }
                } else {
                  errors.push(d)
                }
              Ok((interface_id, external)) => {
                record_path(owner, target, interface_id, external)
                let canonical = prepared.interface_name(interface_id)
                world_entry(
                  owner,
                  imported,
                  name.unwrap_or(canonical),
                  Interface(interface_id),
                  id,
                  name is None,
                )
              }
            }
          Signature(..) =>
            match name {
              Some(name) => {
                if !identifier(name) {
                  bad(id, "WIT-S001", "invalid world function name")
                }
                world_entry(
                  owner,
                  imported,
                  signature_name(tree, target, name),
                  Function(target),
                  id,
                  false,
                )
                pending.push((target, Signature, scope))
              }
              None => bad(id, "WIT-S001", "world functions require a name")
            }
          Interface(..) =>
            match name {
              Some(name) => {
                if !identifier(name) {
                  bad(id, "WIT-S001", "invalid inline interface name")
                }
                world_entry(owner, imported, name, Interface(target), id, false)
                pending.push((target, Inline, scope))
              }
              None => bad(id, "WIT-S001", "inline interfaces require a name")
            }
          _ => bad(target, "WIT-S001", "invalid world item role")
        }
      }
      (Member, Include(path~, renames~, attributes~)) => {
        let owner = scope_owners[scope]
        if !(tree.nodes[owner].data is World(..)) {
          bad(id, "WIT-S001", "include requires a world")
          continue
        }
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "include attributes are not yet supported")
        }
        for selector in renames {
          guard tree.nodes[selector].data
            is Rename(name~, renamed=Some(replacement)) &&
            identifier(name) &&
            identifier(replacement) else {
            bad(selector, "WIT-S001", "invalid include rename AST")
            continue
          }
        }
        match prepared.find_item(scopes, path, "world", file_aliases~) {
          Err(d) =>
            if !((d.code == "WIT-S005" || d.code == "WIT-S008") &&
              disabled_foreign(id, path)) {
              errors.push(d)
            }
          Ok((target, external)) => {
            record_path(owner, path, target, external)
            includes.push((owner, target, id, renames))
          }
        }
      }
      (Member, Resource(methods~, attributes~, ..)) => {
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "resource attributes are not yet supported")
        }
        aliases.push(id)
        let owner = scope_owners[scope]
        for func_id in methods {
          if tree.nodes[owner].data is World(..) &&
            resource_function_name(tree, id, func_id) is Some(name) {
            let function_id = match tree.nodes[func_id].data {
              Function(signature~, ..) => signature
              _ => func_id
            }
            world_entry(
              owner,
              true,
              name,
              Function(function_id),
              func_id,
              false,
            )
          }
        }
        for i = methods.length() - 1; i >= 0; i = i - 1 {
          pending.push((methods[i], ResourceMember, scope))
        }
      }
      (Member, Alias(ty~, attributes~, ..)) => {
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        aliases.push(id)
        pending.push((ty, Type, scope))
      }
      (Member, Record(fields~, attributes~, ..)) => {
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        if fields.is_empty() {
          bad(id, "WIT-S007", "empty record")
        }
        duplicates(fields, "field")
        aliases.push(id)
        for i = fields.length() - 1; i >= 0; i = i - 1 {
          pending.push((fields[i], Field, scope))
        }
      }
      (Member, Flags(cases~, attributes~, ..))
      | (Member, Enum(cases~, attributes~, ..))
      | (Member, Variant(cases~, attributes~, ..)) => {
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        if cases.is_empty() {
          bad(id, "WIT-S007", "empty aggregate")
        }
        if data is Flags(..) && cases.length() > 32 {
          bad(cases[32], "WIT-S007", "cannot have more than 32 flags")
        }
        duplicates(cases, "case")
        aliases.push(id)
        for i = cases.length() - 1; i >= 0; i = i - 1 {
          pending.push(
            (
              cases[i],
              if data is Variant(..) {
                Case
              } else {
                EmptyCase
              },
              scope,
            ),
          )
        }
      }
      (Field, Field(ty~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        pending.push((ty, Type, scope))
      }
      (Case, Case(payload~, attributes~, ..))
      | (EmptyCase, Case(payload~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        if payload is Some(ty) {
          if role is EmptyCase {
            bad(id, "WIT-S001", "enum and flag cases cannot have payloads")
          }
          pending.push((ty, Type, scope))
        }
      }
      (Member, Function(signature~, attributes~, is_static~, ..))
      | (ResourceMember, Function(signature~, attributes~, is_static~, ..)) => {
        if is_static && role is Member {
          bad(id, "WIT-S001", "static functions require a resource")
        }
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "function attributes are not yet supported")
        }
        if role is ResourceMember &&
          !is_static &&
          tree.nodes[signature].data is Signature(params~, ..) {
          for parameter in params {
            if tree.nodes[parameter].data is Parameter(name~, ..) &&
              strong_name(name) == "self" {
              let d = prepared_error(
                prepared, parameter, "WIT-S004", "parameter conflicts with the implicit self receiver",
              )
              errors.push({
                ..d,
                related: [
                  {
                    location: prepared.origins[signature].location,
                    message: "implicit receiver declared by this method",
                  },
                ],
              })
            }
          }
        }
        pending.push((signature, Signature, scope))
      }
      (ResourceMember, Constructor(params~, result~, attributes~)) => {
        if !semantic_attributes(tree, attributes) {
          bad(id, "WIT-S003", "constructor attributes are not yet supported")
        }
        duplicates(params, "parameter")
        if result is Some(result) {
          pending.push((result, Type, scope))
        }
        for i = params.length() - 1; i >= 0; i = i - 1 {
          pending.push((params[i], Parameter, scope))
        }
      }
      (Signature, Signature(params~, result~, flavor~, asynchronous~)) => {
        if flavor != Func && asynchronous {
          bad(id, "WIT-S001", "accessors cannot be asynchronous")
        }
        if flavor == Get {
          if !params.is_empty() {
            bad(id, "WIT-S007", "getters cannot have explicit parameters")
          }
          if result is None {
            bad(id, "WIT-S007", "getters must return a value")
          }
        } else if flavor == Set && params.length() != 1 {
          bad(
            id, "WIT-S007", "setters must have exactly one explicit parameter",
          )
        }
        duplicates(params, "parameter")
        if result is Some(result) {
          pending.push((result, Type, scope))
        }
        for i = params.length() - 1; i >= 0; i = i - 1 {
          pending.push((params[i], Parameter, scope))
        }
      }
      (Parameter, Parameter(ty~, ..)) => pending.push((ty, Type, scope))
      (Type, PrimitiveType(name~)) =>
        if ![
            "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "f32",
            "f64", "char", "string", "error-context",
          ].contains(name) {
          bad(id, "WIT-S001", "unknown primitive type `" + name + "`")
        }
      (Type, NamedType(name~)) => {
        if binary_references.get(id) is Some(reference) {
          match
            encoded_reference_target(
              prepared, scopes, owner_scopes, id, reference,
            ) {
            Err(error) => errors.push(error)
            Ok((interface_id, target)) => {
              references.push((id, target))
              bindings.push({
                name: reference.type_name,
                scope,
                node: id,
                target,
              })
              let owner = scope_owners[scope]
              record_path(
                owner,
                id,
                interface_id,
                prepared.node_packages[id] !=
                prepared.node_packages[interface_id],
              )
              if tree.nodes[owner].data is World(..) {
                tables.uses[owner].push((interface_id, id))
              }
            }
          }
          continue
        }
        match scopes[scope].get(name) {
          Some(target) =>
            if type_declaration(tree.nodes[target].data) ||
              tree.nodes[target].data is Rename(..) {
              references.push((id, target))
              bindings.push({ name, scope, node: id, target, })
            } else {
              let d = prepared_error(
                prepared,
                id,
                "WIT-S008",
                "expected a type, found `" + name + "`",
              )
              errors.push({
                ..d,
                related: [
                  {
                    location: prepared.origins[target].location,
                    message: "non-type declaration is here",
                  },
                ],
              })
            }
          None => bad(id, "WIT-S005", "unresolved type `" + name + "`")
        }
      }
      (Type, ListType(element~, length~)) => {
        if length is Some(size) && fixed_size(size) is None {
          bad(id, "WIT-S007", "fixed list size must be a decimal u32")
        }
        pending.push((element, Type, scope))
      }
      (Type, OwnType(resource~)) | (Type, BorrowType(resource~)) => {
        if !(tree.nodes[resource].data is NamedType(..)) {
          bad(resource, "WIT-S001", "a handle target must be a resource name")
        }
        pending.push((resource, Type, scope))
      }
      (Type, TupleType(elements~)) => {
        if elements.is_empty() {
          bad(id, "WIT-S007", "empty tuple")
        }
        for i = elements.length() - 1; i >= 0; i = i - 1 {
          pending.push((elements[i], Type, scope))
        }
      }
      (Type, OptionType(payload~)) => pending.push((payload, Type, scope))
      (Type, ResultType(ok~, error~)) => {
        if error is Some(ty) {
          pending.push((ty, Type, scope))
        }
        if ok is Some(ty) {
          pending.push((ty, Type, scope))
        }
      }
      (Type, FutureType(payload~)) | (Type, StreamType(payload~)) =>
        if payload is Some(ty) {
          pending.push((ty, Type, scope))
        }
      (Type, MapType(key~, value~)) => {
        // At this reference revision only direct scalar key syntax is valid.
        // An alias to string remains a defined type and is rejected upstream.
        let valid_key = match tree.nodes[key].data {
          PrimitiveType(name~) =>
            [
              "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "char",
              "string",
            ].contains(name)
          _ => false
        }
        if !valid_key {
          bad(
            key, "WIT-S007", "invalid map key type; expected a direct bool, integer, char or string scalar",
          )
        }
        pending.push((value, Type, scope))
        pending.push((key, Type, scope))
      }
      _ => accepted = false
    }
    if !accepted {
      bad(
        id,
        "WIT-S003",
        "unsupported construct or invalid AST role: " +
        @debug.to_string(node.data.kind()),
      )
    }
  }
  // Alias edges are followed with an explicit stack. Cycles cannot create a model.
  let edges : Map[Int32, Int32] = Map([])
  for (reference, target) in references {
    edges[reference] = target
  }
  let color = Array::make(tree.nodes.length(), 0)
  for alias_id in aliases {
    let work = [(alias_id, false)]
    while work.pop() is Some((id, leaving)) {
      if leaving {
        color[id] = 2
        continue
      }
      if color[id] == 2 {
        continue
      }
      if color[id] == 1 {
        let related : Array[Label] = []
        // The work stack retains ancestors' leave records. Bound diagnostic
        // expansion even for a very deep or densely connected invalid graph.
        for i = work.length() - 1; i >= 0 && i >= work.length() - 64; i = i - 1 {
          let (ancestor, leaving) = work[i]
          if leaving && related.length() < 32 {
            related.push({
              location: prepared.origins[ancestor].location,
              message: "type dependency passes through here",
            })
          }
        }
        let d = prepared_error(
          prepared, id, "WIT-S006", "cyclic type dependency",
        )
        errors.push({ ..d, related: ReadOnlyArray::from_array(related), })
        continue
      }
      color[id] = 1
      work.push((id, true))
      if edges.get(id) is Some(target) {
        work.push((target, false))
      }
      let children = type_edges(tree.nodes[id].data)
      for i = children.length() - 1; i >= 0; i = i - 1 {
        work.push((children[i], false))
      }
    }
  }
  graph_cycles(prepared, interface_edges, false, errors)
  graph_cycles(prepared, package_edges, true, errors)
  if !errors.is_empty() {
    return Err(dependency_chains(prepared, package_edges, errors))
  }
  let resources = resource_roots(tree, edges, excluded_selectors)
  verify_handle_targets(prepared, resources, errors)
  verify_constructors(prepared, edges, errors, binary_sources~)
  verify_setter_results(prepared, edges, errors, binary_sources~)
  if !errors.is_empty() {
    return Err(dependency_chains(prepared, package_edges, errors))
  }
  let arena = SemanticArena::new(
    prepared,
    edges,
    resources,
    stabilities,
    interface_edges,
    external_ids,
    binary_sources~,
  )
  verify_interface_accessors(arena, errors)
  if !errors.is_empty() {
    return Err(dependency_chains(prepared, package_edges, errors))
  }
  let selection = select_features(
    prepared,
    arena,
    stabilities,
    edges,
    semantic_features,
    foreign.versions,
    errors,
    binary_sources~,
  )
  verify_handles(prepared, edges, selection.functions, errors)
  for (owner, target, at, _) in includes {
    if selection.nodes[owner] && selection.nodes[at] && !selection.nodes[target] {
      errors.push(unavailable(prepared, arena, at, target))
    }
  }
  let includes = includes.filter(entry => {
    selection.nodes[entry.0] && selection.nodes[entry.2]
  })
  let interface_edges = interface_edges.filter(entry => {
    selection.nodes[entry.0] && selection.nodes[entry.2]
  })
  filter_world_items(prepared, arena, tables, selection, errors)
  if !errors.is_empty() {
    return Err(dependency_chains(prepared, package_edges, errors))
  }
  encoded_merge_models(arena, selected_models, input_ranks) catch {
    Unsupported(message) =>
      return Err([
        error_at(
          prepared.origins[prepared.roots[0]].location,
          "WIT-B002",
          message,
        ),
      ])
    Invalid(message) =>
      return Err([
        error_at(
          prepared.origins[prepared.roots[0]].location,
          "WIT-B004",
          message,
        ),
      ])
  }
  expand_worlds(prepared, tables, includes, arena, interface_edges, errors)
  verify_accessor_pairs(arena, tables, errors)
  let worlds : Array[ResolvedWorld] = []
  for id, node in tree.nodes {
    if selection.nodes[id] &&
      node.data is World(name~, ..) &&
      tables.imports.get(id) is Some(imports) {
      worlds.push({
        id,
        name,
        package_identity: prepared.identities[prepared.node_packages[id]],
        stability: stabilities[id].value,
        imports: ordered_world_items(imports, arena),
        exports: ordered_world_items(tables.exports[id], arena),
        location: prepared.origins[id].location,
      })
    }
  }
  if errors.is_empty() {
    for id, origin in prepared.origins {
      if origin.node is Some(original) {
        selection_output[(origin.location.source, original)] = selection.nodes[id]
      }
    }
    let first = prepared.documents[0]
    let functions = ReadOnlyArray::from_array(
      arena.function_order.map(id => arena.functions[id]),
    )
    let interfaces = ReadOnlyArray::from_array(
      arena.interface_order.map(id => arena.interfaces[id]),
    )
    let world_dependencies : Map[Int32, Array[Int32]] = Map([])
    for (owner, target, _, _) in includes {
      let edges = world_dependencies
        .get(owner)
        .unwrap_or_else(() => {
          let edges = []
          world_dependencies[owner] = edges
          edges
        })
      edges.push(target)
    }
    let world_dependency_order = []
    let ordered_worlds : Map[Int32, Bool] = Map([])
    for world in worlds {
      let pending = [(world.id, false)]
      while pending.pop() is Some((id, finish)) {
        if ordered_worlds.contains(id) {
          continue
        }
        if finish {
          ordered_worlds[id] = true
          world_dependency_order.push(id)
          continue
        }
        pending.push((id, true))
        if world_dependencies.get(id) is Some(edges) {
          for dependency in edges.rev() {
            pending.push((dependency, false))
          }
        }
      }
    }
    let model : SemanticModel = {
      bindings: ReadOnlyArray::from_array(
        bindings.filter(b => {
          selection.nodes[b.node] && selection.nodes[b.target]
        }),
      ),
      resolved_types: ReadOnlyArray::from_array(
        arena.type_order.map(id => arena.types[id]),
      ),
      package_identity: prepared.identities[0],
      resolved_worlds: ReadOnlyArray::from_array(worlds),
      world_dependency_order: ReadOnlyArray::from_array(world_dependency_order),
      resolved_interfaces: interfaces,
      resolved_functions: functions,
    }
    Ok({
      model,
      root_location: {
        source: first.id,
        position: SourceSpan(first.ast.nodes[first.ast.nodes.length() - 1].span),
      },
      documents: prepared.documents,
      encoded_packages: [],
      packages: prepared.identities,
      origins: ReadOnlyArray::from_array(arena.origins),
    })
  } else {
    Err(dependency_chains(prepared, package_edges, errors))
  }
}
