// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (!llvm.struct<(i32, !llvm.array<2 x i64>)>)>, linkage = #llvm.linkage<external>, sym_name = "f"}> ({
  ^bb0(%a: !llvm.struct<(i32, !llvm.array<2 x i64>)>):
    %v = "llvm.extractvalue"(%a) <{position = array<i64: 1, -1>}> : (!llvm.struct<(i32, !llvm.array<2 x i64>)>) -> i64
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: llvm.extractvalue: position out of bounds: -1
