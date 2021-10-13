import { BigIntMath } from '../util/BigIntMath';
import { Value, TokenMap } from './types';

/**
 * Sum asset quantities
 */
const coalesceTokenMaps = (totals: (TokenMap | undefined)[]): TokenMap | undefined => {
  const result: TokenMap = {};
  for (const assetTotals of totals.filter((quantities) => !!quantities)) {
    for (const assetKey in assetTotals) {
      result[assetKey] = (result[assetKey] || 0n) + assetTotals[assetKey];
    }
  }
  if (Object.keys(result).length === 0) {
    return undefined;
  }
  return result;
};

/**
 * Sum all quantities
 */
export const coalesceValueQuantities = (quantities: Value[]): Value => ({
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins)),
  assets: coalesceTokenMaps(quantities.map(({ assets }) => assets))
});
