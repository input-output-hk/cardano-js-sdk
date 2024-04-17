import {
  areNumbersEqualInConstantTime,
  areStringsEqualInConstantTime,
  deepEquals,
  sameArrayItems,
  strictEquals
} from '../src';

describe('equals', () => {
  test('deepEquals', () => {
    expect(deepEquals([], [])).toBe(true);
    expect(deepEquals({}, {})).toBe(true);
    expect(deepEquals([{ prop: 'prop' }], [{ prop: 'prop' }])).toBe(true);
    expect(deepEquals([{ prop: 'prop' }], [{ prop: 'prop2' }])).toBe(false);
  });

  test('strictEquals', () => {
    expect(strictEquals('1', 1 as unknown as string)).toBe(false);
    expect(strictEquals('1', '1')).toBe(true);
  });

  test('sameArrayItems', () => {
    expect(sameArrayItems([], [], strictEquals)).toBe(true);
    expect(sameArrayItems(['a'], ['a', 'b'], strictEquals)).toBe(false);
    expect(sameArrayItems(['a', 'b'], ['a', 'b'], strictEquals)).toBe(true);
    expect(sameArrayItems(['a', 'b'], ['b', 'a'], strictEquals)).toBe(true);
  });

  test('returns true for equal numbers', () => {
    expect(areNumbersEqualInConstantTime(123, 123)).toBe(true);
  });

  test('returns false for different numbers', () => {
    expect(areNumbersEqualInConstantTime(123, 456)).toBe(false);
  });

  test('handles edge cases like zero', () => {
    expect(areNumbersEqualInConstantTime(0, 0)).toBe(true);
    expect(areNumbersEqualInConstantTime(0, 1)).toBe(false);
  });

  test('handles negative numbers', () => {
    expect(areNumbersEqualInConstantTime(-1, -1)).toBe(true);
    expect(areNumbersEqualInConstantTime(-1, 1)).toBe(false);
  });

  test('returns true for identical strings', () => {
    expect(areStringsEqualInConstantTime('hello', 'hello')).toBe(true);
  });

  test('returns false for different strings', () => {
    expect(areStringsEqualInConstantTime('hello', 'world')).toBe(false);
  });

  test('returns false for strings of different lengths', () => {
    expect(areStringsEqualInConstantTime('short', 'longer')).toBe(false);
  });

  test('handles empty strings', () => {
    expect(areStringsEqualInConstantTime('', '')).toBe(true);
    expect(areStringsEqualInConstantTime('', 'nonempty')).toBe(false);
  });

  test('considers character case in comparisons', () => {
    expect(areStringsEqualInConstantTime('case', 'Case')).toBe(false);
  });

  test('returns true for Unicode characters', () => {
    expect(areStringsEqualInConstantTime('😊', '😊')).toBe(true);
    expect(areStringsEqualInConstantTime('😊', '😢')).toBe(false);
  });
});
