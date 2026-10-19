///|
// Values are resolved postorder. Cached borrow information is complete when
// each type is allocated, because names only refer to earlier declarations.
fn Check::value(
  self : Check,
  root : Int32,
  scope : Int32,
) -> Int32 raise SemanticFailure {
  let pending = [(root, false)]
  while pending.pop() is Some((node, finish)) {
    if self.values[node] >= 0 {
      continue
    }
    let data = self.tree.nodes[node].data
    if !finish {
      let children : ReadOnlyArray[Int32] = match data {
        ListType(element~) => [element]
        TupleType(elements~) => {
          guard !elements.is_empty() else {
            raise Problem(
              self.problem(
                node, "WAC-S001", "tuple requires at least one element",
              ),
            )
          }
          elements
        }
        OptionType(payload~) => [payload]
        ResultType(ok~, error~) => {
          let children = []
          if ok is Some(id) {
            children.push(id)
          }
          if error is Some(id) {
            children.push(id)
          }
          ReadOnlyArray::from_array(children)
        }
        FutureType(payload~) | StreamType(payload~) =>
          match payload {
            None => []
            Some(id) => [id]
          }
        PrimitiveType(_) | NamedType(_) | BorrowType(_) => []
        NamedResults(_) =>
          raise Problem(
            self.problem(
              node, "WAC-S003", "named function results are outside the pinned WAC semantic profile",
            ),
          )
        _ =>
          raise Problem(self.problem(node, "WAC-S001", "expected a value type"))
      }
      pending.push((node, true))
      for i = children.length() - 1; i >= 0; i = i - 1 {
        pending.push((children[i], false))
      }
      continue
    }
    let kind : TypeKind = match data {
      PrimitiveType(name~) => {
        guard [
          "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "f32", "f64",
          "char", "string", "error-context",
        ].contains(name) else {
          raise Problem(
            self.problem(
              node,
              "WAC-S001",
              "unknown primitive type `" + name + "`",
            ),
          )
        }
        Scalar(name)
      }
      NamedType(name~) => {
        let item = self.lookup(scope, node, name)
        guard item.kind is Type(id) else {
          raise Problem(
            self.problem(
              node,
              "WAC-S005",
              "`" + name + "` is not a value type",
              first=Some(item.node),
            ),
          )
        }
        if self.types[id].kind is Resource(_) {
          Own(id)
        } else {
          guard value_kind(self.types[id].kind) else {
            raise Problem(
              self.problem(
                node,
                "WAC-S005",
                "`" + name + "` is not a value type",
                first=Some(item.node),
              ),
            )
          }
          self.values[node] = id
          continue
        }
      }
      BorrowType(resource~) => {
        guard self.tree.nodes[resource].data is NamedType(name~) else {
          raise Problem(
            self.problem(
              resource, "WAC-S001", "borrow target must be a named resource",
            ),
          )
        }
        let item = self.lookup(scope, resource, name)
        guard item.kind is Type(id) && self.types[id].kind is Resource(_) else {
          raise Problem(
            self.problem(
              resource,
              "WAC-S005",
              "`" + name + "` is not a resource type",
              first=Some(item.node),
            ),
          )
        }
        Borrow(id)
      }
      ListType(element~) => List(self.values[element])
      TupleType(elements~) => Tuple(elements.map(id => self.values[id]))
      OptionType(payload~) => Option(self.values[payload])
      ResultType(ok~, error~) =>
        Result(ok.map(id => self.values[id]), error.map(id => self.values[id]))
      FutureType(payload~) => Future(payload.map(id => self.values[id]))
      StreamType(payload~) => Stream(payload.map(id => self.values[id]))
      _ =>
        raise Problem(self.problem(node, "WAC-S001", "invalid value type role"))
    }
    self.values[node] = self.add_type(node, kind)
  }
  self.values[root]
}

///|
fn Check::parameters(
  self : Check,
  node : Int32,
  params : ReadOnlyArray[Int32],
  scope : Int32,
  receiver~ : Int32? = None,
) -> ReadOnlyArray[TypeMember] raise SemanticFailure {
  let members = []
  let seen : Map[String, Int32] = Map([])
  if receiver is Some(resource) {
    seen["self"] = node
    members.push({
      name: "self",
      ty: self.add_type(node, Borrow(resource)),
      location: self.location(node),
    })
  }
  for parameter in params {
    guard self.tree.nodes[parameter].data is Parameter(name~, ty~) else {
      raise Problem(self.problem(parameter, "WAC-S001", "expected a parameter"))
    }
    self.name(parameter, name)
    let ty = self.value(ty, scope)
    if seen.get(name) is Some(first) {
      raise Problem(
        self.problem(
          parameter,
          "WAC-S004",
          "duplicate parameter `" + name + "`",
          first=Some(first),
        ),
      )
    }
    seen[name] = parameter
    members.push({ name, ty, location: self.location(parameter), })
  }
  ReadOnlyArray::from_array(members)
}

