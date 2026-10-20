(component
  (core type $a (;0;) (func (param i32 i64) (result i32)))
  (core type $m (;1;)
    (module
      (type (;0;) (func))
      (import "env" "a" (func (type 0)))
      (export "f" (func (type 0)))
    )
  )
  (import "m" (core module $m (;0;) (type $m)))
)
