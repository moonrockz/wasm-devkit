(module
  (type $f (;0;) (shared (func)))
  (global $g (;0;) (shared mut i32) i32.const 1)
  (func (;0;) (type $f)
    i32.const 2
    global.set $g
  )
)
