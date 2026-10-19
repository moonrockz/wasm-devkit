(component (type $t (future)) (export "t" (type $t)) (core type $ct (func (param externref))) (import "f" (func $f (param "p" $t))) (core func (canon lower (func $f) gc (core-type $ct))))
