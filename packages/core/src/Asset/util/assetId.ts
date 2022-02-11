import { AssetId, AssetName, PolicyId } from '../../Cardano';
import { CSL } from '../../CSL';

export const policyIdFromAssetId = (assetId: AssetId): PolicyId => PolicyId(assetId.slice(0, 56));
export const assetNameFromAssetId = (assetId: AssetId): AssetName => AssetName(assetId.slice(56));

/**
 * @returns {string} concatenated hex-encoded policy id and asset name
 */
export const createAssetId = (scriptHash: CSL.ScriptHash, assetName: CSL.AssetName): AssetId =>
  AssetId(Buffer.from(scriptHash.to_bytes()).toString('hex') + Buffer.from(assetName.name()).toString('hex'));

export const parseAssetId = (assetId: AssetId) => {
  const policyId = policyIdFromAssetId(assetId);
  const assetName = assetNameFromAssetId(assetId);
  return {
    assetName: CSL.AssetName.new(Buffer.from(assetName, 'hex')),
    scriptHash: CSL.ScriptHash.from_bytes(Buffer.from(policyId, 'hex'))
  };
};
