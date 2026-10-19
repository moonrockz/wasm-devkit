(component
  (core module (;0;)
    (type (;0;) (func (param i32 i32)))
    (type (;1;) (func (param i32 i32 i32) (result i32)))
    (type (;2;) (func (param i32 i32) (result i32)))
    (type (;3;) (func))
    (type (;4;) (func (result i32)))
    (type (;5;) (func (param i32)))
    (type (;6;) (func (param i32 i32 i32)))
    (type (;7;) (func (param i32 i32 i32 i32)))
    (type (;8;) (func (param i32 i32 i32 i32 i32)))
    (type (;9;) (func (param i32 i32 i32 i32 i32 i32 i32)))
    (type (;10;) (func (param i32 i32 i32 i32) (result i32)))
    (type (;11;) (func (param i32) (result i32)))
    (type (;12;) (func (param i32 i32 i32 i32 i32 i32)))
    (type (;13;) (func (param i32 i32 i32 i32 i32 i32) (result i32)))
    (type (;14;) (func (param i32 i32 i32 i32 i32) (result i32)))
    (type (;15;) (func (param i64 i32 i32) (result i32)))
    (table (;0;) 26 26 funcref)
    (memory (;0;) 17)
    (global $__stack_pointer (;0;) (mut i32) i32.const 1048576)
    (global (;1;) i32 i32.const 1050961)
    (global (;2;) i32 i32.const 1050976)
    (export "memory" (memory 0))
    (export "hello" (func $hello))
    (export "cabi_post_hello" (func $cabi_post_hello))
    (export "cabi_realloc" (func $cabi_realloc))
    (export "__data_end" (global 1))
    (export "__heap_base" (global 2))
    (elem (;0;) (i32.const 1) func $_ZN4core3ptr30drop_in_place$LT$$RF$usize$GT$17h47a431ebe5707960E $_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h7bc483c80bad04b6E $_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17hf7c5e72c33d02c47E $_ZN3std5alloc24default_alloc_error_hook17hb90ac78828581236E $_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17hc0da2817d3a744a6E $_ZN58_$LT$alloc..string..String$u20$as$u20$core..fmt..Write$GT$9write_str17hf9053c3a4494653aE $_ZN58_$LT$alloc..string..String$u20$as$u20$core..fmt..Write$GT$10write_char17h063160badd7077ccE $_ZN4core3fmt5Write9write_fmt17hffd94433da6ef0e4E $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17h5c94a5461dcd884dE $_ZN4core3ptr122drop_in_place$LT$$RF$alloc..boxed..Box$LT$dyn$u20$core..error..Error$u2b$core..marker..Sync$u2b$core..marker..Send$GT$$GT$17h1180b14201b07337E $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17h8c09ce30cfb56d1cE $_ZN99_$LT$std..panicking..begin_panic_handler..StaticStrPayload$u20$as$u20$core..panic..PanicPayload$GT$8take_box17hc813660103856c46E $_ZN99_$LT$std..panicking..begin_panic_handler..StaticStrPayload$u20$as$u20$core..panic..PanicPayload$GT$3get17h20f50abc24867da8E $_ZN4core3ptr77drop_in_place$LT$std..panicking..begin_panic_handler..FormatStringPayload$GT$17h192372df2cc52b39E $_ZN102_$LT$std..panicking..begin_panic_handler..FormatStringPayload$u20$as$u20$core..panic..PanicPayload$GT$8take_box17h4253cf791c247536E $_ZN102_$LT$std..panicking..begin_panic_handler..FormatStringPayload$u20$as$u20$core..panic..PanicPayload$GT$3get17h6541a23d93727cccE $_ZN4core3ptr29drop_in_place$LT$$LP$$RP$$GT$17h78062830dc5d549cE $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17hc894c8c4ad4a3830E $_ZN4core3ops8function6FnOnce9call_once17hbdd3bac4d73d8ae8E $_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17h3616e10b12449442E $_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h0a20f2b6114281ceE $_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h780d3eefec70f4afE $_ZN59_$LT$core..fmt..Arguments$u20$as$u20$core..fmt..Display$GT$3fmt17h37e2c1310d2a64e6E $_ZN4core3ptr37drop_in_place$LT$core..fmt..Error$GT$17h9152df636f15f3d2E $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17h3f1658fbcb5f23d9E)
    (func $__wasm_call_ctors (;0;) (type 3))
    (func $_ZN5alloc7raw_vec14handle_reserve17h2ebba3ae66d563d2E (;1;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 32
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      global.set $__stack_pointer
      local.get 4
      local.get 0
      i32.store offset=16
      local.get 4
      local.get 1
      i32.store offset=20
      local.get 4
      local.get 0
      local.get 1
      call $_ZN4core6result19Result$LT$T$C$E$GT$7map_err17had25ca9954f40b7aE
      local.get 4
      i32.load
      local.set 5
      local.get 4
      i32.load offset=4
      local.set 6
      local.get 4
      local.get 6
      i32.store offset=12
      local.get 4
      local.get 5
      i32.store offset=8
      local.get 4
      i32.load offset=8
      local.set 7
      i32.const -2147483647
      local.set 8
      local.get 7
      local.set 9
      local.get 8
      local.set 10
      local.get 9
      local.get 10
      i32.eq
      local.set 11
      i32.const 0
      local.set 12
      i32.const 1
      local.set 13
      i32.const 1
      local.set 14
      local.get 11
      local.get 14
      i32.and
      local.set 15
      local.get 12
      local.get 13
      local.get 15
      select
      local.set 16
      block ;; label = @1
        local.get 16
        br_if 0 (;@1;)
        i32.const 32
        local.set 17
        local.get 4
        local.get 17
        i32.add
        local.set 18
        local.get 18
        global.set $__stack_pointer
        return
      end
      local.get 4
      i32.load offset=8
      local.set 19
      i32.const 0
      local.set 20
      i32.const 1
      local.set 21
      local.get 21
      local.get 20
      local.get 19
      select
      local.set 22
      block ;; label = @1
        local.get 22
        br_if 0 (;@1;)
        call $_ZN5alloc7raw_vec17capacity_overflow17hfd18578094e5282cE
        unreachable
      end
      local.get 4
      i32.load offset=8
      local.set 23
      local.get 4
      i32.load offset=12
      local.set 24
      local.get 4
      local.get 23
      i32.store offset=24
      local.get 4
      local.get 24
      i32.store offset=28
      local.get 23
      local.get 24
      call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
      unreachable
    )
    (func $hello (;2;) (type 4) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 0
      i32.const 80
      local.set 1
      local.get 0
      local.get 1
      i32.sub
      local.set 2
      local.get 2
      global.set $__stack_pointer
      call $_ZN11wit_bindgen2rt14run_ctors_once17h1e4f0d96413fa296E
      i32.const 20
      local.set 3
      local.get 2
      local.get 3
      i32.add
      local.set 4
      local.get 4
      local.set 5
      local.get 5
      call $_ZN59_$LT$hello..Component$u20$as$u20$hello..bindings..Guest$GT$5hello17hbd3a9e77acbb45cfE
      i32.const 1050468
      local.set 6
      local.get 2
      local.get 6
      i32.store offset=64
      i32.const 8
      local.set 7
      local.get 2
      local.get 7
      i32.store offset=68
      i32.const 1050468
      local.set 8
      local.get 2
      local.get 8
      i32.store offset=44
      i32.const 32
      local.set 9
      local.get 2
      local.get 9
      i32.add
      local.set 10
      local.get 10
      local.set 11
      i32.const 20
      local.set 12
      local.get 2
      local.get 12
      i32.add
      local.set 13
      local.get 13
      local.set 14
      local.get 11
      local.get 14
      call $_ZN5alloc6string6String10into_bytes17h27929a3e850a2e23E
      i32.const 8
      local.set 15
      local.get 2
      local.get 15
      i32.add
      local.set 16
      i32.const 32
      local.set 17
      local.get 2
      local.get 17
      i32.add
      local.set 18
      local.get 16
      local.get 18
      call $_ZN5alloc3vec16Vec$LT$T$C$A$GT$16into_boxed_slice17h489bd644c6570a98E
      local.get 2
      i32.load offset=12
      local.set 19
      local.get 2
      i32.load offset=8
      local.set 20
      local.get 2
      local.get 20
      i32.store offset=48
      local.get 2
      local.get 19
      i32.store offset=52
      local.get 2
      local.get 20
      i32.store offset=72
      local.get 2
      local.get 19
      i32.store offset=76
      local.get 2
      local.get 20
      i32.store offset=56
      local.get 2
      local.get 19
      i32.store offset=60
      local.get 20
      local.get 19
      call $_ZN4core3mem6forget17h734bfb586f46e07cE
      i32.const 4
      local.set 21
      local.get 8
      local.get 21
      i32.add
      local.set 22
      local.get 22
      local.get 8
      i32.lt_s
      local.set 23
      i32.const 1
      local.set 24
      local.get 23
      local.get 24
      i32.and
      local.set 25
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    local.get 25
                    br_if 0 (;@7;)
                    i32.const 3
                    local.set 26
                    local.get 22
                    local.get 26
                    i32.and
                    local.set 27
                    i32.const 0
                    local.set 28
                    local.get 27
                    local.set 29
                    local.get 28
                    local.set 30
                    local.get 29
                    local.get 30
                    i32.eq
                    local.set 31
                    i32.const 1
                    local.set 32
                    local.get 31
                    local.get 32
                    i32.and
                    local.set 33
                    local.get 33
                    br_if 1 (;@6;)
                    br 2 (;@5;)
                  end
                  i32.const 1048608
                  local.set 34
                  i32.const 28
                  local.set 35
                  i32.const 1048592
                  local.set 36
                  local.get 34
                  local.get 35
                  local.get 36
                  call $_ZN4core9panicking5panic17hd37d8d0a98259c88E
                  unreachable
                end
                local.get 22
                local.get 19
                i32.store
                i32.const 0
                local.set 37
                local.get 8
                local.set 38
                i32.const 1
                local.set 39
                local.get 37
                local.get 39
                i32.and
                local.set 40
                local.get 40
                br_if 2 (;@3;)
                br 1 (;@4;)
              end
              i32.const 4
              local.set 41
              i32.const 1048636
              local.set 42
              local.get 41
              local.get 22
              local.get 42
              call $_ZN4core9panicking36panic_misaligned_pointer_dereference17habcd31ab43a20267E
              unreachable
            end
            i32.const 3
            local.set 43
            local.get 38
            local.get 43
            i32.and
            local.set 44
            i32.const 0
            local.set 45
            local.get 44
            local.set 46
            local.get 45
            local.set 47
            local.get 46
            local.get 47
            i32.eq
            local.set 48
            i32.const 1
            local.set 49
            local.get 48
            local.get 49
            i32.and
            local.set 50
            local.get 50
            br_if 1 (;@2;)
            br 2 (;@1;)
          end
          i32.const 1048608
          local.set 51
          i32.const 28
          local.set 52
          i32.const 1048652
          local.set 53
          local.get 51
          local.get 52
          local.get 53
          call $_ZN4core9panicking5panic17hd37d8d0a98259c88E
          unreachable
        end
        local.get 38
        local.get 20
        i32.store
        i32.const 80
        local.set 54
        local.get 2
        local.get 54
        i32.add
        local.set 55
        local.get 55
        global.set $__stack_pointer
        local.get 8
        return
      end
      i32.const 4
      local.set 56
      i32.const 1048668
      local.set 57
      local.get 56
      local.get 38
      local.get 57
      call $_ZN4core9panicking36panic_misaligned_pointer_dereference17habcd31ab43a20267E
      unreachable
    )
    (func $cabi_post_hello (;3;) (type 5) (param i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 1
      i32.const 16
      local.set 2
      local.get 1
      local.get 2
      i32.sub
      local.set 3
      local.get 3
      global.set $__stack_pointer
      local.get 3
      local.get 0
      i32.store offset=4
      i32.const 0
      local.set 4
      local.get 0
      local.set 5
      i32.const 1
      local.set 6
      local.get 4
      local.get 6
      i32.and
      local.set 7
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    local.get 7
                    br_if 0 (;@7;)
                    i32.const 3
                    local.set 8
                    local.get 5
                    local.get 8
                    i32.and
                    local.set 9
                    i32.const 0
                    local.set 10
                    local.get 9
                    local.set 11
                    local.get 10
                    local.set 12
                    local.get 11
                    local.get 12
                    i32.eq
                    local.set 13
                    i32.const 1
                    local.set 14
                    local.get 13
                    local.get 14
                    i32.and
                    local.set 15
                    local.get 15
                    br_if 1 (;@6;)
                    br 2 (;@5;)
                  end
                  i32.const 1048608
                  local.set 16
                  i32.const 28
                  local.set 17
                  i32.const 1048684
                  local.set 18
                  local.get 16
                  local.get 17
                  local.get 18
                  call $_ZN4core9panicking5panic17hd37d8d0a98259c88E
                  unreachable
                end
                local.get 5
                i32.load
                local.set 19
                local.get 3
                local.get 19
                i32.store offset=8
                i32.const 4
                local.set 20
                local.get 0
                local.get 20
                i32.add
                local.set 21
                local.get 21
                local.get 0
                i32.lt_s
                local.set 22
                i32.const 1
                local.set 23
                local.get 22
                local.get 23
                i32.and
                local.set 24
                local.get 24
                br_if 2 (;@3;)
                br 1 (;@4;)
              end
              i32.const 4
              local.set 25
              i32.const 1048700
              local.set 26
              local.get 25
              local.get 5
              local.get 26
              call $_ZN4core9panicking36panic_misaligned_pointer_dereference17habcd31ab43a20267E
              unreachable
            end
            i32.const 3
            local.set 27
            local.get 21
            local.get 27
            i32.and
            local.set 28
            i32.const 0
            local.set 29
            local.get 28
            local.set 30
            local.get 29
            local.set 31
            local.get 30
            local.get 31
            i32.eq
            local.set 32
            i32.const 1
            local.set 33
            local.get 32
            local.get 33
            i32.and
            local.set 34
            local.get 34
            br_if 1 (;@2;)
            br 2 (;@1;)
          end
          i32.const 1048608
          local.set 35
          i32.const 28
          local.set 36
          i32.const 1048716
          local.set 37
          local.get 35
          local.get 36
          local.get 37
          call $_ZN4core9panicking5panic17hd37d8d0a98259c88E
          unreachable
        end
        local.get 21
        i32.load
        local.set 38
        local.get 3
        local.get 38
        i32.store offset=12
        i32.const 1
        local.set 39
        local.get 19
        local.get 38
        local.get 39
        call $_ZN11wit_bindgen2rt7dealloc17h183b5fdc6aa132c8E
        i32.const 16
        local.set 40
        local.get 3
        local.get 40
        i32.add
        local.set 41
        local.get 41
        global.set $__stack_pointer
        return
      end
      i32.const 4
      local.set 42
      i32.const 1048732
      local.set 43
      local.get 42
      local.get 21
      local.get 43
      call $_ZN4core9panicking36panic_misaligned_pointer_dereference17habcd31ab43a20267E
      unreachable
    )
    (func $_ZN47_$LT$str$u20$as$u20$alloc..string..ToString$GT$9to_string17hb2114d404f8e9b62E (;4;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 i64 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 96
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 1
      i32.store offset=44
      local.get 5
      local.get 2
      i32.store offset=48
      local.get 5
      local.get 1
      i32.store offset=52
      local.get 5
      local.get 2
      i32.store offset=56
      local.get 5
      local.get 2
      i32.store offset=60
      i32.const 0
      local.set 6
      local.get 5
      local.get 2
      local.get 6
      call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$11allocate_in17h8c19c6b440b7e7eaE
      local.get 5
      i32.load offset=4
      local.set 7
      local.get 5
      i32.load
      local.set 8
      local.get 5
      local.get 8
      i32.store offset=32
      local.get 5
      local.get 7
      i32.store offset=36
      i32.const 0
      local.set 9
      local.get 5
      local.get 9
      i32.store offset=40
      local.get 5
      local.get 1
      i32.store offset=64
      i32.const 32
      local.set 10
      local.get 5
      local.get 10
      i32.add
      local.set 11
      local.get 11
      local.set 12
      local.get 5
      local.get 12
      i32.store offset=68
      i32.const 32
      local.set 13
      local.get 5
      local.get 13
      i32.add
      local.set 14
      local.get 14
      local.set 15
      local.get 5
      local.get 15
      i32.store offset=72
      local.get 5
      i32.load offset=32
      local.set 16
      local.get 5
      local.get 16
      i32.store offset=76
      local.get 5
      local.get 16
      i32.store offset=80
      local.get 5
      local.get 2
      i32.store offset=84
      i32.const 0
      local.set 17
      local.get 2
      local.get 17
      i32.shl
      local.set 18
      local.get 16
      local.get 1
      local.get 18
      call $memcpy
      drop
      i32.const 32
      local.set 19
      local.get 5
      local.get 19
      i32.add
      local.set 20
      local.get 20
      local.set 21
      local.get 5
      local.get 21
      i32.store offset=88
      local.get 5
      local.get 2
      i32.store offset=92
      local.get 5
      local.get 2
      i32.store offset=40
      i32.const 8
      local.set 22
      i32.const 16
      local.set 23
      local.get 5
      local.get 23
      i32.add
      local.set 24
      local.get 24
      local.get 22
      i32.add
      local.set 25
      i32.const 32
      local.set 26
      local.get 5
      local.get 26
      i32.add
      local.set 27
      local.get 27
      local.get 22
      i32.add
      local.set 28
      local.get 28
      i32.load
      local.set 29
      local.get 25
      local.get 29
      i32.store
      local.get 5
      i64.load offset=32 align=4
      local.set 30
      local.get 5
      local.get 30
      i64.store offset=16
      local.get 5
      i64.load offset=16 align=4
      local.set 31
      local.get 0
      local.get 31
      i64.store align=4
      i32.const 8
      local.set 32
      local.get 0
      local.get 32
      i32.add
      local.set 33
      i32.const 16
      local.set 34
      local.get 5
      local.get 34
      i32.add
      local.set 35
      local.get 35
      local.get 32
      i32.add
      local.set 36
      local.get 36
      i32.load
      local.set 37
      local.get 33
      local.get 37
      i32.store
      i32.const 96
      local.set 38
      local.get 5
      local.get 38
      i32.add
      local.set 39
      local.get 39
      global.set $__stack_pointer
      return
    )
    (func $_ZN5alloc6string6String10into_bytes17h27929a3e850a2e23E (;5;) (type 0) (param i32 i32)
      (local i64 i32 i32 i32 i32)
      local.get 1
      i64.load align=4
      local.set 2
      local.get 0
      local.get 2
      i64.store align=4
      i32.const 8
      local.set 3
      local.get 0
      local.get 3
      i32.add
      local.set 4
      local.get 1
      local.get 3
      i32.add
      local.set 5
      local.get 5
      i32.load
      local.set 6
      local.get 4
      local.get 6
      i32.store
      return
    )
    (func $_ZN59_$LT$hello..Component$u20$as$u20$hello..bindings..Guest$GT$5hello17hbd3a9e77acbb45cfE (;6;) (type 5) (param i32)
      (local i32 i32)
      i32.const 1048748
      local.set 1
      i32.const 5
      local.set 2
      local.get 0
      local.get 1
      local.get 2
      call $_ZN47_$LT$str$u20$as$u20$alloc..string..ToString$GT$9to_string17hb2114d404f8e9b62E
      return
    )
    (func $_ZN5alloc7raw_vec14handle_reserve28_$u7b$$u7b$closure$u7d$$u7d$17h59f4cd3c846e8137E (;7;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 48
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      local.get 1
      i32.store offset=8
      local.get 5
      local.get 2
      i32.store offset=12
      i32.const 8
      local.set 6
      local.get 5
      local.get 6
      i32.add
      local.set 7
      local.get 7
      local.set 8
      local.get 5
      local.get 8
      i32.store offset=28
      i32.const 8
      local.set 9
      local.get 5
      local.get 9
      i32.add
      local.set 10
      local.get 10
      local.set 11
      local.get 5
      local.get 11
      i32.store offset=32
      local.get 5
      i32.load offset=8
      local.set 12
      i32.const 0
      local.set 13
      i32.const 1
      local.set 14
      local.get 14
      local.get 13
      local.get 12
      select
      local.set 15
      block ;; label = @1
        block ;; label = @2
          local.get 15
          br_if 0 (;@2;)
          i32.const 0
          local.set 16
          local.get 5
          local.get 16
          i32.store offset=16
          br 1 (;@1;)
        end
        i32.const 8
        local.set 17
        local.get 5
        local.get 17
        i32.add
        local.set 18
        local.get 18
        local.set 19
        local.get 5
        local.get 19
        i32.store offset=36
        i32.const 8
        local.set 20
        local.get 5
        local.get 20
        i32.add
        local.set 21
        local.get 21
        local.set 22
        i32.const 8
        local.set 23
        local.get 22
        local.get 23
        i32.add
        local.set 24
        local.get 5
        local.get 24
        i32.store offset=40
        i32.const 8
        local.set 25
        local.get 5
        local.get 25
        i32.add
        local.set 26
        local.get 26
        local.set 27
        local.get 5
        local.get 27
        i32.store offset=44
        local.get 5
        i32.load offset=8
        local.set 28
        local.get 5
        i32.load offset=12
        local.set 29
        local.get 5
        local.get 28
        i32.store offset=16
        local.get 5
        local.get 29
        i32.store offset=20
      end
      local.get 5
      i32.load offset=16
      local.set 30
      local.get 5
      i32.load offset=20
      local.set 31
      local.get 0
      local.get 31
      i32.store offset=4
      local.get 0
      local.get 30
      i32.store
      return
    )
    (func $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$11allocate_in17h8c19c6b440b7e7eaE (;8;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 160
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 2
      local.set 6
      local.get 5
      local.get 6
      i32.store8 offset=30
      local.get 5
      local.get 1
      i32.store offset=108
      i32.const 0
      local.set 7
      i32.const 1
      local.set 8
      local.get 7
      local.get 8
      i32.and
      local.set 9
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            local.get 9
            br_if 0 (;@3;)
            local.get 1
            br_if 1 (;@2;)
          end
          i32.const 1
          local.set 10
          local.get 5
          local.get 10
          i32.store offset=152
          i32.const 1
          local.set 11
          local.get 5
          local.get 11
          i32.store offset=156
          i32.const 1
          local.set 12
          local.get 5
          local.get 12
          i32.store offset=84
          local.get 5
          i32.load offset=84
          local.set 13
          local.get 5
          local.get 13
          i32.store offset=80
          local.get 5
          i32.load offset=80
          local.set 14
          local.get 5
          local.get 14
          i32.store offset=32
          i32.const 0
          local.set 15
          local.get 5
          local.get 15
          i32.store offset=36
          br 1 (;@1;)
        end
        i32.const 1
        local.set 16
        local.get 5
        local.get 16
        i32.store offset=116
        i32.const 16
        local.set 17
        local.get 5
        local.get 17
        i32.add
        local.set 18
        local.get 18
        local.get 16
        local.get 16
        local.get 1
        call $_ZN4core5alloc6layout6Layout5array5inner17h5c28e5f19d76a48bE
        local.get 5
        i32.load offset=16
        local.set 19
        local.get 5
        i32.load offset=20
        local.set 20
        local.get 5
        local.get 20
        i32.store offset=52
        local.get 5
        local.get 19
        i32.store offset=48
        local.get 5
        i32.load offset=48
        local.set 21
        i32.const 1
        local.set 22
        i32.const 0
        local.set 23
        local.get 23
        local.get 22
        local.get 21
        select
        local.set 24
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                local.get 24
                br_if 0 (;@5;)
                local.get 5
                i32.load offset=48
                local.set 25
                local.get 5
                i32.load offset=52
                local.set 26
                local.get 5
                local.get 25
                i32.store offset=120
                local.get 5
                local.get 26
                i32.store offset=124
                local.get 5
                local.get 25
                i32.store offset=40
                local.get 5
                local.get 26
                i32.store offset=44
                i32.const 40
                local.set 27
                local.get 5
                local.get 27
                i32.add
                local.set 28
                local.get 28
                local.set 29
                local.get 5
                local.get 29
                i32.store offset=128
                local.get 5
                i32.load offset=44
                local.set 30
                local.get 5
                local.get 30
                i32.store offset=132
                i32.const 2147483647
                local.set 31
                local.get 30
                local.set 32
                local.get 31
                local.set 33
                local.get 32
                local.get 33
                i32.gt_u
                local.set 34
                i32.const 1
                local.set 35
                local.get 34
                local.get 35
                i32.and
                local.set 36
                local.get 36
                br_if 2 (;@3;)
                br 1 (;@4;)
              end
              call $_ZN5alloc7raw_vec17capacity_overflow17hfd18578094e5282cE
              unreachable
            end
            i32.const -2147483647
            local.set 37
            local.get 5
            local.get 37
            i32.store offset=56
            br 1 (;@2;)
          end
          i32.const 0
          local.set 38
          local.get 5
          local.get 38
          i32.store offset=96
          local.get 5
          i32.load offset=96
          local.set 39
          local.get 5
          i32.load offset=100
          local.set 40
          local.get 5
          local.get 39
          i32.store offset=88
          local.get 5
          local.get 40
          i32.store offset=92
          local.get 5
          i32.load offset=88
          local.set 41
          local.get 5
          i32.load offset=92
          local.set 42
          local.get 5
          local.get 41
          i32.store offset=56
          local.get 5
          local.get 42
          i32.store offset=60
        end
        local.get 5
        i32.load offset=56
        local.set 43
        i32.const -2147483647
        local.set 44
        local.get 43
        local.set 45
        local.get 44
        local.set 46
        local.get 45
        local.get 46
        i32.eq
        local.set 47
        i32.const 0
        local.set 48
        i32.const 1
        local.set 49
        i32.const 1
        local.set 50
        local.get 47
        local.get 50
        i32.and
        local.set 51
        local.get 48
        local.get 49
        local.get 51
        select
        local.set 52
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                local.get 52
                br_if 0 (;@5;)
                local.get 5
                i32.load8_u offset=30
                local.set 53
                i32.const 1
                local.set 54
                local.get 53
                local.get 54
                i32.and
                local.set 55
                local.get 55
                i32.eqz
                br_if 1 (;@4;)
                br 2 (;@3;)
              end
              call $_ZN5alloc7raw_vec17capacity_overflow17hfd18578094e5282cE
              unreachable
            end
            local.get 5
            i32.load offset=40
            local.set 56
            local.get 5
            i32.load offset=44
            local.set 57
            i32.const 31
            local.set 58
            local.get 5
            local.get 58
            i32.add
            local.set 59
            local.get 5
            local.get 59
            local.get 56
            local.get 57
            call $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17he7fd3fa2e46b921aE
            local.get 5
            i32.load
            local.set 60
            local.get 5
            i32.load offset=4
            local.set 61
            local.get 5
            local.get 61
            i32.store offset=68
            local.get 5
            local.get 60
            i32.store offset=64
            br 1 (;@2;)
          end
          local.get 5
          i32.load offset=40
          local.set 62
          local.get 5
          i32.load offset=44
          local.set 63
          i32.const 8
          local.set 64
          local.get 5
          local.get 64
          i32.add
          local.set 65
          i32.const 31
          local.set 66
          local.get 5
          local.get 66
          i32.add
          local.set 67
          local.get 65
          local.get 67
          local.get 62
          local.get 63
          call $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$15allocate_zeroed17h6b054cea0b582dc3E
          local.get 5
          i32.load offset=8
          local.set 68
          local.get 5
          i32.load offset=12
          local.set 69
          local.get 5
          local.get 69
          i32.store offset=68
          local.get 5
          local.get 68
          i32.store offset=64
        end
        local.get 5
        i32.load offset=64
        local.set 70
        i32.const 1
        local.set 71
        i32.const 0
        local.set 72
        local.get 72
        local.get 71
        local.get 70
        select
        local.set 73
        block ;; label = @2
          local.get 73
          br_if 0 (;@2;)
          local.get 5
          i32.load offset=64
          local.set 74
          local.get 5
          i32.load offset=68
          local.set 75
          local.get 5
          local.get 74
          i32.store offset=136
          local.get 5
          local.get 75
          i32.store offset=140
          local.get 5
          local.get 74
          i32.store offset=144
          local.get 5
          local.get 74
          i32.store offset=76
          local.get 5
          i32.load offset=76
          local.set 76
          local.get 5
          local.get 76
          i32.store offset=148
          local.get 5
          local.get 76
          i32.store offset=104
          local.get 5
          i32.load offset=104
          local.set 77
          local.get 5
          local.get 77
          i32.store offset=72
          local.get 5
          i32.load offset=72
          local.set 78
          local.get 5
          local.get 78
          i32.store offset=32
          local.get 5
          local.get 1
          i32.store offset=36
          br 1 (;@1;)
        end
        local.get 5
        i32.load offset=40
        local.set 79
        local.get 5
        i32.load offset=44
        local.set 80
        local.get 79
        local.get 80
        call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
        unreachable
      end
      local.get 5
      i32.load offset=32
      local.set 81
      local.get 5
      i32.load offset=36
      local.set 82
      local.get 0
      local.get 82
      i32.store offset=4
      local.get 0
      local.get 81
      i32.store
      i32.const 160
      local.set 83
      local.get 5
      local.get 83
      i32.add
      local.set 84
      local.get 84
      global.set $__stack_pointer
      return
    )
    (func $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$6shrink17hcad799d117808234E (;9;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 288
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 1
      i32.store offset=192
      local.get 5
      local.get 2
      i32.store offset=196
      i32.const 0
      local.set 6
      i32.const 1
      local.set 7
      local.get 6
      local.get 7
      i32.and
      local.set 8
      block ;; label = @1
        block ;; label = @2
          local.get 8
          br_if 0 (;@2;)
          local.get 1
          i32.load offset=4
          local.set 9
          local.get 5
          local.get 9
          i32.store offset=28
          br 1 (;@1;)
        end
        i32.const -1
        local.set 10
        local.get 5
        local.get 10
        i32.store offset=28
      end
      local.get 5
      i32.load offset=28
      local.set 11
      local.get 2
      local.set 12
      local.get 11
      local.set 13
      local.get 12
      local.get 13
      i32.le_u
      local.set 14
      i32.const 1
      local.set 15
      local.get 14
      local.get 15
      i32.and
      local.set 16
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      block ;; label = @9
                        local.get 16
                        br_if 0 (;@9;)
                        i32.const 1048792
                        local.set 17
                        local.get 5
                        local.get 17
                        i32.store offset=200
                        i32.const 1
                        local.set 18
                        local.get 5
                        local.get 18
                        i32.store offset=204
                        i32.const 0
                        local.set 19
                        i32.const 1
                        local.set 20
                        local.get 19
                        local.get 20
                        i32.and
                        local.set 21
                        local.get 21
                        br_if 2 (;@7;)
                        br 1 (;@8;)
                      end
                      i32.const 64
                      local.set 22
                      local.get 5
                      local.get 22
                      i32.add
                      local.set 23
                      local.get 23
                      local.set 24
                      local.get 24
                      local.get 1
                      call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17h9a822d492b59fa1cE
                      local.get 5
                      i32.load offset=68
                      local.set 25
                      i32.const 0
                      local.set 26
                      i32.const 1
                      local.set 27
                      local.get 27
                      local.get 26
                      local.get 25
                      select
                      local.set 28
                      i32.const 1
                      local.set 29
                      local.get 28
                      local.set 30
                      local.get 29
                      local.set 31
                      local.get 30
                      local.get 31
                      i32.eq
                      local.set 32
                      i32.const 1
                      local.set 33
                      local.get 32
                      local.get 33
                      i32.and
                      local.set 34
                      local.get 34
                      br_if 2 (;@6;)
                      br 3 (;@5;)
                    end
                    i32.const 0
                    local.set 35
                    local.get 5
                    local.get 35
                    i32.store offset=148
                    i32.const 1048792
                    local.set 36
                    local.get 5
                    local.get 36
                    i32.store offset=32
                    i32.const 1
                    local.set 37
                    local.get 5
                    local.get 37
                    i32.store offset=36
                    local.get 5
                    i32.load offset=148
                    local.set 38
                    local.get 5
                    i32.load offset=152
                    local.set 39
                    local.get 5
                    local.get 38
                    i32.store offset=48
                    local.get 5
                    local.get 39
                    i32.store offset=52
                    i32.const 1048800
                    local.set 40
                    local.get 5
                    local.get 40
                    i32.store offset=40
                    i32.const 0
                    local.set 41
                    local.get 5
                    local.get 41
                    i32.store offset=44
                    i32.const 32
                    local.set 42
                    local.get 5
                    local.get 42
                    i32.add
                    local.set 43
                    local.get 43
                    local.set 44
                    i32.const 1048876
                    local.set 45
                    local.get 44
                    local.get 45
                    call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
                    unreachable
                  end
                  i32.const 124
                  local.set 46
                  local.get 5
                  local.get 46
                  i32.add
                  local.set 47
                  local.get 47
                  local.set 48
                  i32.const 1048904
                  local.set 49
                  i32.const 1
                  local.set 50
                  local.get 48
                  local.get 49
                  local.get 50
                  call $_ZN4core3fmt9Arguments9new_const17h098141deaf10bf58E
                  i32.const 124
                  local.set 51
                  local.get 5
                  local.get 51
                  i32.add
                  local.set 52
                  local.get 52
                  local.set 53
                  i32.const 1048988
                  local.set 54
                  local.get 53
                  local.get 54
                  call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
                  unreachable
                end
                local.get 5
                i32.load offset=64
                local.set 55
                local.get 5
                local.get 55
                i32.store offset=208
                local.get 5
                i32.load offset=68
                local.set 56
                local.get 5
                i32.load offset=72
                local.set 57
                local.get 5
                local.get 56
                i32.store offset=212
                local.get 5
                local.get 57
                i32.store offset=216
                local.get 5
                local.get 56
                i32.store offset=56
                local.get 5
                local.get 57
                i32.store offset=60
                local.get 2
                i32.eqz
                br_if 1 (;@4;)
                br 2 (;@3;)
              end
              i32.const -2147483647
              local.set 58
              local.get 5
              local.get 58
              i32.store offset=20
              br 3 (;@1;)
            end
            i32.const 8
            local.set 59
            local.get 1
            local.get 59
            i32.add
            local.set 60
            local.get 5
            i32.load offset=56
            local.set 61
            local.get 5
            i32.load offset=60
            local.set 62
            local.get 60
            local.get 55
            local.get 61
            local.get 62
            call $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17h4bd7376b40e5390dE
            i32.const 1
            local.set 63
            local.get 5
            local.get 63
            i32.store offset=220
            i32.const 1
            local.set 64
            local.get 5
            local.get 64
            i32.store offset=224
            i32.const 1
            local.set 65
            local.get 5
            local.get 65
            i32.store offset=156
            local.get 5
            i32.load offset=156
            local.set 66
            local.get 5
            local.get 66
            i32.store offset=76
            local.get 5
            i32.load offset=76
            local.set 67
            local.get 1
            local.get 67
            i32.store
            i32.const 0
            local.set 68
            local.get 1
            local.get 68
            i32.store offset=4
            br 1 (;@2;)
          end
          i32.const 1
          local.set 69
          local.get 5
          local.get 69
          i32.store offset=228
          i32.const 0
          local.set 70
          local.get 2
          local.get 70
          i32.shl
          local.set 71
          local.get 5
          local.get 71
          i32.store offset=232
          i32.const 56
          local.set 72
          local.get 5
          local.get 72
          i32.add
          local.set 73
          local.get 73
          local.set 74
          local.get 5
          local.get 74
          i32.store offset=236
          local.get 5
          i32.load offset=56
          local.set 75
          local.get 5
          local.get 75
          i32.store offset=240
          local.get 5
          local.get 75
          i32.store offset=160
          local.get 5
          i32.load offset=160
          local.set 76
          local.get 5
          local.get 76
          i32.store offset=244
          local.get 5
          local.get 71
          i32.store offset=84
          local.get 5
          local.get 76
          i32.store offset=80
          i32.const 8
          local.set 77
          local.get 1
          local.get 77
          i32.add
          local.set 78
          local.get 5
          i32.load offset=56
          local.set 79
          local.get 5
          i32.load offset=60
          local.set 80
          local.get 5
          i32.load offset=80
          local.set 81
          local.get 5
          i32.load offset=84
          local.set 82
          i32.const 8
          local.set 83
          local.get 5
          local.get 83
          i32.add
          local.set 84
          local.get 84
          local.get 78
          local.get 55
          local.get 79
          local.get 80
          local.get 81
          local.get 82
          call $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$6shrink17h778ddcc05bced5bbE
          local.get 5
          i32.load offset=12
          local.set 85
          local.get 5
          i32.load offset=8
          local.set 86
          i32.const 80
          local.set 87
          local.get 5
          local.get 87
          i32.add
          local.set 88
          local.get 88
          local.set 89
          local.get 5
          local.get 89
          i32.store offset=112
          local.get 5
          i32.load offset=112
          local.set 90
          i32.const 100
          local.set 91
          local.get 5
          local.get 91
          i32.add
          local.set 92
          local.get 92
          local.set 93
          local.get 93
          local.get 86
          local.get 85
          local.get 90
          call $_ZN4core6result19Result$LT$T$C$E$GT$7map_err17h4bcadcfc8cbc2ce6E
          local.get 5
          i32.load offset=100
          local.set 94
          block ;; label = @3
            block ;; label = @4
              local.get 94
              br_if 0 (;@4;)
              local.get 5
              i32.load offset=104
              local.set 95
              local.get 5
              i32.load offset=108
              local.set 96
              local.get 5
              local.get 95
              i32.store offset=248
              local.get 5
              local.get 96
              i32.store offset=252
              local.get 5
              local.get 95
              i32.store offset=92
              local.get 5
              local.get 96
              i32.store offset=96
              i32.const 0
              local.set 97
              local.get 5
              local.get 97
              i32.store offset=88
              br 1 (;@3;)
            end
            local.get 5
            i32.load offset=104
            local.set 98
            local.get 5
            i32.load offset=108
            local.set 99
            local.get 5
            local.get 98
            i32.store offset=256
            local.get 5
            local.get 99
            i32.store offset=260
            local.get 5
            local.get 98
            i32.store offset=164
            local.get 5
            local.get 99
            i32.store offset=168
            local.get 5
            i32.load offset=164
            local.set 100
            local.get 5
            i32.load offset=168
            local.set 101
            local.get 5
            local.get 100
            i32.store offset=92
            local.get 5
            local.get 101
            i32.store offset=96
            i32.const 1
            local.set 102
            local.get 5
            local.get 102
            i32.store offset=88
          end
          local.get 5
          i32.load offset=88
          local.set 103
          block ;; label = @3
            local.get 103
            br_if 0 (;@3;)
            local.get 5
            i32.load offset=92
            local.set 104
            local.get 5
            i32.load offset=96
            local.set 105
            local.get 5
            local.get 104
            i32.store offset=264
            local.get 5
            local.get 105
            i32.store offset=268
            local.get 5
            local.get 104
            i32.store offset=272
            local.get 5
            local.get 104
            i32.store offset=176
            local.get 5
            i32.load offset=176
            local.set 106
            local.get 5
            local.get 106
            i32.store offset=276
            local.get 5
            local.get 106
            i32.store offset=180
            local.get 5
            i32.load offset=180
            local.set 107
            local.get 5
            local.get 107
            i32.store offset=172
            local.get 5
            i32.load offset=172
            local.set 108
            local.get 1
            local.get 108
            i32.store
            local.get 1
            local.get 2
            i32.store offset=4
            br 1 (;@2;)
          end
          local.get 5
          i32.load offset=92
          local.set 109
          local.get 5
          i32.load offset=96
          local.set 110
          local.get 5
          local.get 109
          i32.store offset=116
          local.get 5
          local.get 110
          i32.store offset=120
          local.get 5
          i32.load offset=116
          local.set 111
          local.get 5
          i32.load offset=120
          local.set 112
          local.get 5
          local.get 111
          i32.store offset=280
          local.get 5
          local.get 112
          i32.store offset=284
          local.get 5
          local.get 111
          i32.store offset=184
          local.get 5
          local.get 112
          i32.store offset=188
          local.get 5
          i32.load offset=184
          local.set 113
          local.get 5
          i32.load offset=188
          local.set 114
          local.get 5
          local.get 113
          i32.store offset=20
          local.get 5
          local.get 114
          i32.store offset=24
          br 1 (;@1;)
        end
        i32.const -2147483647
        local.set 115
        local.get 5
        local.get 115
        i32.store offset=20
      end
      local.get 5
      i32.load offset=20
      local.set 116
      local.get 5
      i32.load offset=24
      local.set 117
      local.get 0
      local.get 117
      i32.store offset=4
      local.get 0
      local.get 116
      i32.store
      i32.const 288
      local.set 118
      local.get 5
      local.get 118
      i32.add
      local.set 119
      local.get 119
      global.set $__stack_pointer
      return
    )
    (func $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$6shrink28_$u7b$$u7b$closure$u7d$$u7d$17h0c4f54572494c2f2E (;10;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 16
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      local.get 1
      i32.store
      local.get 4
      i32.load
      local.set 5
      local.get 5
      i32.load
      local.set 6
      local.get 5
      i32.load offset=4
      local.set 7
      local.get 4
      local.get 6
      i32.store offset=4
      local.get 4
      local.get 7
      i32.store offset=8
      local.get 4
      i32.load offset=4
      local.set 8
      local.get 4
      i32.load offset=8
      local.set 9
      local.get 0
      local.get 9
      i32.store offset=4
      local.get 0
      local.get 8
      i32.store
      return
    )
    (func $_ZN5alloc3vec16Vec$LT$T$C$A$GT$13shrink_to_fit17h80abdc49d5726d4dE (;11;) (type 5) (param i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 1
      i32.const 32
      local.set 2
      local.get 1
      local.get 2
      i32.sub
      local.set 3
      local.get 3
      global.set $__stack_pointer
      local.get 3
      local.get 0
      i32.store offset=16
      local.get 3
      local.get 0
      i32.store offset=20
      i32.const 0
      local.set 4
      i32.const 1
      local.set 5
      local.get 4
      local.get 5
      i32.and
      local.set 6
      block ;; label = @1
        block ;; label = @2
          local.get 6
          br_if 0 (;@2;)
          local.get 0
          i32.load offset=4
          local.set 7
          local.get 3
          local.get 7
          i32.store offset=12
          br 1 (;@1;)
        end
        i32.const -1
        local.set 8
        local.get 3
        local.get 8
        i32.store offset=12
      end
      local.get 0
      i32.load offset=8
      local.set 9
      local.get 3
      i32.load offset=12
      local.set 10
      local.get 10
      local.set 11
      local.get 9
      local.set 12
      local.get 11
      local.get 12
      i32.gt_u
      local.set 13
      i32.const 1
      local.set 14
      local.get 13
      local.get 14
      i32.and
      local.set 15
      block ;; label = @1
        block ;; label = @2
          local.get 15
          br_if 0 (;@2;)
          br 1 (;@1;)
        end
        local.get 3
        local.get 0
        i32.store offset=24
        local.get 0
        i32.load offset=8
        local.set 16
        local.get 3
        local.get 16
        i32.store offset=28
        local.get 3
        local.get 0
        local.get 16
        call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$6shrink17hcad799d117808234E
        local.get 3
        i32.load offset=4
        local.set 17
        local.get 3
        i32.load
        local.set 18
        local.get 18
        local.get 17
        call $_ZN5alloc7raw_vec14handle_reserve17h2ebba3ae66d563d2E
      end
      i32.const 32
      local.set 19
      local.get 3
      local.get 19
      i32.add
      local.set 20
      local.get 20
      global.set $__stack_pointer
      return
    )
    (func $_ZN5alloc3vec16Vec$LT$T$C$A$GT$16into_boxed_slice17h489bd644c6570a98E (;12;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 i32 i32 i32 i32 i64 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 256
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      global.set $__stack_pointer
      local.get 1
      call $_ZN5alloc3vec16Vec$LT$T$C$A$GT$13shrink_to_fit17h80abdc49d5726d4dE
      i32.const 8
      local.set 5
      local.get 1
      local.get 5
      i32.add
      local.set 6
      local.get 6
      i32.load
      local.set 7
      i32.const 32
      local.set 8
      local.get 4
      local.get 8
      i32.add
      local.set 9
      local.get 9
      local.get 5
      i32.add
      local.set 10
      local.get 10
      local.get 7
      i32.store
      local.get 1
      i64.load align=4
      local.set 11
      local.get 4
      local.get 11
      i64.store offset=32
      i32.const 16
      local.set 12
      local.get 4
      local.get 12
      i32.add
      local.set 13
      local.get 13
      local.get 5
      i32.add
      local.set 14
      local.get 10
      i32.load
      local.set 15
      local.get 14
      local.get 15
      i32.store
      local.get 4
      i64.load offset=32
      local.set 16
      local.get 4
      local.get 16
      i64.store offset=16
      i32.const 16
      local.set 17
      local.get 4
      local.get 17
      i32.add
      local.set 18
      local.get 4
      local.get 18
      i32.store offset=136
      i32.const 16
      local.set 19
      local.get 4
      local.get 19
      i32.add
      local.set 20
      local.get 4
      local.get 20
      i32.store offset=140
      local.get 4
      i32.load offset=16
      local.set 21
      local.get 4
      i32.load offset=20
      local.set 22
      local.get 4
      local.get 21
      i32.store offset=144
      local.get 4
      local.get 22
      i32.store offset=148
      i32.const 16
      local.set 23
      local.get 4
      local.get 23
      i32.add
      local.set 24
      local.get 4
      local.get 24
      i32.store offset=152
      i32.const 16
      local.set 25
      local.get 4
      local.get 25
      i32.add
      local.set 26
      local.get 4
      local.get 26
      i32.store offset=156
      local.get 14
      i32.load
      local.set 27
      local.get 4
      local.get 27
      i32.store offset=160
      local.get 4
      local.get 21
      i32.store offset=52
      local.get 4
      local.get 22
      i32.store offset=56
      i32.const 52
      local.set 28
      local.get 4
      local.get 28
      i32.add
      local.set 29
      local.get 4
      local.get 29
      i32.store offset=164
      i32.const 52
      local.set 30
      local.get 4
      local.get 30
      i32.add
      local.set 31
      local.get 4
      local.get 31
      i32.store offset=168
      local.get 4
      i32.load offset=52
      local.set 32
      local.get 4
      local.get 32
      i32.store offset=172
      local.get 4
      local.get 32
      i32.store offset=176
      local.get 4
      local.get 32
      i32.store offset=180
      local.get 4
      local.get 32
      i32.store offset=68
      local.get 4
      local.get 27
      i32.store offset=72
      local.get 4
      i32.load offset=68
      local.set 33
      local.get 4
      i32.load offset=72
      local.set 34
      local.get 4
      local.get 33
      i32.store offset=60
      local.get 4
      local.get 34
      i32.store offset=64
      local.get 4
      i32.load offset=60
      local.set 35
      local.get 4
      i32.load offset=64
      local.set 36
      local.get 4
      local.get 35
      i32.store offset=184
      local.get 4
      local.get 36
      i32.store offset=188
      local.get 4
      local.get 35
      i32.store offset=192
      local.get 4
      local.get 36
      i32.store offset=196
      i32.const 52
      local.set 37
      local.get 4
      local.get 37
      i32.add
      local.set 38
      local.get 4
      local.get 38
      i32.store offset=200
      i32.const 52
      local.set 39
      local.get 4
      local.get 39
      i32.add
      local.set 40
      local.get 40
      local.get 5
      i32.add
      local.set 41
      local.get 4
      local.get 41
      i32.store offset=204
      local.get 4
      local.get 35
      i32.store offset=84
      local.get 4
      local.get 36
      i32.store offset=88
      local.get 4
      i32.load offset=84
      local.set 42
      local.get 4
      i32.load offset=88
      local.set 43
      local.get 4
      local.get 42
      i32.store offset=76
      local.get 4
      local.get 43
      i32.store offset=80
      local.get 4
      i32.load offset=76
      local.set 44
      local.get 4
      i32.load offset=80
      local.set 45
      local.get 4
      local.get 44
      i32.store offset=44
      local.get 4
      local.get 45
      i32.store offset=48
      local.get 4
      i32.load offset=44
      local.set 46
      local.get 4
      i32.load offset=48
      local.set 47
      local.get 4
      local.get 46
      i32.store offset=92
      local.get 4
      local.get 47
      i32.store offset=96
      i32.const 92
      local.set 48
      local.get 4
      local.get 48
      i32.add
      local.set 49
      local.get 49
      local.get 5
      i32.add
      local.set 50
      local.get 4
      local.get 50
      i32.store offset=208
      local.get 4
      i32.load offset=92
      local.set 51
      local.get 4
      i32.load offset=96
      local.set 52
      local.get 4
      local.get 51
      i32.store offset=212
      local.get 4
      local.get 52
      i32.store offset=216
      local.get 4
      local.get 51
      i32.store offset=100
      local.get 4
      local.get 52
      i32.store offset=104
      i32.const 100
      local.set 53
      local.get 4
      local.get 53
      i32.add
      local.set 54
      local.get 4
      local.get 54
      i32.store offset=220
      local.get 4
      i32.load offset=100
      local.set 55
      local.get 4
      i32.load offset=104
      local.set 56
      local.get 4
      local.get 55
      i32.store offset=224
      local.get 4
      local.get 56
      i32.store offset=228
      local.get 4
      local.get 55
      i32.store offset=232
      local.get 4
      local.get 56
      i32.store offset=236
      local.get 4
      local.get 55
      i32.store offset=108
      local.get 4
      local.get 56
      i32.store offset=112
      local.get 4
      i32.load offset=108
      local.set 57
      local.get 4
      i32.load offset=112
      local.set 58
      local.get 4
      local.get 57
      i32.store offset=240
      local.get 4
      local.get 58
      i32.store offset=244
      local.get 4
      local.get 57
      i32.store offset=248
      local.get 4
      local.get 58
      i32.store offset=252
      local.get 4
      local.get 57
      i32.store offset=124
      local.get 4
      local.get 58
      i32.store offset=128
      local.get 4
      i32.load offset=124
      local.set 59
      local.get 4
      i32.load offset=128
      local.set 60
      local.get 4
      local.get 59
      i32.store offset=116
      local.get 4
      local.get 60
      i32.store offset=120
      local.get 4
      i32.load offset=116
      local.set 61
      local.get 4
      i32.load offset=120
      local.set 62
      local.get 4
      local.get 61
      i32.store offset=8
      local.get 4
      local.get 62
      i32.store offset=12
      local.get 4
      i32.load offset=8
      local.set 63
      local.get 4
      i32.load offset=12
      local.set 64
      local.get 0
      local.get 64
      i32.store offset=4
      local.get 0
      local.get 63
      i32.store
      i32.const 256
      local.set 65
      local.get 4
      local.get 65
      i32.add
      local.set 66
      local.get 66
      global.set $__stack_pointer
      return
    )
    (func $_ZN4core5alloc6layout6Layout5array5inner17h5c28e5f19d76a48bE (;13;) (type 7) (param i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 48
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 1
      i32.store offset=28
      local.get 6
      local.get 2
      i32.store offset=32
      local.get 6
      local.get 3
      i32.store offset=36
      block ;; label = @1
        block ;; label = @2
          local.get 1
          i32.eqz
          br_if 0 (;@2;)
          local.get 6
          local.get 2
          i32.store offset=20
          local.get 6
          i32.load offset=20
          local.set 7
          i32.const 1
          local.set 8
          local.get 7
          local.get 8
          i32.sub
          local.set 9
          i32.const 2147483647
          local.set 10
          local.get 10
          local.get 9
          i32.sub
          local.set 11
          i32.const 0
          local.set 12
          local.get 1
          local.set 13
          local.get 12
          local.set 14
          local.get 13
          local.get 14
          i32.eq
          local.set 15
          i32.const 1
          local.set 16
          local.get 15
          local.get 16
          i32.and
          local.set 17
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                local.get 17
                br_if 0 (;@5;)
                local.get 11
                local.get 1
                i32.div_u
                local.set 18
                local.get 3
                local.set 19
                local.get 18
                local.set 20
                local.get 19
                local.get 20
                i32.gt_u
                local.set 21
                i32.const 1
                local.set 22
                local.get 21
                local.get 22
                i32.and
                local.set 23
                local.get 23
                br_if 2 (;@3;)
                br 1 (;@4;)
              end
              i32.const 1049104
              local.set 24
              i32.const 25
              local.set 25
              i32.const 1049084
              local.set 26
              local.get 24
              local.get 25
              local.get 26
              call $_ZN4core9panicking5panic17hd37d8d0a98259c88E
              unreachable
            end
            br 1 (;@2;)
          end
          i32.const 0
          local.set 27
          local.get 6
          local.get 27
          i32.store offset=4
          br 1 (;@1;)
        end
        local.get 1
        local.get 3
        i32.mul
        local.set 28
        local.get 6
        local.get 28
        i32.store offset=40
        local.get 6
        local.get 2
        i32.store offset=24
        local.get 6
        i32.load offset=24
        local.set 29
        local.get 6
        local.get 29
        i32.store offset=44
        local.get 6
        local.get 28
        i32.store offset=16
        local.get 6
        local.get 29
        i32.store offset=12
        local.get 6
        i32.load offset=12
        local.set 30
        local.get 6
        i32.load offset=16
        local.set 31
        local.get 6
        local.get 30
        i32.store offset=4
        local.get 6
        local.get 31
        i32.store offset=8
      end
      local.get 6
      i32.load offset=4
      local.set 32
      local.get 6
      i32.load offset=8
      local.set 33
      local.get 0
      local.get 33
      i32.store offset=4
      local.get 0
      local.get 32
      i32.store
      i32.const 48
      local.set 34
      local.get 6
      local.get 34
      i32.add
      local.set 35
      local.get 35
      global.set $__stack_pointer
      return
    )
    (func $_ZN5alloc5alloc6Global10alloc_impl17h455120c429ef56d2E (;14;) (type 8) (param i32 i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 5
      i32.const 272
      local.set 6
      local.get 5
      local.get 6
      i32.sub
      local.set 7
      local.get 7
      global.set $__stack_pointer
      i32.const 0
      local.set 8
      local.get 7
      local.get 8
      i32.store offset=8
      i32.const 0
      local.set 9
      local.get 7
      local.get 9
      i32.store offset=12
      i32.const 0
      local.set 10
      local.get 7
      local.get 10
      i32.store offset=16
      i32.const 1050477
      local.set 11
      local.get 7
      local.get 11
      i32.store offset=20
      i32.const 1050477
      local.set 12
      local.get 7
      local.get 12
      i32.store offset=24
      i32.const 1050477
      local.set 13
      local.get 7
      local.get 13
      i32.store offset=28
      i32.const 1050477
      local.set 14
      local.get 7
      local.get 14
      i32.store offset=32
      i32.const 1050477
      local.set 15
      local.get 7
      local.get 15
      i32.store offset=36
      local.get 7
      local.get 2
      i32.store offset=48
      local.get 7
      local.get 3
      i32.store offset=52
      local.get 7
      local.get 1
      i32.store offset=164
      local.get 4
      local.set 16
      local.get 7
      local.get 16
      i32.store8 offset=171
      i32.const 48
      local.set 17
      local.get 7
      local.get 17
      i32.add
      local.set 18
      local.get 18
      local.set 19
      local.get 7
      local.get 19
      i32.store offset=172
      local.get 7
      i32.load offset=52
      local.set 20
      local.get 7
      local.get 20
      i32.store offset=176
      block ;; label = @1
        block ;; label = @2
          local.get 20
          br_if 0 (;@2;)
          i32.const 48
          local.set 21
          local.get 7
          local.get 21
          i32.add
          local.set 22
          local.get 22
          local.set 23
          local.get 7
          local.get 23
          i32.store offset=180
          local.get 7
          i32.load offset=48
          local.set 24
          local.get 7
          local.get 24
          i32.store offset=184
          local.get 7
          local.get 24
          i32.store offset=116
          local.get 7
          i32.load offset=116
          local.set 25
          local.get 7
          local.get 25
          i32.store offset=188
          local.get 7
          local.get 25
          i32.store offset=192
          local.get 7
          local.get 25
          i32.store offset=72
          local.get 7
          i32.load offset=72
          local.set 26
          local.get 7
          local.get 26
          i32.store offset=196
          local.get 7
          local.get 26
          i32.store offset=200
          local.get 7
          local.get 26
          i32.store offset=128
          i32.const 0
          local.set 27
          local.get 7
          local.get 27
          i32.store offset=132
          local.get 7
          i32.load offset=128
          local.set 28
          local.get 7
          i32.load offset=132
          local.set 29
          local.get 7
          local.get 28
          i32.store offset=120
          local.get 7
          local.get 29
          i32.store offset=124
          local.get 7
          i32.load offset=120
          local.set 30
          local.get 7
          i32.load offset=124
          local.set 31
          local.get 7
          local.get 30
          i32.store offset=204
          local.get 7
          local.get 31
          i32.store offset=208
          local.get 7
          local.get 30
          i32.store offset=64
          local.get 7
          local.get 31
          i32.store offset=68
          local.get 7
          i32.load offset=64
          local.set 32
          local.get 7
          i32.load offset=68
          local.set 33
          local.get 7
          local.get 32
          i32.store offset=56
          local.get 7
          local.get 33
          i32.store offset=60
          br 1 (;@1;)
        end
        local.get 4
        local.set 34
        block ;; label = @2
          block ;; label = @3
            local.get 34
            br_if 0 (;@3;)
            local.get 7
            i32.load offset=48
            local.set 35
            local.get 7
            i32.load offset=52
            local.set 36
            local.get 7
            local.get 35
            i32.store offset=88
            local.get 7
            local.get 36
            i32.store offset=92
            i32.const 0
            local.set 37
            local.get 37
            i32.load8_u offset=1050477
            local.set 38
            local.get 7
            local.get 38
            i32.store8 offset=215
            i32.const 88
            local.set 39
            local.get 7
            local.get 39
            i32.add
            local.set 40
            local.get 40
            local.set 41
            local.get 7
            local.get 41
            i32.store offset=216
            local.get 7
            i32.load offset=92
            local.set 42
            i32.const 88
            local.set 43
            local.get 7
            local.get 43
            i32.add
            local.set 44
            local.get 44
            local.set 45
            local.get 7
            local.get 45
            i32.store offset=220
            local.get 7
            i32.load offset=88
            local.set 46
            local.get 7
            local.get 46
            i32.store offset=224
            local.get 7
            local.get 46
            i32.store offset=140
            local.get 7
            i32.load offset=140
            local.set 47
            local.get 42
            local.get 47
            call $__rust_alloc
            local.set 48
            local.get 7
            local.get 48
            i32.store offset=76
            br 1 (;@2;)
          end
          local.get 7
          i32.load offset=48
          local.set 49
          local.get 7
          i32.load offset=52
          local.set 50
          local.get 7
          local.get 49
          i32.store offset=80
          local.get 7
          local.get 50
          i32.store offset=84
          i32.const 80
          local.set 51
          local.get 7
          local.get 51
          i32.add
          local.set 52
          local.get 52
          local.set 53
          local.get 7
          local.get 53
          i32.store offset=228
          local.get 7
          i32.load offset=84
          local.set 54
          i32.const 80
          local.set 55
          local.get 7
          local.get 55
          i32.add
          local.set 56
          local.get 56
          local.set 57
          local.get 7
          local.get 57
          i32.store offset=232
          local.get 7
          i32.load offset=80
          local.set 58
          local.get 7
          local.get 58
          i32.store offset=236
          local.get 7
          local.get 58
          i32.store offset=136
          local.get 7
          i32.load offset=136
          local.set 59
          local.get 54
          local.get 59
          call $__rust_alloc_zeroed
          local.set 60
          local.get 7
          local.get 60
          i32.store offset=76
        end
        local.get 7
        i32.load offset=76
        local.set 61
        local.get 7
        local.get 61
        i32.store offset=240
        block ;; label = @2
          block ;; label = @3
            local.get 61
            br_if 0 (;@3;)
            i32.const 0
            local.set 62
            local.get 7
            local.get 62
            i32.store offset=104
            br 1 (;@2;)
          end
          local.get 7
          local.get 61
          i32.store offset=144
          local.get 7
          i32.load offset=144
          local.set 63
          local.get 7
          local.get 63
          i32.store offset=104
        end
        local.get 7
        i32.load offset=104
        local.set 64
        i32.const 0
        local.set 65
        i32.const 1
        local.set 66
        local.get 66
        local.get 65
        local.get 64
        select
        local.set 67
        block ;; label = @2
          block ;; label = @3
            local.get 67
            br_if 0 (;@3;)
            i32.const 0
            local.set 68
            local.get 7
            local.get 68
            i32.store offset=100
            br 1 (;@2;)
          end
          local.get 7
          i32.load offset=104
          local.set 69
          local.get 7
          local.get 69
          i32.store offset=244
          local.get 7
          local.get 69
          i32.store offset=100
        end
        local.get 7
        i32.load offset=100
        local.set 70
        i32.const 1
        local.set 71
        i32.const 0
        local.set 72
        local.get 72
        local.get 71
        local.get 70
        select
        local.set 73
        block ;; label = @2
          block ;; label = @3
            local.get 73
            br_if 0 (;@3;)
            local.get 7
            i32.load offset=100
            local.set 74
            local.get 7
            local.get 74
            i32.store offset=248
            local.get 7
            local.get 74
            i32.store offset=96
            br 1 (;@2;)
          end
          i32.const 0
          local.set 75
          local.get 7
          local.get 75
          i32.store offset=96
        end
        local.get 7
        i32.load offset=96
        local.set 76
        i32.const 1
        local.set 77
        i32.const 0
        local.set 78
        local.get 78
        local.get 77
        local.get 76
        select
        local.set 79
        block ;; label = @2
          local.get 79
          br_if 0 (;@2;)
          local.get 7
          i32.load offset=96
          local.set 80
          local.get 7
          local.get 80
          i32.store offset=252
          local.get 7
          local.get 80
          i32.store offset=256
          local.get 7
          local.get 80
          i32.store offset=260
          local.get 7
          local.get 80
          i32.store offset=156
          local.get 7
          local.get 20
          i32.store offset=160
          local.get 7
          i32.load offset=156
          local.set 81
          local.get 7
          i32.load offset=160
          local.set 82
          local.get 7
          local.get 81
          i32.store offset=148
          local.get 7
          local.get 82
          i32.store offset=152
          local.get 7
          i32.load offset=148
          local.set 83
          local.get 7
          i32.load offset=152
          local.set 84
          local.get 7
          local.get 83
          i32.store offset=264
          local.get 7
          local.get 84
          i32.store offset=268
          local.get 7
          local.get 83
          i32.store offset=108
          local.get 7
          local.get 84
          i32.store offset=112
          local.get 7
          i32.load offset=108
          local.set 85
          local.get 7
          i32.load offset=112
          local.set 86
          local.get 7
          local.get 85
          i32.store offset=56
          local.get 7
          local.get 86
          i32.store offset=60
          br 1 (;@1;)
        end
        i32.const 0
        local.set 87
        local.get 7
        local.get 87
        i32.store offset=56
      end
      local.get 7
      i32.load offset=56
      local.set 88
      local.get 7
      i32.load offset=60
      local.set 89
      local.get 0
      local.get 89
      i32.store offset=4
      local.get 0
      local.get 88
      i32.store
      i32.const 272
      local.set 90
      local.get 7
      local.get 90
      i32.add
      local.set 91
      local.get 91
      global.set $__stack_pointer
      return
    )
    (func $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17h4bd7376b40e5390dE (;15;) (type 7) (param i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 48
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 2
      i32.store
      local.get 6
      local.get 3
      i32.store offset=4
      local.get 6
      local.get 0
      i32.store offset=20
      local.get 6
      local.get 1
      i32.store offset=24
      local.get 6
      local.set 7
      local.get 6
      local.get 7
      i32.store offset=28
      local.get 6
      i32.load offset=4
      local.set 8
      block ;; label = @1
        block ;; label = @2
          local.get 8
          br_if 0 (;@2;)
          br 1 (;@1;)
        end
        local.get 6
        local.get 1
        i32.store offset=32
        local.get 6
        i32.load
        local.set 9
        local.get 6
        i32.load offset=4
        local.set 10
        local.get 6
        local.get 9
        i32.store offset=8
        local.get 6
        local.get 10
        i32.store offset=12
        i32.const 8
        local.set 11
        local.get 6
        local.get 11
        i32.add
        local.set 12
        local.get 12
        local.set 13
        local.get 6
        local.get 13
        i32.store offset=36
        local.get 6
        i32.load offset=12
        local.set 14
        i32.const 8
        local.set 15
        local.get 6
        local.get 15
        i32.add
        local.set 16
        local.get 16
        local.set 17
        local.get 6
        local.get 17
        i32.store offset=40
        local.get 6
        i32.load offset=8
        local.set 18
        local.get 6
        local.get 18
        i32.store offset=44
        local.get 6
        local.get 18
        i32.store offset=16
        local.get 6
        i32.load offset=16
        local.set 19
        local.get 1
        local.get 14
        local.get 19
        call $__rust_dealloc
      end
      i32.const 48
      local.set 20
      local.get 6
      local.get 20
      i32.add
      local.set 21
      local.get 21
      global.set $__stack_pointer
      return
    )
    (func $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$15allocate_zeroed17h6b054cea0b582dc3E (;16;) (type 7) (param i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 32
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 1
      i32.store offset=20
      local.get 6
      local.get 2
      i32.store offset=24
      local.get 6
      local.get 3
      i32.store offset=28
      i32.const 1
      local.set 7
      i32.const 8
      local.set 8
      local.get 6
      local.get 8
      i32.add
      local.set 9
      local.get 9
      local.get 1
      local.get 2
      local.get 3
      local.get 7
      call $_ZN5alloc5alloc6Global10alloc_impl17h455120c429ef56d2E
      local.get 6
      i32.load offset=8
      local.set 10
      local.get 6
      i32.load offset=12
      local.set 11
      local.get 0
      local.get 11
      i32.store offset=4
      local.get 0
      local.get 10
      i32.store
      i32.const 32
      local.set 12
      local.get 6
      local.get 12
      i32.add
      local.set 13
      local.get 13
      global.set $__stack_pointer
      return
    )
    (func $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$6shrink17h778ddcc05bced5bbE (;17;) (type 9) (param i32 i32 i32 i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 7
      i32.const 352
      local.set 8
      local.get 7
      local.get 8
      i32.sub
      local.set 9
      local.get 9
      global.set $__stack_pointer
      i32.const 0
      local.set 10
      local.get 9
      local.get 10
      i32.store offset=20
      i32.const 0
      local.set 11
      local.get 9
      local.get 11
      i32.store offset=24
      i32.const 0
      local.set 12
      local.get 9
      local.get 12
      i32.store offset=28
      local.get 9
      local.get 3
      i32.store offset=44
      local.get 9
      local.get 4
      i32.store offset=48
      local.get 9
      local.get 5
      i32.store offset=52
      local.get 9
      local.get 6
      i32.store offset=56
      local.get 9
      local.get 1
      i32.store offset=184
      local.get 9
      local.get 2
      i32.store offset=188
      i32.const 52
      local.set 13
      local.get 9
      local.get 13
      i32.add
      local.set 14
      local.get 14
      local.set 15
      local.get 9
      local.get 15
      i32.store offset=192
      local.get 9
      i32.load offset=56
      local.set 16
      local.get 9
      local.get 16
      i32.store offset=68
      local.get 9
      i32.load offset=68
      local.set 17
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            local.get 17
            br_if 0 (;@3;)
            local.get 9
            i32.load offset=44
            local.set 18
            local.get 9
            i32.load offset=48
            local.set 19
            local.get 1
            local.get 2
            local.get 18
            local.get 19
            call $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17h4bd7376b40e5390dE
            i32.const 52
            local.set 20
            local.get 9
            local.get 20
            i32.add
            local.set 21
            local.get 21
            local.set 22
            local.get 9
            local.get 22
            i32.store offset=196
            local.get 9
            i32.load offset=52
            local.set 23
            local.get 9
            local.get 23
            i32.store offset=200
            local.get 9
            local.get 23
            i32.store offset=128
            local.get 9
            i32.load offset=128
            local.set 24
            local.get 9
            local.get 24
            i32.store offset=204
            local.get 9
            local.get 24
            i32.store offset=208
            local.get 9
            local.get 24
            i32.store offset=80
            local.get 9
            i32.load offset=80
            local.set 25
            local.get 9
            local.get 25
            i32.store offset=212
            local.get 9
            local.get 25
            i32.store offset=216
            local.get 9
            local.get 25
            i32.store offset=140
            i32.const 0
            local.set 26
            local.get 9
            local.get 26
            i32.store offset=144
            local.get 9
            i32.load offset=140
            local.set 27
            local.get 9
            i32.load offset=144
            local.set 28
            local.get 9
            local.get 27
            i32.store offset=132
            local.get 9
            local.get 28
            i32.store offset=136
            local.get 9
            i32.load offset=132
            local.set 29
            local.get 9
            i32.load offset=136
            local.set 30
            local.get 9
            local.get 29
            i32.store offset=220
            local.get 9
            local.get 30
            i32.store offset=224
            local.get 9
            local.get 29
            i32.store offset=72
            local.get 9
            local.get 30
            i32.store offset=76
            local.get 9
            i32.load offset=72
            local.set 31
            local.get 9
            i32.load offset=76
            local.set 32
            local.get 9
            local.get 31
            i32.store offset=60
            local.get 9
            local.get 32
            i32.store offset=64
            br 1 (;@2;)
          end
          i32.const 68
          local.set 33
          local.get 9
          local.get 33
          i32.add
          local.set 34
          local.get 34
          local.set 35
          local.get 9
          local.get 35
          i32.store offset=228
          i32.const 44
          local.set 36
          local.get 9
          local.get 36
          i32.add
          local.set 37
          local.get 37
          local.set 38
          local.get 9
          local.get 38
          i32.store offset=232
          local.get 9
          i32.load offset=44
          local.set 39
          local.get 9
          local.get 39
          i32.store offset=236
          local.get 9
          local.get 39
          i32.store offset=148
          local.get 9
          i32.load offset=148
          local.set 40
          i32.const 52
          local.set 41
          local.get 9
          local.get 41
          i32.add
          local.set 42
          local.get 42
          local.set 43
          local.get 9
          local.get 43
          i32.store offset=240
          local.get 9
          i32.load offset=52
          local.set 44
          local.get 9
          local.get 44
          i32.store offset=244
          local.get 9
          local.get 44
          i32.store offset=152
          local.get 9
          i32.load offset=152
          local.set 45
          local.get 40
          local.set 46
          local.get 45
          local.set 47
          local.get 46
          local.get 47
          i32.eq
          local.set 48
          i32.const 1
          local.set 49
          local.get 48
          local.get 49
          i32.and
          local.set 50
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      block ;; label = @9
                        block ;; label = @10
                          local.get 50
                          br_if 0 (;@10;)
                          local.get 9
                          i32.load offset=68
                          local.set 51
                          local.get 9
                          local.get 51
                          i32.store offset=248
                          local.get 9
                          i32.load offset=52
                          local.set 52
                          local.get 9
                          i32.load offset=56
                          local.set 53
                          local.get 9
                          local.get 52
                          i32.store offset=252
                          local.get 9
                          local.get 53
                          i32.store offset=256
                          i32.const 0
                          local.set 54
                          i32.const 8
                          local.set 55
                          local.get 9
                          local.get 55
                          i32.add
                          local.set 56
                          local.get 56
                          local.get 1
                          local.get 52
                          local.get 53
                          local.get 54
                          call $_ZN5alloc5alloc6Global10alloc_impl17h455120c429ef56d2E
                          local.get 9
                          i32.load offset=8
                          local.set 57
                          local.get 9
                          i32.load offset=12
                          local.set 58
                          local.get 9
                          local.get 58
                          i32.store offset=124
                          local.get 9
                          local.get 57
                          i32.store offset=120
                          local.get 9
                          i32.load offset=120
                          local.set 59
                          i32.const 1
                          local.set 60
                          i32.const 0
                          local.set 61
                          local.get 61
                          local.get 60
                          local.get 59
                          select
                          local.set 62
                          local.get 62
                          i32.eqz
                          br_if 1 (;@9;)
                          br 2 (;@8;)
                        end
                        local.get 9
                        i32.load offset=68
                        local.set 63
                        local.get 9
                        local.get 63
                        i32.store offset=296
                        i32.const 44
                        local.set 64
                        local.get 9
                        local.get 64
                        i32.add
                        local.set 65
                        local.get 65
                        local.set 66
                        local.get 9
                        local.get 66
                        i32.store offset=300
                        local.get 9
                        local.get 2
                        i32.store offset=304
                        local.get 9
                        i32.load offset=44
                        local.set 67
                        local.get 9
                        i32.load offset=48
                        local.set 68
                        local.get 9
                        local.get 67
                        i32.store offset=84
                        local.get 9
                        local.get 68
                        i32.store offset=88
                        i32.const 84
                        local.set 69
                        local.get 9
                        local.get 69
                        i32.add
                        local.set 70
                        local.get 70
                        local.set 71
                        local.get 9
                        local.get 71
                        i32.store offset=308
                        local.get 9
                        i32.load offset=88
                        local.set 72
                        i32.const 84
                        local.set 73
                        local.get 9
                        local.get 73
                        i32.add
                        local.set 74
                        local.get 74
                        local.set 75
                        local.get 9
                        local.get 75
                        i32.store offset=312
                        local.get 9
                        i32.load offset=84
                        local.set 76
                        local.get 9
                        local.get 76
                        i32.store offset=316
                        local.get 9
                        local.get 76
                        i32.store offset=156
                        local.get 9
                        i32.load offset=156
                        local.set 77
                        local.get 2
                        local.get 72
                        local.get 77
                        local.get 63
                        call $__rust_realloc
                        local.set 78
                        local.get 9
                        local.get 78
                        i32.store offset=320
                        local.get 78
                        i32.eqz
                        br_if 3 (;@6;)
                        br 4 (;@5;)
                      end
                      local.get 9
                      i32.load offset=120
                      local.set 79
                      local.get 9
                      i32.load offset=124
                      local.set 80
                      local.get 9
                      local.get 79
                      i32.store offset=260
                      local.get 9
                      local.get 80
                      i32.store offset=264
                      local.get 9
                      local.get 79
                      i32.store offset=112
                      local.get 9
                      local.get 80
                      i32.store offset=116
                      br 1 (;@7;)
                    end
                    i32.const 0
                    local.set 81
                    local.get 9
                    local.get 81
                    i32.store offset=112
                  end
                  local.get 9
                  i32.load offset=112
                  local.set 82
                  i32.const 1
                  local.set 83
                  i32.const 0
                  local.set 84
                  local.get 84
                  local.get 83
                  local.get 82
                  select
                  local.set 85
                  block ;; label = @7
                    local.get 85
                    br_if 0 (;@7;)
                    local.get 9
                    i32.load offset=112
                    local.set 86
                    local.get 9
                    i32.load offset=116
                    local.set 87
                    local.get 9
                    local.get 86
                    i32.store offset=268
                    local.get 9
                    local.get 87
                    i32.store offset=272
                    local.get 9
                    local.get 2
                    i32.store offset=276
                    local.get 9
                    local.get 86
                    i32.store offset=280
                    local.get 9
                    local.get 87
                    i32.store offset=284
                    local.get 9
                    local.get 86
                    i32.store offset=288
                    local.get 9
                    local.get 86
                    i32.store offset=180
                    local.get 9
                    i32.load offset=180
                    local.set 88
                    local.get 9
                    local.get 88
                    i32.store offset=292
                    i32.const 0
                    local.set 89
                    local.get 51
                    local.get 89
                    i32.shl
                    local.set 90
                    local.get 88
                    local.get 2
                    local.get 90
                    call $memcpy
                    drop
                    local.get 9
                    i32.load offset=44
                    local.set 91
                    local.get 9
                    i32.load offset=48
                    local.set 92
                    local.get 1
                    local.get 2
                    local.get 91
                    local.get 92
                    call $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17h4bd7376b40e5390dE
                    local.get 9
                    local.get 86
                    i32.store offset=60
                    local.get 9
                    local.get 87
                    i32.store offset=64
                    br 5 (;@2;)
                  end
                  i32.const 0
                  local.set 93
                  local.get 9
                  local.get 93
                  i32.store offset=60
                  br 3 (;@3;)
                end
                i32.const 0
                local.set 94
                local.get 9
                local.get 94
                i32.store offset=100
                br 1 (;@4;)
              end
              local.get 9
              local.get 78
              i32.store offset=160
              local.get 9
              i32.load offset=160
              local.set 95
              local.get 9
              local.get 95
              i32.store offset=100
            end
            local.get 9
            i32.load offset=100
            local.set 96
            i32.const 0
            local.set 97
            i32.const 1
            local.set 98
            local.get 98
            local.get 97
            local.get 96
            select
            local.set 99
            block ;; label = @4
              block ;; label = @5
                local.get 99
                br_if 0 (;@5;)
                i32.const 0
                local.set 100
                local.get 9
                local.get 100
                i32.store offset=96
                br 1 (;@4;)
              end
              local.get 9
              i32.load offset=100
              local.set 101
              local.get 9
              local.get 101
              i32.store offset=324
              local.get 9
              local.get 101
              i32.store offset=96
            end
            local.get 9
            i32.load offset=96
            local.set 102
            i32.const 1
            local.set 103
            i32.const 0
            local.set 104
            local.get 104
            local.get 103
            local.get 102
            select
            local.set 105
            block ;; label = @4
              block ;; label = @5
                local.get 105
                br_if 0 (;@5;)
                local.get 9
                i32.load offset=96
                local.set 106
                local.get 9
                local.get 106
                i32.store offset=328
                local.get 9
                local.get 106
                i32.store offset=92
                br 1 (;@4;)
              end
              i32.const 0
              local.set 107
              local.get 9
              local.get 107
              i32.store offset=92
            end
            local.get 9
            i32.load offset=92
            local.set 108
            i32.const 1
            local.set 109
            i32.const 0
            local.set 110
            local.get 110
            local.get 109
            local.get 108
            select
            local.set 111
            block ;; label = @4
              local.get 111
              br_if 0 (;@4;)
              local.get 9
              i32.load offset=92
              local.set 112
              local.get 9
              local.get 112
              i32.store offset=332
              local.get 9
              local.get 112
              i32.store offset=336
              local.get 9
              local.get 112
              i32.store offset=340
              local.get 9
              local.get 112
              i32.store offset=172
              local.get 9
              local.get 63
              i32.store offset=176
              local.get 9
              i32.load offset=172
              local.set 113
              local.get 9
              i32.load offset=176
              local.set 114
              local.get 9
              local.get 113
              i32.store offset=164
              local.get 9
              local.get 114
              i32.store offset=168
              local.get 9
              i32.load offset=164
              local.set 115
              local.get 9
              i32.load offset=168
              local.set 116
              local.get 9
              local.get 115
              i32.store offset=344
              local.get 9
              local.get 116
              i32.store offset=348
              local.get 9
              local.get 115
              i32.store offset=104
              local.get 9
              local.get 116
              i32.store offset=108
              local.get 9
              i32.load offset=104
              local.set 117
              local.get 9
              i32.load offset=108
              local.set 118
              local.get 9
              local.get 117
              i32.store offset=60
              local.get 9
              local.get 118
              i32.store offset=64
              br 2 (;@2;)
            end
            i32.const 0
            local.set 119
            local.get 9
            local.get 119
            i32.store offset=60
          end
          br 1 (;@1;)
        end
      end
      local.get 9
      i32.load offset=60
      local.set 120
      local.get 9
      i32.load offset=64
      local.set 121
      local.get 0
      local.get 121
      i32.store offset=4
      local.get 0
      local.get 120
      i32.store
      i32.const 352
      local.set 122
      local.get 9
      local.get 122
      i32.add
      local.set 123
      local.get 123
      global.set $__stack_pointer
      return
    )
    (func $_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17he7fd3fa2e46b921aE (;18;) (type 7) (param i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 32
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 1
      i32.store offset=20
      local.get 6
      local.get 2
      i32.store offset=24
      local.get 6
      local.get 3
      i32.store offset=28
      i32.const 0
      local.set 7
      i32.const 8
      local.set 8
      local.get 6
      local.get 8
      i32.add
      local.set 9
      local.get 9
      local.get 1
      local.get 2
      local.get 3
      local.get 7
      call $_ZN5alloc5alloc6Global10alloc_impl17h455120c429ef56d2E
      local.get 6
      i32.load offset=8
      local.set 10
      local.get 6
      i32.load offset=12
      local.set 11
      local.get 0
      local.get 11
      i32.store offset=4
      local.get 0
      local.get 10
      i32.store
      i32.const 32
      local.set 12
      local.get 6
      local.get 12
      i32.add
      local.set 13
      local.get 13
      global.set $__stack_pointer
      return
    )
    (func $_ZN4core6result19Result$LT$T$C$E$GT$7map_err17h4bcadcfc8cbc2ce6E (;19;) (type 7) (param i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 48
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 1
      i32.store offset=20
      local.get 6
      local.get 2
      i32.store offset=24
      local.get 6
      local.get 3
      i32.store offset=32
      i32.const 1
      local.set 7
      local.get 6
      local.get 7
      i32.store8 offset=31
      local.get 6
      i32.load offset=20
      local.set 8
      i32.const 1
      local.set 9
      i32.const 0
      local.set 10
      local.get 10
      local.get 9
      local.get 8
      select
      local.set 11
      block ;; label = @1
        block ;; label = @2
          local.get 11
          br_if 0 (;@2;)
          local.get 6
          i32.load offset=20
          local.set 12
          local.get 6
          i32.load offset=24
          local.set 13
          local.get 6
          local.get 12
          i32.store offset=40
          local.get 6
          local.get 13
          i32.store offset=44
          local.get 0
          local.get 12
          i32.store offset=4
          local.get 0
          local.get 13
          i32.store offset=8
          i32.const 0
          local.set 14
          local.get 0
          local.get 14
          i32.store
          br 1 (;@1;)
        end
        i32.const 0
        local.set 15
        local.get 6
        local.get 15
        i32.store8 offset=31
        i32.const 8
        local.set 16
        local.get 6
        local.get 16
        i32.add
        local.set 17
        local.get 17
        local.get 3
        call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$6shrink28_$u7b$$u7b$closure$u7d$$u7d$17h0c4f54572494c2f2E
        local.get 6
        i32.load offset=12
        local.set 18
        local.get 6
        i32.load offset=8
        local.set 19
        local.get 0
        local.get 19
        i32.store offset=4
        local.get 0
        local.get 18
        i32.store offset=8
        i32.const 1
        local.set 20
        local.get 0
        local.get 20
        i32.store
      end
      local.get 6
      i32.load8_u offset=31
      local.set 21
      i32.const 1
      local.set 22
      local.get 21
      local.get 22
      i32.and
      local.set 23
      block ;; label = @1
        local.get 23
        i32.eqz
        br_if 0 (;@1;)
      end
      i32.const 48
      local.set 24
      local.get 6
      local.get 24
      i32.add
      local.set 25
      local.get 25
      global.set $__stack_pointer
      return
    )
    (func $_ZN4core6result19Result$LT$T$C$E$GT$7map_err17had25ca9954f40b7aE (;20;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 48
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 1
      i32.store offset=12
      local.get 5
      local.get 2
      i32.store offset=16
      i32.const 1
      local.set 6
      local.get 5
      local.get 6
      i32.store8 offset=37
      local.get 5
      i32.load offset=12
      local.set 7
      i32.const -2147483647
      local.set 8
      local.get 7
      local.set 9
      local.get 8
      local.set 10
      local.get 9
      local.get 10
      i32.eq
      local.set 11
      i32.const 0
      local.set 12
      i32.const 1
      local.set 13
      i32.const 1
      local.set 14
      local.get 11
      local.get 14
      i32.and
      local.set 15
      local.get 12
      local.get 13
      local.get 15
      select
      local.set 16
      block ;; label = @1
        block ;; label = @2
          local.get 16
          br_if 0 (;@2;)
          i32.const -2147483647
          local.set 17
          local.get 5
          local.get 17
          i32.store offset=20
          br 1 (;@1;)
        end
        local.get 5
        i32.load offset=12
        local.set 18
        local.get 5
        i32.load offset=16
        local.set 19
        local.get 5
        local.get 18
        i32.store offset=40
        local.get 5
        local.get 19
        i32.store offset=44
        i32.const 0
        local.set 20
        local.get 5
        local.get 20
        i32.store8 offset=37
        local.get 5
        local.get 18
        i32.store offset=28
        local.get 5
        local.get 19
        i32.store offset=32
        local.get 5
        i32.load offset=28
        local.set 21
        local.get 5
        i32.load offset=32
        local.set 22
        local.get 5
        local.get 21
        local.get 22
        call $_ZN5alloc7raw_vec14handle_reserve28_$u7b$$u7b$closure$u7d$$u7d$17h59f4cd3c846e8137E
        local.get 5
        i32.load offset=4
        local.set 23
        local.get 5
        i32.load
        local.set 24
        local.get 5
        local.get 24
        i32.store offset=20
        local.get 5
        local.get 23
        i32.store offset=24
      end
      local.get 5
      i32.load8_u offset=37
      local.set 25
      i32.const 1
      local.set 26
      local.get 25
      local.get 26
      i32.and
      local.set 27
      block ;; label = @1
        local.get 27
        i32.eqz
        br_if 0 (;@1;)
      end
      local.get 5
      i32.load offset=20
      local.set 28
      local.get 5
      i32.load offset=24
      local.set 29
      local.get 0
      local.get 29
      i32.store offset=4
      local.get 0
      local.get 28
      i32.store
      i32.const 48
      local.set 30
      local.get 5
      local.get 30
      i32.add
      local.set 31
      local.get 31
      global.set $__stack_pointer
      return
    )
    (func $_ZN4core3mem6forget17h734bfb586f46e07cE (;21;) (type 0) (param i32 i32)
      (local i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 16
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      local.get 0
      i32.store offset=8
      local.get 4
      local.get 1
      i32.store offset=12
      return
    )
    (func $_ZN4core3fmt9Arguments9new_const17h098141deaf10bf58E (;22;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 48
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 1
      i32.store offset=40
      local.get 5
      local.get 2
      i32.store offset=44
      i32.const 1
      local.set 6
      local.get 2
      local.set 7
      local.get 6
      local.set 8
      local.get 7
      local.get 8
      i32.gt_u
      local.set 9
      i32.const 1
      local.set 10
      local.get 9
      local.get 10
      i32.and
      local.set 11
      block ;; label = @1
        local.get 11
        br_if 0 (;@1;)
        i32.const 0
        local.set 12
        local.get 5
        local.get 12
        i32.store offset=32
        local.get 0
        local.get 1
        i32.store
        local.get 0
        local.get 2
        i32.store offset=4
        local.get 5
        i32.load offset=32
        local.set 13
        local.get 5
        i32.load offset=36
        local.set 14
        local.get 0
        local.get 13
        i32.store offset=16
        local.get 0
        local.get 14
        i32.store offset=20
        i32.const 1049132
        local.set 15
        local.get 0
        local.get 15
        i32.store offset=8
        i32.const 0
        local.set 16
        local.get 0
        local.get 16
        i32.store offset=12
        i32.const 48
        local.set 17
        local.get 5
        local.get 17
        i32.add
        local.set 18
        local.get 18
        global.set $__stack_pointer
        return
      end
      i32.const 8
      local.set 19
      local.get 5
      local.get 19
      i32.add
      local.set 20
      local.get 20
      local.set 21
      i32.const 1049144
      local.set 22
      i32.const 1
      local.set 23
      local.get 21
      local.get 22
      local.get 23
      call $_ZN4core3fmt9Arguments9new_const17h098141deaf10bf58E
      i32.const 8
      local.set 24
      local.get 5
      local.get 24
      i32.add
      local.set 25
      local.get 25
      local.set 26
      i32.const 1049228
      local.set 27
      local.get 26
      local.get 27
      call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
      unreachable
    )
    (func $__rust_alloc (;23;) (type 2) (param i32 i32) (result i32)
      (local i32)
      local.get 0
      local.get 1
      call $__rdl_alloc
      local.set 2
      local.get 2
      return
    )
    (func $__rust_dealloc (;24;) (type 6) (param i32 i32 i32)
      local.get 0
      local.get 1
      local.get 2
      call $__rdl_dealloc
      return
    )
    (func $__rust_realloc (;25;) (type 10) (param i32 i32 i32 i32) (result i32)
      (local i32)
      local.get 0
      local.get 1
      local.get 2
      local.get 3
      call $__rdl_realloc
      local.set 4
      local.get 4
      return
    )
    (func $__rust_alloc_zeroed (;26;) (type 2) (param i32 i32) (result i32)
      (local i32)
      local.get 0
      local.get 1
      call $__rdl_alloc_zeroed
      local.set 2
      local.get 2
      return
    )
    (func $__rust_alloc_error_handler (;27;) (type 0) (param i32 i32)
      local.get 0
      local.get 1
      call $__rg_oom
      return
    )
    (func $_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h7bc483c80bad04b6E (;28;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 16
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      global.set $__stack_pointer
      local.get 4
      local.get 0
      i32.store offset=8
      local.get 4
      local.get 1
      i32.store offset=12
      local.get 0
      i32.load
      local.set 5
      local.get 5
      local.get 1
      call $_ZN4core3fmt3num52_$LT$impl$u20$core..fmt..Debug$u20$for$u20$usize$GT$3fmt17h13efbb46a9ba2ec0E
      local.set 6
      i32.const 1
      local.set 7
      local.get 6
      local.get 7
      i32.and
      local.set 8
      i32.const 16
      local.set 9
      local.get 4
      local.get 9
      i32.add
      local.set 10
      local.get 10
      global.set $__stack_pointer
      local.get 8
      return
    )
    (func $_ZN4core3fmt3num52_$LT$impl$u20$core..fmt..Debug$u20$for$u20$usize$GT$3fmt17h13efbb46a9ba2ec0E (;29;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 16
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      global.set $__stack_pointer
      local.get 4
      local.get 0
      i32.store offset=8
      local.get 4
      local.get 1
      i32.store offset=12
      local.get 1
      i32.load offset=28
      local.set 5
      i32.const 16
      local.set 6
      local.get 5
      local.get 6
      i32.and
      local.set 7
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 7
              br_if 0 (;@4;)
              local.get 1
              i32.load offset=28
              local.set 8
              i32.const 32
              local.set 9
              local.get 8
              local.get 9
              i32.and
              local.set 10
              local.get 10
              i32.eqz
              br_if 1 (;@3;)
              br 2 (;@2;)
            end
            local.get 0
            local.get 1
            call $_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17h3616e10b12449442E
            local.set 11
            i32.const 1
            local.set 12
            local.get 11
            local.get 12
            i32.and
            local.set 13
            local.get 4
            local.get 13
            i32.store8 offset=7
            br 2 (;@1;)
          end
          local.get 0
          local.get 1
          call $_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17hf7c5e72c33d02c47E
          local.set 14
          i32.const 1
          local.set 15
          local.get 14
          local.get 15
          i32.and
          local.set 16
          local.get 4
          local.get 16
          i32.store8 offset=7
          br 1 (;@1;)
        end
        local.get 0
        local.get 1
        call $_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h47738bb070892c53E
        local.set 17
        i32.const 1
        local.set 18
        local.get 17
        local.get 18
        i32.and
        local.set 19
        local.get 4
        local.get 19
        i32.store8 offset=7
      end
      local.get 4
      i32.load8_u offset=7
      local.set 20
      i32.const 1
      local.set 21
      local.get 20
      local.get 21
      i32.and
      local.set 22
      i32.const 16
      local.set 23
      local.get 4
      local.get 23
      i32.add
      local.set 24
      local.get 24
      global.set $__stack_pointer
      local.get 22
      return
    )
    (func $_ZN4core3fmt9Arguments9new_const17h1ec7881ff7509332E (;30;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 48
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 1
      i32.store offset=40
      local.get 5
      local.get 2
      i32.store offset=44
      i32.const 1
      local.set 6
      local.get 2
      local.set 7
      local.get 6
      local.set 8
      local.get 7
      local.get 8
      i32.gt_u
      local.set 9
      i32.const 1
      local.set 10
      local.get 9
      local.get 10
      i32.and
      local.set 11
      block ;; label = @1
        local.get 11
        br_if 0 (;@1;)
        i32.const 0
        local.set 12
        local.get 5
        local.get 12
        i32.store offset=32
        local.get 0
        local.get 1
        i32.store
        local.get 0
        local.get 2
        i32.store offset=4
        local.get 5
        i32.load offset=32
        local.set 13
        local.get 5
        i32.load offset=36
        local.set 14
        local.get 0
        local.get 13
        i32.store offset=16
        local.get 0
        local.get 14
        i32.store offset=20
        i32.const 1049244
        local.set 15
        local.get 0
        local.get 15
        i32.store offset=8
        i32.const 0
        local.set 16
        local.get 0
        local.get 16
        i32.store offset=12
        i32.const 48
        local.set 17
        local.get 5
        local.get 17
        i32.add
        local.set 18
        local.get 18
        global.set $__stack_pointer
        return
      end
      i32.const 8
      local.set 19
      local.get 5
      local.get 19
      i32.add
      local.set 20
      local.get 20
      local.set 21
      i32.const 1049256
      local.set 22
      i32.const 1
      local.set 23
      local.get 21
      local.get 22
      local.get 23
      call $_ZN4core3fmt9Arguments9new_const17h1ec7881ff7509332E
      i32.const 8
      local.set 24
      local.get 5
      local.get 24
      i32.add
      local.set 25
      local.get 25
      local.set 26
      i32.const 1049340
      local.set 27
      local.get 26
      local.get 27
      call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
      unreachable
    )
    (func $_ZN4core3ptr30drop_in_place$LT$$RF$usize$GT$17h47a431ebe5707960E (;31;) (type 5) (param i32)
      (local i32 i32 i32)
      global.get $__stack_pointer
      local.set 1
      i32.const 16
      local.set 2
      local.get 1
      local.get 2
      i32.sub
      local.set 3
      local.get 3
      local.get 0
      i32.store offset=12
      return
    )
    (func $_ZN4core3ptr7mut_ptr31_$LT$impl$u20$$BP$mut$u20$T$GT$7is_null17hc1dbb12882878cecE (;32;) (type 11) (param i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 1
      i32.const 16
      local.set 2
      local.get 1
      local.get 2
      i32.sub
      local.set 3
      local.get 3
      local.get 0
      i32.store offset=8
      local.get 3
      local.get 0
      i32.store offset=12
      i32.const 0
      local.set 4
      local.get 0
      local.set 5
      local.get 4
      local.set 6
      local.get 5
      local.get 6
      i32.eq
      local.set 7
      i32.const 1
      local.set 8
      local.get 7
      local.get 8
      i32.and
      local.set 9
      local.get 9
      return
    )
    (func $_ZN4core5alloc6layout6Layout25from_size_align_unchecked17h106b431bc11ab2ebE (;33;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 16
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      local.get 1
      i32.store offset=8
      local.get 5
      local.get 2
      i32.store offset=12
      local.get 5
      local.get 1
      i32.store offset=4
      local.get 5
      local.get 2
      i32.store
      local.get 5
      i32.load
      local.set 6
      local.get 5
      i32.load offset=4
      local.set 7
      local.get 0
      local.get 7
      i32.store offset=4
      local.get 0
      local.get 6
      i32.store
      return
    )
    (func $_ZN4core9core_arch6wasm3211unreachable17he10b8dff6ee95941E (;34;) (type 3)
      unreachable
      unreachable
    )
    (func $_ZN4core9panicking13assert_failed17h0edb14ca2a2368e9E (;35;) (type 8) (param i32 i32 i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 5
      i32.const 16
      local.set 6
      local.get 5
      local.get 6
      i32.sub
      local.set 7
      local.get 7
      global.set $__stack_pointer
      local.get 7
      local.get 1
      i32.store offset=4
      local.get 7
      local.get 2
      i32.store offset=8
      local.get 7
      local.get 0
      i32.store8 offset=15
      i32.const 4
      local.set 8
      local.get 7
      local.get 8
      i32.add
      local.set 9
      local.get 9
      local.set 10
      i32.const 1049356
      local.set 11
      i32.const 8
      local.set 12
      local.get 7
      local.get 12
      i32.add
      local.set 13
      local.get 13
      local.set 14
      local.get 0
      local.get 10
      local.get 11
      local.get 14
      local.get 11
      local.get 3
      local.get 4
      call $_ZN4core9panicking19assert_failed_inner17h003d4b5b03930769E
      unreachable
    )
    (func $_ZN5alloc5alloc5alloc17hcc0a2211818163d2E (;36;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 48
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      global.set $__stack_pointer
      i32.const 1050477
      local.set 5
      local.get 4
      local.get 5
      i32.store
      i32.const 1050477
      local.set 6
      local.get 4
      local.get 6
      i32.store offset=4
      i32.const 1050477
      local.set 7
      local.get 4
      local.get 7
      i32.store offset=8
      i32.const 1050477
      local.set 8
      local.get 4
      local.get 8
      i32.store offset=12
      i32.const 1050477
      local.set 9
      local.get 4
      local.get 9
      i32.store offset=16
      local.get 4
      local.get 0
      i32.store offset=20
      local.get 4
      local.get 1
      i32.store offset=24
      i32.const 0
      local.set 10
      local.get 10
      i32.load8_u offset=1050477
      local.set 11
      local.get 4
      local.get 11
      i32.store8 offset=35
      i32.const 20
      local.set 12
      local.get 4
      local.get 12
      i32.add
      local.set 13
      local.get 13
      local.set 14
      local.get 4
      local.get 14
      i32.store offset=36
      local.get 4
      i32.load offset=24
      local.set 15
      i32.const 20
      local.set 16
      local.get 4
      local.get 16
      i32.add
      local.set 17
      local.get 17
      local.set 18
      local.get 4
      local.get 18
      i32.store offset=40
      local.get 4
      i32.load offset=20
      local.set 19
      local.get 4
      local.get 19
      i32.store offset=44
      local.get 4
      local.get 19
      i32.store offset=28
      local.get 4
      i32.load offset=28
      local.set 20
      local.get 15
      local.get 20
      call $__rust_alloc
      local.set 21
      i32.const 48
      local.set 22
      local.get 4
      local.get 22
      i32.add
      local.set 23
      local.get 23
      global.set $__stack_pointer
      local.get 21
      return
    )
    (func $_ZN5alloc5alloc7dealloc17h127d5c2a6e3b481dE (;37;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 32
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 1
      i32.store offset=4
      local.get 5
      local.get 2
      i32.store offset=8
      local.get 5
      local.get 0
      i32.store offset=16
      i32.const 4
      local.set 6
      local.get 5
      local.get 6
      i32.add
      local.set 7
      local.get 7
      local.set 8
      local.get 5
      local.get 8
      i32.store offset=20
      local.get 5
      i32.load offset=8
      local.set 9
      i32.const 4
      local.set 10
      local.get 5
      local.get 10
      i32.add
      local.set 11
      local.get 11
      local.set 12
      local.get 5
      local.get 12
      i32.store offset=24
      local.get 5
      i32.load offset=4
      local.set 13
      local.get 5
      local.get 13
      i32.store offset=28
      local.get 5
      local.get 13
      i32.store offset=12
      local.get 5
      i32.load offset=12
      local.set 14
      local.get 0
      local.get 9
      local.get 14
      call $__rust_dealloc
      i32.const 32
      local.set 15
      local.get 5
      local.get 15
      i32.add
      local.set 16
      local.get 16
      global.set $__stack_pointer
      return
    )
    (func $_ZN5alloc5alloc7realloc17hc468765d5706897fE (;38;) (type 10) (param i32 i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 32
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 1
      i32.store
      local.get 6
      local.get 2
      i32.store offset=4
      local.get 6
      local.get 0
      i32.store offset=12
      local.get 6
      local.get 3
      i32.store offset=16
      local.get 6
      local.set 7
      local.get 6
      local.get 7
      i32.store offset=20
      local.get 6
      i32.load offset=4
      local.set 8
      local.get 6
      local.set 9
      local.get 6
      local.get 9
      i32.store offset=24
      local.get 6
      i32.load
      local.set 10
      local.get 6
      local.get 10
      i32.store offset=28
      local.get 6
      local.get 10
      i32.store offset=8
      local.get 6
      i32.load offset=8
      local.set 11
      local.get 0
      local.get 8
      local.get 11
      local.get 3
      call $__rust_realloc
      local.set 12
      i32.const 32
      local.set 13
      local.get 6
      local.get 13
      i32.add
      local.set 14
      local.get 14
      global.set $__stack_pointer
      local.get 12
      return
    )
    (func $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17h9a822d492b59fa1cE (;39;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 2
      i32.const 80
      local.set 3
      local.get 2
      local.get 3
      i32.sub
      local.set 4
      local.get 4
      local.get 1
      i32.store offset=44
      i32.const 0
      local.set 5
      i32.const 1
      local.set 6
      local.get 5
      local.get 6
      i32.and
      local.set 7
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            local.get 7
            br_if 0 (;@3;)
            local.get 1
            i32.load offset=4
            local.set 8
            local.get 8
            br_if 1 (;@2;)
          end
          i32.const 0
          local.set 9
          local.get 0
          local.get 9
          i32.store offset=4
          br 1 (;@1;)
        end
        i32.const 1
        local.set 10
        local.get 4
        local.get 10
        i32.store offset=48
        i32.const 1
        local.set 11
        local.get 4
        local.get 11
        i32.store offset=52
        local.get 1
        i32.load offset=4
        local.set 12
        local.get 4
        local.get 12
        i32.store offset=56
        i32.const 0
        local.set 13
        local.get 12
        local.get 13
        i32.shl
        local.set 14
        local.get 4
        local.get 14
        i32.store offset=60
        local.get 4
        local.get 14
        i32.store offset=16
        i32.const 1
        local.set 15
        local.get 4
        local.get 15
        i32.store offset=12
        local.get 1
        i32.load
        local.set 16
        local.get 4
        local.get 16
        i32.store offset=64
        local.get 4
        local.get 16
        i32.store offset=68
        local.get 4
        local.get 16
        i32.store offset=36
        local.get 4
        i32.load offset=36
        local.set 17
        local.get 4
        local.get 17
        i32.store offset=72
        local.get 4
        local.get 17
        i32.store offset=40
        local.get 4
        i32.load offset=40
        local.set 18
        local.get 4
        local.get 18
        i32.store offset=76
        local.get 4
        local.get 18
        i32.store offset=32
        local.get 4
        i32.load offset=32
        local.set 19
        local.get 4
        local.get 19
        i32.store offset=20
        local.get 4
        i32.load offset=12
        local.set 20
        local.get 4
        i32.load offset=16
        local.set 21
        local.get 4
        local.get 20
        i32.store offset=24
        local.get 4
        local.get 21
        i32.store offset=28
        local.get 4
        i64.load offset=20 align=4
        local.set 22
        local.get 0
        local.get 22
        i64.store align=4
        i32.const 8
        local.set 23
        local.get 0
        local.get 23
        i32.add
        local.set 24
        i32.const 20
        local.set 25
        local.get 4
        local.get 25
        i32.add
        local.set 26
        local.get 26
        local.get 23
        i32.add
        local.set 27
        local.get 27
        i32.load
        local.set 28
        local.get 24
        local.get 28
        i32.store
      end
      return
    )
    (func $_ZN11wit_bindgen2rt14run_ctors_once17h1e4f0d96413fa296E (;40;) (type 3)
      (local i32 i32 i32 i32 i32 i32)
      i32.const 0
      local.set 0
      local.get 0
      i32.load8_u offset=1050478
      local.set 1
      i32.const 1
      local.set 2
      local.get 1
      local.get 2
      i32.and
      local.set 3
      block ;; label = @1
        local.get 3
        br_if 0 (;@1;)
        call $__wasm_call_ctors
        i32.const 1
        local.set 4
        i32.const 0
        local.set 5
        local.get 5
        local.get 4
        i32.store8 offset=1050478
      end
      return
    )
    (func $cabi_realloc (;41;) (type 10) (param i32 i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 i32 i32 i32 i32 i32 i32 i32 i64 i64 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 4
      i32.const 128
      local.set 5
      local.get 4
      local.get 5
      i32.sub
      local.set 6
      local.get 6
      global.set $__stack_pointer
      local.get 6
      local.get 3
      i32.store offset=24
      local.get 6
      local.get 0
      i32.store offset=108
      local.get 6
      local.get 1
      i32.store offset=112
      local.get 6
      local.get 2
      i32.store offset=116
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    local.get 1
                    br_if 0 (;@7;)
                    local.get 6
                    i32.load offset=24
                    local.set 7
                    local.get 7
                    i32.eqz
                    br_if 1 (;@6;)
                    br 2 (;@5;)
                  end
                  i32.const 1
                  local.set 8
                  i32.const 1
                  local.set 9
                  local.get 8
                  local.get 9
                  i32.and
                  local.set 10
                  local.get 10
                  br_if 2 (;@4;)
                  br 3 (;@3;)
                end
                local.get 6
                local.get 2
                i32.store offset=28
                br 4 (;@1;)
              end
              local.get 6
              i32.load offset=24
              local.set 11
              i32.const 8
              local.set 12
              local.get 6
              local.get 12
              i32.add
              local.set 13
              local.get 13
              local.get 11
              local.get 2
              call $_ZN4core5alloc6layout6Layout25from_size_align_unchecked17h106b431bc11ab2ebE
              local.get 6
              i32.load offset=12
              local.set 14
              local.get 6
              i32.load offset=8
              local.set 15
              local.get 6
              local.get 15
              i32.store offset=32
              local.get 6
              local.get 14
              i32.store offset=36
              local.get 6
              i32.load offset=32
              local.set 16
              local.get 6
              i32.load offset=36
              local.set 17
              local.get 16
              local.get 17
              call $_ZN5alloc5alloc5alloc17hcc0a2211818163d2E
              local.set 18
              local.get 6
              local.get 18
              i32.store offset=40
              br 2 (;@2;)
            end
            i32.const 24
            local.set 19
            local.get 6
            local.get 19
            i32.add
            local.set 20
            local.get 20
            local.set 21
            local.get 6
            local.get 21
            i32.store offset=44
            i32.const 1049372
            local.set 22
            local.get 6
            local.get 22
            i32.store offset=48
            local.get 6
            i32.load offset=44
            local.set 23
            local.get 6
            local.get 23
            i32.store offset=120
            local.get 6
            i32.load offset=48
            local.set 24
            local.get 6
            local.get 24
            i32.store offset=124
            local.get 23
            i32.load
            local.set 25
            local.get 24
            i32.load
            local.set 26
            local.get 25
            local.set 27
            local.get 26
            local.set 28
            local.get 27
            local.get 28
            i32.eq
            local.set 29
            i32.const 1
            local.set 30
            local.get 29
            local.get 30
            i32.and
            local.set 31
            local.get 31
            i32.eqz
            br_if 0 (;@3;)
            i32.const 1
            local.set 32
            local.get 6
            local.get 32
            i32.store8 offset=55
            i32.const 84
            local.set 33
            local.get 6
            local.get 33
            i32.add
            local.set 34
            local.get 34
            local.set 35
            i32.const 1049420
            local.set 36
            i32.const 1
            local.set 37
            local.get 35
            local.get 36
            local.get 37
            call $_ZN4core3fmt9Arguments9new_const17h1ec7881ff7509332E
            i32.const 16
            local.set 38
            i32.const 56
            local.set 39
            local.get 6
            local.get 39
            i32.add
            local.set 40
            local.get 40
            local.get 38
            i32.add
            local.set 41
            i32.const 84
            local.set 42
            local.get 6
            local.get 42
            i32.add
            local.set 43
            local.get 43
            local.get 38
            i32.add
            local.set 44
            local.get 44
            i64.load align=4
            local.set 45
            local.get 41
            local.get 45
            i64.store
            i32.const 8
            local.set 46
            i32.const 56
            local.set 47
            local.get 6
            local.get 47
            i32.add
            local.set 48
            local.get 48
            local.get 46
            i32.add
            local.set 49
            i32.const 84
            local.set 50
            local.get 6
            local.get 50
            i32.add
            local.set 51
            local.get 51
            local.get 46
            i32.add
            local.set 52
            local.get 52
            i64.load align=4
            local.set 53
            local.get 49
            local.get 53
            i64.store
            local.get 6
            i64.load offset=84 align=4
            local.set 54
            local.get 6
            local.get 54
            i64.store offset=56
            local.get 6
            i32.load8_u offset=55
            local.set 55
            i32.const 56
            local.set 56
            local.get 6
            local.get 56
            i32.add
            local.set 57
            local.get 57
            local.set 58
            i32.const 1049524
            local.set 59
            local.get 55
            local.get 23
            local.get 24
            local.get 58
            local.get 59
            call $_ZN4core9panicking13assert_failed17h0edb14ca2a2368e9E
            unreachable
          end
          i32.const 16
          local.set 60
          local.get 6
          local.get 60
          i32.add
          local.set 61
          local.get 61
          local.get 1
          local.get 2
          call $_ZN4core5alloc6layout6Layout25from_size_align_unchecked17h106b431bc11ab2ebE
          local.get 6
          i32.load offset=20
          local.set 62
          local.get 6
          i32.load offset=16
          local.set 63
          local.get 6
          local.get 63
          i32.store offset=32
          local.get 6
          local.get 62
          i32.store offset=36
          local.get 6
          i32.load offset=32
          local.set 64
          local.get 6
          i32.load offset=36
          local.set 65
          local.get 6
          i32.load offset=24
          local.set 66
          local.get 0
          local.get 64
          local.get 65
          local.get 66
          call $_ZN5alloc5alloc7realloc17hc468765d5706897fE
          local.set 67
          local.get 6
          local.get 67
          i32.store offset=40
        end
        local.get 6
        i32.load offset=40
        local.set 68
        local.get 68
        call $_ZN4core3ptr7mut_ptr31_$LT$impl$u20$$BP$mut$u20$T$GT$7is_null17hc1dbb12882878cecE
        local.set 69
        i32.const 1
        local.set 70
        local.get 69
        local.get 70
        i32.and
        local.set 71
        block ;; label = @2
          local.get 71
          br_if 0 (;@2;)
          local.get 6
          i32.load offset=40
          local.set 72
          local.get 6
          local.get 72
          i32.store offset=28
          br 1 (;@1;)
        end
        i32.const 1
        local.set 73
        i32.const 1
        local.set 74
        local.get 73
        local.get 74
        i32.and
        local.set 75
        block ;; label = @2
          local.get 75
          br_if 0 (;@2;)
          call $_ZN4core9core_arch6wasm3211unreachable17he10b8dff6ee95941E
          unreachable
        end
        local.get 6
        i32.load offset=32
        local.set 76
        local.get 6
        i32.load offset=36
        local.set 77
        local.get 76
        local.get 77
        call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
        unreachable
      end
      local.get 6
      i32.load offset=28
      local.set 78
      i32.const 128
      local.set 79
      local.get 6
      local.get 79
      i32.add
      local.set 80
      local.get 80
      global.set $__stack_pointer
      local.get 78
      return
    )
    (func $_ZN11wit_bindgen2rt7dealloc17h183b5fdc6aa132c8E (;42;) (type 6) (param i32 i32 i32)
      (local i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      local.set 3
      i32.const 32
      local.set 4
      local.get 3
      local.get 4
      i32.sub
      local.set 5
      local.get 5
      global.set $__stack_pointer
      local.get 5
      local.get 0
      i32.store offset=12
      local.get 5
      local.get 1
      i32.store offset=16
      local.get 5
      local.get 2
      i32.store offset=20
      block ;; label = @1
        local.get 1
        i32.eqz
        br_if 0 (;@1;)
        local.get 5
        local.get 1
        local.get 2
        call $_ZN4core5alloc6layout6Layout25from_size_align_unchecked17h106b431bc11ab2ebE
        local.get 5
        i32.load offset=4
        local.set 6
        local.get 5
        i32.load
        local.set 7
        local.get 5
        local.get 7
        i32.store offset=24
        local.get 5
        local.get 6
        i32.store offset=28
        local.get 0
        local.get 7
        local.get 6
        call $_ZN5alloc5alloc7dealloc17h127d5c2a6e3b481dE
      end
      i32.const 32
      local.set 8
      local.get 5
      local.get 8
      i32.add
      local.set 9
      local.get 9
      global.set $__stack_pointer
      return
    )
    (func $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17h5c94a5461dcd884dE (;43;) (type 0) (param i32 i32)
      local.get 0
      i64.const -8454237885602762920
      i64.store offset=8
      local.get 0
      i64.const 3944000453910847919
      i64.store
    )
    (func $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17h8c09ce30cfb56d1cE (;44;) (type 0) (param i32 i32)
      local.get 0
      i64.const -163230743173927068
      i64.store offset=8
      local.get 0
      i64.const -4493808902380553279
      i64.store
    )
    (func $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17hc894c8c4ad4a3830E (;45;) (type 0) (param i32 i32)
      local.get 0
      i64.const -3777529136054271931
      i64.store offset=8
      local.get 0
      i64.const 2295361781758797333
      i64.store
    )
    (func $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve21do_reserve_and_handle17h7b12e1ef062559f5E (;46;) (type 6) (param i32 i32 i32)
      (local i32 i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      block ;; label = @1
        block ;; label = @2
          local.get 1
          local.get 2
          i32.add
          local.tee 2
          local.get 1
          i32.lt_u
          br_if 0 (;@2;)
          local.get 0
          i32.load offset=4
          local.tee 1
          i32.const 1
          i32.shl
          local.tee 4
          local.get 2
          local.get 4
          local.get 2
          i32.gt_u
          select
          local.tee 2
          i32.const 8
          local.get 2
          i32.const 8
          i32.gt_u
          select
          local.tee 2
          i32.const -1
          i32.xor
          i32.const 31
          i32.shr_u
          local.set 4
          block ;; label = @3
            block ;; label = @4
              local.get 1
              br_if 0 (;@4;)
              local.get 3
              i32.const 0
              i32.store offset=24
              br 1 (;@3;)
            end
            local.get 3
            local.get 1
            i32.store offset=28
            local.get 3
            i32.const 1
            i32.store offset=24
            local.get 3
            local.get 0
            i32.load
            i32.store offset=20
          end
          local.get 3
          i32.const 8
          i32.add
          local.get 4
          local.get 2
          local.get 3
          i32.const 20
          i32.add
          call $_ZN5alloc7raw_vec11finish_grow17he9b0ed653cd2ddbdE
          local.get 3
          i32.load offset=12
          local.set 1
          block ;; label = @3
            local.get 3
            i32.load offset=8
            br_if 0 (;@3;)
            local.get 0
            local.get 2
            i32.store offset=4
            local.get 0
            local.get 1
            i32.store
            br 2 (;@1;)
          end
          local.get 1
          i32.const -2147483647
          i32.eq
          br_if 1 (;@1;)
          local.get 1
          i32.eqz
          br_if 0 (;@2;)
          local.get 1
          local.get 3
          i32.const 16
          i32.add
          i32.load
          call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
          unreachable
        end
        call $_ZN5alloc7raw_vec17capacity_overflow17hfd18578094e5282cE
        unreachable
      end
      local.get 3
      i32.const 32
      i32.add
      global.set $__stack_pointer
    )
    (func $_ZN4core3fmt5Write9write_fmt17hffd94433da6ef0e4E (;47;) (type 2) (param i32 i32) (result i32)
      local.get 0
      i32.const 1049584
      local.get 1
      call $_ZN4core3fmt5write17h42a704582454311cE
    )
    (func $_ZN4core3ptr122drop_in_place$LT$$RF$alloc..boxed..Box$LT$dyn$u20$core..error..Error$u2b$core..marker..Sync$u2b$core..marker..Send$GT$$GT$17h1180b14201b07337E (;48;) (type 5) (param i32))
    (func $_ZN4core3ptr29drop_in_place$LT$$LP$$RP$$GT$17h78062830dc5d549cE (;49;) (type 5) (param i32))
    (func $_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17hc0da2817d3a744a6E (;50;) (type 5) (param i32)
      (local i32)
      block ;; label = @1
        local.get 0
        i32.load offset=4
        local.tee 1
        i32.eqz
        br_if 0 (;@1;)
        local.get 0
        i32.load
        local.get 1
        i32.const 1
        call $__rust_dealloc
      end
    )
    (func $_ZN4core3ptr77drop_in_place$LT$std..panicking..begin_panic_handler..FormatStringPayload$GT$17h192372df2cc52b39E (;51;) (type 5) (param i32)
      (local i32)
      block ;; label = @1
        local.get 0
        i32.load offset=4
        local.tee 1
        i32.eqz
        br_if 0 (;@1;)
        local.get 0
        i32.const 8
        i32.add
        i32.load
        local.tee 0
        i32.eqz
        br_if 0 (;@1;)
        local.get 1
        local.get 0
        i32.const 1
        call $__rust_dealloc
      end
    )
    (func $_ZN58_$LT$alloc..string..String$u20$as$u20$core..fmt..Write$GT$10write_char17h063160badd7077ccE (;52;) (type 2) (param i32 i32) (result i32)
      (local i32 i32)
      global.get $__stack_pointer
      i32.const 16
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 1
              i32.const 128
              i32.lt_u
              br_if 0 (;@4;)
              local.get 2
              i32.const 0
              i32.store offset=12
              local.get 1
              i32.const 2048
              i32.lt_u
              br_if 1 (;@3;)
              block ;; label = @5
                local.get 1
                i32.const 65536
                i32.ge_u
                br_if 0 (;@5;)
                local.get 2
                local.get 1
                i32.const 63
                i32.and
                i32.const 128
                i32.or
                i32.store8 offset=14
                local.get 2
                local.get 1
                i32.const 12
                i32.shr_u
                i32.const 224
                i32.or
                i32.store8 offset=12
                local.get 2
                local.get 1
                i32.const 6
                i32.shr_u
                i32.const 63
                i32.and
                i32.const 128
                i32.or
                i32.store8 offset=13
                i32.const 3
                local.set 1
                br 3 (;@2;)
              end
              local.get 2
              local.get 1
              i32.const 63
              i32.and
              i32.const 128
              i32.or
              i32.store8 offset=15
              local.get 2
              local.get 1
              i32.const 6
              i32.shr_u
              i32.const 63
              i32.and
              i32.const 128
              i32.or
              i32.store8 offset=14
              local.get 2
              local.get 1
              i32.const 12
              i32.shr_u
              i32.const 63
              i32.and
              i32.const 128
              i32.or
              i32.store8 offset=13
              local.get 2
              local.get 1
              i32.const 18
              i32.shr_u
              i32.const 7
              i32.and
              i32.const 240
              i32.or
              i32.store8 offset=12
              i32.const 4
              local.set 1
              br 2 (;@2;)
            end
            block ;; label = @4
              local.get 0
              i32.load offset=8
              local.tee 3
              local.get 0
              i32.load offset=4
              i32.ne
              br_if 0 (;@4;)
              local.get 0
              local.get 3
              call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$16reserve_for_push17h5a55bed17c35e9efE
              local.get 0
              i32.load offset=8
              local.set 3
            end
            local.get 0
            local.get 3
            i32.const 1
            i32.add
            i32.store offset=8
            local.get 0
            i32.load
            local.get 3
            i32.add
            local.get 1
            i32.store8
            br 2 (;@1;)
          end
          local.get 2
          local.get 1
          i32.const 63
          i32.and
          i32.const 128
          i32.or
          i32.store8 offset=13
          local.get 2
          local.get 1
          i32.const 6
          i32.shr_u
          i32.const 192
          i32.or
          i32.store8 offset=12
          i32.const 2
          local.set 1
        end
        block ;; label = @2
          local.get 0
          i32.load offset=4
          local.get 0
          i32.load offset=8
          local.tee 3
          i32.sub
          local.get 1
          i32.ge_u
          br_if 0 (;@2;)
          local.get 0
          local.get 3
          local.get 1
          call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve21do_reserve_and_handle17h7b12e1ef062559f5E
          local.get 0
          i32.load offset=8
          local.set 3
        end
        local.get 0
        i32.load
        local.get 3
        i32.add
        local.get 2
        i32.const 12
        i32.add
        local.get 1
        call $memcpy
        drop
        local.get 0
        local.get 3
        local.get 1
        i32.add
        i32.store offset=8
      end
      local.get 2
      i32.const 16
      i32.add
      global.set $__stack_pointer
      i32.const 0
    )
    (func $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$16reserve_for_push17h5a55bed17c35e9efE (;53;) (type 0) (param i32 i32)
      (local i32 i32 i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      block ;; label = @1
        block ;; label = @2
          local.get 1
          i32.const 1
          i32.add
          local.tee 1
          i32.eqz
          br_if 0 (;@2;)
          local.get 0
          i32.load offset=4
          local.tee 3
          i32.const 1
          i32.shl
          local.tee 4
          local.get 1
          local.get 4
          local.get 1
          i32.gt_u
          select
          local.tee 1
          i32.const 8
          local.get 1
          i32.const 8
          i32.gt_u
          select
          local.tee 1
          i32.const -1
          i32.xor
          i32.const 31
          i32.shr_u
          local.set 4
          block ;; label = @3
            block ;; label = @4
              local.get 3
              br_if 0 (;@4;)
              local.get 2
              i32.const 0
              i32.store offset=24
              br 1 (;@3;)
            end
            local.get 2
            local.get 3
            i32.store offset=28
            local.get 2
            i32.const 1
            i32.store offset=24
            local.get 2
            local.get 0
            i32.load
            i32.store offset=20
          end
          local.get 2
          i32.const 8
          i32.add
          local.get 4
          local.get 1
          local.get 2
          i32.const 20
          i32.add
          call $_ZN5alloc7raw_vec11finish_grow17he9b0ed653cd2ddbdE
          local.get 2
          i32.load offset=12
          local.set 3
          block ;; label = @3
            local.get 2
            i32.load offset=8
            br_if 0 (;@3;)
            local.get 0
            local.get 1
            i32.store offset=4
            local.get 0
            local.get 3
            i32.store
            br 2 (;@1;)
          end
          local.get 3
          i32.const -2147483647
          i32.eq
          br_if 1 (;@1;)
          local.get 3
          i32.eqz
          br_if 0 (;@2;)
          local.get 3
          local.get 2
          i32.const 16
          i32.add
          i32.load
          call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
          unreachable
        end
        call $_ZN5alloc7raw_vec17capacity_overflow17hfd18578094e5282cE
        unreachable
      end
      local.get 2
      i32.const 32
      i32.add
      global.set $__stack_pointer
    )
    (func $_ZN58_$LT$alloc..string..String$u20$as$u20$core..fmt..Write$GT$9write_str17hf9053c3a4494653aE (;54;) (type 1) (param i32 i32 i32) (result i32)
      (local i32)
      block ;; label = @1
        local.get 0
        i32.load offset=4
        local.get 0
        i32.load offset=8
        local.tee 3
        i32.sub
        local.get 2
        i32.ge_u
        br_if 0 (;@1;)
        local.get 0
        local.get 3
        local.get 2
        call $_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve21do_reserve_and_handle17h7b12e1ef062559f5E
        local.get 0
        i32.load offset=8
        local.set 3
      end
      local.get 0
      i32.load
      local.get 3
      i32.add
      local.get 1
      local.get 2
      call $memcpy
      drop
      local.get 0
      local.get 3
      local.get 2
      i32.add
      i32.store offset=8
      i32.const 0
    )
    (func $_ZN5alloc7raw_vec11finish_grow17he9b0ed653cd2ddbdE (;55;) (type 7) (param i32 i32 i32 i32)
      (local i32)
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            local.get 1
            i32.eqz
            br_if 0 (;@3;)
            local.get 2
            i32.const -1
            i32.le_s
            br_if 1 (;@2;)
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  local.get 3
                  i32.load offset=4
                  i32.eqz
                  br_if 0 (;@6;)
                  block ;; label = @7
                    local.get 3
                    i32.const 8
                    i32.add
                    i32.load
                    local.tee 4
                    br_if 0 (;@7;)
                    block ;; label = @8
                      local.get 2
                      br_if 0 (;@8;)
                      local.get 1
                      local.set 3
                      br 4 (;@4;)
                    end
                    i32.const 0
                    i32.load8_u offset=1050477
                    drop
                    br 2 (;@5;)
                  end
                  local.get 3
                  i32.load
                  local.get 4
                  local.get 1
                  local.get 2
                  call $__rust_realloc
                  local.set 3
                  br 2 (;@4;)
                end
                block ;; label = @6
                  local.get 2
                  br_if 0 (;@6;)
                  local.get 1
                  local.set 3
                  br 2 (;@4;)
                end
                i32.const 0
                i32.load8_u offset=1050477
                drop
              end
              local.get 2
              local.get 1
              call $__rust_alloc
              local.set 3
            end
            block ;; label = @4
              local.get 3
              i32.eqz
              br_if 0 (;@4;)
              local.get 0
              local.get 3
              i32.store offset=4
              local.get 0
              i32.const 8
              i32.add
              local.get 2
              i32.store
              local.get 0
              i32.const 0
              i32.store
              return
            end
            local.get 0
            local.get 1
            i32.store offset=4
            local.get 0
            i32.const 8
            i32.add
            local.get 2
            i32.store
            br 2 (;@1;)
          end
          local.get 0
          i32.const 0
          i32.store offset=4
          local.get 0
          i32.const 8
          i32.add
          local.get 2
          i32.store
          br 1 (;@1;)
        end
        local.get 0
        i32.const 0
        i32.store offset=4
      end
      local.get 0
      i32.const 1
      i32.store
    )
    (func $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE (;56;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32)
      local.get 0
      i32.load offset=12
      local.set 2
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            local.get 1
            i32.const 256
            i32.lt_u
            br_if 0 (;@3;)
            local.get 0
            i32.load offset=24
            local.set 3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  local.get 2
                  local.get 0
                  i32.ne
                  br_if 0 (;@6;)
                  local.get 0
                  i32.const 20
                  i32.const 16
                  local.get 0
                  i32.const 20
                  i32.add
                  local.tee 2
                  i32.load
                  local.tee 4
                  select
                  i32.add
                  i32.load
                  local.tee 1
                  br_if 1 (;@5;)
                  i32.const 0
                  local.set 2
                  br 2 (;@4;)
                end
                local.get 0
                i32.load offset=8
                local.tee 1
                local.get 2
                i32.store offset=12
                local.get 2
                local.get 1
                i32.store offset=8
                br 1 (;@4;)
              end
              local.get 2
              local.get 0
              i32.const 16
              i32.add
              local.get 4
              select
              local.set 4
              loop ;; label = @5
                local.get 4
                local.set 5
                local.get 1
                local.tee 2
                i32.const 20
                i32.add
                local.tee 1
                local.get 2
                i32.const 16
                i32.add
                local.get 1
                i32.load
                local.tee 1
                select
                local.set 4
                local.get 2
                i32.const 20
                i32.const 16
                local.get 1
                select
                i32.add
                i32.load
                local.tee 1
                br_if 0 (;@5;)
              end
              local.get 5
              i32.const 0
              i32.store
            end
            local.get 3
            i32.eqz
            br_if 2 (;@1;)
            block ;; label = @4
              local.get 0
              i32.load offset=28
              i32.const 2
              i32.shl
              i32.const 1050504
              i32.add
              local.tee 1
              i32.load
              local.get 0
              i32.eq
              br_if 0 (;@4;)
              local.get 3
              i32.const 16
              i32.const 20
              local.get 3
              i32.load offset=16
              local.get 0
              i32.eq
              select
              i32.add
              local.get 2
              i32.store
              local.get 2
              i32.eqz
              br_if 3 (;@1;)
              br 2 (;@2;)
            end
            local.get 1
            local.get 2
            i32.store
            local.get 2
            br_if 1 (;@2;)
            i32.const 0
            i32.const 0
            i32.load offset=1050916
            i32.const -2
            local.get 0
            i32.load offset=28
            i32.rotl
            i32.and
            i32.store offset=1050916
            br 2 (;@1;)
          end
          block ;; label = @3
            local.get 2
            local.get 0
            i32.load offset=8
            local.tee 4
            i32.eq
            br_if 0 (;@3;)
            local.get 4
            local.get 2
            i32.store offset=12
            local.get 2
            local.get 4
            i32.store offset=8
            return
          end
          i32.const 0
          i32.const 0
          i32.load offset=1050912
          i32.const -2
          local.get 1
          i32.const 3
          i32.shr_u
          i32.rotl
          i32.and
          i32.store offset=1050912
          return
        end
        local.get 2
        local.get 3
        i32.store offset=24
        block ;; label = @2
          local.get 0
          i32.load offset=16
          local.tee 1
          i32.eqz
          br_if 0 (;@2;)
          local.get 2
          local.get 1
          i32.store offset=16
          local.get 1
          local.get 2
          i32.store offset=24
        end
        local.get 0
        i32.const 20
        i32.add
        i32.load
        local.tee 1
        i32.eqz
        br_if 0 (;@1;)
        local.get 2
        i32.const 20
        i32.add
        local.get 1
        i32.store
        local.get 1
        local.get 2
        i32.store offset=24
        return
      end
    )
    (func $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$13dispose_chunk17h8b98108d6dc2a901E (;57;) (type 0) (param i32 i32)
      (local i32 i32)
      local.get 0
      local.get 1
      i32.add
      local.set 2
      block ;; label = @1
        block ;; label = @2
          local.get 0
          i32.load offset=4
          local.tee 3
          i32.const 1
          i32.and
          br_if 0 (;@2;)
          local.get 3
          i32.const 3
          i32.and
          i32.eqz
          br_if 1 (;@1;)
          local.get 0
          i32.load
          local.tee 3
          local.get 1
          i32.add
          local.set 1
          block ;; label = @3
            local.get 0
            local.get 3
            i32.sub
            local.tee 0
            i32.const 0
            i32.load offset=1050928
            i32.ne
            br_if 0 (;@3;)
            local.get 2
            i32.load offset=4
            i32.const 3
            i32.and
            i32.const 3
            i32.ne
            br_if 1 (;@2;)
            i32.const 0
            local.get 1
            i32.store offset=1050920
            local.get 2
            local.get 2
            i32.load offset=4
            i32.const -2
            i32.and
            i32.store offset=4
            local.get 0
            local.get 1
            i32.const 1
            i32.or
            i32.store offset=4
            local.get 2
            local.get 1
            i32.store
            return
          end
          local.get 0
          local.get 3
          call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE
        end
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                local.get 2
                i32.load offset=4
                local.tee 3
                i32.const 2
                i32.and
                br_if 0 (;@5;)
                local.get 2
                i32.const 0
                i32.load offset=1050932
                i32.eq
                br_if 2 (;@3;)
                local.get 2
                i32.const 0
                i32.load offset=1050928
                i32.eq
                br_if 3 (;@2;)
                local.get 2
                local.get 3
                i32.const -8
                i32.and
                local.tee 3
                call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE
                local.get 0
                local.get 3
                local.get 1
                i32.add
                local.tee 1
                i32.const 1
                i32.or
                i32.store offset=4
                local.get 0
                local.get 1
                i32.add
                local.get 1
                i32.store
                local.get 0
                i32.const 0
                i32.load offset=1050928
                i32.ne
                br_if 1 (;@4;)
                i32.const 0
                local.get 1
                i32.store offset=1050920
                return
              end
              local.get 2
              local.get 3
              i32.const -2
              i32.and
              i32.store offset=4
              local.get 0
              local.get 1
              i32.const 1
              i32.or
              i32.store offset=4
              local.get 0
              local.get 1
              i32.add
              local.get 1
              i32.store
            end
            block ;; label = @4
              local.get 1
              i32.const 256
              i32.lt_u
              br_if 0 (;@4;)
              local.get 0
              local.get 1
              call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$18insert_large_chunk17h21e3abcf61006a52E
              br 3 (;@1;)
            end
            local.get 1
            i32.const -8
            i32.and
            i32.const 1050648
            i32.add
            local.set 2
            block ;; label = @4
              block ;; label = @5
                i32.const 0
                i32.load offset=1050912
                local.tee 3
                i32.const 1
                local.get 1
                i32.const 3
                i32.shr_u
                i32.shl
                local.tee 1
                i32.and
                br_if 0 (;@5;)
                i32.const 0
                local.get 3
                local.get 1
                i32.or
                i32.store offset=1050912
                local.get 2
                local.set 1
                br 1 (;@4;)
              end
              local.get 2
              i32.load offset=8
              local.set 1
            end
            local.get 2
            local.get 0
            i32.store offset=8
            local.get 1
            local.get 0
            i32.store offset=12
            local.get 0
            local.get 2
            i32.store offset=12
            local.get 0
            local.get 1
            i32.store offset=8
            return
          end
          i32.const 0
          local.get 0
          i32.store offset=1050932
          i32.const 0
          i32.const 0
          i32.load offset=1050924
          local.get 1
          i32.add
          local.tee 1
          i32.store offset=1050924
          local.get 0
          local.get 1
          i32.const 1
          i32.or
          i32.store offset=4
          local.get 0
          i32.const 0
          i32.load offset=1050928
          i32.ne
          br_if 1 (;@1;)
          i32.const 0
          i32.const 0
          i32.store offset=1050920
          i32.const 0
          i32.const 0
          i32.store offset=1050928
          return
        end
        i32.const 0
        local.get 0
        i32.store offset=1050928
        i32.const 0
        i32.const 0
        i32.load offset=1050920
        local.get 1
        i32.add
        local.tee 1
        i32.store offset=1050920
        local.get 0
        local.get 1
        i32.const 1
        i32.or
        i32.store offset=4
        local.get 0
        local.get 1
        i32.add
        local.get 1
        i32.store
        return
      end
    )
    (func $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$18insert_large_chunk17h21e3abcf61006a52E (;58;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32)
      i32.const 0
      local.set 2
      block ;; label = @1
        local.get 1
        i32.const 256
        i32.lt_u
        br_if 0 (;@1;)
        i32.const 31
        local.set 2
        local.get 1
        i32.const 16777215
        i32.gt_u
        br_if 0 (;@1;)
        local.get 1
        i32.const 6
        local.get 1
        i32.const 8
        i32.shr_u
        i32.clz
        local.tee 2
        i32.sub
        i32.shr_u
        i32.const 1
        i32.and
        local.get 2
        i32.const 1
        i32.shl
        i32.sub
        i32.const 62
        i32.add
        local.set 2
      end
      local.get 0
      i64.const 0
      i64.store offset=16 align=4
      local.get 0
      local.get 2
      i32.store offset=28
      local.get 2
      i32.const 2
      i32.shl
      i32.const 1050504
      i32.add
      local.set 3
      block ;; label = @1
        block ;; label = @2
          i32.const 0
          i32.load offset=1050916
          local.tee 4
          i32.const 1
          local.get 2
          i32.shl
          local.tee 5
          i32.and
          br_if 0 (;@2;)
          i32.const 0
          local.get 4
          local.get 5
          i32.or
          i32.store offset=1050916
          local.get 3
          local.get 0
          i32.store
          local.get 0
          local.get 3
          i32.store offset=24
          br 1 (;@1;)
        end
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 3
              i32.load
              local.tee 4
              i32.load offset=4
              i32.const -8
              i32.and
              local.get 1
              i32.ne
              br_if 0 (;@4;)
              local.get 4
              local.set 2
              br 1 (;@3;)
            end
            local.get 1
            i32.const 0
            i32.const 25
            local.get 2
            i32.const 1
            i32.shr_u
            i32.sub
            local.get 2
            i32.const 31
            i32.eq
            select
            i32.shl
            local.set 3
            loop ;; label = @4
              local.get 4
              local.get 3
              i32.const 29
              i32.shr_u
              i32.const 4
              i32.and
              i32.add
              i32.const 16
              i32.add
              local.tee 5
              i32.load
              local.tee 2
              i32.eqz
              br_if 2 (;@2;)
              local.get 3
              i32.const 1
              i32.shl
              local.set 3
              local.get 2
              local.set 4
              local.get 2
              i32.load offset=4
              i32.const -8
              i32.and
              local.get 1
              i32.ne
              br_if 0 (;@4;)
            end
          end
          local.get 2
          i32.load offset=8
          local.tee 3
          local.get 0
          i32.store offset=12
          local.get 2
          local.get 0
          i32.store offset=8
          local.get 0
          i32.const 0
          i32.store offset=24
          local.get 0
          local.get 2
          i32.store offset=12
          local.get 0
          local.get 3
          i32.store offset=8
          return
        end
        local.get 5
        local.get 0
        i32.store
        local.get 0
        local.get 4
        i32.store offset=24
      end
      local.get 0
      local.get 0
      i32.store offset=12
      local.get 0
      local.get 0
      i32.store offset=8
    )
    (func $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$4free17h9b9b5b55abd73bc8E (;59;) (type 5) (param i32)
      (local i32 i32 i32 i32 i32)
      local.get 0
      i32.const -8
      i32.add
      local.tee 1
      local.get 0
      i32.const -4
      i32.add
      i32.load
      local.tee 2
      i32.const -8
      i32.and
      local.tee 0
      i32.add
      local.set 3
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 2
              i32.const 1
              i32.and
              br_if 0 (;@4;)
              local.get 2
              i32.const 3
              i32.and
              i32.eqz
              br_if 1 (;@3;)
              local.get 1
              i32.load
              local.tee 2
              local.get 0
              i32.add
              local.set 0
              block ;; label = @5
                local.get 1
                local.get 2
                i32.sub
                local.tee 1
                i32.const 0
                i32.load offset=1050928
                i32.ne
                br_if 0 (;@5;)
                local.get 3
                i32.load offset=4
                i32.const 3
                i32.and
                i32.const 3
                i32.ne
                br_if 1 (;@4;)
                i32.const 0
                local.get 0
                i32.store offset=1050920
                local.get 3
                local.get 3
                i32.load offset=4
                i32.const -2
                i32.and
                i32.store offset=4
                local.get 1
                local.get 0
                i32.const 1
                i32.or
                i32.store offset=4
                local.get 3
                local.get 0
                i32.store
                return
              end
              local.get 1
              local.get 2
              call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE
            end
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  local.get 3
                  i32.load offset=4
                  local.tee 2
                  i32.const 2
                  i32.and
                  br_if 0 (;@6;)
                  local.get 3
                  i32.const 0
                  i32.load offset=1050932
                  i32.eq
                  br_if 2 (;@4;)
                  local.get 3
                  i32.const 0
                  i32.load offset=1050928
                  i32.eq
                  br_if 5 (;@1;)
                  local.get 3
                  local.get 2
                  i32.const -8
                  i32.and
                  local.tee 2
                  call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE
                  local.get 1
                  local.get 2
                  local.get 0
                  i32.add
                  local.tee 0
                  i32.const 1
                  i32.or
                  i32.store offset=4
                  local.get 1
                  local.get 0
                  i32.add
                  local.get 0
                  i32.store
                  local.get 1
                  i32.const 0
                  i32.load offset=1050928
                  i32.ne
                  br_if 1 (;@5;)
                  i32.const 0
                  local.get 0
                  i32.store offset=1050920
                  return
                end
                local.get 3
                local.get 2
                i32.const -2
                i32.and
                i32.store offset=4
                local.get 1
                local.get 0
                i32.const 1
                i32.or
                i32.store offset=4
                local.get 1
                local.get 0
                i32.add
                local.get 0
                i32.store
              end
              local.get 0
              i32.const 256
              i32.lt_u
              br_if 2 (;@2;)
              local.get 1
              local.get 0
              call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$18insert_large_chunk17h21e3abcf61006a52E
              i32.const 0
              local.set 1
              i32.const 0
              i32.const 0
              i32.load offset=1050952
              i32.const -1
              i32.add
              local.tee 0
              i32.store offset=1050952
              local.get 0
              br_if 1 (;@3;)
              block ;; label = @5
                i32.const 0
                i32.load offset=1050640
                local.tee 0
                i32.eqz
                br_if 0 (;@5;)
                i32.const 0
                local.set 1
                loop ;; label = @6
                  local.get 1
                  i32.const 1
                  i32.add
                  local.set 1
                  local.get 0
                  i32.load offset=8
                  local.tee 0
                  br_if 0 (;@6;)
                end
              end
              i32.const 0
              local.get 1
              i32.const 4095
              local.get 1
              i32.const 4095
              i32.gt_u
              select
              i32.store offset=1050952
              return
            end
            i32.const 0
            local.get 1
            i32.store offset=1050932
            i32.const 0
            i32.const 0
            i32.load offset=1050924
            local.get 0
            i32.add
            local.tee 0
            i32.store offset=1050924
            local.get 1
            local.get 0
            i32.const 1
            i32.or
            i32.store offset=4
            block ;; label = @4
              local.get 1
              i32.const 0
              i32.load offset=1050928
              i32.ne
              br_if 0 (;@4;)
              i32.const 0
              i32.const 0
              i32.store offset=1050920
              i32.const 0
              i32.const 0
              i32.store offset=1050928
            end
            local.get 0
            i32.const 0
            i32.load offset=1050944
            local.tee 4
            i32.le_u
            br_if 0 (;@3;)
            i32.const 0
            i32.load offset=1050932
            local.tee 3
            i32.eqz
            br_if 0 (;@3;)
            i32.const 0
            local.set 1
            block ;; label = @4
              i32.const 0
              i32.load offset=1050924
              local.tee 5
              i32.const 41
              i32.lt_u
              br_if 0 (;@4;)
              i32.const 1050632
              local.set 0
              loop ;; label = @5
                block ;; label = @6
                  local.get 0
                  i32.load
                  local.tee 2
                  local.get 3
                  i32.gt_u
                  br_if 0 (;@6;)
                  local.get 2
                  local.get 0
                  i32.load offset=4
                  i32.add
                  local.get 3
                  i32.gt_u
                  br_if 2 (;@4;)
                end
                local.get 0
                i32.load offset=8
                local.tee 0
                br_if 0 (;@5;)
              end
            end
            block ;; label = @4
              i32.const 0
              i32.load offset=1050640
              local.tee 0
              i32.eqz
              br_if 0 (;@4;)
              i32.const 0
              local.set 1
              loop ;; label = @5
                local.get 1
                i32.const 1
                i32.add
                local.set 1
                local.get 0
                i32.load offset=8
                local.tee 0
                br_if 0 (;@5;)
              end
            end
            i32.const 0
            local.get 1
            i32.const 4095
            local.get 1
            i32.const 4095
            i32.gt_u
            select
            i32.store offset=1050952
            local.get 5
            local.get 4
            i32.le_u
            br_if 0 (;@3;)
            i32.const 0
            i32.const -1
            i32.store offset=1050944
          end
          return
        end
        local.get 0
        i32.const -8
        i32.and
        i32.const 1050648
        i32.add
        local.set 3
        block ;; label = @2
          block ;; label = @3
            i32.const 0
            i32.load offset=1050912
            local.tee 2
            i32.const 1
            local.get 0
            i32.const 3
            i32.shr_u
            i32.shl
            local.tee 0
            i32.and
            br_if 0 (;@3;)
            i32.const 0
            local.get 2
            local.get 0
            i32.or
            i32.store offset=1050912
            local.get 3
            local.set 0
            br 1 (;@2;)
          end
          local.get 3
          i32.load offset=8
          local.set 0
        end
        local.get 3
        local.get 1
        i32.store offset=8
        local.get 0
        local.get 1
        i32.store offset=12
        local.get 1
        local.get 3
        i32.store offset=12
        local.get 1
        local.get 0
        i32.store offset=8
        return
      end
      i32.const 0
      local.get 1
      i32.store offset=1050928
      i32.const 0
      i32.const 0
      i32.load offset=1050920
      local.get 0
      i32.add
      local.tee 0
      i32.store offset=1050920
      local.get 1
      local.get 0
      i32.const 1
      i32.or
      i32.store offset=4
      local.get 1
      local.get 0
      i32.add
      local.get 0
      i32.store
    )
    (func $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$6malloc17hbf148db4c9dd20cdE (;60;) (type 11) (param i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i64)
      global.get $__stack_pointer
      i32.const 16
      i32.sub
      local.tee 1
      global.set $__stack_pointer
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      local.get 0
                      i32.const 245
                      i32.lt_u
                      br_if 0 (;@8;)
                      i32.const 0
                      local.set 2
                      local.get 0
                      i32.const -65587
                      i32.ge_u
                      br_if 7 (;@1;)
                      local.get 0
                      i32.const 11
                      i32.add
                      local.tee 0
                      i32.const -8
                      i32.and
                      local.set 3
                      i32.const 0
                      i32.load offset=1050916
                      local.tee 4
                      i32.eqz
                      br_if 4 (;@4;)
                      i32.const 0
                      local.set 5
                      block ;; label = @9
                        local.get 3
                        i32.const 256
                        i32.lt_u
                        br_if 0 (;@9;)
                        i32.const 31
                        local.set 5
                        local.get 3
                        i32.const 16777215
                        i32.gt_u
                        br_if 0 (;@9;)
                        local.get 3
                        i32.const 6
                        local.get 0
                        i32.const 8
                        i32.shr_u
                        i32.clz
                        local.tee 0
                        i32.sub
                        i32.shr_u
                        i32.const 1
                        i32.and
                        local.get 0
                        i32.const 1
                        i32.shl
                        i32.sub
                        i32.const 62
                        i32.add
                        local.set 5
                      end
                      i32.const 0
                      local.get 3
                      i32.sub
                      local.set 2
                      block ;; label = @9
                        local.get 5
                        i32.const 2
                        i32.shl
                        i32.const 1050504
                        i32.add
                        i32.load
                        local.tee 6
                        br_if 0 (;@9;)
                        i32.const 0
                        local.set 0
                        i32.const 0
                        local.set 7
                        br 2 (;@7;)
                      end
                      i32.const 0
                      local.set 0
                      local.get 3
                      i32.const 0
                      i32.const 25
                      local.get 5
                      i32.const 1
                      i32.shr_u
                      i32.sub
                      local.get 5
                      i32.const 31
                      i32.eq
                      select
                      i32.shl
                      local.set 8
                      i32.const 0
                      local.set 7
                      loop ;; label = @9
                        block ;; label = @10
                          local.get 6
                          i32.load offset=4
                          i32.const -8
                          i32.and
                          local.tee 9
                          local.get 3
                          i32.lt_u
                          br_if 0 (;@10;)
                          local.get 9
                          local.get 3
                          i32.sub
                          local.tee 9
                          local.get 2
                          i32.ge_u
                          br_if 0 (;@10;)
                          local.get 9
                          local.set 2
                          local.get 6
                          local.set 7
                          local.get 9
                          br_if 0 (;@10;)
                          i32.const 0
                          local.set 2
                          local.get 6
                          local.set 7
                          local.get 6
                          local.set 0
                          br 4 (;@6;)
                        end
                        local.get 6
                        i32.const 20
                        i32.add
                        i32.load
                        local.tee 9
                        local.get 0
                        local.get 9
                        local.get 6
                        local.get 8
                        i32.const 29
                        i32.shr_u
                        i32.const 4
                        i32.and
                        i32.add
                        i32.const 16
                        i32.add
                        i32.load
                        local.tee 6
                        i32.ne
                        select
                        local.get 0
                        local.get 9
                        select
                        local.set 0
                        local.get 8
                        i32.const 1
                        i32.shl
                        local.set 8
                        local.get 6
                        i32.eqz
                        br_if 2 (;@7;)
                        br 0 (;@9;)
                      end
                    end
                    block ;; label = @8
                      i32.const 0
                      i32.load offset=1050912
                      local.tee 7
                      i32.const 16
                      local.get 0
                      i32.const 11
                      i32.add
                      i32.const -8
                      i32.and
                      local.get 0
                      i32.const 11
                      i32.lt_u
                      select
                      local.tee 3
                      i32.const 3
                      i32.shr_u
                      local.tee 2
                      i32.shr_u
                      local.tee 0
                      i32.const 3
                      i32.and
                      i32.eqz
                      br_if 0 (;@8;)
                      block ;; label = @9
                        block ;; label = @10
                          local.get 0
                          i32.const -1
                          i32.xor
                          i32.const 1
                          i32.and
                          local.get 2
                          i32.add
                          local.tee 3
                          i32.const 3
                          i32.shl
                          local.tee 0
                          i32.const 1050648
                          i32.add
                          local.tee 2
                          local.get 0
                          i32.const 1050656
                          i32.add
                          i32.load
                          local.tee 0
                          i32.load offset=8
                          local.tee 6
                          i32.eq
                          br_if 0 (;@10;)
                          local.get 6
                          local.get 2
                          i32.store offset=12
                          local.get 2
                          local.get 6
                          i32.store offset=8
                          br 1 (;@9;)
                        end
                        i32.const 0
                        local.get 7
                        i32.const -2
                        local.get 3
                        i32.rotl
                        i32.and
                        i32.store offset=1050912
                      end
                      local.get 0
                      i32.const 8
                      i32.add
                      local.set 2
                      local.get 0
                      local.get 3
                      i32.const 3
                      i32.shl
                      local.tee 3
                      i32.const 3
                      i32.or
                      i32.store offset=4
                      local.get 0
                      local.get 3
                      i32.add
                      local.tee 0
                      local.get 0
                      i32.load offset=4
                      i32.const 1
                      i32.or
                      i32.store offset=4
                      br 7 (;@1;)
                    end
                    local.get 3
                    i32.const 0
                    i32.load offset=1050920
                    i32.le_u
                    br_if 3 (;@4;)
                    block ;; label = @8
                      block ;; label = @9
                        block ;; label = @10
                          local.get 0
                          br_if 0 (;@10;)
                          i32.const 0
                          i32.load offset=1050916
                          local.tee 0
                          i32.eqz
                          br_if 6 (;@4;)
                          local.get 0
                          i32.ctz
                          i32.const 2
                          i32.shl
                          i32.const 1050504
                          i32.add
                          i32.load
                          local.tee 6
                          i32.load offset=4
                          i32.const -8
                          i32.and
                          local.get 3
                          i32.sub
                          local.set 2
                          local.get 6
                          local.set 7
                          loop ;; label = @11
                            block ;; label = @12
                              local.get 6
                              i32.load offset=16
                              local.tee 0
                              br_if 0 (;@12;)
                              local.get 6
                              i32.const 20
                              i32.add
                              i32.load
                              local.tee 0
                              br_if 0 (;@12;)
                              local.get 7
                              i32.load offset=24
                              local.set 5
                              block ;; label = @13
                                block ;; label = @14
                                  block ;; label = @15
                                    local.get 7
                                    i32.load offset=12
                                    local.tee 0
                                    local.get 7
                                    i32.ne
                                    br_if 0 (;@15;)
                                    local.get 7
                                    i32.const 20
                                    i32.const 16
                                    local.get 7
                                    i32.const 20
                                    i32.add
                                    local.tee 0
                                    i32.load
                                    local.tee 8
                                    select
                                    i32.add
                                    i32.load
                                    local.tee 6
                                    br_if 1 (;@14;)
                                    i32.const 0
                                    local.set 0
                                    br 2 (;@13;)
                                  end
                                  local.get 7
                                  i32.load offset=8
                                  local.tee 6
                                  local.get 0
                                  i32.store offset=12
                                  local.get 0
                                  local.get 6
                                  i32.store offset=8
                                  br 1 (;@13;)
                                end
                                local.get 0
                                local.get 7
                                i32.const 16
                                i32.add
                                local.get 8
                                select
                                local.set 8
                                loop ;; label = @14
                                  local.get 8
                                  local.set 9
                                  local.get 6
                                  local.tee 0
                                  i32.const 20
                                  i32.add
                                  local.tee 6
                                  local.get 0
                                  i32.const 16
                                  i32.add
                                  local.get 6
                                  i32.load
                                  local.tee 6
                                  select
                                  local.set 8
                                  local.get 0
                                  i32.const 20
                                  i32.const 16
                                  local.get 6
                                  select
                                  i32.add
                                  i32.load
                                  local.tee 6
                                  br_if 0 (;@14;)
                                end
                                local.get 9
                                i32.const 0
                                i32.store
                              end
                              local.get 5
                              i32.eqz
                              br_if 4 (;@8;)
                              block ;; label = @13
                                local.get 7
                                i32.load offset=28
                                i32.const 2
                                i32.shl
                                i32.const 1050504
                                i32.add
                                local.tee 6
                                i32.load
                                local.get 7
                                i32.eq
                                br_if 0 (;@13;)
                                local.get 5
                                i32.const 16
                                i32.const 20
                                local.get 5
                                i32.load offset=16
                                local.get 7
                                i32.eq
                                select
                                i32.add
                                local.get 0
                                i32.store
                                local.get 0
                                i32.eqz
                                br_if 5 (;@8;)
                                br 4 (;@9;)
                              end
                              local.get 6
                              local.get 0
                              i32.store
                              local.get 0
                              br_if 3 (;@9;)
                              i32.const 0
                              i32.const 0
                              i32.load offset=1050916
                              i32.const -2
                              local.get 7
                              i32.load offset=28
                              i32.rotl
                              i32.and
                              i32.store offset=1050916
                              br 4 (;@8;)
                            end
                            local.get 0
                            i32.load offset=4
                            i32.const -8
                            i32.and
                            local.get 3
                            i32.sub
                            local.tee 6
                            local.get 2
                            local.get 6
                            local.get 2
                            i32.lt_u
                            local.tee 6
                            select
                            local.set 2
                            local.get 0
                            local.get 7
                            local.get 6
                            select
                            local.set 7
                            local.get 0
                            local.set 6
                            br 0 (;@11;)
                          end
                        end
                        block ;; label = @10
                          block ;; label = @11
                            local.get 0
                            local.get 2
                            i32.shl
                            i32.const 2
                            local.get 2
                            i32.shl
                            local.tee 0
                            i32.const 0
                            local.get 0
                            i32.sub
                            i32.or
                            i32.and
                            i32.ctz
                            local.tee 2
                            i32.const 3
                            i32.shl
                            local.tee 0
                            i32.const 1050648
                            i32.add
                            local.tee 6
                            local.get 0
                            i32.const 1050656
                            i32.add
                            i32.load
                            local.tee 0
                            i32.load offset=8
                            local.tee 8
                            i32.eq
                            br_if 0 (;@11;)
                            local.get 8
                            local.get 6
                            i32.store offset=12
                            local.get 6
                            local.get 8
                            i32.store offset=8
                            br 1 (;@10;)
                          end
                          i32.const 0
                          local.get 7
                          i32.const -2
                          local.get 2
                          i32.rotl
                          i32.and
                          i32.store offset=1050912
                        end
                        local.get 0
                        local.get 3
                        i32.const 3
                        i32.or
                        i32.store offset=4
                        local.get 0
                        local.get 3
                        i32.add
                        local.tee 8
                        local.get 2
                        i32.const 3
                        i32.shl
                        local.tee 2
                        local.get 3
                        i32.sub
                        local.tee 6
                        i32.const 1
                        i32.or
                        i32.store offset=4
                        local.get 0
                        local.get 2
                        i32.add
                        local.get 6
                        i32.store
                        block ;; label = @10
                          i32.const 0
                          i32.load offset=1050920
                          local.tee 7
                          i32.eqz
                          br_if 0 (;@10;)
                          local.get 7
                          i32.const -8
                          i32.and
                          i32.const 1050648
                          i32.add
                          local.set 2
                          i32.const 0
                          i32.load offset=1050928
                          local.set 3
                          block ;; label = @11
                            block ;; label = @12
                              i32.const 0
                              i32.load offset=1050912
                              local.tee 9
                              i32.const 1
                              local.get 7
                              i32.const 3
                              i32.shr_u
                              i32.shl
                              local.tee 7
                              i32.and
                              br_if 0 (;@12;)
                              i32.const 0
                              local.get 9
                              local.get 7
                              i32.or
                              i32.store offset=1050912
                              local.get 2
                              local.set 7
                              br 1 (;@11;)
                            end
                            local.get 2
                            i32.load offset=8
                            local.set 7
                          end
                          local.get 2
                          local.get 3
                          i32.store offset=8
                          local.get 7
                          local.get 3
                          i32.store offset=12
                          local.get 3
                          local.get 2
                          i32.store offset=12
                          local.get 3
                          local.get 7
                          i32.store offset=8
                        end
                        local.get 0
                        i32.const 8
                        i32.add
                        local.set 2
                        i32.const 0
                        local.get 8
                        i32.store offset=1050928
                        i32.const 0
                        local.get 6
                        i32.store offset=1050920
                        br 8 (;@1;)
                      end
                      local.get 0
                      local.get 5
                      i32.store offset=24
                      block ;; label = @9
                        local.get 7
                        i32.load offset=16
                        local.tee 6
                        i32.eqz
                        br_if 0 (;@9;)
                        local.get 0
                        local.get 6
                        i32.store offset=16
                        local.get 6
                        local.get 0
                        i32.store offset=24
                      end
                      local.get 7
                      i32.const 20
                      i32.add
                      i32.load
                      local.tee 6
                      i32.eqz
                      br_if 0 (;@8;)
                      local.get 0
                      i32.const 20
                      i32.add
                      local.get 6
                      i32.store
                      local.get 6
                      local.get 0
                      i32.store offset=24
                    end
                    block ;; label = @8
                      block ;; label = @9
                        block ;; label = @10
                          local.get 2
                          i32.const 16
                          i32.lt_u
                          br_if 0 (;@10;)
                          local.get 7
                          local.get 3
                          i32.const 3
                          i32.or
                          i32.store offset=4
                          local.get 7
                          local.get 3
                          i32.add
                          local.tee 3
                          local.get 2
                          i32.const 1
                          i32.or
                          i32.store offset=4
                          local.get 3
                          local.get 2
                          i32.add
                          local.get 2
                          i32.store
                          i32.const 0
                          i32.load offset=1050920
                          local.tee 8
                          i32.eqz
                          br_if 1 (;@9;)
                          local.get 8
                          i32.const -8
                          i32.and
                          i32.const 1050648
                          i32.add
                          local.set 6
                          i32.const 0
                          i32.load offset=1050928
                          local.set 0
                          block ;; label = @11
                            block ;; label = @12
                              i32.const 0
                              i32.load offset=1050912
                              local.tee 9
                              i32.const 1
                              local.get 8
                              i32.const 3
                              i32.shr_u
                              i32.shl
                              local.tee 8
                              i32.and
                              br_if 0 (;@12;)
                              i32.const 0
                              local.get 9
                              local.get 8
                              i32.or
                              i32.store offset=1050912
                              local.get 6
                              local.set 8
                              br 1 (;@11;)
                            end
                            local.get 6
                            i32.load offset=8
                            local.set 8
                          end
                          local.get 6
                          local.get 0
                          i32.store offset=8
                          local.get 8
                          local.get 0
                          i32.store offset=12
                          local.get 0
                          local.get 6
                          i32.store offset=12
                          local.get 0
                          local.get 8
                          i32.store offset=8
                          br 1 (;@9;)
                        end
                        local.get 7
                        local.get 2
                        local.get 3
                        i32.add
                        local.tee 0
                        i32.const 3
                        i32.or
                        i32.store offset=4
                        local.get 7
                        local.get 0
                        i32.add
                        local.tee 0
                        local.get 0
                        i32.load offset=4
                        i32.const 1
                        i32.or
                        i32.store offset=4
                        br 1 (;@8;)
                      end
                      i32.const 0
                      local.get 3
                      i32.store offset=1050928
                      i32.const 0
                      local.get 2
                      i32.store offset=1050920
                    end
                    local.get 7
                    i32.const 8
                    i32.add
                    local.set 2
                    br 6 (;@1;)
                  end
                  block ;; label = @7
                    local.get 0
                    local.get 7
                    i32.or
                    br_if 0 (;@7;)
                    i32.const 0
                    local.set 7
                    i32.const 2
                    local.get 5
                    i32.shl
                    local.tee 0
                    i32.const 0
                    local.get 0
                    i32.sub
                    i32.or
                    local.get 4
                    i32.and
                    local.tee 0
                    i32.eqz
                    br_if 3 (;@4;)
                    local.get 0
                    i32.ctz
                    i32.const 2
                    i32.shl
                    i32.const 1050504
                    i32.add
                    i32.load
                    local.set 0
                  end
                  local.get 0
                  i32.eqz
                  br_if 1 (;@5;)
                end
                loop ;; label = @6
                  local.get 0
                  local.get 7
                  local.get 0
                  i32.load offset=4
                  i32.const -8
                  i32.and
                  local.tee 6
                  local.get 3
                  i32.sub
                  local.tee 9
                  local.get 2
                  i32.lt_u
                  local.tee 5
                  select
                  local.set 4
                  local.get 6
                  local.get 3
                  i32.lt_u
                  local.set 8
                  local.get 9
                  local.get 2
                  local.get 5
                  select
                  local.set 9
                  block ;; label = @7
                    local.get 0
                    i32.load offset=16
                    local.tee 6
                    br_if 0 (;@7;)
                    local.get 0
                    i32.const 20
                    i32.add
                    i32.load
                    local.set 6
                  end
                  local.get 7
                  local.get 4
                  local.get 8
                  select
                  local.set 7
                  local.get 2
                  local.get 9
                  local.get 8
                  select
                  local.set 2
                  local.get 6
                  local.set 0
                  local.get 6
                  br_if 0 (;@6;)
                end
              end
              local.get 7
              i32.eqz
              br_if 0 (;@4;)
              block ;; label = @5
                i32.const 0
                i32.load offset=1050920
                local.tee 0
                local.get 3
                i32.lt_u
                br_if 0 (;@5;)
                local.get 2
                local.get 0
                local.get 3
                i32.sub
                i32.ge_u
                br_if 1 (;@4;)
              end
              local.get 7
              i32.load offset=24
              local.set 5
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    local.get 7
                    i32.load offset=12
                    local.tee 0
                    local.get 7
                    i32.ne
                    br_if 0 (;@7;)
                    local.get 7
                    i32.const 20
                    i32.const 16
                    local.get 7
                    i32.const 20
                    i32.add
                    local.tee 0
                    i32.load
                    local.tee 8
                    select
                    i32.add
                    i32.load
                    local.tee 6
                    br_if 1 (;@6;)
                    i32.const 0
                    local.set 0
                    br 2 (;@5;)
                  end
                  local.get 7
                  i32.load offset=8
                  local.tee 6
                  local.get 0
                  i32.store offset=12
                  local.get 0
                  local.get 6
                  i32.store offset=8
                  br 1 (;@5;)
                end
                local.get 0
                local.get 7
                i32.const 16
                i32.add
                local.get 8
                select
                local.set 8
                loop ;; label = @6
                  local.get 8
                  local.set 9
                  local.get 6
                  local.tee 0
                  i32.const 20
                  i32.add
                  local.tee 6
                  local.get 0
                  i32.const 16
                  i32.add
                  local.get 6
                  i32.load
                  local.tee 6
                  select
                  local.set 8
                  local.get 0
                  i32.const 20
                  i32.const 16
                  local.get 6
                  select
                  i32.add
                  i32.load
                  local.tee 6
                  br_if 0 (;@6;)
                end
                local.get 9
                i32.const 0
                i32.store
              end
              local.get 5
              i32.eqz
              br_if 2 (;@2;)
              block ;; label = @5
                local.get 7
                i32.load offset=28
                i32.const 2
                i32.shl
                i32.const 1050504
                i32.add
                local.tee 6
                i32.load
                local.get 7
                i32.eq
                br_if 0 (;@5;)
                local.get 5
                i32.const 16
                i32.const 20
                local.get 5
                i32.load offset=16
                local.get 7
                i32.eq
                select
                i32.add
                local.get 0
                i32.store
                local.get 0
                i32.eqz
                br_if 3 (;@2;)
                br 2 (;@3;)
              end
              local.get 6
              local.get 0
              i32.store
              local.get 0
              br_if 1 (;@3;)
              i32.const 0
              i32.const 0
              i32.load offset=1050916
              i32.const -2
              local.get 7
              i32.load offset=28
              i32.rotl
              i32.and
              i32.store offset=1050916
              br 2 (;@2;)
            end
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      block ;; label = @9
                        i32.const 0
                        i32.load offset=1050920
                        local.tee 0
                        local.get 3
                        i32.ge_u
                        br_if 0 (;@9;)
                        block ;; label = @10
                          i32.const 0
                          i32.load offset=1050924
                          local.tee 0
                          local.get 3
                          i32.gt_u
                          br_if 0 (;@10;)
                          local.get 1
                          i32.const 4
                          i32.add
                          i32.const 1050956
                          local.get 3
                          i32.const 65583
                          i32.add
                          i32.const -65536
                          i32.and
                          call $_ZN61_$LT$dlmalloc..sys..System$u20$as$u20$dlmalloc..Allocator$GT$5alloc17he84e5c996fe9815fE
                          block ;; label = @11
                            local.get 1
                            i32.load offset=4
                            local.tee 7
                            br_if 0 (;@11;)
                            i32.const 0
                            local.set 2
                            br 10 (;@1;)
                          end
                          local.get 1
                          i32.load offset=12
                          local.set 5
                          i32.const 0
                          i32.const 0
                          i32.load offset=1050936
                          local.get 1
                          i32.load offset=8
                          local.tee 9
                          i32.add
                          local.tee 0
                          i32.store offset=1050936
                          i32.const 0
                          i32.const 0
                          i32.load offset=1050940
                          local.tee 2
                          local.get 0
                          local.get 2
                          local.get 0
                          i32.gt_u
                          select
                          i32.store offset=1050940
                          block ;; label = @11
                            block ;; label = @12
                              block ;; label = @13
                                i32.const 0
                                i32.load offset=1050932
                                local.tee 2
                                i32.eqz
                                br_if 0 (;@13;)
                                i32.const 1050632
                                local.set 0
                                loop ;; label = @14
                                  local.get 7
                                  local.get 0
                                  i32.load
                                  local.tee 6
                                  local.get 0
                                  i32.load offset=4
                                  local.tee 8
                                  i32.add
                                  i32.eq
                                  br_if 2 (;@12;)
                                  local.get 0
                                  i32.load offset=8
                                  local.tee 0
                                  br_if 0 (;@14;)
                                  br 3 (;@11;)
                                end
                              end
                              block ;; label = @13
                                block ;; label = @14
                                  i32.const 0
                                  i32.load offset=1050948
                                  local.tee 0
                                  i32.eqz
                                  br_if 0 (;@14;)
                                  local.get 7
                                  local.get 0
                                  i32.ge_u
                                  br_if 1 (;@13;)
                                end
                                i32.const 0
                                local.get 7
                                i32.store offset=1050948
                              end
                              i32.const 0
                              i32.const 4095
                              i32.store offset=1050952
                              i32.const 0
                              local.get 5
                              i32.store offset=1050644
                              i32.const 0
                              local.get 9
                              i32.store offset=1050636
                              i32.const 0
                              local.get 7
                              i32.store offset=1050632
                              i32.const 0
                              i32.const 1050648
                              i32.store offset=1050660
                              i32.const 0
                              i32.const 1050656
                              i32.store offset=1050668
                              i32.const 0
                              i32.const 1050648
                              i32.store offset=1050656
                              i32.const 0
                              i32.const 1050664
                              i32.store offset=1050676
                              i32.const 0
                              i32.const 1050656
                              i32.store offset=1050664
                              i32.const 0
                              i32.const 1050672
                              i32.store offset=1050684
                              i32.const 0
                              i32.const 1050664
                              i32.store offset=1050672
                              i32.const 0
                              i32.const 1050680
                              i32.store offset=1050692
                              i32.const 0
                              i32.const 1050672
                              i32.store offset=1050680
                              i32.const 0
                              i32.const 1050688
                              i32.store offset=1050700
                              i32.const 0
                              i32.const 1050680
                              i32.store offset=1050688
                              i32.const 0
                              i32.const 1050696
                              i32.store offset=1050708
                              i32.const 0
                              i32.const 1050688
                              i32.store offset=1050696
                              i32.const 0
                              i32.const 1050704
                              i32.store offset=1050716
                              i32.const 0
                              i32.const 1050696
                              i32.store offset=1050704
                              i32.const 0
                              i32.const 1050712
                              i32.store offset=1050724
                              i32.const 0
                              i32.const 1050704
                              i32.store offset=1050712
                              i32.const 0
                              i32.const 1050712
                              i32.store offset=1050720
                              i32.const 0
                              i32.const 1050720
                              i32.store offset=1050732
                              i32.const 0
                              i32.const 1050720
                              i32.store offset=1050728
                              i32.const 0
                              i32.const 1050728
                              i32.store offset=1050740
                              i32.const 0
                              i32.const 1050728
                              i32.store offset=1050736
                              i32.const 0
                              i32.const 1050736
                              i32.store offset=1050748
                              i32.const 0
                              i32.const 1050736
                              i32.store offset=1050744
                              i32.const 0
                              i32.const 1050744
                              i32.store offset=1050756
                              i32.const 0
                              i32.const 1050744
                              i32.store offset=1050752
                              i32.const 0
                              i32.const 1050752
                              i32.store offset=1050764
                              i32.const 0
                              i32.const 1050752
                              i32.store offset=1050760
                              i32.const 0
                              i32.const 1050760
                              i32.store offset=1050772
                              i32.const 0
                              i32.const 1050760
                              i32.store offset=1050768
                              i32.const 0
                              i32.const 1050768
                              i32.store offset=1050780
                              i32.const 0
                              i32.const 1050768
                              i32.store offset=1050776
                              i32.const 0
                              i32.const 1050776
                              i32.store offset=1050788
                              i32.const 0
                              i32.const 1050784
                              i32.store offset=1050796
                              i32.const 0
                              i32.const 1050776
                              i32.store offset=1050784
                              i32.const 0
                              i32.const 1050792
                              i32.store offset=1050804
                              i32.const 0
                              i32.const 1050784
                              i32.store offset=1050792
                              i32.const 0
                              i32.const 1050800
                              i32.store offset=1050812
                              i32.const 0
                              i32.const 1050792
                              i32.store offset=1050800
                              i32.const 0
                              i32.const 1050808
                              i32.store offset=1050820
                              i32.const 0
                              i32.const 1050800
                              i32.store offset=1050808
                              i32.const 0
                              i32.const 1050816
                              i32.store offset=1050828
                              i32.const 0
                              i32.const 1050808
                              i32.store offset=1050816
                              i32.const 0
                              i32.const 1050824
                              i32.store offset=1050836
                              i32.const 0
                              i32.const 1050816
                              i32.store offset=1050824
                              i32.const 0
                              i32.const 1050832
                              i32.store offset=1050844
                              i32.const 0
                              i32.const 1050824
                              i32.store offset=1050832
                              i32.const 0
                              i32.const 1050840
                              i32.store offset=1050852
                              i32.const 0
                              i32.const 1050832
                              i32.store offset=1050840
                              i32.const 0
                              i32.const 1050848
                              i32.store offset=1050860
                              i32.const 0
                              i32.const 1050840
                              i32.store offset=1050848
                              i32.const 0
                              i32.const 1050856
                              i32.store offset=1050868
                              i32.const 0
                              i32.const 1050848
                              i32.store offset=1050856
                              i32.const 0
                              i32.const 1050864
                              i32.store offset=1050876
                              i32.const 0
                              i32.const 1050856
                              i32.store offset=1050864
                              i32.const 0
                              i32.const 1050872
                              i32.store offset=1050884
                              i32.const 0
                              i32.const 1050864
                              i32.store offset=1050872
                              i32.const 0
                              i32.const 1050880
                              i32.store offset=1050892
                              i32.const 0
                              i32.const 1050872
                              i32.store offset=1050880
                              i32.const 0
                              i32.const 1050888
                              i32.store offset=1050900
                              i32.const 0
                              i32.const 1050880
                              i32.store offset=1050888
                              i32.const 0
                              i32.const 1050896
                              i32.store offset=1050908
                              i32.const 0
                              i32.const 1050888
                              i32.store offset=1050896
                              i32.const 0
                              local.get 7
                              i32.const 15
                              i32.add
                              i32.const -8
                              i32.and
                              local.tee 0
                              i32.const -8
                              i32.add
                              local.tee 2
                              i32.store offset=1050932
                              i32.const 0
                              i32.const 1050896
                              i32.store offset=1050904
                              i32.const 0
                              local.get 7
                              local.get 0
                              i32.sub
                              local.get 9
                              i32.const -40
                              i32.add
                              local.tee 0
                              i32.add
                              i32.const 8
                              i32.add
                              local.tee 6
                              i32.store offset=1050924
                              local.get 2
                              local.get 6
                              i32.const 1
                              i32.or
                              i32.store offset=4
                              local.get 7
                              local.get 0
                              i32.add
                              i32.const 40
                              i32.store offset=4
                              i32.const 0
                              i32.const 2097152
                              i32.store offset=1050944
                              br 8 (;@4;)
                            end
                            local.get 2
                            local.get 7
                            i32.ge_u
                            br_if 0 (;@11;)
                            local.get 6
                            local.get 2
                            i32.gt_u
                            br_if 0 (;@11;)
                            local.get 0
                            i32.load offset=12
                            local.tee 6
                            i32.const 1
                            i32.and
                            br_if 0 (;@11;)
                            local.get 6
                            i32.const 1
                            i32.shr_u
                            local.get 5
                            i32.eq
                            br_if 3 (;@8;)
                          end
                          i32.const 0
                          i32.const 0
                          i32.load offset=1050948
                          local.tee 0
                          local.get 7
                          local.get 7
                          local.get 0
                          i32.gt_u
                          select
                          i32.store offset=1050948
                          local.get 7
                          local.get 9
                          i32.add
                          local.set 6
                          i32.const 1050632
                          local.set 0
                          block ;; label = @11
                            block ;; label = @12
                              block ;; label = @13
                                loop ;; label = @14
                                  local.get 0
                                  i32.load
                                  local.get 6
                                  i32.eq
                                  br_if 1 (;@13;)
                                  local.get 0
                                  i32.load offset=8
                                  local.tee 0
                                  br_if 0 (;@14;)
                                  br 2 (;@12;)
                                end
                              end
                              local.get 0
                              i32.load offset=12
                              local.tee 8
                              i32.const 1
                              i32.and
                              br_if 0 (;@12;)
                              local.get 8
                              i32.const 1
                              i32.shr_u
                              local.get 5
                              i32.eq
                              br_if 1 (;@11;)
                            end
                            i32.const 1050632
                            local.set 0
                            block ;; label = @12
                              loop ;; label = @13
                                block ;; label = @14
                                  local.get 0
                                  i32.load
                                  local.tee 6
                                  local.get 2
                                  i32.gt_u
                                  br_if 0 (;@14;)
                                  local.get 6
                                  local.get 0
                                  i32.load offset=4
                                  i32.add
                                  local.tee 6
                                  local.get 2
                                  i32.gt_u
                                  br_if 2 (;@12;)
                                end
                                local.get 0
                                i32.load offset=8
                                local.set 0
                                br 0 (;@13;)
                              end
                            end
                            i32.const 0
                            local.get 7
                            i32.const 15
                            i32.add
                            i32.const -8
                            i32.and
                            local.tee 0
                            i32.const -8
                            i32.add
                            local.tee 8
                            i32.store offset=1050932
                            i32.const 0
                            local.get 7
                            local.get 0
                            i32.sub
                            local.get 9
                            i32.const -40
                            i32.add
                            local.tee 0
                            i32.add
                            i32.const 8
                            i32.add
                            local.tee 4
                            i32.store offset=1050924
                            local.get 8
                            local.get 4
                            i32.const 1
                            i32.or
                            i32.store offset=4
                            local.get 7
                            local.get 0
                            i32.add
                            i32.const 40
                            i32.store offset=4
                            i32.const 0
                            i32.const 2097152
                            i32.store offset=1050944
                            local.get 2
                            local.get 6
                            i32.const -32
                            i32.add
                            i32.const -8
                            i32.and
                            i32.const -8
                            i32.add
                            local.tee 0
                            local.get 0
                            local.get 2
                            i32.const 16
                            i32.add
                            i32.lt_u
                            select
                            local.tee 8
                            i32.const 27
                            i32.store offset=4
                            i32.const 0
                            i64.load offset=1050632 align=4
                            local.set 10
                            local.get 8
                            i32.const 16
                            i32.add
                            i32.const 0
                            i64.load offset=1050640 align=4
                            i64.store align=4
                            local.get 8
                            local.get 10
                            i64.store offset=8 align=4
                            i32.const 0
                            local.get 5
                            i32.store offset=1050644
                            i32.const 0
                            local.get 9
                            i32.store offset=1050636
                            i32.const 0
                            local.get 7
                            i32.store offset=1050632
                            i32.const 0
                            local.get 8
                            i32.const 8
                            i32.add
                            i32.store offset=1050640
                            local.get 8
                            i32.const 28
                            i32.add
                            local.set 0
                            loop ;; label = @12
                              local.get 0
                              i32.const 7
                              i32.store
                              local.get 0
                              i32.const 4
                              i32.add
                              local.tee 0
                              local.get 6
                              i32.lt_u
                              br_if 0 (;@12;)
                            end
                            local.get 8
                            local.get 2
                            i32.eq
                            br_if 7 (;@4;)
                            local.get 8
                            local.get 8
                            i32.load offset=4
                            i32.const -2
                            i32.and
                            i32.store offset=4
                            local.get 2
                            local.get 8
                            local.get 2
                            i32.sub
                            local.tee 0
                            i32.const 1
                            i32.or
                            i32.store offset=4
                            local.get 8
                            local.get 0
                            i32.store
                            block ;; label = @12
                              local.get 0
                              i32.const 256
                              i32.lt_u
                              br_if 0 (;@12;)
                              local.get 2
                              local.get 0
                              call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$18insert_large_chunk17h21e3abcf61006a52E
                              br 8 (;@4;)
                            end
                            local.get 0
                            i32.const -8
                            i32.and
                            i32.const 1050648
                            i32.add
                            local.set 6
                            block ;; label = @12
                              block ;; label = @13
                                i32.const 0
                                i32.load offset=1050912
                                local.tee 7
                                i32.const 1
                                local.get 0
                                i32.const 3
                                i32.shr_u
                                i32.shl
                                local.tee 0
                                i32.and
                                br_if 0 (;@13;)
                                i32.const 0
                                local.get 7
                                local.get 0
                                i32.or
                                i32.store offset=1050912
                                local.get 6
                                local.set 0
                                br 1 (;@12;)
                              end
                              local.get 6
                              i32.load offset=8
                              local.set 0
                            end
                            local.get 6
                            local.get 2
                            i32.store offset=8
                            local.get 0
                            local.get 2
                            i32.store offset=12
                            local.get 2
                            local.get 6
                            i32.store offset=12
                            local.get 2
                            local.get 0
                            i32.store offset=8
                            br 7 (;@4;)
                          end
                          local.get 0
                          local.get 7
                          i32.store
                          local.get 0
                          local.get 0
                          i32.load offset=4
                          local.get 9
                          i32.add
                          i32.store offset=4
                          local.get 7
                          i32.const 15
                          i32.add
                          i32.const -8
                          i32.and
                          i32.const -8
                          i32.add
                          local.tee 7
                          local.get 3
                          i32.const 3
                          i32.or
                          i32.store offset=4
                          local.get 6
                          i32.const 15
                          i32.add
                          i32.const -8
                          i32.and
                          i32.const -8
                          i32.add
                          local.tee 2
                          local.get 7
                          local.get 3
                          i32.add
                          local.tee 0
                          i32.sub
                          local.set 3
                          local.get 2
                          i32.const 0
                          i32.load offset=1050932
                          i32.eq
                          br_if 3 (;@7;)
                          local.get 2
                          i32.const 0
                          i32.load offset=1050928
                          i32.eq
                          br_if 4 (;@6;)
                          block ;; label = @11
                            local.get 2
                            i32.load offset=4
                            local.tee 6
                            i32.const 3
                            i32.and
                            i32.const 1
                            i32.ne
                            br_if 0 (;@11;)
                            local.get 2
                            local.get 6
                            i32.const -8
                            i32.and
                            local.tee 6
                            call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE
                            local.get 6
                            local.get 3
                            i32.add
                            local.set 3
                            local.get 2
                            local.get 6
                            i32.add
                            local.tee 2
                            i32.load offset=4
                            local.set 6
                          end
                          local.get 2
                          local.get 6
                          i32.const -2
                          i32.and
                          i32.store offset=4
                          local.get 0
                          local.get 3
                          i32.const 1
                          i32.or
                          i32.store offset=4
                          local.get 0
                          local.get 3
                          i32.add
                          local.get 3
                          i32.store
                          block ;; label = @11
                            local.get 3
                            i32.const 256
                            i32.lt_u
                            br_if 0 (;@11;)
                            local.get 0
                            local.get 3
                            call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$18insert_large_chunk17h21e3abcf61006a52E
                            br 6 (;@5;)
                          end
                          local.get 3
                          i32.const -8
                          i32.and
                          i32.const 1050648
                          i32.add
                          local.set 2
                          block ;; label = @11
                            block ;; label = @12
                              i32.const 0
                              i32.load offset=1050912
                              local.tee 6
                              i32.const 1
                              local.get 3
                              i32.const 3
                              i32.shr_u
                              i32.shl
                              local.tee 3
                              i32.and
                              br_if 0 (;@12;)
                              i32.const 0
                              local.get 6
                              local.get 3
                              i32.or
                              i32.store offset=1050912
                              local.get 2
                              local.set 3
                              br 1 (;@11;)
                            end
                            local.get 2
                            i32.load offset=8
                            local.set 3
                          end
                          local.get 2
                          local.get 0
                          i32.store offset=8
                          local.get 3
                          local.get 0
                          i32.store offset=12
                          local.get 0
                          local.get 2
                          i32.store offset=12
                          local.get 0
                          local.get 3
                          i32.store offset=8
                          br 5 (;@5;)
                        end
                        i32.const 0
                        local.get 0
                        local.get 3
                        i32.sub
                        local.tee 2
                        i32.store offset=1050924
                        i32.const 0
                        i32.const 0
                        i32.load offset=1050932
                        local.tee 0
                        local.get 3
                        i32.add
                        local.tee 6
                        i32.store offset=1050932
                        local.get 6
                        local.get 2
                        i32.const 1
                        i32.or
                        i32.store offset=4
                        local.get 0
                        local.get 3
                        i32.const 3
                        i32.or
                        i32.store offset=4
                        local.get 0
                        i32.const 8
                        i32.add
                        local.set 2
                        br 8 (;@1;)
                      end
                      i32.const 0
                      i32.load offset=1050928
                      local.set 2
                      block ;; label = @9
                        block ;; label = @10
                          local.get 0
                          local.get 3
                          i32.sub
                          local.tee 6
                          i32.const 15
                          i32.gt_u
                          br_if 0 (;@10;)
                          i32.const 0
                          i32.const 0
                          i32.store offset=1050928
                          i32.const 0
                          i32.const 0
                          i32.store offset=1050920
                          local.get 2
                          local.get 0
                          i32.const 3
                          i32.or
                          i32.store offset=4
                          local.get 2
                          local.get 0
                          i32.add
                          local.tee 0
                          local.get 0
                          i32.load offset=4
                          i32.const 1
                          i32.or
                          i32.store offset=4
                          br 1 (;@9;)
                        end
                        i32.const 0
                        local.get 6
                        i32.store offset=1050920
                        i32.const 0
                        local.get 2
                        local.get 3
                        i32.add
                        local.tee 7
                        i32.store offset=1050928
                        local.get 7
                        local.get 6
                        i32.const 1
                        i32.or
                        i32.store offset=4
                        local.get 2
                        local.get 0
                        i32.add
                        local.get 6
                        i32.store
                        local.get 2
                        local.get 3
                        i32.const 3
                        i32.or
                        i32.store offset=4
                      end
                      local.get 2
                      i32.const 8
                      i32.add
                      local.set 2
                      br 7 (;@1;)
                    end
                    local.get 0
                    local.get 8
                    local.get 9
                    i32.add
                    i32.store offset=4
                    i32.const 0
                    i32.const 0
                    i32.load offset=1050932
                    local.tee 0
                    i32.const 15
                    i32.add
                    i32.const -8
                    i32.and
                    local.tee 2
                    i32.const -8
                    i32.add
                    local.tee 6
                    i32.store offset=1050932
                    i32.const 0
                    local.get 0
                    local.get 2
                    i32.sub
                    i32.const 0
                    i32.load offset=1050924
                    local.get 9
                    i32.add
                    local.tee 2
                    i32.add
                    i32.const 8
                    i32.add
                    local.tee 7
                    i32.store offset=1050924
                    local.get 6
                    local.get 7
                    i32.const 1
                    i32.or
                    i32.store offset=4
                    local.get 0
                    local.get 2
                    i32.add
                    i32.const 40
                    i32.store offset=4
                    i32.const 0
                    i32.const 2097152
                    i32.store offset=1050944
                    br 3 (;@4;)
                  end
                  i32.const 0
                  local.get 0
                  i32.store offset=1050932
                  i32.const 0
                  i32.const 0
                  i32.load offset=1050924
                  local.get 3
                  i32.add
                  local.tee 3
                  i32.store offset=1050924
                  local.get 0
                  local.get 3
                  i32.const 1
                  i32.or
                  i32.store offset=4
                  br 1 (;@5;)
                end
                i32.const 0
                local.get 0
                i32.store offset=1050928
                i32.const 0
                i32.const 0
                i32.load offset=1050920
                local.get 3
                i32.add
                local.tee 3
                i32.store offset=1050920
                local.get 0
                local.get 3
                i32.const 1
                i32.or
                i32.store offset=4
                local.get 0
                local.get 3
                i32.add
                local.get 3
                i32.store
              end
              local.get 7
              i32.const 8
              i32.add
              local.set 2
              br 3 (;@1;)
            end
            i32.const 0
            local.set 2
            i32.const 0
            i32.load offset=1050924
            local.tee 0
            local.get 3
            i32.le_u
            br_if 2 (;@1;)
            i32.const 0
            local.get 0
            local.get 3
            i32.sub
            local.tee 2
            i32.store offset=1050924
            i32.const 0
            i32.const 0
            i32.load offset=1050932
            local.tee 0
            local.get 3
            i32.add
            local.tee 6
            i32.store offset=1050932
            local.get 6
            local.get 2
            i32.const 1
            i32.or
            i32.store offset=4
            local.get 0
            local.get 3
            i32.const 3
            i32.or
            i32.store offset=4
            local.get 0
            i32.const 8
            i32.add
            local.set 2
            br 2 (;@1;)
          end
          local.get 0
          local.get 5
          i32.store offset=24
          block ;; label = @3
            local.get 7
            i32.load offset=16
            local.tee 6
            i32.eqz
            br_if 0 (;@3;)
            local.get 0
            local.get 6
            i32.store offset=16
            local.get 6
            local.get 0
            i32.store offset=24
          end
          local.get 7
          i32.const 20
          i32.add
          i32.load
          local.tee 6
          i32.eqz
          br_if 0 (;@2;)
          local.get 0
          i32.const 20
          i32.add
          local.get 6
          i32.store
          local.get 6
          local.get 0
          i32.store offset=24
        end
        block ;; label = @2
          block ;; label = @3
            local.get 2
            i32.const 16
            i32.lt_u
            br_if 0 (;@3;)
            local.get 7
            local.get 3
            i32.const 3
            i32.or
            i32.store offset=4
            local.get 7
            local.get 3
            i32.add
            local.tee 0
            local.get 2
            i32.const 1
            i32.or
            i32.store offset=4
            local.get 0
            local.get 2
            i32.add
            local.get 2
            i32.store
            block ;; label = @4
              local.get 2
              i32.const 256
              i32.lt_u
              br_if 0 (;@4;)
              local.get 0
              local.get 2
              call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$18insert_large_chunk17h21e3abcf61006a52E
              br 2 (;@2;)
            end
            local.get 2
            i32.const -8
            i32.and
            i32.const 1050648
            i32.add
            local.set 3
            block ;; label = @4
              block ;; label = @5
                i32.const 0
                i32.load offset=1050912
                local.tee 6
                i32.const 1
                local.get 2
                i32.const 3
                i32.shr_u
                i32.shl
                local.tee 2
                i32.and
                br_if 0 (;@5;)
                i32.const 0
                local.get 6
                local.get 2
                i32.or
                i32.store offset=1050912
                local.get 3
                local.set 2
                br 1 (;@4;)
              end
              local.get 3
              i32.load offset=8
              local.set 2
            end
            local.get 3
            local.get 0
            i32.store offset=8
            local.get 2
            local.get 0
            i32.store offset=12
            local.get 0
            local.get 3
            i32.store offset=12
            local.get 0
            local.get 2
            i32.store offset=8
            br 1 (;@2;)
          end
          local.get 7
          local.get 2
          local.get 3
          i32.add
          local.tee 0
          i32.const 3
          i32.or
          i32.store offset=4
          local.get 7
          local.get 0
          i32.add
          local.tee 0
          local.get 0
          i32.load offset=4
          i32.const 1
          i32.or
          i32.store offset=4
        end
        local.get 7
        i32.const 8
        i32.add
        local.set 2
      end
      local.get 1
      i32.const 16
      i32.add
      global.set $__stack_pointer
      local.get 2
    )
    (func $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$8memalign17h0c36842f7c9c0436E (;61;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32 i32 i32)
      i32.const 0
      local.set 2
      block ;; label = @1
        i32.const -65587
        local.get 0
        i32.const 16
        local.get 0
        i32.const 16
        i32.gt_u
        select
        local.tee 0
        i32.sub
        local.get 1
        i32.le_u
        br_if 0 (;@1;)
        local.get 0
        i32.const 16
        local.get 1
        i32.const 11
        i32.add
        i32.const -8
        i32.and
        local.get 1
        i32.const 11
        i32.lt_u
        select
        local.tee 3
        i32.add
        i32.const 12
        i32.add
        call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$6malloc17hbf148db4c9dd20cdE
        local.tee 1
        i32.eqz
        br_if 0 (;@1;)
        local.get 1
        i32.const -8
        i32.add
        local.set 2
        block ;; label = @2
          block ;; label = @3
            local.get 0
            i32.const -1
            i32.add
            local.tee 4
            local.get 1
            i32.and
            br_if 0 (;@3;)
            local.get 2
            local.set 0
            br 1 (;@2;)
          end
          local.get 1
          i32.const -4
          i32.add
          local.tee 5
          i32.load
          local.tee 6
          i32.const -8
          i32.and
          local.get 4
          local.get 1
          i32.add
          i32.const 0
          local.get 0
          i32.sub
          i32.and
          i32.const -8
          i32.add
          local.tee 1
          i32.const 0
          local.get 0
          local.get 1
          local.get 2
          i32.sub
          i32.const 16
          i32.gt_u
          select
          i32.add
          local.tee 0
          local.get 2
          i32.sub
          local.tee 1
          i32.sub
          local.set 4
          block ;; label = @3
            local.get 6
            i32.const 3
            i32.and
            i32.eqz
            br_if 0 (;@3;)
            local.get 0
            local.get 4
            local.get 0
            i32.load offset=4
            i32.const 1
            i32.and
            i32.or
            i32.const 2
            i32.or
            i32.store offset=4
            local.get 0
            local.get 4
            i32.add
            local.tee 4
            local.get 4
            i32.load offset=4
            i32.const 1
            i32.or
            i32.store offset=4
            local.get 5
            local.get 1
            local.get 5
            i32.load
            i32.const 1
            i32.and
            i32.or
            i32.const 2
            i32.or
            i32.store
            local.get 2
            local.get 1
            i32.add
            local.tee 4
            local.get 4
            i32.load offset=4
            i32.const 1
            i32.or
            i32.store offset=4
            local.get 2
            local.get 1
            call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$13dispose_chunk17h8b98108d6dc2a901E
            br 1 (;@2;)
          end
          local.get 2
          i32.load
          local.set 2
          local.get 0
          local.get 4
          i32.store offset=4
          local.get 0
          local.get 2
          local.get 1
          i32.add
          i32.store
        end
        block ;; label = @2
          local.get 0
          i32.load offset=4
          local.tee 1
          i32.const 3
          i32.and
          i32.eqz
          br_if 0 (;@2;)
          local.get 1
          i32.const -8
          i32.and
          local.tee 2
          local.get 3
          i32.const 16
          i32.add
          i32.le_u
          br_if 0 (;@2;)
          local.get 0
          local.get 3
          local.get 1
          i32.const 1
          i32.and
          i32.or
          i32.const 2
          i32.or
          i32.store offset=4
          local.get 0
          local.get 3
          i32.add
          local.tee 1
          local.get 2
          local.get 3
          i32.sub
          local.tee 3
          i32.const 3
          i32.or
          i32.store offset=4
          local.get 0
          local.get 2
          i32.add
          local.tee 2
          local.get 2
          i32.load offset=4
          i32.const 1
          i32.or
          i32.store offset=4
          local.get 1
          local.get 3
          call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$13dispose_chunk17h8b98108d6dc2a901E
        end
        local.get 0
        i32.const 8
        i32.add
        local.set 2
      end
      local.get 2
    )
    (func $_ZN3std10sys_common9backtrace26__rust_end_short_backtrace17hcc7222b556723586E (;62;) (type 5) (param i32)
      local.get 0
      call $_ZN3std9panicking19begin_panic_handler28_$u7b$$u7b$closure$u7d$$u7d$17h823c80ef219a166dE
      unreachable
    )
    (func $_ZN3std9panicking19begin_panic_handler28_$u7b$$u7b$closure$u7d$$u7d$17h823c80ef219a166dE (;63;) (type 5) (param i32)
      (local i32 i32 i32)
      global.get $__stack_pointer
      i32.const 16
      i32.sub
      local.tee 1
      global.set $__stack_pointer
      local.get 0
      i32.load
      local.tee 2
      i32.const 12
      i32.add
      i32.load
      local.set 3
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 2
              i32.load offset=4
              br_table 0 (;@4;) 1 (;@3;) 3 (;@1;)
            end
            local.get 3
            br_if 2 (;@1;)
            i32.const 1049540
            local.set 2
            i32.const 0
            local.set 3
            br 1 (;@2;)
          end
          local.get 3
          br_if 1 (;@1;)
          local.get 2
          i32.load
          local.tee 2
          i32.load offset=4
          local.set 3
          local.get 2
          i32.load
          local.set 2
        end
        local.get 1
        local.get 3
        i32.store offset=4
        local.get 1
        local.get 2
        i32.store
        local.get 1
        i32.const 1049776
        local.get 0
        i32.load offset=4
        local.tee 2
        i32.load offset=8
        local.get 0
        i32.load offset=8
        local.get 2
        i32.load8_u offset=16
        local.get 2
        i32.load8_u offset=17
        call $_ZN3std9panicking20rust_panic_with_hook17h62090d3fc0630473E
        unreachable
      end
      local.get 1
      i32.const 0
      i32.store offset=4
      local.get 1
      local.get 2
      i32.store
      local.get 1
      i32.const 1049796
      local.get 0
      i32.load offset=4
      local.tee 2
      i32.load offset=8
      local.get 0
      i32.load offset=8
      local.get 2
      i32.load8_u offset=16
      local.get 2
      i32.load8_u offset=17
      call $_ZN3std9panicking20rust_panic_with_hook17h62090d3fc0630473E
      unreachable
    )
    (func $_ZN3std5alloc24default_alloc_error_hook17hb90ac78828581236E (;64;) (type 0) (param i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 48
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      block ;; label = @1
        i32.const 0
        i32.load8_u offset=1050476
        i32.eqz
        br_if 0 (;@1;)
        local.get 2
        i32.const 24
        i32.add
        i64.const 1
        i64.store align=4
        local.get 2
        i32.const 2
        i32.store offset=16
        local.get 2
        i32.const 1049644
        i32.store offset=12
        local.get 2
        i32.const 3
        i32.store offset=40
        local.get 2
        local.get 1
        i32.store offset=44
        local.get 2
        local.get 2
        i32.const 36
        i32.add
        i32.store offset=20
        local.get 2
        local.get 2
        i32.const 44
        i32.add
        i32.store offset=36
        local.get 2
        i32.const 12
        i32.add
        i32.const 1049684
        call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
        unreachable
      end
      local.get 2
      i32.const 48
      i32.add
      global.set $__stack_pointer
    )
    (func $__rdl_alloc (;65;) (type 2) (param i32 i32) (result i32)
      block ;; label = @1
        local.get 1
        i32.const 9
        i32.lt_u
        br_if 0 (;@1;)
        local.get 1
        local.get 0
        call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$8memalign17h0c36842f7c9c0436E
        return
      end
      local.get 0
      call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$6malloc17hbf148db4c9dd20cdE
    )
    (func $__rdl_dealloc (;66;) (type 6) (param i32 i32 i32)
      local.get 0
      call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$4free17h9b9b5b55abd73bc8E
    )
    (func $__rdl_realloc (;67;) (type 10) (param i32 i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32)
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 2
              i32.const 9
              i32.lt_u
              br_if 0 (;@4;)
              local.get 2
              local.get 3
              call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$8memalign17h0c36842f7c9c0436E
              local.tee 2
              br_if 1 (;@3;)
              i32.const 0
              return
            end
            i32.const 0
            local.set 2
            local.get 3
            i32.const -65588
            i32.gt_u
            br_if 1 (;@2;)
            i32.const 16
            local.get 3
            i32.const 11
            i32.add
            i32.const -8
            i32.and
            local.get 3
            i32.const 11
            i32.lt_u
            select
            local.set 1
            local.get 0
            i32.const -4
            i32.add
            local.tee 4
            i32.load
            local.tee 5
            i32.const -8
            i32.and
            local.set 6
            block ;; label = @4
              block ;; label = @5
                local.get 5
                i32.const 3
                i32.and
                br_if 0 (;@5;)
                local.get 1
                i32.const 256
                i32.lt_u
                br_if 1 (;@4;)
                local.get 6
                local.get 1
                i32.const 4
                i32.or
                i32.lt_u
                br_if 1 (;@4;)
                local.get 6
                local.get 1
                i32.sub
                i32.const 131073
                i32.ge_u
                br_if 1 (;@4;)
                local.get 0
                return
              end
              local.get 0
              i32.const -8
              i32.add
              local.tee 7
              local.get 6
              i32.add
              local.set 8
              block ;; label = @5
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      block ;; label = @9
                        local.get 6
                        local.get 1
                        i32.ge_u
                        br_if 0 (;@9;)
                        local.get 8
                        i32.const 0
                        i32.load offset=1050932
                        i32.eq
                        br_if 4 (;@5;)
                        local.get 8
                        i32.const 0
                        i32.load offset=1050928
                        i32.eq
                        br_if 2 (;@7;)
                        local.get 8
                        i32.load offset=4
                        local.tee 5
                        i32.const 2
                        i32.and
                        br_if 5 (;@4;)
                        local.get 5
                        i32.const -8
                        i32.and
                        local.tee 5
                        local.get 6
                        i32.add
                        local.tee 6
                        local.get 1
                        i32.lt_u
                        br_if 5 (;@4;)
                        local.get 8
                        local.get 5
                        call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$12unlink_chunk17h9c4f3d40073668fcE
                        local.get 6
                        local.get 1
                        i32.sub
                        local.tee 3
                        i32.const 16
                        i32.lt_u
                        br_if 1 (;@8;)
                        local.get 4
                        local.get 1
                        local.get 4
                        i32.load
                        i32.const 1
                        i32.and
                        i32.or
                        i32.const 2
                        i32.or
                        i32.store
                        local.get 7
                        local.get 1
                        i32.add
                        local.tee 2
                        local.get 3
                        i32.const 3
                        i32.or
                        i32.store offset=4
                        local.get 7
                        local.get 6
                        i32.add
                        local.tee 1
                        local.get 1
                        i32.load offset=4
                        i32.const 1
                        i32.or
                        i32.store offset=4
                        local.get 2
                        local.get 3
                        call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$13dispose_chunk17h8b98108d6dc2a901E
                        local.get 0
                        return
                      end
                      local.get 6
                      local.get 1
                      i32.sub
                      local.tee 3
                      i32.const 15
                      i32.gt_u
                      br_if 2 (;@6;)
                      local.get 0
                      return
                    end
                    local.get 4
                    local.get 6
                    local.get 4
                    i32.load
                    i32.const 1
                    i32.and
                    i32.or
                    i32.const 2
                    i32.or
                    i32.store
                    local.get 7
                    local.get 6
                    i32.add
                    local.tee 3
                    local.get 3
                    i32.load offset=4
                    i32.const 1
                    i32.or
                    i32.store offset=4
                    local.get 0
                    return
                  end
                  i32.const 0
                  i32.load offset=1050920
                  local.get 6
                  i32.add
                  local.tee 6
                  local.get 1
                  i32.lt_u
                  br_if 2 (;@4;)
                  block ;; label = @7
                    block ;; label = @8
                      local.get 6
                      local.get 1
                      i32.sub
                      local.tee 3
                      i32.const 15
                      i32.gt_u
                      br_if 0 (;@8;)
                      local.get 4
                      local.get 5
                      i32.const 1
                      i32.and
                      local.get 6
                      i32.or
                      i32.const 2
                      i32.or
                      i32.store
                      local.get 7
                      local.get 6
                      i32.add
                      local.tee 3
                      local.get 3
                      i32.load offset=4
                      i32.const 1
                      i32.or
                      i32.store offset=4
                      i32.const 0
                      local.set 3
                      i32.const 0
                      local.set 2
                      br 1 (;@7;)
                    end
                    local.get 4
                    local.get 1
                    local.get 5
                    i32.const 1
                    i32.and
                    i32.or
                    i32.const 2
                    i32.or
                    i32.store
                    local.get 7
                    local.get 1
                    i32.add
                    local.tee 2
                    local.get 3
                    i32.const 1
                    i32.or
                    i32.store offset=4
                    local.get 7
                    local.get 6
                    i32.add
                    local.tee 1
                    local.get 3
                    i32.store
                    local.get 1
                    local.get 1
                    i32.load offset=4
                    i32.const -2
                    i32.and
                    i32.store offset=4
                  end
                  i32.const 0
                  local.get 2
                  i32.store offset=1050928
                  i32.const 0
                  local.get 3
                  i32.store offset=1050920
                  local.get 0
                  return
                end
                local.get 4
                local.get 1
                local.get 5
                i32.const 1
                i32.and
                i32.or
                i32.const 2
                i32.or
                i32.store
                local.get 7
                local.get 1
                i32.add
                local.tee 2
                local.get 3
                i32.const 3
                i32.or
                i32.store offset=4
                local.get 8
                local.get 8
                i32.load offset=4
                i32.const 1
                i32.or
                i32.store offset=4
                local.get 2
                local.get 3
                call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$13dispose_chunk17h8b98108d6dc2a901E
                local.get 0
                return
              end
              i32.const 0
              i32.load offset=1050924
              local.get 6
              i32.add
              local.tee 6
              local.get 1
              i32.gt_u
              br_if 3 (;@1;)
            end
            local.get 3
            call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$6malloc17hbf148db4c9dd20cdE
            local.tee 1
            i32.eqz
            br_if 1 (;@2;)
            local.get 1
            local.get 0
            i32.const -4
            i32.const -8
            local.get 4
            i32.load
            local.tee 2
            i32.const 3
            i32.and
            select
            local.get 2
            i32.const -8
            i32.and
            i32.add
            local.tee 2
            local.get 3
            local.get 2
            local.get 3
            i32.lt_u
            select
            call $memcpy
            local.set 3
            local.get 0
            call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$4free17h9b9b5b55abd73bc8E
            local.get 3
            return
          end
          local.get 2
          local.get 0
          local.get 1
          local.get 3
          local.get 1
          local.get 3
          i32.lt_u
          select
          call $memcpy
          drop
          local.get 0
          call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$4free17h9b9b5b55abd73bc8E
        end
        local.get 2
        return
      end
      local.get 4
      local.get 1
      local.get 5
      i32.const 1
      i32.and
      i32.or
      i32.const 2
      i32.or
      i32.store
      local.get 7
      local.get 1
      i32.add
      local.tee 3
      local.get 6
      local.get 1
      i32.sub
      local.tee 2
      i32.const 1
      i32.or
      i32.store offset=4
      i32.const 0
      local.get 2
      i32.store offset=1050924
      i32.const 0
      local.get 3
      i32.store offset=1050932
      local.get 0
    )
    (func $__rdl_alloc_zeroed (;68;) (type 2) (param i32 i32) (result i32)
      block ;; label = @1
        block ;; label = @2
          local.get 1
          i32.const 9
          i32.lt_u
          br_if 0 (;@2;)
          local.get 1
          local.get 0
          call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$8memalign17h0c36842f7c9c0436E
          local.set 1
          br 1 (;@1;)
        end
        local.get 0
        call $_ZN8dlmalloc8dlmalloc17Dlmalloc$LT$A$GT$6malloc17hbf148db4c9dd20cdE
        local.set 1
      end
      block ;; label = @1
        local.get 1
        i32.eqz
        br_if 0 (;@1;)
        local.get 1
        i32.const -4
        i32.add
        i32.load8_u
        i32.const 3
        i32.and
        i32.eqz
        br_if 0 (;@1;)
        local.get 1
        i32.const 0
        local.get 0
        call $memset
        drop
      end
      local.get 1
    )
    (func $rust_begin_unwind (;69;) (type 5) (param i32)
      (local i32 i32)
      global.get $__stack_pointer
      i32.const 16
      i32.sub
      local.tee 1
      global.set $__stack_pointer
      block ;; label = @1
        local.get 0
        i32.load offset=8
        local.tee 2
        br_if 0 (;@1;)
        i32.const 1049540
        i32.const 43
        i32.const 1049728
        call $_ZN4core9panicking5panic17hd37d8d0a98259c88E
        unreachable
      end
      local.get 1
      local.get 0
      i32.load offset=12
      i32.store offset=12
      local.get 1
      local.get 0
      i32.store offset=8
      local.get 1
      local.get 2
      i32.store offset=4
      local.get 1
      i32.const 4
      i32.add
      call $_ZN3std10sys_common9backtrace26__rust_end_short_backtrace17hcc7222b556723586E
      unreachable
    )
    (func $_ZN102_$LT$std..panicking..begin_panic_handler..FormatStringPayload$u20$as$u20$core..panic..PanicPayload$GT$8take_box17h4253cf791c247536E (;70;) (type 0) (param i32 i32)
      (local i32 i32 i32 i32 i64)
      global.get $__stack_pointer
      i32.const 48
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      local.get 1
      i32.const 4
      i32.add
      local.set 3
      block ;; label = @1
        local.get 1
        i32.load offset=4
        br_if 0 (;@1;)
        local.get 1
        i32.load
        local.set 4
        local.get 2
        i32.const 36
        i32.add
        i32.const 8
        i32.add
        local.tee 5
        i32.const 0
        i32.store
        local.get 2
        i64.const 1
        i64.store offset=36 align=4
        local.get 2
        i32.const 36
        i32.add
        i32.const 1049584
        local.get 4
        call $_ZN4core3fmt5write17h42a704582454311cE
        drop
        local.get 2
        i32.const 24
        i32.add
        i32.const 8
        i32.add
        local.get 5
        i32.load
        local.tee 4
        i32.store
        local.get 2
        local.get 2
        i64.load offset=36 align=4
        local.tee 6
        i64.store offset=24
        local.get 3
        i32.const 8
        i32.add
        local.get 4
        i32.store
        local.get 3
        local.get 6
        i64.store align=4
      end
      local.get 2
      i32.const 8
      i32.add
      i32.const 8
      i32.add
      local.tee 4
      local.get 3
      i32.const 8
      i32.add
      i32.load
      i32.store
      local.get 1
      i32.const 12
      i32.add
      i32.const 0
      i32.store
      local.get 3
      i64.load align=4
      local.set 6
      local.get 1
      i64.const 1
      i64.store offset=4 align=4
      i32.const 0
      i32.load8_u offset=1050477
      drop
      local.get 2
      local.get 6
      i64.store offset=8
      block ;; label = @1
        i32.const 12
        i32.const 4
        call $__rust_alloc
        local.tee 1
        br_if 0 (;@1;)
        i32.const 4
        i32.const 12
        call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
        unreachable
      end
      local.get 1
      local.get 2
      i64.load offset=8
      i64.store align=4
      local.get 1
      i32.const 8
      i32.add
      local.get 4
      i32.load
      i32.store
      local.get 0
      i32.const 1049744
      i32.store offset=4
      local.get 0
      local.get 1
      i32.store
      local.get 2
      i32.const 48
      i32.add
      global.set $__stack_pointer
    )
    (func $_ZN102_$LT$std..panicking..begin_panic_handler..FormatStringPayload$u20$as$u20$core..panic..PanicPayload$GT$3get17h6541a23d93727cccE (;71;) (type 0) (param i32 i32)
      (local i32 i32 i32 i64)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      local.get 1
      i32.const 4
      i32.add
      local.set 3
      block ;; label = @1
        local.get 1
        i32.load offset=4
        br_if 0 (;@1;)
        local.get 1
        i32.load
        local.set 1
        local.get 2
        i32.const 20
        i32.add
        i32.const 8
        i32.add
        local.tee 4
        i32.const 0
        i32.store
        local.get 2
        i64.const 1
        i64.store offset=20 align=4
        local.get 2
        i32.const 20
        i32.add
        i32.const 1049584
        local.get 1
        call $_ZN4core3fmt5write17h42a704582454311cE
        drop
        local.get 2
        i32.const 8
        i32.add
        i32.const 8
        i32.add
        local.get 4
        i32.load
        local.tee 1
        i32.store
        local.get 2
        local.get 2
        i64.load offset=20 align=4
        local.tee 5
        i64.store offset=8
        local.get 3
        i32.const 8
        i32.add
        local.get 1
        i32.store
        local.get 3
        local.get 5
        i64.store align=4
      end
      local.get 0
      i32.const 1049744
      i32.store offset=4
      local.get 0
      local.get 3
      i32.store
      local.get 2
      i32.const 32
      i32.add
      global.set $__stack_pointer
    )
    (func $_ZN99_$LT$std..panicking..begin_panic_handler..StaticStrPayload$u20$as$u20$core..panic..PanicPayload$GT$8take_box17hc813660103856c46E (;72;) (type 0) (param i32 i32)
      (local i32 i32)
      i32.const 0
      i32.load8_u offset=1050477
      drop
      local.get 1
      i32.load offset=4
      local.set 2
      local.get 1
      i32.load
      local.set 3
      block ;; label = @1
        i32.const 8
        i32.const 4
        call $__rust_alloc
        local.tee 1
        br_if 0 (;@1;)
        i32.const 4
        i32.const 8
        call $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E
        unreachable
      end
      local.get 1
      local.get 2
      i32.store offset=4
      local.get 1
      local.get 3
      i32.store
      local.get 0
      i32.const 1049760
      i32.store offset=4
      local.get 0
      local.get 1
      i32.store
    )
    (func $_ZN99_$LT$std..panicking..begin_panic_handler..StaticStrPayload$u20$as$u20$core..panic..PanicPayload$GT$3get17h20f50abc24867da8E (;73;) (type 0) (param i32 i32)
      local.get 0
      i32.const 1049760
      i32.store offset=4
      local.get 0
      local.get 1
      i32.store
    )
    (func $_ZN3std9panicking20rust_panic_with_hook17h62090d3fc0630473E (;74;) (type 12) (param i32 i32 i32 i32 i32 i32)
      (local i32 i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 6
      global.set $__stack_pointer
      i32.const 0
      i32.const 0
      i32.load offset=1050500
      local.tee 7
      i32.const 1
      i32.add
      i32.store offset=1050500
      block ;; label = @1
        block ;; label = @2
          local.get 7
          i32.const 0
          i32.lt_s
          br_if 0 (;@2;)
          i32.const 0
          i32.load8_u offset=1050960
          i32.const 255
          i32.and
          br_if 0 (;@2;)
          i32.const 0
          i32.const 1
          i32.store8 offset=1050960
          i32.const 0
          i32.const 0
          i32.load offset=1050956
          i32.const 1
          i32.add
          i32.store offset=1050956
          local.get 6
          local.get 5
          i32.store8 offset=29
          local.get 6
          local.get 4
          i32.store8 offset=28
          local.get 6
          local.get 3
          i32.store offset=24
          local.get 6
          local.get 2
          i32.store offset=20
          local.get 6
          i32.const 1049816
          i32.store offset=16
          local.get 6
          i32.const 1049540
          i32.store offset=12
          i32.const 0
          i32.load offset=1050484
          local.tee 7
          i32.const -1
          i32.le_s
          br_if 0 (;@2;)
          i32.const 0
          local.get 7
          i32.const 1
          i32.add
          i32.store offset=1050484
          block ;; label = @3
            i32.const 0
            i32.load offset=1050492
            i32.eqz
            br_if 0 (;@3;)
            local.get 6
            local.get 0
            local.get 1
            i32.load offset=16
            call_indirect (type 0)
            local.get 6
            local.get 6
            i64.load
            i64.store offset=12 align=4
            i32.const 0
            i32.load offset=1050492
            local.get 6
            i32.const 12
            i32.add
            i32.const 0
            i32.load offset=1050496
            i32.load offset=20
            call_indirect (type 0)
            i32.const 0
            i32.load offset=1050484
            i32.const -1
            i32.add
            local.set 7
          end
          i32.const 0
          local.get 7
          i32.store offset=1050484
          i32.const 0
          i32.const 0
          i32.store8 offset=1050960
          local.get 4
          br_if 1 (;@1;)
        end
        unreachable
        unreachable
      end
      local.get 0
      local.get 1
      call $rust_panic
      unreachable
    )
    (func $rust_panic (;75;) (type 0) (param i32 i32)
      local.get 0
      local.get 1
      call $__rust_start_panic
      drop
      unreachable
      unreachable
    )
    (func $__rg_oom (;76;) (type 0) (param i32 i32)
      (local i32)
      local.get 1
      local.get 0
      i32.const 0
      i32.load offset=1050480
      local.tee 2
      i32.const 4
      local.get 2
      select
      call_indirect (type 0)
      unreachable
      unreachable
    )
    (func $__rust_start_panic (;77;) (type 2) (param i32 i32) (result i32)
      unreachable
      unreachable
    )
    (func $_ZN61_$LT$dlmalloc..sys..System$u20$as$u20$dlmalloc..Allocator$GT$5alloc17he84e5c996fe9815fE (;78;) (type 6) (param i32 i32 i32)
      (local i32)
      local.get 2
      i32.const 16
      i32.shr_u
      memory.grow
      local.set 3
      local.get 0
      i32.const 0
      i32.store offset=8
      local.get 0
      i32.const 0
      local.get 2
      i32.const -65536
      i32.and
      local.get 3
      i32.const -1
      i32.eq
      local.tee 2
      select
      i32.store offset=4
      local.get 0
      i32.const 0
      local.get 3
      i32.const 16
      i32.shl
      local.get 2
      select
      i32.store
    )
    (func $_ZN5alloc5alloc18handle_alloc_error17h910e7c06f9931dd2E (;79;) (type 0) (param i32 i32)
      local.get 1
      local.get 0
      call $__rust_alloc_error_handler
      unreachable
    )
    (func $_ZN5alloc7raw_vec17capacity_overflow17hfd18578094e5282cE (;80;) (type 3)
      (local i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 0
      global.set $__stack_pointer
      local.get 0
      i32.const 20
      i32.add
      i64.const 0
      i64.store align=4
      local.get 0
      i32.const 1
      i32.store offset=12
      local.get 0
      i32.const 1049880
      i32.store offset=8
      local.get 0
      i32.const 1049832
      i32.store offset=16
      local.get 0
      i32.const 8
      i32.add
      i32.const 1049888
      call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
      unreachable
    )
    (func $_ZN4core3ops8function6FnOnce9call_once17hbdd3bac4d73d8ae8E (;81;) (type 2) (param i32 i32) (result i32)
      local.get 0
      i32.load
      drop
      loop (result i32) ;; label = @1
        br 0 (;@1;)
      end
    )
    (func $_ZN4core3ptr37drop_in_place$LT$core..fmt..Error$GT$17h9152df636f15f3d2E (;82;) (type 5) (param i32))
    (func $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E (;83;) (type 0) (param i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      local.get 2
      i32.const 1
      i32.store16 offset=28
      local.get 2
      local.get 1
      i32.store offset=24
      local.get 2
      local.get 0
      i32.store offset=20
      local.get 2
      i32.const 1049904
      i32.store offset=16
      local.get 2
      i32.const 1049904
      i32.store offset=12
      local.get 2
      i32.const 12
      i32.add
      call $rust_begin_unwind
      unreachable
    )
    (func $_ZN4core5slice5index26slice_start_index_len_fail17hccf4311a8a2aeb43E (;84;) (type 6) (param i32 i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 48
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      local.get 3
      local.get 0
      i32.store
      local.get 3
      local.get 1
      i32.store offset=4
      local.get 3
      i32.const 8
      i32.add
      i32.const 12
      i32.add
      i64.const 2
      i64.store align=4
      local.get 3
      i32.const 32
      i32.add
      i32.const 12
      i32.add
      i32.const 3
      i32.store
      local.get 3
      i32.const 2
      i32.store offset=12
      local.get 3
      i32.const 1050452
      i32.store offset=8
      local.get 3
      i32.const 3
      i32.store offset=36
      local.get 3
      local.get 3
      i32.const 32
      i32.add
      i32.store offset=16
      local.get 3
      local.get 3
      i32.const 4
      i32.add
      i32.store offset=40
      local.get 3
      local.get 3
      i32.store offset=32
      local.get 3
      i32.const 8
      i32.add
      local.get 2
      call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
      unreachable
    )
    (func $_ZN4core3fmt9Formatter3pad17h72842a1298c3e678E (;85;) (type 1) (param i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32)
      block ;; label = @1
        local.get 0
        i32.load
        local.tee 3
        local.get 0
        i32.load offset=8
        local.tee 4
        i32.or
        i32.eqz
        br_if 0 (;@1;)
        block ;; label = @2
          local.get 4
          i32.eqz
          br_if 0 (;@2;)
          local.get 1
          local.get 2
          i32.add
          local.set 5
          local.get 0
          i32.const 12
          i32.add
          i32.load
          i32.const 1
          i32.add
          local.set 6
          i32.const 0
          local.set 7
          local.get 1
          local.set 8
          block ;; label = @3
            loop ;; label = @4
              local.get 8
              local.set 4
              local.get 6
              i32.const -1
              i32.add
              local.tee 6
              i32.eqz
              br_if 1 (;@3;)
              local.get 4
              local.get 5
              i32.eq
              br_if 2 (;@2;)
              block ;; label = @5
                block ;; label = @6
                  local.get 4
                  i32.load8_s
                  local.tee 9
                  i32.const -1
                  i32.le_s
                  br_if 0 (;@6;)
                  local.get 4
                  i32.const 1
                  i32.add
                  local.set 8
                  local.get 9
                  i32.const 255
                  i32.and
                  local.set 9
                  br 1 (;@5;)
                end
                local.get 4
                i32.load8_u offset=1
                i32.const 63
                i32.and
                local.set 10
                local.get 9
                i32.const 31
                i32.and
                local.set 8
                block ;; label = @6
                  local.get 9
                  i32.const -33
                  i32.gt_u
                  br_if 0 (;@6;)
                  local.get 8
                  i32.const 6
                  i32.shl
                  local.get 10
                  i32.or
                  local.set 9
                  local.get 4
                  i32.const 2
                  i32.add
                  local.set 8
                  br 1 (;@5;)
                end
                local.get 10
                i32.const 6
                i32.shl
                local.get 4
                i32.load8_u offset=2
                i32.const 63
                i32.and
                i32.or
                local.set 10
                block ;; label = @6
                  local.get 9
                  i32.const -16
                  i32.ge_u
                  br_if 0 (;@6;)
                  local.get 10
                  local.get 8
                  i32.const 12
                  i32.shl
                  i32.or
                  local.set 9
                  local.get 4
                  i32.const 3
                  i32.add
                  local.set 8
                  br 1 (;@5;)
                end
                local.get 10
                i32.const 6
                i32.shl
                local.get 4
                i32.load8_u offset=3
                i32.const 63
                i32.and
                i32.or
                local.get 8
                i32.const 18
                i32.shl
                i32.const 1835008
                i32.and
                i32.or
                local.tee 9
                i32.const 1114112
                i32.eq
                br_if 3 (;@2;)
                local.get 4
                i32.const 4
                i32.add
                local.set 8
              end
              local.get 7
              local.get 4
              i32.sub
              local.get 8
              i32.add
              local.set 7
              local.get 9
              i32.const 1114112
              i32.ne
              br_if 0 (;@4;)
              br 2 (;@2;)
            end
          end
          local.get 4
          local.get 5
          i32.eq
          br_if 0 (;@2;)
          block ;; label = @3
            local.get 4
            i32.load8_s
            local.tee 8
            i32.const -1
            i32.gt_s
            br_if 0 (;@3;)
            local.get 8
            i32.const -32
            i32.lt_u
            br_if 0 (;@3;)
            local.get 8
            i32.const -16
            i32.lt_u
            br_if 0 (;@3;)
            local.get 4
            i32.load8_u offset=2
            i32.const 63
            i32.and
            i32.const 6
            i32.shl
            local.get 4
            i32.load8_u offset=1
            i32.const 63
            i32.and
            i32.const 12
            i32.shl
            i32.or
            local.get 4
            i32.load8_u offset=3
            i32.const 63
            i32.and
            i32.or
            local.get 8
            i32.const 255
            i32.and
            i32.const 18
            i32.shl
            i32.const 1835008
            i32.and
            i32.or
            i32.const 1114112
            i32.eq
            br_if 1 (;@2;)
          end
          block ;; label = @3
            block ;; label = @4
              local.get 7
              i32.eqz
              br_if 0 (;@4;)
              block ;; label = @5
                local.get 7
                local.get 2
                i32.lt_u
                br_if 0 (;@5;)
                i32.const 0
                local.set 4
                local.get 7
                local.get 2
                i32.eq
                br_if 1 (;@4;)
                br 2 (;@3;)
              end
              i32.const 0
              local.set 4
              local.get 1
              local.get 7
              i32.add
              i32.load8_s
              i32.const -64
              i32.lt_s
              br_if 1 (;@3;)
            end
            local.get 1
            local.set 4
          end
          local.get 7
          local.get 2
          local.get 4
          select
          local.set 2
          local.get 4
          local.get 1
          local.get 4
          select
          local.set 1
        end
        block ;; label = @2
          local.get 3
          br_if 0 (;@2;)
          local.get 0
          i32.load offset=20
          local.get 1
          local.get 2
          local.get 0
          i32.const 24
          i32.add
          i32.load
          i32.load offset=12
          call_indirect (type 1)
          return
        end
        local.get 0
        i32.load offset=4
        local.set 5
        block ;; label = @2
          block ;; label = @3
            local.get 2
            i32.const 16
            i32.lt_u
            br_if 0 (;@3;)
            local.get 1
            local.get 2
            call $_ZN4core3str5count14do_count_chars17h03ab3d83c3fe1609E
            local.set 4
            br 1 (;@2;)
          end
          block ;; label = @3
            local.get 2
            br_if 0 (;@3;)
            i32.const 0
            local.set 4
            br 1 (;@2;)
          end
          local.get 2
          i32.const 3
          i32.and
          local.set 6
          block ;; label = @3
            block ;; label = @4
              local.get 2
              i32.const 4
              i32.ge_u
              br_if 0 (;@4;)
              i32.const 0
              local.set 4
              i32.const 0
              local.set 9
              br 1 (;@3;)
            end
            local.get 2
            i32.const -4
            i32.and
            local.set 7
            i32.const 0
            local.set 4
            i32.const 0
            local.set 9
            loop ;; label = @4
              local.get 4
              local.get 1
              local.get 9
              i32.add
              local.tee 8
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.get 8
              i32.const 1
              i32.add
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.get 8
              i32.const 2
              i32.add
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.get 8
              i32.const 3
              i32.add
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.set 4
              local.get 7
              local.get 9
              i32.const 4
              i32.add
              local.tee 9
              i32.ne
              br_if 0 (;@4;)
            end
          end
          local.get 6
          i32.eqz
          br_if 0 (;@2;)
          local.get 1
          local.get 9
          i32.add
          local.set 8
          loop ;; label = @3
            local.get 4
            local.get 8
            i32.load8_s
            i32.const -65
            i32.gt_s
            i32.add
            local.set 4
            local.get 8
            i32.const 1
            i32.add
            local.set 8
            local.get 6
            i32.const -1
            i32.add
            local.tee 6
            br_if 0 (;@3;)
          end
        end
        block ;; label = @2
          block ;; label = @3
            local.get 5
            local.get 4
            i32.le_u
            br_if 0 (;@3;)
            local.get 5
            local.get 4
            i32.sub
            local.set 7
            i32.const 0
            local.set 4
            block ;; label = @4
              block ;; label = @5
                block ;; label = @6
                  local.get 0
                  i32.load8_u offset=32
                  br_table 2 (;@4;) 0 (;@6;) 1 (;@5;) 2 (;@4;) 2 (;@4;)
                end
                local.get 7
                local.set 4
                i32.const 0
                local.set 7
                br 1 (;@4;)
              end
              local.get 7
              i32.const 1
              i32.shr_u
              local.set 4
              local.get 7
              i32.const 1
              i32.add
              i32.const 1
              i32.shr_u
              local.set 7
            end
            local.get 4
            i32.const 1
            i32.add
            local.set 4
            local.get 0
            i32.const 24
            i32.add
            i32.load
            local.set 8
            local.get 0
            i32.load offset=16
            local.set 6
            local.get 0
            i32.load offset=20
            local.set 9
            loop ;; label = @4
              local.get 4
              i32.const -1
              i32.add
              local.tee 4
              i32.eqz
              br_if 2 (;@2;)
              local.get 9
              local.get 6
              local.get 8
              i32.load offset=16
              call_indirect (type 2)
              i32.eqz
              br_if 0 (;@4;)
            end
            i32.const 1
            return
          end
          local.get 0
          i32.load offset=20
          local.get 1
          local.get 2
          local.get 0
          i32.const 24
          i32.add
          i32.load
          i32.load offset=12
          call_indirect (type 1)
          return
        end
        i32.const 1
        local.set 4
        block ;; label = @2
          local.get 9
          local.get 1
          local.get 2
          local.get 8
          i32.load offset=12
          call_indirect (type 1)
          br_if 0 (;@2;)
          i32.const 0
          local.set 4
          block ;; label = @3
            loop ;; label = @4
              block ;; label = @5
                local.get 7
                local.get 4
                i32.ne
                br_if 0 (;@5;)
                local.get 7
                local.set 4
                br 2 (;@3;)
              end
              local.get 4
              i32.const 1
              i32.add
              local.set 4
              local.get 9
              local.get 6
              local.get 8
              i32.load offset=16
              call_indirect (type 2)
              i32.eqz
              br_if 0 (;@4;)
            end
            local.get 4
            i32.const -1
            i32.add
            local.set 4
          end
          local.get 4
          local.get 7
          i32.lt_u
          local.set 4
        end
        local.get 4
        return
      end
      local.get 0
      i32.load offset=20
      local.get 1
      local.get 2
      local.get 0
      i32.const 24
      i32.add
      i32.load
      i32.load offset=12
      call_indirect (type 1)
    )
    (func $_ZN4core9panicking5panic17hd37d8d0a98259c88E (;86;) (type 6) (param i32 i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      local.get 3
      i32.const 12
      i32.add
      i64.const 0
      i64.store align=4
      local.get 3
      i32.const 1
      i32.store offset=4
      local.get 3
      i32.const 1049904
      i32.store offset=8
      local.get 3
      local.get 1
      i32.store offset=28
      local.get 3
      local.get 0
      i32.store offset=24
      local.get 3
      local.get 3
      i32.const 24
      i32.add
      i32.store
      local.get 3
      local.get 2
      call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
      unreachable
    )
    (func $_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u32$GT$3fmt17hf7c5e72c33d02c47E (;87;) (type 2) (param i32 i32) (result i32)
      local.get 0
      i64.load32_u
      i32.const 1
      local.get 1
      call $_ZN4core3fmt3num3imp7fmt_u6417hc7126242d903f6c0E
    )
    (func $_ZN4core3fmt5write17h42a704582454311cE (;88;) (type 1) (param i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
      global.get $__stack_pointer
      i32.const 48
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      local.get 3
      i32.const 36
      i32.add
      local.get 1
      i32.store
      local.get 3
      i32.const 3
      i32.store8 offset=44
      local.get 3
      i32.const 32
      i32.store offset=28
      i32.const 0
      local.set 4
      local.get 3
      i32.const 0
      i32.store offset=40
      local.get 3
      local.get 0
      i32.store offset=32
      local.get 3
      i32.const 0
      i32.store offset=20
      local.get 3
      i32.const 0
      i32.store offset=12
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              block ;; label = @5
                local.get 2
                i32.load offset=16
                local.tee 5
                br_if 0 (;@5;)
                local.get 2
                i32.const 12
                i32.add
                i32.load
                local.tee 0
                i32.eqz
                br_if 1 (;@4;)
                local.get 2
                i32.load offset=8
                local.tee 1
                local.get 0
                i32.const 3
                i32.shl
                i32.add
                local.set 6
                local.get 0
                i32.const -1
                i32.add
                i32.const 536870911
                i32.and
                i32.const 1
                i32.add
                local.set 4
                local.get 2
                i32.load
                local.set 0
                loop ;; label = @6
                  block ;; label = @7
                    local.get 0
                    i32.const 4
                    i32.add
                    i32.load
                    local.tee 7
                    i32.eqz
                    br_if 0 (;@7;)
                    local.get 3
                    i32.load offset=32
                    local.get 0
                    i32.load
                    local.get 7
                    local.get 3
                    i32.load offset=36
                    i32.load offset=12
                    call_indirect (type 1)
                    br_if 4 (;@3;)
                  end
                  local.get 1
                  i32.load
                  local.get 3
                  i32.const 12
                  i32.add
                  local.get 1
                  i32.const 4
                  i32.add
                  i32.load
                  call_indirect (type 2)
                  br_if 3 (;@3;)
                  local.get 0
                  i32.const 8
                  i32.add
                  local.set 0
                  local.get 1
                  i32.const 8
                  i32.add
                  local.tee 1
                  local.get 6
                  i32.ne
                  br_if 0 (;@6;)
                  br 2 (;@4;)
                end
              end
              local.get 2
              i32.const 20
              i32.add
              i32.load
              local.tee 1
              i32.eqz
              br_if 0 (;@4;)
              local.get 1
              i32.const 5
              i32.shl
              local.set 8
              local.get 1
              i32.const -1
              i32.add
              i32.const 134217727
              i32.and
              i32.const 1
              i32.add
              local.set 4
              local.get 2
              i32.load offset=8
              local.set 9
              local.get 2
              i32.load
              local.set 0
              i32.const 0
              local.set 7
              loop ;; label = @5
                block ;; label = @6
                  local.get 0
                  i32.const 4
                  i32.add
                  i32.load
                  local.tee 1
                  i32.eqz
                  br_if 0 (;@6;)
                  local.get 3
                  i32.load offset=32
                  local.get 0
                  i32.load
                  local.get 1
                  local.get 3
                  i32.load offset=36
                  i32.load offset=12
                  call_indirect (type 1)
                  br_if 3 (;@3;)
                end
                local.get 3
                local.get 5
                local.get 7
                i32.add
                local.tee 1
                i32.const 16
                i32.add
                i32.load
                i32.store offset=28
                local.get 3
                local.get 1
                i32.const 28
                i32.add
                i32.load8_u
                i32.store8 offset=44
                local.get 3
                local.get 1
                i32.const 24
                i32.add
                i32.load
                i32.store offset=40
                local.get 1
                i32.const 12
                i32.add
                i32.load
                local.set 10
                i32.const 0
                local.set 11
                i32.const 0
                local.set 6
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      local.get 1
                      i32.const 8
                      i32.add
                      i32.load
                      br_table 1 (;@7;) 0 (;@8;) 2 (;@6;) 1 (;@7;)
                    end
                    local.get 10
                    i32.const 3
                    i32.shl
                    local.set 12
                    i32.const 0
                    local.set 6
                    local.get 9
                    local.get 12
                    i32.add
                    local.tee 12
                    i32.load offset=4
                    i32.const 19
                    i32.ne
                    br_if 1 (;@6;)
                    local.get 12
                    i32.load
                    i32.load
                    local.set 10
                  end
                  i32.const 1
                  local.set 6
                end
                local.get 3
                local.get 10
                i32.store offset=16
                local.get 3
                local.get 6
                i32.store offset=12
                local.get 1
                i32.const 4
                i32.add
                i32.load
                local.set 6
                block ;; label = @6
                  block ;; label = @7
                    block ;; label = @8
                      local.get 1
                      i32.load
                      br_table 1 (;@7;) 0 (;@8;) 2 (;@6;) 1 (;@7;)
                    end
                    local.get 6
                    i32.const 3
                    i32.shl
                    local.set 10
                    local.get 9
                    local.get 10
                    i32.add
                    local.tee 10
                    i32.load offset=4
                    i32.const 19
                    i32.ne
                    br_if 1 (;@6;)
                    local.get 10
                    i32.load
                    i32.load
                    local.set 6
                  end
                  i32.const 1
                  local.set 11
                end
                local.get 3
                local.get 6
                i32.store offset=24
                local.get 3
                local.get 11
                i32.store offset=20
                local.get 9
                local.get 1
                i32.const 20
                i32.add
                i32.load
                i32.const 3
                i32.shl
                i32.add
                local.tee 1
                i32.load
                local.get 3
                i32.const 12
                i32.add
                local.get 1
                i32.const 4
                i32.add
                i32.load
                call_indirect (type 2)
                br_if 2 (;@3;)
                local.get 0
                i32.const 8
                i32.add
                local.set 0
                local.get 8
                local.get 7
                i32.const 32
                i32.add
                local.tee 7
                i32.ne
                br_if 0 (;@5;)
              end
            end
            local.get 4
            local.get 2
            i32.load offset=4
            i32.ge_u
            br_if 1 (;@2;)
            local.get 3
            i32.load offset=32
            local.get 2
            i32.load
            local.get 4
            i32.const 3
            i32.shl
            i32.add
            local.tee 1
            i32.load
            local.get 1
            i32.load offset=4
            local.get 3
            i32.load offset=36
            i32.load offset=12
            call_indirect (type 1)
            i32.eqz
            br_if 1 (;@2;)
          end
          i32.const 1
          local.set 1
          br 1 (;@1;)
        end
        i32.const 0
        local.set 1
      end
      local.get 3
      i32.const 48
      i32.add
      global.set $__stack_pointer
      local.get 1
    )
    (func $_ZN36_$LT$T$u20$as$u20$core..any..Any$GT$7type_id17h3f1658fbcb5f23d9E (;89;) (type 0) (param i32 i32)
      local.get 0
      i64.const -3777529136054271931
      i64.store offset=8
      local.get 0
      i64.const 2295361781758797333
      i64.store
    )
    (func $_ZN44_$LT$$RF$T$u20$as$u20$core..fmt..Display$GT$3fmt17h780d3eefec70f4afE (;90;) (type 2) (param i32 i32) (result i32)
      local.get 1
      local.get 0
      i32.load
      local.get 0
      i32.load offset=4
      call $_ZN4core3fmt9Formatter3pad17h72842a1298c3e678E
    )
    (func $_ZN4core9panicking18panic_nounwind_fmt17h5dc55a1ee2efd409E (;91;) (type 6) (param i32 i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 32
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      local.get 3
      local.get 1
      i32.store8 offset=29
      local.get 3
      i32.const 0
      i32.store8 offset=28
      local.get 3
      local.get 2
      i32.store offset=24
      local.get 3
      local.get 0
      i32.store offset=20
      local.get 3
      i32.const 1049904
      i32.store offset=16
      local.get 3
      i32.const 1049904
      i32.store offset=12
      local.get 3
      i32.const 12
      i32.add
      call $rust_begin_unwind
      unreachable
    )
    (func $_ZN4core9panicking36panic_misaligned_pointer_dereference17habcd31ab43a20267E (;92;) (type 6) (param i32 i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 112
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      local.get 3
      local.get 1
      i32.store offset=4
      local.get 3
      local.get 0
      i32.store
      local.get 3
      i32.const 32
      i32.add
      i32.const 12
      i32.add
      i32.const 20
      i32.store
      local.get 3
      i32.const 28
      i32.add
      i32.const 2
      i32.store
      local.get 3
      i32.const 20
      i32.store offset=36
      local.get 3
      local.get 3
      i32.const 4
      i32.add
      i32.store offset=40
      local.get 3
      local.get 3
      i32.store offset=32
      local.get 3
      i32.const 108
      i32.add
      i32.const 3
      i32.store8
      local.get 3
      i32.const 104
      i32.add
      i32.const 4
      i32.store
      local.get 3
      i32.const 96
      i32.add
      i64.const 4294967328
      i64.store align=4
      local.get 3
      i32.const 88
      i32.add
      i32.const 2
      i32.store
      local.get 3
      i32.const 2
      i32.store offset=12
      local.get 3
      i32.const 1049992
      i32.store offset=8
      local.get 3
      i32.const 2
      i32.store offset=80
      local.get 3
      i32.const 3
      i32.store8 offset=76
      local.get 3
      i32.const 4
      i32.store offset=72
      local.get 3
      i64.const 32
      i64.store offset=64 align=4
      local.get 3
      i32.const 2
      i32.store offset=56
      local.get 3
      i32.const 2
      i32.store offset=48
      local.get 3
      local.get 3
      i32.const 48
      i32.add
      i32.store offset=24
      local.get 3
      i32.const 8
      i32.add
      i32.const 12
      i32.add
      i32.const 2
      i32.store
      local.get 3
      local.get 3
      i32.const 32
      i32.add
      i32.store offset=16
      local.get 3
      i32.const 8
      i32.add
      i32.const 0
      local.get 2
      call $_ZN4core9panicking18panic_nounwind_fmt17h5dc55a1ee2efd409E
      unreachable
    )
    (func $_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..LowerHex$u20$for$u20$i32$GT$3fmt17h3616e10b12449442E (;93;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32)
      global.get $__stack_pointer
      i32.const 128
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      local.get 0
      i32.load
      local.set 0
      i32.const 0
      local.set 3
      loop ;; label = @1
        local.get 2
        local.get 3
        i32.add
        i32.const 127
        i32.add
        i32.const 48
        i32.const 87
        local.get 0
        i32.const 15
        i32.and
        local.tee 4
        i32.const 10
        i32.lt_u
        select
        local.get 4
        i32.add
        i32.store8
        local.get 3
        i32.const -1
        i32.add
        local.set 3
        local.get 0
        i32.const 16
        i32.lt_u
        local.set 4
        local.get 0
        i32.const 4
        i32.shr_u
        local.set 0
        local.get 4
        i32.eqz
        br_if 0 (;@1;)
      end
      block ;; label = @1
        local.get 3
        i32.const 128
        i32.add
        local.tee 0
        i32.const 128
        i32.le_u
        br_if 0 (;@1;)
        local.get 0
        i32.const 128
        i32.const 1050184
        call $_ZN4core5slice5index26slice_start_index_len_fail17hccf4311a8a2aeb43E
        unreachable
      end
      local.get 1
      i32.const 1
      i32.const 1050152
      i32.const 2
      local.get 2
      local.get 3
      i32.add
      i32.const 128
      i32.add
      i32.const 0
      local.get 3
      i32.sub
      call $_ZN4core3fmt9Formatter12pad_integral17hb35b7e60893bfb42E
      local.set 0
      local.get 2
      i32.const 128
      i32.add
      global.set $__stack_pointer
      local.get 0
    )
    (func $_ZN4core9panicking19assert_failed_inner17h003d4b5b03930769E (;94;) (type 9) (param i32 i32 i32 i32 i32 i32 i32)
      (local i32)
      global.get $__stack_pointer
      i32.const 112
      i32.sub
      local.tee 7
      global.set $__stack_pointer
      local.get 7
      local.get 2
      i32.store offset=12
      local.get 7
      local.get 1
      i32.store offset=8
      local.get 7
      local.get 4
      i32.store offset=20
      local.get 7
      local.get 3
      i32.store offset=16
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 0
              i32.const 255
              i32.and
              br_table 0 (;@4;) 1 (;@3;) 2 (;@2;) 0 (;@4;)
            end
            local.get 7
            i32.const 1050008
            i32.store offset=24
            i32.const 2
            local.set 2
            br 2 (;@1;)
          end
          local.get 7
          i32.const 1050010
          i32.store offset=24
          i32.const 2
          local.set 2
          br 1 (;@1;)
        end
        local.get 7
        i32.const 1050012
        i32.store offset=24
        i32.const 7
        local.set 2
      end
      local.get 7
      local.get 2
      i32.store offset=28
      block ;; label = @1
        local.get 5
        i32.load
        br_if 0 (;@1;)
        local.get 7
        i32.const 76
        i32.add
        i32.const 21
        i32.store
        local.get 7
        i32.const 56
        i32.add
        i32.const 12
        i32.add
        i32.const 21
        i32.store
        local.get 7
        i32.const 88
        i32.add
        i32.const 12
        i32.add
        i64.const 3
        i64.store align=4
        local.get 7
        i32.const 3
        i32.store offset=92
        local.get 7
        i32.const 1050068
        i32.store offset=88
        local.get 7
        i32.const 22
        i32.store offset=60
        local.get 7
        local.get 7
        i32.const 56
        i32.add
        i32.store offset=96
        local.get 7
        local.get 7
        i32.const 16
        i32.add
        i32.store offset=72
        local.get 7
        local.get 7
        i32.const 8
        i32.add
        i32.store offset=64
        local.get 7
        local.get 7
        i32.const 24
        i32.add
        i32.store offset=56
        local.get 7
        i32.const 88
        i32.add
        local.get 6
        call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
        unreachable
      end
      local.get 7
      i32.const 32
      i32.add
      i32.const 16
      i32.add
      local.get 5
      i32.const 16
      i32.add
      i64.load align=4
      i64.store
      local.get 7
      i32.const 32
      i32.add
      i32.const 8
      i32.add
      local.get 5
      i32.const 8
      i32.add
      i64.load align=4
      i64.store
      local.get 7
      local.get 5
      i64.load align=4
      i64.store offset=32
      local.get 7
      i32.const 88
      i32.add
      i32.const 12
      i32.add
      i64.const 4
      i64.store align=4
      local.get 7
      i32.const 84
      i32.add
      i32.const 21
      i32.store
      local.get 7
      i32.const 76
      i32.add
      i32.const 21
      i32.store
      local.get 7
      i32.const 56
      i32.add
      i32.const 12
      i32.add
      i32.const 23
      i32.store
      local.get 7
      i32.const 4
      i32.store offset=92
      local.get 7
      i32.const 1050120
      i32.store offset=88
      local.get 7
      i32.const 22
      i32.store offset=60
      local.get 7
      local.get 7
      i32.const 56
      i32.add
      i32.store offset=96
      local.get 7
      local.get 7
      i32.const 16
      i32.add
      i32.store offset=80
      local.get 7
      local.get 7
      i32.const 8
      i32.add
      i32.store offset=72
      local.get 7
      local.get 7
      i32.const 32
      i32.add
      i32.store offset=64
      local.get 7
      local.get 7
      i32.const 24
      i32.add
      i32.store offset=56
      local.get 7
      i32.const 88
      i32.add
      local.get 6
      call $_ZN4core9panicking9panic_fmt17hd79411a297d06dc8E
      unreachable
    )
    (func $_ZN42_$LT$$RF$T$u20$as$u20$core..fmt..Debug$GT$3fmt17h0a20f2b6114281ceE (;95;) (type 2) (param i32 i32) (result i32)
      local.get 0
      i32.load
      local.get 1
      local.get 0
      i32.load offset=4
      i32.load offset=12
      call_indirect (type 2)
    )
    (func $_ZN59_$LT$core..fmt..Arguments$u20$as$u20$core..fmt..Display$GT$3fmt17h37e2c1310d2a64e6E (;96;) (type 2) (param i32 i32) (result i32)
      local.get 1
      i32.load offset=20
      local.get 1
      i32.const 24
      i32.add
      i32.load
      local.get 0
      call $_ZN4core3fmt5write17h42a704582454311cE
    )
    (func $_ZN4core3fmt9Formatter12pad_integral17hb35b7e60893bfb42E (;97;) (type 13) (param i32 i32 i32 i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32)
      block ;; label = @1
        block ;; label = @2
          local.get 1
          br_if 0 (;@2;)
          local.get 5
          i32.const 1
          i32.add
          local.set 6
          local.get 0
          i32.load offset=28
          local.set 7
          i32.const 45
          local.set 8
          br 1 (;@1;)
        end
        i32.const 43
        i32.const 1114112
        local.get 0
        i32.load offset=28
        local.tee 7
        i32.const 1
        i32.and
        local.tee 1
        select
        local.set 8
        local.get 1
        local.get 5
        i32.add
        local.set 6
      end
      block ;; label = @1
        block ;; label = @2
          local.get 7
          i32.const 4
          i32.and
          br_if 0 (;@2;)
          i32.const 0
          local.set 2
          br 1 (;@1;)
        end
        block ;; label = @2
          block ;; label = @3
            local.get 3
            i32.const 16
            i32.lt_u
            br_if 0 (;@3;)
            local.get 2
            local.get 3
            call $_ZN4core3str5count14do_count_chars17h03ab3d83c3fe1609E
            local.set 1
            br 1 (;@2;)
          end
          block ;; label = @3
            local.get 3
            br_if 0 (;@3;)
            i32.const 0
            local.set 1
            br 1 (;@2;)
          end
          local.get 3
          i32.const 3
          i32.and
          local.set 9
          block ;; label = @3
            block ;; label = @4
              local.get 3
              i32.const 4
              i32.ge_u
              br_if 0 (;@4;)
              i32.const 0
              local.set 1
              i32.const 0
              local.set 10
              br 1 (;@3;)
            end
            local.get 3
            i32.const -4
            i32.and
            local.set 11
            i32.const 0
            local.set 1
            i32.const 0
            local.set 10
            loop ;; label = @4
              local.get 1
              local.get 2
              local.get 10
              i32.add
              local.tee 12
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.get 12
              i32.const 1
              i32.add
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.get 12
              i32.const 2
              i32.add
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.get 12
              i32.const 3
              i32.add
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.set 1
              local.get 11
              local.get 10
              i32.const 4
              i32.add
              local.tee 10
              i32.ne
              br_if 0 (;@4;)
            end
          end
          local.get 9
          i32.eqz
          br_if 0 (;@2;)
          local.get 2
          local.get 10
          i32.add
          local.set 12
          loop ;; label = @3
            local.get 1
            local.get 12
            i32.load8_s
            i32.const -65
            i32.gt_s
            i32.add
            local.set 1
            local.get 12
            i32.const 1
            i32.add
            local.set 12
            local.get 9
            i32.const -1
            i32.add
            local.tee 9
            br_if 0 (;@3;)
          end
        end
        local.get 1
        local.get 6
        i32.add
        local.set 6
      end
      block ;; label = @1
        block ;; label = @2
          local.get 0
          i32.load
          br_if 0 (;@2;)
          i32.const 1
          local.set 1
          local.get 0
          i32.load offset=20
          local.tee 12
          local.get 0
          i32.load offset=24
          local.tee 10
          local.get 8
          local.get 2
          local.get 3
          call $_ZN4core3fmt9Formatter12pad_integral12write_prefix17h4ec46e2a4d9c027bE
          br_if 1 (;@1;)
          local.get 12
          local.get 4
          local.get 5
          local.get 10
          i32.load offset=12
          call_indirect (type 1)
          return
        end
        block ;; label = @2
          local.get 0
          i32.load offset=4
          local.tee 9
          local.get 6
          i32.gt_u
          br_if 0 (;@2;)
          i32.const 1
          local.set 1
          local.get 0
          i32.load offset=20
          local.tee 12
          local.get 0
          i32.load offset=24
          local.tee 10
          local.get 8
          local.get 2
          local.get 3
          call $_ZN4core3fmt9Formatter12pad_integral12write_prefix17h4ec46e2a4d9c027bE
          br_if 1 (;@1;)
          local.get 12
          local.get 4
          local.get 5
          local.get 10
          i32.load offset=12
          call_indirect (type 1)
          return
        end
        block ;; label = @2
          local.get 7
          i32.const 8
          i32.and
          i32.eqz
          br_if 0 (;@2;)
          local.get 0
          i32.load offset=16
          local.set 11
          local.get 0
          i32.const 48
          i32.store offset=16
          local.get 0
          i32.load8_u offset=32
          local.set 7
          i32.const 1
          local.set 1
          local.get 0
          i32.const 1
          i32.store8 offset=32
          local.get 0
          i32.load offset=20
          local.tee 12
          local.get 0
          i32.load offset=24
          local.tee 10
          local.get 8
          local.get 2
          local.get 3
          call $_ZN4core3fmt9Formatter12pad_integral12write_prefix17h4ec46e2a4d9c027bE
          br_if 1 (;@1;)
          local.get 9
          local.get 6
          i32.sub
          i32.const 1
          i32.add
          local.set 1
          block ;; label = @3
            loop ;; label = @4
              local.get 1
              i32.const -1
              i32.add
              local.tee 1
              i32.eqz
              br_if 1 (;@3;)
              local.get 12
              i32.const 48
              local.get 10
              i32.load offset=16
              call_indirect (type 2)
              i32.eqz
              br_if 0 (;@4;)
            end
            i32.const 1
            return
          end
          i32.const 1
          local.set 1
          local.get 12
          local.get 4
          local.get 5
          local.get 10
          i32.load offset=12
          call_indirect (type 1)
          br_if 1 (;@1;)
          local.get 0
          local.get 7
          i32.store8 offset=32
          local.get 0
          local.get 11
          i32.store offset=16
          i32.const 0
          local.set 1
          br 1 (;@1;)
        end
        local.get 9
        local.get 6
        i32.sub
        local.set 6
        block ;; label = @2
          block ;; label = @3
            block ;; label = @4
              local.get 0
              i32.load8_u offset=32
              local.tee 1
              br_table 2 (;@2;) 0 (;@4;) 1 (;@3;) 0 (;@4;) 2 (;@2;)
            end
            local.get 6
            local.set 1
            i32.const 0
            local.set 6
            br 1 (;@2;)
          end
          local.get 6
          i32.const 1
          i32.shr_u
          local.set 1
          local.get 6
          i32.const 1
          i32.add
          i32.const 1
          i32.shr_u
          local.set 6
        end
        local.get 1
        i32.const 1
        i32.add
        local.set 1
        local.get 0
        i32.const 24
        i32.add
        i32.load
        local.set 12
        local.get 0
        i32.load offset=16
        local.set 9
        local.get 0
        i32.load offset=20
        local.set 10
        block ;; label = @2
          loop ;; label = @3
            local.get 1
            i32.const -1
            i32.add
            local.tee 1
            i32.eqz
            br_if 1 (;@2;)
            local.get 10
            local.get 9
            local.get 12
            i32.load offset=16
            call_indirect (type 2)
            i32.eqz
            br_if 0 (;@3;)
          end
          i32.const 1
          return
        end
        i32.const 1
        local.set 1
        local.get 10
        local.get 12
        local.get 8
        local.get 2
        local.get 3
        call $_ZN4core3fmt9Formatter12pad_integral12write_prefix17h4ec46e2a4d9c027bE
        br_if 0 (;@1;)
        local.get 10
        local.get 4
        local.get 5
        local.get 12
        i32.load offset=12
        call_indirect (type 1)
        br_if 0 (;@1;)
        i32.const 0
        local.set 1
        loop ;; label = @2
          block ;; label = @3
            local.get 6
            local.get 1
            i32.ne
            br_if 0 (;@3;)
            local.get 6
            local.get 6
            i32.lt_u
            return
          end
          local.get 1
          i32.const 1
          i32.add
          local.set 1
          local.get 10
          local.get 9
          local.get 12
          i32.load offset=16
          call_indirect (type 2)
          i32.eqz
          br_if 0 (;@2;)
        end
        local.get 1
        i32.const -1
        i32.add
        local.get 6
        i32.lt_u
        return
      end
      local.get 1
    )
    (func $_ZN4core3str5count14do_count_chars17h03ab3d83c3fe1609E (;98;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32)
      block ;; label = @1
        block ;; label = @2
          local.get 1
          local.get 0
          i32.const 3
          i32.add
          i32.const -4
          i32.and
          local.tee 2
          local.get 0
          i32.sub
          local.tee 3
          i32.lt_u
          br_if 0 (;@2;)
          local.get 1
          local.get 3
          i32.sub
          local.tee 4
          i32.const 4
          i32.lt_u
          br_if 0 (;@2;)
          local.get 4
          i32.const 3
          i32.and
          local.set 5
          i32.const 0
          local.set 6
          i32.const 0
          local.set 1
          block ;; label = @3
            local.get 2
            local.get 0
            i32.eq
            local.tee 7
            br_if 0 (;@3;)
            i32.const 0
            local.set 1
            block ;; label = @4
              block ;; label = @5
                local.get 2
                local.get 0
                i32.const -1
                i32.xor
                i32.add
                i32.const 3
                i32.ge_u
                br_if 0 (;@5;)
                i32.const 0
                local.set 8
                br 1 (;@4;)
              end
              i32.const 0
              local.set 8
              loop ;; label = @5
                local.get 1
                local.get 0
                local.get 8
                i32.add
                local.tee 9
                i32.load8_s
                i32.const -65
                i32.gt_s
                i32.add
                local.get 9
                i32.const 1
                i32.add
                i32.load8_s
                i32.const -65
                i32.gt_s
                i32.add
                local.get 9
                i32.const 2
                i32.add
                i32.load8_s
                i32.const -65
                i32.gt_s
                i32.add
                local.get 9
                i32.const 3
                i32.add
                i32.load8_s
                i32.const -65
                i32.gt_s
                i32.add
                local.set 1
                local.get 8
                i32.const 4
                i32.add
                local.tee 8
                br_if 0 (;@5;)
              end
            end
            local.get 7
            br_if 0 (;@3;)
            local.get 0
            local.get 2
            i32.sub
            local.set 2
            local.get 0
            local.get 8
            i32.add
            local.set 9
            loop ;; label = @4
              local.get 1
              local.get 9
              i32.load8_s
              i32.const -65
              i32.gt_s
              i32.add
              local.set 1
              local.get 9
              i32.const 1
              i32.add
              local.set 9
              local.get 2
              i32.const 1
              i32.add
              local.tee 2
              br_if 0 (;@4;)
            end
          end
          local.get 0
          local.get 3
          i32.add
          local.set 8
          block ;; label = @3
            local.get 5
            i32.eqz
            br_if 0 (;@3;)
            local.get 8
            local.get 4
            i32.const -4
            i32.and
            i32.add
            local.tee 9
            i32.load8_s
            i32.const -65
            i32.gt_s
            local.set 6
            local.get 5
            i32.const 1
            i32.eq
            br_if 0 (;@3;)
            local.get 6
            local.get 9
            i32.load8_s offset=1
            i32.const -65
            i32.gt_s
            i32.add
            local.set 6
            local.get 5
            i32.const 2
            i32.eq
            br_if 0 (;@3;)
            local.get 6
            local.get 9
            i32.load8_s offset=2
            i32.const -65
            i32.gt_s
            i32.add
            local.set 6
          end
          local.get 4
          i32.const 2
          i32.shr_u
          local.set 3
          local.get 6
          local.get 1
          i32.add
          local.set 2
          loop ;; label = @3
            local.get 8
            local.set 6
            local.get 3
            i32.eqz
            br_if 2 (;@1;)
            local.get 3
            i32.const 192
            local.get 3
            i32.const 192
            i32.lt_u
            select
            local.tee 4
            i32.const 3
            i32.and
            local.set 7
            local.get 4
            i32.const 2
            i32.shl
            local.set 5
            i32.const 0
            local.set 9
            block ;; label = @4
              local.get 4
              i32.const 4
              i32.lt_u
              br_if 0 (;@4;)
              local.get 6
              local.get 5
              i32.const 1008
              i32.and
              i32.add
              local.set 0
              i32.const 0
              local.set 9
              local.get 6
              local.set 1
              loop ;; label = @5
                local.get 1
                i32.const 12
                i32.add
                i32.load
                local.tee 8
                i32.const -1
                i32.xor
                i32.const 7
                i32.shr_u
                local.get 8
                i32.const 6
                i32.shr_u
                i32.or
                i32.const 16843009
                i32.and
                local.get 1
                i32.const 8
                i32.add
                i32.load
                local.tee 8
                i32.const -1
                i32.xor
                i32.const 7
                i32.shr_u
                local.get 8
                i32.const 6
                i32.shr_u
                i32.or
                i32.const 16843009
                i32.and
                local.get 1
                i32.const 4
                i32.add
                i32.load
                local.tee 8
                i32.const -1
                i32.xor
                i32.const 7
                i32.shr_u
                local.get 8
                i32.const 6
                i32.shr_u
                i32.or
                i32.const 16843009
                i32.and
                local.get 1
                i32.load
                local.tee 8
                i32.const -1
                i32.xor
                i32.const 7
                i32.shr_u
                local.get 8
                i32.const 6
                i32.shr_u
                i32.or
                i32.const 16843009
                i32.and
                local.get 9
                i32.add
                i32.add
                i32.add
                i32.add
                local.set 9
                local.get 1
                i32.const 16
                i32.add
                local.tee 1
                local.get 0
                i32.ne
                br_if 0 (;@5;)
              end
            end
            local.get 3
            local.get 4
            i32.sub
            local.set 3
            local.get 6
            local.get 5
            i32.add
            local.set 8
            local.get 9
            i32.const 8
            i32.shr_u
            i32.const 16711935
            i32.and
            local.get 9
            i32.const 16711935
            i32.and
            i32.add
            i32.const 65537
            i32.mul
            i32.const 16
            i32.shr_u
            local.get 2
            i32.add
            local.set 2
            local.get 7
            i32.eqz
            br_if 0 (;@3;)
          end
          local.get 6
          local.get 4
          i32.const 252
          i32.and
          i32.const 2
          i32.shl
          i32.add
          local.tee 9
          i32.load
          local.tee 1
          i32.const -1
          i32.xor
          i32.const 7
          i32.shr_u
          local.get 1
          i32.const 6
          i32.shr_u
          i32.or
          i32.const 16843009
          i32.and
          local.set 1
          block ;; label = @3
            local.get 7
            i32.const 1
            i32.eq
            br_if 0 (;@3;)
            local.get 9
            i32.load offset=4
            local.tee 8
            i32.const -1
            i32.xor
            i32.const 7
            i32.shr_u
            local.get 8
            i32.const 6
            i32.shr_u
            i32.or
            i32.const 16843009
            i32.and
            local.get 1
            i32.add
            local.set 1
            local.get 7
            i32.const 2
            i32.eq
            br_if 0 (;@3;)
            local.get 9
            i32.load offset=8
            local.tee 9
            i32.const -1
            i32.xor
            i32.const 7
            i32.shr_u
            local.get 9
            i32.const 6
            i32.shr_u
            i32.or
            i32.const 16843009
            i32.and
            local.get 1
            i32.add
            local.set 1
          end
          local.get 1
          i32.const 8
          i32.shr_u
          i32.const 459007
          i32.and
          local.get 1
          i32.const 16711935
          i32.and
          i32.add
          i32.const 65537
          i32.mul
          i32.const 16
          i32.shr_u
          local.get 2
          i32.add
          return
        end
        block ;; label = @2
          local.get 1
          br_if 0 (;@2;)
          i32.const 0
          return
        end
        local.get 1
        i32.const 3
        i32.and
        local.set 8
        block ;; label = @2
          block ;; label = @3
            local.get 1
            i32.const 4
            i32.ge_u
            br_if 0 (;@3;)
            i32.const 0
            local.set 2
            i32.const 0
            local.set 9
            br 1 (;@2;)
          end
          local.get 1
          i32.const -4
          i32.and
          local.set 3
          i32.const 0
          local.set 2
          i32.const 0
          local.set 9
          loop ;; label = @3
            local.get 2
            local.get 0
            local.get 9
            i32.add
            local.tee 1
            i32.load8_s
            i32.const -65
            i32.gt_s
            i32.add
            local.get 1
            i32.const 1
            i32.add
            i32.load8_s
            i32.const -65
            i32.gt_s
            i32.add
            local.get 1
            i32.const 2
            i32.add
            i32.load8_s
            i32.const -65
            i32.gt_s
            i32.add
            local.get 1
            i32.const 3
            i32.add
            i32.load8_s
            i32.const -65
            i32.gt_s
            i32.add
            local.set 2
            local.get 3
            local.get 9
            i32.const 4
            i32.add
            local.tee 9
            i32.ne
            br_if 0 (;@3;)
          end
        end
        local.get 8
        i32.eqz
        br_if 0 (;@1;)
        local.get 0
        local.get 9
        i32.add
        local.set 1
        loop ;; label = @2
          local.get 2
          local.get 1
          i32.load8_s
          i32.const -65
          i32.gt_s
          i32.add
          local.set 2
          local.get 1
          i32.const 1
          i32.add
          local.set 1
          local.get 8
          i32.const -1
          i32.add
          local.tee 8
          br_if 0 (;@2;)
        end
      end
      local.get 2
    )
    (func $_ZN4core3fmt9Formatter12pad_integral12write_prefix17h4ec46e2a4d9c027bE (;99;) (type 14) (param i32 i32 i32 i32 i32) (result i32)
      (local i32)
      block ;; label = @1
        block ;; label = @2
          block ;; label = @3
            local.get 2
            i32.const 1114112
            i32.eq
            br_if 0 (;@3;)
            i32.const 1
            local.set 5
            local.get 0
            local.get 2
            local.get 1
            i32.load offset=16
            call_indirect (type 2)
            br_if 1 (;@2;)
          end
          local.get 3
          br_if 1 (;@1;)
          i32.const 0
          local.set 5
        end
        local.get 5
        return
      end
      local.get 0
      local.get 3
      local.get 4
      local.get 1
      i32.load offset=12
      call_indirect (type 1)
    )
    (func $_ZN4core3fmt3num3imp7fmt_u6417hc7126242d903f6c0E (;100;) (type 15) (param i64 i32 i32) (result i32)
      (local i32 i32 i64 i32 i32 i32)
      global.get $__stack_pointer
      i32.const 48
      i32.sub
      local.tee 3
      global.set $__stack_pointer
      i32.const 39
      local.set 4
      block ;; label = @1
        block ;; label = @2
          local.get 0
          i64.const 10000
          i64.ge_u
          br_if 0 (;@2;)
          local.get 0
          local.set 5
          br 1 (;@1;)
        end
        i32.const 39
        local.set 4
        loop ;; label = @2
          local.get 3
          i32.const 9
          i32.add
          local.get 4
          i32.add
          local.tee 6
          i32.const -4
          i32.add
          local.get 0
          local.get 0
          i64.const 10000
          i64.div_u
          local.tee 5
          i64.const 10000
          i64.mul
          i64.sub
          i32.wrap_i64
          local.tee 7
          i32.const 65535
          i32.and
          i32.const 100
          i32.div_u
          local.tee 8
          i32.const 1
          i32.shl
          i32.const 1050200
          i32.add
          i32.load16_u align=1
          i32.store16 align=1
          local.get 6
          i32.const -2
          i32.add
          local.get 7
          local.get 8
          i32.const 100
          i32.mul
          i32.sub
          i32.const 65535
          i32.and
          i32.const 1
          i32.shl
          i32.const 1050200
          i32.add
          i32.load16_u align=1
          i32.store16 align=1
          local.get 4
          i32.const -4
          i32.add
          local.set 4
          local.get 0
          i64.const 99999999
          i64.gt_u
          local.set 6
          local.get 5
          local.set 0
          local.get 6
          br_if 0 (;@2;)
        end
      end
      block ;; label = @1
        local.get 5
        i32.wrap_i64
        local.tee 6
        i32.const 99
        i32.le_u
        br_if 0 (;@1;)
        local.get 3
        i32.const 9
        i32.add
        local.get 4
        i32.const -2
        i32.add
        local.tee 4
        i32.add
        local.get 5
        i32.wrap_i64
        local.tee 6
        local.get 6
        i32.const 65535
        i32.and
        i32.const 100
        i32.div_u
        local.tee 6
        i32.const 100
        i32.mul
        i32.sub
        i32.const 65535
        i32.and
        i32.const 1
        i32.shl
        i32.const 1050200
        i32.add
        i32.load16_u align=1
        i32.store16 align=1
      end
      block ;; label = @1
        block ;; label = @2
          local.get 6
          i32.const 10
          i32.lt_u
          br_if 0 (;@2;)
          local.get 3
          i32.const 9
          i32.add
          local.get 4
          i32.const -2
          i32.add
          local.tee 4
          i32.add
          local.get 6
          i32.const 1
          i32.shl
          i32.const 1050200
          i32.add
          i32.load16_u align=1
          i32.store16 align=1
          br 1 (;@1;)
        end
        local.get 3
        i32.const 9
        i32.add
        local.get 4
        i32.const -1
        i32.add
        local.tee 4
        i32.add
        local.get 6
        i32.const 48
        i32.add
        i32.store8
      end
      local.get 2
      local.get 1
      i32.const 1049904
      i32.const 0
      local.get 3
      i32.const 9
      i32.add
      local.get 4
      i32.add
      i32.const 39
      local.get 4
      i32.sub
      call $_ZN4core3fmt9Formatter12pad_integral17hb35b7e60893bfb42E
      local.set 4
      local.get 3
      i32.const 48
      i32.add
      global.set $__stack_pointer
      local.get 4
    )
    (func $_ZN4core3fmt3num53_$LT$impl$u20$core..fmt..UpperHex$u20$for$u20$i32$GT$3fmt17h47738bb070892c53E (;101;) (type 2) (param i32 i32) (result i32)
      (local i32 i32 i32)
      global.get $__stack_pointer
      i32.const 128
      i32.sub
      local.tee 2
      global.set $__stack_pointer
      local.get 0
      i32.load
      local.set 0
      i32.const 0
      local.set 3
      loop ;; label = @1
        local.get 2
        local.get 3
        i32.add
        i32.const 127
        i32.add
        i32.const 48
        i32.const 55
        local.get 0
        i32.const 15
        i32.and
        local.tee 4
        i32.const 10
        i32.lt_u
        select
        local.get 4
        i32.add
        i32.store8
        local.get 3
        i32.const -1
        i32.add
        local.set 3
        local.get 0
        i32.const 16
        i32.lt_u
        local.set 4
        local.get 0
        i32.const 4
        i32.shr_u
        local.set 0
        local.get 4
        i32.eqz
        br_if 0 (;@1;)
      end
      block ;; label = @1
        local.get 3
        i32.const 128
        i32.add
        local.tee 0
        i32.const 128
        i32.le_u
        br_if 0 (;@1;)
        local.get 0
        i32.const 128
        i32.const 1050184
        call $_ZN4core5slice5index26slice_start_index_len_fail17hccf4311a8a2aeb43E
        unreachable
      end
      local.get 1
      i32.const 1
      i32.const 1050152
      i32.const 2
      local.get 2
      local.get 3
      i32.add
      i32.const 128
      i32.add
      i32.const 0
      local.get 3
      i32.sub
      call $_ZN4core3fmt9Formatter12pad_integral17hb35b7e60893bfb42E
      local.set 0
      local.get 2
      i32.const 128
      i32.add
      global.set $__stack_pointer
      local.get 0
    )
    (func $_ZN17compiler_builtins3mem6memcpy17hfd20217541c602e1E (;102;) (type 1) (param i32 i32 i32) (result i32)
      (local i32 i32 i32 i32 i32 i32 i32 i32)
      block ;; label = @1
        block ;; label = @2
          local.get 2
          i32.const 16
          i32.ge_u
          br_if 0 (;@2;)
          local.get 0
          local.set 3
          br 1 (;@1;)
        end
        local.get 0
        i32.const 0
        local.get 0
        i32.sub
        i32.const 3
        i32.and
        local.tee 4
        i32.add
        local.set 5
        block ;; label = @2
          local.get 4
          i32.eqz
          br_if 0 (;@2;)
          local.get 0
          local.set 3
          local.get 1
          local.set 6
          loop ;; label = @3
            local.get 3
            local.get 6
            i32.load8_u
            i32.store8
            local.get 6
            i32.const 1
            i32.add
            local.set 6
            local.get 3
            i32.const 1
            i32.add
            local.tee 3
            local.get 5
            i32.lt_u
            br_if 0 (;@3;)
          end
        end
        local.get 5
        local.get 2
        local.get 4
        i32.sub
        local.tee 7
        i32.const -4
        i32.and
        local.tee 8
        i32.add
        local.set 3
        block ;; label = @2
          block ;; label = @3
            local.get 1
            local.get 4
            i32.add
            local.tee 9
            i32.const 3
            i32.and
            i32.eqz
            br_if 0 (;@3;)
            local.get 8
            i32.const 1
            i32.lt_s
            br_if 1 (;@2;)
            local.get 9
            i32.const 3
            i32.shl
            local.tee 6
            i32.const 24
            i32.and
            local.set 2
            local.get 9
            i32.const -4
            i32.and
            local.tee 10
            i32.const 4
            i32.add
            local.set 1
            i32.const 0
            local.get 6
            i32.sub
            i32.const 24
            i32.and
            local.set 4
            local.get 10
            i32.load
            local.set 6
            loop ;; label = @4
              local.get 5
              local.get 6
              local.get 2
              i32.shr_u
              local.get 1
              i32.load
              local.tee 6
              local.get 4
              i32.shl
              i32.or
              i32.store
              local.get 1
              i32.const 4
              i32.add
              local.set 1
              local.get 5
              i32.const 4
              i32.add
              local.tee 5
              local.get 3
              i32.lt_u
              br_if 0 (;@4;)
              br 2 (;@2;)
            end
          end
          local.get 8
          i32.const 1
          i32.lt_s
          br_if 0 (;@2;)
          local.get 9
          local.set 1
          loop ;; label = @3
            local.get 5
            local.get 1
            i32.load
            i32.store
            local.get 1
            i32.const 4
            i32.add
            local.set 1
            local.get 5
            i32.const 4
            i32.add
            local.tee 5
            local.get 3
            i32.lt_u
            br_if 0 (;@3;)
          end
        end
        local.get 7
        i32.const 3
        i32.and
        local.set 2
        local.get 9
        local.get 8
        i32.add
        local.set 1
      end
      block ;; label = @1
        local.get 2
        i32.eqz
        br_if 0 (;@1;)
        local.get 3
        local.get 2
        i32.add
        local.set 5
        loop ;; label = @2
          local.get 3
          local.get 1
          i32.load8_u
          i32.store8
          local.get 1
          i32.const 1
          i32.add
          local.set 1
          local.get 3
          i32.const 1
          i32.add
          local.tee 3
          local.get 5
          i32.lt_u
          br_if 0 (;@2;)
        end
      end
      local.get 0
    )
    (func $_ZN17compiler_builtins3mem6memset17ha0a3ab3a984e51d4E (;103;) (type 1) (param i32 i32 i32) (result i32)
      (local i32 i32 i32)
      block ;; label = @1
        block ;; label = @2
          local.get 2
          i32.const 16
          i32.ge_u
          br_if 0 (;@2;)
          local.get 0
          local.set 3
          br 1 (;@1;)
        end
        local.get 0
        i32.const 0
        local.get 0
        i32.sub
        i32.const 3
        i32.and
        local.tee 4
        i32.add
        local.set 5
        block ;; label = @2
          local.get 4
          i32.eqz
          br_if 0 (;@2;)
          local.get 0
          local.set 3
          loop ;; label = @3
            local.get 3
            local.get 1
            i32.store8
            local.get 3
            i32.const 1
            i32.add
            local.tee 3
            local.get 5
            i32.lt_u
            br_if 0 (;@3;)
          end
        end
        local.get 5
        local.get 2
        local.get 4
        i32.sub
        local.tee 4
        i32.const -4
        i32.and
        local.tee 2
        i32.add
        local.set 3
        block ;; label = @2
          local.get 2
          i32.const 1
          i32.lt_s
          br_if 0 (;@2;)
          local.get 1
          i32.const 255
          i32.and
          i32.const 16843009
          i32.mul
          local.set 2
          loop ;; label = @3
            local.get 5
            local.get 2
            i32.store
            local.get 5
            i32.const 4
            i32.add
            local.tee 5
            local.get 3
            i32.lt_u
            br_if 0 (;@3;)
          end
        end
        local.get 4
        i32.const 3
        i32.and
        local.set 2
      end
      block ;; label = @1
        local.get 2
        i32.eqz
        br_if 0 (;@1;)
        local.get 3
        local.get 2
        i32.add
        local.set 5
        loop ;; label = @2
          local.get 3
          local.get 1
          i32.store8
          local.get 3
          i32.const 1
          i32.add
          local.tee 3
          local.get 5
          i32.lt_u
          br_if 0 (;@2;)
        end
      end
      local.get 0
    )
    (func $memcpy (;104;) (type 1) (param i32 i32 i32) (result i32)
      local.get 0
      local.get 1
      local.get 2
      call $_ZN17compiler_builtins3mem6memcpy17hfd20217541c602e1E
    )
    (func $memset (;105;) (type 1) (param i32 i32 i32) (result i32)
      local.get 0
      local.get 1
      local.get 2
      call $_ZN17compiler_builtins3mem6memset17ha0a3ab3a984e51d4E
    )
    (data $.rodata (;0;) (i32.const 1048576) "src/bindings.rs\00\00\00\10\00\0f\00\00\00\1f\00\00\00\07\00\00\00attempt to add with overflow\00\00\10\00\0f\00\00\00\1f\00\00\00\05\00\00\00\00\00\10\00\0f\00\00\00 \00\00\00\07\00\00\00\00\00\10\00\0f\00\00\00 \00\00\00\05\00\00\00\00\00\10\00\0f\00\00\00)\00\00\00\12\00\00\00\00\00\10\00\0f\00\00\00)\00\00\00\10\00\00\00\00\00\10\00\0f\00\00\00*\00\00\00\12\00\00\00\00\00\10\00\0f\00\00\00*\00\00\00\10\00\00\00HelloTried to shrink to a larger capacity\00\00\00\b1\00\10\00$\00\00\00/rustc/82e1608dfa6e0b5569232559e3d385fea5a93112/library/alloc/src/raw_vec.rs\e0\00\10\00L\00\00\00\b8\01\00\00\09\00\00\00invalid args<\01\10\00\0c\00\00\00/rustc/82e1608dfa6e0b5569232559e3d385fea5a93112/library/core/src/fmt/mod.rs\00P\01\10\00K\00\00\00C\01\00\00\0d\00\00\00/rustc/82e1608dfa6e0b5569232559e3d385fea5a93112/library/core/src/alloc/layout.rs\ac\01\10\00P\00\00\00\c1\01\00\00)\00\00\00\00\00\00\00attempt to divide by zero\00\00\00invalid args,\02\10\00\0c\00\00\00/rustc/82e1608dfa6e0b5569232559e3d385fea5a93112/library/core/src/fmt/mod.rs\00@\02\10\00K\00\00\00C\01\00\00\0d\00\00\00invalid args\9c\02\10\00\0c\00\00\00/rustc/82e1608dfa6e0b5569232559e3d385fea5a93112/library/core/src/fmt/mod.rs\00\b0\02\10\00K\00\00\00C\01\00\00\0d\00\00\00\01\00\00\00\04\00\00\00\04\00\00\00\02\00\00\00\00\00\00\00non-zero old_len requires non-zero new_len!\00 \03\10\00+\00\00\00/Users/rylev/.cargo/registry/src/index.crates.io-6f17d22bba15001f/wit-bindgen-0.16.0/src/lib.rs\00T\03\10\00_\00\00\00K\00\00\00\0d\00\00\00called `Option::unwrap()` on a `None` value\00\05\00\00\00\0c\00\00\00\04\00\00\00\06\00\00\00\07\00\00\00\08\00\00\00memory allocation of  bytes failed\00\00\08\04\10\00\15\00\00\00\1d\04\10\00\0d\00\00\00library/std/src/alloc.rs<\04\10\00\18\00\00\00b\01\00\00\09\00\00\00library/std/src/panicking.rsd\04\10\00\1c\00\00\00\84\02\00\00\1e\00\00\00\05\00\00\00\0c\00\00\00\04\00\00\00\09\00\00\00\0a\00\00\00\08\00\00\00\04\00\00\00\0b\00\00\00\0a\00\00\00\08\00\00\00\04\00\00\00\0c\00\00\00\0d\00\00\00\0e\00\00\00\10\00\00\00\04\00\00\00\0f\00\00\00\10\00\00\00\11\00\00\00\00\00\00\00\01\00\00\00\12\00\00\00library/alloc/src/raw_vec.rscapacity overflow\00\00\00\04\05\10\00\11\00\00\00\e8\04\10\00\1c\00\00\00!\02\00\00\05\00\00\00\18\00\00\00\00\00\00\00\01\00\00\00\19\00\00\00misaligned pointer dereference: address must be a multiple of  but is \00\00@\05\10\00>\00\00\00~\05\10\00\08\00\00\00==!=matchesassertion `left  right` failed\0a  left: \0a right: \00\a3\05\10\00\10\00\00\00\b3\05\10\00\17\00\00\00\ca\05\10\00\09\00\00\00 right` failed: \0a  left: \00\00\00\a3\05\10\00\10\00\00\00\ec\05\10\00\10\00\00\00\fc\05\10\00\09\00\00\00\ca\05\10\00\09\00\00\000xlibrary/core/src/fmt/num.rs\00\00\00*\06\10\00\1b\00\00\00i\00\00\00\17\00\00\0000010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899range start index  out of range for slice of length  \07\10\00\12\00\00\002\07\10\00\22\00\00\00")
  )
  (core instance (;0;) (instantiate 0))
  (alias core export 0 "memory" (core memory (;0;)))
  (alias core export 0 "cabi_realloc" (core func (;0;)))
  (type (;0;) (func (result string)))
  (alias core export 0 "hello" (core func (;1;)))
  (alias core export 0 "cabi_post_hello" (core func (;2;)))
  (func (;0;) (type 0) (canon lift (core func 1) (memory 0) string-encoding=utf8 (post-return 2)))
  (export (;1;) "hello" (func 0))
)
