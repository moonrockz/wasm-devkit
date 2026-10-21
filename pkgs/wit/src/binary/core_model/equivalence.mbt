// Type Equivalence - Unified type comparison for WebAssembly GC
//
// This module provides a unified API for checking type equivalence,
// handling both same-module and cross-module comparisons with proper
// support for recursive types, rec groups, and all composite types.

///|
priv struct RecGroupIndex {
  group_by_type : Array[Int32]
  position_by_type : Array[Int32]
  groups : Array[Array[Int32]]
}

///|
fn RecGroupIndex::new(
  type_count : Int32,
  rec_group_ids : Array[Int32],
) -> RecGroupIndex {
  let group_by_type = Array::make(type_count, -1)
  let position_by_type = Array::make(type_count, 0)
  let groups : Array[Array[Int32]] = []
  let group_by_id : Map[Int32, Int32] = Map([])
  for type_idx in 0..<type_count {
    let group = if rec_group_ids.length() == 0 ||
      type_idx >= rec_group_ids.length() {
      let group = groups.length()
      groups.push([])
      group
    } else {
      let group_id = rec_group_ids[type_idx]
      match group_by_id.get(group_id) {
        Some(group) => group
        None => {
          let group = groups.length()
          groups.push([])
          group_by_id[group_id] = group
          group
        }
      }
    }
    group_by_type[type_idx] = group
    position_by_type[type_idx] = groups[group].length()
    groups[group].push(type_idx)
  }
  { group_by_type, position_by_type, groups, }
}

///|
fn RecGroupIndex::group_at(self : RecGroupIndex, type_idx : Int32) -> Int32 {
  if type_idx >= 0 && type_idx < self.group_by_type.length() {
    self.group_by_type[type_idx]
  } else {
    -1
  }
}

///|
fn RecGroupIndex::info_at(
  self : RecGroupIndex,
  type_idx : Int32,
) -> (Int32, Int32) {
  let group = self.group_at(type_idx)
  if group >= 0 {
    (self.position_by_type[type_idx], self.groups[group].length())
  } else {
    (0, 1)
  }
}

///|
/// Context for type equivalence checking.
/// Now uses SubType to properly handle func, struct, and array types.
struct TypeEquivalenceContext {
  types1 : Array[SubType]
  types2 : Array[SubType]
  rec_groups1 : RecGroupIndex
  rec_groups2 : RecGroupIndex
  cross_module : Bool
  visited : Map[(Int32, Int32), Bool]
  mut remaining : Int32
  mut exhausted : Bool
}

///|
/// Create a context for same-module type comparison.
pub fn TypeEquivalenceContext::same_module(
  types : Array[SubType],
  type_rec_groups~ : Array[Int32] = [],
) -> TypeEquivalenceContext {
  let rec_groups = RecGroupIndex::new(types.length(), type_rec_groups)
  {
    types1: types,
    types2: types,
    rec_groups1: rec_groups,
    rec_groups2: rec_groups,
    cross_module: false,
    visited: Map([]),
    remaining: 1000000,
    exhausted: false,
  }
}

///|
/// Create a context for cross-module type comparison.
pub fn TypeEquivalenceContext::cross_module(
  types1 : Array[SubType],
  types2 : Array[SubType],
  rec_groups1~ : Array[Int32] = [],
  rec_groups2~ : Array[Int32] = [],
) -> TypeEquivalenceContext {
  {
    types1,
    types2,
    rec_groups1: RecGroupIndex::new(types1.length(), rec_groups1),
    rec_groups2: RecGroupIndex::new(types2.length(), rec_groups2),
    cross_module: true,
    visited: Map([]),
    remaining: 1000000,
    exhausted: false,
  }
}

///|
fn TypeEquivalenceContext::charge(
  self : TypeEquivalenceContext,
  count : Int32,
) -> Bool {
  if count < 0 || count > self.remaining {
    self.exhausted = true
    false
  } else {
    self.remaining -= count
    true
  }
}

///|
priv enum EquivalenceWork {
  Group(Int32, Int32)
  Node(Int32, Int32)
  Ref(Int32, Int32, Int32, Int32)
  Value(ValueType, ValueType, Int32, Int32)
}

