///|
// Component values are linear graph edges. Check after implicit imports have
// merged so sharing one imported value across instantiations is also detected.
fn Check::validate_value_uses(self : Check) -> Unit raise SemanticFailure {
  let uses : Map[Int32, Location] = Map([])
  fn consume(value : Int32, location : Location) -> Unit raise SemanticFailure {
    let item = self.composition_nodes[value]
    guard item.kind is Value(_) else { return }
    if uses.get(value) is Some(first) {
      let message = "component value cannot be used more than once"
      raise Problem({
        code: "WAC-C010",
        message,
        primary: { location, message, },
        related: [
          { location: first, message: "first use here", },
          { location: item.location, message: "value introduced here", },
        ],
      })
    }
    uses[value] = location
  }
  for item in self.composition_nodes {
    if item.operation is Instantiate(_, _, arguments) {
      for argument in arguments {
        consume(argument.value, argument.location)
      }
    }
  }
  for output in self.composition_outputs {
    consume(output.value, output.location)
  }
  for item in self.composition_nodes {
    if item.kind is Value(_) && !uses.contains(item.id) {
      let message = "component value must be used by an instantiation or export"
      raise Problem({
        code: "WAC-C010",
        message,
        primary: { location: item.location, message, },
        related: [],
      })
    }
  }
}
