(component (type $r (resource (rep i32))) (type $i (component (type (instance (alias outer 2 $r (type $r)) (export "r" (type (eq $r))))))) (import "allowed" (component (type $i))))
