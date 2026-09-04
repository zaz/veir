// RUN: veir-interpret %s | filecheck %s

// Lifetime markers are no-ops for the interpreter: a value stored inside the
// live range reads back unchanged.
"builtin.module"() ({
  "func.func"() <{sym_name = "main", function_type = () -> i32}> ({
    %one = "llvm.mlir.constant"() <{ "value" = 1 : i64 }> : () -> i64
    %x = "llvm.mlir.constant"() <{ "value" = 42 : i32 }> : () -> i32
    %p = "llvm.alloca"(%one) <{ "elem_type" = i32 }> : (i64) -> !llvm.ptr
    "llvm.intr.lifetime.start"(%p) : (!llvm.ptr) -> ()
    "llvm.store"(%x, %p) : (i32, !llvm.ptr) -> ()
    %v = "llvm.load"(%p) : (!llvm.ptr) -> i32
    "llvm.intr.lifetime.end"(%p) : (!llvm.ptr) -> ()
    "func.return"(%v) : (i32) -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: Program output: #[0x0000002a#32]
