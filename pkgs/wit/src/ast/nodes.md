# WIT node fields

All references are zero-based AST arena indices. Child references appear before their parent.
Fields marked child define traversal order. Other fields are immutable scalar metadata.
CST nodes use the same `Kind` enum and reference matching arena indices.

| Kind | Fields, in traversal order |
|------|----------------------------|
| `File` | `items: ReadOnlyArray[Int]` child |
| `Package` | `attributes: ReadOnlyArray[Int]` child, `path: Int` child, `items: ReadOnlyArray[Int]` child, `nested: Bool` |
| `Interface` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `items: ReadOnlyArray[Int]` child |
| `World` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `items: ReadOnlyArray[Int]` child |
| `Resource` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `methods: ReadOnlyArray[Int]` child, `has_body: Bool` |
| `Alias` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `ty: Int` child |
| `Record` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `fields: ReadOnlyArray[Int]` child |
| `Flags` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `cases: ReadOnlyArray[Int]` child |
| `Enum` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `cases: ReadOnlyArray[Int]` child |
| `Variant` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `cases: ReadOnlyArray[Int]` child |
| `Function` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `signature: Int` child, `is_static: Bool` |
| `Constructor` | `attributes: ReadOnlyArray[Int]` child, `params: ReadOnlyArray[Int]` child, `result: Int?` child |
| `Signature` | `flavor: FunctionFlavor`, `asynchronous: Bool`, `params: ReadOnlyArray[Int]` child, `result: Int?` child |
| `Import` | `name: String?`, `attributes: ReadOnlyArray[Int]` child, `target: Int` child |
| `Export` | `name: String?`, `attributes: ReadOnlyArray[Int]` child, `target: Int` child |
| `Use` | `attributes: ReadOnlyArray[Int]` child, `path: Int` child, `names: ReadOnlyArray[Int]` child, `renamed: String?` |
| `Include` | `attributes: ReadOnlyArray[Int]` child, `path: Int` child, `renames: ReadOnlyArray[Int]` child |
| `Attribute` | `name: String`, `field: String`, `value: String` |
| `Path` | `namespaces: ReadOnlyArray[String]`, `segments: ReadOnlyArray[String]`, `version: String?` |
| `Rename` | `name: String`, `renamed: String?` |
| `Field` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `ty: Int` child |
| `Case` | `name: String`, `attributes: ReadOnlyArray[Int]` child, `payload: Int?` child |
| `Parameter` | `name: String`, `ty: Int` child |
| `PrimitiveType` | `name: String` |
| `NamedType` | `name: String` |
| `ListType` | `element: Int` child, `length: String?` |
| `TupleType` | `elements: ReadOnlyArray[Int]` child |
| `OptionType` | `payload: Int` child |
| `ResultType` | `ok: Int?` child, `error: Int?` child |
| `OwnType` | `resource: Int` child |
| `BorrowType` | `resource: Int` child |
| `FutureType` | `payload: Int?` child |
| `StreamType` | `payload: Int?` child |
| `MapType` | `key: Int` child, `value: Int` child |
| `Error` | `text: String`, `recovered: ReadOnlyArray[Int]` child |
