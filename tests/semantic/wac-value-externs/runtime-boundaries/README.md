# Runtime value boundaries

Both original inputs are accepted by the pinned WAC loader and wasm-tools.
The current product reports WAC-B002 until runtime value origins, substitution,
export visibility and consuming uses are fully retained. The guard prevents the
runtime contract builder from silently dropping value member metadata.
These two witnesses are additional to the 45 declarative package probes.
Tracked on wasm-devkit-p5m.8.2.2 and wasm-devkit-p5m.8.2.4.
