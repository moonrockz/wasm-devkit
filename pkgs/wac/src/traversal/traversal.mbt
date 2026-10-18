///|
pub(all) enum Syntax {
  Ast(@ast.Tree)
  Cst(@cst.Tree)
}

///|
pub(all) enum Phase {
  Enter
  Leave
} derive(Eq, Debug)

///|
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
pub(all) struct Event {
  phase : Phase
  view : View
} derive(Eq, Debug)

///|
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
pub fn Reader::new(
  syntax : Syntax,
  decide~ : (Event) -> Control = default_decision,
) -> Reader? {
  guard Navigation::new(syntax) is Some(navigation) else { return None }
  Some(reader(navigation, navigation.children.length() - 1, decide))
}

///|
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
pub fn Reader::iter(self : Reader) -> Iter[Event] {
  Iter::new(fn() { self.next() })
}

///|
pub fn Reader::report(self : Reader) -> Report {
  { events: self.count, stopped: self.stopped, }
}

///|
pub fn events(
  syntax : Syntax,
  decide~ : (Event) -> Control = default_decision,
) -> ReadOnlyArray[Event]? {
  guard Reader::new(syntax, decide~) is Some(reader) else { return None }
  Some(ReadOnlyArray::from_iter(reader.iter()))
}

///|
pub fn walk(syntax : Syntax, visit : (Event) -> Control) -> Report? {
  guard Reader::new(syntax, decide=visit) is Some(reader) else { return None }
  while reader.next() is Some(_) {
    ()
  }
  Some(reader.report())
}

///|
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
pub(all) struct Reduction[A] {
  value : A?
  report : Report
}

///|
/// Bottom-up reduction. A pruned node receives no child summaries. An early stop
/// can leave no complete root summary; value is None in that case.
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
pub fn Cursor::root(syntax : Syntax) -> Cursor? {
  guard Navigation::new(syntax) is Some(navigation) else { return None }
  Some({ navigation, index: navigation.children.length() - 1, })
}

///|
pub fn Cursor::view(self : Cursor) -> View {
  self.navigation.view(self.index)
}

///|
pub fn Cursor::child(self : Cursor, slot : Int32) -> Cursor? {
  self.navigation.children[self.index]
  .get(slot)
  .map(index => { navigation: self.navigation, index, })
}

///|
pub fn Cursor::parent(self : Cursor) -> Cursor? {
  let index = self.navigation.parents[self.index]
  if index < 0 {
    None
  } else {
    Some({ navigation: self.navigation, index, })
  }
}

///|
pub fn Cursor::next_sibling(self : Cursor) -> Cursor? {
  guard self.parent() is Some(parent) else { return None }
  parent.child(self.navigation.slots[self.index] + 1)
}

///|
pub fn Cursor::previous_sibling(self : Cursor) -> Cursor? {
  guard self.parent() is Some(parent) else { return None }
  parent.child(self.navigation.slots[self.index] - 1)
}

///|
pub fn Cursor::reader(
  self : Cursor,
  decide~ : (Event) -> Control = default_decision,
) -> Reader {
  reader(self.navigation, self.index, decide)
}

///|
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
pub fn Cursor::ast_node(self : Cursor) -> @ast.Node? {
  match self.navigation.syntax {
    Ast(tree) => tree.nodes.get(self.index)
    Cst(_) => None
  }
}

///|
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
