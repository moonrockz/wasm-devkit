(component (core module $m
 (tag $e (import "env" "e") (param i32))
 (tag (export "tag") (param (ref exn)))
 (func (export "raise") (param i32) local.get 0 throw $e)
 (func (export "catch") (result i32)
  block (result i32) try_table (catch $e 0) i32.const 3 throw $e end unreachable end)
 (global (export "none") (ref null noexn) ref.null noexn)) (export "m" (core module $m)))
