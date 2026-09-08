// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (!llvm.array<2 x i32>)>, linkage = #llvm.linkage<external>, sym_name = "f"}> ({
  ^bb0(%a: !llvm.array<2 x i32>):
    %v = "llvm.extractvalue"(%a) <{position = 0 : i64}> : (!llvm.array<2 x i32>) -> i32
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: llvm.extractvalue: expected 'position' to be a dense array attribute
