(module
  (type (;0;) (func))
  (type (;1;) (func (param i32)))
  (table (;0;) 1 funcref)
  (memory (;0;) 1)
  (tag (;0;) (type 1) (param i32))
  (global (;0;) i32 i32.const 0)
  (export "run" (func 0))
  (func (;0;) (type 0)
    nop
  )
  (data (;0;) (i32.const 0) "x")
  (@custom "linking" (after data) "\02\08'\05\00\00\00\03run\02\00\00\04glob\05\00\00\03tab\01\00\03dat\00\00\01\04\00\00\03tag")
)
