(component
  ;; failed to parse custom section `producers`: invalid producers field name: `x` (at offset 0x15)
  (@custom "producers" "\01\01x\01\ff")
  (core module (;0;)
    ;; failed to parse custom section `dylink.0`: unexpected end-of-file (at offset 0x31)
    (@custom "dylink.0" (before first) "\01\01\00")
  )
)
