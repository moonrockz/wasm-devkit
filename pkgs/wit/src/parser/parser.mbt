///|
/// Proposal switches. Disabled syntax is retained with WIT-P005 diagnostics.
pub(all) struct Features {
  nested_names : Bool
  fixed_lists : Bool
  external_ids : Bool
  accessors : Bool
}

///|
///
/// Enable only the grammar extension your source needs.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "Features::default: Enable only the grammar extension your source needs" {
///   let source = "interface api { type bytes = list<u8, 16>; }"
///   assert_false(@parser.parse(source).is_valid())
///   let features = { ..@parser.Features::default(), fixed_lists: true, }
///   let parsed = @parser.parse(source, features~)
///   assert_true(parsed.is_valid())
///   assert_eq(parsed.cst.to_source(), source)
/// }
/// ```
pub fn Features::default() -> Features {
  {
    nested_names: false,
    fixed_lists: false,
    external_ids: false,
    accessors: false,
  }
}

///|
///
/// Read a corpus with all supported extensions.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "Features::all: Read a corpus with all supported extensions" {
///   let source = "interface api { type bytes = list<u8, 16>; }"
///   let parsed = @parser.parse(source, features=@parser.Features::all())
///   assert_true(parsed.is_valid())
///   // The feature profile is a parsing choice, not a semantic resolver.
///   assert_true(parsed.ast.validate())
/// }
/// ```
pub fn Features::all() -> Features {
  {
    nested_names: true,
    fixed_lists: true,
    external_ids: true,
    accessors: true,
  }
}

///|
/// AST and CST indices correspond one-to-one. Both arenas are postorder.
///
/// A file API combines shared record data, a resource constructor and method, an owned
/// resource result and a world export. Read typed fields to find the declarations your tool needs.
///
/// Example import: `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "Parse: Inspect a resource-based API and its world" {
///   let source =
///     #|package example:files;
///     #|interface files {
///     #|  record metadata { size: u64 }
///     #|  resource file {
///     #|    constructor(path: string);
///     #|    stat: func() -> metadata;
///     #|  }
///     #|  open: func(path: string) -> result<own<file>, string>;
///     #|}
///     #|world app { export files; }
///   let parsed = @parser.parse(source)
///   assert_true(parsed.is_valid())
///   assert_eq(parsed.cst.to_source(), source)
///   let resources = parsed.ast.nodes.filter(node => node.data.kind() == Resource)
///   assert_eq(resources.length(), 1)
///   guard resources[0].data is Resource(name~, methods~, has_body~, ..) else {
///     fail("expected typed resource data")
///   }
///   assert_eq(name, "file")
///   assert_true(has_body)
///   assert_eq(methods.length(), 2)
///   assert_true(parsed.ast.nodes.any(node => node.data.kind() == World))
///   assert_true(parsed.ast.nodes.any(node => node.data.kind() == Record))
/// }
/// ```
pub(all) struct Parse {
  ast : @ast.Tree
  cst : @cst.Tree
  diagnostics : ReadOnlyArray[@diagnostic.Diagnostic]
}

///|
///
/// Inspect diagnostics while retaining invalid input.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "Parse::is_valid: Inspect diagnostics while retaining invalid input" {
///   let source = "interface broken { type missing = ; } interface later {}"
///   let parsed = @parser.parse(source)
///   assert_false(parsed.is_valid())
///   assert_false(parsed.diagnostics.is_empty())
///   assert_eq(parsed.cst.to_source(), source)
///   assert_true(parsed.ast.validate() && parsed.cst.validate())
///   assert_true(
///     parsed.ast.nodes.any(node => node.data is Interface(name="later", ..)),
///   )
/// }
/// ```
pub fn Parse::is_valid(self : Parse) -> Bool {
  !self.diagnostics.any(d => d.severity == Error)
}

///|
priv enum Context {
  File
  Package
  Interface
  World
  Resource
}

///|
priv enum FieldMode {
  Record
  Variant
  Names
  Parameters
  Types
}

///|
priv enum Task {
  Items(Context, Bool)
  Item(Context)
  Finish
  Expect(@scanner.TokenKind, String)
  Fields(FieldMode, @scanner.TokenKind, Bool)
  Field(FieldMode)
  Type
  NamedType
  Signature
  ResultTypeTail
  ListTypeTail
  AfterParams
}

///|
priv struct Frame {
  first : Int32
  start : Int32
  children : Array[Int32]
  mut make : (ReadOnlyArray[Int32]) -> @ast.Data
}

