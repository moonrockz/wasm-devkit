(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (import "r" (type (;0;) (sub resource)))
          (type (;1;) (own 0))
          (type (;2;) (func (result 1)))
          (export "[constructor]r" (func (;0;) (type 2)))
          (type (;3;) (borrow 0))
          (type (;4;) (func (param "self" 3) (param "x" u32) (result string)))
          (import "[method]r.f" (func (;1;) (type 4)))
        )
      )
      (export (;0;) "example:worlds/app" (component (type 0)))
    )
  )
  (export (;1;) "app" (type 0))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
