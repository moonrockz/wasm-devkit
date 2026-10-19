(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (import "r" (type (;0;) (sub resource)))
          (type (;1;) (borrow 0))
          (type (;2;) (func (param "x" 1)))
          (import "f" (func (;0;) (type 2)))
        )
      )
      (export (;0;) "example:worlds/first" (component (type 0)))
    )
  )
  (export (;1;) "first" (type 0))
  (type (;2;)
    (component
      (type (;0;)
        (component
          (import "r" (type (;0;) (sub resource)))
          (type (;1;) (borrow 0))
          (type (;2;) (func (param "x" 1)))
          (import "f" (func (;0;) (type 2)))
        )
      )
      (export (;0;) "example:worlds/second" (component (type 0)))
    )
  )
  (export (;3;) "second" (type 2))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
