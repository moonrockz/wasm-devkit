(component
  (type (;0;)
    (component
      (type (;0;)
        (instance
          (export (;0;) "first" (external-id "same") (type (sub resource)))
          (export (;1;) "second" (external-id "same") (type (sub resource)))
          (type (;2;) (borrow 0))
          (type (;3;) (borrow 1))
          (type (;4;) (func (param "a" 2) (param "b" 3)))
          (export (;0;) "f" (func (type 4)))
        )
      )
      (export (;0;) "test:ids/api" (instance (type 0)))
    )
  )
  (export (;1;) "api" (type 0))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
