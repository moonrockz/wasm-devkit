(component
  (type (;0;)
    (component
      (type (;0;)
        (instance)
      )
      (export (;0;) "test:ids/api" (instance (type 0)))
    )
  )
  (export (;1;) "api" (type 0))
  (type (;2;)
    (component
      (type (;0;)
        (component
          (type (;0;)
            (instance)
          )
          (import "test:ids/api" (external-id "urn:a") (instance (;0;) (type 0)))
        )
      )
      (export (;0;) "test:ids/app" (component (type 0)))
    )
  )
  (export (;3;) "app" (type 2))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
