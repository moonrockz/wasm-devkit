///|
priv enum BinaryProjectionWork {
  Text(String)
  Type(Int32)
  Item(@verifier.Extern)
  Resource(Int32)
  Context(Int32)
}

///|
fn project_context_graph(
  types : ReadOnlyArray[@verifier.ResolvedType],
  resource_identity : (Int32, Int32) -> Int32?,
  work : Array[BinaryProjectionWork],
) -> Array[String] raise {
  let output : Array[String] = []
  let resources : Map[Int32, Int32] = Map([])
  let mut steps = 0
  let mut context = -1
  while work.pop() is Some(current) {
    steps += 1
    assert_true(steps < 1000000)
    let next : Array[BinaryProjectionWork] = []
    match current {
      Context(value) => context = value
      Text(text) => output.push(text)
      Resource(id) => {
        let id = resource_identity(id, context).unwrap()
        let ordinal = match resources.get(id) {
          Some(ordinal) => ordinal
          None => {
            let ordinal = resources.length()
            resources[id] = ordinal
            ordinal
          }
        }
        output.push(ordinal.to_string())
      }
      Item(item) => {
        output.push(item.name)
        let (sort, id) = match item.kind {
          Type(id) => ("type", id)
          Function(id) => ("func", id)
          Instance(id) => ("instance", id)
          Component(id) => ("component", id)
          Module(id) => ("module", id)
          Value(id) => ("value", id)
        }
        output.push(sort)
        next.push(Type(id))
      }
      Type(id) => {
        guard id >= 0 && id < types.length() else { fail("dangling type") }
        let kind = types[id].kind
        match kind {
          Module(core) => output.push(core.to_repr().to_string())
          Alias(id) => next.push(Type(id))
          Scalar(name) => {
            output.push("scalar")
            output.push(name)
          }
          Resource(_) => {
            output.push("resource")
            next.push(Resource(id))
          }
          Own(id) => {
            output.push("own")
            next.push(Resource(id))
          }
          Borrow(id) => {
            output.push("borrow")
            next.push(Resource(id))
          }
          List(id) => {
            output.push("list")
            next.push(Type(id))
          }
          FixedList(id, size) => {
            output.push("fixed-list")
            output.push(size.to_string())
            next.push(Type(id))
          }
          Map(key, value) => {
            output.push("map")
            next.push(Type(key))
            next.push(Type(value))
          }
          Option(id) => {
            output.push("option")
            next.push(Type(id))
          }
          Tuple(ids) => {
            output.push("tuple")
            output.push(ids.length().to_string())
            for id in ids {
              next.push(Type(id))
            }
          }
          Result(ok, error) => {
            output.push("result")
            for value in [ok, error] {
              if value is Some(id) {
                next.push(Text("some"))
                next.push(Type(id))
              } else {
                next.push(Text("none"))
              }
            }
          }
          Future(value) | Stream(value) => {
            output.push(if kind is Future(_) { "future" } else { "stream" })
            if value is Some(id) {
              next.push(Text("some"))
              next.push(Type(id))
            } else {
              next.push(Text("none"))
            }
          }
          Record(fields) => {
            output.push("record")
            output.push(fields.length().to_string())
            for field in fields {
              next.push(Text(field.name))
              next.push(Type(field.ty))
            }
          }
          Enum(names) | Flags(names) => {
            output.push(if kind is Enum(_) { "enum" } else { "flags" })
            output.push(names.length().to_string())
            for name in names {
              output.push(name)
            }
          }
          Variant(cases) => {
            output.push("variant")
            output.push(cases.length().to_string())
            for case in cases {
              next.push(Text(case.name))
              if case.payload is Some(id) {
                next.push(Text("some"))
                next.push(Type(id))
              } else {
                next.push(Text("none"))
              }
            }
          }
          Function(params, result, is_async) => {
            output.push("function")
            output.push(is_async.to_string())
            output.push(params.length().to_string())
            for param in params {
              next.push(Text(param.name))
              next.push(Type(param.ty))
            }
            if result is Some(id) {
              next.push(Text("some"))
              next.push(Type(id))
            } else {
              next.push(Text("none"))
            }
          }
          Interface(identity, uses, exports)
          | World(identity, uses, _, exports) => {
            output.push(
              if kind is Interface(_, _, _) {
                "interface"
              } else {
                "world"
              },
            )
            output.push(identity.unwrap_or(""))
            output.push(uses.length().to_string())
            for used in uses {
              output.push(used.name)
              output.push(used.original_name)
              guard types[used.interface].kind is Interface(name, _, _) else {
                fail("invalid use owner")
              }
              output.push(name.unwrap_or(""))
            }
            if kind is World(_, _, imports, _) {
              next.push(Text(imports.length().to_string()))
              for item in imports {
                next.push(Item(item))
              }
            }
            next.push(Text(exports.length().to_string()))
            for item in exports {
              next.push(Item(item))
            }
          }
        }
      }
    }
    for i = next.length() - 1; i >= 0; i = i - 1 {
      work.push(next[i])
    }
  }
  output
}

