import { resolveObjectValues } from '../src/index.js';

describe('util', () => {
  describe('resolveObjectValues', () => {
    it('resolves all object values which are promises', async () => {
      const result = await resolveObjectValues({
        first: 1,
        second: Promise.resolve(2),
        third: new Promise<number>((resolve) => setTimeout(() => resolve(3), 10))
      });

      expect(result).toEqual({ first: 1, second: 2, third: 3 });
    });
  });
});
