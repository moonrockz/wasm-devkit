(component (core module $m (import "env" "a" (global $a (shared i32))) (global (export "g") (shared i32) (global.get $a))) (export "m" (core module $m)))
