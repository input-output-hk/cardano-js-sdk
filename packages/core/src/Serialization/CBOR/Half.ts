/* eslint-disable no-bitwise */
/* eslint-disable unicorn/number-literal-case */

import { LossOfPrecisionException } from './errors.js';

const LOSS_OF_PRECISION_MSG = 'Invalid conversion. Loss of precision';

/**
 * The name ldexp is short for "load exponent" and is used to perform a binary scaling operation on a given
 * floating-point number.
 *
 * The function takes two arguments: a significand (also known as mantissa) and an exponent. It computes the product of
 * the significand and 2 raised to the power of the exponent, effectively multiplying the significand by a power of 2.
 *
 * @param mantissa The precision of the number.
 * @param exponent The exponent to be multiplied by the mantisa.
 */
const ldexp = (mantissa: number, exponent: number) => {
  const steps = Math.min(3, Math.ceil(Math.abs(exponent) / 1023));
  let result = mantissa;
  for (let i = 0; i < steps; i++) result *= Math.pow(2, Math.floor((exponent + i) / steps));
  return result;
};

/**
 * Decodes a half-precision (16 bits) floating-point number from a Uint8Array.
 *
 * Given a Uint8Array of length 2 representing a 16-bit half-precision floating-point number,
 * this function decodes the number and returns its float equivalent. The input Uint8Array
 * is assumed to be in big-endian format, i.e., the least significant byte is at index 1.
 *
 * The IEEE 754 standard for half-precision floating-point numbers is used for decoding.
 * The format consists of three components: a sign bit, a 5-bit exponent, and a 10-bit significand.
 *
 * @param data A Uint8Array containing the 16-bit half-precision floating-point number in little-endian format.
 * @returns The decoded floating-point number in the standard float format (single-precision).
 *
 * https://www.rfc-editor.org/rfc/rfc7049#appendix-D
 */
export const decodeHalf = (data: Uint8Array): number => {
  const half = (data[0] << 8) + data[1];
  const exp = (half >> 10) & 0x1f;
  const mant = half & 0x3_ff;

  let val;

  if (exp === 0) {
    val = ldexp(mant, -24);
  } else if (exp !== 31) {
    val = ldexp(mant + 1024, exp - 25);
  } else {
    val = mant === 0 ? Number.POSITIVE_INFINITY : Number.NaN;
  }

  return half & 0x80_00 ? -val : val;
};

/**
 * Encodes a single-precision float into a half-precision (16 bits) floating-point number as a Uint8Array.
 *
 * Given a single-precision float, this function encodes it into a 16-bit half-precision floating-point number
 * and returns it as a Uint8Array of length 2 in big-endian format, i.e., the least significant byte is at index 1.
 *
 * The IEEE 754 standard for half-precision floating-point numbers is used for encoding.
 * The format consists of three components: a sign bit, a 5-bit exponent, and a 10-bit significand.
 *
 * @param value A single-precision float to be encoded as a half-precision floating-point number.
 * @returns A Uint8Array containing the 16-bit half-precision floating-point number in big-endian format.
 */
export const encodeHalf = (value: number): Uint8Array => {
  const u32 = Buffer.allocUnsafe(4);
  u32.writeFloatBE(value, 0);
  const u = u32.readUInt32BE(0);

  if ((u & 0x1f_ff) !== 0) {
    throw new LossOfPrecisionException(LOSS_OF_PRECISION_MSG);
  }

  let s16 = (u >> 16) & 0x80_00;
  const exp = (u >> 23) & 0xff;
  const mant = u & 0x7f_ff_ff;

  if (exp >= 113 && exp <= 142) {
    s16 += ((exp - 112) << 10) + (mant >> 13);
  } else if (exp >= 103 && exp < 113) {
    if (mant & ((1 << (126 - exp)) - 1)) {
      throw new LossOfPrecisionException(LOSS_OF_PRECISION_MSG);
    }
    s16 += (mant + 0x80_00_00) >> (126 - exp);
  } else {
    throw new LossOfPrecisionException(LOSS_OF_PRECISION_MSG);
  }

  const result = new Uint8Array(2);
  result[0] = (s16 >>> 8) & 0xff;
  result[1] = s16 & 0xff;

  return result;
};