///|
priv struct State {
  tokens : ReadOnlyArray[@scanner.Token]
  significant : ReadOnlyArray[Int32]
  features : Features
  mut at : Int32
  mut package_seen : Bool
  mut item_seen : Bool
  frames : Array[Frame]
  tasks : Array[Task]
  nodes : Array[@ast.Node]
  concrete : Array[@cst.Node]
  diagnostics : Array[@diagnostic.Diagnostic]
}

///|
fn State::peek(self : State, ahead : Int32) -> @scanner.Token {
  let index = if self.at + ahead < self.significant.length() {
    self.at + ahead
  } else {
    self.significant.length() - 1
  }
  self.tokens[self.significant[index]]
}

///|
fn State::current(self : State) -> @scanner.Token {
  self.peek(0)
}

///|
fn State::raw(self : State) -> Int32 {
  self.significant[self.at]
}

///|
fn State::bump(self : State) -> Unit {
  if self.at + 1 < self.significant.length() {
    self.at += 1
  }
}

///|
fn State::eat(self : State, kind : @scanner.TokenKind) -> Bool {
  if self.current().kind == kind {
    self.bump()
    true
  } else {
    false
  }
}

///|
fn State::word(self : State, text : String) -> Bool {
  self.current().kind == Keyword && self.current().text == text
}

///|
fn State::eat_word(self : State, text : String) -> Bool {
  if self.word(text) {
    self.bump()
    true
  } else {
    false
  }
}

///|
fn State::error(
  self : State,
  code : String,
  message : String,
  recovery~ : @diagnostic.Recovery = Continue,
) -> Unit {
  let token = self.current()
  self.diagnostics.push(
    @diagnostic.Diagnostic::error(
      code,
      message,
      token.span,
      recovery=if token.kind == Eof { EndOfInput } else { recovery },
    ),
  )
}

///|
fn State::expect(
  self : State,
  kind : @scanner.TokenKind,
  text : String,
) -> Bool {
  if self.eat(kind) {
    true
  } else {
    self.error("WIT-P001", "expected " + text)
    false
  }
}

///|
fn State::expect_word(self : State, word : String) -> Unit {
  if !self.eat_word(word) {
    self.error("WIT-P001", "expected '" + word + "'")
  }
}

///|
fn unescape(text : String) -> String {
  if text.has_prefix("%") {
    text.unsafe_substring(start=1, end=text.length())
  } else {
    text
  }
}

///|
fn State::name(self : State) -> String {
  let token = self.current()
  if token.kind == Identifier {
    self.bump()
    unescape(token.text)
  } else {
    self.error("WIT-P001", "expected identifier")
    ""
  }
}

///|
fn State::gate(self : State, enabled : Bool, feature : String) -> Unit {
  if !enabled {
    self.error("WIT-P005", feature + " syntax is disabled")
  }
}

///|
fn State::begin(
  self : State,
  make : (ReadOnlyArray[Int32]) -> @ast.Data,
) -> Unit {
  self.frames.push({
    first: self.raw(),
    start: self.current().span.start,
    children: [],
    make,
  })
}

///|
fn State::set_make(
  self : State,
  make : (ReadOnlyArray[Int32]) -> @ast.Data,
) -> Unit {
  self.frames[self.frames.length() - 1].make = make
}

///|
fn State::emit(
  self : State,
  data : @ast.Data,
  start : Int32,
  first : Int32,
) -> Unit {
  let span : @span.Span = { start, end: self.current().span.start, }
  let id = self.nodes.length()
  self.nodes.push({ data, span, })
  self.concrete.push({
    kind: data.kind(),
    span,
    first_token: first,
    last_token: self.raw(),
    children: data.children(),
  })
  if self.frames.last() is Some(parent) {
    parent.children.push(id)
  }
}

///|
fn State::finish(self : State) -> Unit {
  if self.frames.pop() is Some(frame) {
    self.emit(
      (frame.make)(ReadOnlyArray::from_array(frame.children)),
      frame.start,
      frame.first,
    )
  }
}

///|
fn part(
  children : ReadOnlyArray[Int32],
  start : Int32,
  end : Int32,
) -> ReadOnlyArray[Int32] {
  ReadOnlyArray::makei(end - start, i => children[start + i])
}

///|
fn attrs(
  children : ReadOnlyArray[Int32],
  count : Int32,
) -> ReadOnlyArray[Int32] {
  part(children, 0, count)
}

///|
fn rest(children : ReadOnlyArray[Int32], start : Int32) -> ReadOnlyArray[Int32] {
  part(children, start, children.length())
}

