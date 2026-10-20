(component
  (type (component
    (type (instance
      (export "r" (type (sub resource)))
      (type (own 0))
      (type (list string))
      (type (record (field "id" u32) (field "tags" 2)))
      (export "item" (type (eq 3)))
      (type (func (param "x" string) (param "i" 4) (result 1)))
      (export "make" (func (type 5)))))
    (export "example:pkg/api@1.0.0" (instance (type 0)))))
  (export "api" (type 0))
  (@custom "package-docs" "\00{}"))
