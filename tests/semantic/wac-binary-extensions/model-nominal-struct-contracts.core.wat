(module
 (type $base (sub (struct (field i32))))
 (type $child (sub $base (struct (field i32) (field (mut i64)))))
 (func (export "make") (result (ref $base)) i32.const 1 i64.const 2 struct.new $child)
 (global (export "child") (ref $child) i32.const 1 i64.const 2 struct.new $child))
