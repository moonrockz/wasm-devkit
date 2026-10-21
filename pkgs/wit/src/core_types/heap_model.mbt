///|
/// A value inside a flat core type graph. Nonnegative heap indices refer to
/// `TypeIdentity.types`; negative indices use the signed binary abstract heap
/// codes. Sharedness and nullability are explicit even for bottom types.
pub(all) enum HeapValue {
  Number(String)
  Ref(Bool, Bool, Int32)
} derive(Eq, Debug)

///|
pub(all) enum HeapStorage {
  Value(HeapValue)
  Packed(String)
} derive(Eq, Debug)

///|
pub(all) struct HeapField {
  storage : HeapStorage
  mutable : Bool
} derive(Eq, Debug)

///|
pub(all) enum HeapComposite {
  Function(ReadOnlyArray[HeapValue], ReadOnlyArray[HeapValue])
  Struct(ReadOnlyArray[HeapField])
  Array(HeapField)
} derive(Eq, Debug)

///|
/// Isorecursive group boundaries and declared supertypes form part of a type's
/// identity. All graph edges are indices, so equality and debug rendering do
/// not recurse through input-controlled reference chains.
pub(all) struct HeapDefinition {
  final_ : Bool
  shared : Bool
  supertype : Int32?
  group_start : Int32
  group_size : Int32
  composite : HeapComposite
} derive(Eq, Debug)

///|
/// An immutable graph plus one distinguished type. Unrelated graph nodes do
/// not affect semantic compatibility. Use the checked compatibility operations
/// to compare types from independent modules or differently numbered graphs.
pub(all) struct TypeIdentity {
  types : ReadOnlyArray[HeapDefinition]
  index : Int32
} derive(Eq, Debug)

///|
pub extend HeapValue with Eq::{equal, not_equal}

///|
pub extend HeapValue with @debug.Debug::{to_repr}

///|
pub extend HeapStorage with Eq::{equal, not_equal}

///|
pub extend HeapStorage with @debug.Debug::{to_repr}

///|
pub extend HeapField with Eq::{equal, not_equal}

///|
pub extend HeapField with @debug.Debug::{to_repr}

///|
pub extend HeapComposite with Eq::{equal, not_equal}

///|
pub extend HeapComposite with @debug.Debug::{to_repr}

///|
pub extend HeapDefinition with Eq::{equal, not_equal}

///|
pub extend HeapDefinition with @debug.Debug::{to_repr}

///|
pub extend TypeIdentity with Eq::{equal, not_equal}

///|
pub extend TypeIdentity with @debug.Debug::{to_repr}
