(component (import "r" (type $r (sub resource))) (import "s" (type $s (sub resource))) (type $a (own $r)) (type $b (own $s)) (import "v" (value (type $a))) (export "v" (value 0) (value (type $b))))
