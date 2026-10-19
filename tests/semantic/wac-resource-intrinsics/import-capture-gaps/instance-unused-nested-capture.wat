(component (type $r (resource (rep i32))) (type $i (instance (type (instance (alias outer 2 $r (type $r)) (export "r" (type (eq $r))))))) (import "allowed" (instance (type $i))))
