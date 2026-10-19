(component (core type $a (module )) (core type $b (module (export "value" (global i32)))) (import "m" (core module (type $a))) (export "m" (core module 0) (core module (type $b))))
