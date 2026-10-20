(module
  (type (;0;) (func (param i32 i64 f32) (result i32 i64 f32)))
  (type (;1;) (func (param i32 i64 f32 f64)))
  (func (;0;) (type 0) (param i32 i64 f32) (result i32 i64 f32)
    (local i32 i64)
    local.get 0
    local.get 1
    local.get 2)
  (func (;1;) (type 1) (param $a i32) (param i64 f32) (param $b f64)
    (local $c i32) (local i64 f32))
  (@custom "name" "\02\0c\01\01\03\00\01a\03\01b\04\01c"))