///|
/// Compare whole isorecursive groups with an explicit obligation stack. Only
/// completed successful proofs enter the shared cache; a failed descendant
/// cannot leave optimistic entries that poison a later comparison.
pub fn TypeEquivalenceContext::types_equivalent(
  self : TypeEquivalenceContext,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  let work : Array[EquivalenceWork] = [Group(idx1, idx2)]
  let seen : Map[(Int32, Int32), Bool] = Map([])
  fn compare() -> Bool {
    while work.pop() is Some(task) {
      if !self.charge(1) {
        return false
      }
      match task {
        Group(a, b) => {
          if a < 0 ||
            a >= self.types1.length() ||
            b < 0 ||
            b >= self.types2.length() {
            return false
          }
          if self.rec_groups1.info_at(a) != self.rec_groups2.info_at(b) {
            return false
          }
          if !self.cross_module && a == b {
            continue
          }
          let g1 = self.rec_groups1.groups[self.rec_groups1.group_at(a)]
          let g2 = self.rec_groups2.groups[self.rec_groups2.group_at(b)]
          if !self.charge(g1.length()) {
            return false
          }
          for i, type_index in g1 {
            work.push(Node(type_index, g2[i]))
          }
        }
        Ref(a, b, owner1, owner2) => {
          if a < 0 || b < 0 {
            if a != b {
              return false
            }
            continue
          }
          if a >= self.types1.length() || b >= self.types2.length() {
            return false
          }
          let local1 = self.rec_groups1.group_at(a) ==
            self.rec_groups1.group_at(owner1)
          let local2 = self.rec_groups2.group_at(b) ==
            self.rec_groups2.group_at(owner2)
          if local1 != local2 {
            return false
          }
          if local1 {
            if self.rec_groups1.position_by_type[a] !=
              self.rec_groups2.position_by_type[b] {
              return false
            }
          } else {
            work.push(Group(a, b))
          }
        }
        Value(a, b, owner1, owner2) =>
          match (a.heap(), b.heap()) {
            (Some((an, ash, ah)), Some((bn, bsh, bh))) => {
              if an != bn || ash != bsh {
                return false
              }
              work.push(Ref(ah, bh, owner1, owner2))
            }
            (None, None) => if a != b { return false }
            _ => return false
          }
        Node(a, b) => {
          if seen.contains((a, b)) {
            continue
          }
          match self.visited.get((a, b)) {
            Some(true) => continue
            Some(false) => return false
            None => ()
          }
          seen[(a, b)] = true
          let ta = self.types1[a]
          let tb = self.types2[b]
          if ta.final_ != tb.final_ ||
            ta.composite.is_shared() != tb.composite.is_shared() ||
            ta.supertypes.length() != tb.supertypes.length() {
            return false
          }
          if !self.charge(ta.supertypes.length()) {
            return false
          }
          for i, supertype in ta.supertypes {
            work.push(Ref(supertype, tb.supertypes[i], a, b))
          }
          fn field(f1 : FieldType, f2 : FieldType) -> Bool {
            if f1.mutable != f2.mutable {
              return false
            }
            match (f1.storage_type, f2.storage_type) {
              (Packed(x), Packed(y)) => x == y
              (Val(x), Val(y)) => {
                work.push(Value(x, y, a, b))
                true
              }
              _ => false
            }
          }
          match (ta.composite.unshared(), tb.composite.unshared()) {
            (Func(f1), Func(f2)) => {
              if f1.params.length() != f2.params.length() ||
                f1.results.length() != f2.results.length() {
                return false
              }
              if !self.charge(f1.params.length()) ||
                !self.charge(f1.results.length()) {
                return false
              }
              for i, value in f1.params {
                work.push(Value(value, f2.params[i], a, b))
              }
              for i, value in f1.results {
                work.push(Value(value, f2.results[i], a, b))
              }
            }
            (Struct(s1), Struct(s2)) => {
              if s1.fields.length() != s2.fields.length() {
                return false
              }
              if !self.charge(s1.fields.length()) {
                return false
              }
              for i, f in s1.fields {
                if !field(f, s2.fields[i]) {
                  return false
                }
              }
            }
            (Array(a1), Array(a2)) =>
              if !field(a1.element, a2.element) {
                return false
              }
            (Cont(a1), Cont(a2)) => work.push(Ref(a1, a2, a, b))
            _ => return false
          }
        }
      }
    }
    true
  }
  let result = compare()
  if result {
    for pair in seen.keys() {
      self.visited[pair] = true
    }
  } else if !self.exhausted {
    self.visited[(idx1, idx2)] = false
  }
  result
}

