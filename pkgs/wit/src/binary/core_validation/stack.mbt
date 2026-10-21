///|
priv enum Operand {
  Known(@types.ValueType)
  Bottom
  UnknownRef(Int32?)
}

///|
/// Operand stack for type validation
/// Uses Option to represent polymorphic stack (after unreachable)
priv struct OperandStack {
  stack : Array[Operand]
  mut polymorphic : Bool // true after unreachable instruction
  mut underflow_limit : Int32 // stack height at which polymorphism was enabled
  subtyping_ctx : @types.SubtypingContext?
}

///|
fn OperandStack::new_with_subtyping(
  subtyping_ctx : @types.SubtypingContext,
) -> OperandStack {
  {
    stack: [],
    polymorphic: false,
    underflow_limit: 0,
    subtyping_ctx: Some(subtyping_ctx),
  }
}

///|
fn OperandStack::push(self : OperandStack, ty : @types.ValueType) -> Unit {
  self.stack.push(Known(ty))
}

///|
fn OperandStack::pop(
  self : OperandStack,
  expected : @types.ValueType,
) -> Unit raise ValidationError {
  ignore(self.pop_operand(Some(expected)))
}

///|
fn OperandStack::push_operand(self : OperandStack, operand : Operand) -> Unit {
  self.stack.push(operand)
}

///|
fn OperandStack::matches(
  self : OperandStack,
  actual : @types.ValueType,
  expected : @types.ValueType,
) -> Bool {
  match self.subtyping_ctx {
    Some(ctx) => ctx.value_type_subtype(actual, expected)
    None => is_type_subtype(actual, expected)
  }
}

///|
fn OperandStack::pop_operand(
  self : OperandStack,
  expected : @types.ValueType?,
) -> Operand raise ValidationError {
  let actual = if self.polymorphic && self.stack.is_empty() {
    Bottom
  } else {
    match self.stack.pop() {
      Some(v) => v
      None =>
        raise StackUnderflow(
          match expected {
            Some(ty) => "Expected \{ty}, but stack is empty"
            None => "Expected value, but stack is empty"
          },
        )
    }
  }
  if expected is Some(expected) {
    let compatible = match actual {
      Bottom => true
      Known(ty) => self.matches(ty, expected)
      UnknownRef(heap) =>
        match expected.heap() {
          None => false
          Some((_, shared, _)) =>
            match heap {
              None => true
              Some(heap) => self.matches(HeapRef(false, shared, heap), expected)
            }
        }
    }
    if !compatible {
      match actual {
        Known(ty) => raise TypeMismatch("Expected \{expected}, got \{ty}")
        _ =>
          raise TypeMismatch(
            "reference operand does not match expected type \{expected}",
          )
      }
    }
  }
  actual
}

///|
fn OperandStack::pop_push_types(
  self : OperandStack,
  expected : ArrayView[@types.ValueType],
) -> Unit raise ValidationError {
  let popped = []
  for i = expected.length() - 1; i >= 0; i = i - 1 {
    popped.push(self.pop_operand(Some(expected[i])))
  }
  for i = popped.length() - 1; i >= 0; i = i - 1 {
    self.push_operand(popped[i])
  }
}

///|
/// Check if actual type is a subtype of expected type
/// Handles reference type subtyping for GC proposal
/// Type hierarchy:
///   anyref: eqref, i31ref, structref, arrayref, (ref $struct), (ref $array)
///   eqref: i31ref, structref, arrayref, (ref $struct), (ref $array)
///   funcref: (ref $func), (ref func)
///   externref: (ref extern)

///|
fn to_non_nullable_cast_diff_type(ty : @types.ValueType) -> @types.ValueType {
  ty.with_nullable(false).unwrap_or(ty)
}

///|
/// Compute the diff type for br_on_cast_fail.
/// The diff type represents values that would fail the cast from source to target.
/// Key rule: if source is nullable but target is non-nullable, null can fail the cast,
/// so the diff type must be nullable.
fn compute_br_on_cast_fail_diff_type(
  source : @types.ValueType,
  target : @types.ValueType,
) -> @types.ValueType {
  // If both are nullable, success path consumes null, so fail path is non-null.
  // If source is nullable and target is non-null, null can fail the cast,
  // so fail path remains nullable.
  let source_nullable = source.is_nullable()
  let target_nullable = target.is_nullable()
  if source_nullable && target_nullable {
    return to_non_nullable_cast_diff_type(source)
  }
  if source_nullable && !target_nullable {
    return source
  }
  source
}

