(component (type $r (record (field "x" u32))) (type $i (instance (alias outer 1 $r (type $r)) (export "v" (value (type $r))))) (import "i" (instance (type $i))))
