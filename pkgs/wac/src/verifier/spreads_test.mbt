// Original spread probes against pinned WAC 0.12.0 Document::resolve.
// Crossed resources retain the nominal rejection required by validating compose.

// (component (type (func)) (import "f" (func (type 0))) (import "g" (func (type 0))) (export "out" (func 0)))

///|
fn spread_pair_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x0b\x02\x00\x01\x66\x01\x00\x00\x01\x67\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (type (func)) (import "f" (func (type 0))) (import "g" (func (type 0))) (import "h" (func (type 0))) (export "out" (func 0)))

///|
fn spread_triple_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x10\x03\x00\x01\x66\x01\x00\x00\x01\x67\x01\x00\x00\x01\x68\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00"
}

// (component (import "handle" (type (sub resource))) (type (func (param "h" (own 0)))) (import "take" (func (type 2))) (export "take" (func 0)))

///|
fn spread_resource_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x02\x0b\x0a\x01\x00\x04\x74\x61\x6b\x65\x01\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0" (instance (type 0))))

///|
fn spread_version_major_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.9.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_major_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x39\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.9.0" (instance (type 0))))

///|
fn spread_version_older_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x39\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.2.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_older_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@2.0.0" (instance (type 0))))

///|
fn spread_version_major_different_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x32\x2e\x30\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.9.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_major_different_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x39\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@0.2.1" (instance (type 0))))

///|
fn spread_version_minor_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x32\x2e\x31\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@0.2.9" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_minor_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x32\x2e\x39\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@0.2.0" (instance (type 0))))

///|
fn spread_version_minor_different_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x32\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@0.3.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_minor_different_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x33\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@0.0.1" (instance (type 0))))

///|
fn spread_version_patch_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x30\x2e\x31\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@0.0.2" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_patch_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x30\x2e\x32\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.0.0-rc.1" (instance (type 0))))

///|
fn spread_version_pre_exact_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1c\x01\x00\x17\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x72\x63\x2e\x31\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.0.0-rc.1" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_pre_exact_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x46\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x17\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x72\x63\x2e\x31\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.0.0-rc.1" (instance (type 0))))

///|
fn spread_version_pre_different_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1c\x01\x00\x17\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x72\x63\x2e\x31\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.0.0-rc.2" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_pre_different_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x46\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x17\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x72\x63\x2e\x32\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.0.0" (instance (type 0))))

///|
fn spread_version_pre_stable_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.0.0-rc.1" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_pre_stable_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x46\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x17\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2d\x72\x63\x2e\x31\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.0.0+first" (instance (type 0))))

///|
fn spread_version_build_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1d\x01\x00\x18\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x66\x69\x72\x73\x74\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.0.0+second" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_build_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x48\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x19\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x73\x65\x63\x6f\x6e\x64\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@0.0.1+first" (instance (type 0))))

///|
fn spread_version_patch_build_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1d\x01\x00\x18\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x30\x2e\x31\x2b\x66\x69\x72\x73\x74\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@0.0.1+second" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_patch_build_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x48\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x19\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x30\x2e\x30\x2e\x31\x2b\x73\x65\x63\x6f\x6e\x64\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.0.0+first-a" (instance (type 0))))

///|
fn spread_version_build_dash_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x1f\x01\x00\x1a\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x2b\x66\x69\x72\x73\x74\x2d\x61\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.9.0+second-b" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_build_dash_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4a\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x1b\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x39\x2e\x30\x2b\x73\x65\x63\x6f\x6e\x64\x2d\x62\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@18446744073709551615.1.0" (instance (type 0))))

///|
fn spread_version_max_major_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x2a\x01\x00\x25\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x38\x34\x34\x36\x37\x34\x34\x30\x37\x33\x37\x30\x39\x35\x35\x31\x36\x31\x35\x2e\x31\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@18446744073709551615.2.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_max_major_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x54\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x25\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x38\x34\x34\x36\x37\x34\x34\x30\x37\x33\x37\x30\x39\x35\x35\x31\x36\x31\x35\x2e\x32\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0" (instance (type 0))))

///|
fn spread_version_exact_wins_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.9.0" (instance (type 0)))(export "test:api/run@1.2.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_exact_wins_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x58\x01\x41\x02\x01\x42\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x39\x2e\x30\x05\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0" (instance (type 0))))

///|
fn spread_version_first_compatible_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x17\x01\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.9.0" (instance (type 0)))(export "test:api/run@1.3.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_first_compatible_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x58\x01\x41\x02\x01\x42\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x39\x2e\x30\x05\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x33\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run" (instance (type 0))))

