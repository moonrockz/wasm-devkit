(module
 (type $s (shared (struct (field (mut (ref null (shared any)))))))
 (type $f (shared (func (param (ref null $s)) (result (ref null $s)))))
 (import "env" "g" (global (shared (ref null $s))))
 (table (export "table") shared 1 (ref null $s))
 (global (export "value") (shared (ref null $s)) ref.null $s)
 (func (export "id") (type $f) local.get 0))
