import { generateRandomBigInt, generateRandomHexString } from '../src/index.js';

describe('dataGeneration', () => {
  describe('generateRandomHexString', () => {
    it('generates a valid hex string', () => {
      const hex = generateRandomHexString(10);
      expect(!Number.isNaN(Number(`0x${hex}`))).toBeTruthy();
    });
    it('generates hex string of the correct size', () => {
      const hex = generateRandomHexString(10);
      expect(hex.length).toEqual(10);
    });
  });
  describe('generateRandomBigInt', () => {
    it('generates a bigint between the given range', () => {
      const bigInt = generateRandomBigInt(10_000, 20_000);
      expect(bigInt).toBeLessThanOrEqual(20_000);
      expect(bigInt).toBeGreaterThanOrEqual(10_000);
    });
  });
});
