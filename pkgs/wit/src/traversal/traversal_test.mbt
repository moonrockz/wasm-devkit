///|
fn sample() -> @parser.Parse {
  @parser.parse("interface api { f: func(p:u8)->string; type t=list<u8>; }")
}

///|
fn same_styles(
  syntax : @traversal.Syntax,
  decide : (@traversal.Event) -> @traversal.Control,
) -> Bool {
  guard @traversal.events(syntax, decide~) is Some(expected) else {
    return false
  }
  guard @traversal.Reader::new(syntax, decide~) is Some(reader) else {
    return false
  }
  guard ReadOnlyArray::from_iter(reader.iter()) == expected else {
    return false
  }
  let walked = []
  guard @traversal.walk(syntax, fn(event) {
      walked.push(event)
      decide(event)
    })
    is Some(report) else {
    return false
  }
  guard ReadOnlyArray::from_array(walked) == expected &&
    report == reader.report() else {
    return false
  }
  guard @traversal.fold(syntax, [], fn(acc : Array[@traversal.Event], event) {
      acc.push(event)
      (acc, decide(event))
    })
    is Some((folded, fold_report)) else {
    return false
  }
  guard ReadOnlyArray::from_array(folded) == expected && fold_report == report else {
    return false
  }
  let reduced_trace = []
  guard @traversal.reduce(
      syntax,
      fn(_view, children : ReadOnlyArray[Int32]) {
        1 + children.fold(init=0, fn(a, b) { a + b })
      },
      decide=fn(event) {
        reduced_trace.push(event)
        decide(event)
      },
    )
    is Some(reduced) else {
    return false
  }
  guard ReadOnlyArray::from_array(reduced_trace) == expected &&
    reduced.report == report else {
    return false
  }
  guard @traversal.Cursor::root(syntax) is Some(cursor) else { return false }
  ReadOnlyArray::from_iter(cursor.reader(decide~).iter()) == expected
}

///|
test "source field order has one enter and leave per node" {
  let parsed = sample()
  let stream = @traversal.events(Ast(parsed.ast)).unwrap()
  let trace = stream.map(e => (e.view.index, e.phase)).iter().to_array()
  let e = @traversal.Enter
  let l = @traversal.Leave
  assert_eq(trace, [
    (9, e),
    (8, e),
    (4, e),
    (3, e),
    (1, e),
    (0, e),
    (0, l),
    (1, l),
    (2, e),
    (2, l),
    (3, l),
    (4, l),
    (7, e),
    (6, e),
    (5, e),
    (5, l),
    (6, l),
    (7, l),
    (8, l),
    (9, l),
  ])
  assert_eq(stream[0].view.depth, 0)
  assert_eq(stream[0].view.parent, None)
  assert_eq(stream[5].view.depth, 5)
  assert_eq(stream[5].view.parent, Some(1))
  assert_eq(@traversal.events(Cst(parsed.cst)).unwrap(), stream)
  assert_true(same_styles(Ast(parsed.ast), _ => Continue))
  assert_true(same_styles(Cst(parsed.cst), _ => Continue))
}

///|
test "prune emits a leave and stop does not synthesize ancestor leaves" {
  let parsed = sample()
  let decide = fn(event : @traversal.Event) -> @traversal.Control {
    if event.phase == Enter && event.view.kind == Signature {
      Prune
    } else if event.phase == Leave && event.view.kind == Function {
      Stop
    } else {
      Continue
    }
  }
  let stream = @traversal.events(Ast(parsed.ast), decide~).unwrap()
  assert_eq(stream.map(e => (e.view.index, e.phase)).iter().to_array(), [
    (9, Enter),
    (8, Enter),
    (4, Enter),
    (3, Enter),
    (3, Leave),
    (4, Leave),
  ])
  assert_true(same_styles(Ast(parsed.ast), decide))
  assert_true(same_styles(Cst(parsed.cst), decide))
  let pruned_root = @traversal.events(Ast(parsed.ast), decide=e => {
    if e.phase == Enter {
      Prune
    } else {
      Continue
    }
  }).unwrap()
  assert_eq(pruned_root.length(), 2)
  let stopped_root = @traversal.events(Ast(parsed.ast), decide=_ => Stop).unwrap()
  assert_eq(stopped_root.length(), 1)
}

