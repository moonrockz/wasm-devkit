///|
/// Edges use stable source-local AST node identities. A named type points to
/// its resolved declaration, rather than retaining an unresolved name string.
pub(all) enum TypeKind {
  Scalar(String)
  Resource
  Alias(Int32)
  List(Int32, UInt32?)
  Tuple(ReadOnlyArray[Int32])
  Option(Int32)
  Result(Int32?, Int32?)
  Future(Int32?)
  Stream(Int32?)
  Map(Int32, Int32)
  Record(ReadOnlyArray[TypeMember])
  Flags(ReadOnlyArray[String])
  Enum(ReadOnlyArray[String])
  Variant(ReadOnlyArray[TypeCase])
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
pub(all) struct ResolvedType {
  id : Int32
  name : String?
  kind : TypeKind
  location : Location
} derive(Eq, Debug)

///|
pub fn Verified::types(self : Verified) -> ReadOnlyArray[ResolvedType] {
  self.resolved_types
}

///|
fn type_declaration(data : @ast.Data) -> Bool {
  match data {
    Alias(..)
    | Record(..)
    | Flags(..)
    | Enum(..)
    | Variant(..)
    | Resource(..) => true
    _ => false
  }
}

///|
fn type_edges(data : @ast.Data) -> ReadOnlyArray[Int32] {
  match data {
    Alias(ty~, ..) | Field(ty~, ..) => [ty]
    Record(fields~, ..) => fields
    Variant(cases~, ..) => cases
    Case(payload~, ..) =>
      match payload {
        Some(id) => [id]
        None => []
      }
    ListType(element~, ..) => [element]
    TupleType(elements~) => elements
    OptionType(payload~) => [payload]
    ResultType(ok~, error~) => {
      let result = []
      if ok is Some(id) {
        result.push(id)
      }
      if error is Some(id) {
        result.push(id)
      }
      ReadOnlyArray::from_array(result)
    }
    FutureType(payload~) | StreamType(payload~) =>
      match payload {
        Some(id) => [id]
        None => []
      }
    MapType(key~, value~) => [key, value]
    _ => []
  }
}

///|
fn fixed_size(text : String) -> UInt32? {
  if text.is_empty() {
    return None
  }
  let mut value : UInt32 = 0
  for i in 0..<text.length() {
    let c = text.code_unit_at(i).to_int()
    if c < 48 || c > 57 {
      return None
    }
    let digit = (c - 48).reinterpret_as_uint()
    if value > (4294967295U - digit) / 10 {
      return None
    }
    value = value * 10 + digit
  }
  Some(value)
}

///|
fn resolved_types(
  tree : @ast.Tree,
  source : String,
  references : Map[Int32, Int32],
) -> ReadOnlyArray[ResolvedType] {
  let result : Array[ResolvedType] = []
  for id, node in tree.nodes {
    let kind : TypeKind? = match node.data {
      PrimitiveType(name~) => Some(Scalar(name))
      Resource(..) => Some(Resource)
      NamedType(..) => references.get(id).map(id => TypeKind::Alias(id))
      Alias(ty~, ..) => Some(Alias(ty))
      ListType(element~, length~) =>
        Some(
          List(
            element,
            match length {
              Some(size) => fixed_size(size)
              None => None
            },
          ),
        )
      TupleType(elements~) => Some(Tuple(elements))
      OptionType(payload~) => Some(Option(payload))
      ResultType(ok~, error~) => Some(Result(ok, error))
      FutureType(payload~) => Some(Future(payload))
      StreamType(payload~) => Some(Stream(payload))
      MapType(key~, value~) => Some(Map(key, value))
      Record(fields~, ..) => {
        let members : Array[TypeMember] = []
        for field in fields {
          if tree.nodes[field].data is Field(name~, ty~, ..) {
            members.push({
              name,
              ty,
              location: { source, span: tree.nodes[field].span, },
            })
          }
        }
        Some(Record(ReadOnlyArray::from_array(members)))
      }
      Flags(cases~, ..) | Enum(cases~, ..) => {
        let names : Array[String] = []
        for case_id in cases {
          if tree.nodes[case_id].data is Case(name~, ..) {
            names.push(name)
          }
        }
        Some(
          if node.data is Flags(..) {
            Flags(ReadOnlyArray::from_array(names))
          } else {
            Enum(ReadOnlyArray::from_array(names))
          },
        )
      }
      Variant(cases~, ..) => {
        let members : Array[TypeCase] = []
        for case_id in cases {
          if tree.nodes[case_id].data is Case(name~, payload~, ..) {
            members.push({
              name,
              payload,
              location: { source, span: tree.nodes[case_id].span, },
            })
          }
        }
        Some(Variant(ReadOnlyArray::from_array(members)))
      }
      _ => None
    }
    if kind is Some(kind) {
      result.push({
        id,
        name: declaration(node.data),
        kind,
        location: { source, span: node.span, },
      })
    }
  }
  ReadOnlyArray::from_array(result)
}

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
pub extend ResolvedType with Eq::{equal, not_equal}

///|
pub extend ResolvedType with @debug.Debug::{to_repr}
