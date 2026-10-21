(module
  (rec
    (type $a (;0;) (func (param i32)))
    (type $b (;1;) (func (result i64)))
  )
  (import "env" "a" (func (;0;) (type $a) (param i32)))
  (export "b" (func 1))
  (func (;1;) (type $b) (result i64)
    i64.const 2
  )
)