///|
fn boundary(token : @scanner.Token) -> Bool {
  token.kind == Eof ||
  token.kind == RBrace ||
  token.kind == Semicolon ||
  token.kind == At ||
  (
    token.kind == Keyword &&
    [
      "interface", "world", "package", "type", "record", "flags", "enum", "variant",
      "resource", "import", "export", "include", "use",
    ].contains(token.text)
  )
}

///|
fn State::bad_type(self : State) -> Unit {
  let token = self.current()
  let first = self.raw()
  self.error("WIT-P001", "expected type")
  if !boundary(token) &&
    token.kind != Comma &&
    token.kind != RParen &&
    token.kind != RAngle {
    self.bump()
  }
  self.emit(Error(text=token.text, recovered=[]), token.span.start, first)
}

///|
fn valid_semver(version : String) -> Bool {
  let build_parts = version.split("+").to_array()
  guard build_parts.length() <= 2 else { return false }
  let before_build = build_parts[0].to_owned()
  let dash = before_build.find("-")
  let core = match dash {
    Some(i) => before_build[:i].to_owned()
    None => before_build
  }
  let numbers = core.split(".").to_array()
  guard numbers.length() == 3 else { return false }
  for number in numbers {
    guard !number.is_empty() && !(number.length() > 1 && number.has_prefix("0")) else {
      return false
    }
    for c in number {
      guard c >= '0' && c <= '9' else { return false }
    }
  }
  let labels = []
  if dash is Some(i) {
    labels.push((before_build[i + 1:].to_owned(), true))
  }
  if build_parts.length() == 2 {
    labels.push((build_parts[1].to_owned(), false))
  }
  for (group, prerelease) in labels {
    for label in group.split(".") {
      guard !label.is_empty() else { return false }
      let mut numeric = true
      for c in label {
        let is_digit = c >= '0' && c <= '9'
        guard is_digit ||
          (c >= 'a' && c <= 'z') ||
          (c >= 'A' && c <= 'Z') ||
          c == '-' else {
          return false
        }
        numeric = numeric && is_digit
      }
      guard !(prerelease &&
        numeric &&
        label.length() > 1 &&
        label.has_prefix("0")) else {
        return false
      }
    }
  }
  true
}

///|
fn State::version(self : State) -> String {
  let token = self.current()
  if token.kind == Version {
    if !valid_semver(token.text) {
      self.error("WIT-P002", "invalid semantic version")
    }
    self.bump()
    token.text
  } else {
    self.error("WIT-P002", "expected semantic version")
    if token.kind == Integer {
      self.bump()
    }
    ""
  }
}

///|
fn State::path(self : State, package_decl : Bool) -> Unit {
  let start = self.current().span.start
  let first = self.raw()
  let namespaces = []
  let segments = [self.name()]
  while self.eat(Colon) {
    namespaces.push(segments[segments.length() - 1])
    segments[segments.length() - 1] = self.name()
  }
  while self.eat(Slash) {
    segments.push(self.name())
  }
  if namespaces.length() > 1 ||
    segments.length() > (if package_decl { 1 } else { 2 }) {
    self.gate(self.features.nested_names, "nested namespaces/packages")
  }
  if package_decl && namespaces.is_empty() {
    self.error("WIT-P003", "package names require a namespace")
  }
  if !package_decl && !namespaces.is_empty() && segments.length() < 2 {
    self.error(
      "WIT-P003", "interface/world paths require a slash after the package name",
    )
  }
  if !package_decl && namespaces.is_empty() && segments.length() != 1 {
    self.error("WIT-P003", "local paths must be a single identifier")
  }
  let version = if self.eat(At) {
    if namespaces.is_empty() {
      self.error("WIT-P003", "local names cannot have package versions")
    }
    Some(self.version())
  } else {
    None
  }
  self.emit(
    Path(
      namespaces=ReadOnlyArray::from_array(namespaces),
      segments=ReadOnlyArray::from_array(segments),
      version~,
    ),
    start,
    first,
  )
}

