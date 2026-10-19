(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (type (;0;)
            (instance
              (type (;0;) u32)
              (export (;1;) "t" (external-id "type") (type (eq 0)))
              (type (;2;) (func (param "x" 1)))
              (export (;0;) "f" (external-id "fn") (func (type 2)))
            )
          )
          (import "api" (external-id "inline") (instance (;0;) (type 0)))
        )
      )
      (export (;0;) "test:ids/app" (component (type 0)))
    )
  )
  (export (;1;) "app" (type 0))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
