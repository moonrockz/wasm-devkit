(component
  (core type $f (;0;) (func (param i32)))
  (core type $m (;1;)
    (module
      (alias outer 1 $f (type (;0;)))
      (export "f" (func (type 0)))
    )
  )
  (import "m" (core module $m (;0;) (type $m)))
  (export (;1;) "out" (core module $m))
)
