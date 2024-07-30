import { TokenMap } from '../../Cardano/types/Value';
import { isNotNil } from '@cardano-sdk/util';

/** Sum asset quantities */
export const coalesceTokenMaps = (totals: (TokenMap | undefined)[]): TokenMap | undefined => {
  const result: TokenMap = new Map();
  for (const assetTotals of totals.filter(isNotNil)) {
    for (const [assetId, assetQuantity] of assetTotals.entries()) {
      const sum = result.get(assetId) || 0n;
      result.set(assetId, sum + assetQuantity);
    }
  }
  if (result.size === 0) {
    return undefined;
  }
  return result;
};