///|
fn spread_version_unversioned_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_unversioned_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x3b\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

// (component (type (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run" (instance (type 0))))

///|
fn spread_version_one_unversioned_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x11\x01\x00\x0c\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x05\x00"
}

// (component (type (component (type (instance (type (instance (type (func)) (export "f" (func (type 0))))) (export "test:api/run@1.0.0" (instance (type 0))))) (export "test:provider/api" (instance (type 0))))) (export "api" (type 0)))

///|
fn spread_provider_one_unversioned_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x01\x41\x02\x01\x42\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x04\x00\x11\x74\x65\x73\x74\x3a\x70\x72\x6f\x76\x69\x64\x65\x72\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

///|
test "pinned spread all" {
  let source = "package test:app; interface api {f: func();g: func();} import a: api; let i=new lookup:dep {...a}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "a", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "2", "api",
    "type", "interface", "test:app/api", "0", "2", "f", "func", "function", "false",
    "0", "none", "g", "func", "function", "false", "0", "none", "out", "func", "function",
    "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "6", "definition", "type", "interface", "test:app/api", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "alias:1:f",
    "func", "function", "false", "0", "none", "alias:1:g", "func", "function", "false",
    "0", "none", "instance:lookup:dep", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "0", "none", "alias:4:out", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "alias", "1", "f", "3", "alias", "1", "g", "4", "f", "2", "4", "g", "3",
    "5", "alias", "4", "out",
  ])
}

///|
test "pinned spread explicit-after" {
  let source = "package test:app; interface api {f: func();g: func();} import a: api; import f: func(); let i=new lookup:dep {...a, f}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "f", "func",
    "function", "false", "0", "none", "2", "api", "type", "interface", "test:app/api",
    "0", "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "0", "none", "out", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "6", "definition", "type", "interface", "test:app/api", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "import:f",
    "func", "function", "false", "0", "none", "alias:1:g", "func", "function", "false",
    "0", "none", "instance:lookup:dep", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "0", "none", "alias:4:out", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "3", "alias", "1", "g", "4", "f", "2", "4", "g", "3", "5", "alias", "4", "out",
  ])
}

///|
test "pinned spread explicit-before" {
  let source = "package test:app; interface api {f: func();g: func();} import a: api; import f: func(); let i=new lookup:dep {f, ...a}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "f", "func",
    "function", "false", "0", "none", "2", "api", "type", "interface", "test:app/api",
    "0", "2", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "0", "none", "out", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "6", "definition", "type", "interface", "test:app/api", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "import:f",
    "func", "function", "false", "0", "none", "alias:1:g", "func", "function", "false",
    "0", "none", "instance:lookup:dep", "instance", "interface", "", "0", "1", "out",
    "func", "function", "false", "0", "none", "alias:4:out", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "3", "alias", "1", "g", "4", "f", "2", "4", "g", "3", "5", "alias", "4", "out",
  ])
}

