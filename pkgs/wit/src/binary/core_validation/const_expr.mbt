///|
/// Constant expressions use the ordinary bounded operand/type checker after
/// a flat whitelist check. No operation executes the expression.
fn validate_const_expr(
  globals : ArrayView[@types.GlobalType],
  expr : Array[@types.Instruction],
  expected_type : @types.ValueType,
  funcs~ : Array[Int32] = [],
  types~ : Array[@types.SubType] = [],
  subtyping_ctx~ : @types.SubtypingContext? = None,
  stack_switching~ : Bool = false,
) -> Unit raise ValidationError {
  if expr.is_empty() {
    raise TypeMismatch("empty constant expression")
  }
  let subtyping = subtyping_ctx.unwrap_or_else(() => {
    @types.SubtypingContext::same_module(types)
  })
  let ctx : ValidationContext = {
    constant: true,
    shared: false,
    bulk_memory: true,
    stack_switching,
    types,
    funcs,
    globals,
    tables: [],
    mems: [],
    tags: [],
    elems: [],
    data_count: 0,
    locals: [],
    labels: [],
    returns: [],
    local_init: [],
    declared_funcs: @hashset.HashSet([]),
    subtyping_ctx: subtyping,
  }
  let stack = OperandStack::new_with_subtyping(subtyping)
  for instruction in expr {
    match instruction {
      I32Const(_)
      | I64Const(_)
      | F32Const(_)
      | F64Const(_)
      | V128Const(_)
      | RefNull(_)
      | RefFunc(_)
      | RefI31
      | RefI31Shared
      | AnyConvertExtern
      | ExternConvertAny
      | StructNew(_)
      | StructNewDefault(_)
      | ArrayNew(_)
      | ArrayNewDefault(_)
      | ArrayNewFixed(_, _)
      | I32Add
      | I32Sub
      | I32Mul
      | I64Add
      | I64Sub
      | I64Mul => ()
      GlobalGet(index) =>
        if ctx.get_global_type(index).mutable {
          raise MutableGlobalInConstExpr
        }
      _ => raise ConstantExpressionRequired
    }
    validate_instr(ctx, stack, instruction)
  }
  stack.check_height(1, "constant expression")
  match stack.pop_operand(None) {
    Known(actual) =>
      if !stack.matches(actual, expected_type) {
        raise TypeMismatch(
          "constant expression: expected \{expected_type}, got \{actual}",
        )
      }
    _ => raise ConstantExpressionRequired
  }
  if subtyping.work_exhausted() {
    raise TypeWorkLimit
  }
}