///|
// Static arena roots describe reusable templates. Runtime composition contexts
// supply the nominal identities for each import and instantiated output.
fn source_runtime_projection(model : @verifier.Verified) -> Array[String] raise {
  let work : Array[BinaryProjectionWork] = []
  let nodes = model.composition()
  for i = model.exports().length() - 1; i >= 0; i = i - 1 {
    let item = model.exports()[i]
    let mut context = -1
    for output in model.composition_exports() {
      if output.name == item.name {
        context = output.value
        break
      }
    }
    work.push(Item(item))
    work.push(Context(context))
  }
  work.push(Text(model.exports().length().to_string()))
  for i = model.imports().length() - 1; i >= 0; i = i - 1 {
    let item = model.imports()[i]
    let mut context = -1
    for node in nodes {
      if node.operation == Import(item.name) {
        context = node.id
        break
      }
    }
    work.push(Item(item))
    work.push(Context(context))
  }
  work.push(Text(model.imports().length().to_string()))
  project_context_graph(
    model.types(),
    (id, context) => {
      guard model.resource_identity(id) is Some(root) else { return None }
      if context >= 0 && context < nodes.length() {
        for binding in nodes[context].resources {
          if binding.ty == root {
            return Some(binding.identity)
          }
        }
      }
      // Static-only definitions occupy a separate namespace from runtime IDs.
      Some(-root - 1)
    },
    work,
  )
}

///|
fn project_graph(
  types : ReadOnlyArray[@verifier.ResolvedType],
  resource_identity : (Int32) -> Int32?,
  work : Array[BinaryProjectionWork],
) -> Array[String] raise {
  project_context_graph(types, (id, _) => resource_identity(id), work)
}

///|
fn assert_split_contract(source : String) -> Unit raise {
  let bytes = binary(source)
  let original = match @verifier.decode_component_package(bytes) {
    Ok(model) => model
    Err(errors) => fail("original: " + errors[0].render())
  }
  let split = split_source(source)
  let dependencies : Array[@verifier.PackageSource] = []
  let sources : Array[@verifier.SourcePackage] = []
  for document in split.documents {
    match document.kind {
      Wat =>
        dependencies.push({
          name: document.package_name,
          version: None,
          source: document.path,
          bytes: binary(document.text),
        })
      Wac =>
        sources.push({
          name: document.package_name,
          version: None,
          source: document.path,
          text: document.text,
        })
    }
  }
  let models = @verifier.resolve_composition_packages(
    ReadOnlyArray::from_array(sources),
    dependencies=ReadOnlyArray::from_array(dependencies),
  ).unwrap()
  let mut root : @verifier.Verified? = None
  for model in models {
    if model.name == "split:root" {
      root = Some(model.model)
    }
  }
  let root = root.unwrap()
  guard original.types()[original.world()].kind is World(_, _, imports, exports) else {
    fail("world missing")
  }
  let work : Array[BinaryProjectionWork] = []
  for i = exports.length() - 1; i >= 0; i = i - 1 {
    work.push(Item(exports[i]))
  }
  work.push(Text(exports.length().to_string()))
  for i = imports.length() - 1; i >= 0; i = i - 1 {
    work.push(Item(imports[i]))
  }
  work.push(Text(imports.length().to_string()))
  assert_eq(
    source_runtime_projection(root),
    project_graph(original.types(), id => original.resource_identity(id), work),
  )
}

