(module $m
  (type $sig (func (param i32 i64) (result i32)))
  (import "env" "f" (func $import (type $sig)))
  (func $f (type $sig) (param $x i32) (param $y i64) (result i32)
    (local $z i32)
    block  ;; label = @1
      local.get $x
      br_if 0 (;@1;)
    end
    local.get $x)
  (table $tab 2 funcref)
  (memory $mem 1)
  (global $g i32 (i32.const 1))
  (export "run" (func $f))
  (elem $els (i32.const 0) func $f)
  (data $dat (i32.const 0) "hi\00\ff\22\5c\0a\09\0d")
  (@custom "name" "\00\02\01m\01\0c\02\00\06import\01\01f\02\0c\01\01\03\00\01x\01\01y\02\01z\03\08\01\01\01\00\03out\04\06\01\00\03sig\05\06\01\00\03tab\06\06\01\00\03mem\07\04\01\00\01g\08\06\01\00\03els\09\06\01\00\03dat"))
