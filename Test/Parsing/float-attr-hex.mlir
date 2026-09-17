// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_UNREGISTERED_ROUNDTRIP

// Verify that a 0x-prefixed hexadecimal literal is parsed as the raw IEEE-754
// bit pattern of the type and round-trips. Finite values use MLIR's decimal
// spelling; infinities and NaNs use uppercase hexadecimal, without padding.
// Includes special values: +inf, -inf, NaN, -0.0, +0.0.

"builtin.module"() ({
    "test.test"() { a = 0x7f800000 : f32, b = 0xfff0000000000000 : f64, c = 0x7fc00000 : f32, d = 0x8000 : f16, e = 0x00000000 : f32, f = 0x1 : f32 } : () -> ()
    // CHECK:     "test.test"() {"a" = 0x7F800000 : f32, "b" = 0xFFF0000000000000 : f64, "c" = 0x7FC00000 : f32, "d" = -0.000000e+00 : f16, "e" = 0.000000e+00 : f32, "f" = 1.401300e-45 : f32} : () -> ()
}) : () -> ()
