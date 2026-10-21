///|
/// Validate a single instruction
fn validate_instr(
  ctx : ValidationContext,
  stack : OperandStack,
  instr : @types.Instruction,
) -> Unit raise ValidationError {
  if validate_continuation_instruction(ctx, stack, instr) {
    return
  }
  if !ctx.bulk_memory {
    match instr {
      MemoryInit(_, _)
      | DataDrop(_)
      | MemoryCopy(_, _)
      | MemoryFill(_)
      | TableInit(_, _)
      | ElemDrop(_)
      | TableCopy(_, _) =>
        raise TypeMismatch("bulk memory support is not enabled")
      _ => ()
    }
  }
  match instr {
    // Constants
    I32Const(_) => stack.push(I32)
    I64Const(_) => stack.push(I64)
    F32Const(_) => stack.push(F32)
    F64Const(_) => stack.push(F64)

    // Local operations
    LocalGet(idx) => {
      if idx >= ctx.locals.length() {
        raise InvalidLocalIndex(idx)
      }
      // Check if non-nullable ref local is initialized
      if idx < ctx.local_init.length() && !ctx.local_init[idx] {
        raise UninitializedLocal(idx)
      }
      stack.push(ctx.locals[idx])
    }
    LocalSet(idx) => {
      if idx >= ctx.locals.length() {
        raise InvalidLocalIndex(idx)
      }
      stack.pop(ctx.locals[idx])
      // Mark local as initialized
      if idx < ctx.local_init.length() {
        ctx.local_init[idx] = true
      }
    }
    LocalTee(idx) => {
      if idx >= ctx.locals.length() {
        raise InvalidLocalIndex(idx)
      }
      stack.pop(ctx.locals[idx])
      stack.push(ctx.locals[idx])
      // Mark local as initialized
      if idx < ctx.local_init.length() {
        ctx.local_init[idx] = true
      }
    }

    // Global operations
    GlobalGet(idx) => {
      if idx >= ctx.globals.length() {
        raise InvalidGlobalIndex(idx)
      }
      stack.push(ctx.get_global_type(idx).value_type)
    }
    GlobalSet(idx) => {
      if idx >= ctx.globals.length() {
        raise InvalidGlobalIndex(idx)
      }
      // Global must be mutable to set
      if !ctx.get_global_type(idx).mutable {
        raise TypeMismatch("cannot set immutable global")
      }
      stack.pop(ctx.get_global_type(idx).value_type)
    }

    // i32 binary operations
    I32Add
    | I32Sub
    | I32Mul
    | I32DivS
    | I32DivU
    | I32RemS
    | I32RemU
    | I32And
    | I32Or
    | I32Xor
    | I32Shl
    | I32ShrS
    | I32ShrU
    | I32Rotl
    | I32Rotr => {
      stack.pop(I32)
      stack.pop(I32)
      stack.push(I32)
    }

    // i32 comparison operations
    I32Eq
    | I32Ne
    | I32LtS
    | I32LtU
    | I32GtS
    | I32GtU
    | I32LeS
    | I32LeU
    | I32GeS
    | I32GeU => {
      stack.pop(I32)
      stack.pop(I32)
      stack.push(I32)
    }

    // i32 unary operations
    I32Eqz => {
      stack.pop(I32)
      stack.push(I32)
    }
    I32Clz | I32Ctz | I32Popcnt => {
      stack.pop(I32)
      stack.push(I32)
    }
    // i32 sign-extension operations
    I32Extend8S | I32Extend16S => {
      stack.pop(I32)
      stack.push(I32)
    }

    // i64 binary operations
    I64Add128 | I64Sub128 => {
      stack.pop(I64)
      stack.pop(I64)
      stack.pop(I64)
      stack.pop(I64)
      stack.push(I64)
      stack.push(I64)
    }
    I64MulWideS | I64MulWideU => {
      stack.pop(I64)
      stack.pop(I64)
      stack.push(I64)
      stack.push(I64)
    }

    // i64 binary operations
    I64Add
    | I64Sub
    | I64Mul
    | I64DivS
    | I64DivU
    | I64RemS
    | I64RemU
    | I64And
    | I64Or
    | I64Xor
    | I64Shl
    | I64ShrS
    | I64ShrU
    | I64Rotl
    | I64Rotr => {
      stack.pop(I64)
      stack.pop(I64)
      stack.push(I64)
    }

    // i64 comparison operations
    I64Eq
    | I64Ne
    | I64LtS
    | I64LtU
    | I64GtS
    | I64GtU
    | I64LeS
    | I64LeU
    | I64GeS
    | I64GeU => {
      stack.pop(I64)
      stack.pop(I64)
      stack.push(I32)
    }

    // i64 unary operations
    I64Eqz => {
      stack.pop(I64)
      stack.push(I32)
    }
    I64Clz | I64Ctz | I64Popcnt => {
      stack.pop(I64)
      stack.push(I64)
    }
    // i64 sign-extension operations
    I64Extend8S | I64Extend16S | I64Extend32S => {
      stack.pop(I64)
      stack.push(I64)
    }

    // f32 binary operations
    F32Add | F32Sub | F32Mul | F32Div | F32Min | F32Max | F32Copysign => {
      stack.pop(F32)
      stack.pop(F32)
      stack.push(F32)
    }

    // f32 comparison operations
    F32Eq | F32Ne | F32Lt | F32Gt | F32Le | F32Ge => {
      stack.pop(F32)
      stack.pop(F32)
      stack.push(I32)
    }

    // f32 unary operations
    F32Abs | F32Neg | F32Ceil | F32Floor | F32Trunc | F32Nearest | F32Sqrt => {
      stack.pop(F32)
      stack.push(F32)
    }

    // f64 binary operations
    F64Add | F64Sub | F64Mul | F64Div | F64Min | F64Max | F64Copysign => {
      stack.pop(F64)
      stack.pop(F64)
      stack.push(F64)
    }

    // f64 comparison operations
    F64Eq | F64Ne | F64Lt | F64Gt | F64Le | F64Ge => {
      stack.pop(F64)
      stack.pop(F64)
      stack.push(I32)
    }

    // f64 unary operations
    F64Abs | F64Neg | F64Ceil | F64Floor | F64Trunc | F64Nearest | F64Sqrt => {
      stack.pop(F64)
      stack.push(F64)
    }

    // Conversion operations
    I32WrapI64 => {
      stack.pop(I64)
      stack.push(I32)
    }
    I64ExtendI32S | I64ExtendI32U => {
      stack.pop(I32)
      stack.push(I64)
    }
    I32TruncF32S | I32TruncF32U | I32TruncSatF32S | I32TruncSatF32U => {
      stack.pop(F32)
      stack.push(I32)
    }
    I32TruncF64S | I32TruncF64U | I32TruncSatF64S | I32TruncSatF64U => {
      stack.pop(F64)
      stack.push(I32)
    }
    I64TruncF32S | I64TruncF32U | I64TruncSatF32S | I64TruncSatF32U => {
      stack.pop(F32)
      stack.push(I64)
    }
    I64TruncF64S | I64TruncF64U | I64TruncSatF64S | I64TruncSatF64U => {
      stack.pop(F64)
      stack.push(I64)
    }
    F32ConvertI32S | F32ConvertI32U => {
      stack.pop(I32)
      stack.push(F32)
    }
    F32ConvertI64S | F32ConvertI64U => {
      stack.pop(I64)
      stack.push(F32)
    }
    F64ConvertI32S | F64ConvertI32U => {
      stack.pop(I32)
      stack.push(F64)
    }
    F64ConvertI64S | F64ConvertI64U => {
      stack.pop(I64)
      stack.push(F64)
    }
    F32DemoteF64 => {
      stack.pop(F64)
      stack.push(F32)
    }
    F64PromoteF32 => {
      stack.pop(F32)
      stack.push(F64)
    }
    I32ReinterpretF32 => {
      stack.pop(F32)
      stack.push(I32)
    }
    I64ReinterpretF64 => {
      stack.pop(F64)
      stack.push(I64)
    }
    F32ReinterpretI32 => {
      stack.pop(I32)
      stack.push(F32)
    }
    F64ReinterpretI64 => {
      stack.pop(I64)
      stack.push(F64)
    }

    // Memory operations - validate memory index exists
    // Natural alignment: 8-bit=0, 16-bit=1, 32-bit=2, 64-bit=3
    I32Load(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 2 {
        raise InvalidAlignment(
          "i32.load alignment \{align} exceeds natural alignment 2",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I32)
    }
    I32Load8S(memidx, align, offset) | I32Load8U(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 0 {
        raise InvalidAlignment(
          "i32.load8 alignment \{align} exceeds natural alignment 0",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I32)
    }
    I32Load16S(memidx, align, offset) | I32Load16U(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 1 {
        raise InvalidAlignment(
          "i32.load16 alignment \{align} exceeds natural alignment 1",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I32)
    }
    I64Load(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 3 {
        raise InvalidAlignment(
          "i64.load alignment \{align} exceeds natural alignment 3",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I64)
    }
    I64Load8S(memidx, align, offset) | I64Load8U(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 0 {
        raise InvalidAlignment(
          "i64.load8 alignment \{align} exceeds natural alignment 0",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I64)
    }
    I64Load16S(memidx, align, offset) | I64Load16U(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 1 {
        raise InvalidAlignment(
          "i64.load16 alignment \{align} exceeds natural alignment 1",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I64)
    }
    I64Load32S(memidx, align, offset) | I64Load32U(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 2 {
        raise InvalidAlignment(
          "i64.load32 alignment \{align} exceeds natural alignment 2",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(I64)
    }
    F32Load(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 2 {
        raise InvalidAlignment(
          "f32.load alignment \{align} exceeds natural alignment 2",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(F32)
    }
    F64Load(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 3 {
        raise InvalidAlignment(
          "f64.load alignment \{align} exceeds natural alignment 3",
        )
      }
      stack.pop(ctx.mems[memidx].addr_type()) // address
      stack.push(F64)
    }
    I32Store(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 2 {
        raise InvalidAlignment(
          "i32.store alignment \{align} exceeds natural alignment 2",
        )
      }
      stack.pop(I32) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    I32Store8(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 0 {
        raise InvalidAlignment(
          "i32.store8 alignment \{align} exceeds natural alignment 0",
        )
      }
      stack.pop(I32) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    I32Store16(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 1 {
        raise InvalidAlignment(
          "i32.store16 alignment \{align} exceeds natural alignment 1",
        )
      }
      stack.pop(I32) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    I64Store(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 3 {
        raise InvalidAlignment(
          "i64.store alignment \{align} exceeds natural alignment 3",
        )
      }
      stack.pop(I64) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    I64Store8(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 0 {
        raise InvalidAlignment(
          "i64.store8 alignment \{align} exceeds natural alignment 0",
        )
      }
      stack.pop(I64) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    I64Store16(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 1 {
        raise InvalidAlignment(
          "i64.store16 alignment \{align} exceeds natural alignment 1",
        )
      }
      stack.pop(I64) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    I64Store32(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 2 {
        raise InvalidAlignment(
          "i64.store32 alignment \{align} exceeds natural alignment 2",
        )
      }
      stack.pop(I64) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    F32Store(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 2 {
        raise InvalidAlignment(
          "f32.store alignment \{align} exceeds natural alignment 2",
        )
      }
      stack.pop(F32) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    F64Store(memidx, align, offset) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      validate_mem_offset(ctx.mems[memidx], offset)
      if align > 3 {
        raise InvalidAlignment(
          "f64.store alignment \{align} exceeds natural alignment 3",
        )
      }
      stack.pop(F64) // value
      stack.pop(ctx.mems[memidx].addr_type()) // address
    }
    MemorySize(memidx) | MemoryGrow(memidx) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      let addr_type = ctx.mems[memidx].addr_type()
      if instr is MemoryGrow(_) {
        stack.pop(addr_type) // delta
      }
      stack.push(addr_type)
    }
    MemoryInit(memidx, data_idx) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      if data_idx >= ctx.data_count {
        raise InvalidDataIndex(data_idx)
      }
      let addr_type = ctx.mems[memidx].addr_type()
      stack.pop(I32) // n (always i32 for data segment offset)
      stack.pop(I32) // s (always i32 for data segment offset)
      stack.pop(addr_type) // d (memory address)
    }
    DataDrop(data_idx) =>
      if data_idx >= ctx.data_count {
        raise InvalidDataIndex(data_idx)
      }
    MemoryCopy(dst, src) => {
      if dst >= ctx.mems.length() {
        raise InvalidMemoryIndex(dst)
      }
      if src >= ctx.mems.length() {
        raise InvalidMemoryIndex(src)
      }
      let dst_addr_type = ctx.mems[dst].addr_type()
      let src_addr_type = ctx.mems[src].addr_type()
      // The length uses the smaller of the two address types.
      let n_type = if dst_addr_type == I64 && src_addr_type == I64 {
        @types.ValueType::I64
      } else {
        I32
      }
      stack.pop(n_type) // n
      stack.pop(src_addr_type) // s
      stack.pop(dst_addr_type) // d
    }
    MemoryFill(memidx) => {
      if memidx >= ctx.mems.length() {
        raise InvalidMemoryIndex(memidx)
      }
      let addr_type = ctx.mems[memidx].addr_type()
      stack.pop(addr_type) // n
      stack.pop(I32) // val (always i32)
      stack.pop(addr_type) // d
    }
    Atomic(subop, memidx, align, offset) => {
      // Atomics use memarg except atomic.fence (subop=3).
      if subop != 3 {
        if memidx >= ctx.mems.length() {
          raise InvalidMemoryIndex(memidx)
        }
        validate_mem_offset(ctx.mems[memidx], offset)
      }
      let addr_type = if memidx < ctx.mems.length() {
        ctx.mems[memidx].addr_type()
      } else {
        I32
      }
      fn check_align(
        natural : Int32,
        name : String,
      ) -> Unit raise ValidationError {
        if align != natural {
          raise InvalidAlignment(
            "\{name} alignment \{align} must equal natural alignment \{natural}",
          )
        }
      }

      // Reject the legacy/reserved encoding range [4, 0x10).
      // In the standard encoding, atomics (except notify/wait/fence) start at 0x10.
      if subop >= 4 && subop < 0x10 {
        raise TypeMismatch("unsupported atomic subopcode \{subop}")
      }

      // Normalize subopcode encoding: in the standard encoding most ops start at 0x10.
      let op = if subop >= 0x10 { subop - 12 } else { subop }
      match op {
        0 => {
          check_align(2, "memory.atomic.notify")
          stack.pop(I32) // count
          stack.pop(addr_type) // addr
          stack.push(I32)
        }
        1 => {
          check_align(2, "memory.atomic.wait32")
          stack.pop(I64) // timeout
          stack.pop(I32) // expected
          stack.pop(addr_type) // addr
          stack.push(I32)
        }
        2 => {
          check_align(3, "memory.atomic.wait64")
          stack.pop(I64) // timeout
          stack.pop(I64) // expected
          stack.pop(addr_type) // addr
          stack.push(I32)
        }
        3 => () // atomic.fence
        4 | 6 | 7 => {
          // i32.atomic.load / load8_u / load16_u
          let natural = if op == 4 { 2 } else if op == 6 { 0 } else { 1 }
          check_align(natural, "i32.atomic.load")
          stack.pop(addr_type)
          stack.push(I32)
        }
        5 | 8 | 9 | 10 => {
          // i64.atomic.load / load8_u / load16_u / load32_u
          let natural = if op == 5 {
            3
          } else if op == 8 {
            0
          } else if op == 9 {
            1
          } else {
            2
          }
          check_align(natural, "i64.atomic.load")
          stack.pop(addr_type)
          stack.push(I64)
        }
        11 | 13 | 14 => {
          // i32.atomic.store / store8 / store16
          let natural = if op == 11 { 2 } else if op == 13 { 0 } else { 1 }
          check_align(natural, "i32.atomic.store")
          stack.pop(I32)
          stack.pop(addr_type)
        }
        12 | 15 | 16 | 17 => {
          // i64.atomic.store / store8 / store16 / store32
          let natural = if op == 12 {
            3
          } else if op == 15 {
            0
          } else if op == 16 {
            1
          } else {
            2
          }
          check_align(natural, "i64.atomic.store")
          stack.pop(I64)
          stack.pop(addr_type)
        }

        // RMW add/sub/and/or/xor/xchg
        18
        | 20
        | 21
        | 25
        | 27
        | 28
        | 32
        | 34
        | 35
        | 39
        | 41
        | 42
        | 46
        | 48
        | 49
        | 53
        | 55
        | 56 => {
          // i32 variants (32/8/16)
          let natural = if op == 18 ||
            op == 25 ||
            op == 32 ||
            op == 39 ||
            op == 46 ||
            op == 53 {
            2
          } else if op == 20 ||
            op == 27 ||
            op == 34 ||
            op == 41 ||
            op == 48 ||
            op == 55 {
            0
          } else {
            1
          }
          check_align(natural, "i32.atomic.rmw")
          stack.pop(I32)
          stack.pop(addr_type)
          stack.push(I32)
        }
        19
        | 22
        | 23
        | 24
        | 26
        | 29
        | 30
        | 31
        | 33
        | 36
        | 37
        | 38
        | 40
        | 43
        | 44
        | 45
        | 47
        | 50
        | 51
        | 52
        | 54
        | 57
        | 58
        | 59 => {
          // i64 variants (64/8/16/32)
          let natural = if op == 19 ||
            op == 26 ||
            op == 33 ||
            op == 40 ||
            op == 47 ||
            op == 54 {
            3
          } else if op == 22 ||
            op == 29 ||
            op == 36 ||
            op == 43 ||
            op == 50 ||
            op == 57 {
            0
          } else if op == 23 ||
            op == 30 ||
            op == 37 ||
            op == 44 ||
            op == 51 ||
            op == 58 {
            1
          } else {
            2
          }
          check_align(natural, "i64.atomic.rmw")
          stack.pop(I64)
          stack.pop(addr_type)
          stack.push(I64)
        }

        // cmpxchg
        60 | 62 | 63 => {
          // i32 cmpxchg + 8/16
          let natural = if op == 60 { 2 } else if op == 62 { 0 } else { 1 }
          check_align(natural, "i32.atomic.rmw.cmpxchg")
          stack.pop(I32) // replacement
          stack.pop(I32) // expected
          stack.pop(addr_type)
          stack.push(I32)
        }
        61 | 64 | 65 | 66 => {
          // i64 cmpxchg + 8/16/32
          let natural = if op == 61 {
            3
          } else if op == 64 {
            0
          } else if op == 65 {
            1
          } else {
            2
          }
          check_align(natural, "i64.atomic.rmw.cmpxchg")
          stack.pop(I64) // replacement
          stack.pop(I64) // expected
          stack.pop(addr_type)
          stack.push(I64)
        }
        _ => raise TypeMismatch("unsupported atomic subopcode \{subop}")
      }
    }

    // Table operations
    TableGet(idx) => {
      if idx >= ctx.tables.length() {
        raise InvalidTableIndex(idx)
      }
      let table = ctx.get_table_type(idx)
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(idx_type) // index
      stack.push(table.elem_type)
    }
    TableSet(idx) => {
      if idx >= ctx.tables.length() {
        raise InvalidTableIndex(idx)
      }
      let table = ctx.get_table_type(idx)
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(table.elem_type) // value
      stack.pop(idx_type) // index
    }
    TableSize(idx) => {
      if idx >= ctx.tables.length() {
        raise InvalidTableIndex(idx)
      }
      let table = ctx.get_table_type(idx)
      if table.is_table64 {
        stack.push(I64)
      } else {
        stack.push(I32)
      }
    }
    TableGrow(idx) => {
      if idx >= ctx.tables.length() {
        raise InvalidTableIndex(idx)
      }
      let table = ctx.get_table_type(idx)
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(idx_type) // delta
      stack.pop(table.elem_type) // init value
      stack.push(idx_type) // old size or -1
    }
    TableFill(idx) => {
      if idx >= ctx.tables.length() {
        raise InvalidTableIndex(idx)
      }
      let table = ctx.get_table_type(idx)
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(idx_type) // n
      stack.pop(table.elem_type) // value
      stack.pop(idx_type) // i
    }
    TableCopy(dst_idx, src_idx) => {
      if dst_idx >= ctx.tables.length() {
        raise InvalidTableIndex(dst_idx)
      }
      if src_idx >= ctx.tables.length() {
        raise InvalidTableIndex(src_idx)
      }
      // Check that source element type is subtype of destination element type
      let dst_table = ctx.get_table_type(dst_idx)
      let src_table = ctx.get_table_type(src_idx)
      if !ctx.subtyping_ctx.value_type_subtype(
          src_table.elem_type,
          dst_table.elem_type,
        ) {
        raise TypeMismatch(
          "table.copy: source element type \{src_table.elem_type} is not subtype of destination element type \{dst_table.elem_type}",
        )
      }
      // Length uses i64 only if BOTH tables are table64 (minimum of both types)
      let len_type = if dst_table.is_table64 && src_table.is_table64 {
        @types.ValueType::I64
      } else {
        I32
      }
      stack.pop(len_type) // n
      // Source index uses source table's index type
      stack.pop(if src_table.is_table64 { I64 } else { I32 }) // s
      // Dest index uses dest table's index type
      stack.pop(if dst_table.is_table64 { I64 } else { I32 }) // d
    }
    TableInit(table_idx, elem_idx) => {
      // Validate table and elem indices
      if table_idx >= ctx.tables.length() {
        raise InvalidTableIndex(table_idx)
      }
      if elem_idx >= ctx.elems.length() {
        raise InvalidElemIndex(elem_idx)
      }
      // Check elem segment type matches table element type
      let table = ctx.get_table_type(table_idx)
      let elem_type = ctx.elems[elem_idx]
      if !ctx.subtyping_ctx.value_type_subtype(elem_type, table.elem_type) {
        raise TypeMismatch(
          "element segment type \{elem_type} is not subtype of table element type \{table.elem_type}",
        )
      }
      // For table64: d uses table's index type, s and n are always i32
      // (s is offset into elem segment, n is count - both use i32 since elem is i32-indexed)
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(I32) // n (always i32 - elem segments are i32-indexed)
      stack.pop(I32) // s (always i32 - offset into elem segment)
      stack.pop(idx_type) // d (table's index type)
    }
    ElemDrop(elem_idx) =>
      if elem_idx >= ctx.elems.length() {
        raise InvalidElemIndex(elem_idx)
      }

    // Reference instructions
    RefNull(ref_type) => {
      validate_value_type(
        ref_type,
        ctx.types.length(),
        stack_switching=ctx.stack_switching,
      )
      validate_reference_metadata(ref_type, ctx.types)
      stack.push(to_nullable_ref_type(ref_type))
    }
    RefIsNull => {
      ignore(stack.pop_ref_any())
      stack.push(I32)
    }
    RefEqInstr => {
      let a = stack.pop_maybe_shared_ref(-19)
      let b = stack.pop_maybe_shared_ref(-19)
      if a is Known(at) &&
        b is Known(bt) &&
        at.heap().unwrap().1 != bt.heap().unwrap().1 {
        raise TypeMismatch("ref.eq operands must have matching sharedness")
      }
      stack.push(I32)
    }
    RefFunc(func_idx) => {
      if func_idx >= ctx.funcs.length() {
        raise InvalidFunctionIndex(func_idx)
      }
      // Check that function is declared (referenced in elem segment or global init)
      if !ctx.constant && !ctx.declared_funcs.contains(func_idx) {
        raise UndeclaredFunctionReference(func_idx)
      }
      // ref.func produces (ref $t) where $t is the function's type index
      let type_idx = ctx.funcs[func_idx]
      stack.push(ctx.reference(false, type_idx))
    }
    RefAsNonNull => {
      // ref.as_non_null: pops nullable ref, pushes refined non-null ref
      let nullable_ref = stack.pop_ref_any()
      stack.push_operand(non_nullable_operand(nullable_ref))
    }
    BrOnNull(label_idx) => {
      // br_on_null: pop branch args + ref; on fallthrough push args back + non-null ref
      if label_idx > ctx.labels.length() {
        raise InvalidLabelIndex(label_idx)
      }
      let branch_types = if label_idx == ctx.labels.length() {
        ctx.returns
      } else {
        let label = ctx.labels[ctx.labels.length() - 1 - label_idx]
        get_label_types(ctx, label)
      }
      let nullable_ref = stack.pop_ref_any()
      stack.pop_push_types(branch_types)
      stack.push_operand(non_nullable_operand(nullable_ref))
    }
    BrOnNonNull(label_idx) => {
      // br_on_non_null: pop branch prefix + ref; on fallthrough push only prefix back
      if label_idx > ctx.labels.length() {
        raise InvalidLabelIndex(label_idx)
      }
      let branch_types = if label_idx == ctx.labels.length() {
        ctx.returns
      } else {
        let label = ctx.labels[ctx.labels.length() - 1 - label_idx]
        get_label_types(ctx, label)
      }
      if branch_types.length() == 0 {
        raise TypeMismatch("br_on_non_null target must carry a reference value")
      }
      let branch_ref = branch_types[branch_types.length() - 1]
      if !is_reference_type(branch_ref) {
        raise TypeMismatch("br_on_non_null target must carry a reference value")
      }
      let expected_nullable_ref = to_nullable_ref_type(branch_ref)
      ignore(stack.pop_operand(Some(expected_nullable_ref)))
      stack.pop_push_types(branch_types[:branch_types.length() - 1])
    }

    // Control flow
    Nop => ()
    Unreachable => stack.set_polymorphic()
    Drop => ignore(stack.pop_operand(None))
    Select => {
      stack.pop(I32) // condition
      let a = stack.pop_operand(None)
      let b = stack.pop_operand(None)
      match (a, b) {
        (UnknownRef(_), _) | (_, UnknownRef(_)) =>
          raise TypeMismatch("untyped select requires numeric operands")
        (Known(ty), _) | (_, Known(ty)) if is_reference_type(ty) =>
          raise TypeMismatch("untyped select requires numeric operands")
        (Bottom, other) | (other, Bottom) => stack.push_operand(other)
        (Known(a), Known(b)) => {
          if a != b {
            raise TypeMismatch("select operands have different types")
          }
          stack.push(a)
        }
      }
    }
    SelectTyped(types) => {
      // Select must have exactly one result type
      if types.length() != 1 {
        raise TypeMismatch("invalid result arity")
      }
      // Validate type indices
      let num_types = ctx.types.length()
      for ty in types {
        validate_value_type(ty, num_types, stack_switching=ctx.stack_switching)
        validate_reference_metadata(ty, ctx.types)
      }
      stack.pop(I32) // condition
      // Pop operands matching result types in reverse
      for i = types.length() - 1; i >= 0; i = i - 1 {
        stack.pop(types[i])
        stack.pop(types[i])
      }
      // Push results
      for ty in types {
        stack.push(ty)
      }
    }

    // Function calls
    Call(func_idx) => {
      if func_idx >= ctx.funcs.length() {
        raise InvalidFunctionIndex(func_idx)
      }
      let type_idx = ctx.funcs[func_idx]
      let func_type = ctx.get_func_type(type_idx)
      // Pop parameters in reverse order
      let num_params = func_type.params.length()
      for offset in 0..<num_params {
        let i = num_params - 1 - offset
        stack.pop(func_type.params[i])
      }
      // Push results
      for result in func_type.results {
        stack.push(result)
      }
    }
    CallIndirect(type_idx, table_idx) => {
      if table_idx < 0 || table_idx >= ctx.tables.length() {
        raise InvalidTableIndex(table_idx)
      }
      // call_indirect requires a funcref table
      let table = ctx.get_table_type(table_idx)
      if !ctx.subtyping_ctx.value_type_subtype(table.elem_type, FuncRef) {
        raise TypeMismatch(
          "call_indirect requires funcref table, got \{table.elem_type}",
        )
      }
      if type_idx < 0 || type_idx >= ctx.types.length() {
        raise InvalidTypeIndex(type_idx)
      }
      // Table index uses i64 for table64
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(idx_type) // table index
      let func_type = ctx.get_func_type(type_idx)
      let num_ci_params = func_type.params.length()
      for offset in 0..<num_ci_params {
        let i = num_ci_params - 1 - offset
        stack.pop(func_type.params[i])
      }
      for result in func_type.results {
        stack.push(result)
      }
    }
    CallRef(type_idx) => {
      if type_idx < 0 || type_idx >= ctx.types.length() {
        raise InvalidTypeIndex(type_idx)
      }
      let func_type = ctx.get_func_type(type_idx)
      // Pop the function reference (ref null $t)
      // In unreachable context, this may be a polymorphic type
      stack.pop(ctx.reference(true, type_idx))
      // Pop parameters in reverse order
      let num_params = func_type.params.length()
      for offset in 0..<num_params {
        let i = num_params - 1 - offset
        stack.pop(func_type.params[i])
      }
      // Push results
      for result in func_type.results {
        stack.push(result)
      }
    }
    ReturnCall(func_idx) => {
      if func_idx >= ctx.funcs.length() {
        raise InvalidFunctionIndex(func_idx)
      }
      let type_idx = ctx.funcs[func_idx]
      let func_type = ctx.get_func_type(type_idx)
      // Pop parameters in reverse order
      let num_params = func_type.params.length()
      for offset in 0..<num_params {
        let i = num_params - 1 - offset
        stack.pop(func_type.params[i])
      }
      // Validate results match current function's return type
      // (For tail calls, we return the called function's results)
      for i = 0; i < func_type.results.length(); i = i + 1 {
        if i >= ctx.returns.length() ||
          !ctx.subtyping_ctx.value_type_subtype(
            func_type.results[i],
            ctx.returns[i],
          ) {
          raise TypeMismatch("return_call result type mismatch")
        }
      }
      if func_type.results.length() != ctx.returns.length() {
        raise TypeMismatch("return_call result count mismatch")
      }
      // After return_call, the stack is unreachable
      stack.set_polymorphic()
    }
    ReturnCallIndirect(type_idx, table_idx) => {
      if table_idx < 0 || table_idx >= ctx.tables.length() {
        raise InvalidTableIndex(table_idx)
      }
      // return_call_indirect requires a funcref table
      let table = ctx.get_table_type(table_idx)
      if !ctx.subtyping_ctx.value_type_subtype(table.elem_type, FuncRef) {
        raise TypeMismatch(
          "return_call_indirect requires funcref table, got \{table.elem_type}",
        )
      }
      if type_idx < 0 || type_idx >= ctx.types.length() {
        raise InvalidTypeIndex(type_idx)
      }
      // Table index uses i64 for table64
      let idx_type = if table.is_table64 { @types.ValueType::I64 } else { I32 }
      stack.pop(idx_type) // table index
      let func_type = ctx.get_func_type(type_idx)
      let num_params = func_type.params.length()
      for offset in 0..<num_params {
        let i = num_params - 1 - offset
        stack.pop(func_type.params[i])
      }
      // Validate results match current function's return type
      for i = 0; i < func_type.results.length(); i = i + 1 {
        if i >= ctx.returns.length() ||
          !ctx.subtyping_ctx.value_type_subtype(
            func_type.results[i],
            ctx.returns[i],
          ) {
          raise TypeMismatch("return_call_indirect result type mismatch")
        }
      }
      if func_type.results.length() != ctx.returns.length() {
        raise TypeMismatch("return_call_indirect result count mismatch")
      }
      // After return_call_indirect, the stack is unreachable
      stack.set_polymorphic()
    }
    ReturnCallRef(type_idx) => {
      if type_idx < 0 || type_idx >= ctx.types.length() {
        raise InvalidTypeIndex(type_idx)
      }
      let func_type = ctx.get_func_type(type_idx)
      // Pop the function reference (ref null $t)
      stack.pop(ctx.reference(true, type_idx))
      // Pop parameters in reverse order
      let num_params = func_type.params.length()
      for offset in 0..<num_params {
        let i = num_params - 1 - offset
        stack.pop(func_type.params[i])
      }
      // Validate results match current function's return type
      for i = 0; i < func_type.results.length(); i = i + 1 {
        if i >= ctx.returns.length() ||
          !ctx.subtyping_ctx.value_type_subtype(
            func_type.results[i],
            ctx.returns[i],
          ) {
          raise TypeMismatch("return_call_ref result type mismatch")
        }
      }
      if func_type.results.length() != ctx.returns.length() {
        raise TypeMismatch("return_call_ref result count mismatch")
      }
      // After return_call_ref, the stack is unreachable
      stack.set_polymorphic()
    }

    // Block, Loop, If - with stack height validation and label tracking
    Block(_, _)
    | Loop(_, _)
    | If(_, _, _)
    | TryTable(_, _, _)
    | LegacyTry(_, _, _, _) =>
      raise TypeMismatch(
        "structured instruction requires expression work stack",
      )

    // Branch instructions with proper label validation
    Br(label_idx) => {
      if label_idx > ctx.labels.length() {
        raise InvalidLabelIndex(label_idx)
      }
      // label_idx == labels.length() targets the implicit function label.
      // This is how `br 0` at function top-level behaves (acts like return).
      let branch_types = if label_idx == ctx.labels.length() {
        ctx.returns
      } else {
        // Get label from stack (index 0 is innermost)
        let label = ctx.labels[ctx.labels.length() - 1 - label_idx]
        get_label_types(ctx, label)
      }
      // Pop values that will be passed to target
      for i = branch_types.length() - 1; i >= 0; i = i - 1 {
        stack.pop(branch_types[i])
      }
      stack.set_polymorphic()
    }
    BrIf(label_idx) => {
      stack.pop(I32) // condition
      if label_idx > ctx.labels.length() {
        raise InvalidLabelIndex(label_idx)
      }
      let branch_types = if label_idx == ctx.labels.length() {
        ctx.returns
      } else {
        let label = ctx.labels[ctx.labels.length() - 1 - label_idx]
        get_label_types(ctx, label)
      }
      // Pop and push values (conditional branch)
      for i = branch_types.length() - 1; i >= 0; i = i - 1 {
        stack.pop(branch_types[i])
      }
      for ty in branch_types {
        stack.push(ty)
      }
    }
    BrTable(labels, default_label) => {
      stack.pop(I32) // index
      // Validate default label
      if default_label > ctx.labels.length() {
        raise InvalidLabelIndex(default_label)
      }
      let default_types = if default_label == ctx.labels.length() {
        ctx.returns
      } else {
        let default_info = ctx.labels[ctx.labels.length() - 1 - default_label]
        get_label_types(ctx, default_info)
      }
      // Validate all labels have same arity as default
      for label_idx in labels {
        if label_idx > ctx.labels.length() {
          raise InvalidLabelIndex(label_idx)
        }
        let label_types = if label_idx == ctx.labels.length() {
          ctx.returns
        } else {
          let label_info = ctx.labels[ctx.labels.length() - 1 - label_idx]
          get_label_types(ctx, label_info)
        }
        if label_types.length() != default_types.length() {
          raise TypeMismatch(
            "br_table labels must have same arity: expected \{default_types.length()}, got \{label_types.length()}",
          )
        }
        // Every target must accept the original operands, including when
        // unreachable operands are polymorphic. Checking arity alone is unsafe.
        stack.check_branch_values(label_types)
      }
      // Pop values
      for i = default_types.length() - 1; i >= 0; i = i - 1 {
        stack.pop(default_types[i])
      }
      stack.set_polymorphic()
    }
    Return => {
      // Validate return values match function signature
      for i = ctx.returns.length() - 1; i >= 0; i = i - 1 {
        stack.pop(ctx.returns[i])
      }
      stack.set_polymorphic()
    }

    // Exception handling instructions
    Throw(tag_idx) => {
      // Validate tag index is valid
      if tag_idx < 0 || tag_idx >= ctx.tags.length() {
        raise UnknownTag(tag_idx)
      }
      // Get the tag type and pop its parameters from the stack
      let tag_type = ctx.exception_tag_type(tag_idx)
      for i = tag_type.params.length() - 1; i >= 0; i = i - 1 {
        stack.pop(tag_type.params[i])
      }
      // throw never returns, so set polymorphic
      stack.set_polymorphic()
    }
    Rethrow(depth) => {
      if depth < 0 || depth >= ctx.labels.length() {
        raise InvalidLabelIndex(depth)
      }
      if ctx.labels[ctx.labels.length() - 1 - depth].kind != LegacyCatchLabel {
        raise TypeMismatch("rethrow label must name a legacy catch")
      }
      stack.set_polymorphic()
    }
    ThrowRef => {
      // throw_ref pops an exnref and throws it
      stack.pop(ExnRef)
      stack.set_polymorphic()
    }
    // GC instructions - struct operations
    StructNew(type_idx) => {
      // Pop field values, push struct ref
      let struct_type = ctx.get_struct_type(type_idx)
      for i = struct_type.fields.length() - 1; i >= 0; i = i - 1 {
        stack.pop(
          storage_type_to_value_type(struct_type.fields[i].storage_type),
        )
      }
      stack.push(ctx.reference(false, type_idx))
    }
    StructNewDefault(type_idx) => {
      let struct_type = ctx.get_struct_type(type_idx)
      for field in struct_type.fields {
        require_defaultable(field.storage_type)
      }
      stack.push(ctx.reference(false, type_idx))
    }
    StructGet(type_idx, field_idx)
    | StructGetS(type_idx, field_idx)
    | StructGetU(type_idx, field_idx) => {
      // Resolve the type before popping against it, so a `type_idx` that
      // names no struct is rejected rather than shaping the operand check.
      let struct_type = ctx.get_struct_type(type_idx)
      stack.pop(ctx.reference(true, type_idx))
      guard struct_type.fields.get(field_idx) is Some(field) else {
        raise TypeMismatch("unknown struct field \{field_idx}")
      }
      let packed_get = match instr {
        StructGetS(_, _) | StructGetU(_, _) => true
        _ => false
      }
      require_get_storage(field.storage_type, packed_get)
      stack.push(storage_type_to_value_type(field.storage_type))
    }
    StructSet(type_idx, field_idx) => {
      // Pop value, pop struct ref
      let struct_type = ctx.get_struct_type(type_idx)
      guard struct_type.fields.get(field_idx) is Some(field) else {
        raise TypeMismatch("unknown struct field \{field_idx}")
      }
      // Check that the field is mutable
      if !field.mutable {
        raise TypeMismatch("struct.set on immutable field")
      }
      stack.pop(storage_type_to_value_type(field.storage_type))
      stack.pop(ctx.reference(true, type_idx))
    }

    // GC instructions - array operations
    ArrayNew(type_idx) => {
      // Pop length (i32), pop init value, push array ref. The element type is
      // read below; looking it up first rejects a non-array `type_idx` before
      // anything is popped against it.
      let array_type = ctx.get_array_type(type_idx)
      stack.pop(I32)
      stack.pop(storage_type_to_value_type(array_type.element.storage_type))
      stack.push(ctx.reference(false, type_idx))
    }
    ArrayNewDefault(type_idx) => {
      let array_type = ctx.get_array_type(type_idx)
      require_defaultable(array_type.element.storage_type)
      stack.pop(I32)
      stack.push(ctx.reference(false, type_idx))
    }
    ArrayNewFixed(type_idx, len) => {
      // Pop len elements, push array ref
      let array_type = ctx.get_array_type(type_idx)
      let elem_type = storage_type_to_value_type(
        array_type.element.storage_type,
      )
      // An immediate u32 count can exceed Int32. Empty unreachable stacks
      // supply every remaining operand without iterating over that count.
      let mut remaining = len.reinterpret_as_uint()
      while remaining > 0U {
        if stack.polymorphic && stack.stack.is_empty() {
          break
        }
        stack.pop(elem_type)
        remaining -= 1U
      }
      stack.push(ctx.reference(false, type_idx))
    }
    ArrayNewData(type_idx, data_idx) => {
      // Pop size (i32), pop offset (i32), push array ref
      let array_type = ctx.get_array_type(type_idx)
      if !is_numeric_or_vector_storage_type(array_type.element.storage_type) {
        raise TypeMismatch("array type is not numeric or vector")
      }
      if data_idx >= ctx.data_count {
        raise TypeMismatch(
          "array.new_data: invalid data segment index \{data_idx}",
        )
      }
      stack.pop(I32)
      stack.pop(I32)
      stack.push(ctx.reference(false, type_idx))
    }
    ArrayNewElem(type_idx, elem_idx) => {
      // Pop size (i32), pop offset (i32), push array ref
      let array_type = ctx.get_array_type(type_idx)
      if elem_idx >= ctx.elems.length() {
        raise InvalidElemIndex(elem_idx)
      }
      let elem_type = ctx.elems[elem_idx]
      let array_elem_type = storage_type_to_value_type(
        array_type.element.storage_type,
      )
      if !is_reference_type(array_elem_type) ||
        !ctx.subtyping_ctx.value_type_subtype(elem_type, array_elem_type) {
        raise TypeMismatch(
          "array.new_elem: element segment type \{elem_type} incompatible with array element type \{array_elem_type}",
        )
      }
      stack.pop(I32)
      stack.pop(I32)
      stack.push(ctx.reference(false, type_idx))
    }
    ArrayGet(type_idx) | ArrayGetS(type_idx) | ArrayGetU(type_idx) => {
      // Pop index (i32), pop array ref, push element
      let array_type = ctx.get_array_type(type_idx)
      let packed_get = match instr {
        ArrayGetS(_) | ArrayGetU(_) => true
        _ => false
      }
      require_get_storage(array_type.element.storage_type, packed_get)
      stack.pop(I32)
      stack.pop(ctx.reference(true, type_idx))
      stack.push(storage_type_to_value_type(array_type.element.storage_type))
    }
    ArraySet(type_idx) => {
      // Pop value, pop index (i32), pop array ref
      let array_type = ctx.get_array_type(type_idx)
      // Check that the array element is mutable
      if !array_type.element.mutable {
        raise TypeMismatch("array.set on immutable array")
      }
      stack.pop(storage_type_to_value_type(array_type.element.storage_type))
      stack.pop(I32)
      stack.pop(ctx.reference(true, type_idx))
    }
    ArrayLen => {
      // Pop array ref (any array type), push i32
      // RefNullArray(-1) matches any nullable array reference
      ignore(stack.pop_maybe_shared_ref(-22))
      stack.push(I32)
    }
    ArrayFill(type_idx) => {
      // Pop n (i32), pop value, pop offset (i32), pop array ref
      let array_type = ctx.get_array_type(type_idx)
      // Check that the array element is mutable
      if !array_type.element.mutable {
        raise TypeMismatch("array.fill on immutable array")
      }
      stack.pop(I32)
      stack.pop(storage_type_to_value_type(array_type.element.storage_type))
      stack.pop(I32)
      stack.pop(ctx.reference(true, type_idx))
    }
    ArrayCopy(dst_type, src_type) => {
      // Pop n (i32), pop src_offset (i32), pop src, pop dst_offset (i32), pop dst
      let dst_array = ctx.get_array_type(dst_type)
      let src_array = ctx.get_array_type(src_type)
      // Check that the destination array element is mutable
      if !dst_array.element.mutable {
        raise TypeMismatch("array.copy to immutable array")
      }
      // Check that source element type is compatible with destination element type
      let dst_elem = dst_array.element.storage_type
      let src_elem = src_array.element.storage_type
      let compatible = match (src_elem, dst_elem) {
        (Packed(a), Packed(b)) => a == b
        (Val(src), Val(dst)) => ctx.subtyping_ctx.value_type_subtype(src, dst)
        _ => false
      }
      if !compatible {
        raise TypeMismatch("array.copy: array types do not match")
      }
      stack.pop(I32)
      stack.pop(I32)
      stack.pop(ctx.reference(true, src_type))
      stack.pop(I32)
      stack.pop(ctx.reference(true, dst_type))
    }
    ArrayInitData(type_idx, data_idx) => {
      // Pop n (i32), pop src_offset (i32), pop dst_offset (i32), pop array ref
      let array_type = ctx.get_array_type(type_idx)
      // Check that the array element is mutable
      if !array_type.element.mutable {
        raise TypeMismatch("array.init_data on immutable array")
      }
      if !is_numeric_or_vector_storage_type(array_type.element.storage_type) {
        raise TypeMismatch("array type is not numeric or vector")
      }
      // Check data segment exists
      if data_idx >= ctx.data_count {
        raise TypeMismatch(
          "array.init_data: invalid data segment index \{data_idx}",
        )
      }
      stack.pop(I32)
      stack.pop(I32)
      stack.pop(I32)
      stack.pop(ctx.reference(true, type_idx))
    }
    ArrayInitElem(type_idx, elem_idx) => {
      // Pop n (i32), pop src_offset (i32), pop dst_offset (i32), pop array ref
      let array_type = ctx.get_array_type(type_idx)
      // Check that the array element is mutable
      if !array_type.element.mutable {
        raise TypeMismatch("array.init_elem on immutable array")
      }
      // Check element segment exists and types match
      if elem_idx >= ctx.elems.length() {
        raise InvalidElemIndex(elem_idx)
      }
      let elem_type = ctx.elems[elem_idx]
      let array_elem_type = storage_type_to_value_type(
        array_type.element.storage_type,
      )
      // Check type compatibility - elem segment type must be subtype of array element type
      if !is_reference_type(array_elem_type) ||
        !ctx.subtyping_ctx.value_type_subtype(elem_type, array_elem_type) {
        raise TypeMismatch(
          "array.init_elem: element segment type \{elem_type} incompatible with array element type \{array_elem_type}",
        )
      }
      stack.pop(I32)
      stack.pop(I32)
      stack.pop(I32)
      stack.pop(ctx.reference(true, type_idx))
    }

    // GC instructions - reference casting
    RefTest(target) | RefTestNull(target) => {
      validate_cast_type(ctx, target)
      stack.pop(cast_top_type(ctx, target))
      stack.push(I32)
    }
    RefCast(target) | RefCastNull(target) => {
      validate_cast_type(ctx, target)
      stack.pop(cast_top_type(ctx, target))
      stack.push(target)
    }
    BrOnCast(label_idx, source_type, target_type) => {
      validate_cast_type(ctx, source_type)
      validate_cast_type(ctx, target_type)
      // br_on_cast: Pop source, branch if cast succeeds (push target to label), push diff on fallthrough
      // Validate: target_type must be a subtype of source_type (can only downcast)
      if !ctx.subtyping_ctx.value_type_subtype(target_type, source_type) {
        raise TypeMismatch(
          "br_on_cast: target type \{target_type} is not a subtype of source type \{source_type}",
        )
      }
      // Check that target_type is compatible with branch label
      if label_idx > ctx.labels.length() {
        raise InvalidLabelIndex(label_idx)
      }
      let branch_types = if label_idx == ctx.labels.length() {
        ctx.returns
      } else {
        let label = ctx.labels[ctx.labels.length() - 1 - label_idx]
        get_label_types(ctx, label)
      }
      let diff_type = compute_br_on_cast_fail_diff_type(
        source_type, target_type,
      )
      if branch_types.is_empty() {
        raise TypeMismatch("branch cast target must carry a reference")
      }
      if branch_types.length() >= 1 {
        let expected = branch_types[branch_types.length() - 1]
        if !ctx.subtyping_ctx.value_type_subtype(target_type, expected) {
          raise TypeMismatch(
            "br_on_cast: branch target type \{target_type} not subtype of label type \{expected}",
          )
        }
      }
      // Pop source and any prefix values passed to the branch label.
      stack.pop(source_type)
      stack.pop_push_types(branch_types[:branch_types.length() - 1])
      stack.push(diff_type)
    }
    BrOnCastFail(label_idx, source_type, target_type) => {
      validate_cast_type(ctx, source_type)
      validate_cast_type(ctx, target_type)
      // br_on_cast_fail: Pop source, branch if cast fails (push diff to label), push target on fallthrough
      // Validate: target_type must be a subtype of source_type (can only downcast)
      if !ctx.subtyping_ctx.value_type_subtype(target_type, source_type) {
        raise TypeMismatch(
          "br_on_cast_fail: target type \{target_type} is not a subtype of source type \{source_type}",
        )
      }
      // Check that diff_type is compatible with branch label
      // Diff type: if source is nullable and target is non-nullable, diff is nullable
      // The diff type represents values that fail the cast
      if label_idx > ctx.labels.length() {
        raise InvalidLabelIndex(label_idx)
      }
      let branch_types = if label_idx == ctx.labels.length() {
        ctx.returns
      } else {
        let label = ctx.labels[ctx.labels.length() - 1 - label_idx]
        get_label_types(ctx, label)
      }
      let diff_type = compute_br_on_cast_fail_diff_type(
        source_type, target_type,
      )
      if branch_types.is_empty() {
        raise TypeMismatch("branch cast target must carry a reference")
      }
      if branch_types.length() >= 1 {
        let expected = branch_types[branch_types.length() - 1]
        if !ctx.subtyping_ctx.value_type_subtype(diff_type, expected) {
          raise TypeMismatch(
            "br_on_cast_fail: diff type \{diff_type} not subtype of label type \{expected}",
          )
        }
      }
      // Pop source and branch-prefix values.
      stack.pop(source_type)
      stack.pop_push_types(branch_types[:branch_types.length() - 1])
      stack.push(target_type)
    }

    // GC instructions - i31
    RefI31 => {
      // Pop i32, push i31ref
      stack.pop(I32)
      stack.push(RefI31)
    }
    RefI31Shared => {
      stack.pop(I32)
      stack.push(HeapRef(false, true, -20))
    }
    I31GetS | I31GetU => {
      // Pop i31ref, push i32
      ignore(stack.pop_maybe_shared_ref(-20))
      stack.push(I32)
    }

    // GC instructions - type conversion
    AnyConvertExtern =>
      // Pop externref, push anyref
      stack.push_operand(
        convert_reference(stack.pop_maybe_shared_ref(-17), -18),
      )
    ExternConvertAny =>
      // Pop anyref, push externref
      stack.push_operand(
        convert_reference(stack.pop_maybe_shared_ref(-18), -17),
      )

    // SIMD instructions
    _ => validate_instr_simd(ctx, stack, instr)
  }
}

///|
fn is_numeric_or_vector_value_type(ty : @types.ValueType) -> Bool {
  match ty {
    I32 | I64 | F32 | F64 | V128 => true
    _ => false
  }
}

///|
fn is_numeric_or_vector_storage_type(ty : @types.StorageType) -> Bool {
  match ty {
    Packed(_) => true
    Val(v) => is_numeric_or_vector_value_type(v)
  }
}

///|
fn to_non_nullable_ref_type(
  ty : @types.ValueType,
) -> @types.ValueType raise ValidationError {
  match ty.with_nullable(false) {
    Some(reference) => reference
    None => raise TypeMismatch("expected reference type")
  }
}

///|
fn to_nullable_ref_type(
  ty : @types.ValueType,
) -> @types.ValueType raise ValidationError {
  match ty.with_nullable(true) {
    Some(reference) => reference
    None => raise TypeMismatch("expected reference type")
  }
}

///|
fn non_nullable_operand(operand : Operand) -> Operand raise ValidationError {
  match operand {
    Known(ty) => Known(to_non_nullable_ref_type(ty))
    other => other
  }
}

///|
fn convert_reference(operand : Operand, heap : Int32) -> Operand {
  match operand {
    Known(ty) => {
      let (nullable, shared, _) = ty.heap().unwrap()
      Known(HeapRef(nullable, shared, heap))
    }
    _ => UnknownRef(Some(heap))
  }
}

///|
fn validate_cast_type(
  ctx : ValidationContext,
  target : @types.ValueType,
) -> Unit raise ValidationError {
  validate_value_type(
    target,
    ctx.types.length(),
    stack_switching=ctx.stack_switching,
  )
  validate_reference_metadata(target, ctx.types)
  if !is_reference_type(target) {
    raise TypeMismatch("cast target must be a reference type")
  }
  let (_, _, heap) = cast_top_type(ctx, target).heap().unwrap()
  if heap == -24 {
    raise TypeMismatch("casts cannot target continuation types")
  }
}

///|
fn cast_top_type(
  ctx : ValidationContext,
  target : @types.ValueType,
) -> @types.ValueType raise ValidationError {
  guard target.heap() is Some((_, shared, heap)) else {
    raise TypeMismatch("cast target must be a reference type")
  }
  let heap = if heap >= 0 {
    guard ctx.types.get(heap) is Some(type_) else {
      raise InvalidTypeIndex(heap)
    }
    match type_.composite.unshared() {
      Func(_) => -16
      Struct(_) | Array(_) => -18
      _ => -24
    }
  } else {
    match heap {
      -15 | -18 | -19 | -20 | -21 | -22 => -18
      -13 | -16 => -16
      -14 | -17 => -17
      -12 | -23 => -23
      _ => -24
    }
  }
  HeapRef(true, shared, heap)
}

///|
fn get_block_results(
  ctx : ValidationContext,
  bt : @types.BlockType,
) -> Array[@types.ValueType] raise ValidationError {
  match bt {
    Empty => []
    Value(t) => {
      validate_value_type(
        t,
        ctx.types.length(),
        stack_switching=ctx.stack_switching,
      )
      [t]
    }
    MultiValue(types) => {
      for t in types {
        validate_value_type(
          t,
          ctx.types.length(),
          stack_switching=ctx.stack_switching,
        )
      }
      types
    }
    InlineType(_, results) => {
      for t in results {
        validate_value_type(
          t,
          ctx.types.length(),
          stack_switching=ctx.stack_switching,
        )
      }
      results
    }
    TypeIndex(idx) =>
      if idx < ctx.types.length() {
        ctx.get_func_type(idx).results
      } else {
        raise InvalidTypeIndex(idx)
      }
  }
}

///|
fn get_block_params(
  ctx : ValidationContext,
  bt : @types.BlockType,
) -> Array[@types.ValueType] raise ValidationError {
  match bt {
    Empty => []
    Value(_) => [] // Single value blocks have no params
    MultiValue(_) => [] // MultiValue blocks have no params (result-only)
    InlineType(params, _) => {
      for t in params {
        validate_value_type(
          t,
          ctx.types.length(),
          stack_switching=ctx.stack_switching,
        )
      }
      params
    }
    TypeIndex(idx) =>
      if idx < ctx.types.length() {
        ctx.get_func_type(idx).params
      } else {
        raise InvalidTypeIndex(idx)
      }
  }
}

///|
/// Get the types that a branch to this label should carry
/// For block/if: uses results (br jumps to end)
/// For loop: uses params (br jumps to start)
fn get_label_types(
  ctx : ValidationContext,
  label : LabelInfo,
) -> Array[@types.ValueType] raise ValidationError {
  match label.kind {
    BlockLabel | LegacyTryLabel | LegacyCatchLabel =>
      get_block_results(ctx, label.block_type)
    LoopLabel => get_block_params(ctx, label.block_type)
  }
}

///|
fn validate_catch_handlers(
  ctx : ValidationContext,
  handlers : Array[@types.CatchHandler],
) -> Unit raise ValidationError {
  for handler in handlers {
    let (label, provided) = match handler {
      Catch(tag, label) => (label, ctx.exception_tag_type(tag).params)
      CatchRef(tag, label) => {
        let types = ctx.exception_tag_type(tag).params.copy()
        types.push(HeapRef(false, false, -23))
        (label, types)
      }
      CatchAll(label) => (label, [])
      CatchAllRef(label) =>
        (label, [@types.ValueType::HeapRef(false, false, -23)])
    }
    if label < 0 || label > ctx.labels.length() {
      raise InvalidLabelIndex(label)
    }
    let expected = if label == ctx.labels.length() {
      ctx.returns
    } else {
      get_label_types(ctx, ctx.labels[ctx.labels.length() - 1 - label])
    }
    if provided.length() != expected.length() {
      raise TypeMismatch("catch handler arity mismatch")
    }
    for i, actual in provided {
      if !ctx.subtyping_ctx.value_type_subtype(actual, expected[i]) {
        raise TypeMismatch("catch handler type mismatch")
      }
    }
  }
}

///|
fn require_defaultable(
  storage : @types.StorageType,
) -> Unit raise ValidationError {
  let ty = storage_type_to_value_type(storage)
  if ty.heap() is Some((false, _, _)) {
    raise TypeMismatch("default initializer requires nullable reference fields")
  }
}

///|
fn require_get_storage(
  storage : @types.StorageType,
  packed_get : Bool,
) -> Unit raise ValidationError {
  let packed = match storage {
    Packed(_) => true
    Val(_) => false
  }
  if packed != packed_get {
    raise TypeMismatch(
      "packed storage requires get_s or get_u; unpacked storage requires get",
    )
  }
}
