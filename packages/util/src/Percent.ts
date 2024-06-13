import { OpaqueNumber } from './opaqueTypes';
import sum from 'lodash/sum.js';

/**
 * The Percentage is a relative value that indicates the hundredth parts of any quantity.
 *
 * One percent 1% (0.01) represents the one hundredth, 2 percent 2% (0.02) represents two hundredths,
 * 100% (1.0) represents the whole, 200% (2.0) twice the given quantity and so on…
 */
export type Percent = OpaqueNumber<'Percent'>;
export const Percent = (value: number): Percent => value as unknown as Percent;

/**
 * Calculates the percentages for each part from {@link total}.
 * When total is omitted, it is assumed that the total is the sum of the parts.
 *
 * @param parts array of integer values
 * @param total optional param to allow sum(parts) to be smaller than the total
 * @returns array of floating point percentages, e.g. [0.1, 0.02, 0.587] is equivalent to 10%, 2%, 58.7%
 */
export const calcPercentages = (parts: number[], total = sum(parts)): Percent[] => {
  if (parts.length === 0) {
    return [];
  }

  let partsSum = sum(parts);

  if (total < partsSum) total = partsSum;

  if (total === 0) {
    // it means all parts are 0
    // set everything to 1 and continue with the normal algorithm
    parts = parts.map(() => 1);
    partsSum = sum(parts);
    total = partsSum;
  }

  return parts.map((part) => Percent(part / total));
};
