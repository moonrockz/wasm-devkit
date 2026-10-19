(component (type $r (resource (rep i32))) (type $i (instance (type $r (func)) (export "f" (func (type $r))))) (import "allowed" (instance (type $i))))
