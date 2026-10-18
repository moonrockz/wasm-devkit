///|
/// Choose AST typed fields or CST grammar nodes. Parser-produced AST/CST node indices correspond one-to-one.
pub(all) enum Syntax {
  Ast(@ast.Tree)
  Cst(@cst.Tree)
}

///|
/// A complete visit enters a node, visits its children in field order, and leaves it.
pub(all) enum Phase {
  Enter
  Leave
} derive(Eq, Debug)

///|
/// Continue visits children; Prune on Enter skips them but emits Leave. Stop includes the current event
/// and ends the stream without synthetic ancestor leaves. Prune on Leave acts like Continue.
pub(all) enum Control {
  Continue
  Prune
  Stop
} derive(Eq, Debug)

///|
/// Immutable metadata for a source arena node. index and parent refer to that
/// arena, not a rewritten output arena. Depth is absolute, including for cursors.
pub(all) struct View {
  index : Int32
  kind : @ast.Kind
  span : @span.Span
  depth : Int32
  parent : Int32?
} derive(Eq, Debug)

///|
/// One immutable traversal event. Inspect `view.index` in the selected source arena to read typed node data.
pub(all) struct Event {
  phase : Phase
  view : View
} derive(Eq, Debug)

///|
/// A snapshot of emitted Enter/Leave events and whether a callback requested Stop.
pub(all) struct Report {
  events : Int32
  stopped : Bool
} derive(Eq, Debug)

///|
priv struct Navigation {
  syntax : Syntax
  children : ReadOnlyArray[ReadOnlyArray[Int32]]
  parents : ReadOnlyArray[Int32]
  slots : ReadOnlyArray[Int32]
  depths : ReadOnlyArray[Int32]
}

///|
fn Navigation::new(syntax : Syntax) -> Navigation? {
  let children = match syntax {
    Ast(tree) => {
      guard tree.validate() else { return None }
      tree.nodes.map(n => n.data.children())
    }
    Cst(tree) => {
      guard tree.validate() else { return None }
      tree.nodes.map(n => n.children)
    }
  }
  let parents = Array::make(children.length(), -1)
  let slots = Array::make(children.length(), -1)
  let depths = Array::make(children.length(), 0)
  for i, child_list in children {
    for slot, child in child_list {
      parents[child] = i
      slots[child] = slot
    }
  }
  let mut i = children.length() - 1
  while i >= 0 {
    for child in children[i] {
      depths[child] = depths[i] + 1
    }
    i -= 1
  }
  Some({
    syntax,
    children,
    parents: ReadOnlyArray::from_array(parents),
    slots: ReadOnlyArray::from_array(slots),
    depths: ReadOnlyArray::from_array(depths),
  })
}

///|
fn Navigation::view(self : Navigation, index : Int32) -> View {
  let (kind, span) = match self.syntax {
    Ast(tree) => {
      let node = tree.nodes[index]
      (node.data.kind(), node.span)
    }
    Cst(tree) => {
      let node = tree.nodes[index]
      (node.kind, node.span)
    }
  }
  {
    index,
    kind,
    span,
    depth: self.depths[index],
    parent: if self.parents[index] < 0 {
      None
    } else {
      Some(self.parents[index])
    },
  }
}

///|
fn default_decision(_ : Event) -> Control {
  Continue
}

///|
priv struct Work {
  index : Int32
  phase : Phase
}

///|
/// Mutable reader state is private; syntax and all public event values are immutable.
/// Stop includes the current event and emits no synthetic leaves. Prune on Enter
/// emits that node's Leave and skips descendants. Prune on Leave has no effect.
pub struct Reader {
  priv navigation : Navigation
  priv stack : Array[Work]
  priv decide : (Event) -> Control
  priv mut count : Int32
  priv mut stopped : Bool
  priv mut last_control : Control
}

///|
fn reader(
  navigation : Navigation,
  index : Int32,
  decide : (Event) -> Control,
) -> Reader {
  {
    navigation,
    stack: [{ index, phase: Enter, }],
    decide,
    count: 0,
    stopped: false,
    last_control: Continue,
  }
}