///|
fn Check::signature(
  self : Check,
  node : Int32,
  scope : Int32,
  receiver~ : Int32? = None,
) -> Int32 raise SemanticFailure {
  guard self.tree.nodes[node].data is Signature(params~, result~, asynchronous~) else {
    raise Problem(
      self.problem(node, "WAC-S001", "expected a function signature"),
    )
  }
  let params = self.parameters(node, params, scope, receiver~)
  let result = result.map(id => {
    let ty = self.value(id, scope)
    guard !self.borrowed[ty] else {
      raise Problem(
        self.problem(
          id, "WAC-S006", "function results cannot contain a borrowed resource",
        ),
      )
    }
    ty
  })
  self.add_type(node, Function(params, result, asynchronous))
}

///|
fn Check::function_ref(
  self : Check,
  node : Int32,
  scope : Int32,
) -> Int32 raise SemanticFailure {
  match self.tree.nodes[node].data {
    Signature(..) => self.signature(node, scope)
    NamedType(name~) => {
      let kind = self.lookup(scope, node, name).kind
      match kind {
        Function(id) => id
        Type(id) if self.types[id].kind is Function(_, _, _) => id
        _ =>
          raise Problem(
            self.problem(
              node,
              "WAC-S005",
              "`" + name + "` is not a function type",
            ),
          )
      }
    }
    _ =>
      raise Problem(self.problem(node, "WAC-S001", "expected a function type"))
  }
}

///|
fn Check::type_alias(
  self : Check,
  node : Int32,
  scope : Int32,
  name : String,
  target : Int32,
) -> Int32 raise SemanticFailure {
  let kind : TypeKind = match self.tree.nodes[target].data {
    Signature(..) => {
      let id = self.signature(target, scope)
      self.types[id].kind
    }
    NamedType(name=target_name) => {
      let item = self.lookup(scope, target, target_name)
      match item.kind {
        Function(id) => self.types[id].kind
        Type(id) =>
          match self.types[id].kind {
            Resource(_) => Resource(Some(id))
            Function(_, _, _) => self.types[id].kind
            Interface(_, _, _) | World(_, _, _, _) =>
              raise Problem(
                self.problem(
                  target, "WAC-S005", "cannot alias an interface or world type",
                ),
              )
            _ => Alias(id)
          }
        _ =>
          raise Problem(
            self.problem(target, "WAC-S005", "invalid type alias target"),
          )
      }
    }
    _ => Alias(self.value(target, scope))
  }
  self.add_type(node, kind, name=Some(name))
}

///|
fn Check::aggregate(
  self : Check,
  node : Int32,
  scope : Int32,
) -> Int32 raise SemanticFailure {
  let (name, children) = match self.tree.nodes[node].data {
    Record(name~, fields~) => (name, fields)
    Flags(name~, cases~) | Enum(name~, cases~) | Variant(name~, cases~) =>
      (name, cases)
    _ =>
      raise Problem(
        self.problem(node, "WAC-S001", "expected aggregate declaration"),
      )
  }
  self.name(node, name)
  guard !children.is_empty() else {
    raise Problem(
      self.problem(node, "WAC-S001", "aggregate requires at least one member"),
    )
  }
  let seen : Map[String, Int32] = Map([])
  let fields = []
  let cases = []
  let names = []
  for child in children {
    let member_name = match
      (self.tree.nodes[node].data, self.tree.nodes[child].data) {
      (Record(..), Field(name~, ty~)) => {
        let ty = self.value(ty, scope)
        fields.push({ name, ty, location: self.location(child), })
        name
      }
      (Variant(..), Case(name~, payload~)) => {
        let payload = payload.map(id => self.value(id, scope))
        cases.push({ name, payload, location: self.location(child), })
        name
      }
      (Flags(..) | Enum(..), Case(name~, payload=None)) => {
        names.push(name)
        name
      }
      _ =>
        raise Problem(
          self.problem(child, "WAC-S001", "invalid aggregate member role"),
        )
    }
    self.name(child, member_name)
    if seen.get(member_name) is Some(first) {
      raise Problem(
        self.problem(
          child,
          "WAC-S004",
          "duplicate aggregate member `" + member_name + "`",
          first=Some(first),
        ),
      )
    }
    seen[member_name] = child
  }
  let kind : TypeKind = match self.tree.nodes[node].data {
    Record(..) => Record(ReadOnlyArray::from_array(fields))
    Flags(..) => Flags(ReadOnlyArray::from_array(names))
    Enum(..) => Enum(ReadOnlyArray::from_array(names))
    _ => Variant(ReadOnlyArray::from_array(cases))
  }
  self.add_type(node, kind, name=Some(name))
}
