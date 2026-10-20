///|
// Exact decimal coefficient and base-10 exponent. Integer arithmetic keeps
// subnormal and halfway rounding identical on every target. Exponentiation
// avoids multiplying an entire decimal digit array once per exponent bit.
fn exact_decimal(mantissa : UInt64, binary_exponent : Int32) -> (String, Int32) {
  let coefficient = @bigint.BigInt::from_uint64(mantissa)
  if binary_exponent < 0 {
    let power = @bigint.BigInt::from_int(5).pow(
      @bigint.BigInt::from_int(-binary_exponent),
    )
    ((coefficient * power).to_string(), binary_exponent)
  } else {
    ((coefficient << binary_exponent).to_string(), 0)
  }
}

///|
fn rounded_decimal(
  digits : String,
  exponent : Int32,
  precision : Int32,
) -> (String, Int32) {
  if digits.length() <= precision {
    return (digits, exponent)
  }
  let retained = digits[:precision].to_owned()
  let next = digits[precision].to_int() - 48
  let more = digits[precision + 1:].iter().any(c => c != '0')
  let up = next > 5 ||
    (next == 5 && (more || (digits[precision - 1].to_int() & 1) == 1))
  let mut value = 0UL
  for char in retained {
    value = value * 10UL + (char.to_int() - 48).to_uint64()
  }
  if up {
    value += 1UL
  }
  (value.to_string(), exponent + digits.length() - precision)
}

///|
fn fixed_decimal(digits : String, exponent : Int32) -> String {
  let point = digits.length() + exponent
  if point <= 0 {
    "0." + "0".repeat(-point) + digits
  } else if point >= digits.length() {
    digits + "0".repeat(point - digits.length())
  } else {
    digits[:point].to_owned() + "." + digits[point:].to_owned()
  }
}

///|
fn trim_decimal(digits : String, exponent : Int32) -> (String, Int32) {
  let mut end = digits.length()
  while end > 1 && digits[end - 1] == '0' {
    end -= 1
  }
  (digits[:end].to_owned(), exponent + digits.length() - end)
}

///|
fn decimal_comment(
  mantissa : UInt64,
  exponent : Int32,
  bits : UInt64,
  f32 : Bool,
  style : Compatibility,
) -> String {
  let (digits, exponent) = exact_decimal(mantissa, exponent)
  if style == Wabt {
    let (digits, exponent) = rounded_decimal(digits, exponent, 6)
    let (digits, exponent) = trim_decimal(digits, exponent)
    let scientific = digits.length() + exponent - 1
    if scientific < -4 || scientific >= 6 {
      let fraction = if digits.length() > 1 {
        "." + digits[1:].to_owned()
      } else {
        ""
      }
      let abs = (if scientific < 0 { -scientific } else { scientific }).to_string()
      return digits[:1].to_owned() +
        fraction +
        "e" +
        (if scientific < 0 { "-" } else { "+" }) +
        (if abs.length() < 2 { "0" } else { "" }) +
        abs
    }
    return fixed_decimal(digits, exponent)
  }
  let max = if f32 { 9 } else { 17 }
  for precision in 1..<=max {
    let (rounded, power) = rounded_decimal(digits, exponent, precision)
    let candidate = "\{rounded}e\{power}"
    let parsed = @string.parse_double(candidate) catch { _ => continue }
    let same = if f32 {
      Float::from_double(parsed).reinterpret_as_uint().to_uint64() == bits
    } else {
      parsed.reinterpret_as_uint64() == bits
    }
    if same {
      let (rounded, power) = trim_decimal(rounded, power)
      return fixed_decimal(rounded, power)
    }
  }
  fixed_decimal(digits, exponent)
}

///|
fn compatible_float(raw : UInt64, f32 : Bool, style : Compatibility) -> String {
  let width = if f32 { 23 } else { 52 }
  let bias = if f32 { 127 } else { 1023 }
  let mask = (1UL << width) - 1UL
  let bits = raw & ((1UL << (if f32 { 31 } else { 63 })) - 1UL)
  let negative = raw != bits
  let sign = if negative { "-" } else { "" }
  let exponent = (bits >> width).to_int()
  let fraction = bits & mask
  if exponent == bias * 2 + 1 {
    if fraction == 0UL {
      return "\{sign}inf (;=\{sign}inf;)"
    }
    let payload = if fraction == 1UL << (width - 1) {
      ""
    } else {
      ":0x" + fraction.to_string(radix=16)
    }
    return "\{sign}nan\{payload} (;=\{if style == WasmTools { "NaN" } else { "nan" }};)"
  }
  if bits == 0UL {
    return "\{sign}0x0p+0 (;=\{sign}0;)"
  }
  let mut power = exponent - bias
  let mut mantissa = fraction | (1UL << width)
  if exponent == 0 {
    power = 1 - bias
    mantissa = fraction
    while (mantissa & (1UL << width)) == 0UL {
      mantissa = mantissa << 1
      power -= 1
    }
  }
  let aligned = (mantissa & mask) << ((4 - width % 4) % 4)
  let hex = aligned.to_string(radix=16)
  let hex_width = (width + 3) / 4
  let padded = "0".repeat(hex_width - hex.length()) + hex
  let fraction_text = padded.trim_end(chars="0").to_owned()
  // Both pins retain the dot for subnormal powers of two.
  let dot = if fraction != 0UL || exponent == 0 {
    "." + fraction_text
  } else {
    ""
  }
  let power_sign = if power >= 0 { "+" } else { "" }
  let decimal = decimal_comment(
    if exponent == 0 {
      fraction
    } else {
      fraction | (1UL << width)
    },
    (if exponent == 0 { 1 - bias } else { exponent - bias }) - width,
    bits,
    f32,
    style,
  )
  "\{sign}0x1\{dot}p\{power_sign}\{power} (;=\{sign}\{decimal};)"
}
