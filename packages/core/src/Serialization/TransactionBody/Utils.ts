import * as Crypto from '@cardano-sdk/crypto';
import { AssetId, AssetName, PolicyId, TokenMap } from '../../Cardano/types';

/**
 * Sorts the given map entry canonically.
 *
 * @param lhs The left hand side.
 * @param rhs The right hand side.
 */
export const sortCanonically = (lhs: [string, unknown], rhs: [string, unknown]) => {
  if (lhs[0].length === rhs[0].length) {
    return lhs[0] > rhs[0] ? 1 : -1;
  } else if (lhs[0].length > rhs[0].length) return 1;
  return -1;
};

/**
 * transform a token map into a CDDL compatible multiasset structure.
 *
 * @param tokenMap The token map to be transformed.
 * @returns The multiasset map.
 */
export const tokenMapToMultiAsset = (tokenMap: TokenMap): Map<Crypto.Hash28ByteBase16, Map<AssetName, bigint>> => {
  const multiassets = new Map<Crypto.Hash28ByteBase16, Map<AssetName, bigint>>();

  const sortedTokenMap = new Map([...tokenMap.entries()].sort(sortCanonically));

  for (const [assetId, quantity] of sortedTokenMap.entries()) {
    const policyId = AssetId.getPolicyId(assetId) as unknown as Crypto.Hash28ByteBase16;
    const assetName = AssetId.getAssetName(assetId);

    if (!multiassets.has(policyId)) multiassets.set(policyId, new Map<AssetName, bigint>());

    multiassets.get(policyId)!.set(assetName, quantity);
  }

  return multiassets;
};

/**
 * Transform a CDDL compatible multiasset structure into a token map.
 *
 * @param multiassets The multi asset structure to be converted to token map.
 * @returns The token map.
 */
export const multiAssetsToTokenMap = (multiassets: Map<Crypto.Hash28ByteBase16, Map<AssetName, bigint>>): TokenMap => {
  const tokenMap = new Map<AssetId, bigint>();

  for (const [scriptHash, assets] of multiassets.entries()) {
    for (const [assetName, quantity] of assets.entries()) {
      const assetId = AssetId.fromParts(scriptHash as unknown as PolicyId, assetName);
      tokenMap.set(assetId, quantity);
    }
  }

  return tokenMap;
};