///|
test "cursors navigate without changing earlier positions" {
  let parsed = sample()
  let root = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
  let interface = root.child(0).unwrap()
  let function = interface.child(0).unwrap()
  let alias_node = function.next_sibling().unwrap()
  assert_eq(alias_node.view().kind, Alias)
  assert_eq(alias_node.previous_sibling().unwrap().view(), function.view())
  assert_eq(alias_node.parent().unwrap().view(), interface.view())
  assert_eq(root.view().kind, File)
  assert_true(root.parent() is None)
  assert_true(root.child(-1) is None)
  assert_true(root.child(1) is None)
  assert_true(alias_node.next_sibling() is None)
  assert_true(function.concrete_node() is None)
  assert_true(function.ast_node() is Some(_))
  let concrete = @traversal.Cursor::root(Cst(parsed.cst)).unwrap()
  assert_true(concrete.concrete_node() is Some(_))
  assert_true(concrete.ast_node() is None)
  let mut cursor = Some(root)
  let preorder = []
  while cursor is Some(at) {
    preorder.push(at.view().index)
    cursor = at.next_preorder()
  }
  let stream = @traversal.events(Ast(parsed.ast)).unwrap()
  assert_eq(
    preorder,
    stream
    .filter(e => e.phase == Enter)
    .map(e => e.view.index)
    .iter()
    .to_array(),
  )
}

///|
test "reduction summarizes complete and pruned trees and reports incomplete stops" {
  let parsed = sample()
  let sum = fn(_view, children : ReadOnlyArray[Int32]) {
    children.fold(init=1, fn(a, b) { a + b })
  }
  let reduced = @traversal.reduce(Ast(parsed.ast), sum).unwrap()
  assert_eq(reduced.value, Some(parsed.ast.nodes.length()))
  let pruned = @traversal.reduce(Ast(parsed.ast), sum, decide=e => {
    if e.phase == Enter && e.view.kind == Signature {
      Prune
    } else {
      Continue
    }
  }).unwrap()
  assert_eq(pruned.value, Some(7))
  let stopped = @traversal.reduce(Ast(parsed.ast), sum, decide=_ => Stop).unwrap()
  assert_eq(stopped.value, None)
  assert_true(stopped.report.stopped)
}

///|
test "immutable rewrites update children, prune, drop nodes and cancel stops" {
  let parsed = sample()
  let original = parsed.ast
  let changed = @traversal.rewrite(original, fn(_view, node) {
    match node.data {
      PrimitiveType(name="u8") => Replace(PrimitiveType(name="u64"))
      _ => Keep
    }
  }).unwrap()
  assert_true(changed.tree.validate())
  assert_true(original.nodes.any(n => n.data == PrimitiveType(name="u8")))
  assert_false(changed.tree.nodes.any(n => n.data == PrimitiveType(name="u8")))
  assert_eq(original, sample().ast)
  let identity = @traversal.rewrite(original, (_view, _node) => Keep).unwrap()
  assert_eq(identity.tree, original)
  let pruned = @traversal.rewrite(
    original,
    fn(_view, node) {
      match node.data {
        PrimitiveType(name="u8") => Replace(PrimitiveType(name="u64"))
        _ => Keep
      }
    },
    decide=e => {
      if e.phase == Enter && e.view.kind == Interface {
        Prune
      } else {
        Continue
      }
    },
  ).unwrap()
  assert_eq(pruned.tree, original)
  assert_eq(pruned.report.events, 4)
  let dropped = @traversal.rewrite(original, fn(view, _node) {
    if view.kind == File {
      Replace(File(items=[]))
    } else {
      Keep
    }
  }).unwrap()
  assert_eq(dropped.tree.nodes.length(), 1)
  assert_true(dropped.tree.validate())
  let stopped = @traversal.rewrite(
    original,
    fn(_view, node) {
      match node.data {
        PrimitiveType(name="u8") => Replace(PrimitiveType(name="u64"))
        _ => Keep
      }
    },
    decide=e => {
      if e.phase == Leave && e.view.kind == Alias {
        Stop
      } else {
        Continue
      }
    },
  ).unwrap()
  assert_true(stopped.report.stopped)
  assert_eq(stopped.tree, original)
}

///|
test "subtree replacements import immutable nodes and reanchor source spans" {
  let parsed = sample()
  let subtree : @ast.Tree = {
    nodes: [
      { data: PrimitiveType(name="bool"), span: { start: 100, end: 100, }, },
      { data: OptionType(payload=0), span: { start: 100, end: 101, }, },
    ],
  }
  let result = @traversal.rewrite(parsed.ast, fn(_view, node) {
    if node.data == PrimitiveType(name="u8") {
      Subtree(subtree)
    } else {
      Keep
    }
  }).unwrap()
  assert_true(result.tree.validate())
  assert_eq(result.tree.nodes.length(), parsed.ast.nodes.length() + 2)
  assert_eq(subtree.nodes[0].span.start, 100)
  assert_eq(
    result.tree.nodes.filter(n => n.data == PrimitiveType(name="bool")).length(),
    2,
  )
  for node in result.tree.nodes {
    for child in node.data.children() {
      assert_true(node.span.contains(result.tree.nodes[child].span))
    }
  }
  let bad = @traversal.rewrite(parsed.ast, (_view, _node) => {
    Replace(OptionType(payload=-1))
  })
  assert_true(bad is Err(InvalidReplacement(_)))
}

