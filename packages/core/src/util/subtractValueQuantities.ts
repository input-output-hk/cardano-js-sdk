import { BigIntMath } from '@cardano-sdk/util';
import { util } from '../Asset/index.js';
import type { Value } from '../Cardano/index.js';

/** Subtract all quantities */
export const subtractValueQuantities = (quantities: Value[]) => ({
  assets: util.subtractTokenMaps(quantities.map(({ assets }) => assets)),
  coins: BigIntMath.subtract(quantities.map(({ coins }) => coins))
});
