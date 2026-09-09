// RUN: VEIR_ROUNDTRIP
// RUN: %if mlir-min-23 %{ MLIR_ROUNDTRIP %}

"builtin.module"() ({
  "func.func"() <{function_type = (!llvm.byte<8388607>) -> (), sym_name = "f"}> ({
  ^bb0(%x: !llvm.byte<8388607>):
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: ^{{.*}}(%{{.*}} : !llvm.byte<8388607>):
