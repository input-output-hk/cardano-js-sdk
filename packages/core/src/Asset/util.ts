import { AssetId, TokenMap } from '../Cardano';
import { CSL } from '../CSL';

export const policyIdFromAssetId = (assetId: AssetId): string => assetId.slice(0, 56);
export const assetNameFromAssetId = (assetId: AssetId): string => assetId.slice(56);

/**
 * @returns {string} concatenated hex-encoded policy id and asset name
 */
export const createAssetId = (scriptHash: CSL.ScriptHash, assetName: CSL.AssetName): AssetId =>
  Buffer.from(scriptHash.to_bytes()).toString('hex') + Buffer.from(assetName.name()).toString('hex');

export const parseAssetId = (assetId: AssetId) => {
  const policyId = policyIdFromAssetId(assetId);
  const assetName = assetNameFromAssetId(assetId);
  return {
    assetName: CSL.AssetName.new(Buffer.from(assetName, 'hex')),
    scriptHash: CSL.ScriptHash.from_bytes(Buffer.from(policyId, 'hex'))
  };
};

/**
 * Sum asset quantities
 */
export const coalesceTokenMaps = (totals: (TokenMap | undefined)[]): TokenMap | undefined => {
  const result: TokenMap = {};
  for (const assetTotals of totals.filter((quantities) => !!quantities)) {
    for (const assetKey in assetTotals) {
      result[assetKey] = (result[assetKey] || 0n) + assetTotals[assetKey];
    }
  }
  if (Object.keys(result).length === 0) {
    return undefined;
  }
  return result;
};
