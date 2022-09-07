import isEqual from 'lodash/isEqual';

export const deepEquals = <T>(a: T, b: T) => isEqual(a, b);
