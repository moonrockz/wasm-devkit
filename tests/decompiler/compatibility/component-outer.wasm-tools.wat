(component
  (type $f (;0;) (func))
  (component $c (;0;)
    (alias outer 1 $f (type $g (;0;)))
    (import "f" (func $f (;0;) (type $g)))
  )
  (type $c (;1;)
    (component
      (alias outer 1 $f (type (;0;)))
      (export (;0;) "f" (func (type 0)))
    )
  )
)
