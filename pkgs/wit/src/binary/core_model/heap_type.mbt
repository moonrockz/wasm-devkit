///|
/// Resolve an abstract binary heap type while preserving explicit nullability.
/// Nonnegative indices refer to concrete module types and are resolved separately.
pub fn ValueType::from_abstract_heap_type(
  heap_type : Int32,
  nullable : Bool,
) -> ValueType? {
  Some(
    match heap_type {
      -16 => if nullable { FuncRef } else { RefFunc }
      -17 => if nullable { ExternRef } else { RefExtern }
      -18 => if nullable { AnyRef } else { RefAny }
      -19 => if nullable { RefNullEq } else { RefEq }
      -20 => if nullable { RefNullI31 } else { RefI31 }
      -21 => if nullable { StructRef } else { RefStructAbs }
      -22 => if nullable { ArrayRef } else { RefArrayAbs }
      -23 => if nullable { ExnRef } else { HeapRef(false, false, -23) }
      -15 => if nullable { NullRef } else { RefNone }
      -14 => if nullable { NullExternRef } else { HeapRef(false, false, -14) }
      -13 => if nullable { NullFuncRef } else { HeapRef(false, false, -13) }
      -12 => if nullable { NullExnRef } else { HeapRef(false, false, -12) }
      -24 => if nullable { ContRef } else { RefCont }
      -11 => if nullable { NullContRef } else { RefNoCont }
      _ => return None
    },
  )
}
