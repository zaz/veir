// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

// A block without a terminator is a failure of the local checks, so the
// dominance check does not run: its result would be meaningless for a
// control-flow graph that is missing edges. The use of `%a` outside its
// block is therefore not reported until the terminator is added.

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void (i1)>, sym_name = "f"}> ({
  ^bb0(%c : i1):
    "llvm.cond_br"(%c) [^bb1, ^bb2] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb1:
    %a = "llvm.mlir.constant"() <{value = 1 : i32}> : () -> i32
    "llvm.br"() [^bb3] : () -> ()
  ^bb2:
    %y = "llvm.add"(%a, %a) : (i32, i32) -> i32
  ^bb3:
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK:     Error verifying input program: llvm.func: Expected the last operation of a block to be a terminator
// CHECK-NOT: Error verifying
