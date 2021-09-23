import { Value as OgmiosValue } from '@cardano-ogmios/schema';
import { BigIntMath } from '../util/BigIntMath';

/**
 * {[assetId]: amount}
 */
export type AssetQuantities = OgmiosValue['assets'];

/**
 * Total quantities of Coin and Assets in a Value.
 * TODO: Use Ogmios Value type after it changes lovelaces to bigint;
 */
export interface ValueQuantities {
  coins: bigint;
  assets?: AssetQuantities;
}

/**
 * Sum asset quantities
 */
const coalesceAssetTotals = (...totals: (AssetQuantities | undefined)[]): AssetQuantities | undefined => {
  const result: AssetQuantities = {};
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
export const coalesceValueQuantities = (...quantities: ValueQuantities[]): ValueQuantities => ({
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins)),
  assets: coalesceAssetTotals(...quantities.map(({ assets }) => assets))
});