///|
test "pinned spread no-effect" {
  let source = "package test:app; interface api {f: func();g: func();} import a: api; import f: func(); import g: func(); let i=new lookup:dep {...a,f,g};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread no-match" {
  let source = "package test:app; interface api {h: func();} import a: api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread duplicate" {
  let source = "package test:app; interface api {f: func();g: func();} import a: api; let i=new lookup:dep {...a,...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread wrong-kind" {
  let source = "package test:app; import f: func(); let i=new lookup:dep {...f};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread missing-binding" {
  let source = "package test:app; let i=new lookup:dep {...missing};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread wrong-type" {
  let source = "package test:app; interface api {f: func(x: u32);g: func();} import a: api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread partial" {
  let source = "package test:app; interface api {f: func();} import a: api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread two" {
  let source = "package test:app; interface one {f: func();} interface two {g: func();} import a: one; import b: two; let i=new lookup:dep {...a,...b}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "pair.wasm",
      bytes: spread_pair_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/one", "0", "1", "f", "func", "function",
    "false", "0", "none", "b", "instance", "interface", "test:app/two", "0", "1",
    "g", "func", "function", "false", "0", "none", "3", "one", "type", "interface",
    "test:app/one", "0", "1", "f", "func", "function", "false", "0", "none", "two",
    "type", "interface", "test:app/two", "0", "1", "g", "func", "function", "false",
    "0", "none", "out", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "8", "definition", "type", "interface", "test:app/one", "0", "1", "f", "func",
    "function", "false", "0", "none", "definition", "type", "interface", "test:app/two",
    "0", "1", "g", "func", "function", "false", "0", "none", "import:a", "instance",
    "interface", "test:app/one", "0", "1", "f", "func", "function", "false", "0",
    "none", "import:b", "instance", "interface", "test:app/two", "0", "1", "g", "func",
    "function", "false", "0", "none", "alias:2:f", "func", "function", "false", "0",
    "none", "alias:3:g", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "0",
    "none", "alias:6:out", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "4", "alias", "2", "f", "5", "alias", "3", "g", "6", "f", "4", "6", "g", "5",
    "7", "alias", "6", "out",
  ])
}

///|
test "pinned spread ordered" {
  let source = "package test:app; interface one {f: func();g: func();} interface two {g: func();h: func();} import a: one; import b: two; let i=new lookup:dep {...a,...b}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "triple.wasm",
      bytes: spread_triple_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/one", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "b", "instance",
    "interface", "test:app/two", "0", "2", "g", "func", "function", "false", "0",
    "none", "h", "func", "function", "false", "0", "none", "3", "one", "type", "interface",
    "test:app/one", "0", "2", "f", "func", "function", "false", "0", "none", "g",
    "func", "function", "false", "0", "none", "two", "type", "interface", "test:app/two",
    "0", "2", "g", "func", "function", "false", "0", "none", "h", "func", "function",
    "false", "0", "none", "out", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "9", "definition", "type", "interface", "test:app/one", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "definition", "type", "interface", "test:app/two", "0", "2", "g", "func", "function",
    "false", "0", "none", "h", "func", "function", "false", "0", "none", "import:a",
    "instance", "interface", "test:app/one", "0", "2", "f", "func", "function", "false",
    "0", "none", "g", "func", "function", "false", "0", "none", "import:b", "instance",
    "interface", "test:app/two", "0", "2", "g", "func", "function", "false", "0",
    "none", "h", "func", "function", "false", "0", "none", "alias:2:f", "func", "function",
    "false", "0", "none", "alias:2:g", "func", "function", "false", "0", "none",
    "alias:3:h", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "0",
    "none", "alias:7:out", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "4", "alias", "2", "f", "5", "alias", "2", "g", "6", "alias", "3", "h", "7",
    "f", "4", "7", "g", "5", "7", "h", "6", "8", "alias", "7", "out",
  ])
}

///|
test "pinned spread reverse" {
  let source = "package test:app; interface one {f: func();g: func();} interface two {g: func();h: func();} import a: one; import b: two; let i=new lookup:dep {...b,...a}; export i.out;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "triple.wasm",
      bytes: spread_triple_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/one", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "b", "instance",
    "interface", "test:app/two", "0", "2", "g", "func", "function", "false", "0",
    "none", "h", "func", "function", "false", "0", "none", "3", "one", "type", "interface",
    "test:app/one", "0", "2", "f", "func", "function", "false", "0", "none", "g",
    "func", "function", "false", "0", "none", "two", "type", "interface", "test:app/two",
    "0", "2", "g", "func", "function", "false", "0", "none", "h", "func", "function",
    "false", "0", "none", "out", "func", "function", "false", "0", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "9", "definition", "type", "interface", "test:app/one", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "definition", "type", "interface", "test:app/two", "0", "2", "g", "func", "function",
    "false", "0", "none", "h", "func", "function", "false", "0", "none", "import:a",
    "instance", "interface", "test:app/one", "0", "2", "f", "func", "function", "false",
    "0", "none", "g", "func", "function", "false", "0", "none", "import:b", "instance",
    "interface", "test:app/two", "0", "2", "g", "func", "function", "false", "0",
    "none", "h", "func", "function", "false", "0", "none", "alias:3:g", "func", "function",
    "false", "0", "none", "alias:3:h", "func", "function", "false", "0", "none",
    "alias:2:f", "func", "function", "false", "0", "none", "instance:lookup:dep",
    "instance", "interface", "", "0", "1", "out", "func", "function", "false", "0",
    "none", "alias:7:out", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "4", "alias", "3", "g", "5", "alias", "3", "h", "6", "alias", "2", "f", "7",
    "f", "6", "7", "g", "4", "7", "h", "5", "8", "alias", "7", "out",
  ])
}

///|
test "pinned spread resource" {
  let source = "package test:app; interface api {resource handle; take: func(h: handle);} import a: api; let i=new lookup:dep {...a}; export i.take;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "resource.wasm",
      bytes: spread_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "2", "api", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "take", "func", "function", "false", "1", "h", "own", "1", "none",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "6", "definition", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "import:a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "alias:1:handle", "type", "resource", "0", "alias:1:take", "func", "function",
    "false", "1", "h", "own", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "1", "take", "func", "function", "false", "1", "h", "own", "1", "none",
    "alias:4:take", "func", "function", "false", "1", "h", "own", "1", "none", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "2", "alias", "1", "handle", "3", "alias", "1", "take", "4", "handle", "2", "4",
    "take", "3", "5", "alias", "4", "take",
  ])
}