///|
fn State::attributes(self : State) -> Int32 {
  let mut count = 0
  while self.current().kind == At {
    let start = self.current().span.start
    let first = self.raw()
    self.bump()
    let name = self.name()
    ignore(self.expect(LParen, "'('"))
    let field = if name == "external-id" { "" } else { self.name() }
    if name != "external-id" {
      ignore(self.expect(Equal, "'='"))
    }
    let value = match name {
      "since" | "deprecated" => {
        if field != "version" {
          self.error("WIT-P004", "attribute requires a version field")
        }
        self.version()
      }
      "unstable" => {
        if field != "feature" {
          self.error("WIT-P004", "attribute requires a feature field")
        }
        self.name()
      }
      "external-id" => {
        self.gate(self.features.external_ids, "external-id")
        let value = self.current().text
        ignore(self.expect(StringLiteral, "string name"))
        value
      }
      _ => {
        self.error("WIT-P004", "unknown attribute")
        let value = self.current().text
        if self.current().kind != RParen && !boundary(self.current()) {
          self.bump()
        }
        value
      }
    }
    ignore(self.expect(RParen, "')'"))
    self.emit(Attribute(name~, field~, value~), start, first)
    count += 1
  }
  count
}

///|
/// Skip one malformed item with balanced braces, preserving later declarations.
fn State::recover_item(self : State) -> Unit {
  let first = self.raw()
  let start = self.current().span.start
  self.error("WIT-P006", "unexpected token in item list", recovery=SkipToken)
  let mut depth = 0
  while self.current().kind != Eof {
    let token = self.current()
    if depth == 0 && token.kind == RBrace {
      break
    }
    if self.raw() != first &&
      depth == 0 &&
      boundary(token) &&
      token.kind != Semicolon {
      break
    }
    if token.kind == LBrace {
      depth += 1
    }
    if token.kind == RBrace {
      depth -= 1
    }
    self.bump()
    if depth == 0 && (token.kind == Semicolon || token.kind == RBrace) {
      break
    }
  }
  // Root-level unmatched closers must also make progress.
  if self.raw() == first && self.current().kind != Eof {
    self.bump()
  }
  let text = StringBuilder()
  for i in first..<self.raw() {
    text.write_string(self.tokens[i].text)
  }
  self.emit(Error(text=text.to_string(), recovered=[]), start, first)
}

///|
fn State::renames(self : State, required_alias : Bool) -> Unit {
  let mut first_item = true
  while self.current().kind != RBrace && self.current().kind != Eof {
    if boundary(self.current()) {
      break
    }
    if !first_item {
      if !self.eat(Comma) {
        self.error("WIT-P001", "expected ','")
      }
      if self.current().kind == RBrace {
        break
      }
    }
    let first = self.raw()
    let start = self.current().span.start
    let name = self.name()
    let renamed = if self.eat_word("as") {
      Some(self.name())
    } else {
      if required_alias {
        self.error("WIT-P001", "expected 'as'")
      }
      None
    }
    self.emit(Rename(name~, renamed~), start, first)
    if first == self.raw() {
      self.bump()
    }
    first_item = false
  }
  ignore(self.expect(RBrace, "'}'"))
}

