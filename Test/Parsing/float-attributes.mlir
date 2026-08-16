// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_UNREGISTERED_ROUNDTRIP

// Decimal and scientific float literals, and MLIR's hexadecimal raw-bit form,
// parse to the correctly rounded binary64 value. Values here are restricted to
// ones the current printer reproduces faithfully; NaN and values needing
// shortest-form printing are covered by unit tests until printing follows up.

"builtin.module"() ({
    "test.test"() { neg = -2.5 : f64, one = 1.0 : f64, small = 0.001 : f64, sci = 2.5e1 : f64 } : () -> ()
    // CHECK: "test.test"() {"neg" = -2.500000 : f64, "one" = 1.000000 : f64, "sci" = 25.000000 : f64, "small" = 0.001000 : f64} : () -> ()
    "test.test"() { hex = 0x3FF0000000000000 : f64 } : () -> ()
    // CHECK: "test.test"() {"hex" = 1.000000 : f64} : () -> ()
}) : () -> ()
