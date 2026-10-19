(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (import "r" (type (;0;) (sub resource)))
          (import "alias-r" (type (;1;) (eq 0)))
          (type (;2;) (own 1))
          (type (;3;) (func (result 2)))
          (export (;0;) "f" (func (type 3)))
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
