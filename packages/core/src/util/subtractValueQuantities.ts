import { BigIntMath } from '@cardano-sdk/util';
import { util } from '../Asset';
import type { Value } from '../Cardano';

/** Subtract all quantities */
export const subtractValueQuantities = (quantities: Value[]) => ({
  assets: util.subtractTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.subtract(quantities.map(({ coins }) => coins))
});
