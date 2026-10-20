(module
  (type (;0;) (func (param (ref exn) (ref nofunc) (ref noextern) (ref noexn))))
  (type (;1;) (func (param (ref exn)) (result (ref exn))))
  (type (;2;) (func (result (ref exn))))
  (import "env" "g" (global (;0;) (ref exn)))
  (table (;0;) 0 (ref exn) global.get 0)
  (global (;1;) (ref exn) global.get 0)
  (func (;0;) (type 1) (param (ref exn)) (result (ref exn))
    (local (ref nofunc))
    local.get 0
  )
  (func (;1;) (type 2) (result (ref exn))
    unreachable
    block (result (ref exn)) ;; label = @1
      unreachable
    end
  )
)
