///|
/// The pinned reference parser rejects named results despite its LANGUAGE.md.
/// Enable this switch to retain the named-results grammar extension.
pub(all) struct Features {
  named_results : Bool
}

///|
///
/// Enable only the grammar extension your source needs.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "Features::default: Enable only the grammar extension your source needs" {
///   let source = "package demo:app; type callback = func() -> (value: u8);"
///   assert_false(@parser.parse(source).is_valid())
///   let features : @parser.Features = { named_results: true, }
///   let parsed = @parser.parse(source, features~)
///   assert_true(parsed.is_valid())
///   assert_eq(parsed.cst.to_source(), source)
/// }
/// ```
pub fn Features::default() -> Features {
  { named_results: false, }
}

///|
///
/// Read a corpus with all supported extensions.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "Features::all: Read a corpus with all supported extensions" {
///   let source = "package demo:app; type callback = func() -> (value: u8);"
///   let parsed = @parser.parse(source, features=@parser.Features::all())
///   assert_true(parsed.is_valid())
///   // The feature profile is a parsing choice, not a semantic resolver.
///   assert_true(parsed.ast.validate())
/// }
/// ```
pub fn Features::all() -> Features {
  { named_results: true, }
}

///|
///
/// The target world and component packages stay as syntax references. Spreads, fill arguments,
/// quoted names and explicit grouping remain distinct nodes for indexing and later semantic tooling.
///
/// Example import: `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "Parse: Inspect a target world and composition expression structure" {
///   let source =
///     #|package example:app targets example:types/app;
///     #|interface host-api { log: func(message: string); }
///     #|world app-world { import host: host-api; export run: func(); }
///     #|import host as "example:host/log@1.0.0": host-api;
///     #|let provider = new example:provider { host };
///     #|let app = new example:service { ...provider, "log": host.log, ... };
///     #|export (app)["run"] as "run";
///   let parsed = @parser.parse(source)
///   assert_true(parsed.is_valid())
///   assert_eq(parsed.cst.to_source(), source)
///   let kinds = parsed.ast.nodes.map(node => node.data.kind())
///   assert_true(kinds.contains(World))
///   assert_true(kinds.contains(SpreadArgument))
///   assert_true(kinds.contains(FillArgument))
///   assert_true(kinds.contains(Group))
///   assert_true(kinds.contains(Access))
///   assert_eq(kinds.filter(kind => kind == New).length(), 2)
///   assert_true(
///     parsed.ast.nodes.any(node => node.data is Access(name="run", quoted=true)),
///   )
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
/// Example imports: `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "Parse::is_valid: Inspect diagnostics while retaining invalid input" {
///   let source = "package demo:app; interface broken { type missing = ; } interface later {}"
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
  Top
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
  AfterParams
  ResultTail(Bool)
  Expression
  Primary
  Postfix
  Arguments(Bool)
  Argument
  ExportTail
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
  mut at : Int32
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
    self.error("WAC-P001", "expected " + text)
    false
  }
}

///|
fn State::expect_word(self : State, word : String) -> Unit {
  if !self.eat_word(word) {
    self.error("WAC-P001", "expected '" + word + "'")
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
    self.error("WAC-P001", "expected identifier")
    ""
  }
}

