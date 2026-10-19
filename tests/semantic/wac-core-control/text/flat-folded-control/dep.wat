(component (core module $m (func (export "f") (result i32) block (result i32) (if (result i32) (i32.const 1) (then (i32.const 2)) (else (i32.const 3))) end)) (export "module" (core module $m)))
