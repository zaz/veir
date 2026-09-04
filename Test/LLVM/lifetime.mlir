// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_ROUNDTRIP
//
// `llvm.intr.lifetime.start` and `llvm.intr.lifetime.end` bracket the live
// range of a stack object: one `!llvm.ptr` operand, no result, no attributes.

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<i32 ()>, linkage = #llvm.linkage<external>, sym_name = "scoped"}> ({
    %one = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %x = "llvm.mlir.constant"() <{value = 42 : i32}> : () -> i32
    %p = "llvm.alloca"(%one) <{elem_type = i32}> : (i64) -> !llvm.ptr
    "llvm.intr.lifetime.start"(%p) : (!llvm.ptr) -> ()
    "llvm.store"(%x, %p) : (i32, !llvm.ptr) -> ()
    %v = "llvm.load"(%p) : (!llvm.ptr) -> i32
    "llvm.intr.lifetime.end"(%p) : (!llvm.ptr) -> ()
    "llvm.return"(%v) : (i32) -> ()
  }) : () -> ()
}) : () -> ()

// CHECK:      "llvm.intr.lifetime.start"(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK-NEXT: "llvm.store"(%{{.*}}, %{{.*}})
// CHECK-NEXT: %{{.*}} = "llvm.load"(%{{.*}})
// CHECK-NEXT: "llvm.intr.lifetime.end"(%{{.*}}) : (!llvm.ptr) -> ()
