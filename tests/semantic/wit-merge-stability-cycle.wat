(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (type (;0;)
            (instance
              (type (;0;) (list u32))
              (export (;1;) "a" (type (eq 0)))
              (export (;2;) "b" (type (eq 1)))
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