///|
/// Invalid hand-built trees return None before invoking the callback.
///
/// Pause a reader and then consume its remaining events.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "Reader::new: Pause a reader and then consume its remaining events" {
///   let parsed = @parser.parse("interface api { type byte = u8; }")
///   let reader = @traversal.Reader::new(Ast(parsed.ast)).unwrap()
///   let first = reader.next().unwrap()
///   assert_eq(first.phase, Enter)
///   assert_eq(reader.report().events, 1)
///   let remaining = reader.iter().to_array()
///   assert_eq(remaining.length() + 1, parsed.ast.nodes.length() * 2)
///   assert_eq(reader.next(), None)
///   assert_false(reader.report().stopped)
/// }
/// ```
pub fn Reader::new(
  syntax : Syntax,
  decide~ : (Event) -> Control = default_decision,
) -> Reader? {
  guard Navigation::new(syntax) is Some(navigation) else { return None }
  Some(reader(navigation, navigation.children.length() - 1, decide))
}

///|
/// Advance the same reader state used by `iter`. Return None after exhaustion or Stop.
/// See `Reader::new` for pausing and resuming a reader.
pub fn Reader::next(self : Reader) -> Event? {
  guard self.stack.pop() is Some(work) else { return None }
  let event : Event = {
    phase: work.phase,
    view: self.navigation.view(work.index),
  }
  self.count += 1
  let control = (self.decide)(event)
  self.last_control = control
  if control == Stop {
    self.stopped = true
    self.stack.clear()
  } else if work.phase == Enter {
    self.stack.push({ ..work, phase: Leave, })
    if control != Prune {
      for child in self.navigation.children[work.index].rev_iter() {
        self.stack.push({ index: child, phase: Enter, })
      }
    }
  }
  Some(event)
}

///|
/// Consume the remaining events without restarting. The iterator and `next` share reader state.
pub fn Reader::iter(self : Reader) -> Iter[Event] {
  Iter::new(fn() { self.next() })
}

///|
/// Read progress so far without advancing the reader. Counts include both Enter and Leave.
pub fn Reader::report(self : Reader) -> Report {
  { events: self.count, stopped: self.stopped, }
}

///|
///
/// Use the same source-order events for AST and CST.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "events: Use the same source-order events for AST and CST" {
///   let parsed = @parser.parse(
///     "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
///   )
///   let ast = @traversal.events(Ast(parsed.ast)).unwrap()
///   let cst = @traversal.events(Cst(parsed.cst)).unwrap()
///   assert_eq(ast, cst)
///   assert_eq(ast.length(), parsed.ast.nodes.length() * 2)
///   assert_eq(ast[0].phase, Enter)
///   assert_eq(ast[ast.length() - 1].phase, Leave)
/// }
/// ```
pub fn events(
  syntax : Syntax,
  decide~ : (Event) -> Control = default_decision,
) -> ReadOnlyArray[Event]? {
  guard Reader::new(syntax, decide~) is Some(reader) else { return None }
  Some(ReadOnlyArray::from_iter(reader.iter()))
}

///|
///
/// Stop a search and prune signatures.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "walk: Stop a search and prune signatures" {
///   let parsed = @parser.parse(
///     "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
///   )
///   let visited = []
///   let report = @traversal.walk(Ast(parsed.ast), event => {
///     if event.phase == Enter {
///       visited.push(event.view.kind)
///     }
///     if event.phase == Enter && event.view.kind == Signature {
///       Prune
///     } else if event.phase == Leave && event.view.kind == Function {
///       Stop
///     } else {
///       Continue
///     }
///   }).unwrap()
///   assert_true(report.stopped)
///   assert_true(visited.contains(Signature))
///   assert_false(visited.contains(Parameter))
///   // Stop includes its event and does not add leaves for open ancestors.
///   assert_true(report.events < parsed.ast.nodes.length() * 2)
/// }
/// ```
pub fn walk(syntax : Syntax, visit : (Event) -> Control) -> Report? {
  guard Reader::new(syntax, decide=visit) is Some(reader) else { return None }
  while reader.next() is Some(_) {
    ()
  }
  Some(reader.report())
}

