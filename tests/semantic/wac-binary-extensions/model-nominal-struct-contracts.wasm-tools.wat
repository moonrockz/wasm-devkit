(module
  (type $base (;0;) (sub (struct (field i32))))
  (type $child (;1;) (sub $base (struct (field i32) (field (mut i64)))))
  (type (;2;) (func (result (ref $base))))
  (global (;0;) (ref $child) i32.const 1 i64.const 2 struct.new $child)
  (export "make" (func 0))
  (export "child" (global 0))
  (func (;0;) (type 2) (result (ref $base))
    i32.const 1
    i64.const 2
    struct.new $child
  )
)
