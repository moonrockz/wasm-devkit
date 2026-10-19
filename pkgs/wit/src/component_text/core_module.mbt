///|
// The pinned core WAT parser recurses through flat control keywords, which
// parenthesis-depth checks cannot bound. Reject these before invoking it.
fn check_flat_core_module(
  items : Array[SExpr],
) -> Unit raise ComponentTextError {
  let work = items.copy()
  while work.pop() is Some(item) {
    match item {
      Atom("block" | "loop" | "if" | "try" | "try_table") =>
        raise Unsupported(
          "structured core instructions are outside the flat module profile",
        )
      List(children) =>
        for child in children {
          work.push(child)
        }
      _ => ()
    }
  }
}
