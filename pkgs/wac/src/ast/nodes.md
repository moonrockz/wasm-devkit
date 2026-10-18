# WAC node fields

All child references are postorder arena indices. Fields marked child define source traversal order.
CST grammar nodes use the same Kind enum.

| Kind | Fields |
|------|--------|
| `File` | `directive: Int?` child, `statements: ReadOnlyArray[Int]` child |
| `Package` | `path: Int` child, `targets: Int?` child |
| `Path` | `namespaces: ReadOnlyArray[String]`, `segments: ReadOnlyArray[String]`, `version: String?` |
| `Interface` | `name: String`, `items: ReadOnlyArray[Int]` child |
| `World` | `name: String`, `items: ReadOnlyArray[Int]` child |
| `Resource` | `name: String`, `methods: ReadOnlyArray[Int]` child, `has_body: Bool` |
| `Alias` | `name: String`, `ty: Int` child |
| `Record` | `name: String`, `fields: ReadOnlyArray[Int]` child |
| `Flags` | `name: String`, `cases: ReadOnlyArray[Int]` child |
| `Enum` | `name: String`, `cases: ReadOnlyArray[Int]` child |
| `Variant` | `name: String`, `cases: ReadOnlyArray[Int]` child |
| `Function` | `name: String`, `signature: Int` child, `is_static: Bool` |
| `Constructor` | `params: ReadOnlyArray[Int]` child |
| `Signature` | `asynchronous: Bool`, `params: ReadOnlyArray[Int]` child, `result: Int?` child |
| `NamedResults` | `params: ReadOnlyArray[Int]` child |
| `Import` | `binding: String`, `renamed: Int?` child, `ty: Int` child |
| `WorldImport` | `name: String?`, `target: Int` child |
| `WorldExport` | `name: String?`, `target: Int` child |
| `Use` | `path: Int` child, `names: ReadOnlyArray[Int]` child |
| `Include` | `path: Int` child, `renames: ReadOnlyArray[Int]` child |
| `Rename` | `name: String`, `renamed: String?` |
| `Field` | `name: String`, `ty: Int` child |
| `Case` | `name: String`, `payload: Int?` child |
| `Parameter` | `name: String`, `ty: Int` child |
| `PrimitiveType` | `name: String` |
| `NamedType` | `name: String` |
| `ListType` | `element: Int` child |
| `TupleType` | `elements: ReadOnlyArray[Int]` child |
| `OptionType` | `payload: Int` child |
| `ResultType` | `ok: Int?` child, `error: Int?` child |
| `BorrowType` | `resource: Int` child |
| `FutureType` | `payload: Int?` child |
| `StreamType` | `payload: Int?` child |
| `Let` | `name: String`, `expression: Int` child |
| `Export` | `expression: Int` child, `renamed: Int?` child, `spread: Bool` |
| `Name` | `value: String`, `quoted: Bool` |
| `Expression` | `primary: Int` child, `postfix: ReadOnlyArray[Int]` child |
| `Reference` | `name: String` |
| `Group` | `expression: Int` child |
| `New` | `component: Int` child, `arguments: ReadOnlyArray[Int]` child |
| `InferredArgument` | `name: String` |
| `SpreadArgument` | `name: String` |
| `NamedArgument` | `name: Int` child, `value: Int` child |
| `FillArgument` | none |
| `Access` | `name: String`, `quoted: Bool` |
| `Error` | `text: String`, `recovered: ReadOnlyArray[Int]` child |
