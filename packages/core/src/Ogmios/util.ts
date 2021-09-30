import { Value as _OgmiosValue } from '@cardano-ogmios/schema';
import { BigIntMath } from '../util/BigIntMath';

/**
 * {[assetId]: amount}
 */
export type TokenMap = _OgmiosValue['assets'];

/**
 * Total quantities of Coin and Assets in a Value.
 * TODO: Use Ogmios Value type after it changes lovelaces to bigint;
 */
export interface OgmiosValue {
  coins: bigint;
  assets?: TokenMap;
}

/**
 * Sum asset quantities
 */
const coalesceTokenMaps = (...totals: (TokenMap | undefined)[]): TokenMap | undefined => {
  const result: TokenMap = {};
  for (const assetTotals of totals.filter((quantities) => !!quantities)) {
    for (const assetKey in assetTotals) {
      result[assetKey] = (result[assetKey] || 0n) + assetTotals[assetKey];
    }
  }
  if (Object.keys(result).length === 0) {
    return undefined;
  }
  // eslint-disable-next-line consistent-return
  return result;
};

/**
 * Sum all quantities
 */
export const coalesceValueQuantities = (...quantities: OgmiosValue[]): OgmiosValue => ({
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins)),
  assets: coalesceTokenMaps(...quantities.map(({ assets }) => assets))
});
