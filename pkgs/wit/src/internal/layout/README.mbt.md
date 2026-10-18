# Internal WIT layout

This package renders concrete WIT tokens for the AST printer and source formatter.
It belongs to the WIT implementation and is not a shared syntax abstraction for WAC.

The ownership pass assigns only direct tokens to each grammar node, skipping child ranges.
A token is therefore classified once, even in a deeply nested tree. Path ownership keeps
namespace colons tight; plain import labels retain a following space. Block ownership
separates declaration/aggregate braces from inline selector and include-rename braces.

A private delimiter stack controls indentation and member line breaks. A private writer
defers breaks until it can retain trailing comments beside their preceding token. Raw comment
contents are emitted verbatim. Public printer/formatter operations validate the resulting
syntax and structure; direct rendering only checks concrete arena structure and options.
