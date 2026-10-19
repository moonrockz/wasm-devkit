(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (type (;0;)
            (instance
              (export (;0;) "r" (type (sub resource)))
              (type (;1;) (own 0))
              (type (;2;) (func (result 1)))
              (export (;0;) "[constructor]r" (func (type 2)))
              (type (;3;) (borrow 0))
              (type (;4;) (func (param "self" 3) (param "x" u32) (result string)))
              (export (;1;) "[method]r.f" (func (type 4)))
            )
          )
          (import "dep:base/core" (instance (;0;) (type 0)))
        )
      )
      (export (;0;) "example:methods/app" (component (type 0)))
    )
  )
  (export (;1;) "app" (type 0))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
