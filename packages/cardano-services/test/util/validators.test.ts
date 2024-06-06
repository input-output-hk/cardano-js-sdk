import { OutsideRangeError } from '@cardano-sdk/util';
import { ProviderServerOptionDescriptions } from '../../src/index.js';
import { cacheTtlValidator } from '../../src/util/validators.js';

describe('utils/validators', () => {
  describe('cacheTtlValidator', () => {
    it('returns TTL in seconds with a valid value within the range', async () => {
      expect(
        cacheTtlValidator('240', { lowerBound: 0, upperBound: 500 }, ProviderServerOptionDescriptions.DbCacheTtl)
      ).toEqual(240);
    });

    it('throws a validation error if TTL is not a valid number', async () => {
      const ttl = 'not a number';
      const range = { lowerBound: 0, upperBound: 1 };
      expect(() => cacheTtlValidator(ttl, range, ProviderServerOptionDescriptions.DbCacheTtl)).toThrow(TypeError);
    });

    it('throws a validation error if TTL is lower than the lower limit', async () => {
      const ttl = '9';
      const range = { lowerBound: 10, upperBound: 15 };
      expect(() => cacheTtlValidator(ttl, range, ProviderServerOptionDescriptions.DbCacheTtl)).toThrowError(
        new OutsideRangeError(ttl, range, ProviderServerOptionDescriptions.DbCacheTtl)
      );
    });

    it('throws a validation error if TTL is higher than the upper limit', async () => {
      const ttl = '16';
      const range = { lowerBound: 10, upperBound: 15 };
      expect(() => cacheTtlValidator(ttl, range, ProviderServerOptionDescriptions.DbCacheTtl)).toThrowError(
        new OutsideRangeError(ttl, range, ProviderServerOptionDescriptions.DbCacheTtl)
      );
    });
  });
});
