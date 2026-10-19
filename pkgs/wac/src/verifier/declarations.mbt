///|
fn Check::declare_type(
  self : Check,
  node : Int32,
  scope : Int32,
  importing : Bool,
) -> Unit raise SemanticFailure {
  let (name, ty) = match self.tree.nodes[node].data {
    Alias(name~, ty~) => (name, self.type_alias(node, scope, name, ty))
    Record(name~, ..)
    | Flags(name~, ..)
    | Enum(name~, ..)
    | Variant(name~, ..) => (name, self.aggregate(node, scope))
    Resource(name~, methods~, has_body~) if scope != 0 => {
      guard has_body || methods.is_empty() else {
        raise Problem(
          self.problem(node, "WAC-S001", "resource without a body has methods"),
        )
      }
      let resource = self.add_type(node, Resource(None), name=Some(name))
      self.bind(scope, node, name, {
        kind: Type(resource),
        node,
        external_name: None,
        value: None,
      })
      self.extern_item(scope, node, name, Type(resource), importing)
      let seen : Map[String, Int32] = Map([])
      for method_node in methods {
        let (method_name, external_name, ty) = match
          self.tree.nodes[method_node].data {
          Constructor(params~) => {
            let params = self.parameters(method_node, params, scope)
            let result = self.add_type(method_node, Own(resource))
            (
              "",
              "[constructor]" + name,
              self.add_type(method_node, Function(params, Some(result), false)),
            )
          }
          Function(name=method_name, signature~, is_static~) => {
            self.name(method_node, method_name)
            let ty = self.signature(
              signature,
              scope,
              receiver=if is_static { None } else { Some(resource) },
            )
            (
              method_name,
              (if is_static { "[static]" } else { "[method]" }) +
              name +
              "." +
              method_name,
              ty,
            )
          }
          _ =>
            raise Problem(
              self.problem(
                method_node, "WAC-S001", "invalid resource method role",
              ),
            )
        }
        if seen.get(method_name) is Some(first) {
          raise Problem(
            self.problem(
              method_node,
              "WAC-S004",
              "duplicate resource method or constructor",
              first=Some(first),
            ),
          )
        }
        seen[method_name] = method_node
        self.extern_item(
          scope,
          method_node,
          external_name,
          Function(ty),
          importing,
        )
      }
      return
    }
    _ =>
      raise Problem(
        self.problem(
          node, "WAC-S001", "declaration is not allowed in this scope",
        ),
      )
  }
  self.bind(scope, node, name, {
    kind: Type(ty),
    node,
    external_name: None,
    value: None,
  })
  self.extern_item(scope, node, name, Type(ty), importing)
}

///|
fn Check::qualified(self : Check, name : String) -> String {
  self.package_name +
  "/" +
  name +
  self.package_version.map(version => "@" + version).unwrap_or("")
}

///|
fn Check::local_path(
  self : Check,
  node : Int32,
) -> LocalItem raise SemanticFailure {
  guard self.tree.nodes[node].data is Path(namespaces~, segments~, version~) else {
    raise Problem(
      self.problem(node, "WAC-S001", "expected an interface or world path"),
    )
  }
  if !namespaces.is_empty() {
    return self.package_path(node, namespaces, segments, version)
  }
  guard segments.length() == 1 && version is None else {
    raise Problem(self.problem(node, "WAC-S001", "invalid local path"))
  }
  self.lookup(0, node, segments[0])
}

///|
fn Check::use_types(
  self : Check,
  node : Int32,
  scope : Int32,
  importing : Bool,
) -> Unit raise SemanticFailure {
  guard self.tree.nodes[node].data is Use(path~, names~) else {
    raise Problem(self.problem(node, "WAC-S001", "expected a use declaration"))
  }
  let item = self.local_path(path)
  guard item.kind is Type(interface) &&
    self.types[interface].kind is Interface(_, _, exports) else {
    raise Problem(
      self.problem(path, "WAC-S005", "use requires an interface type"),
    )
  }
  guard !names.is_empty() else {
    raise Problem(
      self.problem(node, "WAC-S001", "use requires at least one selector"),
    )
  }
  for selector in names {
    guard self.tree.nodes[selector].data is Rename(name~, renamed~) else {
      raise Problem(self.problem(selector, "WAC-S001", "invalid use selector"))
    }
    self.name(selector, name)
    let local_name = renamed.unwrap_or(name)
    self.name(selector, local_name)
    let mut selected = None
    for exported in exports {
      if exported.name == name {
        selected = Some(exported)
        break
      }
    }
    guard selected is Some(selected) else {
      raise Problem(
        self.problem(
          selector,
          "WAC-S005",
          "interface has no type `" + name + "`",
          first=Some(item.node),
        ),
      )
    }
    guard selected.kind is Type(ty) &&
      (value_kind(self.types[ty].kind) || self.types[ty].kind is Resource(_)) else {
      raise Problem(
        self.problem(
          selector,
          "WAC-S005",
          "use requires a value or resource type",
          first=Some(item.node),
        ),
      )
    }
    self.extern_item(scope, selector, local_name, Type(ty), importing)
    self.bind(scope, selector, local_name, {
      kind: Type(ty),
      node: selector,
      external_name: None,
      value: None,
    })
    self.scopes[scope].uses.push({
      name: local_name,
      original_name: name,
      interface,
      ty,
      location: self.location(selector),
    })
  }
}

