import * as assetUtil from '../Asset/util/index.js';
import { BigIntMath } from '@cardano-sdk/util';
import type { Value } from '../Cardano/index.js';

/** Sum all quantities */
export const coalesceValueQuantities = (quantities: Value[]): Value => ({
  assets: assetUtil.coalesceTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins))
});
