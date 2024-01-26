/* eslint-disable complexity,sonarjs/cognitive-complexity */
import * as Cardano from '../../Cardano';
import uniq from 'lodash/uniq';

/**
 * Given two Cardano.TokenMaps, compute a Cardano.TokenMap with the difference between the left-hand side and the right-hand side.
 *
 * @param lhs the left-hand side of the subtraction operation.
 * @param rhs the right-hand side of the subtraction operation.
 * @returns The difference between both Cardano.TokenMaps.
 */
export const subtractMaps = (
  lhs: Cardano.TokenMap | undefined,
  rhs: Cardano.TokenMap | undefined
): Cardano.TokenMap | undefined => {
  if (!rhs) {
    if (!lhs) return undefined;

    const nonEmptyValues = new Map<Cardano.AssetId, bigint>();

    for (const [key, value] of lhs.entries()) {
      if (value !== 0n) nonEmptyValues.set(key, value);
    }

    return nonEmptyValues;
  }

  if (!lhs) {
    const negativeValues = new Map<Cardano.AssetId, bigint>();

    for (const [key, value] of rhs.entries()) {
      if (value !== 0n) negativeValues.set(key, -value);
    }

    return negativeValues;
  }

  const result = new Map<Cardano.AssetId, bigint>();
  const intersection = new Array<Cardano.AssetId>();

  // any element that is present in the lhs and not in the rhs will be added as a positive value
  for (const [key, value] of lhs.entries()) {
    if (rhs.has(key)) {
      intersection.push(key);
      continue;
    }

    if (value !== 0n) result.set(key, value);
  }

  // any element that is present in the rhs and not in the lhs will be added as a negative value
  for (const [key, value] of rhs.entries()) {
    if (lhs.has(key)) {
      intersection.push(key);
      continue;
    }

    if (value !== 0n) result.set(key, -value);
  }

  // Elements present in both maps will be subtracted (lhs - rhs)
  const uniqIntersection = uniq(intersection);

  for (const id of uniqIntersection) {
    const lshVal = lhs.get(id);
    const rshVal = rhs.get(id);
    const remainingCoins = lshVal! - rshVal!;

    if (remainingCoins !== 0n) result.set(id, remainingCoins);
  }

  return result;
};

/** Subtract asset quantities in order */
export const subtractTokenMaps = (assets: (Cardano.TokenMap | undefined)[]): Cardano.TokenMap | undefined => {
  if (!assets || assets.length === 0) return undefined;

  return assets.reduce(subtractMaps);
};
