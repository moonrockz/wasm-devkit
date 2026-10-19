(component
 (type (component
  (type (component
   (type (instance (export "r" (type (sub resource)))))
   (import "dep:a/first" (instance (type 0)))
   (import "dep:b/second" (instance (type 0)))
   (alias export 0 "r" (type))
   (import "left" (type (eq 1)))
   (alias export 1 "r" (type))
   (import "right" (type (eq 3)))
   (type (borrow 2))
   (type (borrow 4))
   (type (func (param "a" 5) (param "b" 6)))
   (export "run" (func (type 7)))
  ))
  (export "example:shared/app" (component (type 0)))
 ))
 (export "app" (type 0))
)
