(module
  (type (;0;) (func (param i32)))
  (type (;1;) (func (param i32 i64)))
  (import "env" "e" (tag $e (type 0) (param i32)))
  (tag $t (type 1) (param i32 i64))
  (export "t" (tag $t))
  (@custom "name" "\0b\07\02\00\01e\01\01t"))
