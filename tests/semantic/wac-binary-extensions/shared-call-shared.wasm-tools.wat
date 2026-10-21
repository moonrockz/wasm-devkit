(module
  (type $caller (;0;) (shared (func (result i32))))
  (type $callee (;1;) (shared (func (result i32))))
  (func $callee (;0;) (type $callee)
    i32.const 1
  )
  (func (;1;) (type $caller)
    call $callee
  )
)
