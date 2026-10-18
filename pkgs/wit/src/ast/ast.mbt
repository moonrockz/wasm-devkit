///|
/// Node references are postorder arena indices. Every child precedes its parent.
/// Named fields identify semantic roles; strings and child collections are immutable.
pub(all) enum Data {
  File(items~ : ReadOnlyArray[Int32])
  Package(
    attributes~ : ReadOnlyArray[Int32],
    path~ : Int32,
    items~ : ReadOnlyArray[Int32],
    nested~ : Bool
  )
  Interface(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    items~ : ReadOnlyArray[Int32]
  )
  World(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    items~ : ReadOnlyArray[Int32]
  )
  Resource(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    methods~ : ReadOnlyArray[Int32],
    has_body~ : Bool
  )
  Alias(name~ : String, attributes~ : ReadOnlyArray[Int32], ty~ : Int32)
  Record(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    fields~ : ReadOnlyArray[Int32]
  )
  Flags(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    cases~ : ReadOnlyArray[Int32]
  )
  Enum(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    cases~ : ReadOnlyArray[Int32]
  )
  Variant(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    cases~ : ReadOnlyArray[Int32]
  )
  Function(
    name~ : String,
    attributes~ : ReadOnlyArray[Int32],
    signature~ : Int32,
    is_static~ : Bool
  )
  Constructor(
    attributes~ : ReadOnlyArray[Int32],
    params~ : ReadOnlyArray[Int32],
    result~ : Int32?
  )
  Signature(
    flavor~ : FunctionFlavor,
    asynchronous~ : Bool,
    params~ : ReadOnlyArray[Int32],
    result~ : Int32?
  )
  Import(name~ : String?, attributes~ : ReadOnlyArray[Int32], target~ : Int32)
  Export(name~ : String?, attributes~ : ReadOnlyArray[Int32], target~ : Int32)
  Use(
    attributes~ : ReadOnlyArray[Int32],
    path~ : Int32,
    names~ : ReadOnlyArray[Int32],
    renamed~ : String?
  )
  Include(
    attributes~ : ReadOnlyArray[Int32],
    path~ : Int32,
    renames~ : ReadOnlyArray[Int32]
  )
  Attribute(name~ : String, field~ : String, value~ : String)
  Path(
    namespaces~ : ReadOnlyArray[String],
    segments~ : ReadOnlyArray[String],
    version~ : String?
  )
  Rename(name~ : String, renamed~ : String?)
  Field(name~ : String, attributes~ : ReadOnlyArray[Int32], ty~ : Int32)
  Case(name~ : String, attributes~ : ReadOnlyArray[Int32], payload~ : Int32?)
  Parameter(name~ : String, ty~ : Int32)
  PrimitiveType(name~ : String)
  NamedType(name~ : String)
  ListType(element~ : Int32, length~ : String?)
  TupleType(elements~ : ReadOnlyArray[Int32])
  OptionType(payload~ : Int32)
  ResultType(ok~ : Int32?, error~ : Int32?)
  OwnType(resource~ : Int32)
  BorrowType(resource~ : Int32)
  FutureType(payload~ : Int32?)
  StreamType(payload~ : Int32?)
  MapType(key~ : Int32, value~ : Int32)
  Error(text~ : String, recovered~ : ReadOnlyArray[Int32])
} derive(Eq, Debug)

///|
pub(all) enum Kind {
  File
  Package
  Interface
  World
  Resource
  Alias
  Record
  Flags
  Enum
  Variant
  Function
  Constructor
  Signature
  Import
  Export
  Use
  Include
  Attribute
  Path
  Rename
  Field
  Case
  Parameter
  PrimitiveType
  NamedType
  ListType
  TupleType
  OptionType
  ResultType
  OwnType
  BorrowType
  FutureType
  StreamType
  MapType
  Error
} derive(Eq, Debug)

///|
pub(all) enum FunctionFlavor {
  Func
  Get
  Set
} derive(Eq, Debug)

///|
pub(all) struct Node {
  data : Data
  span : @span.Span
} derive(Eq, Debug)

