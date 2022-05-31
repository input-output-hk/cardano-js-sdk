import { TokenMap } from '../../Cardano';
import { isNotNil } from '@cardano-sdk/util';

/**
 * Subtract asset quantities in order
 */
export const subtractTokenMaps = (assets: (TokenMap | undefined)[]): TokenMap | undefined => {
  if (assets.length <= 0 || !isNotNil(assets[0])) return undefined;
  const result: TokenMap = assets[0];
  const rest: TokenMap[] = assets.slice(1).filter(isNotNil);
  for (const assetTotals of rest) {
    for (const [assetId, assetQuantity] of assetTotals.entries()) {
      const total = result.get(assetId) ?? 0n;
      const diff = total - assetQuantity;
      diff === 0n ? result.delete(assetId) : result.set(assetId, diff);
    }
  }
  if (result.size === 0) {
    return undefined;
  }
  return result;
};
