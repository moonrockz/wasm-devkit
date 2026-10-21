///|
fn function_context(
  ctx : ValidationContext,
  func_type : @types.FuncType,
  code : @types.FunctionCode,
  shared : Bool,
) -> ValidationContext raise ValidationError {
  let num_types = ctx.types.length()

  // Validate type indices in local types
  for local_type in code.locals {
    validate_value_type(
      local_type,
      num_types,
      stack_switching=ctx.stack_switching,
    )
    validate_reference_metadata(local_type, ctx.types)
  }

  // Set up locals: params + declared locals
  let locals : Array[@types.ValueType] = []
  let local_init : Array[Bool] = []
  // Parameters are always initialized (provided by caller)
  for param in func_type.params {
    locals.push(param)
    local_init.push(true)
  }
  // Declared locals: initialized only if they have a default value (not non-nullable ref)
  for local_type in code.locals {
    locals.push(local_type)
    // Non-nullable reference types don't have a default value, so they start uninitialized
    local_init.push(!is_non_nullable_ref(local_type))
  }

  // Create validation context for this function
  { ..ctx, shared, locals, local_init, labels: [], returns: func_type.results, }
}

///|
/// Validate a function body with instruction offset tracking
fn validate_function_with_offset(
  ctx : ValidationContext,
  func_type : @types.FuncType,
  code : @types.FunctionCode,
  func_idx : Int32,
  shared~ : Bool = false,
) -> Unit raise ValidationError {
  let func_ctx = function_context(ctx, func_type, code, shared)
  let stack = OperandStack::new_with_subtyping(func_ctx.subtyping_ctx)

  // Validate function body with offset tracking
  validate_expr_with_offset(func_ctx, stack, code.body, func_idx)

  // Check that final stack has exactly the return types
  let expected_height = func_type.results.length()
  stack.check_height(expected_height, "function return") catch {
    e =>
      raise WithContext(
        ValidationErrorContext::from_error(e).with_func_idx(func_idx),
      )
  }

  // Pop and verify return types
  let num_results = func_type.results.length()
  for offset in 0..<num_results {
    let i = num_results - 1 - offset
    stack.pop(func_type.results[i]) catch {
      e =>
        raise WithContext(
          ValidationErrorContext::from_error(e).with_func_idx(func_idx),
        )
    }
  }
}

///|
/// Validate an expression with instruction offset tracking
fn validate_expr_with_offset(
  ctx : ValidationContext,
  stack : OperandStack,
  instrs : Array[@types.Instruction],
  func_idx : Int32,
) -> Unit raise ValidationError {
  for i, instr in instrs {
    validate_expr(ctx, stack, [instr]) catch {
      e =>
        raise WithContext(
          ValidationErrorContext::from_error(e)
          .with_func_idx(func_idx)
          .with_instr_offset(i)
          .with_instruction(
            match instr {
              Block(_, _) => "block"
              Loop(_, _) => "loop"
              If(_, _, _) => "if"
              TryTable(_, _, _) => "try_table"
              LegacyTry(_, _, _, _) => "try"
              _ => instr.to_string()
            },
          ),
        )
    }
  }
}

///|
/// Validate a function body
fn validate_function(
  ctx : ValidationContext,
  func_type : @types.FuncType,
  code : @types.FunctionCode,
  shared~ : Bool = false,
) -> Unit raise ValidationError {
  let func_ctx = function_context(ctx, func_type, code, shared)
  let stack = OperandStack::new_with_subtyping(func_ctx.subtyping_ctx)

  // Validate function body
  validate_expr(func_ctx, stack, code.body)

  // Check that final stack has exactly the return types
  let expected_height = func_type.results.length()
  stack.check_height(expected_height, "function return")

  // Pop and verify return types
  let results_count = func_type.results.length()
  for offset in 0..<results_count {
    let i = results_count - 1 - offset
    stack.pop(func_type.results[i])
  }
}

///|
priv enum ExpressionWork {
  Sequence(OperandStack, Array[@types.Instruction], Int32)
  LegacyNext(
    OperandStack,
    OperandStack,
    Array[@types.ValueType],
    Array[@types.LegacyCatch],
    Int32,
    Array[Bool],
    Int32?
  )
  Exit(OperandStack, OperandStack, Array[@types.ValueType], Array[Bool], String)
  Else(
    OperandStack,
    OperandStack,
    Array[@types.ValueType],
    Array[@types.ValueType],
    Array[@types.Instruction],
    Array[Bool]
  )
}

///|
fn check_control_results(
  stack : OperandStack,
  results : Array[@types.ValueType],
  context : String,
) -> Unit raise ValidationError {
  stack.check_height(results.length(), context)
  for i = results.length() - 1; i >= 0; i = i - 1 {
    stack.pop(results[i])
  }
}

///|
fn restore_local_init(ctx : ValidationContext, saved : Array[Bool]) -> Unit {
  for i in 0..<saved.length() {
    ctx.local_init[i] = saved[i]
  }
}

