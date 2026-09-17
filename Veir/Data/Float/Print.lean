module

public import Veir.Data.Float.Basic
import Init.Data.Float.Model.Unpacked.Pack.Basic

/-!
MLIR float attribute spelling, following `printFloatValue` in
`mlir/lib/IR/AsmPrinter.cpp` and `toStringImpl` in `llvm/lib/Support/APFloat.cpp`.
The decimal rounding below deliberately includes LLVM's preliminary truncation
and round-half-up rule. Shortest-round-trip printing would give different text.
-/

namespace Veir.Data.Float

open _root_.Float.Model (UnpackedFloat)

/-- LLVM's fixed approximation of log₂(10) is 196/59. Keep it for identical rounding. -/
private def log2TenNumerator : Nat := 196
private def log2TenDenominator : Nat := 59

/-- Convert decimal precision to binary precision, rounding up. -/
private def bitsForDigits (digits : Nat) : Nat :=
  (digits * log2TenNumerator + log2TenDenominator - 1) / log2TenDenominator

/-- Convert binary precision to decimal precision, rounding down. -/
private def digitsForBits (bits : Nat) : Nat :=
  bits * log2TenDenominator / log2TenNumerator

/-- A positive decimal value, `significand * 10^exponent`. -/
private structure Decimal where
  significand : Nat
  exponent : Int

/-- LLVM's two `AdjustToPrecision` steps, expressed using natural numbers. -/
private def Decimal.ofBinary (significand : Nat) (exponent : Int)
    (precision : Nat) : Decimal := Id.run do
  let mut m := significand
  let mut e := exponent
  while m != 0 && m % 2 == 0 do
    m := m / 2
    e := e + 1
  -- m * 2^e = (m * 5^(-e)) * 10^e when e is negative.
  if e < 0 then
    m := m * 5 ^ e.natAbs
  else
    m := m * 2 ^ e.toNat
    e := 0
  -- LLVM first discards decimal places using its estimate of log₂(10).
  let discard := digitsForBits (m.log2 + 1 - bitsForDigits precision)
  m := m / 10 ^ discard
  e := e + discard
  -- Then round the remaining decimal digits, with ties rounded up.
  let discard := (toString m).length - precision
  if discard != 0 then
    let divisor := 10 ^ discard
    m := (m + divisor / 2) / divisor
    e := e + discard
  while m != 0 && m % 10 == 0 do
    m := m / 10
    e := e + 1
  return ⟨m, e⟩

private def zeros (n : Nat) : String := String.ofList (List.replicate n '0')

/-- Scientific notation; the six-digit attempt pads to six fractional places. -/
private def Decimal.scientific (d : Decimal) (padded : Bool) : String :=
  let digits := toString d.significand
  let fraction := (digits.drop 1).toString
  let fraction := if padded then fraction ++ zeros (6 - fraction.length)
    else if fraction.isEmpty then "0" else fraction
  let exponent := d.exponent + (digits.length - 1 : Nat)
  let magnitude := toString exponent.natAbs
  let magnitude := if padded then zeros (2 - magnitude.length) ++ magnitude else magnitude
  (digits.take 1).toString ++ "." ++ fraction ++ (if padded then "e" else "E") ++
    (if exponent < 0 then "-" else "+") ++ magnitude

/-- APFloat's default layout: natural precision and at most three padding zeros. -/
private def Decimal.natural (d : Decimal) (precision : Nat) : String :=
  let digits := toString d.significand
  let point := d.exponent + (digits.length : Int)
  if (if d.exponent ≥ 0 then
      d.exponent > 3 || point > precision
    else point - 1 < -3) then
    d.scientific false
  else if d.exponent ≥ 0 then
    digits ++ zeros d.exponent.toNat
  else if point > 0 then
    (digits.take point.toNat).toString ++ "." ++ (digits.drop point.toNat).toString
  else
    "0." ++ zeros point.natAbs ++ digits

/-- APFloat normalizes the exponent of noncanonical x87 encodings on input. -/
private def FloatValue.normalizeX87 {format : FloatFormat}
    (value : FloatValue format) : FloatValue format :=
  if !format.explicitLeadingBit then value else
  let exponent := value.exponent
  let hasLeadingBit := value.mantissa.getLsbD format.mantissaWithoutLeadingBit
  let normalizedExponent : BitVec format.exponent :=
    if exponent = 0 then (if hasLeadingBit then 1 else 0)
    else if !hasLeadingBit then -1 else exponent
  .ofBits (BitVec.ofBool value.sign ++ normalizedExponent ++ value.mantissa)

/-- Decode through Lean's model, omitting x87's stored leading bit and adjusting its bias. -/
private def FloatValue.unpack {format : FloatFormat} (value : FloatValue format)
    (hm : 0 < format.mantissaWithoutLeadingBit) (he : 2 ≤ format.exponent) : UnpackedFloat :=
  let model := format.toLeanFormat hm he
  let sign := if value.sign then .negative else .positive
  let bits := UnpackedFloat.packComponents model sign value.exponent
    (value.mantissa.truncate model.mantissaBitsWithoutImplicit)
  match UnpackedFloat.unpack model bits with
  | .finite sign m e h => .finite sign m (e + model.exponentBias - format.bias) h
  | other => other

private def FloatValue.hex {format : FloatFormat} (value : FloatValue format) : String :=
  "0x" ++ (String.ofList (Nat.toDigits 16 value.toBits.toNat)).toUpper

/--
Print a float value as MLIR does: try six significant decimal digits, then
natural precision, then uppercase hexadecimal if the decimal has no point.
Non-finite values retain their sign and NaN payload in hexadecimal.
Like APFloat, x87 pseudo-denormals become normal encodings and unnormals become NaNs.

Formats without infinity or signed zero retain hexadecimal spelling: their
decimal conversion in `ofScientific` is not supported yet (parser PR #1359).
-/
public def FloatValue.toMLIRString {format : FloatFormat} (value : FloatValue format) : String :=
  if !format.hasInf || !format.hasNaN || !format.hasNegZero then value.hex else
  if h : format.mantissaWithoutLeadingBit = 0 ∨ format.exponent < 2 then value.hex else
  let value := value.normalizeX87
  let sign := if value.sign then "-" else ""
  match value.unpack (by omega) (by omega) with
  | .notANumber | .infinity _ => value.hex
  | .zero _ => sign ++ "0.000000e+00"
  | .finite _ significand exponent _ =>
    let short := Decimal.ofBinary significand exponent 6
    if FloatValue.ofScientific format value.sign short.significand short.exponent == value then
      sign ++ short.scientific true
    else
      let precision := 2 + digitsForBits (format.toLeanFormat (by omega) (by omega)).mantissaBits
      let text := (Decimal.ofBinary significand exponent precision).natural precision
      if text.contains '.' then sign ++ text else value.hex

end Veir.Data.Float
