(module
  (type (;0;) (func (param i64) (result i64)))
  (memory (;0;) 1)
  (memory (;1;) i64 2)
  (export "target" (memory 1))
  (export "load" (func 0))
  (func (;0;) (type 0) (param i64) (result i64)
    local.get 0
    i64.load 1 offset=18446744073709551615
  )
)