///|
fn State::item(self : State, context : Context) -> Unit {
  self.begin(_ => Error(text="", recovered=[]))
  let count = self.attributes()
  let word = self.current().text
  let top = context is (File | Package)
  let tydef = ["type", "record", "flags", "enum", "variant", "resource"].contains(
      word,
    ) &&
    self.current().kind == Keyword
  if (tydef && (top || context is Resource)) ||
    ((word == "interface" || word == "world") && !top) ||
    (
      (word == "import" || word == "export" || word == "include") &&
      !(context is World)
    ) ||
    (word == "package" && !top) {
    self.error("WIT-P003", "declaration is not allowed in this scope")
  }
  if context is File {
    if word == "package" && self.peek(1).kind == Identifier {
      // The semicolon-vs-body check is made after reading the package path.
      ()
    } else {
      self.item_seen = true
    }
  }
  self.tasks.push(Finish)
  match word {
    "package" if self.current().kind == Keyword => {
      self.bump()
      self.path(true)
      if count > 0 {
        self.error("WIT-P004", "package declarations cannot have attributes")
      }
      if self.eat(LBrace) {
        if context is File {
          self.item_seen = true
        }
        self.set_make(c => {
          Package(
            path=c[count],
            attributes=attrs(c, count),
            items=rest(c, count + 1),
            nested=true,
          )
        })
        self.tasks.push(Items(Package, true))
      } else {
        if !(context is File) {
          self.error("WIT-P003", "nested packages require a body")
        }
        if self.package_seen || self.item_seen {
          self.error(
            "WIT-P003", "root package declaration must occur once, before other items",
          )
        }
        self.package_seen = true
        self.set_make(c => {
          Package(
            path=c[count],
            attributes=attrs(c, count),
            items=[],
            nested=false,
          )
        })
        ignore(self.expect(Semicolon, "';'"))
      }
    }
    "interface" | "world" if self.current().kind == Keyword => {
      self.bump()
      let name = self.name()
      let is_world = word == "world"
      self.set_make(c => {
        if is_world {
          World(name~, attributes=attrs(c, count), items=rest(c, count))
        } else {
          Interface(name~, attributes=attrs(c, count), items=rest(c, count))
        }
      })
      if self.expect(LBrace, "'{'") {
        self.tasks.push(Items(if is_world { World } else { Interface }, true))
      }
    }
    "type" if self.current().kind == Keyword => {
      self.bump()
      let name = self.name()
      self.set_make(c => Alias(name~, attributes=attrs(c, count), ty=c[count]))
      ignore(self.expect(Equal, "'='"))
      self.tasks.push(Expect(Semicolon, "';'"))
      self.tasks.push(Type)
    }
    "record" | "flags" | "enum" | "variant" if self.current().kind == Keyword => {
      self.bump()
      let name = self.name()
      self.set_make(c => {
        let attributes = attrs(c, count)
        let members = rest(c, count)
        match word {
          "record" => Record(name~, attributes~, fields=members)
          "flags" => Flags(name~, attributes~, cases=members)
          "enum" => Enum(name~, attributes~, cases=members)
          _ => Variant(name~, attributes~, cases=members)
        }
      })
      if self.expect(LBrace, "'{'") {
        let mode = match word {
          "record" => Record
          "variant" => Variant
          _ => Names
        }
        self.tasks.push(Fields(mode, RBrace, true))
      }
    }
    "resource" if self.current().kind == Keyword => {
      self.bump()
      let name = self.name()
      let has_body = self.eat(LBrace)
      self.set_make(c => {
        Resource(
          name~,
          attributes=attrs(c, count),
          methods=rest(c, count),
          has_body~,
        )
      })
      if has_body {
        self.tasks.push(Items(Resource, true))
      } else {
        ignore(self.expect(Semicolon, "';'"))
      }
    }
    "use" if self.current().kind == Keyword => {
      if context is Resource {
        self.error("WIT-P003", "use is not allowed in a resource")
      }
      self.bump()
      self.path(false)
      let renamed = if self.eat_word("as") {
        if !top {
          self.error("WIT-P003", "only top-level use can rename an interface")
        }
        Some(self.name())
      } else {
        None
      }
      self.set_make(c => {
        Use(
          path=c[count],
          attributes=attrs(c, count),
          names=rest(c, count + 1),
          renamed~,
        )
      })
      if self.eat(Dot) {
        if top {
          self.error("WIT-P003", "top-level use cannot select type names")
        }
        if self.expect(LBrace, "'{'") {
          self.renames(false)
        }
      } else if !top {
        self.error("WIT-P001", "expected '.{names}'")
      }
      ignore(self.expect(Semicolon, "';'"))
    }
    "include" if self.current().kind == Keyword => {
      self.bump()
      self.path(false)
      self.set_make(c => {
        Include(
          path=c[count],
          attributes=attrs(c, count),
          renames=rest(c, count + 1),
        )
      })
      if self.eat_word("with") {
        if self.expect(LBrace, "'{'") {
          self.renames(true)
        }
        ignore(self.eat(Semicolon))
      } else {
        ignore(self.expect(Semicolon, "';'"))
      }
    }
    "import" | "export" if self.current().kind == Keyword => {
      self.bump()
      self.external(word == "import", count)
    }
    "constructor" if context is Resource && self.current().kind == Keyword => {
      self.bump()
      self.set_make(c => {
        let body = rest(c, count)
        let params = body
          .iter()
          .filter(id => self.nodes[id].data.kind() == Parameter)
          .to_array()
        let result = body
          .iter()
          .find_first(id => self.nodes[id].data.kind() != Parameter)
        Constructor(
          attributes=attrs(c, count),
          params=ReadOnlyArray::from_array(params),
          result~,
        )
      })
      let params = self.expect(LParen, "'('")
      self.tasks.push(Expect(Semicolon, "';'"))
      self.tasks.push(AfterParams)
      if params {
        self.tasks.push(Fields(Parameters, RParen, true))
      }
    }
    _ if self.current().kind == Identifier &&
      (context is Interface || context is Resource) => {
      let name = self.name()
      ignore(self.expect(Colon, "':'"))
      let is_static = self.eat_word("static")
      if is_static && !(context is Resource) {
        self.error("WIT-P003", "static functions require a resource")
      }
      self.set_make(c => {
        Function(
          name~,
          attributes=attrs(c, count),
          signature=c[count],
          is_static~,
        )
      })
      self.tasks.push(Expect(Semicolon, "';'"))
      self.tasks.push(Signature)
    }
    _ => {
      self.set_make(c => Error(text="", recovered=c))
      self.recover_item()
    }
  }
}

