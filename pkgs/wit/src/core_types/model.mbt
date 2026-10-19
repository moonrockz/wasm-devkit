///|
/// Core values used by module signatures. Reference heaps are abstract names;
/// concrete GC/type references are outside this codec's current boundary.
pub(all) enum Value {
  Scalar(String)
  Reference(Bool, String)
} derive(Eq, Debug)

///|
pub(all) struct Function {
  params : ReadOnlyArray[Value]
  results : ReadOnlyArray[Value]
} derive(Eq, Debug)

///|
pub(all) enum External {
  Func(Function)
  Table(Value, UInt64, UInt64?, Bool, Bool)
  Memory(UInt64, UInt64?, Bool, Bool, Int32?)
  Global(Value, Bool, Bool)
  Tag(Function)
} derive(Eq, Debug)

///|
pub(all) struct Import {
  module_name : String
  name : String
  kind : External
} derive(Eq, Debug)

///|
pub(all) struct Export {
  name : String
  kind : External
} derive(Eq, Debug)

///|
pub(all) struct Module {
  imports : ReadOnlyArray[Import]
  exports : ReadOnlyArray[Export]
} derive(Eq, Debug)

///|
pub(all) enum Definition {
  Function(Function)
  Module(Module)
} derive(Eq, Debug)

///|
pub(all) enum ErrorKind {
  Malformed
  Invalid
  Unsupported
} derive(Eq, Debug)

///|
pub(all) struct Diagnostic {
  offset : Int32
  kind : ErrorKind
  message : String
} derive(Eq, Debug)

///|
pub extend Value with Eq::{equal, not_equal}

///|
pub extend Value with @debug.Debug::{to_repr}

///|
pub extend Function with Eq::{equal, not_equal}

///|
pub extend Function with @debug.Debug::{to_repr}

///|
pub extend External with Eq::{equal, not_equal}

///|
pub extend External with @debug.Debug::{to_repr}

///|
pub extend Import with Eq::{equal, not_equal}

///|
pub extend Import with @debug.Debug::{to_repr}

///|
pub extend Export with Eq::{equal, not_equal}

///|
pub extend Export with @debug.Debug::{to_repr}

///|
pub extend Module with Eq::{equal, not_equal}

///|
pub extend Module with @debug.Debug::{to_repr}

///|
pub extend Definition with Eq::{equal, not_equal}

///|
pub extend Definition with @debug.Debug::{to_repr}

///|
pub extend ErrorKind with Eq::{equal, not_equal}

///|
pub extend ErrorKind with @debug.Debug::{to_repr}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Diagnostic with @debug.Debug::{to_repr}
