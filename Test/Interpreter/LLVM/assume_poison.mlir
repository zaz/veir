// RUN: veir-interpret %s | filecheck %s

// `llvm.intr.assume` of a poison condition is immediate UB, like branching
// on poison.
"builtin.module"() ({
  "func.func"() <{sym_name = "main", function_type = () -> i32}> ({
    %poison = "llvm.mlir.poison"() : () -> i1
    %x = "llvm.mlir.constant"() <{ "value" = 42 : i32 }> : () -> i32
    "llvm.intr.assume"(%poison) <{ "op_bundle_sizes" = array<i32> }> : (i1) -> ()
    "func.return"(%x) : (i32) -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: Undefined behavior
