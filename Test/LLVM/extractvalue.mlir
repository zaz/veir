// RUN: VEIR_ROUNDTRIP
// RUN: MLIR_ROUNDTRIP
// RUN: veir-opt %s -p=dce | filecheck %s --check-prefix=DCE

"builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<i64 (!llvm.array<2 x i64>)>, linkage = #llvm.linkage<external>, sym_name = "read"}> ({
  ^bb0(%a: !llvm.array<2 x i64>):
    %v = "llvm.extractvalue"(%a) <{position = array<i64: 1>}> : (!llvm.array<2 x i64>) -> i64
    "llvm.return"(%v) : (i64) -> ()
  }) : () -> ()
  "llvm.func"() <{function_type = !llvm.func<void ()>, linkage = #llvm.linkage<external>, sym_name = "nested"}> ({
    %a = "llvm.mlir.undef"() : () -> !llvm.array<2 x array<3 x i32>>
    %v = "llvm.extractvalue"(%a) <{position = array<i64: 1, 2>}> : (!llvm.array<2 x array<3 x i32>>) -> i32
    %row = "llvm.extractvalue"(%a) <{position = array<i64: 0>}> : (!llvm.array<2 x array<3 x i32>>) -> !llvm.array<3 x i32>
    %whole = "llvm.extractvalue"(%a) <{position = array<i64>}> : (!llvm.array<2 x array<3 x i32>>) -> !llvm.array<2 x array<3 x i32>>
    %p = "llvm.mlir.undef"() : () -> !llvm.array<2 x ptr>
    %ptr = "llvm.extractvalue"(%p) <{position = array<i64: 0>}> : (!llvm.array<2 x ptr>) -> !llvm.ptr
    %f = "llvm.mlir.undef"() : () -> !llvm.array<1 x f64>
    %float = "llvm.extractvalue"(%f) <{position = array<i64: 0>}> : (!llvm.array<1 x f64>) -> f64
    %vecs = "llvm.mlir.undef"() : () -> !llvm.array<2 x vector<4xi8>>
    %vec = "llvm.extractvalue"(%vecs) <{position = array<i64: 1>}> : (!llvm.array<2 x vector<4xi8>>) -> vector<4xi8>
    %s = "llvm.mlir.undef"() : () -> !llvm.struct<(i32, !llvm.struct<(i64, i8)>)>
    %field = "llvm.extractvalue"(%s) <{position = array<i64: 1, 0>}> : (!llvm.struct<(i32, !llvm.struct<(i64, i8)>)>) -> i64
    %same = "llvm.extractvalue"(%s) <{position = array<i64>}> : (!llvm.struct<(i32, !llvm.struct<(i64, i8)>)>) -> !llvm.struct<(i32, !llvm.struct<(i64, i8)>)>
    %as = "llvm.mlir.undef"() : () -> !llvm.array<2 x !llvm.struct<(i64, i8)>>
    %nested = "llvm.extractvalue"(%as) <{position = array<i64: 1, 0>}> : (!llvm.array<2 x !llvm.struct<(i64, i8)>>) -> i64
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 1>}> : (!llvm.array<2 x i64>) -> i64
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 1, 2>}> : (!llvm.array<2 x !llvm.array<3 x i32>>) -> i32
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 0>}> : (!llvm.array<2 x !llvm.array<3 x i32>>) -> !llvm.array<3 x i32>
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64>}> : (!llvm.array<2 x !llvm.array<3 x i32>>) -> !llvm.array<2 x !llvm.array<3 x i32>>
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 0>}> : (!llvm.array<2 x !llvm.ptr>) -> !llvm.ptr
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 0>}> : (!llvm.array<1 x f64>) -> f64
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 1>}> : (!llvm.array<2 x vector<4xi8>>) -> vector<4xi8>
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 1, 0>}> : (!llvm.struct<(i32, {{(!llvm.)?}}struct<(i64, i8)>)>) -> i64
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64>}> : (!llvm.struct<(i32, {{(!llvm.)?}}struct<(i64, i8)>)>) -> !llvm.struct<(i32, {{(!llvm.)?}}struct<(i64, i8)>)>
// CHECK: "llvm.extractvalue"({{.*}}) <{"position" = array<i64: 1, 0>}> : (!llvm.array<2 x {{(!llvm.)?}}struct<(i64, i8)>>) -> i64

// DCE-LABEL: "sym_name" = "read"
// DCE: "llvm.extractvalue"
// DCE: "llvm.return"
// DCE-LABEL: "sym_name" = "nested"
// DCE-NOT: "llvm.extractvalue"
// DCE: "llvm.return"
