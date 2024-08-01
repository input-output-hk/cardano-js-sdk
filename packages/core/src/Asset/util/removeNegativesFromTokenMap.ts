import { TokenMap } from '../../Cardano/types/Value';

/**
 * Remove all negative quantities from a TokenMap.
 * Does not modify the original TokenMap
 *
 * @param {TokenMap} assets TokenMap to remove negative quantities
 * @returns {TokenMap} a copy of `assets` with negative quantities removed, could be empty
 */
export const removeNegativesFromTokenMap = (assets: TokenMap): TokenMap => {
  const result: TokenMap = new Map(assets);
  for (const [assetId, assetQuantity] of result) {
    if (assetQuantity < 0) {
      result.delete(assetId);
    }
  }
  return result;
};
