import * as cip14 from '@emurgo/cip14-js';
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
  return value.toLowerCase() as unknown as AssetName;
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

/**
 * Gets the native asset fingerprint from its policy id and asset name.
 * See CIP-0014
 *
 * @param policyId The native asset policy id.
 * @param assetName The native asset name.
 */
AssetFingerprint.fromParts = (policyId: PolicyId, assetName: AssetName): AssetFingerprint => {
  const cip14Fingerprint = cip14.default.fromParts(
    Buffer.from(policyId.toString(), 'hex'),
    Buffer.from(assetName.toString(), 'hex')
  );

  return AssetFingerprint(cip14Fingerprint.fingerprint());
};
