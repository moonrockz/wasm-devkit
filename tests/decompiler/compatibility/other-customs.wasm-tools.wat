(module
  (type (;0;) (func))
  (func (;0;) (type 0)
    nop
  )
  (@custom "target_features" (after code) "\01+\0bbulk-memory")
  (@custom "dylink" (after code) "\00\00\00\00\00")
  (@custom "reloc.CODE" (after code) "\00\00")
)
