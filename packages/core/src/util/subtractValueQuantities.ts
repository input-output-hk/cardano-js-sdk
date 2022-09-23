import { BigIntMath } from '@cardano-sdk/util';
import { Value } from '../Cardano';
import { util as assetUtil } from '../Asset';

/**
 * Subtract all quantities
 */
export const subtractValueQuantities = (quantities: Value[]) => ({
  assets: assetUtil.subtractTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.subtract(quantities.map(({ coins }) => coins))
});
