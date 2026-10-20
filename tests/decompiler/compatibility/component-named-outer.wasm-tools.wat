(component $root
  (core type $f (;0;) (func (param i32)))
  (core type $m (;1;)
    (module
      (alias outer $root $f (type (;0;)))
      (export "f" (func (type 0)))
    )
  )
  (type $t (;0;) (list u32))
  (component $child (;0;)
    (alias outer $root $t (type $alias (;0;)))
    (type (;1;) (func (param "x" $alias)))
  )
)