///|
/// Immutable arena. Parser output is a tree rooted at the final node.
/// Call validate() after constructing an arena by hand.
pub(all) struct Tree {
  nodes : ReadOnlyArray[Node]
} derive(Eq, Debug)

///|
pub fn Data::kind(self : Data) -> Kind {
  match self {
    File(items=_) => File
    Package(attributes=_, path=_, items=_, nested=_) => Package
    Interface(name=_, attributes=_, items=_) => Interface
    World(name=_, attributes=_, items=_) => World
    Resource(name=_, attributes=_, methods=_, has_body=_) => Resource
    Alias(name=_, attributes=_, ty=_) => Alias
    Record(name=_, attributes=_, fields=_) => Record
    Flags(name=_, attributes=_, cases=_) => Flags
    Enum(name=_, attributes=_, cases=_) => Enum
    Variant(name=_, attributes=_, cases=_) => Variant
    Function(name=_, attributes=_, signature=_, is_static=_) => Function
    Constructor(attributes=_, params=_, result=_) => Constructor
    Signature(flavor=_, asynchronous=_, params=_, result=_) => Signature
    Import(name=_, attributes=_, target=_) => Import
    Export(name=_, attributes=_, target=_) => Export
    Use(attributes=_, path=_, names=_, renamed=_) => Use
    Include(attributes=_, path=_, renames=_) => Include
    Attribute(name=_, field=_, value=_) => Attribute
    Path(namespaces=_, segments=_, version=_) => Path
    Rename(name=_, renamed=_) => Rename
    Field(name=_, attributes=_, ty=_) => Field
    Case(name=_, attributes=_, payload=_) => Case
    Parameter(name=_, ty=_) => Parameter
    PrimitiveType(name=_) => PrimitiveType
    NamedType(name=_) => NamedType
    ListType(element=_, length=_) => ListType
    TupleType(elements=_) => TupleType
    OptionType(payload=_) => OptionType
    ResultType(ok=_, error=_) => ResultType
    OwnType(resource=_) => OwnType
    BorrowType(resource=_) => BorrowType
    FutureType(payload=_) => FutureType
    StreamType(payload=_) => StreamType
    MapType(key=_, value=_) => MapType
    Error(text=_, recovered=_) => Error
  }
}