///|
fn State::gate(self : State, enabled : Bool, feature : String) -> Unit {
  if !enabled {
    self.error("WAC-P005", feature + " syntax is disabled")
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
fn rest(children : ReadOnlyArray[Int32], start : Int32) -> ReadOnlyArray[Int32] {
  part(children, start, children.length())
}

///|
fn boundary(token : @scanner.Token) -> Bool {
  token.kind == Eof ||
  token.kind == RBrace ||
  token.kind == Semicolon ||
  (
    token.kind == Keyword &&
    [
      "interface", "world", "package", "type", "record", "flags", "enum", "variant",
      "resource", "import", "export", "include", "use", "let",
    ].contains(token.text)
  )
}

///|
fn State::bad_type(self : State) -> Unit {
  let token = self.current()
  let first = self.raw()
  self.error("WAC-P001", "expected type")
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
fn State::recover_item(self : State) -> Unit {
  let first = self.raw()
  let start = self.current().span.start
  self.error("WAC-P006", "unexpected token in item list", recovery=SkipToken)
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
        self.error("WAC-P001", "expected ','")
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
        self.error("WAC-P001", "expected 'as'")
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
// Package names and paths are atomic WAC tokens; trivia cannot split them.
fn State::path(self : State, package_name : Bool, allow_local : Bool) -> Unit {
  let token = self.current()
  let first = self.raw()
  let expected = if package_name {
    @scanner.PackageName
  } else {
    @scanner.PackagePath
  }
  if token.kind != expected && !(allow_local && token.kind == Identifier) {
    self.error(
      "WAC-P003",
      if package_name {
        "expected package name"
      } else {
        "expected package path"
      },
    )
    self.emit(Error(text="", recovered=[]), token.span.start, first)
    return
  }
  self.bump()
  let pieces = token.text.split("@").to_array()
  let version = if pieces.length() > 1 {
    Some(pieces[1].to_owned())
  } else {
    None
  }
  if version is Some(v) && !valid_semver(v) {
    self.diagnostics.push(
      @diagnostic.Diagnostic::error(
        "WAC-P002",
        "invalid semantic version",
        token.span,
      ),
    )
  }
  let parts = pieces[0].split("/").to_array()
  let names = parts[0].split(":").to_array()
  let namespaces = ReadOnlyArray::makei(names.length() - 1, i => {
    names[i].to_owned()
  })
  let segments = Array::makei(parts.length(), i => {
    if i == 0 {
      names[names.length() - 1].to_owned()
    } else {
      parts[i].to_owned()
    }
  })
  // Package components retain percent spelling, as in the reference package key.
  self.emit(
    Path(namespaces~, segments=ReadOnlyArray::from_array(segments), version~),
    token.span.start,
    first,
  )
}

///|
fn State::external_name(self : State) -> Unit {
  let token = self.current()
  let first = self.raw()
  let quoted = token.kind == StringLiteral
  let value = if quoted {
    self.bump()
    if token.text.length() >= 2 && token.text.has_suffix("\"") {
      token.text.unsafe_substring(start=1, end=token.text.length() - 1)
    } else {
      ""
    }
  } else {
    self.name()
  }
  self.emit(Name(value~, quoted~), token.span.start, first)
}

///|
fn State::external_type(self : State, package_allowed : Bool) -> Unit {
  if self.word("interface") {
    self.begin(c => Interface(name="", items=c))
    self.bump()
    self.tasks.push(Finish)
    if self.expect(LBrace, "'{'") {
      self.tasks.push(Items(Interface, true))
    }
  } else if self.word("func") || self.word("async") {
    self.tasks.push(Signature)
  } else if package_allowed && self.current().kind == PackagePath {
    self.path(false, false)
  } else {
    self.tasks.push(NamedType)
  }
}

///|
fn State::item(self : State, context : Context) -> Unit {
  self.begin(_ => Error(text="", recovered=[]))
  self.tasks.push(Finish)
  let token = self.current()
  let word = token.text
  let top = context is Top
  if token.kind == Keyword {
    let invalid = match word {
      "interface" | "world" | "let" => !top
      "import" | "export" => !(top || context is World)
      "resource" => !(context is Interface || context is World)
      "include" => !(context is World)
      "use" => !(context is World || context is Interface)
      "type" | "record" | "flags" | "enum" | "variant" => context is Resource
      "constructor" => !(context is Resource)
      _ => false
    }
    if invalid {
      self.error("WAC-P003", "declaration is not allowed in this scope")
    }
  }
  match word {
    "interface" | "world" if token.kind == Keyword => {
      self.bump()
      let name = self.name()
      let is_world = word == "world"
      self.set_make(c => {
        if is_world {
          World(name~, items=c)
        } else {
          Interface(name~, items=c)
        }
      })
      if self.expect(LBrace, "'{'") {
        self.tasks.push(Items(if is_world { World } else { Interface }, true))
      }
    }
    "type" if token.kind == Keyword => {
      self.bump()
      let name = self.name()
      self.set_make(c => Alias(name~, ty=c[0]))
      ignore(self.expect(Equal, "'='"))
      self.tasks.push(Expect(Semicolon, "';'"))
      self.tasks.push(
        if self.word("func") || self.word("async") {
          Signature
        } else {
          Type
        },
      )
    }
    "record" | "flags" | "enum" | "variant" if token.kind == Keyword => {
      self.bump()
      let name = self.name()
      self.set_make(c => {
        match word {
          "record" => Record(name~, fields=c)
          "flags" => Flags(name~, cases=c)
          "enum" => Enum(name~, cases=c)
          _ => Variant(name~, cases=c)
        }
      })
      if self.expect(LBrace, "'{'") {
        self.tasks.push(
          Fields(
            match word {
              "record" => Record
              "variant" => Variant
              _ => Names
            },
            RBrace,
            true,
          ),
        )
      }
    }
    "resource" if token.kind == Keyword => {
      self.bump()
      let name = self.name()
      let has_body = self.eat(LBrace)
      self.set_make(c => Resource(name~, methods=c, has_body~))
      if has_body {
        self.tasks.push(Items(Resource, true))
      } else {
        ignore(self.expect(Semicolon, "';'"))
      }
    }
    "constructor" if token.kind == Keyword => {
      self.bump()
      self.set_make(c => Constructor(params=c))
      self.tasks.push(Expect(Semicolon, "';'"))
      if self.expect(LParen, "'('") {
        self.tasks.push(Fields(Parameters, RParen, true))
      }
    }
    "use" if token.kind == Keyword => {
      self.bump()
      self.set_make(c => Use(path=c[0], names=rest(c, 1)))
      self.path(false, true)
      ignore(self.expect(Dot, "'.'"))
      if self.expect(LBrace, "'{'") {
        self.renames(false)
      }
      ignore(self.expect(Semicolon, "';'"))
    }
    "include" if token.kind == Keyword => {
      self.bump()
      self.set_make(c => Include(path=c[0], renames=rest(c, 1)))
      self.path(false, true)
      if self.eat_word("with") && self.expect(LBrace, "'{'") {
        self.renames(true)
      }
      ignore(self.expect(Semicolon, "';'"))
    }
    "import" if token.kind == Keyword && top => {
      self.bump()
      let binding = self.name()
      let renamed = if self.eat_word("as") {
        self.external_name()
        true
      } else {
        false
      }
      self.set_make(c => {
        Import(
          binding~,
          renamed=if renamed { c.get(0) } else { None },
          ty=c[if renamed { 1 } else { 0 }],
        )
      })
      ignore(self.expect(Colon, "':'"))
      self.tasks.push(Expect(Semicolon, "';'"))
      self.external_type(true)
    }
    "import" | "export" if token.kind == Keyword && context is World => {
      self.bump()
      let name = if self.current().kind == Identifier &&
        self.peek(1).kind == Colon {
        let name = self.name()
        self.bump()
        Some(name)
      } else {
        None
      }
      self.set_make(c => {
        if word == "import" {
          WorldImport(name~, target=c[0])
        } else {
          WorldExport(name~, target=c[0])
        }
      })
      self.tasks.push(Expect(Semicolon, "';'"))
      if name is Some(_) {
        self.external_type(false)
      } else {
        self.path(false, true)
      }
    }
    "let" if token.kind == Keyword => {
      self.bump()
      let name = self.name()
      self.set_make(c => Let(name~, expression=c[0]))
      ignore(self.expect(Equal, "'='"))
      self.tasks.push(Expect(Semicolon, "';'"))
      self.tasks.push(Expression)
    }
    "export" if token.kind == Keyword && top => {
      self.bump()
      self.set_make(c => Export(expression=c[0], renamed=None, spread=false))
      self.tasks.push(ExportTail)
      self.tasks.push(Expression)
    }
    _ if token.kind == Identifier &&
      (context is Interface || context is Resource) => {
      let name = self.name()
      ignore(self.expect(Colon, "':'"))
      let is_static = self.eat_word("static")
      if is_static && !(context is Resource) {
        self.error("WAC-P003", "static functions require a resource")
      }
      self.set_make(c => Function(name~, signature=c[0], is_static~))
      self.tasks.push(Expect(Semicolon, "';'"))
      self.tasks.push(
        if context is Interface && self.current().kind == Identifier {
          NamedType
        } else {
          Signature
        },
      )
    }
    _ => {
      self.error("WAC-P006", "expected declaration", recovery=SkipToken)
      // The recovered text remains one child of this failed declaration frame.
      self.set_make(c => Error(text="", recovered=c))
      self.recover_item()
    }
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
    if first && !(mode is Parameters) {
      self.error("WAC-P003", "aggregate requires at least one member")
    }
    return
  }
  if self.current().kind == Eof ||
    boundary(self.current()) ||
    self.current().kind == RParen ||
    self.current().kind == RAngle {
    self.error("WAC-P001", "expected member or closing delimiter")
    return
  }
  if !first {
    ignore(self.expect(Comma, "','"))
    if self.eat(closing) {
      return
    }
  }
  if self.current().kind == Eof || boundary(self.current()) {
    self.error("WAC-P001", "expected member or closing delimiter")
    return
  }
  self.tasks.push(Fields(mode, closing, false))
  self.tasks.push(if mode is Types { Type } else { Field(mode) })
}

///|
fn State::field(self : State, mode : FieldMode) -> Unit {
  self.begin(_ => Error(text="", recovered=[]))
  let before = self.raw()
  let name = self.name()
  if self.raw() == before &&
    !boundary(self.current()) &&
    self.current().kind != RParen &&
    self.current().kind != RAngle {
    self.bump()
  }
  self.tasks.push(Finish)
  match mode {
    Record | Parameters => {
      self.set_make(c => {
        if mode is Parameters {
          Parameter(name~, ty=c[0])
        } else {
          Field(name~, ty=c[0])
        }
      })
      ignore(self.expect(Colon, "':'"))
      self.tasks.push(Type)
    }
    _ => {
      self.set_make(c => Case(name~, payload=c.get(0)))
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
  self.expect_word("func")
  self.set_make(c => {
    let params = c
      .iter()
      .filter(id => self.nodes[id].data.kind() == Parameter)
      .to_array()
    let result = c
      .iter()
      .find_first(id => self.nodes[id].data.kind() != Parameter)
    Signature(asynchronous~, params=ReadOnlyArray::from_array(params), result~)
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
    "list" | "tuple" | "option" | "result" | "borrow" | "future" | "stream" => {
      let kind = token.text
      self.begin(_ => Error(text="", recovered=[]))
      self.bump()
      self.tasks.push(Finish)
      match kind {
        "list" | "option" | "borrow" => {
          self.set_make(c => {
            match kind {
              "list" => ListType(element=c[0])
              "option" => OptionType(payload=c[0])
              _ => BorrowType(resource=c[0])
            }
          })
          ignore(self.expect(LAngle, "'<'"))
          self.tasks.push(Expect(RAngle, "'>'"))
          self.tasks.push(if kind == "borrow" { NamedType } else { Type })
        }
        "tuple" => {
          self.set_make(c => TupleType(elements=c))
          ignore(self.expect(LAngle, "'<'"))
          self.tasks.push(Fields(Types, RAngle, true))
        }
        "result" => {
          self.set_make(_ => ResultType(ok=None, error=None))
          if self.eat(LAngle) {
            let absent = self.eat(Underscore)
            if !absent {
              self.set_make(c => ResultType(ok=Some(c[0]), error=None))
              self.tasks.push(ResultTail(true))
              self.tasks.push(Type)
            } else {
              self.tasks.push(ResultTail(false))
            }
          }
        }
        _ => {
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
      }
    }
    _ => self.bad_type()
  }
}

///|
fn State::primary(self : State) -> Unit {
  let token = self.current()
  let first = self.raw()
  if token.kind == Identifier {
    self.bump()
    self.emit(Reference(name=unescape(token.text)), token.span.start, first)
  } else if self.eat(LParen) {
    // begin at the opening delimiter, which was consumed above.
    self.frames.push({
      first,
      start: token.span.start,
      children: [],
      make: c => Group(expression=c[0]),
    })
    self.tasks.push(Finish)
    self.tasks.push(Expect(RParen, "')'"))
    self.tasks.push(Expression)
  } else if self.eat_word("new") {
    self.frames.push({
      first,
      start: token.span.start,
      children: [],
      make: c => New(component=c[0], arguments=rest(c, 1)),
    })
    self.path(true, false)
    self.tasks.push(Finish)
    if self.expect(LBrace, "'{'") {
      self.tasks.push(Arguments(true))
    }
  } else {
    self.error("WAC-P001", "expected expression")
    if !boundary(token) && token.kind != RParen && token.kind != Comma {
      self.bump()
    }
    self.emit(Error(text=token.text, recovered=[]), token.span.start, first)
  }
}

///|
fn State::arguments(self : State, first : Bool) -> Unit {
  if self.eat(RBrace) {
    return
  }
  if self.current().kind == Eof || boundary(self.current()) {
    self.error("WAC-P001", "expected argument or '}'")
    return
  }
  if !first {
    ignore(self.expect(Comma, "','"))
    if self.eat(RBrace) {
      return
    }
  }
  if self.current().kind == Eof || boundary(self.current()) {
    self.error("WAC-P001", "expected argument or '}'")
    return
  }
  self.tasks.push(Arguments(false))
  self.tasks.push(Argument)
}

///|
fn State::argument(self : State) -> Unit {
  let token = self.current()
  let first = self.raw()
  if self.eat(Ellipsis) {
    if self.current().kind == Identifier {
      let name = self.name()
      self.emit(SpreadArgument(name~), token.span.start, first)
    } else {
      self.emit(FillArgument, token.span.start, first)
    }
  } else if token.kind == Identifier && self.peek(1).kind != Colon {
    let name = self.name()
    self.emit(InferredArgument(name~), token.span.start, first)
  } else if token.kind == Identifier || token.kind == StringLiteral {
    self.begin(c => NamedArgument(name=c[0], value=c[1]))
    self.external_name()
    ignore(self.expect(Colon, "':'"))
    self.tasks.push(Finish)
    self.tasks.push(Expression)
  } else {
    self.error("WAC-P001", "expected instantiation argument")
    if !boundary(token) {
      self.bump()
    }
    self.emit(Error(text=token.text, recovered=[]), token.span.start, first)
  }
}

///|
/// Pure recovering parse; all input-controlled grammar nesting uses heap tasks.
///
/// Parse a complete WAC document.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`.
///
/// ```mbt check
/// test "parse: Parse a complete WAC document" {
///   let source = "package demo:app; interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }"
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
    at: 0,
    frames: [],
    tasks: [],
    nodes: [],
    concrete: [],
    diagnostics: scan.diagnostics.iter().to_array(),
  }
  let has_header = state.word("package")
  state.frames.push({
    first: 0,
    start: 0,
    children: [],
    make: c => {
      File(
        directive=if has_header { c.get(0) } else { None },
        statements=rest(c, if has_header { 1 } else { 0 }),
      )
    },
  })
  if has_header {
    state.begin(c => Package(path=c[0], targets=c.get(1)))
    state.bump()
    state.path(true, false)
    if state.eat_word("targets") {
      state.path(false, false)
    }
    ignore(state.expect(Semicolon, "';'"))
    state.finish()
  } else {
    state.error("WAC-P003", "document requires an initial package directive")
  }
  state.tasks.push(Finish)
  state.tasks.push(Items(Top, false))
  while state.tasks.pop() is Some(task) {
    match task {
      Finish => state.finish()
      Expect(kind, text) => ignore(state.expect(kind, text))
      Items(context, nested) =>
        if state.current().kind == Eof {
          if nested {
            state.error("WAC-P001", "expected '}'")
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
      AfterParams =>
        if state.eat(Arrow) {
          if state.current().kind == LParen {
            state.gate(features.named_results, "named function results")
            state.begin(c => NamedResults(params=c))
            state.bump()
            state.tasks.push(Finish)
            state.tasks.push(Fields(Parameters, RParen, true))
          } else if state.current().kind != Semicolon {
            state.tasks.push(Type)
          }
        }
      ResultTail(has_ok) =>
        if state.eat(Comma) {
          if !state.eat(Underscore) {
            state.set_make(c => {
              ResultType(
                ok=if has_ok { c.get(0) } else { None },
                error=c.get(if has_ok { 1 } else { 0 }),
              )
            })
            state.tasks.push(Expect(RAngle, "'>'"))
            state.tasks.push(Type)
          } else {
            ignore(state.expect(RAngle, "'>'"))
          }
        } else {
          ignore(state.expect(RAngle, "'>'"))
        }
      Expression => {
        state.begin(c => Expression(primary=c[0], postfix=rest(c, 1)))
        state.tasks.push(Finish)
        state.tasks.push(Postfix)
        state.tasks.push(Primary)
      }
      Primary => state.primary()
      Postfix => {
        let token = state.current()
        let first = state.raw()
        if state.eat(Dot) {
          let name = state.name()
          state.emit(Access(name~, quoted=false), token.span.start, first)
          state.tasks.push(Postfix)
        } else if state.eat(LBracket) {
          let name = state.current()
          let value = if name.kind == StringLiteral && name.text.length() >= 2 {
            name.text.unsafe_substring(start=1, end=name.text.length() - 1)
          } else {
            ""
          }
          ignore(state.expect(StringLiteral, "string export name"))
          ignore(state.expect(RBracket, "']'"))
          state.emit(Access(name=value, quoted=true), token.span.start, first)
          state.tasks.push(Postfix)
        }
      }
      Arguments(first) => state.arguments(first)
      Argument => state.argument()
      ExportTail => {
        let spread = state.eat(Ellipsis)
        let renamed = if !spread && state.eat_word("as") {
          state.external_name()
          true
        } else {
          false
        }
        state.set_make(c => {
          Export(
            expression=c[0],
            renamed=if renamed { c.get(1) } else { None },
            spread~,
          )
        })
        ignore(state.expect(Semicolon, "';'"))
      }
    }
  }
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
