(component
  (core type (;0;) (func (param funcref externref) (result funcref externref)))
  (core type (;1;)
    (module
      (type (;0;) (func (param funcref externref) (result funcref externref)))
      (import "env" "t" (table 1 funcref))
      (export "g" (global externref))
    )
  )
)
