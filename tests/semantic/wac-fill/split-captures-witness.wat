(component
  (type $api (instance
    (export "handle" (type (sub resource)))
    (type $take (func (param "h" (own 0))))
    (export "take" (func (type $take)))))
  (import "a" (instance $a (type $api)))
  (import "b" (instance $b (type $api)))
  (alias export $a "handle" (type $a-handle))
  (alias export $b "handle" (type $b-handle))
  (alias export $a "take" (func $a-take))
  (alias export $b "take" (func $b-take))
  (type $first (func (param "h" (own $a-handle))))
  (import "first" (func $first (type $first)))
  (type $second (func (param "h" (own $b-handle))))
  (import "second" (func $second (type $second)))
  (component $relay
    (import "handle" (type (sub resource)))
    (type $take (func (param "h" (own 0))))
    (import "first" (func (type $take)))
    (import "second" (func (type $take))))
  (instance (instantiate $relay
    (with "handle" (type $a-handle))
    (with "first" (func $first))
    (with "second" (func $a-take))))
  (instance (instantiate $relay
    (with "handle" (type $b-handle))
    (with "first" (func $b-take))
    (with "second" (func $second)))))
