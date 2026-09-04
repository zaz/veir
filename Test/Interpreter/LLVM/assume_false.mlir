// RUN: veir-interpret %s | filecheck %s

// `llvm.intr.assume` of a false condition is immediate UB.
"builtin.module"() ({
  "func.func"() <{sym_name = "main", function_type = () -> i32}> ({
    %f = "llvm.mlir.constant"() <{ "value" = 0 : i1 }> : () -> i1
    %x = "llvm.mlir.constant"() <{ "value" = 42 : i32 }> : () -> i32
    "llvm.intr.assume"(%f) <{ "op_bundle_sizes" = array<i32> }> : (i1) -> ()
    "func.return"(%x) : (i32) -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: Undefined behavior
