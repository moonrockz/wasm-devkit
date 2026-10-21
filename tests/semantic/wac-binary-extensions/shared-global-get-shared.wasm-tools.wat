(module
  (type $f (;0;) (shared (func (result i32))))
  (global $g (;0;) (shared i32) i32.const 1)
  (func (;0;) (type $f)
    global.get $g
  )
)
