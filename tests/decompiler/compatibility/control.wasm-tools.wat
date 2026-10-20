(module
  (type (;0;) (func (param i32 i64) (result i32 i64)))
  (type (;1;) (func))
  (func (;0;) (type 0) (param i32 i64) (result i32 i64)
    local.get 0
    local.get 1
    block (type 0) (param i32 i64) (result i32 i64) ;; label = @1
    end
  )
  (func (;1;) (type 1)
    i32.const 1
    if ;; label = @1
    else
    end
    block ;; label = @1
      loop ;; label = @2
        i32.const 0
        br_table 0 (;@2;) 1 (;@1;) 2
      end
    end
  )
)
