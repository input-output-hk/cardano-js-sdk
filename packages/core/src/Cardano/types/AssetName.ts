import { InvalidStringError, OpaqueString, assertIsHexString } from '@cardano-sdk/util';

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