///|
fn Check::interface_type(
  self : Check,
  node : Int32,
  named : Bool,
) -> Int32 raise SemanticFailure {
  guard self.tree.nodes[node].data is Interface(name~, items~) else {
    raise Problem(self.problem(node, "WAC-S001", "expected an interface"))
  }
  if named {
    self.name(node, name)
  } else {
    guard name.is_empty() else {
      raise Problem(
        self.problem(
          node, "WAC-S001", "inline interface must not have a declaration name",
        ),
      )
    }
  }
  let scope = self.scopes.length()
  self.scopes.push(Scope::new())
  for item in items {
    match self.tree.nodes[item].data {
      Use(..) => self.use_types(item, scope, false)
      Function(name~, signature~, is_static~) => {
        self.name(item, name)
        guard !is_static else {
          raise Problem(
            self.problem(
              item, "WAC-S001", "static functions require a resource",
            ),
          )
        }
        let ty = self.function_ref(signature, scope)
        // Interface functions are exports, not local type bindings.
        self.extern_item(scope, item, name, Function(ty), false)
      }
      _ => self.declare_type(item, scope, false)
    }
  }
  let scope = self.scopes[scope]
  self.add_type(
    node,
    Interface(
      if named {
        Some(self.qualified(name))
      } else {
        None
      },
      ReadOnlyArray::from_array(scope.uses),
      ReadOnlyArray::from_array(scope.exports),
    ),
    name=if named { Some(name) } else { None },
  )
}

///|
fn Check::world_extern(
  self : Check,
  node : Int32,
  scope : Int32,
) -> Unit raise SemanticFailure {
  let (name, target, importing) = match self.tree.nodes[node].data {
    WorldImport(name~, target~) => (name, target, true)
    WorldExport(name~, target~) => (name, target, false)
    _ =>
      raise Problem(
        self.problem(node, "WAC-S001", "expected a world import or export"),
      )
  }
  let (name, kind) = match name {
    None => {
      let item = self.local_path(target)
      guard item.kind is Type(ty) &&
        self.types[ty].kind is Interface(Some(name), _, _) else {
        raise Problem(
          self.problem(
            target, "WAC-S005", "unnamed world item requires a named interface",
          ),
        )
      }
      (name, ItemKind::Instance(ty))
    }
    Some(name) => {
      self.name(node, name)
      let kind : ItemKind = match self.tree.nodes[target].data {
        Signature(..) => Function(self.signature(target, scope))
        Interface(..) => Instance(self.interface_type(target, false))
        NamedType(name~) => {
          let item = self.lookup(scope, target, name, root_fallback=true)
          guard item.kind is Type(ty) else {
            raise Problem(
              self.problem(
                target, "WAC-S005", "world item requires a function or interface type",
              ),
            )
          }
          match self.types[ty].kind {
            Function(_, _, _) => Function(ty)
            Interface(_, _, _) => Instance(ty)
            _ =>
              raise Problem(
                self.problem(
                  target, "WAC-S005", "world item requires a function or interface type",
                ),
              )
          }
        }
        _ =>
          raise Problem(
            self.problem(target, "WAC-S001", "invalid world extern type"),
          )
      }
      (name, kind)
    }
  }
  self.extern_item(scope, node, name, kind, importing)
}

