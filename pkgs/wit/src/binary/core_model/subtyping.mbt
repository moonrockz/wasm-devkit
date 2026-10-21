// Unified Subtyping API for WebAssembly GC
//
// This module provides a unified API for checking type subtyping,
// used by both the validator (compile-time) and executor (runtime).
// Implements the GC proposal subtyping rules including:
// - Function subtyping (contravariant params, covariant results)
// - Struct width + depth subtyping
// - Array element invariance for mutable, covariance for immutable
// - Field mutability variance

///|
/// Context for subtyping checks.
/// Can be used for same-module or cross-module comparisons.
pub struct SubtypingContext {
  types1 : Array[SubType]
  types2 : Array[SubType]
  rec_groups1 : Array[Int32]
  rec_groups2 : Array[Int32]
  canonical1 : Array[Int32]
  canonical2 : Array[Int32]
  cross_module : Bool
  visited : Map[(Int32, Int32), Bool]
  equivalence : TypeEquivalenceContext
}

///|
/// Create a context for same-module subtyping.
pub fn SubtypingContext::same_module(
  types : Array[SubType],
  rec_groups~ : Array[Int32] = [],
  canonical~ : Array[Int32] = [],
) -> SubtypingContext {
  {
    types1: types,
    types2: types,
    rec_groups1: rec_groups,
    rec_groups2: rec_groups,
    canonical1: canonical,
    canonical2: canonical,
    cross_module: false,
    visited: Map([]),
    equivalence: TypeEquivalenceContext::same_module(
      types,
      type_rec_groups=rec_groups,
    ),
  }
}

///|
/// Create a context for cross-module subtyping (e.g., import validation).
pub fn SubtypingContext::cross_module(
  types1 : Array[SubType],
  types2 : Array[SubType],
  rec_groups1~ : Array[Int32] = [],
  rec_groups2~ : Array[Int32] = [],
  canonical1~ : Array[Int32] = [],
  canonical2~ : Array[Int32] = [],
) -> SubtypingContext {
  {
    types1,
    types2,
    rec_groups1,
    rec_groups2,
    canonical1,
    canonical2,
    cross_module: true,
    visited: Map([]),
    equivalence: TypeEquivalenceContext::cross_module(
      types1,
      types2,
      rec_groups1~,
      rec_groups2~,
    ),
  }
}

///|
/// Check if type at idx1 is a subtype of type at idx2.
/// This is the main entry point for runtime type subtyping.
/// For WebAssembly GC isorecursive types, subtyping is based on:
/// 1. Type equality (via canonical indices)
/// 2. Declared supertype chain
/// Structural subtyping is NOT considered at runtime (only for validation).
pub fn SubtypingContext::is_subtype(
  self : SubtypingContext,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  self.is_subtype_direction(idx1, idx2, false)
}

///|
/// Reverse comparisons keep the module of each index explicit, including
/// contravariant function parameters in cross-module declarations.
fn SubtypingContext::is_subtype_direction(
  self : SubtypingContext,
  subtype : Int32,
  supertype : Int32,
  reverse : Bool,
) -> Bool {
  let source = if reverse { self.types2 } else { self.types1 }
  let target = if reverse { self.types1 } else { self.types2 }
  if subtype < 0 ||
    subtype >= source.length() ||
    supertype < 0 ||
    supertype >= target.length() {
    return false
  }
  if !reverse && self.visited.get((subtype, supertype)) is Some(result) {
    return result
  }
  let work = [subtype]
  let seen : Map[Int32, Bool] = Map([])
  while work.pop() is Some(index) {
    if !self.equivalence.charge(1) {
      return false
    }
    if seen.contains(index) {
      continue
    }
    seen[index] = true
    let equal = if !self.cross_module &&
      self.canonical1.get(index) is Some(ca) &&
      self.canonical2.get(supertype) is Some(cb) {
      ca == cb
    } else if reverse {
      self.equivalence.types_equivalent(supertype, index)
    } else {
      self.equivalence.types_equivalent(index, supertype)
    }
    if self.work_exhausted() {
      return false
    }
    if equal {
      if !reverse {
        self.visited[(subtype, supertype)] = true
      }
      return true
    }
    if !self.equivalence.charge(source[index].supertypes.length()) {
      return false
    }
    for parent in source[index].supertypes {
      if parent >= 0 && parent < source.length() {
        work.push(parent)
      }
    }
  }
  if !reverse {
    self.visited[(subtype, supertype)] = false
  }
  false
}

