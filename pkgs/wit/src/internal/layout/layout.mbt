///|
priv struct Writer {
  out : StringBuilder
  width : Int32
  mut indent : Int32
  mut line_start : Bool
  mut pending_space : Bool
  mut pending_break : Bool
  mut content : Bool
}

///|
fn Writer::newline(self : Writer) -> Unit {
  self.pending_space = false
  self.pending_break = false
  if !self.line_start {
    self.out.write_string("\n")
    self.line_start = true
  }
}

///|
fn Writer::prepare(self : Writer) -> Unit {
  if self.pending_break {
    self.newline()
  }
}

///|
fn Writer::write(self : Writer, text : String) -> Unit {
  if self.line_start {
    for _ in 0..<(self.indent * self.width) {
      self.out.write_string(" ")
    }
  } else if self.pending_space {
    self.out.write_string(" ")
  }
  self.pending_space = false
  self.out.write_string(text)
  self.line_start = text.has_suffix("\n")
  self.content = true
}

///|
fn Writer::tight(self : Writer, text : String) -> Unit {
  self.pending_space = false
  self.write(text)
}

///|
priv struct Frame {
  closing : @scanner.TokenKind
  block : Bool
  selector : Bool
  mut content : Bool
}

///|
/// Assign only the tokens directly owned by each grammar node. Skipping child
/// ranges makes the complete pass linear even through deeply nested types.
fn owners(tree : @cst.Tree) -> Array[@ast.Kind] {
  let result : Array[@ast.Kind] = Array::make(tree.tokens.length(), File)
  for node in tree.nodes {
    let mut at = node.first_token
    for child in node.children {
      let range = tree.nodes[child]
      for i in at..<range.first_token {
        result[i] = node.kind
      }
      at = range.last_token
    }
    for i in at..<node.last_token {
      result[i] = node.kind
    }
  }
  result
}

///|
/// Preserve every non-whitespace token, including raw comments. Rendering is
/// iterative; source grammar ownership preserves whitespace-sensitive imports.
pub fn render(tree : @cst.Tree, indent_width : Int32) -> String? {
  guard indent_width >= 0 && indent_width <= 8 && tree.validate() else {
    return None
  }
  let owner = owners(tree)
  let writer : Writer = {
    out: StringBuilder(),
    width: indent_width,
    indent: 0,
    line_start: true,
    pending_space: false,
    pending_break: false,
    content: false,
  }
  let stack : Array[Frame] = []
  let mut original_break = false
  for i, token in tree.tokens {
    let kind = token.kind
    if kind == Whitespace {
      if i == 0 && token.text.has_prefix("\ufeff") {
        writer.out.write_string("\ufeff")
      }
      original_break = original_break || token.text.contains("\n")
      continue
    }
    if kind == Eof {
      break
    }
    if kind == LineComment || kind == BlockComment {
      if stack.last() is Some(frame) {
        frame.content = true
      }
      let standalone = writer.line_start || original_break
      if standalone {
        writer.newline()
      }
      // A trailing comment stays before a deferred declaration line break.
      writer.pending_space = !writer.line_start
      writer.write(token.text)
      if kind == LineComment {
        writer.newline()
      } else if standalone {
        writer.pending_break = true
      } else {
        writer.pending_space = true
      }
      original_break = false
      continue
    }
    original_break = false
    let closing = kind == RBrace || kind == RParen || kind == RAngle
    if closing {
      guard stack.pop() is Some(frame) && frame.closing == kind else {
        return None
      }
      if frame.block {
        writer.indent -= 1
        if frame.content {
          writer.pending_break = true
        } else {
          writer.pending_break = false
        }
      }
      writer.prepare()
      if kind == RBrace && !frame.block && !frame.selector && frame.content {
        writer.pending_space = !writer.line_start
        writer.write(token.text)
      } else {
        writer.tight(token.text)
      }
      if frame.block || (kind == RBrace && !frame.selector) {
        writer.pending_break = true
      }
      if kind == RParen && owner[i] == Attribute {
        writer.pending_break = true
      }
      continue
    }
    if stack.last() is Some(frame) {
      frame.content = true
    }
    // Include renames can be followed by an optional semicolon.
    if kind == Semicolon {
      writer.pending_break = false
    } else {
      writer.prepare()
    }
    match kind {
      LBrace => {
        let selector = owner[i] == Use
        let block = owner[i] != Use && owner[i] != Include
        if selector {
          writer.tight("{")
        } else {
          writer.pending_space = !writer.line_start
          writer.write("{")
        }
        stack.push({ closing: RBrace, block, selector, content: false, })
        if block {
          writer.indent += 1
          writer.pending_break = true
        } else if !selector {
          writer.pending_space = true
        }
      }
      LParen | LAngle => {
        writer.tight(token.text)
        stack.push({
          closing: if kind == LParen {
            RParen
          } else {
            RAngle
          },
          block: false,
          selector: false,
          content: false,
        })
      }
      Semicolon => {
        writer.tight(";")
        writer.pending_break = true
      }
      Comma => {
        writer.tight(",")
        if stack.last() is Some(frame) && frame.block {
          writer.pending_break = true
        } else {
          writer.pending_space = true
        }
      }
      Colon => {
        writer.tight(":")
        if owner[i] != Path {
          writer.pending_space = true
        }
      }
      Dot | Slash | At => writer.tight(token.text)
      Equal | Arrow => {
        writer.pending_space = !writer.line_start
        writer.write(token.text)
        writer.pending_space = true
      }
      _ => {
        writer.write(token.text)
        writer.pending_space = true
      }
    }
  }
  guard stack.is_empty() else { return None }
  if writer.content {
    writer.newline()
  }
  Some(writer.out.to_string())
}
