///|
fn corpus_input(
  input : @verifier.PackageInput,
  formatted : Bool,
) -> @verifier.PackageInput raise {
  match input {
    Encoded(_) => input
    Source(source) => {
      let documents = []
      for index = source.documents.length() - 1; index >= 0; index = index - 1 {
        let document = source.documents[index]
        if formatted {
          let text = @formatter.format(
            document.text,
            features=@parser.Features::reference(),
          ).unwrap()
          assert_eq(
            @formatter.format(text, features=@parser.Features::reference()).unwrap(),
            text,
          )
          documents.push(section_document(document.id, text))
        } else {
          documents.push(document)
        }
      }
      Source({ documents: ReadOnlyArray::from_array(documents), })
    }
  }
}

///|
// The upstream groups contain independent package inputs. Their dependency
// ordering may change; first-input precedence for overlapping mixed providers
// is intentionally exercised by separate tests and must not be reordered.
fn corpus_resolve(
  root : @verifier.PackageInput,
  dependencies~ : ReadOnlyArray[@verifier.PackageInput] = [],
  semantic_features~ : @verifier.SemanticFeatures,
) -> Result[@verifier.Resolution, ReadOnlyArray[@verifier.Diagnostic]] raise {
  let result = @verifier.resolve_packages(
    root,
    dependencies~,
    semantic_features~,
  )
  let repeated = @verifier.resolve_packages(
    root,
    dependencies~,
    semantic_features~,
  )
  match result {
    Err(errors) => {
      assert_eq(repeated.unwrap_err(), errors)
      result
    }
    Ok(model) => {
      let expected = model_projection(model)
      assert_eq(model_projection(repeated.unwrap()), expected)
      for formatted in [false, true] {
        let reordered = []
        for index = dependencies.length() - 1; index >= 0; index = index - 1 {
          reordered.push(corpus_input(dependencies[index], formatted))
        }
        let changed = @verifier.resolve_packages(
          corpus_input(root, formatted),
          dependencies=ReadOnlyArray::from_array(reordered),
          semantic_features~,
        ).unwrap()
        assert_eq(model_projection(changed), expected)
        assert_eq(model_projection(model), expected)
      }
      result
    }
  }
}
