// RUN: not veir-opt %s 2>&1 | filecheck %s
// RUN: MLIR_INVALID

// Every operand that is not dominated by its definition is reported, in
// source order, and operands of one operation in operand order.

"builtin.module"() ({
  "func.func"() <{sym_name = "f", function_type = (i1) -> ()}> ({
  ^bb0(%c : i1):
    "cf.cond_br"(%c) [^bb1, ^bb2] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb1:
    %a = "arith.constant"() <{value = 1 : i32}> : () -> i32
    %b = "arith.constant"() <{value = 2 : i32}> : () -> i32
    "cf.br"() [^bb3] : () -> ()
  ^bb2:
    %x = "arith.addi"(%a, %b) : (i32, i32) -> i32
    %y = "arith.muli"(%x, %b) : (i32, i32) -> i32
    "cf.br"() [^bb3] : () -> ()
  ^bb3:
    "func.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK:      Error verifying input program: arith.addi: operand #0 does not dominate this use
// CHECK-NEXT: Error verifying input program: arith.addi: operand #1 does not dominate this use
// CHECK-NEXT: Error verifying input program: arith.muli: operand #1 does not dominate this use
// CHECK-NOT:  Error verifying
