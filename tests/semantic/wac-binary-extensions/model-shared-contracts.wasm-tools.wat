(module
  (type $s (;0;) (shared (struct (field (mut (ref null (shared any)))))))
  (type $f (;1;) (shared (func (param (ref null $s)) (result (ref null $s)))))
  (import "env" "g" (global (;0;) (shared (ref null $s))))
  (table (;0;) shared 1 (ref null $s))
  (global (;1;) (shared (ref null $s)) ref.null $s)
  (export "table" (table 0))
  (export "value" (global 1))
  (export "id" (func 0))
  (func (;0;) (type $f)
    local.get 0
  )
)
