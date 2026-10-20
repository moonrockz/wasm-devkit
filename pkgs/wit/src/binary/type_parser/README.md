# Stack-safe component type parser

This internal compatibility package retains parsing functions from
`Milky2018/wasm_component@0.16.0`, upstream
[wasmoon](https://github.com/Milky2018/wasmoon) commit
`397eb299e696d54cbc3bdcb095a5f535a74ad317`.
The Apache-2.0 license and upstream notices are retained. `UPSTREAM.sha256`
records the complete published source files used for the extractions below.
The binary model and other section parsers remain pinned dependencies.

`parse_type_section` decodes component and instance scopes with an explicit
work stack. It preserves declaration order and the dependency's leaf decoding,
including core type payloads, aliases and name attributes. Core payload framing
uses `core_types.scan_type`, so nested memories and tables retain full unsigned
limits and custom memory pages without narrowing to u32. Vector counts are
checked against remaining bytes before scheduling work. `parse_component`
uses a separate explicit stack to assemble concrete component snapshots.

Production binary validation, WIT reconstruction, WAC dependency decoding and
both decompilers use these functions. Public binary entry points still enforce
the existing 256-scope profile before parsing. The parser itself is tested at
6,000 levels, against the pinned parser on shallow structures and against
truncated deep inputs. Beads task: `wasm-devkit-p5m.14`.

`LOCAL.patch` records changes against these extracted baselines, using the
retained filenames as patch paths. Each extraction begins with the named
function or declaration, excluding its preceding `///|` marker, and ends
immediately before the indicated marker or at end of file.

| Retained file | Published baseline extraction |
| --- | --- |
| `reader.mbt` | `binary.mbt`: `priv struct Reader` through immediately before `\n///|\npub fn parse_component_binary` |
| `error.mbt` | `binary.mbt`: `pub suberror ComponentParseError` through immediately before `///|\npriv struct Reader` |
| `attributes.mbt` | `import_export.mbt`: `fn parse_name_annot` through immediately before `///|\nfn parse_importname` |
| `type_section.mbt` | `type_section.mbt`: `fn Reader::read_label` through EOF, followed by `\n///|\n` and `canon_start.mbt`: `fn parse_prim_valtype_from_sleb` through immediately before the next `\n///|` |
| `component.mbt` | `component.mbt`: `fn component_from_binary` through EOF |

`types.mbt`, `moon.pkg` and `type_section_wbtest.mbt` are original integration
code. Apply the patch with `git apply --no-index` in a directory containing
these baseline extractions to reconstruct the retained source files.
