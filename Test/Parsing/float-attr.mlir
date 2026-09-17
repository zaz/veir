// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_UNREGISTERED_ROUNDTRIP

"builtin.module"() ({
    "test.test"() { a = 1.5 : f64, b = -2.25 : f64, c = 100.5 : f64, d = 0.5 : f32, e = 1.5 : f16, f = 1.5 : bf16 } : () -> ()
    // CHECK:     "test.test"() {"a" = 1.500000e+00 : f64, "b" = -2.250000e+00 : f64, "c" = 1.005000e+02 : f64, "d" = 5.000000e-01 : f32, "e" = 1.500000e+00 : f16, "f" = 1.500000e+00 : bf16} : () -> ()
}) : () -> ()
