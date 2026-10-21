(module
  (type $base (;0;) (sub (array anyref)))
  (type $child (;1;) (sub $base (array i31ref)))
  (type (;2;) (func (result (ref $base))))
  (table (;0;) 0 (ref null $child))
  (export "make" (func 0))
  (export "child" (table 0))
  (func (;0;) (type 2) (result (ref $base))
    ref.null i31
    i32.const 0
    array.new $child
  )
)
