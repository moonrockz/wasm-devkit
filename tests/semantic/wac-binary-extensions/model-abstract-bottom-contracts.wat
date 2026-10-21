(component (core module $m
 (type $f (func (param (ref none) (ref nofunc) (ref noextern) (ref noexn) (ref eq) (ref i31))))
 (import "env" "f" (func (type $f)))
 (table (export "exn") 0 (ref null exn))
 (global (export "none") (ref null none) ref.null none)) (export "m" (core module $m)))
