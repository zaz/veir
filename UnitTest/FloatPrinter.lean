import Veir.Parser.AttrParser

open Veir Veir.Data.Float Veir.Parser Veir.AttrParser

-- Expected spellings from MLIR's printFloatValue, not a shortest-decimal printer.
-- Check both the public attribute printer and reparsing to the original bits.
private def check (format : FloatFormat) (bits : Nat) (text : String)
    (parsedBits : Nat := bits) : Bool :=
  let attr : FloatAttr := ⟨⟨format⟩, .ofNat format bits⟩
  let text := s!"{text} : {format.canonicalName}"
  toString attr == text && match ParserState.fromInput text.toByteArray with
  | .error _ => false
  | .ok state => match parseAttribute.run' {} state with
    | .ok result => result == .floatAttr ⟨⟨format⟩, .ofNat format parsedBits⟩
    | .error _ => false

-- Six significant digits, padded to six fractional places, with signed exponents.
#guard check .f64 0x3fb999999999999a "1.000000e-01"
#guard check .f64 0x3ff0000000000000 "1.000000e+00"
#guard check .f64 0x8000000000000000 "-0.000000e+00"
#guard check .f64 0 "0.000000e+00"
#guard check .f16 0x8000 "-0.000000e+00"
-- The discarded digit is exactly five: LLVM rounds up, not to even.
#guard check .f16 0x3c10 "1.015630e+00"

-- Natural precision, the positional/scientific boundary, and integral fallback.
#guard check .f32 0x3f800001 "1.00000012"
#guard check .f64 0x3ff0000000000001 "1.0000000000000002"
#guard check .f64 0x3ff3c0ca428c59fb "1.2345678901234567"
#guard check .f64 0x3f543a272d955e51 "0.0012345678899999999"
#guard check .f64 0x3f202e85be111841 "1.23456789E-4"
#guard check .f64 0x4132d68700000000 "0x4132D68700000000"
#guard check .f64 0x426cbe991a080000 "0x426CBE991A080000"
-- LLVM's preliminary truncation changes the final digit from 2 to 1 here.
#guard check .f64 0x0d42528da9d3d7c7 "8.3856677392886631E-245"

-- Smallest subnormals, normal boundaries, and largest finite values.
#guard check .f16 1 "5.960460e-08"
#guard check .f16 0x400 "6.103520e-05"
#guard check .f16 0x7bff "6.550400e+04"
#guard check .bf16 1 "9.183550e-41"
#guard check .bf16 0x7f7f "3.389530e+38"
#guard check .f8E5M2 1 "1.525880e-05"
#guard check .f8E5M2 0x7b "5.734400e+04"
#guard check .f32 1 "1.401300e-45"
#guard check .f32 0x800000 "1.17549435E-38"
#guard check .f32 0x7f7fffff "3.40282347E+38"
#guard check .f64 1 "4.940660e-324"
#guard check .f64 0xfffffffffffff "2.2250738585072009E-308"
#guard check .f64 0x10000000000000 "2.2250738585072014E-308"
#guard check .f64 0x7fefffffffffffff "1.7976931348623157E+308"
#guard check .f80 1 "3.645200e-4951"
#guard check .f80 0x3fff8000000000000001 "1.00000000000000000011"
#guard check .f80 0x7ffeffffffffffffffff "1.18973149535723176502E+4932"
#guard check .f128 1 "6.475180e-4966"
#guard check .f128 0x3fff0000000000000000000000000001 "1.00000000000000000000000000000000019"
#guard check .f128 0x7ffeffffffffffffffffffffffffffff "1.18973149535723176508575932662800702E+4932"

-- APFloat canonicalizes x87 pseudo-denormals and unnormals when reading raw bits.
#guard check .f80 0x8000000000000000 "3.36210314311209350626E-4932" 0x18000000000000000
#guard check .f80 0x10000000000000000 "0x7FFF0000000000000000" 0x7fff0000000000000000

-- Infinities and NaNs retain their sign and payload, without lowercase or padding.
#guard check .f16 0x7c00 "0x7C00"
#guard check .f64 0xfff0000000000000 "0xFFF0000000000000"
#guard check .f64 0x7ff0000000000001 "0x7FF0000000000001"
#guard check .f64 0xfff8123456789abc "0xFFF8123456789ABC"
#guard check .f32 0xffc12345 "0xFFC12345"
#guard check .f80 0xffffc000000000000123 "0xFFFFC000000000000123"
#guard check .f128 0xffff8000000000000000000000000123 "0xFFFF8000000000000000000000000123"

-- The two formats whose decimal reader is unsupported stay lossless in hex.
#guard check .f8E4M3FN 0x7e "0x7E"
#guard check .f8E4M3FNUZ 1 "0x1"
#guard check .f8E4M3FNUZ 0x80 "0x80"
