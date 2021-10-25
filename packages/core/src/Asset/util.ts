import { CSL } from '../CSL';

export type AssetId = string;

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
    scriptHash: CSL.ScriptHash.from_bytes(Buffer.from(policyId, 'hex')),
    assetName: CSL.AssetName.new(Buffer.from(assetName, 'hex'))
  };
};