///|
test "concrete source edits preserve originals and return invalid syntax as data" {
  let source = "interface api { type t = u8; }"
  let parsed = @parser.parse(source)
  let primitive = parsed.ast.nodes
    .iter()
    .find_first(n => n.data == PrimitiveType(name="u8"))
    .unwrap()
  let result = @traversal.rewrite_cst(parsed.cst, [
    { span: primitive.span, text: "u64", },
  ]).unwrap()
  assert_true(result.is_valid())
  assert_eq(result.cst.to_source(), "interface api { type t = u64; }")
  assert_eq(parsed.cst.to_source(), source)
  let invalid = @traversal.rewrite_cst(parsed.cst, [
    { span: { start: source.length(), end: source.length(), }, text: " {", },
  ]).unwrap()
  assert_false(invalid.is_valid())
  assert_eq(invalid.cst.to_source(), source + " {")
  assert_true(invalid.ast.validate())
  let bad = @traversal.rewrite_cst(parsed.cst, [
    { span: { start: -1, end: 0, }, text: "", },
  ])
  assert_true(bad is Err(InvalidTextEdit(0)))
  let overlap = @traversal.rewrite_cst(parsed.cst, [
    { span: { start: 0, end: 2, }, text: "", },
    { span: { start: 1, end: 3, }, text: "", },
  ])
  assert_true(overlap is Err(InvalidTextEdit(1)))
}

///|
test "invalid arenas never reach visitors or unsafe navigation" {
  let tree : @ast.Tree = { nodes: [], }
  let mut calls = 0
  assert_true(
    @traversal.Reader::new(Ast(tree), decide=_ => {
      calls += 1
      Continue
    })
    is None,
  )
  assert_true(@traversal.Cursor::root(Ast(tree)) is None)
  assert_true(
    @traversal.rewrite(tree, (_view, _node) => Keep) is Err(InvalidTree),
  )
  assert_eq(calls, 0)
}

///|
test "law: every traversal style agrees for generated prune and stop policies" {
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let out = StringBuilder()
      out.write_string("interface property { type t = tuple<")
      for i, b in choices {
        if i > 0 {
          out.write_string(",")
        }
        out.write_string(
          if b.to_int() % 2 == 0 {
            "list<option<u8>>"
          } else {
            "result<u8,string>"
          },
        )
      }
      out.write_string(">; type after = u8; }")
      let parsed = @parser.parse(out.to_string())
      let modulus = choices.length() % 7 + 2
      let decide = fn(event : @traversal.Event) -> @traversal.Control {
        if event.view.index % modulus == 0 && event.phase == Enter {
          Prune
        } else if event.view.index % 11 == 1 && event.phase == Leave {
          Stop
        } else {
          Continue
        }
      }
      same_styles(Ast(parsed.ast), decide) &&
      same_styles(Cst(parsed.cst), decide)
    },
    count=400,
    max_size=64,
    seed=20261023,
  )
}

///|
test "deep readers cursors reductions rewrites and concrete reparsing use stacks" {
  let out = StringBuilder()
  out.write_string("interface deep { type t = ")
  for _ in 0..<16000 {
    out.write_string("option<")
  }
  out.write_string("u8")
  for _ in 0..<16000 {
    out.write_string(">")
  }
  out.write_string("; }")
  let source = out.to_string()
  let parsed = @parser.parse(source)
  assert_true(parsed.is_valid())
  let count = @traversal.fold(Ast(parsed.ast), 0, fn(n, _event) {
    (n + 1, Continue)
  }).unwrap()
  assert_eq(count.0, parsed.ast.nodes.length() * 2)
  let reduced = @traversal.reduce(Cst(parsed.cst), fn(
    _view,
    children : ReadOnlyArray[Int32],
  ) {
    children.fold(init=1, fn(a, b) { a + b })
  }).unwrap()
  assert_eq(reduced.value, Some(parsed.ast.nodes.length()))
  let mut cursor = @traversal.Cursor::root(Ast(parsed.ast)).unwrap()
  while cursor.child(0) is Some(child) {
    cursor = child
  }
  assert_eq(cursor.view().depth, 16003)
  while cursor.parent() is Some(parent) {
    cursor = parent
  }
  assert_eq(cursor.view().depth, 0)
  let rewrite = @traversal.rewrite(parsed.ast, (_view, _node) => Keep).unwrap()
  assert_eq(rewrite.tree, parsed.ast)
  let concrete = @traversal.rewrite_cst(parsed.cst, [
    {
      span: { start: source.length(), end: source.length(), },
      text: " //tail",
    },
  ]).unwrap()
  assert_true(concrete.is_valid())
  assert_eq(concrete.cst.to_source(), source + " //tail")
}

