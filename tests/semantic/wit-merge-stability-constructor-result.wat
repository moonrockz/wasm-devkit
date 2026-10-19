(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (type (;0;)
            (instance
              (export (;0;) "r" (type (sub resource)))
              (export (;1;) "s" (type (sub resource)))
              (type (;2;) (own 1))
              (type (;3;) (result 2))
              (export (;4;) "t" (type (eq 3)))
            )
          )
          (import "test:dep/base" (instance (;0;) (type 0)))
        )
      )
      (export (;0;) "test:root/app" (component (type 0)))
    )
  )
  (export (;1;) "app" (type 0))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
