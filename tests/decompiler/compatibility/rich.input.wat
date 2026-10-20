(module
  (type (func (param i32) (result i32)))
  (import "env" "f" (func (type 0)))
  (import "env" "mem" (memory 1 2))
  (import "env" "g" (global (mut i64)))
  (import "env" "t" (table 1 funcref))
  (table 2 funcref)
  (table 1 externref)
  (global (mut f32) (f32.const 0.1))
  (global f64 (f64.const -0x1p-1074))
  (global f32 (f32.const nan:0x400001))
  (func (param i32) (result i32) (local i64 f64)
    local.get 0
    block (result i32)
      loop
        local.get 0
        local.get 0
        br_if 1
        drop
      end
      local.get 0
      if (result i32)
        i32.const 1
      else
        i32.const 2
      end
    end
    i32.add
    i32.load offset=4
    local.get 0
    call_indirect 1 (type 0)
    local.get 0
    br_table 0 0)
  (func (result f32 f64 v128)
    f32.const -0
    f64.const inf
    v128.const i32x4 1 2 3 4)
  (func
    i32.const 0
    i32.const 0
    i32.const 1
    memory.init 0
    data.drop 1
    i32.const 0
    ref.null extern
    table.set 2)
  (elem (i32.const 0) func 1)
  (elem func 2)
  (elem declare func 0)
  (data (i32.const 8) "hi\00\ff\"\\")
  (data "passive")
  (export "id" (func 1))
  (export "mem" (memory 0))
  (export "table" (table 1))
  (export "global" (global 1))
  (start 3)
)
