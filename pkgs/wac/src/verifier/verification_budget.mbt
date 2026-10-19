///|
priv struct VerificationBudget {
  mut remaining : Int32
}

///|
fn Check::verification_step(
  self : Check,
  budget : VerificationBudget,
  node : Int32,
) -> Unit raise SemanticFailure {
  budget.remaining -= 1
  if budget.remaining < 0 {
    raise Problem(
      self.problem(
        node, "WAC-C006", "semantic graph exceeds the verification work limit",
      ),
    )
  }
}
