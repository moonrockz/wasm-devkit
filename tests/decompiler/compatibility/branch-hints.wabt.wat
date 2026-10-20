(module
  (type (;0;) (func (param i32)))
  (func (;0;) (type 0) (param i32)
    local.get 0
    (@metadata.code.branch_hint "\01") if  ;; label = @1
      local.get 0
      (@metadata.code.branch_hint "\00") br_if 0 (;@1;)
    end)
  (@custom "metadata.code.branch_hint" "\01\00\02\03\01\01\07\01\00"))
