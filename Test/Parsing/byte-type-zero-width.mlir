// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "func.func"() <{function_type = (!llvm.byte<0>) -> (), sym_name = "f"}> ({
  ^bb0(%x: !llvm.byte<0>):
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: bitwidth must be greater than 0
