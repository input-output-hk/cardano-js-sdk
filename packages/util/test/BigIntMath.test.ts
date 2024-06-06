/* eslint-disable sonarjs/no-duplicate-string */
import { BigIntMath } from '../src/BigIntMath.js';

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
  describe('subtract', () => {
    test('empty array', () => expect(BigIntMath.subtract([])).toBe(0n));
    test('non-empty array', () => expect(BigIntMath.subtract([4n, 3n])).toBe(1n));
    test('negative result', () => expect(BigIntMath.subtract([4n, 3n, 4n])).toBe(-3n));
  });
});
