import { Asset } from '../..';
import { BigIntMath } from '@cardano-sdk/util';
import { Value } from '../types';

/**
 * Sum all quantities
 */
export const coalesceValueQuantities = (quantities: Value[]): Value => ({
  assets: Asset.util.coalesceTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins))
});
