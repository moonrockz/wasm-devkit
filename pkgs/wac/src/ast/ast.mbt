///|
/// Immutable typed WAC data with postorder arena references.
pub(all) enum Data {
  File(directive~ : Int32?, statements~ : ReadOnlyArray[Int32])
  Package(path~ : Int32, targets~ : Int32?)
  Path(
    namespaces~ : ReadOnlyArray[String],
    segments~ : ReadOnlyArray[String],
    version~ : String?
  )
  Interface(name~ : String, items~ : ReadOnlyArray[Int32])
  World(name~ : String, items~ : ReadOnlyArray[Int32])
  Resource(name~ : String, methods~ : ReadOnlyArray[Int32], has_body~ : Bool)
  Alias(name~ : String, ty~ : Int32)
  Record(name~ : String, fields~ : ReadOnlyArray[Int32])
  Flags(name~ : String, cases~ : ReadOnlyArray[Int32])
  Enum(name~ : String, cases~ : ReadOnlyArray[Int32])
  Variant(name~ : String, cases~ : ReadOnlyArray[Int32])
  Function(name~ : String, signature~ : Int32, is_static~ : Bool)
  Constructor(params~ : ReadOnlyArray[Int32])
  Signature(
    asynchronous~ : Bool,
    params~ : ReadOnlyArray[Int32],
    result~ : Int32?
  )
  NamedResults(params~ : ReadOnlyArray[Int32])
  Import(binding~ : String, renamed~ : Int32?, ty~ : Int32)
  WorldImport(name~ : String?, target~ : Int32)
  WorldExport(name~ : String?, target~ : Int32)
  Use(path~ : Int32, names~ : ReadOnlyArray[Int32])
  Include(path~ : Int32, renames~ : ReadOnlyArray[Int32])
  Rename(name~ : String, renamed~ : String?)
  Field(name~ : String, ty~ : Int32)
  Case(name~ : String, payload~ : Int32?)
  Parameter(name~ : String, ty~ : Int32)
  PrimitiveType(name~ : String)
  NamedType(name~ : String)
  ListType(element~ : Int32)
  TupleType(elements~ : ReadOnlyArray[Int32])
  OptionType(payload~ : Int32)
  ResultType(ok~ : Int32?, error~ : Int32?)
  BorrowType(resource~ : Int32)
  FutureType(payload~ : Int32?)
  StreamType(payload~ : Int32?)
  Let(name~ : String, expression~ : Int32)
  Export(expression~ : Int32, renamed~ : Int32?, spread~ : Bool)
  Name(value~ : String, quoted~ : Bool)
  Expression(primary~ : Int32, postfix~ : ReadOnlyArray[Int32])
  Reference(name~ : String)
  Group(expression~ : Int32)
  New(component~ : Int32, arguments~ : ReadOnlyArray[Int32])
  InferredArgument(name~ : String)
  SpreadArgument(name~ : String)
  NamedArgument(name~ : Int32, value~ : Int32)
  FillArgument
  Access(name~ : String, quoted~ : Bool)
  Error(text~ : String, recovered~ : ReadOnlyArray[Int32])
} derive(Eq, Debug)

///|
pub(all) enum Kind {
  File
  Package
  Path
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
  NamedResults
  Import
  WorldImport
  WorldExport
  Use
  Include
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
  BorrowType
  FutureType
  StreamType
  Let
  Export
  Name
  Expression
  Reference
  Group
  New
  InferredArgument
  SpreadArgument
  NamedArgument
  FillArgument
  Access
  Error
} derive(Eq, Debug)

///|
pub(all) struct Node {
  data : Data
  span : @span.Span
} derive(Eq, Debug)

///|
pub(all) struct Tree {
  nodes : ReadOnlyArray[Node]
} derive(Eq, Debug)

