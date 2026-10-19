# Registry artifact metadata

This CLI support package validates immutable artifact and lockfile records and
computes SHA-256 cache keys/content digests on all four MoonBit targets. It has no
filesystem or network access. Keys retain the requested registry spelling,
package name and exact optional version, including build metadata. Lock entries
also retain the resolved registry, resolved version and content digest.

The verification adapter loads bytes and checks their digest before constructing
a WAC `PackageSource`. The normal semantic decoder remains responsible for
component validity. Registry identities come from lookup records, independently
of names embedded in package bytes. Pure WIT/WAC libraries do not depend on this
CLI package or the optional Warg process.