///|
/// Children in source field order. This method never descends into another node.
pub fn Data::children(self : Data) -> ReadOnlyArray[Int32] {
  let out = []
  match self {
    File(items~) =>
      for child in items {
        out.push(child)
      }
    Package(attributes~, path~, items~, nested=_) => {
      for child in attributes {
        out.push(child)
      }
      out.push(path)
      for child in items {
        out.push(child)
      }
    }
    Interface(name=_, attributes~, items~) => {
      for child in attributes {
        out.push(child)
      }
      for child in items {
        out.push(child)
      }
    }
    World(name=_, attributes~, items~) => {
      for child in attributes {
        out.push(child)
      }
      for child in items {
        out.push(child)
      }
    }
    Resource(name=_, attributes~, methods~, has_body=_) => {
      for child in attributes {
        out.push(child)
      }
      for child in methods {
        out.push(child)
      }
    }
    Alias(name=_, attributes~, ty~) => {
      for child in attributes {
        out.push(child)
      }
      out.push(ty)
    }
    Record(name=_, attributes~, fields~) => {
      for child in attributes {
        out.push(child)
      }
      for child in fields {
        out.push(child)
      }
    }
    Flags(name=_, attributes~, cases~) => {
      for child in attributes {
        out.push(child)
      }
      for child in cases {
        out.push(child)
      }
    }
    Enum(name=_, attributes~, cases~) => {
      for child in attributes {
        out.push(child)
      }
      for child in cases {
        out.push(child)
      }
    }
    Variant(name=_, attributes~, cases~) => {
      for child in attributes {
        out.push(child)
      }
      for child in cases {
        out.push(child)
      }
    }
    Function(name=_, attributes~, signature~, is_static=_) => {
      for child in attributes {
        out.push(child)
      }
      out.push(signature)
    }
    Constructor(attributes~, params~, result~) => {
      for child in attributes {
        out.push(child)
      }
      for child in params {
        out.push(child)
      }
      if result is Some(child) {
        out.push(child)
      }
    }
    Signature(flavor=_, asynchronous=_, params~, result~) => {
      for child in params {
        out.push(child)
      }
      if result is Some(child) {
        out.push(child)
      }
    }
    Import(name=_, attributes~, target~) => {
      for child in attributes {
        out.push(child)
      }
      out.push(target)
    }
    Export(name=_, attributes~, target~) => {
      for child in attributes {
        out.push(child)
      }
      out.push(target)
    }
    Use(attributes~, path~, names~, renamed=_) => {
      for child in attributes {
        out.push(child)
      }
      out.push(path)
      for child in names {
        out.push(child)
      }
    }
    Include(attributes~, path~, renames~) => {
      for child in attributes {
        out.push(child)
      }
      out.push(path)
      for child in renames {
        out.push(child)
      }
    }
    Attribute(name=_, field=_, value=_) => ()
    Path(namespaces=_, segments=_, version=_) => ()
    Rename(name=_, renamed=_) => ()
    Field(name=_, attributes~, ty~) => {
      for child in attributes {
        out.push(child)
      }
      out.push(ty)
    }
    Case(name=_, attributes~, payload~) => {
      for child in attributes {
        out.push(child)
      }
      if payload is Some(child) {
        out.push(child)
      }
    }
    Parameter(name=_, ty~) => out.push(ty)
    PrimitiveType(name=_) => ()
    NamedType(name=_) => ()
    ListType(element~, length=_) => out.push(element)
    TupleType(elements~) =>
      for child in elements {
        out.push(child)
      }
    OptionType(payload~) => out.push(payload)
    ResultType(ok~, error~) => {
      if ok is Some(child) {
        out.push(child)
      }
      if error is Some(child) {
        out.push(child)
      }
    }
    OwnType(resource~) => out.push(resource)
    BorrowType(resource~) => out.push(resource)
    FutureType(payload~) => if payload is Some(child) { out.push(child) }
    StreamType(payload~) => if payload is Some(child) { out.push(child) }
    MapType(key~, value~) => {
      out.push(key)
      out.push(value)
    }
    Error(text=_, recovered~) =>
      for child in recovered {
        out.push(child)
      }
  }
  ReadOnlyArray::from_array(out)
}

///|
pub fn Tree::root(self : Tree) -> Int32? {
  if self.nodes.is_empty() {
    None
  } else {
    Some(self.nodes.length() - 1)
  }
}

///|
/// Validate range bounds, postorder edges, containment and exactly one parent
/// per non-root node. Linear in arena size; no recursive validation or destruction.
pub fn Tree::validate(self : Tree) -> Bool {
  guard !self.nodes.is_empty() else { return false }
  let parents = Array::make(self.nodes.length(), 0)
  for i, node in self.nodes {
    guard node.span.start >= 0 && node.span.end >= node.span.start else {
      return false
    }
    let mut previous_end = node.span.start
    for child in node.data.children() {
      guard child >= 0 &&
        child < i &&
        node.span.contains(self.nodes[child].span) else {
        return false
      }
      guard self.nodes[child].span.start >= previous_end else { return false }
      previous_end = self.nodes[child].span.end
      parents[child] += 1
      guard parents[child] == 1 else { return false }
    }
  }
  for i in 0..<(parents.length() - 1) {
    guard parents[i] == 1 else { return false }
  }
  parents[parents.length() - 1] == 0
}

///|
pub extend Data with Eq::{equal, not_equal}

///|
pub extend Data with @debug.Debug::{to_repr}

///|
pub extend Kind with Eq::{equal, not_equal}

///|
pub extend Kind with @debug.Debug::{to_repr}

///|
pub extend FunctionFlavor with Eq::{equal, not_equal}

///|
pub extend FunctionFlavor with @debug.Debug::{to_repr}

///|
pub extend Node with Eq::{equal, not_equal}

///|
pub extend Node with @debug.Debug::{to_repr}

///|
pub extend Tree with Eq::{equal, not_equal}

///|
pub extend Tree with @debug.Debug::{to_repr}
