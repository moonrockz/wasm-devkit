(component (core module $m
 (tag $e (param i32))
 (func (export "catch") (result i32) try (result i32) i32.const 3 throw $e catch $e end)
 (func (export "rethrow") try i32.const 1 throw $e catch_all rethrow 0 end)) (export "m" (core module $m)))
