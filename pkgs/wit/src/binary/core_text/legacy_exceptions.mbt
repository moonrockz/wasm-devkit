///|
// Called immediately after the `try` keyword. Public WAT framing bounds nesting.
fn Parser::parse_legacy_try(
  self : Parser,
  folded : Bool,
) -> @types.Instruction raise WatError {
  let label = match self.current.token {
    Id(name) => {
      self.advance()
      Some(name)
    }
    _ => None
  }
  let bt = self.parse_block_type()
  self.push_label(label)
  let body = if folded {
    self.expect_lparen()
    self.expect_keyword("do")
    let body = self.parse_instructions()
    self.expect_rparen()
    body
  } else {
    self.parse_instructions()
  }
  let catches : Array[@types.LegacyCatch] = []
  let mut delegate = None
  let mut popped = false
  while true {
    if folded {
      if self.current.token != LParen {
        break
      }
      self.advance()
    }
    match self.current.token {
      Keyword("catch") | Keyword("catch_all") as token => {
        if catches.last() is Some(last) && last.tag is None {
          raise ParseError("catch follows catch_all", self.loc())
        }
        self.advance()
        let tag = if token == Keyword("catch") {
          Some(self.parse_tag_idx())
        } else {
          None
        }
        let body = self.parse_instructions()
        if folded {
          self.expect_rparen()
        }
        catches.push({ tag, body, })
      }
      Keyword("delegate") => {
        if !catches.is_empty() {
          raise ParseError("delegate follows catch", self.loc())
        }
        self.advance()
        self.pop_label()
        popped = true
        delegate = Some(self.parse_label_idx())
        if folded {
          self.expect_rparen()
        }
        break
      }
      _ => {
        if folded {
          raise UnexpectedToken("expected legacy catch or delegate", self.loc())
        }
        break
      }
    }
  }
  if !popped {
    self.pop_label()
  }
  if folded {
    self.expect_rparen()
  } else if delegate is None {
    self.expect_keyword("end")
    self.skip_optional_id()
  }
  LegacyTry(bt, body, catches, delegate)
}
