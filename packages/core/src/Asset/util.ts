import { CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { AssetName, ScriptHash } from '@emurgo/cardano-serialization-lib-nodejs';

export const policyIdFromAssetId = (assetId: string, bech32PrefixLength = 4): string =>
  assetId.slice(0, 52 + bech32PrefixLength);
export const assetNameFromAssetId = (assetId: string, bech32PrefixLength = 4): string =>
  assetId.slice(52 + bech32PrefixLength);

export const createAssetSerializer = (csl: CardanoSerializationLib, bech32Prefix = 'b32_') => {
  const encoder = new TextEncoder();
  const decoder = new TextDecoder();
  return {
    /**
     * Combine script hash and asset name into unique asset identifier.
     * Operation can be reversed with *parseId(assetId)*.
     */
    createId: (scriptHash: ScriptHash, assetName: AssetName): string =>
      scriptHash.to_bech32(bech32Prefix) + decoder.decode(assetName.name()),
    /**
     * Get asset ScriptHash and AssetName from id created by *createId(scriptHash, assetName)*.
     */
    parseId: (id: string) => {
      const scriptHashBech32 = policyIdFromAssetId(id, bech32Prefix.length);
      const assetName = assetNameFromAssetId(id, bech32Prefix.length);
      return {
        scriptHash: csl.ScriptHash.from_bech32(scriptHashBech32),
        assetName: csl.AssetName.new(encoder.encode(assetName))
      };
    }
  };
};

export type AssetSerializer = ReturnType<typeof createAssetSerializer>;
