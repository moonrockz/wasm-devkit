(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (type (;0;)
            (instance
              (type (;0;) u32)
              (export (;1;) "type" (type (eq 0)))
            )
          )
          (import "dep:world/interface" (instance (;0;) (type 0)))
        )
      )
      (export (;0;) "example:reserved/app" (component (type 0)))
    )
  )
  (export (;1;) "app" (type 0))
  (@custom "package-docs" "\01{}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