///|
test "pinned spread resource-crossed" {
  let source = "package test:app; interface api {resource handle; take: func(h: handle);} import a: api; import b: api; let i=new lookup:dep {handle: b.handle,...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "resource.wasm",
      bytes: spread_resource_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C005")
}

///|
test "pinned spread major" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-major.wasm",
      bytes: spread_version_major_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-major.wasm",
      bytes: spread_provider_major_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@1.9.0", "instance", "interface", "test:api/run@1.9.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@1.9.0", "instance", "interface", "test:api/run@1.9.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.9.0",
    "instance", "interface", "test:api/run@1.9.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance:lookup:dep", "instance", "interface", "", "0",
    "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.9.0", "2", "test:api/run@1.2.0", "1",
  ])
}

///|
test "pinned spread older" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-older.wasm",
      bytes: spread_version_older_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-older.wasm",
      bytes: spread_provider_older_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@1.2.0", "instance", "interface", "test:api/run@1.2.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@1.2.0", "instance", "interface", "test:api/run@1.2.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.2.0",
    "instance", "interface", "test:api/run@1.2.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance:lookup:dep", "instance", "interface", "", "0",
    "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.2.0", "2", "test:api/run@1.9.0", "1",
  ])
}

///|
test "pinned spread major-different" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-major-different.wasm",
      bytes: spread_version_major_different_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-major-different.wasm",
      bytes: spread_provider_major_different_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread minor" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-minor.wasm",
      bytes: spread_version_minor_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-minor.wasm",
      bytes: spread_provider_minor_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@0.2.9", "instance", "interface", "test:api/run@0.2.9", "0",
    "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@0.2.9", "instance", "interface", "test:api/run@0.2.9",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@0.2.9",
    "instance", "interface", "test:api/run@0.2.9", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance:lookup:dep", "instance", "interface", "", "0",
    "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@0.2.9", "2", "test:api/run@0.2.1", "1",
  ])
}

///|
test "pinned spread minor-different" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-minor-different.wasm",
      bytes: spread_version_minor_different_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-minor-different.wasm",
      bytes: spread_provider_minor_different_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread patch" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-patch.wasm",
      bytes: spread_version_patch_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-patch.wasm",
      bytes: spread_provider_patch_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread pre-exact" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-pre-exact.wasm",
      bytes: spread_version_pre_exact_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-pre-exact.wasm",
      bytes: spread_provider_pre_exact_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@1.0.0-rc.1", "instance", "interface", "test:api/run@1.0.0-rc.1",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@1.0.0-rc.1", "instance", "interface", "test:api/run@1.0.0-rc.1",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.0.0-rc.1",
    "instance", "interface", "test:api/run@1.0.0-rc.1", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance:lookup:dep", "instance", "interface", "", "0",
    "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.0.0-rc.1", "2", "test:api/run@1.0.0-rc.1",
    "1",
  ])
}

///|
test "pinned spread pre-different" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-pre-different.wasm",
      bytes: spread_version_pre_different_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-pre-different.wasm",
      bytes: spread_provider_pre_different_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread pre-stable" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-pre-stable.wasm",
      bytes: spread_version_pre_stable_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-pre-stable.wasm",
      bytes: spread_provider_pre_stable_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread build" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-build.wasm",
      bytes: spread_version_build_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-build.wasm",
      bytes: spread_provider_build_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@1.0.0+second", "instance", "interface", "test:api/run@1.0.0+second",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@1.0.0+second", "instance", "interface", "test:api/run@1.0.0+second",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.0.0+second",
    "instance", "interface", "test:api/run@1.0.0+second", "0", "1", "f", "func",
    "function", "false", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.0.0+second", "2", "test:api/run@1.0.0+first",
    "1",
  ])
}

