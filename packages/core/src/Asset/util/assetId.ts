import { AssetId, AssetName, PolicyId } from '../../Cardano';
import { CSL, util } from '../../';

export const policyIdFromAssetId = (assetId: AssetId): PolicyId => PolicyId(assetId.slice(0, 56));
export const assetNameFromAssetId = (assetId: AssetId): AssetName => AssetName(assetId.slice(56));

/**
 * @returns {string} concatenated hex-encoded policy id and asset name
 */
export const createAssetId = (scriptHash: CSL.ScriptHash, assetName: CSL.AssetName): AssetId =>
  AssetId(util.bytesToHex(scriptHash.to_bytes()) + util.bytesToHex(assetName.name()).toString());

/**
 * @returns {AssetId} concatenated policy id and asset name
 */
export const assetIdFromPolicyAndName = (policyId: PolicyId, assetName: AssetName): AssetId =>
  AssetId(policyId.toString() + assetName.toString());

export const parseAssetId = (assetId: AssetId) => {
  const policyId = policyIdFromAssetId(assetId);
  const assetName = assetNameFromAssetId(assetId);
  return {
    assetName: CSL.AssetName.new(Buffer.from(assetName, 'hex')),
    scriptHash: CSL.ScriptHash.from_bytes(Buffer.from(policyId, 'hex'))
  };
};
