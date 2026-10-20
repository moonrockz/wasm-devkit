(component
  (import "host" (instance $h (export "log" (func (param "msg" string)))))
  (alias export $h "log" (func $log))
  (core module $libc
    (memory (export "mem") 1)
    (func (export "realloc") (param i32 i32 i32 i32) (result i32) i32.const 0))
  (core instance $libc (instantiate $libc))
  (core func $log (canon lower (func $log) (memory (core memory $libc "mem"))
    (realloc (core func $libc "realloc")) string-encoding=utf8))
  (core module $m
    (import "host" "log" (func (param i32 i32)))
    (func (export "run")))
  (core instance $i (instantiate $m
    (with "host" (instance (export "log" (func $log))))))
  (type $run (func))
  (func $run (type $run) (canon lift (core func $i "run")))
  (export "run" (func $run)))
