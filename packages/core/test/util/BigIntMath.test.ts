import { BigIntMath } from '../../src/util/BigIntMath';

describe('BigIntMath', () => {
  describe('abs', () => {
    it('positive', () => expect(BigIntMath.abs(1n)).toBe(1n));
    it('negative', () => expect(BigIntMath.abs(-1n)).toBe(1n));
  });
  describe('sum', () => {
    it('empty', () => expect(BigIntMath.sum([])).toBe(0n));
    it('non-empty', () => expect(BigIntMath.sum([-1n, 5n])).toBe(4n));
  });
});
