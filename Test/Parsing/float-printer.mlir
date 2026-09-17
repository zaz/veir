// RUN: VEIR_UNREGISTERED_ROUNDTRIP
// RUN: mlir-opt %s --allow-unregistered-dialect --mlir-print-op-generic | veir-opt --allow-unregistered-dialect --print-op-generic | filecheck %s
// RUN: mlir-opt %s --allow-unregistered-dialect --mlir-print-op-generic | filecheck %s --check-prefix=MLIR
// REQUIRES: mlir-opt

// Compare MLIR's output directly too: checking only after VeIR could hide
// different spellings. Use one MLIR print because its scalar decimal reader
// goes through double and underflows the f128 case on a second MLIR parse.
"builtin.module"() ({
  "test.fp"() {value = 0.1 : f64} : () -> ()
  // CHECK: "value" = 1.000000e-01 : f64
  // MLIR: value = 1.000000e-01 : f64
  "test.fp"() {value = -0.0 : f32} : () -> ()
  // CHECK: "value" = -0.000000e+00 : f32
  // MLIR: value = -0.000000e+00 : f32
  "test.fp"() {value = 0x3ff0000000000001 : f64} : () -> ()
  // CHECK: "value" = 1.0000000000000002 : f64
  // MLIR: value = 1.0000000000000002 : f64
  "test.fp"() {value = 0x3f543a272d955e51 : f64} : () -> ()
  // CHECK: "value" = 0.0012345678899999999 : f64
  // MLIR: value = 0.0012345678899999999 : f64
  "test.fp"() {value = 0x3f202e85be111841 : f64} : () -> ()
  // CHECK: "value" = 1.23456789E-4 : f64
  // MLIR: value = 1.23456789E-4 : f64
  "test.fp"() {value = 0x0d42528da9d3d7c7 : f64} : () -> ()
  // CHECK: "value" = 8.3856677392886631E-245 : f64
  // MLIR: value = 8.3856677392886631E-245 : f64
  "test.fp"() {value = 1234567.0 : f64} : () -> ()
  // CHECK: "value" = 0x4132D68700000000 : f64
  // MLIR: value = 0x4132D68700000000 : f64
  "test.fp"() {value = 0x7ff0000000000001 : f64} : () -> ()
  // CHECK: "value" = 0x7FF0000000000001 : f64
  // MLIR: value = 0x7FF0000000000001 : f64
  "test.fp"() {value = 0xfff8123456789abc : f64} : () -> ()
  // CHECK: "value" = 0xFFF8123456789ABC : f64
  // MLIR: value = 0xFFF8123456789ABC : f64
  "test.fp"() {value = 0x1 : f128} : () -> ()
  // CHECK: "value" = 6.475180e-4966 : f128
  // MLIR: value = 6.475180e-4966 : f128
}) : () -> ()
