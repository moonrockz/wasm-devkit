(component  (core type $ct (func (param i32) (result i64))) (import "f" (func $f async (param "p0" u32) (result u64))) (core func $lower (canon lower (func $f) gc (core-type $ct) async)))
