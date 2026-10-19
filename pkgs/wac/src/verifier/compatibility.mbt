///|
priv struct ResourceComparison {
  actual : Int32
  expected : Int32
  bind : Bool
  reverse : Bool
  actual_binder : Bool
  expected_binder : Bool
}

///|
// Private evidence from a successful structural comparison. Resource binders
// are separate from handles so implicit imports cannot unify captured values.
priv struct CompatibilityTrace {
  types : Map[Int32, Int32]
  binders : Array[(Int32, Int32)]
  resource_pairs : Array[ResourceComparison]
  mut steps : Int32
}

///|
priv enum CompatibilityWork {
  CompareItem(ItemKind, ItemKind, Bool, String)
  CompareType(Int32, Int32, Bool, String)
  CompareResource(ResourceComparison, String)
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
    Module(_) => "core module"
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
fn Check::compatibility_externs(
  self : Check,
  node : Int32,
  work : Array[CompatibilityWork],
  actual : ReadOnlyArray[Extern],
  expected : ReadOnlyArray[Extern],
  reverse : Bool,
  importing : Bool,
  trace : CompatibilityTrace?,
) -> String? raise SemanticFailure {
  let flipped = reverse != importing
  let required = if flipped { actual } else { expected }
  let provided = if flipped { expected } else { actual }
  if provided.length() > 1000000 || required.length() > 1000000 {
    raise Problem(
      self.problem(
        node, "WAC-C006", "type compatibility exceeds the verification work limit",
      ),
    )
  }
  let indexed : Map[String, ItemKind] = Map([])
  for candidate in provided {
    if trace is Some(trace) {
      trace.steps += 1
      if trace.steps > 1000000 {
        raise Problem(
          self.problem(
            node, "WAC-C006", "type compatibility exceeds the verification work limit",
          ),
        )
      }
    }
    if !indexed.contains(candidate.name) {
      indexed[candidate.name] = candidate.kind
    }
  }
  let next : Array[CompatibilityWork] = []
  for requirement in required {
    if trace is Some(trace) {
      trace.steps += 1
      if trace.steps > 1000000 {
        raise Problem(
          self.problem(
            node, "WAC-C006", "type compatibility exceeds the verification work limit",
          ),
        )
      }
    }
    let found = indexed.get(requirement.name)
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
  reverse~ : Bool = false,
  nominal~ : Bool = true,
  resources~ : ReadOnlyArray[ResourceBinding]? = None,
  trace~ : CompatibilityTrace? = None,
) -> Unit raise SemanticFailure {
  let actual_resources : ReadOnlyArray[ResourceBinding] = match resources {
    Some(resources) => resources
    None =>
      match actual.value {
        Some(value) => self.composition_nodes[value].resources
        None => []
      }
  }
  let work = [
    CompatibilityWork::CompareItem(
      actual.kind,
      expected,
      reverse,
      "instantiation argument",
    ),
  ]
  let seen : Map[(Int32, Int32, Bool), Bool] = Map([])
  let mut remaining = 1000000
  while work.pop() is Some(current) {
    remaining -= 1
    if trace is Some(trace) {
      trace.steps += 1
    }
    if remaining < 0 ||
      trace.map(trace => trace.steps > 1000000).unwrap_or(false) {
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
          | (Component(_), Component(_))
          | (Module(_), Module(_))
          | (Value(_), Value(_)) => true
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
          if trace is Some(trace) {
            trace.types[bi] = ai
            if self.types[ai].kind is Resource(None) &&
              self.types[bi].kind is Resource(None) {
              trace.binders.push((ai, bi))
            }
          }
          work.push(
            CompareResource(
              {
                actual: ar,
                expected: br,
                bind: true,
                reverse,
                actual_binder: self.types[ai].kind is Resource(None),
                expected_binder: self.types[bi].kind is Resource(None),
              },
              context,
            ),
          )
        } else {
          work.push(CompareType(ai, bi, reverse, context))
        }
      }
      CompareResource(pair, context) => {
        let a = pair.actual
        let b = pair.expected
        let bind = pair.bind
        if trace is Some(trace) {
          trace.types[b] = a
        }
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
        if trace is Some(trace) {
          trace.types[b] = a
          trace.resource_pairs.push({ ..pair, actual: a, expected: b, })
        }
        if !nominal {
          continue
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
        if trace is Some(trace) {
          trace.types[b] = a
        }
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
          (Module(a), Module(b)) => {
            let limit = match trace {
              Some(t) => Int32::min(remaining, 1000000 - t.steps)
              None => remaining
            }
            let (actual, expected) = if reverse { (b, a) } else { (a, b) }
            match
              @core_types.check_module_subtype(
                actual,
                expected,
                work_limit=limit,
              ) {
              Ok(rest) => {
                let used = limit - rest
                remaining -= used
                if trace is Some(t) {
                  t.steps += used
                }
              }
              Err(Mismatch(message)) => mismatch = Some(message)
              Err(WorkLimit) =>
                raise Problem(
                  self.problem(
                    node, "WAC-C006", "core module compatibility exceeds the verification work limit",
                  ),
                )
            }
          }
          (Scalar(a), Scalar(b)) =>
            if a != b {
              mismatch = Some("expected `" + b + "`, found `" + a + "`")
            }
          (Resource(_), Resource(_)) =>
            work.push(
              CompareResource(
                {
                  actual: a,
                  expected: b,
                  bind: false,
                  reverse,
                  actual_binder: false,
                  expected_binder: false,
                },
                context,
              ),
            )
          (Own(a), Own(b)) | (Borrow(a), Borrow(b)) =>
            work.push(
              CompareResource(
                {
                  actual: a,
                  expected: b,
                  bind: false,
                  reverse,
                  actual_binder: false,
                  expected_binder: false,
                },
                context,
              ),
            )
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
            mismatch = self.compatibility_externs(
              node, work, a, b, reverse, false, trace,
            )
          (World(_, _, ai, ae), World(_, _, bi, be)) => {
            mismatch = self.compatibility_externs(
              node, work, ae, be, reverse, false, trace,
            )
            if mismatch is None {
              mismatch = self.compatibility_externs(
                node, work, ai, bi, reverse, true, trace,
              )
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
