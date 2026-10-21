(module
  (type $caller (;0;) (shared (func)))
  (type $callee (;1;) (shared (func)))
  (export "callee" (func $callee))
  (func $callee (;0;) (type $callee))
  (func (;1;) (type $caller)
    ref.func $callee
    drop
  )
)
