(component (core type $a (module (export "f" (func (result i32))))) (core module (func (export "f") (result i32) i32.const 42)) (export "m" (core module 0) (core module (type $a))))