///|
/// Check if two composite types satisfy the subtyping relation.
fn SubtypingContext::composite_subtype(
  self : SubtypingContext,
  c1 : CompositeType,
  c2 : CompositeType,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  if c1.is_shared() != c2.is_shared() {
    return false
  }
  match (c1.unshared(), c2.unshared()) {
    (Func(f1), Func(f2)) => self.func_subtype(f1, f2, idx1, idx2)
    (Struct(s1), Struct(s2)) => self.struct_subtype(s1, s2, idx1, idx2)
    (Array(a1), Array(a2)) => self.array_subtype(a1, a2, idx1, idx2)
    (Cont(f1), Cont(f2)) => self.is_subtype(f1, f2)
    _ => false // Different composite types are never subtypes
  }
}

///|
/// Function subtyping: contravariant params, covariant results.
/// f1 <: f2 iff
///   |params| == |params| && |results| == |results| &&
///   forall i: f2.params[i] <: f1.params[i] (contravariant) &&
///   forall i: f1.results[i] <: f2.results[i] (covariant)
fn SubtypingContext::func_subtype(
  self : SubtypingContext,
  f1 : FuncType,
  f2 : FuncType,
  _idx1 : Int32,
  _idx2 : Int32,
) -> Bool {
  // Parameter and result counts must match
  if f1.params.length() != f2.params.length() ||
    f1.results.length() != f2.results.length() {
    return false
  }
  // Contravariant params: f2.params[i] <: f1.params[i]
  for i, p2 in f2.params {
    if !self.value_type_subtype_direction(p2, f1.params[i], self.cross_module) {
      return false
    }
  }
  // Covariant results: f1.results[i] <: f2.results[i]
  for i, r1 in f1.results {
    if !self.value_type_subtype(r1, f2.results[i]) {
      return false
    }
  }
  true
}

///|
/// Struct subtyping: width + depth subtyping.
/// s1 <: s2 iff
///   |s1.fields| >= |s2.fields| &&
///   forall i < |s2.fields|: field_subtype(s1.fields[i], s2.fields[i])
fn SubtypingContext::struct_subtype(
  self : SubtypingContext,
  s1 : StructType,
  s2 : StructType,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  // Width: subtype must have at least as many fields
  if s1.fields.length() < s2.fields.length() {
    return false
  }
  // Depth: each corresponding field must satisfy field subtyping
  for i, f2 in s2.fields {
    if !self.field_subtype(s1.fields[i], f2, idx1, idx2) {
      return false
    }
  }
  true
}

///|
/// Array subtyping: invariant for mutable, covariant for immutable.
/// a1 <: a2 iff
///   if a2.element.mutable: element types must be equal (invariant)
///   else: a1.element <: a2.element (covariant)
fn SubtypingContext::array_subtype(
  self : SubtypingContext,
  a1 : ArrayType,
  a2 : ArrayType,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  self.field_subtype(a1.element, a2.element, idx1, idx2)
}

///|
/// Field subtyping with mutability variance rules.
/// For mutable fields: types must be exactly equal (invariant)
/// For immutable fields: f1.type <: f2.type (covariant)
fn SubtypingContext::field_subtype(
  self : SubtypingContext,
  f1 : FieldType,
  f2 : FieldType,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  if f2.mutable {
    // Mutable fields require exact type equality (invariance)
    // Both must be mutable and storage types must be equal
    f1.mutable &&
    self.storage_types_equal(f1.storage_type, f2.storage_type, idx1, idx2)
  } else {
    // Immutable fields allow covariance
    // f1 can be mutable or immutable, but f1.type must be subtype of f2.type
    !f1.mutable &&
    self.storage_type_subtype(f1.storage_type, f2.storage_type, idx1, idx2)
  }
}

///|
/// Storage type subtyping.
fn SubtypingContext::storage_type_subtype(
  self : SubtypingContext,
  s1 : StorageType,
  s2 : StorageType,
  _idx1 : Int32,
  _idx2 : Int32,
) -> Bool {
  match (s1, s2) {
    (Val(v1), Val(v2)) => self.value_type_subtype(v1, v2)
    (Packed(p1), Packed(p2)) => p1 == p2
    _ => false
  }
}