///|
test "child remapping covers the complete documented node table" {
  let source =
    #|package a:b;
    #|package a:c {}
    #|@since(version=1.0.0)
    #|interface i {
    #|  resource r { constructor(p:u8); f: static async func() -> u8; }
    #|  type a = tuple<list<u8>,option<u8>,result<u8,string>,own<r>,borrow<r>,future<u8>,stream<u8>,map<bool,u8>,r>;
    #|  record rec { f:u8 }
    #|  flags fl { a }
    #|  enum en { a }
    #|  variant va { a(u8) }
    #|  use x.{a as b};
    #|}
    #|world w { import a:b/x; export run:func(); include y; }
    #|?;
  let parsed = @parser.parse(source)
  assert_true(parsed.ast.validate())
  let kinds : Array[@ast.Kind] = []
  for node in parsed.ast.nodes {
    let data = node.data
    if !kinds.contains(data.kind()) {
      kinds.push(data.kind())
    }
    assert_eq(data.map_children(i => i), data)
    let changed = data.map_children(i => i + 100)
    assert_eq(changed.kind(), data.kind())
    assert_eq(changed.children(), data.children().map(i => i + 100))
  }
  assert_eq(kinds.length(), 35)
}

///|
test "equal-position source insertions retain order and UTF-16 edits retain malformed text" {
  let parsed = @parser.parse("interface i {}")
  let inserted = @traversal.rewrite_cst(parsed.cst, [
    { span: { start: 0, end: 0, }, text: "//first\n", },
    { span: { start: 0, end: 0, }, text: "//second\n", },
  ]).unwrap()
  assert_eq(inserted.cst.to_source(), "//first\n//second\ninterface i {}")
  let source = "//😀\ninterface i {}"
  let original = @parser.parse(source)
  let split = @traversal.rewrite_cst(original.cst, [
    { span: { start: 2, end: 3, }, text: "", },
  ]).unwrap()
  assert_false(split.is_valid())
  assert_true(split.diagnostics.any(d => d.code == "WIT-L008"))
  assert_eq(
    split.cst.to_source(),
    source.unsafe_substring(start=0, end=2) +
    source.unsafe_substring(start=3, end=source.length()),
  )
  assert_eq(original.cst.to_source(), source)
}

///|
test "law: identity and shape-changing rewrites preserve immutable originals" {
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let out = StringBuilder()
      out.write_string("interface a { type t = tuple<")
      for i, b in choices {
        if i > 0 {
          out.write_string(",")
        }
        out.write_string(
          if b.to_int() % 2 == 0 {
            "list<option<u8>>"
          } else {
            "result<u8,string>"
          },
        )
      }
      out.write_string(">; }")
      let source = out.to_string()
      let parsed = @parser.parse(source)
      guard @traversal.rewrite(parsed.ast, (_view, _node) => Keep)
        is Ok(identity) else {
        return false
      }
      guard identity.tree == parsed.ast else { return false }
      guard @traversal.rewrite(parsed.ast, fn(_view, node) {
          if node.data.kind() == ListType {
            Replace(PrimitiveType(name="u64"))
          } else {
            Keep
          }
        })
        is Ok(changed) else {
        return false
      }
      changed.tree.validate() &&
      changed.tree.nodes.length() <= parsed.ast.nodes.length() &&
      parsed.ast == @parser.parse(source).ast
    },
    count=400,
    max_size=64,
    seed=20261024,
  )
}

///|
test "rewrite decisions have the canonical event trace" {
  let parsed = sample()
  let trace = []
  let decide = fn(event : @traversal.Event) -> @traversal.Control {
    if event.phase == Enter && event.view.kind == Signature {
      Prune
    } else {
      Continue
    }
  }
  let _ = @traversal.rewrite(parsed.ast, (_view, _node) => Keep, decide=e => {
    trace.push(e)
    decide(e)
  }).unwrap()
  assert_eq(
    ReadOnlyArray::from_array(trace),
    @traversal.events(Ast(parsed.ast), decide~).unwrap(),
  )
}