///|
pub fn Data::kind(self : Data) -> Kind {
  match self {
    File(directive=_, statements=_) => File
    Package(path=_, targets=_) => Package
    Path(namespaces=_, segments=_, version=_) => Path
    Interface(name=_, items=_) => Interface
    World(name=_, items=_) => World
    Resource(name=_, methods=_, has_body=_) => Resource
    Alias(name=_, ty=_) => Alias
    Record(name=_, fields=_) => Record
    Flags(name=_, cases=_) => Flags
    Enum(name=_, cases=_) => Enum
    Variant(name=_, cases=_) => Variant
    Function(name=_, signature=_, is_static=_) => Function
    Constructor(params=_) => Constructor
    Signature(asynchronous=_, params=_, result=_) => Signature
    NamedResults(params=_) => NamedResults
    Import(binding=_, renamed=_, ty=_) => Import
    WorldImport(name=_, target=_) => WorldImport
    WorldExport(name=_, target=_) => WorldExport
    Use(path=_, names=_) => Use
    Include(path=_, renames=_) => Include
    Rename(name=_, renamed=_) => Rename
    Field(name=_, ty=_) => Field
    Case(name=_, payload=_) => Case
    Parameter(name=_, ty=_) => Parameter
    PrimitiveType(name=_) => PrimitiveType
    NamedType(name=_) => NamedType
    ListType(element=_) => ListType
    TupleType(elements=_) => TupleType
    OptionType(payload=_) => OptionType
    ResultType(ok=_, error=_) => ResultType
    BorrowType(resource=_) => BorrowType
    FutureType(payload=_) => FutureType
    StreamType(payload=_) => StreamType
    Let(name=_, expression=_) => Let
    Export(expression=_, renamed=_, spread=_) => Export
    Name(value=_, quoted=_) => Name
    Expression(primary=_, postfix=_) => Expression
    Reference(name=_) => Reference
    Group(expression=_) => Group
    New(component=_, arguments=_) => New
    InferredArgument(name=_) => InferredArgument
    SpreadArgument(name=_) => SpreadArgument
    NamedArgument(name=_, value=_) => NamedArgument
    FillArgument => FillArgument
    Access(name=_, quoted=_) => Access
    Error(text=_, recovered=_) => Error
  }
}

///|
pub fn Data::children(self : Data) -> ReadOnlyArray[Int32] {
  let out = []
  match self {
    File(directive~, statements~) => {
      if directive is Some(child) {
        out.push(child)
      }
      for child in statements {
        out.push(child)
      }
    }
    Package(path~, targets~) => {
      out.push(path)
      if targets is Some(child) {
        out.push(child)
      }
    }
    Path(namespaces=_, segments=_, version=_) => ()
    Interface(name=_, items~) =>
      for child in items {
        out.push(child)
      }
    World(name=_, items~) =>
      for child in items {
        out.push(child)
      }
    Resource(name=_, methods~, has_body=_) =>
      for child in methods {
        out.push(child)
      }
    Alias(name=_, ty~) => out.push(ty)
    Record(name=_, fields~) =>
      for child in fields {
        out.push(child)
      }
    Flags(name=_, cases~) =>
      for child in cases {
        out.push(child)
      }
    Enum(name=_, cases~) =>
      for child in cases {
        out.push(child)
      }
    Variant(name=_, cases~) =>
      for child in cases {
        out.push(child)
      }
    Function(name=_, signature~, is_static=_) => out.push(signature)
    Constructor(params~) =>
      for child in params {
        out.push(child)
      }
    Signature(asynchronous=_, params~, result~) => {
      for child in params {
        out.push(child)
      }
      if result is Some(child) {
        out.push(child)
      }
    }
    NamedResults(params~) =>
      for child in params {
        out.push(child)
      }
    Import(binding=_, renamed~, ty~) => {
      if renamed is Some(child) {
        out.push(child)
      }
      out.push(ty)
    }
    WorldImport(name=_, target~) => out.push(target)
    WorldExport(name=_, target~) => out.push(target)
    Use(path~, names~) => {
      out.push(path)
      for child in names {
        out.push(child)
      }
    }
    Include(path~, renames~) => {
      out.push(path)
      for child in renames {
        out.push(child)
      }
    }
    Rename(name=_, renamed=_) => ()
    Field(name=_, ty~) => out.push(ty)
    Case(name=_, payload~) => if payload is Some(child) { out.push(child) }
    Parameter(name=_, ty~) => out.push(ty)
    PrimitiveType(name=_) => ()
    NamedType(name=_) => ()
    ListType(element~) => out.push(element)
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
    BorrowType(resource~) => out.push(resource)
    FutureType(payload~) => if payload is Some(child) { out.push(child) }
    StreamType(payload~) => if payload is Some(child) { out.push(child) }
    Let(name=_, expression~) => out.push(expression)
    Export(expression~, renamed~, spread=_) => {
      out.push(expression)
      if renamed is Some(child) {
        out.push(child)
      }
    }
    Name(value=_, quoted=_) => ()
    Expression(primary~, postfix~) => {
      out.push(primary)
      for child in postfix {
        out.push(child)
      }
    }
    Reference(name=_) => ()
    Group(expression~) => out.push(expression)
    New(component~, arguments~) => {
      out.push(component)
      for child in arguments {
        out.push(child)
      }
    }
    InferredArgument(name=_) => ()
    SpreadArgument(name=_) => ()
    NamedArgument(name~, value~) => {
      out.push(name)
      out.push(value)
    }
    FillArgument => ()
    Access(name=_, quoted=_) => ()
    Error(text=_, recovered~) =>
      for child in recovered {
        out.push(child)
      }
  }
  ReadOnlyArray::from_array(out)
}

