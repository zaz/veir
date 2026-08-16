// RUN: not veir-opt %s 2>&1 | filecheck %s --strict-whitespace

// Verify that a decimal integer literal with a float type is rejected, with
// the same guidance MLIR gives.

"builtin.module"() ({
  %a = "test.test"() <{"value" = 5 : f64}> : () -> f64
}) : () -> ()

// CHECK:invalid-float-attr.mlir:7:34: error: expected floating point literal; add a trailing dot to make the literal a float
// CHECK-NEXT:  %a = "test.test"() <{"value" = 5 : f64}> : () -> f64
// CHECK-NEXT:                                  ^