///|
fn Check::include_world(
  self : Check,
  node : Int32,
  scope : Int32,
) -> Unit raise SemanticFailure {
  guard self.tree.nodes[node].data is Include(path~, renames~) else {
    raise Problem(self.problem(node, "WAC-S001", "expected a world include"))
  }
  let replacements : Map[String, (String, Int32)] = Map([])
  for rename in renames {
    guard self.tree.nodes[rename].data
      is Rename(name~, renamed=Some(replacement)) else {
      raise Problem(
        self.problem(
          rename, "WAC-S001", "include rename requires a target name",
        ),
      )
    }
    self.name(rename, name)
    self.name(rename, replacement)
    if replacements.get(name) is Some((_, first)) {
      raise Problem(
        self.problem(
          rename,
          "WAC-S004",
          "duplicate include selector `" + name + "`",
          first=Some(first),
        ),
      )
    }
    replacements[name] = (replacement, rename)
  }
  let item = self.local_path(path)
  let ty = match item.kind {
    Type(ty) | Component(ty) => ty
    _ =>
      raise Problem(
        self.problem(path, "WAC-S005", "include requires a world type"),
      )
  }
  guard self.types[ty].kind is World(_, _, imports, exports) else {
    raise Problem(
      self.problem(path, "WAC-S005", "include requires a world type"),
    )
  }
  for (items, importing) in [(imports, true), (exports, false)] {
    for item in items {
      let seen = if importing {
        self.scopes[scope].import_nodes
      } else {
        self.scopes[scope].export_nodes
      }
      if item.name.contains(":") {
        if !seen.contains(item.name) {
          self.extern_item(scope, node, item.name, item.kind, importing)
        }
      } else {
        let (name, at) = replacements
          .get(item.name)
          .unwrap_or((item.name, node))
        replacements.remove(item.name) |> ignore
        self.extern_item(scope, at, name, item.kind, importing)
      }
    }
  }
  // Check missing selectors in source order, independent of map iteration.
  for rename in renames {
    if self.tree.nodes[rename].data is Rename(name~, ..) &&
      replacements.contains(name) {
      raise Problem(
        self.problem(
          rename,
          "WAC-S005",
          "included world has no replaceable item `" + name + "`",
          first=Some(item.node),
        ),
      )
    }
  }
}

///|
fn Check::world_type(self : Check, node : Int32) -> Int32 raise SemanticFailure {
  guard self.tree.nodes[node].data is World(name~, items~) else {
    raise Problem(self.problem(node, "WAC-S001", "expected a world"))
  }
  self.name(node, name)
  let scope = self.scopes.length()
  self.scopes.push(Scope::new())
  let includes = []
  for item in items {
    match self.tree.nodes[item].data {
      Include(..) => includes.push(item)
      Use(..) => self.use_types(item, scope, true)
      WorldImport(..) | WorldExport(..) => self.world_extern(item, scope)
      _ => self.declare_type(item, scope, true)
    }
  }
  for included_node in includes {
    self.include_world(included_node, scope)
  }
  let scope = self.scopes[scope]
  self.add_type(
    node,
    World(
      Some(self.qualified(name)),
      ReadOnlyArray::from_array(scope.uses),
      ReadOnlyArray::from_array(scope.imports),
      ReadOnlyArray::from_array(scope.exports),
    ),
    name=Some(name),
  )
}

///|
fn Check::external_name(
  self : Check,
  node : Int32,
  importing : Bool,
) -> String raise SemanticFailure {
  guard self.tree.nodes[node].data is Name(value~, quoted~) else {
    raise Problem(self.problem(node, "WAC-S001", "expected an external name"))
  }
  if !quoted {
    self.name(node, value)
  }
  guard valid_external_name(value, importing) else {
    raise Problem(
      self.problem(node, "WAC-S005", "invalid external name `" + value + "`"),
    )
  }
  value
}

