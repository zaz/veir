module

public import Srtfp.Schubfach
public import Srtfp.Text

public section

/-!
  # Float attribute printing

  Prints a binary64 value from its bit pattern as the shortest round-trip
  decimal: srtfp's verified Schubfach printer supplies the unique minimal
  digit string, and srtfp's text layer renders it (positional for moderate
  magnitudes, scientific otherwise). NaN and the infinities print as the raw
  bit pattern in uppercase hexadecimal (`0x7FF8000000000000`), as in MLIR;
  the sign lives in the bit pattern, so there is never a leading minus on a
  hex form.

  Every decimal output is parseable by both VeIR and MLIR: srtfp proves
  `Text.parse .mlir (Text.format opts d) = some d` for any compatible
  presentation options (`Srtfp.Text.parse_format`), and `veirFormat` below
  is compatible by `decide`. This deliberately does not reproduce MLIR's own
  `printFloatValue` output byte for byte (MLIR pads to 6 significant digits
  or jumps to 17); a byte-compatible emulation of MLIR's printing existed at
  an earlier revision of this file — see the history of this PR.
-/

namespace Veir.FloatPrinter

/--
  VeIR's presentation of shortest-form decimals: Python `repr`'s
  positional/scientific window, a forced `.0` on integral values, bare
  exponents (`"2.0"`, `"1.5e-7"`).
-/
def veirFormat : Srtfp.Text.FormatOptions := { minFracDigits := 1, sciMinFracDigits := 1 }

def hexDigitChar (d : Nat) : Char :=
  if d < 10 then Char.ofNat ('0'.toNat + d) else Char.ofNat ('A'.toNat + d - 10)

/-- `0x`-prefixed uppercase hexadecimal of the raw bit pattern. -/
def hexString (bits : UInt64) : String := Id.run do
  let mut s := ""
  let mut n := bits.toNat
  while n ≠ 0 do
    s := String.singleton (hexDigitChar (n % 16)) ++ s
    n := n / 16
  return "0x" ++ (if s = "" then "0" else s)

/--
  Print the binary64 value with bit pattern `bits` in shortest round-trip
  form; NaN and the infinities print as raw bits.
-/
def shortestFloatString (bits : UInt64) : String :=
  match Srtfp.Schubfach.toDecimalBits bits with
  | .error _ => hexString bits
  | .ok dec => Srtfp.Text.format veirFormat dec

end Veir.FloatPrinter
