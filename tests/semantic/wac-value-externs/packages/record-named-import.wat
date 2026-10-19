(component (type $r (record (field "x" u32))) (import "r" (type $rt (eq $r))) (import "v" (value (type $rt))) (export "v" (value 0)))
