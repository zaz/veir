// RUN: VEIR_ROUNDTRIP
// RUN: %if mlir-opt %{ mlir-opt --mlir-print-op-generic --allow-unregistered-dialect %s | veir-opt --allow-unregistered-dialect --print-op-generic | filecheck %s %}

// MLIR's scalar decimal reader passes through double, so a second MLIR parse
// would underflow the smallest f128 subnormal to zero. Check one MLIR print
// and round-trip its spelling through VeIR's format-aware reader instead.

"builtin.module"() ({
    "test.test"() { a = 1.5 : f80, b = -2.25 : f80, c = 1.5 : f128, d = 0.5 : f128, e = 0x7fff8000000000000000 : f80, f = 0x1 : f128 } : () -> ()
    // CHECK:     "test.test"() {"a" = 1.500000e+00 : f80, "b" = -2.250000e+00 : f80, "c" = 1.500000e+00 : f128, "d" = 5.000000e-01 : f128, "e" = 0x7FFF8000000000000000 : f80, "f" = 6.475180e-4966 : f128} : () -> ()
}) : () -> ()
