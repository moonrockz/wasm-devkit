(module
  (type (;0;) (func))
  (func (;0;) (type 0)
    block (result anyref) ;; label = @1
      ref.null any
      br_on_cast_fail 0 (;@1;) anyref (ref eq)
    end
    drop
  )
)
