# Pinned encoder exclusion

The pinned WAC Document API accepts this export spread. Its CLI encoder emits a
component rejected with `func not valid to be used as export`. The equivalent
wrapped-instance export in `../composition/record-named` validates. This is an
encoder failure, not a product acceptance exclusion; the verifier does not emit
or execute component binaries. Tracked on `wasm-devkit-p5m.8.2.4`.