///|
/// Storage type equality (for invariant contexts).
fn SubtypingContext::storage_types_equal(
  self : SubtypingContext,
  s1 : StorageType,
  s2 : StorageType,
  idx1 : Int32,
  idx2 : Int32,
) -> Bool {
  match (s1, s2) {
    (Val(v1), Val(v2)) => self.value_types_equal(v1, v2, idx1, idx2)
    (Packed(p1), Packed(p2)) => p1 == p2
    _ => false
  }
}

///|
/// Value type subtyping including abstract heap type hierarchy.
pub fn SubtypingContext::value_type_subtype(
  self : SubtypingContext,
  v1 : ValueType,
  v2 : ValueType,
  _idx1~ : Int32 = 0,
  _idx2~ : Int32 = 0,
) -> Bool {
  self.value_type_subtype_direction(v1, v2, false)
}

///|
fn SubtypingContext::value_type_subtype_direction(
  self : SubtypingContext,
  v1 : ValueType,
  v2 : ValueType,
  reverse : Bool,
) -> Bool {
  let source = if reverse { self.types2 } else { self.types1 }
  let target = if reverse { self.types1 } else { self.types2 }
  match (v1.heap(), v2.heap()) {
    (None, None) => v1 == v2
    (Some((an, ash, ah)), Some((bn, bsh, bh))) => {
      if ash != bsh || (an && !bn) {
        return false
      }
      if ah >= 0 && bh >= 0 {
        return self.is_subtype_direction(ah, bh, reverse)
      }
      if ah >= 0 {
        guard source.get(ah) is Some(type_) else { return false }
        abstract_heap_subtype(composite_heap(type_.composite), bh)
      } else if bh >= 0 {
        guard target.get(bh) is Some(type_) else { return false }
        abstract_heap_subtype(ah, composite_heap(type_.composite)) &&
        is_bottom_heap(ah)
      } else {
        abstract_heap_subtype(ah, bh)
      }
    }
    _ => false
  }
}

///|
/// Value type equality (for invariant contexts like mutable fields).
fn SubtypingContext::value_types_equal(
  self : SubtypingContext,
  v1 : ValueType,
  v2 : ValueType,
  _idx1 : Int32,
  _idx2 : Int32,
) -> Bool {
  match (v1.heap(), v2.heap()) {
    (None, None) => v1 == v2
    (Some((an, ash, ah)), Some((bn, bsh, bh))) => {
      if an != bn || ash != bsh {
        return false
      }
      if ah < 0 || bh < 0 {
        ah == bh
      } else {
        self.types_equivalent(ah, bh)
      }
    }
    _ => false
  }
}

///|
/// Check type equivalence for invariant contexts.
/// Two types are equivalent if they have the same canonical index
/// or are structurally identical.
fn SubtypingContext::types_equivalent(
  self : SubtypingContext,
  t1 : Int32,
  t2 : Int32,
) -> Bool {
  if t1 < 0 ||
    t1 >= self.types1.length() ||
    t2 < 0 ||
    t2 >= self.types2.length() {
    return false
  }
  if !self.cross_module &&
    self.canonical1.get(t1) is Some(a) &&
    self.canonical2.get(t2) is Some(b) {
    return a == b
  }
  self.equivalence.types_equivalent(t1, t2)
}

///|
/// Validate that a declared subtype relationship is structurally valid.
/// This should be called during validation to ensure that when a type
/// declares a supertype, the subtype's structure is compatible.
pub fn SubtypingContext::validate_declared_subtype(
  self : SubtypingContext,
  sub_idx : Int32,
  super_idx : Int32,
) -> Bool {
  if sub_idx < 0 ||
    sub_idx >= self.types1.length() ||
    super_idx < 0 ||
    super_idx >= self.types2.length() {
    return false
  }
  let sub_type = self.types1[sub_idx]
  let super_type = self.types2[super_idx]
  // Supertype must not be final
  if super_type.final_ {
    return false
  }
  // Composite type kinds must match
  if sub_type.composite.is_shared() != super_type.composite.is_shared() {
    return false
  }
  let kind_matches = match
    (sub_type.composite.unshared(), super_type.composite.unshared()) {
    (Func(_), Func(_)) => true
    (Struct(_), Struct(_)) => true
    (Array(_), Array(_)) => true
    (Cont(_), Cont(_)) => true
    _ => false
  }
  if !kind_matches {
    return false
  }
  // Structural subtyping must hold
  self.composite_subtype(
    sub_type.composite,
    super_type.composite,
    sub_idx,
    super_idx,
  )
}
