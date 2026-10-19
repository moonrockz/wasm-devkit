///|
// Original WAT validated with wasm-tools 1.262.0 and wit-parser 0.262.0.
test "WAT customs producers escapes quoted names and binary forms match the pinned loader" {
  for
    (name, text, expected) in [
      (
        "custom", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"extra\" \"hello\"))",
        true,
      ),
      (
        "empty-custom", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"extra\"))",
        true,
      ),
      (
        "multi-string", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"extra\" \"a\" \"b\" \"\\00\\ff\"))",
        true,
      ),
      (
        "metadata", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"package-docs\" \"\\01{\\\"docs\\\":\\\"hello\\\"}\"))",
        true,
      ),
      (
        "producers", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@producers (processed-by \"tool\" \"1.0\") (language \"WIT\" \"1\") (sdk \"x\" \"2\") (processed-by \"tool\" \"3\")))",
        true,
      ),
      (
        "empty-producers", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@producers))",
        true,
      ),
      (
        "unicode", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"\\u{1f600}\" \"😀\\u{0_f_3}\\u{0__0}\\'\\t\\r\\n\\00\"))",
        true,
      ),
      (
        "escaped-bidi", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"other\" \"\\u{202e}\"))",
        true,
      ),
      (
        "quoted-annotation", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@\"custom\" \"x\" \"data\"))",
        true,
      ),
      (
        "comments", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(; outer (; nested ;) ;) (@custom ;; line\r \"x\" (;ignored;) \"data\"))",
        true,
      ),
      (
        "bad-custom-name-utf8", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"\\ff\" \"data\"))",
        false,
      ),
      (
        "bad-producer-utf8", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@producers (processed-by \"\\ff\" \"1\")))",
        false,
      ),
      (
        "bad-producer-field", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@producers (tool \"name\" \"1\")))",
        false,
      ),
      (
        "bad-producer-arity", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@producers (sdk \"name\")))",
        false,
      ),
      (
        "bad-custom-value", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" 1))",
        false,
      ),
      (
        "bad-placement", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" (after last) \"data\"))",
        false,
      ),
      (
        "bad-escape", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\\q\"))",
        false,
      ),
      (
        "bad-byte-escape", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\\fg\"))",
        false,
      ),
      (
        "bad-unicode-surrogate", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\\u{d800}\"))",
        false,
      ),
      (
        "bad-unicode-range", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\\u{110000}\"))",
        false,
      ),
      (
        "bad-unicode-trailing-underscore", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\\u{f_}\"))",
        false,
      ),
      (
        "bad-unicode-leading-underscore", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\\u{_f}\"))",
        false,
      ),
      (
        "bad-literal-control", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\n\"))",
        false,
      ),
      (
        "bad-literal-bidi", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\" \"\u{202e}\"))",
        false,
      ),
      (
        "bad-comment-bidi", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(; \u{202e} ;) (@custom \"x\"))",
        false,
      ),
      (
        "adjacent-string", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"x\"\"y\"))",
        false,
      ),
      (
        "adjacent-atom", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom\"x\" \"y\"))",
        false,
      ),
      (
        "quoted-identifiers", "(component $\"name with spaces\" (type $\"wrapper type\" (component (type $\"api type\" (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type $\"api type\"))))) (export \"api\" (type $\"wrapper type\")))",
        true,
      ),
      (
        "binary-form", "(component binary \"\\00\\61\\73\\6d\\0d\\00\\01\\00\\07\\4b\\01\\41\\02\\01\\42\\06\\01\\79\\04\\00\\02\\69\\64\\03\\00\\00\\01\\72\\01\\02\\69\\64\\01\\04\\00\\04\\69\\74\\65\\6d\\03\\00\\02\\01\\40\\01\\01\\78\\03\\00\\73\\04\\00\\03\\72\\75\\6e\\01\\04\\04\\00\\15\\65\\78\\61\\6d\\70\\6c\\65\\3a\\64\\65\\70\\2f\\61\\70\\69\\40\\31\\2e\\30\\2e\\30\\05\\00\\0b\\09\\01\\00\\03\\61\\70\\69\\03\\00\\00\\07\\b0\\01\\01\\41\\02\\01\\41\\04\\01\\42\\06\\01\\79\\04\\00\\02\\69\\64\\03\\00\\00\\01\\72\\01\\02\\69\\64\\01\\04\\00\\04\\69\\74\\65\\6d\\03\\00\\02\\01\\40\\01\\01\\78\\03\\00\\73\\04\\00\\03\\72\\75\\6e\\01\\04\\03\\00\\15\\65\\78\\61\\6d\\70\\6c\\65\\3a\\64\\65\\70\\2f\\61\\70\\69\\40\\31\\2e\\30\\2e\\30\\05\\00\\01\\42\\06\\01\\79\\04\\00\\02\\69\\64\\03\\00\\00\\01\\72\\01\\02\\69\\64\\01\\04\\00\\04\\69\\74\\65\\6d\\03\\00\\02\\01\\40\\01\\01\\78\\03\\00\\73\\04\\00\\03\\72\\75\\6e\\01\\04\\04\\00\\15\\65\\78\\61\\6d\\70\\6c\\65\\3a\\64\\65\\70\\2f\\61\\70\\69\\40\\31\\2e\\30\\2e\\30\\05\\01\\04\\00\\15\\65\\78\\61\\6d\\70\\6c\\65\\3a\\64\\65\\70\\2f\\61\\70\\70\\40\\31\\2e\\30\\2e\\30\\04\\00\\0b\\09\\01\\00\\03\\61\\70\\70\\03\\02\\00\\00\\10\\0c\\70\\61\\63\\6b\\61\\67\\65\\2d\\64\\6f\\63\\73\\01\\7b\\7d\\00\\2f\\09\\70\\72\\6f\\64\\75\\63\\65\\72\\73\\01\\0c\\70\\72\\6f\\63\\65\\73\\73\\65\\64\\2d\\62\\79\\01\\0d\\77\\69\\74\\2d\\63\\6f\\6d\\70\\6f\\6e\\65\\6e\\74\\07\\30\\2e\\32\\36\\32\\2e\\30\")",
        true,
      ),
    ] {
    let decoded = @verifier.decode_wat_package(text, source_id=name + ".wat")
    assert_eq(decoded is Ok(_), expected, msg=name)
    match decoded {
      Ok(input) => {
        let model = @verifier.resolve_packages(Encoded(input)).unwrap()
        assert_eq(model.root().key(), "example:dep@1.0.0", msg=name)
        assert_eq(model.sources().length(), 0)
        assert_true(
          model.types().all(ty => ty.location.position == BinaryOffset(None)),
        )
      }
      Err(errors) =>
        assert_true(
          errors.all(error => {
            error.primary.location.position == BinaryOffset(None)
          }),
        )
    }
  }
}

///|
test "WAT custom bytes and producer groups retain exact payloads" {
  let input = @verifier.decode_wat_package(
    "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0))(@custom \"extra\" \"a\" \"b\" \"\\00\\ff\") (@producers (processed-by \"tool\" \"1\") (language \"WIT\" \"\") (processed-by \"tool\" \"2\")))",
  ).unwrap()
  let expected = b"\x00\x0a\x05\x65\x78\x74\x72\x61\x61\x62\x00\xff\x00\x36\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x02\x08\x6c\x61\x6e\x67\x75\x61\x67\x65\x01\x03\x57\x49\x54\x00\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x02\x04\x74\x6f\x6f\x6c\x01\x31\x04\x74\x6f\x6f\x6c\x01\x32"
  let bytes = input.bytes()
  assert_eq(bytes[bytes.length() - expected.length():].to_owned(), expected)
}