///|
fn State::external(self : State, importing : Bool, count : Int32) -> Unit {
  let first = self.current()
  let colon = self.peek(1)
  let target = self.peek(2)
  let colon_form = colon.kind == Colon
  let function_form = (
      target.kind == Keyword &&
      (target.text == "func" || target.text == "async")
    ) ||
    (
      target.kind == Identifier &&
      (target.text == "get" || target.text == "set") &&
      self.peek(3).kind == LParen
    )
  let inline_form = target.kind == Keyword && target.text == "interface"
  let spaced = first.span.end != colon.span.start ||
    colon.span.end != target.span.start
  let named = colon_form &&
    (
      function_form ||
      inline_form ||
      spaced ||
      (
        self.features.external_ids &&
        !self.features.nested_names &&
        (self.peek(3).kind == Semicolon || self.peek(3).kind == Colon)
      )
    )
  let name = if named {
    let n = self.name()
    self.bump()
    Some(n)
  } else {
    None
  }
  self.set_make(c => {
    if importing {
      Import(name~, attributes=attrs(c, count), target=c[count])
    } else {
      Export(name~, attributes=attrs(c, count), target=c[count])
    }
  })
  if named && function_form {
    self.tasks.push(Expect(Semicolon, "';'"))
    self.tasks.push(Signature)
  } else if named && inline_form {
    self.begin(c => Interface(name="", attributes=[], items=c))
    self.bump()
    self.tasks.push(Finish)
    if self.expect(LBrace, "'{'") {
      self.tasks.push(Items(Interface, true))
    }
  } else {
    if named {
      self.gate(self.features.external_ids, "named interface import/export")
    }
    self.path(false)
    ignore(self.expect(Semicolon, "';'"))
  }
}

///|
fn State::fields(
  self : State,
  mode : FieldMode,
  closing : @scanner.TokenKind,
  first : Bool,
) -> Unit {
  if self.eat(closing) {
    return
  }
  if (
      boundary(self.current()) &&
      !(mode is Record || mode is Variant || mode is Names)
    ) ||
    self.current().kind == Eof ||
    (self.current().kind == RBrace && closing != RBrace) ||
    (self.current().kind == RParen && closing != RParen) ||
    (self.current().kind == RAngle && closing != RAngle) {
    self.error("WIT-P001", "expected closing delimiter")
    return
  }
  if !first {
    if !self.eat(Comma) {
      self.error("WIT-P001", "expected ','")
    }
    if self.eat(closing) {
      return
    }
  }
  if self.current().kind == Eof ||
    (boundary(self.current()) && self.current().kind != At) {
    self.error("WIT-P001", "expected member or closing delimiter")
    return
  }
  self.tasks.push(Fields(mode, closing, false))
  self.tasks.push(if mode is Types { Type } else { Field(mode) })
}

///|
fn State::field(self : State, mode : FieldMode) -> Unit {
  self.begin(_ => Error(text="", recovered=[]))
  let count = if mode is Parameters { 0 } else { self.attributes() }
  if count > 0 {
    self.error("WIT-P004", "attributes are not permitted on aggregate members")
  }
  let before = self.raw()
  let name = self.name()
  if self.raw() == before &&
    self.current().kind != Eof &&
    self.current().kind != RBrace &&
    self.current().kind != RParen {
    self.bump()
  }
  self.tasks.push(Finish)
  match mode {
    Record | Parameters => {
      self.set_make(c => {
        if mode is Parameters {
          Parameter(name~, ty=c[0])
        } else {
          Field(name~, attributes=attrs(c, count), ty=c[count])
        }
      })
      ignore(self.expect(Colon, "':'"))
      self.tasks.push(Type)
    }
    _ => {
      self.set_make(c => {
        Case(name~, attributes=attrs(c, count), payload=c.get(count))
      })
      if mode is Variant && self.eat(LParen) {
        self.tasks.push(Expect(RParen, "')'"))
        self.tasks.push(Type)
      }
    }
  }
}

