import { BigIntMath } from '../../src/util/BigIntMath';

describe('BigIntMath', () => {
  describe('abs', () => {
    test('positive', () => expect(BigIntMath.abs(1n)).toBe(1n));
    test('negative', () => expect(BigIntMath.abs(-1n)).toBe(1n));
  });
  describe('sum', () => {
    test('empty array', () => expect(BigIntMath.sum([])).toBe(0n));
    test('non-empty array', () => expect(BigIntMath.sum([-1n, 5n])).toBe(4n));
  });
  describe('max', () => {
    test('empty array', () => expect(BigIntMath.max([])).toBeNull());
    test('non-empty array', () => expect(BigIntMath.max([-2n, -1n, 0n])).toBe(0n));
  });
});
