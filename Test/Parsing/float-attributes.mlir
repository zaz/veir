// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_UNREGISTERED_ROUNDTRIP

// Decimal and scientific float literals, and MLIR's hexadecimal raw-bit form,
// parse to the correctly rounded binary64 value; printing emulates MLIR's
// printFloatValue byte for byte (6-digit scientific when it round-trips,
// 17-digit natural precision when it contains '.', raw bits otherwise).

"builtin.module"() ({
    "test.test"() { neg = -2.5 : f64, one = 1.0 : f64, sci = 2.5e1 : f64, small = 0.001 : f64 } : () -> ()
    // CHECK: "test.test"() {"neg" = -2.500000e+00 : f64, "one" = 1.000000e+00 : f64, "sci" = 2.500000e+01 : f64, "small" = 1.000000e-03 : f64} : () -> ()
    "test.test"() { third = 0.1 : f64, pathological = 6016.951217939863 : f64 } : () -> ()
    // CHECK: "test.test"() {"pathological" = 6016.9512179398635 : f64, "third" = 1.000000e-01 : f64} : () -> ()
    "test.test"() { hex = 0x3FF0000000000000 : f64, nan = 0x7FF8000000000000 : f64, ninf = 0xFFF0000000000000 : f64 } : () -> ()
    // CHECK: "test.test"() {"hex" = 1.000000e+00 : f64, "nan" = 0x7FF8000000000000 : f64, "ninf" = 0xFFF0000000000000 : f64} : () -> ()
    "test.test"() { nodot = 123456789000.0 : f64, subnormal = 4.9e-324 : f64 } : () -> ()
    // CHECK: "test.test"() {"nodot" = 0x423CBE991A080000 : f64, "subnormal" = 4.940660e-324 : f64} : () -> ()
}) : () -> ()
