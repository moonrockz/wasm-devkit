(component (core type $t (module (export "g" (global (shared i32))))) (core module $m (global (export "g") i32 (i32.const 1))) (export "m" (core module $m) (core module (type $t))))
