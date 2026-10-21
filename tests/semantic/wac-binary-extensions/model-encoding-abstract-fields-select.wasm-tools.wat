(module
  (type (;0;) (struct (field structref) (field arrayref)))
  (type (;1;) (array arrayref))
  (type (;2;) (func (param structref structref i32) (result structref)))
  (global (;0;) arrayref ref.null array)
  (export "id" (func 0))
  (export "g" (global 0))
  (func (;0;) (type 2) (param structref structref i32) (result structref)
    local.get 0
    local.get 1
    local.get 2
    select (result structref)
  )
)
