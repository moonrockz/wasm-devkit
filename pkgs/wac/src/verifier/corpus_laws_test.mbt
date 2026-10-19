///|
fn corpus_snapshot(model : @verifier.Verified) -> Array[String] raise {
  let result = composition_projection(model)
  result.append(composition_edges(model))
  result.append(implicit_import_projection(model))
  for item in model.composition_exports() {
    result.push(item.name)
    result.push(item.value.to_string())
  }
  result
}

///|
fn corpus_verify(
  source~ : String,
  source_id~ : String,
  dependencies~ : ReadOnlyArray[@verifier.PackageSource],
  wit_dependencies~ : ReadOnlyArray[@verifier.WitPackageSource],
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] raise {
  let parsed = @parser.parse(source)
  let result = @verifier.verify(
    parsed,
    source~,
    source_id~,
    dependencies~,
    wit_dependencies~,
  )
  let repeated = @verifier.verify(
    parsed,
    source~,
    source_id~,
    dependencies~,
    wit_dependencies~,
  )
  match result {
    Err(errors) => assert_eq(repeated.unwrap_err(), errors)
    Ok(model) => {
      let expected = corpus_snapshot(model)
      assert_eq(corpus_snapshot(repeated.unwrap()), expected)
      let binary = []
      let wit = []
      for i = dependencies.length() - 1; i >= 0; i = i - 1 {
        binary.push(dependencies[i])
      }
      for i = wit_dependencies.length() - 1; i >= 0; i = i - 1 {
        wit.push(wit_dependencies[i])
      }
      let formatted = @formatter.format(source).unwrap()
      assert_eq(@formatter.format(formatted).unwrap(), formatted)
      for text in [source, formatted] {
        let changed = @verifier.verify(
          @parser.parse(text),
          source=text,
          source_id~,
          dependencies=ReadOnlyArray::from_array(binary),
          wit_dependencies=ReadOnlyArray::from_array(wit),
        ).unwrap()
        assert_eq(corpus_snapshot(changed), expected)
        assert_eq(corpus_snapshot(model), expected)
      }
    }
  }
  result
}
