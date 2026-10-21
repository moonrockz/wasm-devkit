(component (core module $m (memory 1) (memory (export "target") 2) (func (export "load") (result i32) i32.const 0 i32.load 1)) (export "m" (core module $m)))
