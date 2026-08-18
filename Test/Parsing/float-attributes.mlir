// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_UNREGISTERED_ROUNDTRIP

// Decimal and scientific float literals, and MLIR's hexadecimal raw-bit form,
// parse to the correctly rounded binary64 value; printing emits the shortest
// round-trip decimal (Schubfach), with raw-bit hex for NaN and infinities.
// Every printed form is parseable by both VeIR and MLIR, so the mixed
// mlir-opt pipelines below reach the same fixpoint.

"builtin.module"() ({
    "test.test"() { neg = -2.5 : f64, one = 1.0 : f64, sci = 2.5e1 : f64, small = 0.001 : f64 } : () -> ()
    // CHECK: "test.test"() {"neg" = -2.5 : f64, "one" = 1.0 : f64, "sci" = 25.0 : f64, "small" = 0.001 : f64} : () -> ()
    "test.test"() { third = 0.1 : f64, pathological = 6016.951217939863 : f64 } : () -> ()
    // CHECK: "test.test"() {"pathological" = 6016.951217939863 : f64, "third" = 0.1 : f64} : () -> ()
    "test.test"() { hex = 0x3FF0000000000000 : f64, nan = 0x7FF8000000000000 : f64, ninf = 0xFFF0000000000000 : f64 } : () -> ()
    // CHECK: "test.test"() {"hex" = 1.0 : f64, "nan" = 0x7FF8000000000000 : f64, "ninf" = 0xFFF0000000000000 : f64} : () -> ()
    "test.test"() { nodot = 123456789000.0 : f64, subnormal = 4.9e-324 : f64 } : () -> ()
    // CHECK: "test.test"() {"nodot" = 123456789000.0 : f64, "subnormal" = 5.0e-324 : f64} : () -> ()
}) : () -> ()
