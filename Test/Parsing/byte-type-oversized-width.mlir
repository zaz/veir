// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "func.func"() <{function_type = (!llvm.byte<8388608>) -> (), sym_name = "f"}> ({
  ^bb0(%x: !llvm.byte<8388608>):
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: bitwidth must be less than 8388608, but got 8388608
