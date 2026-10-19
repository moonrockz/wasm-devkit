(component  (core type $ct (func (param i32) (result i64))) (import "f" (func $f  (param "p0" u32) (result u64))) (core func $lower (canon lower (func $f) gc gc (core-type $ct))))
