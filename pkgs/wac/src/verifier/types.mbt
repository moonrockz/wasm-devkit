///|
/// A component item refers to a type in the verified model's immutable arena.
pub(all) enum ItemKind {
  Type(Int32)
  Function(Int32)
  Instance(Int32)
  Component(Int32)
} derive(Eq, Debug)

///|
pub(all) struct TypeMember {
  name : String
  ty : Int32
  location : Location
} derive(Eq, Debug)

///|
pub(all) struct TypeCase {
  name : String
  payload : Int32?
  location : Location
} derive(Eq, Debug)

///|
pub(all) struct Extern {
  name : String
  kind : ItemKind
  location : Location
} derive(Eq, Debug)

///|
pub(all) struct UsedType {
  name : String
  original_name : String
  interface : Int32
  ty : Int32
  location : Location
} derive(Eq, Debug)

///|
/// Type references are arena indices, including nominal resource aliases.
/// A Resource with no alias introduces a new identity; Own and Borrow retain
/// the referenced resource declaration even when it is an alias.
pub(all) enum TypeKind {
  Scalar(String)
  Alias(Int32)
  Resource(Int32?)
  Own(Int32)
  Borrow(Int32)
  List(Int32)
  FixedList(Int32, Int32)
  Map(Int32, Int32)
  Tuple(ReadOnlyArray[Int32])
  Option(Int32)
  Result(Int32?, Int32?)
  Future(Int32?)
  Stream(Int32?)
  Record(ReadOnlyArray[TypeMember])
  Flags(ReadOnlyArray[String])
  Enum(ReadOnlyArray[String])
  Variant(ReadOnlyArray[TypeCase])
  Function(ReadOnlyArray[TypeMember], Int32?, Bool)
  Interface(String?, ReadOnlyArray[UsedType], ReadOnlyArray[Extern])
  World(
    String?,
    ReadOnlyArray[UsedType],
    ReadOnlyArray[Extern],
    ReadOnlyArray[Extern]
  )
} derive(Eq, Debug)

///|
pub(all) struct ResolvedType {
  id : Int32
  name : String?
  kind : TypeKind
  location : Location
} derive(Eq, Debug)

///|
pub(all) struct ResolvedDeclaration {
  name : String
  scope : Int32
  node : Int32
  kind : ItemKind
} derive(Eq, Debug)

///|
pub fn Verified::types(self : Verified) -> ReadOnlyArray[ResolvedType] {
  self.resolved_types
}

///|
pub fn Verified::items(self : Verified) -> ReadOnlyArray[ResolvedDeclaration] {
  self.resolved_declarations
}

///|
pub fn Verified::imports(self : Verified) -> ReadOnlyArray[Extern] {
  self.resolved_imports
}

///|
pub fn Verified::exports(self : Verified) -> ReadOnlyArray[Extern] {
  self.resolved_exports
}

///|
/// Return the introducing resource's arena identity, following aliases with a
/// bounded loop. Other types and out-of-range indices return None.
pub fn Verified::resource_identity(self : Verified, id : Int32) -> Int32? {
  let mut current = id
  for _ in 0..<self.resolved_types.length() {
    guard current >= 0 && current < self.resolved_types.length() else {
      return None
    }
    match self.resolved_types[current].kind {
      Resource(None) => return Some(current)
      Resource(Some(next)) => current = next
      _ => return None
    }
  }
  None
}

///|
pub extend ItemKind with Eq::{equal, not_equal}

///|
pub extend ItemKind with @debug.Debug::{to_repr}

///|
pub extend TypeKind with Eq::{equal, not_equal}

///|
pub extend TypeKind with @debug.Debug::{to_repr}

///|
pub extend TypeMember with Eq::{equal, not_equal}

///|
pub extend TypeMember with @debug.Debug::{to_repr}

///|
pub extend TypeCase with Eq::{equal, not_equal}

///|
pub extend TypeCase with @debug.Debug::{to_repr}

///|
pub extend Extern with Eq::{equal, not_equal}

///|
pub extend Extern with @debug.Debug::{to_repr}

///|
pub extend UsedType with Eq::{equal, not_equal}

///|
pub extend UsedType with @debug.Debug::{to_repr}

///|
pub extend ResolvedType with Eq::{equal, not_equal}

///|
pub extend ResolvedType with @debug.Debug::{to_repr}

///|
pub extend ResolvedDeclaration with Eq::{equal, not_equal}

///|
pub extend ResolvedDeclaration with @debug.Debug::{to_repr}
