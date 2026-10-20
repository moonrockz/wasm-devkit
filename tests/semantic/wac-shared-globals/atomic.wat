(component (core module $m (global $g (shared mut i32) (i32.const 0)) (func (result i32) global.atomic.get seqcst $g)) (export "m" (core module $m)))
