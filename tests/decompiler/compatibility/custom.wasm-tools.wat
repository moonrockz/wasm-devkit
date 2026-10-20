(module
  (@custom "a" (before first) "\00\ff")
  (type (;0;) (func))
  (memory (;0;) 1)
  (@custom "b" (after memory) "x")
  (func (;0;) (type 0))
  (@producers)
)
