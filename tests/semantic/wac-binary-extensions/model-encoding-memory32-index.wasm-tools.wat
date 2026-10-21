(module
  (type (;0;) (func (result i32)))
  (memory (;0;) 1)
  (memory (;1;) 2)
  (export "target" (memory 1))
  (export "load" (func 0))
  (func (;0;) (type 0) (result i32)
    i32.const 0
    i32.load 1
  )
)
