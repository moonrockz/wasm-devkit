// Retained from Milky2018/wasm_component@0.16.0; local formatting changes.
// Modified by wasm-devkit: permit root component imports.

///|
/// Handle component import section (id 10).
fn validate_component_section_import(
  payload : Bytes,
  cfg : ComponentValidationConfig,
  _is_root : Bool,
  counts : Counts,
  type_table : Array[@component.TypeDef?],
  local_resource_types : Array[Bool],
  resource_ids : Array[Int32?],
  type_sizes : Array[Int32],
  type_depths : Array[Int32],
  component_sizes : Array[Int32],
  instance_sizes : Array[Int32],
  named_types : Map[Int32, Int32],
  import_named_types : Map[Int32, Int32],
  core_type_exports : Array[Map[String, Int32]?],
  core_type_module_imports : Array[Array[CoreModuleTypeImport]?],
  core_type_module_export_types : Array[Map[String, CoreExternType]?],
  core_module_exports : Array[Map[String, Int32]?],
  core_module_defs : Array[@types.Module?],
  core_module_export_types : Array[Map[String, CoreExternType]?],
  core_module_type_imports : Array[Array[CoreModuleTypeImport]?],
  component_import_sorts : Array[Map[String, @component.Sort]?],
  component_import_instance_sigs : Array[Map[String, InstanceSig]?],
  component_import_func_sigs : Array[Map[String, FuncSigShape]?],
  component_import_instance_resource_exports : Array[
    Map[String, Map[String, Int32]]?,
  ],
  component_import_core_module_exports : Array[Map[String, Map[String, Int32]]?],
  component_import_core_module_import_sigs : Array[
    Map[String, Map[String, CoreExternType]]?,
  ],
  component_import_type_bounds : Array[Map[String, @component.TypeBound]?],
  component_import_type_sigs : Array[Map[String, TypeSig]?],
  component_export_sorts : Array[Map[String, @component.Sort]?],
  component_export_instance_sigs : Array[Map[String, InstanceSig]?],
  component_export_instance_type_sigs : Array[
    Map[String, Map[String, TypeSig]]?,
  ],
  component_export_instance_func_sigs : Array[
    Map[String, Map[String, FuncSigShape]]?,
  ],
  component_export_type_sigs : Array[Map[String, TypeSig]?],
  component_export_func_sigs : Array[Map[String, FuncSigShape]?],
  instance_sigs : Array[InstanceSig?],
  interface_instance_idxs : Map[Int32, Int32],
  instance_export_type_idxs : Array[Array[Int32]?],
  instance_export_func_idxs : Array[Array[Int32]?],
  instance_export_type_map : Array[Map[String, ExportedTypeInfo]?],
  instance_export_type_sigs : Array[Map[String, TypeSig]?],
  instance_export_func_sigs : Array[Map[String, FuncSigShape]?],
  instance_nested_instance_type_sigs : Array[Map[String, Map[String, TypeSig]]?],
  instance_nested_instance_func_sigs : Array[
    Map[String, Map[String, FuncSigShape]]?,
  ],
  func_types : Array[@component.FuncType?],
  func_sig_shapes : Array[FuncSigShape?],
  seen_import_names : Map[String, String],
  import_resource_names : Map[String, Int32],
  my_import_sorts : Map[String, @component.Sort],
  my_import_instance_sigs : Map[String, InstanceSig],
  my_import_func_sigs : Map[String, FuncSigShape],
  my_import_instance_resource_exports : Map[String, Map[String, Int32]],
  my_import_type_bounds : Map[String, @component.TypeBound],
  my_import_type_sigs : Map[String, TypeSig],
  type_outers : Array[Array[@component.TypeDef?]],
  next_resource_id : Int32,
  imported_funcs : Int32,
) -> (Int32, Int32) raise ComponentValidationError {
  let mut next_resource_id = next_resource_id
  let mut imported_funcs = imported_funcs
  let (import_locals, remaining) = import_local_resources(
    local_resource_types,
    resource_ids,
    counts.metadata_remaining,
  )
  counts.metadata_remaining = remaining
  let imports = @component.parse_import_section(payload) catch {
    e => raise SectionParseError(10, "\{e}")
  }
  for i in imports {
    validate_import_name(i.name, cfg)
    validate_name_attributes(
      10,
      importname_to_bytes(i.name),
      i.attributes,
      sort_of_externdesc(i.desc),
      cfg,
    )
    if importname_to_string(i.name) is Some(name) {
      let key = if cfg.wit_names { wit_conflict_key(name) } else { name }
      match seen_import_names.get(key) {
        Some(prev) =>
          if prev == name {
            raise DuplicateImportName(name)
          } else {
            raise SectionParseError(
              10,
              "import name `\{name}` conflicts with previous name `\{prev}`",
            )
          }
        None => seen_import_names.set(key, name)
      }
    }
    if importname_to_string(i.name) is Some(name) {
      my_import_sorts.set(name, sort_of_externdesc(i.desc))
    }
    if importname_to_string(i.name) is Some(name) &&
      parse_bracket_resource_name(name) is Some(_) &&
      !(i.desc is FuncType(_)) {
      raise SectionParseError(10, "is not a func")
    }
    // Import type references must be in-bounds at the point they appear.
    validate_externdesc(i.desc, type_table, counts.core_type)
    match i.desc {
      Type(Eq(tyidx)) =>
        if local_resource_types.get(tyidx) is Some(true) {
          raise SectionParseError(10, "local resource type found in imports")
        }
      FuncType(tyidx) =>
        match type_table[tyidx] {
          Some(FuncType(_)) => ()
          Some(_) => raise CanonExpectedFuncType(tyidx)
          None => ()
        }
      ComponentType(tyidx) =>
        match type_table[tyidx] {
          Some(ComponentType(_)) => ()
          Some(_) => raise InvalidTypeIndex(tyidx)
          None => ()
        }
      InstanceType(tyidx) =>
        match type_table[tyidx] {
          Some(InstanceType(_)) => ()
          Some(InstanceTypeEmpty) => ()
          Some(_) => raise InvalidTypeIndex(tyidx)
          None => ()
        }
      _ => ()
    }
    if i.desc is Value(Type(value)) {
      if !valtype_valid_in_interface(
          value,
          type_table,
          resource_ids,
          import_named_types,
          Map([]),
        ) {
        raise SectionParseError(10, "value not valid to be used as import")
      }
      let signature = counts.value_signature(value, type_table, resource_ids)
      counts.values.push({ signature, used: false, })
    }
    if i.desc is FuncType(tyidx) {
      match type_table[tyidx] {
        Some(FuncType(ft)) => {
          let sig = funcsig_of_functype(ft, type_table, resource_ids)
          if importname_to_string(i.name) is Some(name) {
            validate_bracketed_func_name(
              10, name, ft, type_table, resource_ids, import_resource_names,
            )
          }
          if !functype_valid_in_interface(
              ft, type_table, resource_ids, import_named_types,
            ) {
            raise SectionParseError(10, "func not valid to be used as import")
          }
          func_types.push(Some(ft))
          func_sig_shapes.push(Some(sig))
          if importname_to_string(i.name) is Some(name) {
            my_import_func_sigs.set(name, sig)
          }
        }
        _ => {
          func_types.push(None)
          func_sig_shapes.push(None)
        }
      }
    }
    if i.desc is CoreModuleType(tyidx) {
      if tyidx >= 0 && tyidx < core_type_exports.length() {
        match core_type_exports[tyidx] {
          Some(map) => core_module_exports.push(Some(map))
          None => raise CoreTypeIndexNotModuleType(tyidx)
        }
      } else {
        core_module_exports.push(None)
      }
    }
    match i.desc {
      CoreModuleType(tyidx) => {
        core_module_defs.push(None)
        if tyidx >= 0 && tyidx < core_type_module_export_types.length() {
          core_module_export_types.push(core_type_module_export_types[tyidx])
        } else {
          core_module_export_types.push(None)
        }
        if tyidx >= 0 && tyidx < core_type_module_imports.length() {
          core_module_type_imports.push(core_type_module_imports[tyidx])
        } else {
          core_module_type_imports.push(None)
        }
      }
      InstanceType(tyidx) => {
        let mut type_map : Map[String, ExportedTypeInfo]? = None
        let mut type_sig_map : Map[String, TypeSig]? = None
        let mut resource_exports : Map[String, Int32]? = None
        let mut func_export_sigs : Map[String, FuncSigShape]? = None
        match type_table[tyidx] {
          Some(td) => {
            let sig = instancetype_sig_of_typedef(td, type_table, Map([]))
            instance_sigs.push(Some(sig))
            if importname_to_string(i.name) is Some(name) {
              my_import_instance_sigs.set(name, sig)
            }
            match td {
              InstanceType(decls) => {
                let local_types : Array[@component.TypeDef] = []
                let local_resource_ids : Array[Int32?] = []
                let local_origins : Map[Int32, Int32] = Map([])
                let out : Map[String, ExportedTypeInfo] = Map([])
                let type_sigs : Map[String, TypeSig] = Map([])
                let res : Map[String, Int32] = Map([])
                let fns : Map[String, FuncSigShape] = Map([])
                let mut any_types = false
                let mut any_fns = false
                let visiting : Map[Int32, Int32] = Map([])
                fn record_type_slot() -> Unit {
                  local_types.push(InstanceTypeEmpty)
                  local_resource_ids.push(None)
                }

                for d in decls {
                  match d {
                    Type(t) => {
                      local_types.push(t)
                      local_resource_ids.push(None)
                    }
                    AliasOuter(kind, count, index) =>
                      if kind == 0x03 {
                        let slot = local_types.length()
                        if count == 1 && type_table.get(index) is Some(Some(_)) {
                          record_type_slot()
                          local_origins[slot] = index
                        } else if count == 0 &&
                          local_types.get(index) is Some(td) {
                          local_types.push(td)
                          local_resource_ids.push(local_resource_ids[index])
                          if local_origins.get(index) is Some(origin) {
                            local_origins[slot] = origin
                          }
                        } else {
                          record_type_slot()
                        }
                      }
                    AliasInstanceExport(kind, _inst, _name) =>
                      if kind == 0x03 {
                        record_type_slot()
                      }
                    Export(name, _attributes, desc) =>
                      match desc {
                        Type(b) =>
                          match b {
                            SubResource => {
                              let rid = next_resource_id
                              next_resource_id += 1
                              local_types.push(
                                ResourceType(-1, 0x7f, None, HostDefined),
                              )
                              local_resource_ids.push(Some(rid))
                              out.set(name, Resource(rid))
                              type_sigs.set(name, Resource(rid))
                              res.set(name, rid)
                              any_types = true
                            }
                            Eq(idx) => {
                              let new_idx = local_types.length()
                              if idx >= 0 && idx < local_types.length() {
                                local_types.push(local_types[idx])
                                local_resource_ids.push(local_resource_ids[idx])
                                if local_origins.get(idx) is Some(origin) {
                                  local_origins[new_idx] = origin
                                }
                              } else {
                                record_type_slot()
                              }
                              let sig = type_sig_of_valtype_lg(
                                TypeIdx(new_idx),
                                local_types,
                                local_resource_ids,
                                type_table,
                                resource_ids,
                                visiting,
                              )
                              out.set(name, Opaque)
                              type_sigs.set(name, sig)
                              any_types = true
                            }
                          }
                        FuncType(ft_idx) => {
                          let sig = if local_origins.get(ft_idx) is Some(origin) &&
                            type_table.get(origin) is Some(Some(FuncType(ft))) {
                            Some(
                              funcsig_of_functype(ft, type_table, resource_ids),
                            )
                          } else if ft_idx >= 0 && ft_idx < local_types.length() {
                            match local_types[ft_idx] {
                              FuncType(ft) =>
                                Some(
                                  funcsig_of_functype_lg(
                                    ft,
                                    local_types,
                                    local_resource_ids,
                                    type_table,
                                    resource_ids,
                                    local_origins~,
                                    global_function=local_origins.contains(
                                      ft_idx,
                                    ),
                                  ),
                                )
                              _ => None
                            }
                          } else if ft_idx >= 0 && ft_idx < type_table.length() {
                            match type_table[ft_idx] {
                              Some(FuncType(ft)) =>
                                Some(
                                  funcsig_of_functype_lg(
                                    ft,
                                    [],
                                    [],
                                    type_table,
                                    resource_ids,
                                  ),
                                )
                              _ => None
                            }
                          } else {
                            None
                          }
                          match sig {
                            Some(s) => {
                              fns.set(name, s)
                              any_fns = true
                            }
                            None => ()
                          }
                        }
                        _ => ()
                      }
                    _ => ()
                  }
                }
                if any_types {
                  type_map = Some(out)
                  type_sig_map = Some(type_sigs)
                  resource_exports = Some(res)
                }
                if any_fns {
                  func_export_sigs = Some(fns)
                }
              }
              _ => ()
            }
            match (importname_to_string(i.name), resource_exports) {
              (Some(name), Some(res)) =>
                my_import_instance_resource_exports.set(name, res)
              _ => ()
            }
            if !instancetype_valid_for_use_as_interface(
                tyidx, type_table, type_outers, import_named_types,
              ) {
              raise SectionParseError(
                10, "instance not valid to be used as import",
              )
            }
          }
          None => instance_sigs.push(None)
        }
        if type_table[tyidx] is Some(td) {
          let (metadata, next, remaining) = imported_instance_metadata(
            td,
            type_table,
            resource_ids,
            resource_exports.unwrap_or(Map([])),
            counts.type_metadata,
            next_resource_id,
            counts.metadata_remaining,
          )
          counts.metadata_remaining = remaining
          next_resource_id = next
          if metadata is Some(metadata) {
            func_export_sigs = Some(metadata.nodes[0].functions)
            counts.instance_metadata[instance_sigs.length() - 1] = (metadata, 0)
            let core_scope = match counts.core_contracts {
              Some(graph) =>
                match graph.scope(0) {
                  Some(root) =>
                    match root.binding(3, tyidx) {
                      Some(Scope(id)) => Some(id)
                      _ => None
                    }
                  None => None
                }
              None => None
            }
            let (contract, next, remaining) = scoped_contract_metadata(
              td,
              type_table,
              resource_ids,
              counts.type_metadata,
              next_resource_id,
              counts.metadata_remaining,
              core_contracts=counts.core_contracts,
              core_scope~,
              seed=Some((metadata, 0)),
            )
            next_resource_id = next
            counts.metadata_remaining = remaining
            if contract is Some(contract) {
              counts.instance_contracts[instance_sigs.length() - 1] = (
                contract, 0,
              )
            }
            instance_sigs[instance_sigs.length() - 1] = Some(
              metadata_instance_sig(metadata, 0),
            )
          }
        }
        counts.metadata_remaining = check_import_resources(
          counts.instance_contracts
          .get(instance_sigs.length() - 1)
          .map(pair => pair.0),
          import_locals,
          counts.metadata_remaining,
        )
        instance_export_type_idxs.push(None)
        instance_export_func_idxs.push(None)
        instance_export_type_map.push(type_map)
        instance_export_type_sigs.push(type_sig_map)
        instance_export_func_sigs.push(func_export_sigs)
        instance_nested_instance_type_sigs.push(None)
        instance_nested_instance_func_sigs.push(None)
        // Imported instances contribute an entry to the instance index space.
        // We don't have a precise effective-size model here; treat as 1.
        instance_sizes.push(1)
        // Bit 1 names exported types; bit 2 also permits using them in imports.
        interface_instance_idxs.set(instance_sigs.length() - 1, 3)
      }
      _ => ()
    }
    if i.desc is FuncType(_) {
      imported_funcs += 1
    }
    if i.desc is ComponentType(tyidx) {
      if type_table.get(tyidx) is Some(Some(td)) {
        let core_scope = match counts.core_contracts {
          Some(graph) =>
            match graph.scope(0) {
              Some(root) =>
                match root.binding(3, tyidx) {
                  Some(Scope(id)) => Some(id)
                  _ => None
                }
              None => None
            }
          None => None
        }
        let (metadata, next, remaining) = scoped_contract_metadata(
          td,
          type_table,
          resource_ids,
          counts.type_metadata,
          next_resource_id,
          counts.metadata_remaining,
          core_contracts=counts.core_contracts,
          core_scope~,
        )
        next_resource_id = next
        counts.metadata_remaining = remaining
        if metadata is Some(metadata) {
          counts.component_contracts[counts.component] = (metadata, 0)
        }
      }
      counts.metadata_remaining = check_import_resources(
        counts.component_contracts.get(counts.component).map(pair => pair.0),
        import_locals,
        counts.metadata_remaining,
      )
      let mut import_sorts : Map[String, @component.Sort]? = None
      let mut import_instance_sigs : Map[String, InstanceSig]? = None
      let mut import_func_sigs : Map[String, FuncSigShape]? = None
      let mut import_core_module_import_sigs : Map[
        String,
        Map[String, CoreExternType],
      ]? = None
      let mut import_core_module_exports : Map[String, Map[String, Int32]]? = None
      let mut import_type_sigs : Map[String, TypeSig]? = None
      let mut import_type_bounds : Map[String, @component.TypeBound]? = None
      let mut export_sorts : Map[String, @component.Sort]? = None
      let mut export_instance_sigs : Map[String, InstanceSig]? = None
      let mut export_type_sigs : Map[String, TypeSig]? = None
      let mut export_func_sigs : Map[String, FuncSigShape]? = None
      if tyidx >= 0 && tyidx < type_table.length() {
        if type_table[tyidx] is Some(ComponentType(decls)) {
          let (imp_sorts, imp_inst_sigs, exp_sorts, exp_inst_sigs) = componenttype_signature_of_decls(
            decls, type_table,
          )
          import_sorts = Some(imp_sorts)
          import_instance_sigs = Some(imp_inst_sigs)
          import_func_sigs = Some(
            componenttype_import_func_sigs_of_decls(
              decls, type_table, resource_ids,
            ),
          )
          let (core_imports, core_exports) = componenttype_import_core_module_sigs_of_decls(
            decls,
          )
          import_core_module_import_sigs = Some(core_imports)
          import_core_module_exports = Some(core_exports)
          import_type_sigs = Some(
            componenttype_import_type_sigs_of_decls(
              decls, type_table, resource_ids,
            ),
          )
          import_type_bounds = Some(
            componenttype_import_type_bounds_of_decls(decls),
          )
          export_sorts = Some(exp_sorts)
          export_instance_sigs = Some(exp_inst_sigs)
          export_type_sigs = Some(
            componenttype_export_type_sigs_of_decls(
              decls, type_table, resource_ids,
            ),
          )
          export_func_sigs = Some(
            componenttype_export_func_sigs_of_decls(
              decls, type_table, resource_ids,
            ),
          )
        }
      }
      component_import_sorts.push(import_sorts)
      component_import_instance_sigs.push(import_instance_sigs)
      component_import_func_sigs.push(import_func_sigs)
      component_import_instance_resource_exports.push(None)
      component_import_core_module_exports.push(import_core_module_exports)
      component_import_core_module_import_sigs.push(
        import_core_module_import_sigs,
      )
      component_import_type_bounds.push(import_type_bounds)
      component_import_type_sigs.push(import_type_sigs)
      component_export_sorts.push(export_sorts)
      component_export_instance_sigs.push(export_instance_sigs)
      component_export_instance_type_sigs.push(None)
      component_export_instance_func_sigs.push(None)
      component_export_type_sigs.push(export_type_sigs)
      component_export_func_sigs.push(export_func_sigs)
      // Imported component size is unknown; treat as 1.
      component_sizes.push(1)
    }
    if i.desc is Type(b) {
      // Type imports extend the type index space.
      //
      // `eq` imports are aliases to an existing type, so we can propagate
      // the underlying definition/size/depth. `sub resource` is treated
      // as abstract for now.
      match b {
        Eq(tyidx) =>
          if tyidx >= 0 && tyidx < type_table.length() {
            type_table.push(type_table[tyidx])
            if tyidx >= 0 && tyidx < local_resource_types.length() {
              local_resource_types.push(local_resource_types[tyidx])
            } else {
              local_resource_types.push(false)
            }
            if tyidx >= 0 && tyidx < resource_ids.length() {
              resource_ids.push(resource_ids[tyidx])
            } else {
              resource_ids.push(None)
            }
            if tyidx >= 0 && tyidx < type_sizes.length() {
              type_sizes.push(type_sizes[tyidx])
            } else {
              type_sizes.push(1)
            }
            if tyidx >= 0 && tyidx < type_depths.length() {
              type_depths.push(type_depths[tyidx])
            } else {
              type_depths.push(1)
            }
          } else {
            type_table.push(None)
            local_resource_types.push(false)
            resource_ids.push(None)
            type_sizes.push(1)
            type_depths.push(1)
          }
        SubResource => {
          type_table.push(Some(ResourceType(-1, 0x7f, None, HostDefined)))
          local_resource_types.push(false)
          resource_ids.push(Some(next_resource_id))
          next_resource_id += 1
          type_sizes.push(1)
          type_depths.push(1)
        }
      }
      // Imported types are named by their import string, so the newly
      // introduced type index is available as a named type.
      let new_idx = type_table.length() - 1
      named_types.set(new_idx, 1)
      import_named_types.set(new_idx, 1)
      if importname_to_string(i.name) is Some(name) {
        match b {
          Eq(tyidx) => {
            my_import_type_bounds.set(name, Eq(tyidx))
            my_import_type_sigs.set(
              name,
              type_sig_of_typeidx(tyidx, type_table, resource_ids),
            )
          }
          SubResource => {
            import_resource_names.set(name, new_idx)
            my_import_type_bounds.set(name, SubResource)
            my_import_type_sigs.set(
              name,
              type_sig_of_typeidx(new_idx, type_table, resource_ids),
            )
          }
        }
      }
      if !valtype_valid_for_type_import_export(
          TypeIdx(new_idx),
          type_table,
          resource_ids,
          import_named_types,
          Map([]),
        ) {
        raise SectionParseError(10, "type not valid to be used as import")
      }
      if type_table[new_idx] is Some(InstanceType(_)) ||
        type_table[new_idx] is Some(InstanceTypeEmpty) {
        if !instancetype_valid_for_use_as_interface(
            new_idx, type_table, type_outers, import_named_types,
          ) {
          raise SectionParseError(10, "type not valid to be used as import")
        }
      }
    }
    count_import(i.desc, counts)
  }
  (next_resource_id, imported_funcs)
}
