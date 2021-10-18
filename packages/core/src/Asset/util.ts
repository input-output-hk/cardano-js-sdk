import { CSL } from '../CSL';
import { Buffer } from 'buffer';

export const policyIdFromAssetId = (assetId: string): string => assetId.slice(0, 56);
export const assetNameFromAssetId = (assetId: string): string => assetId.slice(56);

/**
 * @returns {string} concatenated hex-encoded policy id and asset name
 */
export const createAssetId = (scriptHash: CSL.ScriptHash, assetName: CSL.AssetName): string =>
  Buffer.from(scriptHash.to_bytes()).toString('hex') + Buffer.from(assetName.name()).toString('hex');

export const parseAssetId = (assetId: string) => {
  const policyId = policyIdFromAssetId(assetId);
  const assetName = assetNameFromAssetId(assetId);
  return {
    scriptHash: CSL.ScriptHash.from_bytes(Buffer.from(policyId, 'hex')),
    assetName: CSL.AssetName.new(Buffer.from(assetName, 'hex'))
  };
};