///|
fn State::signature(self : State) -> Unit {
  self.begin(_ => Error(text="", recovered=[]))
  let asynchronous = self.eat_word("async")
  let token = self.current()
  let flavor : @ast.FunctionFlavor = if token.kind == Identifier &&
    token.text == "get" {
    self.gate(self.features.accessors, "accessors")
    self.bump()
    Get
  } else if token.kind == Identifier && token.text == "set" {
    self.gate(self.features.accessors, "accessors")
    self.bump()
    Set
  } else {
    self.expect_word("func")
    Func
  }
  if asynchronous && flavor != Func {
    self.error("WIT-P003", "accessors cannot be async")
  }
  self.set_make(c => {
    let params = c
      .iter()
      .filter(id => self.nodes[id].data.kind() == Parameter)
      .to_array()
    let result = c
      .iter()
      .find_first(id => self.nodes[id].data.kind() != Parameter)
    Signature(
      flavor~,
      asynchronous~,
      params=ReadOnlyArray::from_array(params),
      result~,
    )
  })
  self.tasks.push(Finish)
  self.tasks.push(AfterParams)
  if self.expect(LParen, "'('") {
    self.tasks.push(Fields(Parameters, RParen, true))
  }
}

///|
fn State::ty(self : State) -> Unit {
  let token = self.current()
  let first = self.raw()
  if token.kind == Identifier {
    self.bump()
    self.emit(NamedType(name=unescape(token.text)), token.span.start, first)
    return
  }
  if token.kind != Keyword {
    self.bad_type()
    return
  }
  match token.text {
    "u8"
    | "u16"
    | "u32"
    | "u64"
    | "s8"
    | "s16"
    | "s32"
    | "s64"
    | "f32"
    | "f64"
    | "char"
    | "bool"
    | "string"
    | "error-context" => {
      self.bump()
      self.emit(PrimitiveType(name=token.text), token.span.start, first)
    }
    "list"
    | "tuple"
    | "option"
    | "result"
    | "own"
    | "borrow"
    | "future"
    | "stream"
    | "map" => {
      let kind = token.text
      self.begin(_ => Error(text="", recovered=[]))
      self.bump()
      self.tasks.push(Finish)
      match kind {
        "list" => {
          self.set_make(c => ListType(element=c[0], length=None))
          ignore(self.expect(LAngle, "'<'"))
          self.tasks.push(ListTypeTail)
          self.tasks.push(Type)
        }
        "tuple" => {
          self.set_make(c => TupleType(elements=c))
          ignore(self.expect(LAngle, "'<'"))
          self.tasks.push(Fields(Types, RAngle, true))
        }
        "option" | "own" | "borrow" => {
          self.set_make(c => {
            match kind {
              "option" => OptionType(payload=c[0])
              "own" => OwnType(resource=c[0])
              _ => BorrowType(resource=c[0])
            }
          })
          ignore(self.expect(LAngle, "'<'"))
          self.tasks.push(Expect(RAngle, "'>'"))
          self.tasks.push(if kind == "option" { Type } else { NamedType })
        }
        "result" => {
          self.set_make(_ => ResultType(ok=None, error=None))
          if self.eat(LAngle) {
            if self.eat(Underscore) {
              self.set_make(c => ResultType(ok=None, error=Some(c[0])))
              ignore(self.expect(Comma, "','"))
              self.tasks.push(Expect(RAngle, "'>'"))
              self.tasks.push(Type)
            } else {
              self.set_make(c => ResultType(ok=Some(c[0]), error=None))
              self.tasks.push(ResultTypeTail)
              self.tasks.push(Type)
            }
          }
        }
        "future" | "stream" => {
          self.set_make(c => {
            if kind == "future" {
              FutureType(payload=c.get(0))
            } else {
              StreamType(payload=c.get(0))
            }
          })
          if self.eat(LAngle) {
            self.tasks.push(Expect(RAngle, "'>'"))
            self.tasks.push(Type)
          }
        }
        _ => {
          self.set_make(c => MapType(key=c[0], value=c[1]))
          ignore(self.expect(LAngle, "'<'"))
          self.tasks.push(Expect(RAngle, "'>'"))
          self.tasks.push(Type)
          self.tasks.push(Expect(Comma, "','"))
          self.tasks.push(Type)
        }
      }
    }
    _ => self.bad_type()
  }
}

