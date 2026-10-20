(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (result f32 f64 v128)))
  (type (;2;) (func))
  (import "env" "f" (func (;0;) (type 0)))
  (import "env" "mem" (memory (;0;) 1 2))
  (import "env" "g" (global (;0;) (mut i64)))
  (import "env" "t" (table (;0;) 1 funcref))
  (func (;1;) (type 0) (param i32) (result i32)
    (local i64 f64)
    local.get 0
    block (result i32)  ;; label = @1
      loop  ;; label = @2
        local.get 0
        local.get 0
        br_if 1 (;@1;)
        drop
      end
      local.get 0
      if (result i32)  ;; label = @2
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
    br_table 0 (;@0;) 0 (;@0;))
  (func (;2;) (type 1) (result f32 f64 v128)
    f32.const -0x0p+0 (;=-0;)
    f64.const inf (;=inf;)
    v128.const i32x4 0x00000001 0x00000002 0x00000003 0x00000004)
  (func (;3;) (type 2)
    i32.const 0
    i32.const 0
    i32.const 1
    memory.init 0
    data.drop 1
    i32.const 0
    ref.null extern
    table.set 2)
  (table (;1;) 2 funcref)
  (table (;2;) 1 externref)
  (global (;1;) (mut f32) (f32.const 0x1.99999ap-4 (;=0.1;)))
  (global (;2;) f64 (f64.const -0x1.p-1074 (;=-4.94066e-324;)))
  (global (;3;) f32 (f32.const nan:0x400001 (;=nan;)))
  (export "id" (func 1))
  (export "mem" (memory 0))
  (export "table" (table 1))
  (export "global" (global 1))
  (start 3)
  (elem (;0;) (i32.const 0) func 1)
  (elem (;1;) func 2)
  (elem (;2;) declare func 0)
  (data (;0;) (i32.const 8) "hi\00\ff\22\5c")
  (data (;1;) "passive"))
