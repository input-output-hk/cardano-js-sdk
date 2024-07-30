import { BigIntMath } from '@cardano-sdk/util';
import { Value } from '../Cardano/types/Value';
import { util } from '../Asset';

/** Subtract all quantities */
export const subtractValueQuantities = (quantities: Value[]) => ({
  assets: util.subtractTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.subtract(quantities.map(({ coins }) => coins))
});