///|
fn TypeEquivalenceContext::types_structurally_equal(
  self : TypeEquivalenceContext,
  a : Int32,
  b : Int32,
) -> Bool {
  self.types_equivalent(a, b)
}

///|
/// Get rec group info (position, size) for a type at given index.
/// Returns (position_in_group, group_size) tuple.
pub fn get_rec_group_info(
  rec_groups : Array[Int32],
  type_idx : Int32,
) -> (Int32, Int32) {
  if type_idx < 0 || rec_groups.length() == 0 || type_idx >= rec_groups.length() {
    return (0, 1) // Default to singleton rec group
  }
  let rec_id = rec_groups[type_idx]
  let mut size = 0
  let mut position = 0
  for i, id in rec_groups {
    if id == rec_id {
      if i < type_idx {
        position = position + 1
      }
      size = size + 1
    }
  }
  (position, size)
}

///|
/// Compute canonical type indices for a module's types.
/// Structurally equivalent types (in equivalent rec groups) will be
/// assigned the same canonical index.
/// For isorecursive typing, entire rec groups must be pairwise equivalent.
pub fn compute_canonical_type_indices_checked(
  types : Array[SubType],
  type_rec_groups~ : Array[Int32] = [],
) -> Result[Array[Int32], Unit] {
  let canonical : Array[Int32] = Array::make(types.length(), -1)
  let ctx = TypeEquivalenceContext::same_module(types, type_rec_groups~)
  for group_index, members in ctx.rec_groups1.groups {
    let mut canonical_first = members[0]
    for previous_group in 0..<group_index {
      if !ctx.charge(1) {
        return Err(())
      }
      let previous_members = ctx.rec_groups1.groups[previous_group]
      if members.length() != previous_members.length() {
        continue
      }
      let mut equivalent = true
      for position, type_idx in members {
        if !ctx.types_structurally_equal(type_idx, previous_members[position]) {
          equivalent = false
          break
        }
      }
      if ctx.exhausted {
        return Err(())
      }
      if equivalent {
        canonical_first = previous_members[0]
        break
      }
    }
    for position, type_idx in members {
      canonical[type_idx] = canonical_first + position
    }
  }
  Ok(canonical)
}

///|
/// Compare two function types for simple structural equality.
/// This is for direct type comparison without type indices (e.g., host functions).
/// Note: This does NOT handle typed function references properly - use
/// TypeEquivalenceContext for full recursive type comparison.
pub fn func_types_equal(t1 : FuncType, t2 : FuncType) -> Bool {
  if t1.params.length() != t2.params.length() ||
    t1.results.length() != t2.results.length() {
    return false
  }
  for i, p1 in t1.params {
    if !value_types_simple_equal(p1, t2.params[i]) {
      return false
    }
  }
  for i, r1 in t1.results {
    if !value_types_simple_equal(r1, t2.results[i]) {
      return false
    }
  }
  true
}

///|
/// Compare two value types for simple equality.
/// For typed references, compares indices directly (only valid for same module).
fn value_types_simple_equal(v1 : ValueType, v2 : ValueType) -> Bool {
  match (v1.heap(), v2.heap()) {
    (None, None) => v1 == v2
    (Some(a), Some(b)) => a == b
    _ => false
  }
}

///|
/// Compatibility normalization only. Validation uses the checked form so an
/// exhausted proof never becomes acceptance evidence.
pub fn compute_canonical_type_indices(
  types : Array[SubType],
  type_rec_groups~ : Array[Int32] = [],
) -> Array[Int32] {
  match compute_canonical_type_indices_checked(types, type_rec_groups~) {
    Ok(indices) => indices
    Err(_) => Array::makei(types.length(), i => i)
  }
}

///|
pub fn SubtypingContext::work_exhausted(self : SubtypingContext) -> Bool {
  self.equivalence.exhausted
}

///|
/// Reduce, never reset, the shared comparison allowance.
pub fn SubtypingContext::restrict_work_limit(
  self : SubtypingContext,
  limit : Int32,
) -> Unit {
  self.equivalence.remaining = self.equivalence.remaining.min(limit.max(0))
}

///|
pub fn SubtypingContext::remaining_work(self : SubtypingContext) -> Int32 {
  self.equivalence.remaining
}

///|
pub fn SubtypingContext::reference_types_equal(
  self : SubtypingContext,
  left : Int32,
  right : Int32,
) -> Bool {
  self.types_equivalent(left, right)
}
