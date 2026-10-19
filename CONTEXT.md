# WIT and WAC tooling

The languages have separate syntax and semantic rules. These terms distinguish
their input artifacts from the evidence produced by verification.

## Language

**Source document**:
Original language text associated with a caller-supplied identity and available
syntax results. Its source positions count UTF-16 code units.

**Encoded WIT package**:
A WIT package carried by component type metadata in a supported binary or WAT
encoding. It need not have an original WIT source document.

**Component validation evidence**:
Evidence that a component's encoding and type semantics satisfy a stated profile.
It does not by itself establish a WIT package or an executable implementation.

**Verified model**:
Immutable semantic identities and relationships that satisfy a language's
verification rules for the selected profile and supplied dependency closure.

**Resolution**:
One root package and its verified dependency closure, with their provenance.
_Avoid_: File discovery, registry lookup

**WIT provenance**:
The original source or encoded provider associated with a semantic declaration.
Text positions and binary byte positions are distinct; either can be unavailable.
