(module (type $caller (shared (func (result i32)))) (type $callee (shared (func (result i32)))) (func $callee (type $callee) i32.const 1) (func (type $caller) call $callee))
