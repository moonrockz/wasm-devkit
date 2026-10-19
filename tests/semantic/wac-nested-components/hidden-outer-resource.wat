(component
  (type $api (instance
    (export "r" (type $r (sub resource)))
    (type $record (record (field "h" (own $r))))
    (export "rec" (type (eq $record)))
  ))
  (import "api" (instance $api (type $api)))
  (alias export $api "rec" (type $rec))
  (component $child
    (alias outer 1 $rec (type $rec))
    (export "rec" (type $rec))
  )
  (export "child" (component $child))
)
