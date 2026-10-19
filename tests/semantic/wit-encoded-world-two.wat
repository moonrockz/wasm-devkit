(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (import "left" (type (;0;) (sub resource)))
          (import "right" (type (;1;) (sub resource)))
          (type (;2;) (borrow 0))
          (type (;3;) (borrow 1))
          (type (;4;) (func (param "x" 2) (param "y" 3)))
          (import "f" (func (;0;) (type 4)))
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
