import { InvalidRangeError, inRange, throwIfInvalidRange } from '../src/Range.js';

describe('Range', () => {
  describe('throwIfInvalidRange', () => {
    test('lower bound only', () => {
      expect(() => throwIfInvalidRange({ lowerBound: 2 })).not.toThrow(InvalidRangeError);
    });
    test('upper bound only', () => {
      expect(() => throwIfInvalidRange({ upperBound: 4 })).not.toThrow(InvalidRangeError);
    });
    test('lower bound lower than upper bound', () => {
      expect(() => throwIfInvalidRange({ lowerBound: 2, upperBound: 4 })).not.toThrow(InvalidRangeError);
    });
    test('lower equal to upper bound', () => {
      expect(() => throwIfInvalidRange({ lowerBound: 4, upperBound: 4 })).toThrow(InvalidRangeError);
    });
    test('lower bound higher than upper bound', () => {
      expect(() => throwIfInvalidRange({ lowerBound: 5, upperBound: 4 })).toThrow(InvalidRangeError);
    });
    test('negative lower bound', () => {
      expect(() => throwIfInvalidRange({ lowerBound: -1 })).not.toThrow(InvalidRangeError);
    });
  });
  describe('inRange', () => {
    describe('only lower bound', () => {
      const range = { lowerBound: 2 };
      test('x lower than lower bound', () => {
        expect(inRange(1, range)).toBe(false);
      });
      test('x equal to lower bound', () => {
        expect(inRange(2, range)).toBe(true);
      });
      test('x higher than lower bound', () => {
        expect(inRange(3, range)).toBe(true);
      });
    });
    describe('lower and upper bound', () => {
      const range = { lowerBound: 2, upperBound: 4 };
      test('x lower than lower bound', () => {
        expect(inRange(1, range)).toBe(false);
      });
      test('x equal to lower bound', () => {
        expect(inRange(2, range)).toBe(true);
      });
      test('x higher than lower bound, less than upper bound', () => {
        expect(inRange(3, range)).toBe(true);
      });
      test('x equal to upper bound', () => {
        expect(inRange(4, range)).toBe(true);
      });
      test('x higher than upper bound', () => {
        expect(inRange(5, range)).toBe(false);
      });
    });
    describe('only upper bound', () => {
      const range = { upperBound: 4 };
      test('x lower than upper bound', () => {
        expect(inRange(1, range)).toBe(true);
      });
      test('x equal to upper bound', () => {
        expect(inRange(4, range)).toBe(true);
      });
      test('x higher than upper bound', () => {
        expect(inRange(5, range)).toBe(false);
      });
    });
  });
});
