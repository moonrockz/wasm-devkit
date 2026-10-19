(component
  (type (;0;)
    (component
      (type (;0;)
        (component
          (import "r" (type (;0;) (sub resource)))
          (type (;1;) (own 0))
          (type (;2;) (func (result 1)))
          (import "[constructor]r" (func (;0;) (type 2)))
          (type (;3;) (borrow 0))
          (type (;4;) (func (param "self" 3)))
          (import "[method]r.f" (func (;1;) (type 4)))
        )
      )
      (export (;0;) "example:worlds/app" (component (type 0)))
    )
  )
  (export (;1;) "app" (type 0))
  (@custom "package-docs" "\01{\22worlds\22:{\22app\22:{\22types\22:{\22r\22:{\22stability\22:{\22unstable\22:{\22feature\22:\22hidden\22}}}},\22funcs\22:{\22[constructor]r\22:{\22stability\22:{\22unstable\22:{\22feature\22:\22ctor\22}}},\22[method]r.f\22:{\22stability\22:{\22unstable\22:{\22feature\22:\22method\22}}}}}}}")
  (@producers
    (processed-by "wit-component" "0.262.0")
  )
)