///|
test "split contracts preserve qualified instance identities and shared resources" {
  let source =
    #|(component
    #|  (type (instance
    #|    (export "r" (type (sub resource)))
    #|    (type (own 0))
    #|    (type (func (result 1)))
    #|    (export "make" (func (type 2)))))
    #|  (import "test:pkg/api" (instance (type 0)))
    #|  (alias export 0 "r" (type))
    #|  (type (borrow 1))
    #|  (type (func (param "x" 2)))
    #|  (import "consume" (func (type 3)))
    #|  (export "test:pkg/api" (instance 0))
    #|  (export "consume" (func 0)))
  assert_split_contract(source)
}

///|
test "escaping composite origins outside the verifier profile fail before splitting" {
  let source =
    #|(component
    #|  (type (instance
    #|    (export "r" (type (sub resource)))
    #|    (type (own 0))
    #|    (type (record (field "handle" 1)))
    #|    (export "item" (type (eq 2)))))
    #|  (import "test:pkg/api" (instance (type 0)))
    #|  (alias export 0 "item" (type))
    #|  (type (func (param "x" 1)))
    #|  (import "consume" (func (type 2)))
    #|  (export "test:pkg/api" (instance 0))
    #|  (export "consume" (func 0)))
  let bytes = binary(source)
  assert_true(@verifier.decode_component_package(bytes) is Err(_))
  assert_true(@decompiler.split(bytes) is Err(_))
}

///|
test "pure component outer aliases keep their concrete dependency and contract" {
  let source =
    #|(component
    #|  (component (core module))
    #|  (component
    #|    (alias outer 1 0 (component))
    #|    (instance (instantiate 0))
    #|    (export "inner" (instance 0)))
    #|  (instance (instantiate 1))
    #|  (export "outer" (instance 0)))
  assert_split_contract(source)
}

///|
test "a core leaf closes an outer value type before standalone compilation" {
  let source =
    #|(component
    #|  (type u32)
    #|  (component
    #|    (alias outer 1 0 (type))
    #|    (core module)
    #|    (export "scalar" (type 0)))
    #|  (instance (instantiate 0))
    #|  (export "out" (instance 0)))
  assert_split_contract(source)
}

///|
test "an imported component is invoked without adding a public import" {
  let source =
    #|(component
    #|  (type (component
    #|    (type (func))
    #|    (import "f" (func (type 0)))
    #|    (export "f" (func (type 0)))))
    #|  (import "c" (component (type 0)))
    #|  (type (func))
    #|  (import "f" (func (type 1)))
    #|  (instance (instantiate 0 (with "f" (func 0))))
    #|  (export "out" (instance 0)))
  assert_split_contract(source)
}

///|
test "concrete component exports retain their original world contract" {
  assert_split_contract(
    "(component (component (core module)) (export \"child\" (component 0)))",
  )
}

///|
test "outer imported component captures propagate through a pure composition" {
  let source =
    #|(component
    #|  (type (component))
    #|  (import "c" (component (type 0)))
    #|  (component
    #|    (alias outer 1 0 (component))
    #|    (instance (instantiate 0))
    #|    (export "out" (instance 0)))
    #|  (instance (instantiate 1))
    #|  (export "out" (instance 0)))
  assert_split_contract(source)
}

///|
test "instance export ascriptions preserve the restricted public shape" {
  let source =
    #|(component
    #|  (type (instance))
    #|  (component (core module))
    #|  (instance (instantiate 0))
    #|  (export "out" (instance 0) (instance (type 0))))
  assert_split_contract(source)
}

