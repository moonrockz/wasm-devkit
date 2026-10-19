///|
priv enum CompatibilityWork {
  CompareItem(ItemKind, ItemKind, Bool, String)
  CompareType(Int32, Int32, Bool, String)
  CompareResource(Int32, Int32, Bool, String)
}

///|
priv struct ResourceConstraint {
  actual : Int32
  expected : Int32
  node : Int32
  context : String
}

///|
fn type_description(kind : TypeKind) -> String {
  match kind {
    Scalar(name) => name
    Alias(_) => "alias"
    Resource(_) => "resource"
    Own(_) => "owned resource"
    Borrow(_) => "borrowed resource"
    List(_) => "list"
    FixedList(_, _) => "fixed list"
    Map(_, _) => "map"
    Tuple(_) => "tuple"
    Option(_) => "option"
    Result(_, _) => "result"
    Future(_) => "future"
    Stream(_) => "stream"
    Record(_) => "record"
    Flags(_) => "flags"
    Enum(_) => "enum"
    Variant(_) => "variant"
    Function(_, _, _) => "function"
    Interface(_, _, _) => "interface"
    World(_, _, _, _) => "component"
  }
}

///|
fn Check::compatibility_problem(
  self : Check,
  node : Int32,
  actual : Int32,
  expected : Int32,
  context : String,
  message : String,
) -> Diagnostic {
  let problem = self.problem(node, "WAC-C005", context + ": " + message)
  {
    ..problem,
    related: [
      {
        location: self.types[expected].location,
        message: "expected type declared here",
      },
      {
        location: self.types[actual].location,
        message: "provided type declared here",
      },
    ],
  }
}

///|
fn Check::unalias(self : Check, id : Int32) -> Int32 {
  let mut current = id
  for _ in 0..<self.types.length() {
    match self.types[current].kind {
      Alias(next) => current = next
      _ => break
    }
  }
  current
}

///|
fn compatibility_optional(
  work : Array[CompatibilityWork],
  a : Int32?,
  b : Int32?,
  reverse : Bool,
  context : String,
) -> Bool {
  match (a, b) {
    (Some(a), Some(b)) => {
      work.push(CompareType(a, b, reverse, context))
      true
    }
    (None, None) => true
    _ => false
  }
}

///|
fn compatibility_externs(
  work : Array[CompatibilityWork],
  actual : ReadOnlyArray[Extern],
  expected : ReadOnlyArray[Extern],
  reverse : Bool,
  importing : Bool,
) -> String? {
  let flipped = reverse != importing
  let required = if flipped { actual } else { expected }
  let provided = if flipped { expected } else { actual }
  let next : Array[CompatibilityWork] = []
  for requirement in required {
    let mut found : ItemKind? = None
    for candidate in provided {
      if candidate.name == requirement.name {
        found = Some(candidate.kind)
        break
      }
    }
    guard found is Some(kind) else {
      return Some(
        "missing " +
        (if importing { "import" } else { "export" }) +
        " `" +
        requirement.name +
        "`",
      )
    }
    let (a, b) = if flipped {
      (requirement.kind, kind)
    } else {
      (kind, requirement.kind)
    }
    next.push(
      CompareItem(
        a,
        b,
        flipped,
        (if importing { "import" } else { "export" }) +
        " `" +
        requirement.name +
        "`",
      ),
    )
  }
  for i = next.length() - 1; i >= 0; i = i - 1 {
    work.push(next[i])
  }
  None
}