///|
fn control_stack(
  ctx : ValidationContext,
  params : Array[@types.ValueType],
) -> OperandStack {
  let stack = OperandStack::new_with_subtyping(ctx.subtyping_ctx)
  for param in params {
    stack.push(param)
  }
  stack
}

///|
// Traverse instruction bodies with explicit continuations. A label stays active
// until its matching Exit; each if arm starts from the same local-init state.
fn validate_expr(
  ctx : ValidationContext,
  stack : OperandStack,
  instrs : Array[@types.Instruction],
) -> Unit raise ValidationError {
  let work : Array[ExpressionWork] = [Sequence(stack, instrs, 0)]
  while work.pop() is Some(task) {
    match task {
      Sequence(outer, instructions, index) => {
        if index >= instructions.length() {
          continue
        }
        work.push(Sequence(outer, instructions, index + 1))
        let instruction = instructions[index]
        match instruction {
          Block(bt, body) | Loop(bt, body) | TryTable(bt, _, body) => {
            let params = get_block_params(ctx, bt)
            let results = get_block_results(ctx, bt)
            for i = params.length() - 1; i >= 0; i = i - 1 {
              outer.pop(params[i])
            }
            if instruction is TryTable(_, handlers, _) {
              validate_catch_handlers(ctx, handlers)
            }
            let inner = control_stack(ctx, params)
            let saved = ctx.local_init.copy()
            let (kind, context) = match instruction {
              Loop(_, _) => (LoopLabel, "loop exit")
              TryTable(_, _, _) => (BlockLabel, "try_table exit")
              _ => (BlockLabel, "block exit")
            }
            ctx.labels.push({ kind, block_type: bt, })
            work.push(Exit(outer, inner, results, saved, context))
            work.push(Sequence(inner, body, 0))
          }
          LegacyTry(bt, body, catches, delegate) => {
            if delegate is Some(_) && !catches.is_empty() {
              raise TypeMismatch("delegate cannot follow catch")
            }
            for i, arm in catches {
              if arm.tag is None && i + 1 < catches.length() {
                raise TypeMismatch("catch cannot follow catch_all")
              }
            }
            let params = get_block_params(ctx, bt)
            let results = get_block_results(ctx, bt)
            for i = params.length() - 1; i >= 0; i = i - 1 {
              outer.pop(params[i])
            }
            let inner = control_stack(ctx, params)
            let saved = ctx.local_init.copy()
            ctx.labels.push({ kind: LegacyTryLabel, block_type: bt, })
            work.push(
              LegacyNext(outer, inner, results, catches, 0, saved, delegate),
            )
            work.push(Sequence(inner, body, 0))
          }
          If(bt, then_body, else_body) => {
            outer.pop(I32)
            let params = get_block_params(ctx, bt)
            let results = get_block_results(ctx, bt)
            for i = params.length() - 1; i >= 0; i = i - 1 {
              outer.pop(params[i])
            }
            let saved = ctx.local_init.copy()
            let inner = control_stack(ctx, params)
            ctx.labels.push({ kind: BlockLabel, block_type: bt, })
            work.push(Else(outer, inner, params, results, else_body, saved))
            work.push(Sequence(inner, then_body, 0))
          }
          _ => validate_instr(ctx, outer, instruction)
        }
      }
      LegacyNext(outer, inner, results, catches, index, saved, delegate) => {
        check_control_results(inner, results, "legacy try arm exit")
        restore_local_init(ctx, saved)
        if index < catches.length() {
          let arm = catches[index]
          let params = match arm.tag {
            Some(tag) => ctx.exception_tag_type(tag).params
            None => []
          }
          let inner = control_stack(ctx, params)
          let last = ctx.labels.length() - 1
          ctx.labels[last] = { ..ctx.labels[last], kind: LegacyCatchLabel, }
          work.push(
            LegacyNext(
              outer,
              inner,
              results,
              catches,
              index + 1,
              saved,
              delegate,
            ),
          )
          work.push(Sequence(inner, arm.body, 0))
        } else {
          ignore(ctx.labels.pop())
          if delegate is Some(depth) &&
            (depth < 0 || depth > ctx.labels.length()) {
            raise InvalidLabelIndex(depth)
          }
          for result in results {
            outer.push(result)
          }
        }
      }
      Else(outer, then_stack, params, results, else_body, saved) => {
        check_control_results(then_stack, results, "if-then exit")
        restore_local_init(ctx, saved)
        let inner = control_stack(ctx, params)
        work.push(Exit(outer, inner, results, saved, "if-else exit"))
        work.push(Sequence(inner, else_body, 0))
      }
      Exit(outer, inner, results, saved, context) => {
        ctx.labels.pop() |> ignore
        restore_local_init(ctx, saved)
        check_control_results(inner, results, context)
        for result in results {
          outer.push(result)
        }
      }
    }
  }
}
