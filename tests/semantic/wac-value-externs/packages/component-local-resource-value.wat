(component (type $r (resource (rep i32))) (type $c (component (alias outer 1 $r (type $r)) (type $o (own $r)) (import "v" (value (type $o))))) (import "c" (component (type $c))))
