(module
  (type (;0;) (func))
  (tag $e (;0;) (type 0))
  (func (;0;) (type 0)
    block $outer
      try_table $inner (catch $e $outer) (catch_all $outer)
        nop
        br $inner
      end
    end
  )
  (func (;1;) (type 0)
    block $outer-ref (result exnref)
      try_table $inner-ref (catch_ref $e $outer-ref) (catch_all_ref $outer-ref)
        nop
      end
      unreachable
    end
    drop
  )
)
