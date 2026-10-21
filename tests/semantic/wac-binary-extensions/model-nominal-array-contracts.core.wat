(module
 (type $base (sub (array anyref)))
 (type $child (sub $base (array i31ref)))
 (func (export "make") (result (ref $base)) ref.null i31 i32.const 0 array.new $child)
 (table (export "child") 0 (ref null $child)))
