# Runtime component instances

Original Apache-2.0 probes compare WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` and wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features enabled.
`packages.json` records 43 binary inputs. Supported accepted packages compare
complete ordered binary and WAT models, including named uses, nominal resource
identity, nested interfaces/components and core module contracts.

Section 5 instantiates imported components and constructs inline instances.
Argument checks retain captured resource equality and bind abstract imported
resources to supplied identities. Exported resources are fresh per instance;
component type references preserve their abstract template identities. Ordered
indices reject forward module, instance, component, type and function references.

The subsequent named-origin checkpoint admits `type-argument-named`, matching both
references. `type-argument` supplies the original anonymous record and fails the
final instance export check. The mismatched record control also rejects. Further
visibility and template-sharing cases are retained in `../wac-runtime-origins`.

Six source compositions compare the Document API and CLI. Four accepted outputs
pass independent wasm-tools validation and full public composition projections.
Two additional accepted Document inputs under `encoder-exclusions` panic in the
pinned CLI: aggregation of an anonymous interface and encoding of a component
member. Their exact sources and error output are retained separately from the
successful compositions, tracked on `wasm-devkit-p5m.8.2.4`.

Runtime component definitions, value arguments, starts, structured core bodies
and asynchronous canonical operations remain outside this checkpoint. No API
executes a component. Contract cloning, substitution and validation use explicit
work stacks and cumulative limits. Whitebox tests cover 6,000 nested contracts,
shared nodes, immutable templates, preserved captures and budget exhaustion.
`SHA256SUMS` covers every fixture and reference result.
