import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob, InvalidStringError, OpaqueString, assertIsHexString, typedBech32 } from '@cardano-sdk/util';
import { TextDecoder } from 'web-encoding';

export type AssetId = OpaqueString<'AssetId'>;

/** Hex-encoded asset name */
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

const utf8Decoder = new TextDecoder('utf8', { fatal: true });
AssetName.toUTF8 = (assetName: AssetName, stripInvisibleCharacters = false) => {
  const assetNameBuffer = Buffer.from(assetName, 'hex');
  try {
    if (stripInvisibleCharacters) {
      // 'invisible' control characters are valid utf8, but we don't want to use them, strip them out
      return utf8Decoder.decode(assetNameBuffer.filter((v) => v > 31));
    }
    return utf8Decoder.decode(assetNameBuffer);
  } catch (error) {
    throw new InvalidStringError(`Cannot convert AssetName '${assetName}' to UTF8`, error);
  }
};

/**
 * @param {string} value concatenated PolicyId and AssetName
 * @throws InvalidStringError
 */
export const AssetId = (value: string): AssetId => {
  const normalizedValue = value.split('.').join('');
  assertIsHexString(normalizedValue);
  if (normalizedValue.length > 120) throw new InvalidStringError('too long');
  if (normalizedValue.length < 56) throw new InvalidStringError('too short');
  return normalizedValue as unknown as AssetId;
};

/** Hex-encoded policy id */
export type PolicyId = OpaqueString<'PolicyId'>;
export const PolicyId = (value: string): PolicyId => Crypto.Hash28ByteBase16(value) as unknown as PolicyId;

AssetId.getPolicyId = (id: AssetId) => PolicyId(id.slice(0, 56));
AssetId.getAssetName = (id: AssetId) => AssetName(id.slice(56));
AssetId.fromParts = (policyId: PolicyId, assetName: AssetName): AssetId => AssetId(policyId + assetName);

/** Fingerprint of a native asset for human comparison See CIP-0014 */
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
  const policyBuf = Buffer.from(policyId, 'hex');
  const assetNameBuf = Buffer.from(assetName, 'hex');
  const hexDigest = Crypto.blake2b.hash(HexBlob.fromBytes(new Uint8Array([...policyBuf, ...assetNameBuf])), 20);

  return AssetFingerprint(HexBlob.toTypedBech32<string>('asset', hexDigest));
};
