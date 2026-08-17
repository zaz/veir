module

public import Srtfp.Clinger

public section

/-!
  # MLIR-compatible float printing

  Prints a binary64 value from its bit pattern exactly as MLIR prints a f64
  `FloatAttr`, byte for byte. This replicates `printFloatValue`
  (`mlir/lib/IR/AsmPrinter.cpp`) and the parts of `APFloat::toString` /
  `toStringImpl` (`llvm/lib/Support/APFloat.cpp`) it invokes:

  1. the 6-significant-digit scientific form (`3.140000e+00`), emitted iff
     reparsing it yields the same bit pattern;
  2. otherwise the 17-digit "natural precision" form
     (`2.0951218323850843E-171`), emitted iff it contains a `.`;
  3. otherwise the raw bit pattern in uppercase hexadecimal
     (`0x7FF8000000000000`), which is also used for NaN and the infinities
     (the sign lives in the bit pattern; no leading minus).

  Quirks of the original are replicated deliberately, since round-trip tests
  compare byte-identical output against `mlir-opt`: decimal rounding is
  half-up on the digit string (APFloat has a FIXME about this), preceded by a
  coarse binary truncation stage, and the 17-digit form falls back to hex for
  values it would print without a decimal point (e.g. `123456789000.0`).
-/

namespace Veir.FloatPrinter

/--
  The digit-string state of `toStringImpl`: decimal `digits` (least
  significant first, most significant last, no trailing decimal zeros in the
  least significant positions) and the exponent `exp10` such that the value is
  `digits × 10^exp10`.
-/
structure DecimalDigits where
  digits : Array Nat
  exp10 : Int

/--
  Decompose `bits` into `(significand, exponent)` with value
  `significand × 2^exponent`, for finite nonzero values.
-/
def decompose (bits : UInt64) : Nat × Int :=
  let mantissa := (bits &&& 0xFFFFFFFFFFFFF).toNat
  let biasedExp := ((bits >>> 52) &&& 0x7FF).toNat
  if biasedExp = 0 then (mantissa, -1074)
  else (mantissa + 2 ^ 52, (biasedExp : Int) - 1075)

/--
  `APFloat::toStringImpl` digit computation: exact decimal digits of
  `sig × 2^exp2`, truncated by the binary pre-adjustment stage and rounded
  half-up to `formatPrecision` significant digits.
-/
def computeDigits (sig : Nat) (exp2 : Int) (formatPrecision : Nat) : DecimalDigits := Id.run do
  -- Ignore trailing binary zeros.
  let mut sig := sig
  let mut exp2 := exp2
  while sig % 2 = 0 && sig ≠ 0 do
    sig := sig / 2
    exp2 := exp2 + 1
  -- Change the exponent from 2^e to 10^e: sig × 2^e = (sig × 5^(-e)) × 10^e.
  let mut n : Nat := if exp2 ≥ 0 then sig <<< exp2.toNat else sig * 5 ^ (-exp2).toNat
  let mut exp10 : Int := if exp2 ≥ 0 then 0 else exp2
  -- First AdjustToPrecision: coarse binary truncation.
  let bits := n.log2 + 1
  let bitsRequired := (formatPrecision * 196 + 58) / 59
  if bits > bitsRequired then
    let tensRemovable := (bits - bitsRequired) * 59 / 196
    if tensRemovable > 0 then
      exp10 := exp10 + tensRemovable
      n := n / 10 ^ tensRemovable
  -- Extract decimal digits, least significant first, dropping trailing zeros.
  let mut digits : Array Nat := #[]
  let mut inTrail := true
  while n ≠ 0 do
    let d := n % 10
    n := n / 10
    if inTrail && d = 0 then
      exp10 := exp10 + 1
    else
      digits := digits.push d
      inTrail := false
  -- Second AdjustToPrecision: round half-up to formatPrecision digits.
  let nd := digits.size
  if nd > formatPrecision then
    let mut fs := nd - formatPrecision
    if digits[fs - 1]! < 5 then
      -- Round down; also drop trailing zeros of the result.
      while fs < nd && digits[fs]! = 0 do
        fs := fs + 1
      exp10 := exp10 + fs
      digits := digits.extract fs nd
    else
      -- Round up with decimal carry; carried-through nines are dropped.
      let mut i := fs
      while i < nd do
        if digits[i]! = 9 then
          fs := fs + 1
          i := i + 1
        else
          digits := digits.set! i (digits[i]! + 1)
          break
      if fs = nd then
        exp10 := exp10 + fs
        digits := #[1]
      else
        exp10 := exp10 + fs
        digits := digits.extract fs nd
  return { digits, exp10 }

/-- The numeric value of the digit string (digits are least significant first). -/
def DecimalDigits.significand (d : DecimalDigits) : Nat :=
  d.digits.foldr (fun digit acc => acc * 10 + digit) 0

