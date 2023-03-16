import { AssetId, AssetName, PolicyId } from '../../Cardano/types/Asset';

export const policyIdFromAssetId = (assetId: AssetId): PolicyId => PolicyId(assetId.slice(0, 56));
export const assetNameFromAssetId = (assetId: AssetId): AssetName => AssetName(assetId.slice(56));

/**
 * @returns {AssetId} concatenated policy id and asset name
 */
export const assetIdFromPolicyAndName = (policyId: PolicyId, assetName: AssetName): AssetId =>
  AssetId(policyId + assetName);
