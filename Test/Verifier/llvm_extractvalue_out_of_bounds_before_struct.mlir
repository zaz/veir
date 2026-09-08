// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (!llvm.array<2 x !llvm.struct<(i32, i64)>>)>, linkage = #llvm.linkage<external>, sym_name = "f"}> ({
  ^bb0(%a: !llvm.array<2 x !llvm.struct<(i32, i64)>>):
    %v = "llvm.extractvalue"(%a) <{position = array<i64: 2, 0>}> : (!llvm.array<2 x !llvm.struct<(i32, i64)>>) -> i32
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: llvm.extractvalue: position out of bounds: 2