///|
test "pinned spread patch-build" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-patch-build.wasm",
      bytes: spread_version_patch_build_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-patch-build.wasm",
      bytes: spread_provider_patch_build_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "pinned spread build-dash" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-build-dash.wasm",
      bytes: spread_version_build_dash_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-build-dash.wasm",
      bytes: spread_provider_build_dash_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@1.9.0+second-b", "instance", "interface", "test:api/run@1.9.0+second-b",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@1.9.0+second-b", "instance", "interface", "test:api/run@1.9.0+second-b",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.9.0+second-b",
    "instance", "interface", "test:api/run@1.9.0+second-b", "0", "1", "f", "func",
    "function", "false", "0", "none", "instance:lookup:dep", "instance", "interface",
    "", "0", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.9.0+second-b", "2", "test:api/run@1.0.0+first-a",
    "1",
  ])
}

///|
test "pinned spread max-major" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-max-major.wasm",
      bytes: spread_version_max_major_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-max-major.wasm",
      bytes: spread_provider_max_major_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run@18446744073709551615.2.0", "instance", "interface", "test:api/run@18446744073709551615.2.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run@18446744073709551615.2.0", "instance", "interface", "test:api/run@18446744073709551615.2.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@18446744073709551615.2.0",
    "instance", "interface", "test:api/run@18446744073709551615.2.0", "0", "1", "f",
    "func", "function", "false", "0", "none", "instance:lookup:dep", "instance",
    "interface", "", "0", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@18446744073709551615.2.0", "2", "test:api/run@18446744073709551615.1.0",
    "1",
  ])
}

///|
test "pinned spread exact-wins" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-exact-wins.wasm",
      bytes: spread_version_exact_wins_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-exact-wins.wasm",
      bytes: spread_provider_exact_wins_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "2", "test:api/run@1.9.0", "instance", "interface", "test:api/run@1.9.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "test:api/run@1.2.0", "instance",
    "interface", "test:api/run@1.9.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "2", "test:api/run@1.9.0", "instance", "interface", "test:api/run@1.9.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "test:api/run@1.2.0",
    "instance", "interface", "test:api/run@1.9.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:0:test:api/run@1.2.0", "instance", "interface",
    "test:api/run@1.9.0", "0", "1", "f", "func", "function", "false", "0", "none",
    "instance:lookup:dep", "instance", "interface", "", "0", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.2.0", "2", "test:api/run@1.2.0", "1",
  ])
}

///|
test "pinned spread first-compatible" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-first-compatible.wasm",
      bytes: spread_version_first_compatible_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-first-compatible.wasm",
      bytes: spread_provider_first_compatible_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "2", "test:api/run@1.9.0", "instance", "interface", "test:api/run@1.9.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "test:api/run@1.3.0", "instance",
    "interface", "test:api/run@1.9.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "2", "test:api/run@1.9.0", "instance", "interface", "test:api/run@1.9.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "test:api/run@1.3.0",
    "instance", "interface", "test:api/run@1.9.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:0:test:api/run@1.9.0", "instance", "interface",
    "test:api/run@1.9.0", "0", "1", "f", "func", "function", "false", "0", "none",
    "instance:lookup:dep", "instance", "interface", "", "0", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run@1.9.0", "2", "test:api/run@1.2.0", "1",
  ])
}

///|
test "pinned spread unversioned" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-unversioned.wasm",
      bytes: spread_version_unversioned_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-unversioned.wasm",
      bytes: spread_provider_unversioned_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:provider/api", "instance", "interface", "test:provider/api", "0",
    "1", "test:api/run", "instance", "interface", "test:api/run", "0", "1", "f",
    "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_projection(result.unwrap()), [
    "3", "import:lookup:provider/api", "instance", "interface", "test:provider/api",
    "0", "1", "test:api/run", "instance", "interface", "test:api/run", "0", "1",
    "f", "func", "function", "false", "0", "none", "alias:0:test:api/run", "instance",
    "interface", "test:api/run", "0", "1", "f", "func", "function", "false", "0",
    "none", "instance:lookup:dep", "instance", "interface", "", "0", "0", "0",
  ])
  assert_eq(composition_edges(result.unwrap()), [
    "1", "alias", "0", "test:api/run", "2", "test:api/run", "1",
  ])
}

///|
test "pinned spread one-unversioned" {
  let source = "package test:app; import a: lookup:provider/api; let i=new lookup:dep {...a};"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "version-one-unversioned.wasm",
      bytes: spread_version_one_unversioned_bytes(),
    },
    {
      name: "lookup:provider",
      version: None,
      source: "provider-one-unversioned.wasm",
      bytes: spread_provider_one_unversioned_bytes(),
    },
  ])
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}