///|
pub fn Data::map_children(self : Data, replace : (Int32) -> Int32) -> Data {
  match self {
    File(directive~, statements~) =>
      File(directive=directive.map(replace), statements=statements.map(replace))
    Package(path~, targets~) =>
      Package(path=replace(path), targets=targets.map(replace))
    Path(namespaces~, segments~, version~) =>
      Path(namespaces~, segments~, version~)
    Interface(name~, items~) => Interface(name~, items=items.map(replace))
    World(name~, items~) => World(name~, items=items.map(replace))
    Resource(name~, methods~, has_body~) =>
      Resource(name~, methods=methods.map(replace), has_body~)
    Alias(name~, ty~) => Alias(name~, ty=replace(ty))
    Record(name~, fields~) => Record(name~, fields=fields.map(replace))
    Flags(name~, cases~) => Flags(name~, cases=cases.map(replace))
    Enum(name~, cases~) => Enum(name~, cases=cases.map(replace))
    Variant(name~, cases~) => Variant(name~, cases=cases.map(replace))
    Function(name~, signature~, is_static~) =>
      Function(name~, signature=replace(signature), is_static~)
    Constructor(params~) => Constructor(params=params.map(replace))
    Signature(asynchronous~, params~, result~) =>
      Signature(
        asynchronous~,
        params=params.map(replace),
        result=result.map(replace),
      )
    NamedResults(params~) => NamedResults(params=params.map(replace))
    Import(binding~, renamed~, ty~) =>
      Import(binding~, renamed=renamed.map(replace), ty=replace(ty))
    WorldImport(name~, target~) => WorldImport(name~, target=replace(target))
    WorldExport(name~, target~) => WorldExport(name~, target=replace(target))
    Use(path~, names~) => Use(path=replace(path), names=names.map(replace))
    Include(path~, renames~) =>
      Include(path=replace(path), renames=renames.map(replace))
    Rename(name~, renamed~) => Rename(name~, renamed~)
    Field(name~, ty~) => Field(name~, ty=replace(ty))
    Case(name~, payload~) => Case(name~, payload=payload.map(replace))
    Parameter(name~, ty~) => Parameter(name~, ty=replace(ty))
    PrimitiveType(name~) => PrimitiveType(name~)
    NamedType(name~) => NamedType(name~)
    ListType(element~) => ListType(element=replace(element))
    TupleType(elements~) => TupleType(elements=elements.map(replace))
    OptionType(payload~) => OptionType(payload=replace(payload))
    ResultType(ok~, error~) =>
      ResultType(ok=ok.map(replace), error=error.map(replace))
    BorrowType(resource~) => BorrowType(resource=replace(resource))
    FutureType(payload~) => FutureType(payload=payload.map(replace))
    StreamType(payload~) => StreamType(payload=payload.map(replace))
    Let(name~, expression~) => Let(name~, expression=replace(expression))
    Export(expression~, renamed~, spread~) =>
      Export(
        expression=replace(expression),
        renamed=renamed.map(replace),
        spread~,
      )
    Name(value~, quoted~) => Name(value~, quoted~)
    Expression(primary~, postfix~) =>
      Expression(primary=replace(primary), postfix=postfix.map(replace))
    Reference(name~) => Reference(name~)
    Group(expression~) => Group(expression=replace(expression))
    New(component~, arguments~) =>
      New(component=replace(component), arguments=arguments.map(replace))
    InferredArgument(name~) => InferredArgument(name~)
    SpreadArgument(name~) => SpreadArgument(name~)
    NamedArgument(name~, value~) =>
      NamedArgument(name=replace(name), value=replace(value))
    FillArgument => FillArgument
    Access(name~, quoted~) => Access(name~, quoted~)
    Error(text~, recovered~) => Error(text~, recovered=recovered.map(replace))
  }
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
/// Structural equality ignoring all source locations and arena numbering. Valid
/// trees are compared with an explicit pair stack, without recursive descent.
pub fn Tree::equivalent(self : Tree, other : Tree) -> Bool {
  guard self.validate() &&
    other.validate() &&
    self.nodes.length() == other.nodes.length() else {
    return false
  }
  let pending = [(self.nodes.length() - 1, other.nodes.length() - 1)]
  while pending.pop() is Some((left, right)) {
    let a = self.nodes[left].data
    let b = other.nodes[right].data
    guard a.map_children(_ => 0) == b.map_children(_ => 0) else { return false }
    let ac = a.children()
    let bc = b.children()
    for i in 0..<ac.length() {
      pending.push((ac[i], bc[i]))
    }
  }
  true
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
pub extend Node with Eq::{equal, not_equal}

///|
pub extend Node with @debug.Debug::{to_repr}

///|
pub extend Tree with Eq::{equal, not_equal}

///|
pub extend Tree with @debug.Debug::{to_repr}
