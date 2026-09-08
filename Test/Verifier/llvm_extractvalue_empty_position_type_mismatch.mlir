// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (!llvm.struct<(i32, i64)>)>, linkage = #llvm.linkage<external>, sym_name = "f"}> ({
  ^bb0(%a: !llvm.struct<(i32, i64)>):
    %v = "llvm.extractvalue"(%a) <{position = array<i64>}> : (!llvm.struct<(i32, i64)>) -> i64
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: llvm.extractvalue: Type mismatch: extracting from !llvm.struct<(i32, i64)> should produce !llvm.struct<(i32, i64)> but this op returns i64