///|
///
/// Count function declarations without double-counting leave events.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "fold: Count function declarations without double-counting leave events" {
///   let parsed = @parser.parse(
///     "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
///   )
///   let (count, report) = @traversal.fold(Ast(parsed.ast), 0, (count, event) => {
///     let increment = if event.phase == Enter && event.view.kind == Function {
///       1
///     } else {
///       0
///     }
///     (count + increment, Continue)
///   }).unwrap()
///   assert_eq(count, 2)
///   assert_eq(report.events, parsed.ast.nodes.length() * 2)
/// }
/// ```
pub fn[A] fold(
  syntax : Syntax,
  initial : A,
  step : (A, Event) -> (A, Control),
) -> (A, Report)? {
  let mut accumulator = initial
  guard Reader::new(syntax, decide=fn(event) {
      let (next, control) = step(accumulator, event)
      accumulator = next
      control
    })
    is Some(reader) else {
    return None
  }
  while reader.next() is Some(_) {
    ()
  }
  Some((accumulator, reader.report()))
}

///|
/// A completed root summary, or None if Stop prevented root completion, plus the traversal report.
pub(all) struct Reduction[A] {
  value : A?
  report : Report
}

///|
/// Bottom-up reduction. A pruned node receives no child summaries. An early stop
/// can leave no complete root summary; value is None in that case.
///
/// Summarize a subtree from its children upward.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "reduce: Summarize a subtree from its children upward" {
///   let parsed = @parser.parse("interface api { type byte = u8; }")
///   let reduced = @traversal.reduce(Cst(parsed.cst), (
///     _view,
///     children : ReadOnlyArray[Int32],
///   ) => children.fold(init=1, (total, child_count) => total + child_count)).unwrap()
///   assert_eq(reduced.value, Some(parsed.cst.nodes.length()))
///   let stopped = @traversal.reduce(
///     Ast(parsed.ast),
///     (_view, _children : ReadOnlyArray[Int32]) => 1,
///     decide=_event => Stop,
///   ).unwrap()
///   assert_eq(stopped.value, None)
///   assert_true(stopped.report.stopped)
/// }
/// ```
pub fn[A] reduce(
  syntax : Syntax,
  combine : (View, ReadOnlyArray[A]) -> A,
  decide~ : (Event) -> Control = default_decision,
) -> Reduction[A]? {
  guard Reader::new(syntax, decide~) is Some(reader) else { return None }
  let frames : Array[Array[A]] = []
  let mut value = None
  while reader.next() is Some(event) {
    match event.phase {
      Enter => frames.push([])
      Leave => {
        guard frames.pop() is Some(children) else { return None }
        let next = combine(event.view, ReadOnlyArray::from_array(children))
        if frames.last() is Some(parent) {
          parent.push(next)
        } else {
          value = Some(next)
        }
      }
    }
  }
  Some({ value, report: reader.report(), })
}

///|
/// Immutable cursor. Navigation tables are built once and shared by every cursor;
/// moving to a child, parent or sibling is constant time without copying a path.
pub struct Cursor {
  priv navigation : Navigation
  priv index : Int32
}

///|
///
/// Navigate siblings while keeping earlier cursor positions.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "Cursor::root: Navigate siblings while keeping earlier cursor positions" {
///   let parsed = @parser.parse(
///     "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
///   )
///   let root = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
///   let interface = root.child(0).unwrap()
///   let first = interface.child(0).unwrap()
///   let second = first.next_sibling().unwrap()
///   assert_eq(first.view().kind, Function)
///   assert_eq(second.previous_sibling().unwrap().view(), first.view())
///   assert_eq(second.parent().unwrap().view(), interface.view())
///   assert_eq(root.view().kind, File)
///   assert_true(root.parent() is None)
///   assert_true(first.ast_node() is Some(_))
///   assert_true(first.concrete_node() is None)
///   let concrete = @traversal.Cursor::root(Cst(parsed.cst)).unwrap()
///   assert_true(concrete.concrete_node() is Some(_))
///   assert_true(concrete.ast_node() is None)
/// }
/// ```
pub fn Cursor::root(syntax : Syntax) -> Cursor? {
  guard Navigation::new(syntax) is Some(navigation) else { return None }
  Some({ navigation, index: navigation.children.length() - 1, })
}

///|
/// Read absolute source-arena metadata at this position without moving the cursor.
pub fn Cursor::view(self : Cursor) -> View {
  self.navigation.view(self.index)
}

///|
/// Return a new cursor at a source-order child slot, or None outside the child list.
pub fn Cursor::child(self : Cursor, slot : Int32) -> Cursor? {
  self.navigation.children[self.index]
  .get(slot)
  .map(index => { navigation: self.navigation, index, })
}

