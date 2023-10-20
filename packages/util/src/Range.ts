import { CustomError } from 'ts-custom-error';

/** Base interface to model a range */

export interface Range<TBound> {
  /** Inclusive */
  lowerBound?: TBound;
  /** Inclusive */
  upperBound?: TBound;
}

export class InvalidRangeError extends CustomError {
  public constructor(message: string) {
    super();
    this.message = message;
  }
}

export class OutsideRangeError<T, R> extends CustomError {
  public constructor(value: T, { lowerBound, upperBound }: Range<R>, description: string) {
    super();
    this.message = `${description} - ${value} must be between ${lowerBound} and ${upperBound}`;
  }
}

export const throwIfInvalidRange = <T>({ lowerBound, upperBound }: Range<T>): void => {
  if (!lowerBound && !upperBound) {
    throw new InvalidRangeError('Must provide at least one bound');
  } else if (lowerBound === upperBound) {
    throw new InvalidRangeError(`Lower bound: ${lowerBound}, cannot equal upper bound ${upperBound}`);
  } else if (lowerBound && lowerBound > upperBound!) {
    throw new InvalidRangeError(`Lower bound: ${lowerBound}, cannot be larger than upper bound: ${upperBound}`);
  }
};

export const inRange = <T>(value: T, range: Range<T>): boolean => {
  throwIfInvalidRange(range);
  const { lowerBound, upperBound } = range;
  if (!lowerBound && upperBound) {
    return value <= upperBound;
  } else if (lowerBound && !upperBound) {
    return value >= lowerBound;
  }
  return value >= lowerBound! && value <= upperBound!;
};

export const throwIfOutsideRange = <T>(value: T, range: Range<T>, description: string): void => {
  if (!inRange(value, range)) {
    throw new OutsideRangeError(value, range, description);
  }
};
