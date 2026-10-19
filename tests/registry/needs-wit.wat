(component
  (type $api (instance
    (type $token u32)
    (export "token" (type (eq $token)))
    (type $ping (func (param "value" $token)))
    (export "ping" (func (type $ping)))
  ))
  (import "test:wit/api" (instance (type $api)))
  (export "api" (instance 0))
)
