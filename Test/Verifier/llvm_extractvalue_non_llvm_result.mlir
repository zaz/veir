// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (!llvm.struct<(i32)>)>, linkage = #llvm.linkage<external>, sym_name = "f"}> ({
  ^bb0(%a: !llvm.struct<(i32)>):
    %r = "llvm.extractvalue"(%a) <{position = array<i64: 0>}> : (!llvm.struct<(i32)>) -> index
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: llvm.extractvalue: result 0 must be an LLVM dialect-compatible type, but got index