///|
/// Return a new parent position. The root has no parent; the original cursor is unchanged.
pub fn Cursor::parent(self : Cursor) -> Cursor? {
  let index = self.navigation.parents[self.index]
  if index < 0 {
    None
  } else {
    Some({ navigation: self.navigation, index, })
  }
}

///|
/// Move to the following child of the same parent, or None at the last sibling/root.
pub fn Cursor::next_sibling(self : Cursor) -> Cursor? {
  guard self.parent() is Some(parent) else { return None }
  parent.child(self.navigation.slots[self.index] + 1)
}

///|
/// Move to the preceding child of the same parent, or None at the first sibling/root.
pub fn Cursor::previous_sibling(self : Cursor) -> Cursor? {
  guard self.parent() is Some(parent) else { return None }
  parent.child(self.navigation.slots[self.index] - 1)
}

///|
///
/// Read a cursor subtree with absolute depth metadata.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "Cursor::reader: Read a cursor subtree with absolute depth metadata" {
///   let parsed = @parser.parse(
///     "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
///   )
///   let root = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
///   let interface = root.child(0).unwrap()
///   let first = interface.child(0).unwrap()
///   let events = first.reader().iter().to_array()
///   assert_eq(events[0].view.index, first.view().index)
///   assert_eq(events[0].view.depth, 2)
///   assert_eq(events[0].view.parent, Some(interface.view().index))
///   assert_eq(
///     first.next_preorder(control=Prune).unwrap().view(),
///     first.next_sibling().unwrap().view(),
///   )
///   assert_true(first.next_preorder(control=Stop) is None)
/// }
/// ```
pub fn Cursor::reader(
  self : Cursor,
  decide~ : (Event) -> Control = default_decision,
) -> Reader {
  reader(self.navigation, self.index, decide)
}

///|
///
/// Read a cursor subtree with absolute depth metadata.
///
/// Example imports: `moonrockz/wit/parser` as `@parser`, `moonrockz/wit/traversal` as `@traversal`.
///
/// ```mbt check
/// test "Cursor::next_preorder: Read a cursor subtree with absolute depth metadata" {
///   let parsed = @parser.parse(
///     "interface api { f: func(value: u8) -> string; g: func(); type bytes = list<u8>; }",
///   )
///   let root = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
///   let interface = root.child(0).unwrap()
///   let first = interface.child(0).unwrap()
///   let events = first.reader().iter().to_array()
///   assert_eq(events[0].view.index, first.view().index)
///   assert_eq(events[0].view.depth, 2)
///   assert_eq(events[0].view.parent, Some(interface.view().index))
///   assert_eq(
///     first.next_preorder(control=Prune).unwrap().view(),
///     first.next_sibling().unwrap().view(),
///   )
///   assert_true(first.next_preorder(control=Stop) is None)
/// }
/// ```
pub fn Cursor::next_preorder(
  self : Cursor,
  control~ : Control = Continue,
) -> Cursor? {
  if control == Stop {
    return None
  }
  if control == Continue && self.child(0) is Some(child) {
    return Some(child)
  }
  let mut at = self
  while true {
    if at.next_sibling() is Some(sibling) {
      return Some(sibling)
    }
    if at.parent() is Some(parent) {
      at = parent
    } else {
      return None
    }
  } nobreak {
    None
  }
}

///|
/// Return typed node data for an AST cursor. A CST cursor returns None.
pub fn Cursor::ast_node(self : Cursor) -> @ast.Node? {
  match self.navigation.syntax {
    Ast(tree) => tree.nodes.get(self.index)
    Cst(_) => None
  }
}

///|
/// Return grammar/token-range data for a CST cursor. An AST cursor returns None.
pub fn Cursor::concrete_node(self : Cursor) -> @cst.Node? {
  match self.navigation.syntax {
    Cst(tree) => tree.nodes.get(self.index)
    Ast(_) => None
  }
}

///|
pub extend Phase with Eq::{equal, not_equal}

///|
pub extend Control with Eq::{equal, not_equal}

///|
pub extend View with Eq::{equal, not_equal}

///|
pub extend Event with Eq::{equal, not_equal}

///|
pub extend Report with Eq::{equal, not_equal}

///|
pub extend Phase with @debug.Debug::{to_repr}

///|
pub extend Control with @debug.Debug::{to_repr}

///|
pub extend View with @debug.Debug::{to_repr}

///|
pub extend Event with @debug.Debug::{to_repr}

///|
pub extend Report with @debug.Debug::{to_repr}
