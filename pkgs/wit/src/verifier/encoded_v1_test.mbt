///|
test "encoded v1 identities members metadata and malformed wrappers" {
  for
    (name, text, accepted) in [
      (
        "simple", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"example:dep/wit@1.0.0\" (type 0)))",
        true,
      ),
      (
        "mismatch", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"other:pkg/api@2.0.0\" (instance (type 0))))) (export \"example:dep/wit@1.0.0\" (type 0)))",
        true,
      ),
      (
        "empty", "(component (type (component)) (export \"example:dep/wit@1.0.0\" (type 0)))",
        true,
      ),
      (
        "v2-renamed", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"other-name\" (type 0)))",
        true,
      ),
      (
        "world", "(component (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (export \"example:dep/api@1.0.0\" (instance (type 0))) (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (import \"example:dep/api@1.0.0\" (instance (type 0))) (type (func (result string))) (export \"run\" (func (type 1))))) (export \"example:dep/app@1.0.0\" (component (type 1))))) (export \"example:dep/wit@1.0.0\" (type 0)))",
        true,
      ),
      (
        "metadata", "(component (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (export \"example:dep/api@1.0.0\" (instance (type 0))) (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (import \"example:dep/api@1.0.0\" (instance (type 0))) (type (func (result string))) (export \"run\" (func (type 1))))) (export \"example:dep/app@1.0.0\" (component (type 1))))) (export \"example:dep/wit@1.0.0\" (type 0)) (@custom \"package-docs\" \"\\01{\\\"interfaces\\\":{\\\"api\\\":{\\\"funcs\\\":{\\\"run\\\":{\\\"stability\\\":{\\\"unstable\\\":{\\\"feature\\\":\\\"preview\\\"}}}}}}}\") (@producers (processed-by \"test\" \"1\")))",
        true,
      ),
      (
        "wrong-export", "(component (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (export \"example:dep/api@1.0.0\" (instance (type 0))) (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (import \"example:dep/api@1.0.0\" (instance (type 0))) (type (func (result string))) (export \"run\" (func (type 1))))) (export \"example:dep/app@1.0.0\" (component (type 1))))) (export \"example:dep/other@1.0.0\" (type 0)))",
        false,
      ),
      (
        "multiple-exports", "(component (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (export \"example:dep/api@1.0.0\" (instance (type 0))) (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (import \"example:dep/api@1.0.0\" (instance (type 0))) (type (func (result string))) (export \"run\" (func (type 1))))) (export \"example:dep/app@1.0.0\" (component (type 1))))) (export \"example:dep/wit@1.0.0\" (type 0)) (export \"extra\" (type 0)))",
        false,
      ),
      (
        "v2-duplicate", "(component (type (component (type (instance (export \"r\" (type (sub resource))))) (export \"example:dep/api@1.0.0\" (instance (type 0))))) (export \"first\" (type 0)) (export \"second\" (type 0)))",
        false,
      ),
    ] {
    let decoded = @verifier.decode_wat_package(text)
    assert_eq(decoded is Ok(_), accepted, msg=name)
    if decoded is Ok(input) {
      let model = @verifier.resolve_packages(Encoded(input)).unwrap()
      assert_eq(model.root().key(), "example:dep@1.0.0", msg=name)
      assert_eq(
        model.interfaces().length(),
        if name == "empty" {
          0
        } else {
          1
        },
        msg=name,
      )
      assert_eq(
        model.worlds().length(),
        if name == "world" || name == "metadata" {
          1
        } else {
          0
        },
        msg=name,
      )
      if name == "metadata" {
        assert_eq(model.interfaces()[0].functions.length(), 0)
      }
      if name == "world" {
        assert_eq(model.interfaces()[0].functions.length(), 1)
      }
      assert_eq(model.sources().length(), 0)
      assert_true(
        model.types().all(ty => ty.location.position == BinaryOffset(None)),
      )
    }
  }
}

///|
test "v1 WAT metadata matches binary feature selection and retained stability" {
  let text = "(component (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (export \"example:dep/api@1.0.0\" (instance (type 0))) (type (component (type (instance (type u32) (export \"id\" (type (eq 0))) (type (func (param \"x\" 1) (result string))) (export \"run\" (func (type 2))))) (import \"example:dep/api@1.0.0\" (instance (type 0))) (type (func (result string))) (export \"run\" (func (type 1))))) (export \"example:dep/app@1.0.0\" (component (type 1))))) (export \"example:dep/wit@1.0.0\" (type 0)) (@custom \"package-docs\" \"\\01{\\\"interfaces\\\":{\\\"api\\\":{\\\"funcs\\\":{\\\"run\\\":{\\\"stability\\\":{\\\"unstable\\\":{\\\"feature\\\":\\\"preview\\\"}}}}}}}\") (@producers (processed-by \"test\" \"1\")))"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x9b\x01\x01\x41\x04\x01\x42\x04\x01\x79\x04\x00\x02\x69\x64\x03\x00\x00\x01\x40\x01\x01\x78\x01\x00\x73\x04\x00\x03\x72\x75\x6e\x01\x02\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x41\x04\x01\x42\x04\x01\x79\x04\x00\x02\x69\x64\x03\x00\x00\x01\x40\x01\x01\x78\x01\x00\x73\x04\x00\x03\x72\x75\x6e\x01\x02\x03\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x40\x00\x00\x73\x04\x00\x03\x72\x75\x6e\x01\x01\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x01\x0b\x1b\x01\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x77\x69\x74\x40\x31\x2e\x30\x2e\x30\x03\x00\x00\x00\x67\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x22\x69\x6e\x74\x65\x72\x66\x61\x63\x65\x73\x22\x3a\x7b\x22\x61\x70\x69\x22\x3a\x7b\x22\x66\x75\x6e\x63\x73\x22\x3a\x7b\x22\x72\x75\x6e\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x70\x72\x65\x76\x69\x65\x77\x22\x7d\x7d\x7d\x7d\x7d\x7d\x7d\x00\x20\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x04\x74\x65\x73\x74\x01\x31"
  for
    features in [
      @verifier.SemanticFeatures::default(),
      @verifier.SemanticFeatures::all(),
    ] {
    let wat = @verifier.resolve_packages(
      Encoded(@verifier.decode_wat_package(text).unwrap()),
      semantic_features=features,
    ).unwrap()
    let binary = @verifier.resolve_packages(
      Encoded(@verifier.decode_package(bytes).unwrap()),
      semantic_features=features,
    ).unwrap()
    assert_eq(wat.world_summary(), binary.world_summary())
    assert_eq(
      wat.interfaces()[0].functions.length(),
      if features.all_enabled {
        1
      } else {
        0
      },
    )
    assert_eq(
      wat.interfaces()[0].functions.length(),
      binary.interfaces()[0].functions.length(),
    )
    if features.all_enabled {
      assert_eq(wat.functions()[0].stability, Unstable("preview", None))
      assert_eq(wat.functions()[0].stability, binary.functions()[0].stability)
    }
  }
}
