import { Hash28ByteBase16, OpaqueString, assertIsHexString, typedBech32 } from '../util';
import { InvalidStringError } from '../..';

export type AssetId = OpaqueString<'AssetId'>;

/**
 * Hex-encoded asset name
 */
export type AssetName = OpaqueString<'AssetName'>;
export const AssetName = (value: string): AssetName => {
  if (value.length > 0) {
    assertIsHexString(value);
    if (value.length > 64) {
      throw new InvalidStringError('too long');
    }
  }
  return value as unknown as AssetName;
};

/**
 * @param {string} value concatenated PolicyId and AssetName
 * @throws InvalidStringError
 */
export const AssetId = (value: string): AssetId => {
  assertIsHexString(value);
  if (value.length > 120) throw new InvalidStringError('too long');
  if (value.length < 56) throw new InvalidStringError('too short');
  return value as unknown as AssetId;
};

/**
 * Hex-encoded policy id
 */
export type PolicyId = Hash28ByteBase16<'PolicyId'>;
export const PolicyId = (value: string): PolicyId => Hash28ByteBase16(value);

/**
 * Fingerprint of a native asset for human comparison
 * See CIP-0014
 */
export type AssetFingerprint = OpaqueString<'AssetFingerprint'>;
export const AssetFingerprint = (value: string): AssetFingerprint => typedBech32(value, 'asset', 32);