///|
fn Check::file(self : Check, root : Int32) -> Unit raise SemanticFailure {
  guard self.tree.nodes[root].data
    is File(directive=Some(directive), statements~) else {
    raise Problem(
      self.problem(
        root, "WAC-S001", "missing package directive or invalid file role",
      ),
    )
  }
  guard self.tree.nodes[directive].data is Package(path~, targets~) else {
    raise Problem(
      self.problem(directive, "WAC-S001", "expected a package directive"),
    )
  }
  guard self.tree.nodes[path].data is Path(namespaces~, segments~, version~) &&
    !namespaces.is_empty() &&
    segments.length() == 1 else {
    raise Problem(self.problem(path, "WAC-S001", "invalid package identity"))
  }
  for part in namespaces {
    self.name(path, part)
  }
  self.name(path, segments[0])
  if version is Some(version) && !semantic_version(version) {
    raise Problem(self.problem(path, "WAC-S001", "invalid package version"))
  }
  self.package_name = namespaces.join(":") + ":" + segments[0]
  self.package_version = version
  guard targets is None else {
    raise Problem(
      self.problem(
        directive, "WAC-S003", "target resolution is not yet supported",
      ),
    )
  }
  for node in statements {
    match self.tree.nodes[node].data {
      Interface(name~, ..) | World(name~, ..) => {
        let ty = if self.tree.nodes[node].data is Interface(..) {
          self.interface_type(node, true)
        } else {
          self.world_type(node)
        }
        self.bind(0, node, name, {
          kind: Type(ty),
          node,
          external_name: None,
          value: None,
        })
        self.extern_item(0, node, name, Type(ty), false)
      }
      Alias(..) | Record(..) | Flags(..) | Enum(..) | Variant(..) =>
        self.declare_type(node, 0, false)
      Import(binding~, renamed~, ty~) => {
        let kind : ItemKind = match self.tree.nodes[ty].data {
          Signature(..) => Function(self.signature(ty, 0))
          Interface(..) => Instance(self.interface_type(ty, false))
          NamedType(name~) => self.lookup(0, ty, name).kind
          Path(..) => self.local_path(ty).kind
          _ =>
            raise Problem(self.problem(ty, "WAC-S001", "invalid import type"))
        }
        let name = match renamed {
          Some(name) => self.external_name(name, true)
          None if self.tree.nodes[ty].data
            is Path(namespaces~, segments~, version~) =>
            namespaces.join(":") +
            ":" +
            segments.join("/") +
            version.map(value => "@" + value).unwrap_or("")
          None =>
            match kind {
              Instance(id) | Component(id) =>
                match self.types[id].kind {
                  Interface(Some(name), _, _) | World(Some(name), _, _, _) =>
                    name
                  _ => binding
                }
              _ => binding
            }
        }
        let kind = self.promote(kind)
        self.extern_item(0, node, name, kind, true)
        self.bind(0, node, binding, {
          kind,
          node,
          external_name: Some(name),
          value: None,
        })
      }
      Let(name~, expression~) => {
        let item = self.expression(expression)
        self.bind(0, node, name, item)
      }
      Export(expression~, renamed~, spread~) => {
        let item = self.expression(expression)
        if spread {
          guard renamed is None else {
            raise Problem(
              self.problem(
                node, "WAC-S001", "export spread cannot have a rename",
              ),
            )
          }
          self.export_spread(node, expression, item)
          continue
        }
        let inferred = match item.kind {
          Instance(ty) =>
            match self.types[ty].kind {
              Interface(Some(name), _, _) => Some(name)
              _ => item.external_name
            }
          _ => item.external_name
        }
        let name = match renamed {
          Some(name) => self.external_name(name, false)
          None =>
            match inferred {
              Some(name) => name
              None =>
                raise Problem(
                  self.problem(
                    node, "WAC-S005", "export needs an explicit name",
                  ),
                )
            }
        }
        self.export_value(node, name, item)
      }
      _ =>
        raise Problem(
          self.problem(
            node, "WAC-S001", "declaration is not allowed at root scope",
          ),
        )
    }
  }
}

///|
fn semantic_version(version : String) -> Bool {
  let build = version.split("+").to_array()
  guard build.length() <= 2 else { return false }
  let before = build[0].to_owned()
  let dash = before.find("-")
  let core = match dash {
    Some(i) => before[:i].to_owned()
    None => before
  }
  let numbers = core.split(".").to_array()
  guard numbers.length() == 3 else { return false }
  for number in numbers {
    guard !number.is_empty() && !(number.length() > 1 && number.has_prefix("0")) else {
      return false
    }
    let mut value = 0UL
    for c in number {
      guard c >= '0' && c <= '9' else { return false }
      let digit = (c.to_int() - 48).to_uint64()
      guard value <= (18446744073709551615UL - digit) / 10UL else {
        return false
      }
      value = value * 10UL + digit
    }
  }
  let groups = []
  if dash is Some(i) {
    groups.push((before[i + 1:].to_owned(), true))
  }
  if build.length() == 2 {
    groups.push((build[1].to_owned(), false))
  }
  for (group, prerelease) in groups {
    for label in group.split(".") {
      guard !label.is_empty() else { return false }
      let mut numeric = true
      for c in label {
        let digit = c >= '0' && c <= '9'
        guard digit ||
          (c >= 'a' && c <= 'z') ||
          (c >= 'A' && c <= 'Z') ||
          c == '-' else {
          return false
        }
        numeric = numeric && digit
      }
      guard !(prerelease &&
        numeric &&
        label.length() > 1 &&
        label.has_prefix("0")) else {
        return false
      }
    }
  }
  true
}
