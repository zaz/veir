// RUN: veir-interpret %s | filecheck %s

// `llvm.intr.assume` of a true condition is a no-op.
"builtin.module"() ({
  "func.func"() <{sym_name = "main", function_type = () -> i32}> ({
    %t = "llvm.mlir.constant"() <{ "value" = 1 : i1 }> : () -> i1
    %x = "llvm.mlir.constant"() <{ "value" = 42 : i32 }> : () -> i32
    "llvm.intr.assume"(%t) <{ "op_bundle_sizes" = array<i32> }> : (i1) -> ()
    "func.return"(%x) : (i32) -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: Program output: #[0x0000002a#32]
