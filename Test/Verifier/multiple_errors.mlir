// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

// Verification reports every failure, not just the first, in source order.
// The dangling global reference, the block without a terminator, and the
// forbidden i0 operand are three independent failures. The use of `%a`
// outside its block is a dominance failure, which is only reported once the
// other checks pass: dominance assumes the structure they establish.

"builtin.module"() ({
  "llvm.mlir.global"() <{addr_space = 0 : i32, alignment = 4 : i64, global_type = i32, linkage = #llvm.linkage<external>, sym_name = "declared"}> ({
  }) : () -> ()
  "llvm.func"() <{function_type = !llvm.func<i32 ()>, sym_name = "f"}> ({
    %p0 = "llvm.mlir.addressof"() <{global_name = @undeclared}> : () -> !llvm.ptr
    %p1 = "llvm.mlir.addressof"() <{global_name = @declared}> : () -> !llvm.ptr
    %0 = "llvm.mlir.constant"() <{value = 13 : i32}> : () -> i32
    "llvm.return"(%0) : (i32) -> ()
  }) : () -> ()
  "llvm.func"() <{function_type = !llvm.func<void ()>, sym_name = "no_terminator"}> ({
    %1 = "llvm.mlir.constant"() <{value = 2 : i32}> : () -> i32
  }) : () -> ()
  "func.func"() <{sym_name = "g", function_type = (i1, i0) -> ()}> ({
  ^bb0(%c : i1, %z : i0):
    %x = "arith.addi"(%z, %z) : (i0, i0) -> i0
    %k = "llvm.mlir.constant"() <{value = 1 : i32}> : () -> i32
    "cf.cond_br"(%c, %k) [^bb1, ^bb2] <{operandSegmentSizes = array<i32: 1, 1, 0>}> : (i1, i32) -> ()
  ^bb1(%a : i32):
    "cf.br"() [^bb3] : () -> ()
  ^bb2:
    %y = "llvm.add"(%a, %a) : (i32, i32) -> i32
    "cf.br"() [^bb3] : () -> ()
  ^bb3:
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK:      Error verifying input program: llvm.mlir.addressof: symbol '@undeclared' does not name an llvm.mlir.global
// CHECK-NEXT: Error verifying input program: llvm.func: Expected the last operation of a block to be a terminator
// CHECK-NEXT: Error verifying input program: arith.addi: operand 0 has forbidden i0 type
// CHECK-NOT:  Error verifying
