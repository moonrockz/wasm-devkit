///|
/// Render the compatibility AST through the bounded explicit-stack printer.
pub fn render(mod_ : @types.Module) -> String raise @core_printer.WatPrintError {
  @core_printer.render(mod_)
}
