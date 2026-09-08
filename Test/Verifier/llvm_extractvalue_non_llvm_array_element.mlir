// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (!llvm.array<1 x index>)>, linkage = #llvm.linkage<external>, sym_name = "f"}> ({
  ^bb0(%a: !llvm.array<1 x index>):
    %r = "llvm.extractvalue"(%a) <{position = array<i64: 0>}> : (!llvm.array<1 x index>) -> index
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: llvm.extractvalue: operand 0 must be an LLVM dialect-compatible type, but got !llvm.array<1 x index>
