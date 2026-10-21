(module
  (type (;0;) (func))
  (type (;1;) (func (result i32 eqref)))
  (func (;0;) (type 0)
    block (type 1) (result i32 eqref) ;; label = @1
      i32.const 1
      ref.null any
      br_on_cast 0 (;@1;) anyref eqref
      drop
      drop
      i32.const 2
      ref.null eq
    end
    drop
    drop
  )
)