///|
// Structural compatibility follows the pinned WAC rules. Resource equations
// are deferred until every argument has bound its imported resource types.
fn Check::compatible(
  self : Check,
  node : Int32,
  actual : LocalItem,
  expected : ItemKind,
  bindings : Map[Int32, Int32],
  constraints : Array[ResourceConstraint],
) -> Unit raise SemanticFailure {
  let actual_resources : ReadOnlyArray[ResourceBinding] = match actual.value {
    Some(value) => self.composition_nodes[value].resources
    None => []
  }
  let work = [
    CompatibilityWork::CompareItem(
      actual.kind,
      expected,
      false,
      "instantiation argument",
    ),
  ]
  let seen : Map[(Int32, Int32, Bool), Bool] = Map([])
  let mut remaining = 1000000
  while work.pop() is Some(current) {
    remaining -= 1
    if remaining < 0 {
      raise Problem(
        self.problem(
          node, "WAC-C006", "type compatibility exceeds the verification work limit",
        ),
      )
    }
    match current {
      CompareItem(a, b, reverse, context) => {
        let same_sort = match (a, b) {
          (Type(_), Type(_))
          | (Function(_), Function(_))
          | (Instance(_), Instance(_))
          | (Component(_), Component(_)) => true
          _ => false
        }
        let ai = binary_kind_id(a)
        let bi = binary_kind_id(b)
        if !same_sort {
          raise Problem(
            self.compatibility_problem(
              node, ai, bi, context, "provided item kind does not match the expected item kind",
            ),
          )
        }
        if a is Type(_) &&
          self.resource_root(ai) is Some(ar) &&
          self.resource_root(bi) is Some(br) {
          work.push(CompareResource(ar, br, true, context))
        } else {
          work.push(CompareType(ai, bi, reverse, context))
        }
      }
      CompareResource(a, b, bind, context) => {
        guard self.resource_root(a) is Some(a) &&
          self.resource_root(b) is Some(b) else {
          raise Problem(
            self.compatibility_problem(
              node, a, b, context, "invalid resource identity",
            ),
          )
        }
        if self.types[a].name != self.types[b].name {
          raise Problem(
            self.compatibility_problem(
              node, a, b, context, "resource names do not match",
            ),
          )
        }
        guard resource_binding(actual_resources, a) is Some(identity) else {
          raise Problem(
            self.compatibility_problem(
              node, a, b, context, "provided resource has no runtime identity",
            ),
          )
        }
        if bind {
          if bindings.get(b) is Some(previous) && previous != identity {
            raise Problem(
              self.compatibility_problem(
                node, a, b, context, "resource types are not the same",
              ),
            )
          }
          bindings[b] = identity
        } else {
          constraints.push({ actual: identity, expected: b, node, context, })
        }
      }
      CompareType(a, b, reverse, context) => {
        let a = self.unalias(a)
        let b = self.unalias(b)
        let key = (a, b, reverse)
        if seen.contains(key) {
          continue
        }
        seen[key] = true
        let ak = self.types[a].kind
        let bk = self.types[b].kind
        let mut mismatch : String? = None
        match (ak, bk) {
          (Scalar(a), Scalar(b)) =>
            if a != b {
              mismatch = Some("expected `" + b + "`, found `" + a + "`")
            }
          (Resource(_), Resource(_)) =>
            work.push(CompareResource(a, b, false, context))
          (Own(a), Own(b)) | (Borrow(a), Borrow(b)) =>
            work.push(CompareResource(a, b, false, context))
          (List(a), List(b)) | (Option(a), Option(b)) =>
            work.push(CompareType(a, b, reverse, context))
          (FixedList(a, al), FixedList(b, bl)) => {
            if al != bl {
              mismatch = Some("fixed-list lengths differ")
            }
            work.push(CompareType(a, b, reverse, context))
          }
          (Map(ak, av), Map(bk, bv)) => {
            work.push(CompareType(av, bv, reverse, "map value"))
            work.push(CompareType(ak, bk, reverse, "map key"))
          }
          (Tuple(a), Tuple(b)) =>
            if a.length() != b.length() {
              mismatch = Some("tuple lengths differ")
            } else {
              for i = a.length() - 1; i >= 0; i = i - 1 {
                work.push(CompareType(a[i], b[i], reverse, "tuple element"))
              }
            }
          (Result(ao, ae), Result(bo, be)) =>
            if !compatibility_optional(work, ae, be, reverse, "result error") ||
              !compatibility_optional(work, ao, bo, reverse, "result value") {
              mismatch = Some("result payload presence differs")
            }
          (Future(a), Future(b)) | (Stream(a), Stream(b)) =>
            if !compatibility_optional(work, a, b, reverse, context) {
              mismatch = Some("payload presence differs")
            }
          (Flags(a), Flags(b)) | (Enum(a), Enum(b)) =>
            if a != b {
              mismatch = Some("ordered names differ")
            }
          (Record(a), Record(b)) =>
            if a.length() != b.length() {
              mismatch = Some("record field counts differ")
            } else {
              for i = a.length() - 1; i >= 0; i = i - 1 {
                if a[i].name != b[i].name {
                  mismatch = Some("ordered record field names differ")
                }
                work.push(
                  CompareType(
                    a[i].ty,
                    b[i].ty,
                    reverse,
                    "record field `" + b[i].name + "`",
                  ),
                )
              }
            }
          (Variant(a), Variant(b)) =>
            if a.length() != b.length() {
              mismatch = Some("variant case counts differ")
            } else {
              for i = a.length() - 1; i >= 0; i = i - 1 {
                if a[i].name != b[i].name {
                  mismatch = Some("ordered variant case names differ")
                }
                if !compatibility_optional(
                    work,
                    a[i].payload,
                    b[i].payload,
                    reverse,
                    "variant case `" + b[i].name + "`",
                  ) {
                  mismatch = Some("variant payload presence differs")
                }
              }
            }
          (Function(ap, ar, aa), Function(bp, br, ba)) => {
            if aa != ba {
              mismatch = Some("async and synchronous functions differ")
            }
            if ap.length() != bp.length() {
              mismatch = Some("function parameter counts differ")
            } else {
              if !compatibility_optional(
                  work, ar, br, reverse, "function result",
                ) {
                mismatch = Some("function result presence differs")
              }
              for i = ap.length() - 1; i >= 0; i = i - 1 {
                if ap[i].name != bp[i].name {
                  mismatch = Some(
                    "expected parameter `" +
                    bp[i].name +
                    "`, found `" +
                    ap[i].name +
                    "`",
                  )
                }
                work.push(
                  CompareType(
                    ap[i].ty,
                    bp[i].ty,
                    reverse,
                    "function parameter `" + bp[i].name + "`",
                  ),
                )
              }
            }
          }
          (Interface(_, _, a), Interface(_, _, b)) =>
            mismatch = compatibility_externs(work, a, b, reverse, false)
          (World(_, _, ai, ae), World(_, _, bi, be)) => {
            mismatch = compatibility_externs(work, ae, be, reverse, false)
            if mismatch is None {
              mismatch = compatibility_externs(work, ai, bi, reverse, true)
            }
          }
          _ =>
            mismatch = Some(
              "expected " +
              type_description(bk) +
              ", found " +
              type_description(ak),
            )
        }
        if mismatch is Some(message) {
          raise Problem(
            self.compatibility_problem(node, a, b, context, message),
          )
        }
      }
    }
  }
}
