import { OpaqueNumber } from './opaqueTypes';

/**
 * The Percentage is a relative value that indicates the hundredth parts of any quantity.
 *
 * One percent 1% (0.01) represents the one hundredth, 2 percent 2% (0.02) represents two hundredths,
 * 100% (1.0) represents the whole, 200% (2.0) twice the given quantity and so on…
 */
export type Percent = OpaqueNumber<'Percent'>;
export const Percent = (value: number): Percent => value as unknown as Percent;
