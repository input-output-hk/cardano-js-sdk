import { BigNum } from '@emurgo/cardano-serialization-lib-nodejs';

export const MAX_U64 = 18_446_744_073_709_551_615n;

export const MIN_I64 = -9_223_372_036_854_775_808n;
export const MAX_I64 = 9_223_372_036_854_775_807n;

export const maxBigNum = BigNum.from_str(MAX_U64.toString());

export type CslObject = { to_bytes: () => Uint8Array };

/**
 * Check if serialized CSL objects are equal by comparing their byte representations
 *
 * @returns {boolean} true if objects are equal, false otherwise
 */
export const bytewiseEquals = (obj1: CslObject, obj2: CslObject) => {
  if (obj1 === obj2) return true;
  const obj1Bytes = obj1.to_bytes();
  const obj2Bytes = obj2.to_bytes();
  if (obj1Bytes.length !== obj2Bytes.length) return false;
  return obj1Bytes.every((byte, idx) => obj2Bytes[idx] === byte);
};
