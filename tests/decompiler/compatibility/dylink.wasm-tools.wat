(module
  (@dylink.0
    (mem-info (memory 5 2) (table 3 0))
    (needed "a.so" "b.so")
    (export-info "f" binding-weak exported)
    (import-info "env" "g" undefined)
    (runtime-path "/lib")
    (target-arch "wasm32")
  )
)
