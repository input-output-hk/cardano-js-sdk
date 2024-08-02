import * as assetUtil from '../Asset/util';
import { BigIntMath } from '@cardano-sdk/util';
import type { Value } from '../Cardano';

/** Sum all quantities */
export const coalesceValueQuantities = (quantities: Value[]): Value => ({
  assets: assetUtil.coalesceTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins))
});
