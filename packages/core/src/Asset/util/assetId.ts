import { AssetId, AssetName, PolicyId } from '../../Cardano/types';
import { CML } from '../../CML/CML';
import { bytesToHex } from '../../util/misc/bytesToHex';

export const policyIdFromAssetId = (assetId: AssetId): PolicyId => PolicyId(assetId.slice(0, 56));
export const assetNameFromAssetId = (assetId: AssetId): AssetName => AssetName(assetId.slice(56));

/**
 * @returns {string} concatenated hex-encoded policy id and asset name
 */
export const createAssetId = (scriptHash: CML.ScriptHash, assetName: CML.AssetName): AssetId =>
  AssetId(bytesToHex(scriptHash.to_bytes()) + bytesToHex(assetName.name()).toString());

/**
 * @returns {AssetId} concatenated policy id and asset name
 */
export const assetIdFromPolicyAndName = (policyId: PolicyId, assetName: AssetName): AssetId =>
  AssetId(policyId.toString() + assetName.toString());

export const parseAssetId = (assetId: AssetId) => {
  const policyId = policyIdFromAssetId(assetId);
  const assetName = assetNameFromAssetId(assetId);
  return {
    assetName: CML.AssetName.new(Buffer.from(assetName, 'hex')),
    scriptHash: CML.ScriptHash.from_bytes(Buffer.from(policyId, 'hex'))
  };
};