///|
test "outer imported resource aliases rejected by the verifier cannot produce documents" {
  let source =
    #|(component
    #|  (type (instance (export "r" (type (sub resource)))))
    #|  (import "api" (instance (type 0)))
    #|  (alias export 0 "r" (type))
    #|  (component
    #|    (alias outer 1 1 (type))
    #|    (core module)
    #|    (export "r" (type 0)))
    #|  (instance (instantiate 0))
    #|  (export "api" (instance 0))
    #|  (export "out" (instance 1)))
  let bytes = binary(source)
  assert_true(@verifier.decode_component_package(bytes) is Err(_))
  assert_true(@decompiler.split(bytes) is Err(_))
}

///|
test "ascriptions hide instance members while preserving the original import contract" {
  let source =
    #|(component
    #|  (type (func))
    #|  (type (instance))
    #|  (import "f" (func (type 0)))
    #|  (instance (export "f" (func 0)))
    #|  (export "out" (instance 0) (instance (type 1))))
  assert_split_contract(source)
}

///|
test "qualified imported component identities survive invocation adapters" {
  let source =
    #|(component
    #|  (type (component))
    #|  (import "test:pkg/worker" (component (type 0)))
    #|  (instance (instantiate 0))
    #|  (export "out" (instance 0)))
  assert_split_contract(source)
}

///|
test "qualified runtime instance export identities survive splitting" {
  let source =
    #|(component
    #|  (component (core module))
    #|  (instance (instantiate 0))
    #|  (export "test:pkg/result" (instance 0)))
  assert_split_contract(source)
}

///|
test "binary relay composition keeps complete ordered instantiation and access edges" {
  let source =
    #|(component
    #|  (type (func (param "x" u32) (result u32)))
    #|  (import "f" (func (type 0)))
    #|  (component
    #|    (type (func (param "x" u32) (result u32)))
    #|    (import "f" (func (type 0)))
    #|    (core module)
    #|    (export "f" (func 0)))
    #|  (instance (instantiate 0 (with "f" (func 0))))
    #|  (alias export 0 "f" (func))
    #|  (instance (instantiate 0 (with "f" (func 1))))
    #|  (alias export 1 "f" (func))
    #|  (export "run" (func 2)))
  assert_split_contract(source)
  let split = split_source(source)
  let sources : Array[@verifier.SourcePackage] = []
  let dependencies : Array[@verifier.PackageSource] = []
  let mut child_key = ""
  for document in split.documents {
    if document.kind == @decompiler.Wac {
      sources.push({
        name: document.package_name,
        version: None,
        source: document.path,
        text: document.text,
      })
    } else {
      dependencies.push({
        name: document.package_name,
        version: None,
        source: document.path,
        bytes: binary(document.text),
      })
      if document.id == split.inventory.entries[1].id {
        child_key = document.package_name
      }
    }
  }
  let models = @verifier.resolve_composition_packages(
    ReadOnlyArray::from_array(sources),
    dependencies=ReadOnlyArray::from_array(dependencies),
  ).unwrap()
  let model = models[0].model
  let nodes = model.composition()
  assert_eq(nodes.length(), 5)
  assert_eq(nodes[0].operation, @verifier.Import("f"))
  guard nodes[1].operation is Instantiate(first, None, first_args) else {
    fail("first instantiate missing")
  }
  assert_eq(first, child_key)
  assert_eq(first_args.length(), 1)
  assert_eq(first_args[0].name, "f")
  assert_eq(first_args[0].value, 0)
  assert_eq(nodes[2].operation, @verifier.Access(1, "f"))
  guard nodes[3].operation is Instantiate(second, None, second_args) else {
    fail("second instantiate missing")
  }
  assert_eq(second, child_key)
  assert_eq(second_args.length(), 1)
  assert_eq(second_args[0].name, "f")
  assert_eq(second_args[0].value, 2)
  assert_eq(nodes[4].operation, @verifier.Access(3, "f"))
  assert_eq(model.composition_exports().length(), 1)
  assert_eq(model.composition_exports()[0].name, "run")
  assert_eq(model.composition_exports()[0].value, 4)
}