///|
/// Pure recovering syntax parse. Every grammar continuation is a Task, so input
/// nesting consumes heap work-stack entries rather than the language call stack.
///
/// Parse a complete WIT document.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "parse: Parse a complete WIT document" {
///   let source = "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }"
///   let parsed = @parser.parse(source)
///   assert_true(parsed.is_valid())
///   assert_true(parsed.diagnostics.is_empty())
///   assert_true(parsed.ast.validate())
///   assert_true(parsed.cst.validate())
///   assert_eq(parsed.cst.to_source(), source)
///   assert_eq(parsed.ast.nodes.length(), parsed.cst.nodes.length())
/// }
/// ```
pub fn parse(
  text : String,
  features~ : Features = Features::default(),
) -> Parse {
  let scan = @scanner.scan(text)
  let significant = []
  for index, token in scan.tokens {
    if !token.kind.is_trivia() {
      significant.push(index)
    }
  }
  let state : State = {
    tokens: scan.tokens,
    significant: ReadOnlyArray::from_array(significant),
    features,
    at: 0,
    package_seen: false,
    item_seen: false,
    frames: [],
    tasks: [],
    nodes: [],
    concrete: [],
    diagnostics: scan.diagnostics.iter().to_array(),
  }
  state.frames.push({
    first: 0,
    start: 0,
    children: [],
    make: c => File(items=c),
  })
  state.tasks.push(Finish)
  state.tasks.push(Items(File, false))
  while state.tasks.pop() is Some(task) {
    match task {
      Finish => state.finish()
      Expect(kind, spelling) => ignore(state.expect(kind, spelling))
      Items(context, nested) =>
        if state.current().kind == Eof {
          if nested {
            state.error("WIT-P001", "expected '}'")
          }
        } else if nested && state.eat(RBrace) {
          ()
        } else {
          state.tasks.push(Items(context, nested))
          state.tasks.push(Item(context))
        }
      Item(context) => state.item(context)
      Fields(mode, closing, first) => state.fields(mode, closing, first)
      Field(mode) => state.field(mode)
      Type => state.ty()
      NamedType =>
        if state.current().kind == Identifier {
          let first = state.raw()
          let token = state.current()
          state.bump()
          state.emit(
            NamedType(name=unescape(token.text)),
            token.span.start,
            first,
          )
        } else {
          state.bad_type()
        }
      Signature => state.signature()
      AfterParams => if state.eat(Arrow) { state.tasks.push(Type) }
      ResultTypeTail =>
        if state.eat(Comma) {
          state.set_make(c => ResultType(ok=Some(c[0]), error=Some(c[1])))
          state.tasks.push(Expect(RAngle, "'>'"))
          state.tasks.push(Type)
        } else {
          ignore(state.expect(RAngle, "'>'"))
        }
      ListTypeTail => {
        if state.eat(Comma) {
          state.gate(features.fixed_lists, "fixed-length lists")
          let length = state.current().text
          if state.current().kind != Integer {
            state.error(
              "WIT-P003", "fixed list length must be a decimal integer",
            )
          }
          ignore(state.expect(Integer, "integer length"))
          state.set_make(c => ListType(element=c[0], length=Some(length)))
        }
        ignore(state.expect(RAngle, "'>'"))
      }
    }
  }
  // Root uniquely includes EOF and leading/trailing trivia.
  let last = state.concrete.length() - 1
  let root = state.concrete[last]
  state.concrete[last] = {
    ..root,
    last_token: scan.tokens.length(),
    span: { start: 0, end: text.length(), },
  }
  state.nodes[last] = {
    ..state.nodes[last],
    span: { start: 0, end: text.length(), },
  }
  state.diagnostics.sort_by(fn(a, b) {
    let order = a.primary.span.start.compare(b.primary.span.start)
    if order == 0 {
      a.code.compare(b.code)
    } else {
      order
    }
  })
  {
    ast: { nodes: ReadOnlyArray::from_array(state.nodes), },
    cst: {
      tokens: scan.tokens,
      nodes: ReadOnlyArray::from_array(state.concrete),
    },
    diagnostics: ReadOnlyArray::from_array(state.diagnostics),
  }
}

///|
/// Grammar accepted by the pinned wasm-tools v1.262.0 semantic reference.
/// Keeps the older default/all syntax profiles unchanged. Disabling nested
/// namespace syntax disambiguates unspaced named interface paths.
///
/// ```mbt check
/// test "select the current semantic-reference grammar explicitly" {
///   let source = "package example:app;interface api{}world app{import a:api;}"
///   assert_false(
///     @parser.parse(source, features=@parser.Features::all()).is_valid(),
///   )
///   assert_true(
///     @parser.parse(source, features=@parser.Features::reference()).is_valid(),
///   )
/// }
/// ```
pub fn Features::reference() -> Features {
  {
    nested_names: false,
    fixed_lists: true,
    external_ids: true,
    accessors: false,
  }
}
