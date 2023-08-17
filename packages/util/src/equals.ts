import isEqual from 'lodash/isEqual';

export const deepEquals = <T>(a: T, b: T) => isEqual(a, b);

export const strictEquals = <T>(a: T, b: T) => a === b;

export const sameArrayItems = <T>(arrayA: T[], arrayB: T[], itemEquals: (a: T, b: T) => boolean) =>
  arrayA.length === arrayB.length && arrayA.every((a) => arrayB.some((b) => itemEquals(a, b)));
