(component (core module $m (tag (param i32)) (func  block $outer (result i32) try_table $inner (catch 0 $outer) i32.const 1 throw 0 end unreachable end drop)) (export "m" (core module $m)))
