import * as assetUtil from '../Asset/util';
import { BigIntMath } from '@cardano-sdk/util';
import { Value } from '../Cardano/types/Value';

/** Sum all quantities */
export const coalesceValueQuantities = (quantities: Value[]): Value => ({
  assets: assetUtil.coalesceTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins))
});
