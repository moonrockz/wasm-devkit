///|
fn Parser::parse_global_type(self : Parser) -> @types.GlobalType raise WatError {
  if self.current.token != LParen {
    return {
      value_type: self.parse_value_type(),
      mutable: false,
      is_shared: false,
    }
  }
  self.advance()
  let shared = self.current.token == Keyword("shared")
  if shared {
    self.advance()
  }
  let (value_type, mutable) = if self.current.token == Keyword("mut") {
    self.advance()
    let value = self.parse_value_type()
    self.expect_rparen()
    return { value_type: value, mutable: true, is_shared: shared, }
  } else if shared && self.current.token == LParen {
    self.advance()
    if self.current.token == Keyword("mut") {
      self.advance()
      let value = self.parse_value_type()
      self.expect_rparen()
      (value, true)
    } else {
      guard self.parse_storage_type_after_lparen() is Val(value) else {
        raise ParseError("global requires a value type", self.loc())
      }
      (value, false)
    }
  } else if shared {
    (self.parse_value_type(), false)
  } else {
    guard self.parse_storage_type_after_lparen() is Val(value) else {
      raise ParseError("global requires a value type", self.loc())
    }
    return { value_type: value, mutable: false, is_shared: false, }
  }
  self.expect_rparen()
  { value_type, mutable, is_shared: shared, }
}
