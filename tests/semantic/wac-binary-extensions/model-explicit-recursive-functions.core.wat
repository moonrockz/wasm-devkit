(module (rec (type $a (func (param i32))) (type $b (func (result i64))))
 (import "env" "a" (func (type $a)))
 (func (export "b") (type $b) i64.const 2))
