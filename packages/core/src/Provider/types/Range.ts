/**
 * Base interface to model a range
 */
export interface Range<TBound> {
  /**
   * Inclusive
   */
  lowerBound?: TBound;
  /**
   * Inclusive
   */
  upperBound?: TBound;
}