def digitChar (d : Nat) : Char := Char.ofNat ('0'.toNat + d)

/-- Decimal digits of `n`, most significant first, at least `minWidth` wide. -/
def natDigits (n : Nat) (minWidth : Nat := 1) : String := Id.run do
  let mut s := ""
  let mut n := n
  while n ≠ 0 do
    s := String.singleton (digitChar (n % 10)) ++ s
    n := n / 10
  while s.length < minWidth do
    s := "0" ++ s
  return s

/--
  `APFloat::toStringImpl` formatting of a rounded digit string, replicating
  the scientific/positional decision and both layouts.
-/
def formatDigits (isNeg : Bool) (d : DecimalDigits)
    (formatPrecision formatMaxPadding : Nat) (truncateZero : Bool) : String := Id.run do
  let digits := d.digits
  let nd := digits.size
  let exp10 := d.exp10
  let sign := if isNeg then "-" else ""
  let formatScientific :=
    if formatMaxPadding = 0 then
      true
    else if exp10 ≥ 0 then
      exp10.toNat > formatMaxPadding || nd + exp10.toNat > formatPrecision
    else
      let msd := exp10 + (nd - 1 : Nat)
      if msd ≥ 0 then false else (-msd).toNat > formatMaxPadding
  if formatScientific then
    let exp := exp10 + (nd - 1 : Nat)
    let mut s := sign ++ String.singleton (digitChar digits[nd - 1]!) ++ "."
    if nd = 1 && truncateZero then
      s := s ++ "0"
    else
      for i in [1:nd] do
        s := s ++ String.singleton (digitChar digits[nd - 1 - i]!)
    if !truncateZero && formatPrecision + 1 > nd then
      s := s ++ String.ofList (List.replicate (formatPrecision - nd + 1) '0')
    s := s ++ (if truncateZero then "E" else "e")
    s := s ++ (if exp ≥ 0 then "+" else "-")
    -- The exponent always has at least two digits unless zeros are truncated.
    s := s ++ natDigits exp.natAbs (if truncateZero then 1 else 2)
    return s
  else if exp10 ≥ 0 then
    let mut s := sign
    for i in [0:nd] do
      s := s ++ String.singleton (digitChar digits[nd - 1 - i]!)
    return s ++ String.ofList (List.replicate exp10.toNat '0')
  else
    let nWholeDigits := exp10 + (nd : Nat)
    let mut s := sign
    let mut i := 0
    if nWholeDigits > 0 then
      while i < nWholeDigits.toNat do
        s := s ++ String.singleton (digitChar digits[nd - i - 1]!)
        i := i + 1
      s := s ++ "."
    else
      s := s ++ "0." ++ String.ofList (List.replicate (-nWholeDigits).toNat '0')
    while i < nd do
      s := s ++ String.singleton (digitChar digits[nd - i - 1]!)
      i := i + 1
    return s

def hexDigitChar (d : Nat) : Char :=
  if d < 10 then digitChar d else Char.ofNat ('A'.toNat + d - 10)

/-- `0x`-prefixed uppercase hexadecimal of the raw bit pattern. -/
def hexString (bits : UInt64) : String := Id.run do
  let mut s := ""
  let mut n := bits.toNat
  while n ≠ 0 do
    s := String.singleton (hexDigitChar (n % 16)) ++ s
    n := n / 16
  return "0x" ++ (if s = "" then "0" else s)

/--
  Print the binary64 value with bit pattern `bits` exactly as MLIR's
  `printFloatValue` prints a f64 attribute value.
-/
def mlirFloatString (bits : UInt64) : String :=
  let biasedExp := ((bits >>> 52) &&& 0x7FF).toNat
  let mantissa := (bits &&& 0xFFFFFFFFFFFFF).toNat
  let isNeg := bits >>> 63 = 1
  if biasedExp = 2047 then
    -- NaN and the infinities print as raw bits.
    hexString bits
  else if biasedExp = 0 && mantissa = 0 then
    -- Zeros: `APFloat::toString` special case, always round-trips.
    (if isNeg then "-" else "") ++ "0.000000e+00"
  else
    let (sig, exp2) := decompose bits
    -- Tier 1: 6 significant digits, emitted iff it reparses to the same bits.
    let d6 := computeDigits sig exp2 6
    if Srtfp.Clinger.decimalToFloatBits isNeg d6.significand d6.exp10 = bits then
      formatDigits isNeg d6 6 0 false
    else
      -- Tier 2: "natural precision" (2 + 53×59/196 = 17 digits for binary64),
      -- emitted iff it contains a decimal point; otherwise raw bits.
      let d17 := computeDigits sig exp2 17
      let s := formatDigits isNeg d17 17 3 true
      if s.contains '.' then s else hexString bits

end Veir.FloatPrinter