///|
fn is_type_subtype(
  actual : @types.ValueType,
  expected : @types.ValueType,
) -> Bool {
  if actual == expected {
    return true
  }
  guard actual.heap() is Some((an, ash, ah)) &&
    expected.heap() is Some((bn, bsh, bh)) else {
    return false
  }
  if ash != bsh || (an && !bn) {
    return false
  }
  if ah >= 0 && bh >= 0 {
    return ah == bh
  }
  fn kind(ty : @types.ValueType) -> Int32? {
    match ty {
      RefFuncTyped(_) | RefNullFuncTyped(_) => Some(-16)
      RefStruct(_) | RefNullStruct(_) => Some(-21)
      RefArray(_) | RefNullArray(_) => Some(-22)
      RefContTyped(_) | RefNullContTyped(_) => Some(-24)
      _ => None
    }
  }
  let aheap = if ah >= 0 {
    match kind(actual) {
      Some(h) => h
      None => return false
    }
  } else {
    ah
  }
  let bheap = if bh >= 0 {
    if ah != -15 && ah != -14 && ah != -13 && ah != -12 && ah != -11 {
      return false
    }
    match kind(expected) {
      Some(h) => h
      None => return false
    }
  } else {
    bh
  }
  @types.SubtypingContext::same_module([]).value_type_subtype(
    HeapRef(an, ash, aheap),
    HeapRef(bn, bsh, bheap),
  )
}

///|
fn is_reference_type(ty : @types.ValueType) -> Bool {
  ty.heap() is Some(_)
}

///|
/// Pop a reference value type from the stack.
/// In polymorphic-unreachable state, synthesize `nullref` as the bottom ref.
fn OperandStack::pop_ref_any(
  self : OperandStack,
) -> Operand raise ValidationError {
  match self.pop_operand(None) {
    Bottom => UnknownRef(None)
    Known(ty) =>
      if is_reference_type(ty) {
        Known(ty)
      } else {
        raise TypeMismatch("expected reference operand")
      }
    operand => operand
  }
}

///|
fn OperandStack::pop_maybe_shared_ref(
  self : OperandStack,
  heap : Int32,
) -> Operand raise ValidationError {
  let operand = self.pop_ref_any()
  match operand {
    Known(ty) => {
      let shared = ty.heap().unwrap().1
      if !self.matches(ty, HeapRef(true, shared, heap)) {
        raise TypeMismatch("reference operand has incompatible heap type")
      }
    }
    UnknownRef(Some(actual)) =>
      if !is_type_subtype(
          HeapRef(false, false, actual),
          HeapRef(true, false, heap),
        ) {
        raise TypeMismatch("reference operand has incompatible heap type")
      }
    _ => ()
  }
  operand
}

///|
fn OperandStack::set_polymorphic(self : OperandStack) -> Unit {
  // Entering unreachable code resets the operand stack to the
  // current control-frame base (which is 0 for each validation stack
  // used by validate_function / validate block bodies).
  self.stack.clear()
  self.polymorphic = true
  self.underflow_limit = 0
}

///|
/// Check that stack has exactly the expected height
/// In polymorphic mode, we can synthesize values from below the underflow_limit,
/// but actual values pushed after unreachable still count.
fn OperandStack::check_height(
  self : OperandStack,
  expected : Int32,
  context : String,
) -> Unit raise ValidationError {
  let actual = self.stack.length()
  if self.polymorphic {
    // Values above underflow_limit are real values that were pushed after unreachable
    let real_values = actual - self.underflow_limit
    // We can synthesize up to (expected - real_values) values from the polymorphic stack,
    // but if we have more real values than expected, that's an error
    if real_values > expected {
      raise StackHeightMismatch(
        "\{context}: expected stack height \{expected}, got at least \{real_values} values after unreachable code",
      )
    }
  } else if actual != expected {
    raise StackHeightMismatch(
      "\{context}: expected stack height \{expected}, got \{actual}",
    )
  }
}

///|
fn OperandStack::check_branch_values(
  self : OperandStack,
  expected : Array[@types.ValueType],
) -> Unit raise ValidationError {
  let count = self.stack.length().min(expected.length())
  let start = self.stack.length() - count
  let trial : OperandStack = {
    stack: Array::makei(count, i => self.stack[start + i]),
    polymorphic: self.polymorphic,
    underflow_limit: 0,
    subtyping_ctx: self.subtyping_ctx,
  }
  for i = expected.length() - 1; i >= 0; i = i - 1 {
    trial.pop(expected[i])
  }
}
