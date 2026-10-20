(module $m
  (type $sig (;0;) (func (param i32 i64) (result i32)))
  (import "env" "f" (func $import (;0;) (type $sig) (param i32 i64) (result i32)))
  (table $tab (;0;) 2 funcref)
  (memory $mem (;0;) 1)
  (global $g (;0;) i32 i32.const 1)
  (export "run" (func $f))
  (elem $els (;0;) (i32.const 0) func $f)
  (func $f (;1;) (type $sig) (param $x i32) (param $y i64) (result i32)
    (local $z i32)
    block $out
      local.get $x
      br_if $out
    end
    local.get $x
  )
  (data $dat (;0;) (i32.const 0) "hi\00\ff\22\5c\0a\09\0d")
)
