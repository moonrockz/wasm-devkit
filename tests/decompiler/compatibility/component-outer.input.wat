(component (type $f (func)) (component $c (alias outer 1 $f (type $g)) (import "f" (func $f (type $g)))) (type $c (component (alias outer 1 $f (type $g)) (export "f" (func (type $g))))))
