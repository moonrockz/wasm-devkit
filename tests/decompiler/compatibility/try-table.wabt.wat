(module
  (type (;0;) (func))
  (func (;0;) (type 0)
    block  ;; label = @1
      try_table  ;; label = @2
        (catch $e 0 (;@1;))
        (catch_all 0 (;@1;))
        nop
        br 0 (;@2;)
      end
    end)
  (func (;1;) (type 0)
    block (result exnref)  ;; label = @1
      try_table  ;; label = @2
        (catch_ref $e 0 (;@1;))
        (catch_all_ref 0 (;@1;))
        nop
      end
      unreachable
    end
    drop)
  (tag $e (type 0))
  (@custom "name" "\03)\02\00\02\00\05outer\01\05inner\01\02\00\09outer-ref\01\09inner-ref\0b\04\01\00\01e"))
