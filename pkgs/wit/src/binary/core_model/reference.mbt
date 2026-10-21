///|
/// Exact flat heap representation. Negative heap codes are abstract types;
/// nonnegative indices name types in the enclosing module.
pub fn ValueType::heap(self : ValueType) -> (Bool, Bool, Int32)? {
  match self {
    HeapRef(nullable, shared, heap) => Some((nullable, shared, heap))
    FuncRef => Some((true, false, -16))
    ExternRef => Some((true, false, -17))
    AnyRef => Some((true, false, -18))
    RefNullEq => Some((true, false, -19))
    RefNullI31 => Some((true, false, -20))
    StructRef | RefNullStruct(-1) => Some((true, false, -21))
    ArrayRef | RefNullArray(-1) => Some((true, false, -22))
    ExnRef => Some((true, false, -23))
    ContRef => Some((true, false, -24))
    NullRef => Some((true, false, -15))
    NullExternRef => Some((true, false, -14))
    NullFuncRef => Some((true, false, -13))
    NullExnRef => Some((true, false, -12))
    NullContRef => Some((true, false, -11))
    RefFunc => Some((false, false, -16))
    RefExtern => Some((false, false, -17))
    RefAny => Some((false, false, -18))
    RefEq => Some((false, false, -19))
    RefI31 => Some((false, false, -20))
    RefStructAbs | RefStruct(-1) => Some((false, false, -21))
    RefArrayAbs | RefArray(-1) => Some((false, false, -22))
    RefCont => Some((false, false, -24))
    RefNone => Some((false, false, -15))
    RefNoCont => Some((false, false, -11))
    RefFuncTyped(index)
    | RefStruct(index)
    | RefArray(index)
    | RefContTyped(index) => Some((false, false, index))
    RefNullFuncTyped(index)
    | RefNullStruct(index)
    | RefNullArray(index)
    | RefNullContTyped(index) => Some((true, false, index))
    _ => None
  }
}

///|
pub fn CompositeType::is_shared(self : CompositeType) -> Bool {
  match self {
    SharedFunc(_) | SharedStruct(_) | SharedArray(_) => true
    _ => false
  }
}

///|
pub fn CompositeType::unshared(self : CompositeType) -> CompositeType {
  match self {
    SharedFunc(f) => Func(f)
    SharedStruct(s) => Struct(s)
    SharedArray(a) => Array(a)
    other => other
  }
}

///|
pub fn Module::reference(
  self : Module,
  nullable : Bool,
  index : Int32,
) -> ValueType? {
  guard self.types.get(index) is Some(type_) else { return None }
  Some(typed_reference(type_.composite, nullable, index))
}

///|
pub fn typed_reference(
  composite : CompositeType,
  nullable : Bool,
  index : Int32,
) -> ValueType {
  if composite.is_shared() {
    return HeapRef(nullable, true, index)
  }
  match composite {
    Func(_) =>
      if nullable {
        RefNullFuncTyped(index)
      } else {
        RefFuncTyped(index)
      }
    Struct(_) => if nullable { RefNullStruct(index) } else { RefStruct(index) }
    Array(_) => if nullable { RefNullArray(index) } else { RefArray(index) }
    _ => if nullable { RefNullContTyped(index) } else { RefContTyped(index) }
  }
}

///|
fn composite_heap(type_ : CompositeType) -> Int32 {
  match type_.unshared() {
    Func(_) => -16
    Struct(_) => -21
    Array(_) => -22
    _ => -24
  }
}

///|
fn is_bottom_heap(heap : Int32) -> Bool {
  heap == -15 || heap == -14 || heap == -13 || heap == -12 || heap == -11
}

///|
fn abstract_heap_subtype(a : Int32, b : Int32) -> Bool {
  if a == b {
    return true
  }
  match a {
    -15 => b == -18 || b == -19 || b == -20 || b == -21 || b == -22
    -14 => b == -17
    -13 => b == -16
    -12 => b == -23
    -11 => b == -24
    -20 | -21 | -22 => b == -19 || b == -18
    -19 => b == -18
    _ => false
  }
}

///|
pub fn heap_name(heap : Int32) -> String {
  match heap {
    -16 => "func"
    -17 => "extern"
    -18 => "any"
    -19 => "eq"
    -20 => "i31"
    -21 => "struct"
    -22 => "array"
    -23 => "exn"
    -24 => "cont"
    -15 => "none"
    -14 => "noextern"
    -13 => "nofunc"
    -12 => "noexn"
    -11 => "nocont"
    _ => heap.to_string()
  }
}

///|
/// Change only nullability while retaining the exact heap and sharedness.
pub fn ValueType::with_nullable(
  self : ValueType,
  nullable : Bool,
) -> ValueType? {
  guard self.heap() is Some((old, shared, heap)) else { return None }
  if old == nullable {
    return Some(self)
  }
  if shared {
    return Some(HeapRef(nullable, shared, heap))
  }
  if heap < 0 {
    return ValueType::from_abstract_heap_type(heap, nullable)
  }
  Some(
    match self {
      RefFuncTyped(_) | RefNullFuncTyped(_) =>
        if nullable {
          RefNullFuncTyped(heap)
        } else {
          RefFuncTyped(heap)
        }
      RefStruct(_) | RefNullStruct(_) =>
        if nullable {
          RefNullStruct(heap)
        } else {
          RefStruct(heap)
        }
      RefArray(_) | RefNullArray(_) =>
        if nullable {
          RefNullArray(heap)
        } else {
          RefArray(heap)
        }
      RefContTyped(_) | RefNullContTyped(_) =>
        if nullable {
          RefNullContTyped(heap)
        } else {
          RefContTyped(heap)
        }
      _ => HeapRef(nullable, shared, heap)
    },
  )
}
