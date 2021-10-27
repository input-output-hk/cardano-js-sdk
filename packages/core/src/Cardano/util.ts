import { Asset, BigIntMath } from '..';
import { Value } from './types';

/**
 * Blockchain restriction for minimum coin quantity in a UTxO
 */
export const computeMinUtxoValue = (coinsPerUtxoWord: bigint): bigint => coinsPerUtxoWord * 29n;

/**
 * Sum all quantities
 */
export const coalesceValueQuantities = (quantities: Value[]): Value => ({
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins)),
  assets: Asset.util.coalesceTokenMaps(quantities.map(({ assets }) => assets))
});
