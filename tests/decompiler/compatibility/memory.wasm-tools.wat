(module
  (type (;0;) (func (result i32)))
  (memory $m (;0;) 1)
  (memory $other (;1;) 1)
  (func (;0;) (type 0) (result i32)
    i32.const 0
    i32.load align=1
    drop
    i32.const 0
    i64.load8_s $other
    drop
    i32.const 0
    i64.load32_u
    drop
    memory.size
    drop
    i32.const 0
    i32.const 0
    i32.const 0
    memory.copy
    memory.size $other
  )
)
