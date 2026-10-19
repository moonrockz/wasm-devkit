(component (type $r (resource (rep i32))) (type $i (instance (type $inner (instance (export "r" (type (sub resource))))) (export "child" (instance (type $inner))))) (import "i" (instance (type $i))))
